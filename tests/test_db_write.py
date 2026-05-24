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
