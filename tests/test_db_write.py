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
