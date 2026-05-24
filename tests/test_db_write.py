import pytest
from unittest.mock import MagicMock, patch, call


def _configure_db():
    from utils import db
    db._conn_params = {
        "host": "localhost", "port": 3306,
        "database": "c02", "user": "u", "password": "p", "charset": "latin1",
    }


def _make_conn(cursor):
    conn = MagicMock()
    conn.cursor.return_value = cursor
    return conn


def test_verify_patients_sql_has_rank_filter():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = []
    with patch("mysql.connector.connect", return_value=_make_conn(mock_cursor)):
        db.verify_patients([{"mbi": "1AA0AA0AA11"}])
    sql = mock_cursor.execute.call_args[0][0]
    assert "Rank = 1" in sql
    assert "InactiveDate IS NULL" in sql


def test_verify_patients_sql_includes_icd10_columns():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = []
    with patch("mysql.connector.connect", return_value=_make_conn(mock_cursor)):
        db.verify_patients([{"mbi": "1AA0AA0AA11"}])
    sql = mock_cursor.execute.call_args[0][0]
    assert "ICD10_01" in sql
    assert "ICD10_12" in sql


def test_verify_patients_sql_includes_gender_height_weight():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = []
    with patch("mysql.connector.connect", return_value=_make_conn(mock_cursor)):
        db.verify_patients([{"mbi": "1AA0AA0AA11"}])
    sql = mock_cursor.execute.call_args[0][0]
    assert "Gender" in sql
    assert "Height" in sql
    assert "Weight" in sql


def test_validate_icd10_codes_returns_invalid_set():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = [("M54.5",)]
    with patch("mysql.connector.connect", return_value=_make_conn(mock_cursor)):
        result = db.validate_icd10_codes(["M54.5", "BADCODE"])
    assert result == {"BADCODE"}


def test_validate_icd10_codes_empty_input():
    _configure_db()
    from utils import db
    with patch("mysql.connector.connect") as mock_connect:
        result = db.validate_icd10_codes([])
    assert result == set()
    mock_connect.assert_not_called()


def test_validate_icd10_codes_all_valid():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = [("M54.5",), ("Z96.641",)]
    with patch("mysql.connector.connect", return_value=_make_conn(mock_cursor)):
        result = db.validate_icd10_codes(["M54.5", "Z96.641"])
    assert result == set()


def test_insert_doctor_dry_run_skips_execute():
    _configure_db()
    from utils import db
    with patch("mysql.connector.connect") as mock_connect:
        result = db.insert_doctor(
            {"first": "John", "last": "Smith", "npi": "1234567890"}, dry_run=True
        )
    assert result is None
    mock_connect.assert_not_called()


def test_insert_doctor_live_executes_and_calls_mir():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.lastrowid = 42
    with patch("mysql.connector.connect", return_value=_make_conn(mock_cursor)):
        result = db.insert_doctor(
            {"first": "John", "last": "Smith", "npi": "1234567890",
             "mi": "A", "suffix": "MD", "courtesy": "Dr.",
             "address1": "1 Main St", "address2": "", "city": "NYC",
             "state": "NY", "zip": "10001", "phone": "2125550100", "fax": ""},
            dry_run=False,
        )
    assert result == 42
    execute_calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert any("INSERT" in c for c in execute_calls)
    assert any("mir_update_doctor" in c for c in execute_calls)


def test_insert_doctor_middle_name_truncated_to_one_char():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.lastrowid = 1
    with patch("mysql.connector.connect", return_value=_make_conn(mock_cursor)):
        db.insert_doctor(
            {"first": "J", "last": "S", "npi": "1", "mi": "AB"},
            dry_run=False,
        )
    insert_params = mock_cursor.execute.call_args_list[0][0][1]
    mi_index = 2
    assert insert_params[mi_index] == "A"


def test_insert_insurance_company_dry_run_skips():
    _configure_db()
    from utils import db
    with patch("mysql.connector.connect") as mock_connect:
        result = db.insert_insurance_company("Test Ins Co", dry_run=True)
    assert result is None
    mock_connect.assert_not_called()


def test_insert_insurance_company_live_executes_and_calls_mir():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.lastrowid = 5
    with patch("mysql.connector.connect", return_value=_make_conn(mock_cursor)):
        result = db.insert_insurance_company("Test Ins Co", dry_run=False)
    assert result == 5
    execute_calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert any("INSERT" in c and "tbl_insurancecompany" in c for c in execute_calls)
    assert any("mir_update_insurancecompany" in c for c in execute_calls)


def test_insert_patient_dry_run_skips():
    _configure_db()
    from utils import db
    patient = {
        "first": "Jane", "last": "Doe", "mi": "A", "suffix": "",
        "dob": "01/15/1950", "mbi": "1AA0AA0AA11",
        "address1": "1 Main", "address2": "", "city": "Trenton",
        "state": "NJ", "zip": "08610", "phone": "6095550100",
        "gender": "Female", "height": "65.0", "weight": "140.0",
        "icd10": ["M54.5"],
        "secondary": None,
        "_doctor": {"npi": "1234567890"},
        "_notion_page_id": "page-uuid",
    }
    with patch("mysql.connector.connect") as mock_connect:
        result = db.insert_patient(patient, {"NJ": "Medicare Region A"}, dry_run=True)
    assert result is None
    mock_connect.assert_not_called()


def test_insert_patient_live_runs_transaction():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.fetchone.side_effect = [
        (100,),    # MAX AccountNumber
        (7,),      # doctor ID lookup
        (3,),      # primary insurance ID lookup
    ]
    mock_cursor.lastrowid = 9
    conn_mock = MagicMock()
    conn_mock.cursor.return_value = mock_cursor
    patient = {
        "first": "Jane", "last": "Doe", "mi": "A", "suffix": "",
        "dob": "01/15/1950", "mbi": "1AA0AA0AA11",
        "address1": "1 Main", "address2": "", "city": "Trenton",
        "state": "NJ", "zip": "08610", "phone": "6095550100",
        "gender": "Female", "height": "65.0", "weight": "140.0",
        "icd10": ["M54.5"],
        "secondary": None,
        "_doctor": {"npi": "1234567890"},
    }
    with patch("mysql.connector.connect", return_value=conn_mock):
        result = db.insert_patient(patient, {"NJ": "Medicare Region A"}, dry_run=False)
    assert result == 9
    conn_mock.start_transaction.assert_called_once()
    conn_mock.commit.assert_called_once()
    execute_calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert any("INSERT INTO tbl_customer" in c for c in execute_calls)
    assert any("tbl_customer_insurance" in c for c in execute_calls)
    assert any("mir_update_customer" in c and "mir_update_customer_insurance" not in c for c in execute_calls)
    assert any("mir_update_customer_insurance" in c for c in execute_calls)


def test_insert_patient_rollback_on_error():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.fetchone.side_effect = [
        (100,),
        (7,),
        None,  # insurance not found → triggers RuntimeError
    ]
    conn_mock = MagicMock()
    conn_mock.cursor.return_value = mock_cursor
    patient = {
        "first": "Jane", "last": "Doe", "mi": "", "suffix": "",
        "dob": "01/15/1950", "mbi": "1AA0AA0AA11",
        "address1": "", "address2": "", "city": "", "state": "NJ",
        "zip": "", "phone": "", "gender": "Female",
        "height": "", "weight": "",
        "icd10": [], "secondary": None,
        "_doctor": {"npi": "1"},
    }
    with patch("mysql.connector.connect", return_value=conn_mock):
        with pytest.raises(RuntimeError, match="not found"):
            db.insert_patient(patient, {"NJ": "Missing Co"}, dry_run=False)
    conn_mock.rollback.assert_called_once()


def test_insert_patient_secondary_inserts_rank2():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.fetchone.side_effect = [
        (100,),  # MAX acct
        (7,),    # doctor ID
        (3,),    # primary insurance ID
        (4,),    # secondary insurance ID
    ]
    mock_cursor.lastrowid = 9
    conn_mock = MagicMock()
    conn_mock.cursor.return_value = mock_cursor
    patient = {
        "first": "Jane", "last": "Doe", "mi": "", "suffix": "",
        "dob": "01/15/1950", "mbi": "1AA0AA0AA11",
        "address1": "", "address2": "", "city": "", "state": "NJ",
        "zip": "", "phone": "", "gender": "Female",
        "height": "", "weight": "",
        "icd10": [],
        "secondary": {"ins_company": "Aetna", "ins_type": "COMMERCIAL_GROUP", "policy": "X123"},
        "_doctor": {"npi": "1"},
    }
    with patch("mysql.connector.connect", return_value=conn_mock):
        db.insert_patient(patient, {"NJ": "Medicare"}, dry_run=False)
    execute_calls = [str(c) for c in mock_cursor.execute.call_args_list]
    ins_inserts = [c for c in execute_calls if "tbl_customer_insurance" in c and "INSERT" in c]
    assert len(ins_inserts) == 2


def test_insert_patient_empty_gender_defaults_to_male():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.fetchone.side_effect = [(100,), (7,), (3,)]
    mock_cursor.lastrowid = 9
    conn_mock = MagicMock()
    conn_mock.cursor.return_value = mock_cursor
    patient = {
        "first": "Jane", "last": "Doe", "mi": "", "suffix": "",
        "dob": "01/15/1950", "mbi": "1AA0AA0AA11",
        "address1": "", "address2": "", "city": "", "state": "NJ",
        "zip": "", "phone": "", "gender": "",
        "height": "", "weight": "",
        "icd10": [], "secondary": None, "notes": "",
        "_doctor": {"npi": "1234567890"},
    }
    with patch("mysql.connector.connect", return_value=conn_mock):
        db.insert_patient(patient, {"NJ": "Medicare"}, dry_run=False)
    insert_params = mock_cursor.execute.call_args_list[3][0][1]
    gender_index = 17
    assert insert_params[gender_index] == "Male"


def test_insert_patient_with_notes_inserts_customer_notes():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.fetchone.side_effect = [
        (100,),  # MAX acct
        (7,),    # doctor ID
        (3,),    # primary insurance ID
    ]
    mock_cursor.lastrowid = 9
    conn_mock = MagicMock()
    conn_mock.cursor.return_value = mock_cursor
    patient = {
        "first": "Jane", "last": "Doe", "mi": "", "suffix": "",
        "dob": "01/15/1950", "mbi": "1AA0AA0AA11",
        "address1": "", "address2": "", "city": "", "state": "NJ",
        "zip": "", "phone": "", "gender": "Female",
        "height": "", "weight": "",
        "icd10": [],
        "secondary": None,
        "notes": "Patient requires wheelchair ramp.",
        "_doctor": {"npi": "1234567890"},
    }
    with patch("mysql.connector.connect", return_value=conn_mock):
        db.insert_patient(patient, {"NJ": "Medicare"}, dry_run=False)
    execute_calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert any("tbl_customer_notes" in c for c in execute_calls)


def test_insert_patient_no_notes_skips_customer_notes():
    _configure_db()
    from utils import db
    mock_cursor = MagicMock()
    mock_cursor.fetchone.side_effect = [
        (100,),  # MAX acct
        (7,),    # doctor ID
        (3,),    # primary insurance ID
    ]
    mock_cursor.lastrowid = 9
    conn_mock = MagicMock()
    conn_mock.cursor.return_value = mock_cursor
    patient = {
        "first": "Jane", "last": "Doe", "mi": "", "suffix": "",
        "dob": "01/15/1950", "mbi": "1AA0AA0AA11",
        "address1": "", "address2": "", "city": "", "state": "NJ",
        "zip": "", "phone": "", "gender": "Female",
        "height": "", "weight": "",
        "icd10": [],
        "secondary": None,
        "notes": "",
        "_doctor": {"npi": "1234567890"},
    }
    with patch("mysql.connector.connect", return_value=conn_mock):
        db.insert_patient(patient, {"NJ": "Medicare"}, dry_run=False)
    execute_calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert not any("tbl_customer_notes" in c for c in execute_calls)


def test_backup_databases_calls_mysqldump(tmp_path):
    _configure_db()
    from utils import db
    with patch("utils.creds.get_mysql_creds", return_value=("user", "pass")), \
         patch("subprocess.run") as mock_run, \
         patch("builtins.open", MagicMock()):
        mock_run.return_value = MagicMock(returncode=0, stderr="")
        result = db.backup_databases(str(tmp_path))
    cmd = mock_run.call_args[0][0]
    assert "mysqldump" in cmd[0]
    assert "--databases" in cmd
    assert "c02" in cmd
    assert "dmeworks" in cmd
    assert result.endswith(".sql")


def test_backup_databases_raises_on_failure(tmp_path):
    _configure_db()
    from utils import db
    with patch("utils.creds.get_mysql_creds", return_value=("user", "pass")), \
         patch("subprocess.run") as mock_run, \
         patch("builtins.open", MagicMock()):
        mock_run.return_value = MagicMock(returncode=1, stderr="access denied")
        with pytest.raises(RuntimeError, match="mysqldump failed"):
            db.backup_databases(str(tmp_path))
