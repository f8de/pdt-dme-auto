# DME Auto Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace pywinauto UI entry with direct MySQL writes, fixing all known bugs and hardening for production.

**Architecture:** `ingest.py` implements an 8-step flow (backup → fetch → validate → DB checks → insert doctors → insert insurance companies → insert patients → verify). All writes are parameterized SQL inside transactions. Dry-run is the default; `--live` flag triggers real writes. pywinauto is retained only in diagnostic tools.

**Tech Stack:** Python 3.11, mysql-connector-python, requests (Notion API), Doppler (secrets), pytest + unittest.mock

---

## File Map

| File | Action | Notes |
|---|---|---|
| `utils/logger.py` | Modify | Rotating daily logs, 30-day retention |
| `config/clients.json` | Create | Client code → display name + DB name |
| `utils/validate.py` | Create | MBI regex, all validation logic |
| `utils/db.py` | Modify | Fix verify_patients; add validate_icd10_codes, insert_doctor, insert_insurance_company, insert_patient, backup_databases |
| `utils/ui.py` | Create | Shared pywinauto utilities extracted from both entry files |
| `ingest.py` | Create | Main entry — replaces `entry_all.py` |
| `ingest_test.py` | Create | Test client wrapper — replaces `entry_test.py` |
| `run.py` | Modify | Wire ingest/ingest_test dispatch modes; remove entry_all/entry_test |
| `packaging/dmeworks.spec` | Modify | Update hiddenimports; add clients.json to datas |
| `tests/test_logger.py` | Create | Rotating log tests |
| `tests/test_validate.py` | Create | MBI regex + validation rule tests |
| `tests/test_db_write.py` | Create | Insert function tests (mocked connector) |
| `tests/test_notion_parse.py` | Modify | Add gender/height/weight/fax/courtesy fields to fixtures |

---

## Task 1: Logger — rotating daily files + 30-day purge

**Files:**
- Modify: `utils/logger.py`
- Create: `tests/test_logger.py`

- [ ] **Step 1: Write the failing tests**

```python
# tests/test_logger.py
import logging
import os
import time
from datetime import datetime
from pathlib import Path
from unittest.mock import patch
import tempfile
import pytest


def _fresh_logger(name: str, log_dir: str):
    # Remove any cached logger to force re-initialization
    existing = logging.getLogger(name)
    for h in existing.handlers[:]:
        existing.removeHandler(h)
    import utils.logger as ul
    with patch("utils.logger._log_dir", return_value=log_dir):
        return ul.get_logger(name)


def test_logger_uses_daily_filename():
    with tempfile.TemporaryDirectory() as tmpdir:
        logger = _fresh_logger("test_daily", tmpdir)
        fh = next(h for h in logger.handlers if isinstance(h, logging.FileHandler))
        today = datetime.now().strftime("%Y-%m-%d")
        assert today in fh.baseFilename


def test_logger_appends_not_overwrites():
    with tempfile.TemporaryDirectory() as tmpdir:
        logger = _fresh_logger("test_append", tmpdir)
        fh = next(h for h in logger.handlers if isinstance(h, logging.FileHandler))
        assert fh.mode == "a"


def test_logger_purges_old_log_files():
    with tempfile.TemporaryDirectory() as tmpdir:
        old = Path(tmpdir) / "dme-auto-2020-01-01.log"
        old.write_text("stale")
        old_mtime = time.time() - (31 * 86400)
        os.utime(old, (old_mtime, old_mtime))
        _fresh_logger("test_purge", tmpdir)
        assert not old.exists()


def test_logger_keeps_recent_log_files():
    with tempfile.TemporaryDirectory() as tmpdir:
        recent = Path(tmpdir) / "dme-auto-2099-12-31.log"
        recent.write_text("keep me")
        _fresh_logger("test_keep", tmpdir)
        assert recent.exists()
```

- [ ] **Step 2: Run tests to verify they fail**

```
pytest tests/test_logger.py -v
```
Expected: FAIL — daily filename, append mode, purge not yet implemented.

- [ ] **Step 3: Update `utils/logger.py`**

Replace the entire `get_logger` function with:

```python
import logging
import os
import re
import sys
import time
from datetime import datetime


_FMT     = "[%(asctime)s] %(levelname)-8s  %(name)-10s  %(message)s"
_DATEFMT = "%Y-%m-%d %H:%M:%S"
_KEEP_DAYS = 30


def _log_dir() -> str:
    if getattr(sys, "frozen", False):
        return os.path.join(os.path.dirname(sys.executable), "logs")
    return os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "logs")


def _purge_old_logs(log_dir: str) -> None:
    cutoff = time.time() - _KEEP_DAYS * 86400
    for fname in os.listdir(log_dir):
        if fname.startswith("dme-auto-") and fname.endswith(".log"):
            fpath = os.path.join(log_dir, fname)
            try:
                if os.path.getmtime(fpath) < cutoff:
                    os.remove(fpath)
            except OSError:
                pass


def get_logger(name: str = "dmeworks") -> logging.Logger:
    log_dir = _log_dir()
    os.makedirs(log_dir, exist_ok=True)
    _purge_old_logs(log_dir)
    log_file = os.path.join(log_dir, f"dme-auto-{datetime.now():%Y-%m-%d}.log")

    logger = logging.getLogger(name)
    if logger.handlers:
        return logger

    logger.setLevel(logging.DEBUG)

    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    ch.setFormatter(logging.Formatter(_FMT, _DATEFMT))

    fh = logging.FileHandler(log_file, mode="a", encoding="utf-8")
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(logging.Formatter(_FMT, _DATEFMT))

    logger.addHandler(ch)
    logger.addHandler(fh)

    return logger


def mask_mbi(mbi: str) -> str:
    """1EG4TE5MK72 -> 1EG4-***-****"""
    clean = re.sub(r"[-\s]", "", mbi)
    prefix = clean[:4] if len(clean) >= 4 else clean
    return f"{prefix}-***-****"


def mask_dob(dob: str) -> str:
    return "**/**/****"
```

- [ ] **Step 4: Run tests to verify they pass**

```
pytest tests/test_logger.py -v
```
Expected: 4 PASSED.

- [ ] **Step 5: Commit**

```bash
git add utils/logger.py tests/test_logger.py
git commit -m "fix: rotating daily log files, 30-day retention"
```

---

## Task 2: config/clients.json

**Files:**
- Create: `config/clients.json`

- [ ] **Step 1: Read the existing database_reference.json to verify db names**

```bash
cat config/database_reference.json
```
Expected to show: `{"allied": "c02", "test": "c01"}` (or similar).

- [ ] **Step 2: Create `config/clients.json`**

```json
{
  "allied": {
    "name": "Allied",
    "db": "c02"
  },
  "c01": {
    "name": "Test (c01)",
    "db": "c01"
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add config/clients.json
git commit -m "feat: add clients.json client code to DB name mapping"
```

---

## Task 3: Create `utils/validate.py`

**Files:**
- Create: `utils/validate.py`
- Create: `tests/test_validate.py`

- [ ] **Step 1: Write the failing tests**

```python
# tests/test_validate.py
import pytest


def test_mbi_regex_accepts_valid_format():
    from utils.validate import MBI_RE
    # Format: N-A-AN-N-A-AN-AN-A-A-N-N
    assert MBI_RE.match("1AA0AA0AA11")
    assert MBI_RE.match("9YY9YY9YY99")
    assert MBI_RE.match("1EG4TE5MK72")  # known valid format


def test_mbi_regex_rejects_starts_with_zero():
    from utils.validate import MBI_RE
    assert not MBI_RE.match("0AA0AA0AA11")


def test_mbi_regex_rejects_excluded_letters():
    from utils.validate import MBI_RE
    # B excluded at position 2
    assert not MBI_RE.match("1BA0AA0AA11")
    # I excluded at position 2
    assert not MBI_RE.match("1IA0AA0AA11")


def test_mbi_regex_rejects_wrong_length():
    from utils.validate import MBI_RE
    assert not MBI_RE.match("1AA0AA0AA1")   # 10 chars
    assert not MBI_RE.match("1AA0AA0AA111") # 12 chars


def test_validate_patient_passes_with_all_required():
    from utils.validate import validate_patient
    patient = {
        "mbi": "1AA0AA0AA11",
        "dob": "01/15/1950",
        "state": "NJ",
        "gender": "Male",
        "_doctor": {"npi": "1234567890"},
    }
    errors = validate_patient(patient, {"NJ": "Medicare DMERC"})
    assert errors == []


def test_validate_patient_missing_mbi():
    from utils.validate import validate_patient
    patient = {"mbi": "", "dob": "01/15/1950", "state": "NJ",
               "gender": "Male", "_doctor": {"npi": "1"}}
    errors = validate_patient(patient, {"NJ": "x"})
    assert any("missing MBI" in e for e in errors)


def test_validate_patient_invalid_mbi_format():
    from utils.validate import validate_patient
    patient = {"mbi": "BADMBI", "dob": "01/15/1950", "state": "NJ",
               "gender": "Male", "_doctor": {"npi": "1"}}
    errors = validate_patient(patient, {"NJ": "x"})
    assert any("invalid MBI" in e for e in errors)


def test_validate_patient_missing_dob():
    from utils.validate import validate_patient
    patient = {"mbi": "1AA0AA0AA11", "dob": "", "state": "NJ",
               "gender": "Male", "_doctor": {"npi": "1"}}
    errors = validate_patient(patient, {"NJ": "x"})
    assert any("missing DOB" in e for e in errors)


def test_validate_patient_bad_dob_format():
    from utils.validate import validate_patient
    patient = {"mbi": "1AA0AA0AA11", "dob": "1950-01-15", "state": "NJ",
               "gender": "Male", "_doctor": {"npi": "1"}}
    errors = validate_patient(patient, {"NJ": "x"})
    assert any("DOB" in e for e in errors)


def test_validate_patient_state_not_in_map():
    from utils.validate import validate_patient
    patient = {"mbi": "1AA0AA0AA11", "dob": "01/15/1950", "state": "ZZ",
               "gender": "Male", "_doctor": {"npi": "1"}}
    errors = validate_patient(patient, {"NJ": "x"})
    assert any("not in insurance map" in e for e in errors)


def test_validate_patient_missing_state():
    from utils.validate import validate_patient
    patient = {"mbi": "1AA0AA0AA11", "dob": "01/15/1950", "state": "",
               "gender": "Male", "_doctor": {"npi": "1"}}
    errors = validate_patient(patient, {"NJ": "x"})
    assert any("missing state" in e for e in errors)


def test_validate_patient_no_npi():
    from utils.validate import validate_patient
    patient = {"mbi": "1AA0AA0AA11", "dob": "01/15/1950", "state": "NJ",
               "gender": "Male", "_doctor": {}}
    errors = validate_patient(patient, {"NJ": "x"})
    assert any("NPI" in e for e in errors)


def test_validate_patient_bad_gender():
    from utils.validate import validate_patient
    patient = {"mbi": "1AA0AA0AA11", "dob": "01/15/1950", "state": "NJ",
               "gender": "Unknown", "_doctor": {"npi": "1"}}
    errors = validate_patient(patient, {"NJ": "x"})
    assert any("gender" in e for e in errors)


def test_validate_patient_female_gender_passes():
    from utils.validate import validate_patient
    patient = {"mbi": "1AA0AA0AA11", "dob": "01/15/1950", "state": "NJ",
               "gender": "Female", "_doctor": {"npi": "1"}}
    errors = validate_patient(patient, {"NJ": "x"})
    assert not any("gender" in e for e in errors)


def test_validate_secondary_valid():
    from utils.validate import validate_secondary
    sec = {"ins_company": "Aetna", "ins_type": "COMMERCIAL_GROUP", "policy": "XYZ"}
    assert validate_secondary(sec) == []


def test_validate_secondary_missing_key():
    from utils.validate import validate_secondary
    sec = {"ins_company": "Aetna", "policy": "XYZ"}  # missing ins_type
    errors = validate_secondary(sec)
    assert any("ins_type" in e for e in errors)


def test_validate_secondary_bad_ins_type():
    from utils.validate import validate_secondary
    sec = {"ins_company": "Aetna", "ins_type": "BADTYPE", "policy": "XYZ"}
    errors = validate_secondary(sec)
    assert any("ins_type" in e and "invalid" in e for e in errors)


def test_validate_secondary_all_valid_types_pass():
    from utils.validate import validate_secondary, VALID_INS_TYPES
    for t in VALID_INS_TYPES:
        sec = {"ins_company": "Co", "ins_type": t, "policy": "P"}
        assert validate_secondary(sec) == [], f"Type {t} should be valid"


def test_validate_patient_with_valid_secondary():
    from utils.validate import validate_patient
    patient = {
        "mbi": "1AA0AA0AA11",
        "dob": "01/15/1950",
        "state": "NJ",
        "gender": "Male",
        "_doctor": {"npi": "1"},
        "secondary": {"ins_company": "Aetna", "ins_type": "COMMERCIAL_GROUP", "policy": "X"},
    }
    errors = validate_patient(patient, {"NJ": "x"})
    assert errors == []


def test_validate_patient_with_invalid_secondary():
    from utils.validate import validate_patient
    patient = {
        "mbi": "1AA0AA0AA11",
        "dob": "01/15/1950",
        "state": "NJ",
        "gender": "Male",
        "_doctor": {"npi": "1"},
        "secondary": {"ins_company": "Aetna", "ins_type": "WRONG", "policy": "X"},
    }
    errors = validate_patient(patient, {"NJ": "x"})
    assert any("ins_type" in e for e in errors)
```

- [ ] **Step 2: Run tests to verify they fail**

```
pytest tests/test_validate.py -v
```
Expected: FAIL — module `utils.validate` not found.

- [ ] **Step 3: Create `utils/validate.py`**

```python
import re
from datetime import datetime

from utils.logger import mask_mbi

MBI_RE = re.compile(
    r'^[1-9][AC-HJ-NP-RT-Y][0-9AC-HJ-NP-RT-Y][0-9]'
    r'[AC-HJ-NP-RT-Y][0-9AC-HJ-NP-RT-Y][0-9AC-HJ-NP-RT-Y]'
    r'[AC-HJ-NP-RT-Y][AC-HJ-NP-RT-Y][0-9][0-9]$'
)

VALID_INS_TYPES = frozenset({
    "MEDICARE", "MEDICAID", "MEDIGAP",
    "SUPPLEMENTAL", "COMMERCIAL_GROUP", "COMMERCIAL_INDIVIDUAL",
})


def validate_patient(patient: dict, insurance_map: dict) -> list[str]:
    """Return list of error strings. Empty = valid."""
    errors: list[str] = []
    mbi = patient.get("mbi", "")
    label = f"MBI {mask_mbi(mbi)}" if mbi else "Patient(no MBI)"

    if not mbi:
        errors.append(f"{label}: missing MBI")
    elif not MBI_RE.match(mbi):
        errors.append(f"{label}: invalid MBI format")

    dob = patient.get("dob", "")
    if not dob:
        errors.append(f"{label}: missing DOB")
    else:
        try:
            datetime.strptime(dob, "%m/%d/%Y")
        except ValueError:
            errors.append(f"{label}: invalid DOB '{dob}' — expected MM/DD/YYYY")

    state = patient.get("state", "")
    if not state:
        errors.append(f"{label}: missing state")
    elif state not in insurance_map:
        errors.append(f"{label}: state '{state}' not in insurance map")

    if not patient.get("_doctor", {}).get("npi"):
        errors.append(f"{label}: doctor has no NPI")

    gender = patient.get("gender", "")
    if gender not in ("Male", "Female"):
        errors.append(f"{label}: gender '{gender}' must be Male or Female")

    sec = patient.get("secondary")
    if sec is not None:
        errors.extend(validate_secondary(sec, label))

    return errors


def validate_secondary(sec: dict, label: str = "Secondary insurance") -> list[str]:
    """Return list of error strings for the secondary insurance dict."""
    errors: list[str] = []
    for key in ("ins_company", "ins_type", "policy"):
        if not sec.get(key):
            errors.append(f"{label}: secondary insurance missing key '{key}'")
    ins_type = sec.get("ins_type", "")
    if ins_type and ins_type not in VALID_INS_TYPES:
        errors.append(
            f"{label}: secondary ins_type '{ins_type}' invalid "
            f"— must be one of {sorted(VALID_INS_TYPES)}"
        )
    return errors
```

- [ ] **Step 4: Run tests to verify they pass**

```
pytest tests/test_validate.py -v
```
Expected: 20 PASSED.

- [ ] **Step 5: Commit**

```bash
git add utils/validate.py tests/test_validate.py
git commit -m "feat: add validate.py — MBI regex + patient/secondary validation"
```

---

## Task 4: `utils/db.py` — fix `verify_patients` + add `validate_icd10_codes`

**Files:**
- Modify: `utils/db.py`
- Create: `tests/test_db_write.py` (skeleton for this + Tasks 5 & 6)

- [ ] **Step 1: Write failing tests**

```python
# tests/test_db_write.py
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
```

- [ ] **Step 2: Run tests to verify they fail**

```
pytest tests/test_db_write.py::test_verify_patients_sql_has_rank_filter tests/test_db_write.py::test_validate_icd10_codes_returns_invalid_set -v
```
Expected: FAIL.

- [ ] **Step 3: Update `utils/db.py` — fix `verify_patients` and add `validate_icd10_codes`**

Replace the entire `verify_patients` function (lines 107–139) with:

```python
def verify_patients(patients: list[dict]) -> dict[str, dict]:
    """
    Deep verification: joins customer + primary insurance + doctor.
    Returns dict keyed by MBI. Only primary insurance (Rank=1, InactiveDate IS NULL).
    """
    mbis = [p["mbi"] for p in patients]
    if not mbis:
        return {}
    ph = ",".join(["%s"] * len(mbis))
    conn = _connect()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(f"""
            SELECT
                ci.PolicyNumber  AS mbi,
                c.FirstName      AS first,
                c.LastName       AS last,
                c.DateofBirth    AS dob,
                c.Address1       AS address1,
                c.City           AS city,
                c.State          AS state,
                c.Zip            AS zip,
                c.Gender         AS gender,
                c.Height         AS height,
                c.Weight         AS weight,
                d.NPI            AS doctor_npi,
                d.LastName       AS doctor_last,
                d.FirstName      AS doctor_first,
                c.ICD10_01       AS icd10_01,
                c.ICD10_02       AS icd10_02,
                c.ICD10_03       AS icd10_03,
                c.ICD10_04       AS icd10_04,
                c.ICD10_05       AS icd10_05,
                c.ICD10_06       AS icd10_06,
                c.ICD10_07       AS icd10_07,
                c.ICD10_08       AS icd10_08,
                c.ICD10_09       AS icd10_09,
                c.ICD10_10       AS icd10_10,
                c.ICD10_11       AS icd10_11,
                c.ICD10_12       AS icd10_12
            FROM tbl_customer_insurance ci
            JOIN tbl_customer c  ON c.ID = ci.CustomerID
            LEFT JOIN tbl_doctor d ON d.ID = c.Doctor1_ID
            WHERE ci.PolicyNumber IN ({ph})
              AND ci.Rank = 1
              AND ci.InactiveDate IS NULL
        """, mbis)
        return {row["mbi"].strip(): row for row in cur.fetchall()}
    finally:
        conn.close()
```

Then add this new function directly after `verify_patients`:

```python
def validate_icd10_codes(codes: list[str]) -> set[str]:
    """Return subset of codes that are NOT valid in dmeworks.tbl_icd10 (missing, header, or retired)."""
    if not codes:
        return set()
    ph = ",".join(["%s"] * len(codes))
    conn = _connect()
    try:
        cur = conn.cursor()
        cur.execute(
            f"SELECT Code FROM dmeworks.tbl_icd10 "
            f"WHERE Code IN ({ph}) AND Header = 0 "
            f"AND (InactiveDate IS NULL OR InactiveDate > CURDATE())",
            codes,
        )
        valid = {r[0].strip() for r in cur.fetchall()}
        return set(codes) - valid
    finally:
        conn.close()
```

- [ ] **Step 4: Run tests to verify they pass**

```
pytest tests/test_db_write.py::test_verify_patients_sql_has_rank_filter tests/test_db_write.py::test_verify_patients_sql_includes_icd10_columns tests/test_db_write.py::test_verify_patients_sql_includes_gender_height_weight tests/test_db_write.py::test_validate_icd10_codes_returns_invalid_set tests/test_db_write.py::test_validate_icd10_codes_empty_input tests/test_db_write.py::test_validate_icd10_codes_all_valid -v
```
Expected: 6 PASSED.

- [ ] **Step 5: Commit**

```bash
git add utils/db.py tests/test_db_write.py
git commit -m "fix: verify_patients adds Rank=1 filter; add validate_icd10_codes"
```

---

## Task 5: `utils/db.py` — `insert_doctor` + `insert_insurance_company`

**Files:**
- Modify: `utils/db.py`
- Modify: `tests/test_db_write.py`

**Schema reference:**
- `dmeworks.tbl_doctor` NOT NULL fields without default: `Address1`, `Address2`, `City`, `Contact`, `Courtesy` (enum), `Fax`, `FirstName`, `LastName`, `LicenseNumber`, `MedicaidNumber`, `MiddleName`, `OtherID`, `Phone`, `Phone2`, `State`, `Suffix`, `Title`, `UPINNumber`, `Zip`
- `dmeworks.tbl_insurancecompany`: all NOT NULL fields have defaults (empty string) — only `Name` and `LastUpdateUserID` need to be set explicitly

- [ ] **Step 1: Add insert function tests to `tests/test_db_write.py`**

Append to the file:

```python
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
            {"first": "J", "last": "S", "npi": "1", "mi": "AB"},  # 2-char MI
            dry_run=False,
        )
    insert_params = mock_cursor.execute.call_args_list[0][0][1]
    mi_index = 2  # MiddleName is 3rd param (0-indexed: FirstName=0, LastName=1, MiddleName=2)
    assert insert_params[mi_index] == "A"  # truncated to 1


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
```

- [ ] **Step 2: Run new tests to verify they fail**

```
pytest tests/test_db_write.py::test_insert_doctor_dry_run_skips_execute tests/test_db_write.py::test_insert_insurance_company_dry_run_skips -v
```
Expected: FAIL — functions not yet defined.

- [ ] **Step 3: Add `insert_doctor` and `insert_insurance_company` to `utils/db.py`**

Add after `validate_icd10_codes`:

```python
# ─── WRITE FUNCTIONS ──────────────────────────────────────────────────────────
# INSERT-only. Never UPDATE or DELETE. Parameterized SQL only.

import logging as _logging
_log = _logging.getLogger("dmeworks.db")


def insert_doctor(doc: dict, dry_run: bool = False) -> int | None:
    """INSERT into dmeworks.tbl_doctor; call MIR proc. Returns new ID or None (dry-run)."""
    sql = """
        INSERT INTO dmeworks.tbl_doctor
            (FirstName, LastName, MiddleName, Suffix, Courtesy,
             NPI, Address1, Address2, City, State, Zip,
             Phone, Phone2, Fax,
             Contact, Title, LicenseNumber, MedicaidNumber, UPINNumber, OtherID,
             LastUpdateUserID, LastUpdateDatetime)
        VALUES (%s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s,
                %s, %s, %s,
                %s, %s, %s, %s, %s, %s,
                %s, NOW())
    """
    params = (
        doc.get("first", ""),
        doc.get("last", ""),
        (doc.get("mi", "") or "")[:1],
        doc.get("suffix", ""),
        doc.get("courtesy", "Dr.") or "Dr.",
        doc.get("npi", ""),
        doc.get("address1", ""),
        doc.get("address2", ""),
        doc.get("city", ""),
        doc.get("state", ""),
        doc.get("zip", ""),
        doc.get("phone", ""),
        "",               # Phone2
        doc.get("fax", ""),
        "",               # Contact
        "",               # Title
        "",               # LicenseNumber
        "",               # MedicaidNumber
        "",               # UPINNumber
        "",               # OtherID
        10,               # LastUpdateUserID
    )
    if dry_run:
        _log.info("[DRY] INSERT doctor NPI=%s", doc.get("npi"))
        return None
    conn = _connect()
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        new_id = cur.lastrowid
        cur.execute("CALL dmeworks.mir_update_doctor(%s)", (new_id,))
        conn.commit()
        return new_id
    finally:
        conn.close()


def insert_insurance_company(name: str, dry_run: bool = False) -> int | None:
    """INSERT into dmeworks.tbl_insurancecompany; call MIR proc. Returns new ID or None (dry-run)."""
    sql = """
        INSERT INTO dmeworks.tbl_insurancecompany (Name, LastUpdateUserID, LastUpdateDatetime)
        VALUES (%s, %s, NOW())
    """
    if dry_run:
        _log.info("[DRY] INSERT insurance company '%s'", name)
        return None
    conn = _connect()
    try:
        cur = conn.cursor()
        cur.execute(sql, (name, 10))
        new_id = cur.lastrowid
        cur.execute("CALL dmeworks.mir_update_insurancecompany(%s)", (new_id,))
        conn.commit()
        return new_id
    finally:
        conn.close()
```

- [ ] **Step 4: Run tests to verify they pass**

```
pytest tests/test_db_write.py -k "insert_doctor or insert_insurance" -v
```
Expected: 5 PASSED.

- [ ] **Step 5: Commit**

```bash
git add utils/db.py tests/test_db_write.py
git commit -m "feat: add insert_doctor and insert_insurance_company to db.py"
```

---

## Task 6: `utils/db.py` — `insert_patient` + `backup_databases`

**Files:**
- Modify: `utils/db.py`
- Modify: `tests/test_db_write.py`

**Schema reference (tbl_customer NOT NULL without default):**
- `DeliveryDirections` longtext → `''`
- `EmergencyContact` longtext → `''`
- `AccidentType` enum('Auto','No','Other') → `'No'`
- `SetupDate` date NOT NULL DEFAULT '0000-00-00' → override with today's date

**InsuranceType codes:** `MEDICARE→MP`, `MEDICAID→OT`, `MEDIGAP→LT`, `SUPPLEMENTAL→SP`, `COMMERCIAL_GROUP→GP`, `COMMERCIAL_INDIVIDUAL→IP`

- [ ] **Step 1: Add `insert_patient` and `backup_databases` tests to `tests/test_db_write.py`**

Append:

```python
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
    # Count tbl_customer_insurance inserts (should be 2: primary + secondary)
    ins_inserts = [c for c in execute_calls if "tbl_customer_insurance" in c and "INSERT" in c]
    assert len(ins_inserts) == 2


def test_backup_databases_calls_mysqldump(tmp_path):
    _configure_db()
    from utils import db
    with patch("utils.db._connect"), \
         patch("utils.creds.get_mysql_creds", return_value=("user", "pass")), \
         patch("subprocess.run") as mock_run:
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
         patch("subprocess.run") as mock_run:
        mock_run.return_value = MagicMock(returncode=1, stderr="access denied")
        with pytest.raises(RuntimeError, match="mysqldump failed"):
            db.backup_databases(str(tmp_path))
```

- [ ] **Step 2: Run new tests to verify they fail**

```
pytest tests/test_db_write.py::test_insert_patient_dry_run_skips tests/test_db_write.py::test_backup_databases_calls_mysqldump -v
```
Expected: FAIL — functions not yet defined.

- [ ] **Step 3: Add `insert_patient` and `backup_databases` to `utils/db.py`**

Add imports at top of the file (after existing imports):

```python
import subprocess
from datetime import datetime as _dt, date as _date
from pathlib import Path as _Path
```

Add these functions after `insert_insurance_company`:

```python
_INS_TYPE_MAP = {
    "MEDICARE": "MP",
    "MEDICAID": "OT",
    "MEDIGAP": "LT",
    "SUPPLEMENTAL": "SP",
    "COMMERCIAL_GROUP": "GP",
    "COMMERCIAL_INDIVIDUAL": "IP",
}


def insert_patient(patient: dict, insurance_map: dict, dry_run: bool = False) -> int | None:
    """
    INSERT patient into tbl_customer + tbl_customer_insurance in a single transaction.
    Calls c02.mir_update_customer and c02.mir_update_customer_insurance after commit.
    Returns new customer ID or None (dry-run).
    Raises RuntimeError if required lookups (doctor, insurance) fail.
    On any error: rolls back and re-raises.
    """
    from utils.logger import mask_mbi
    mbi   = patient["mbi"]
    label = f"MBI {mask_mbi(mbi)}"

    icd10 = patient.get("icd10", [])
    icd10_vals = tuple(icd10[i] if i < len(icd10) else None for i in range(12))

    try:
        height = float(patient["height"]) if patient.get("height") else None
        weight = float(patient["weight"]) if patient.get("weight") else None
    except (ValueError, TypeError):
        height = weight = None

    try:
        dob = _dt.strptime(patient["dob"], "%m/%d/%Y").date()
    except ValueError as e:
        raise ValueError(f"{label}: invalid DOB '{patient['dob']}'") from e

    if dry_run:
        _log.info("[DRY] INSERT patient %s %s | %s", patient["first"], patient["last"], label)
        return None

    conn = _connect()
    try:
        conn.start_transaction()
        cur = conn.cursor()

        # Generate unique AccountNumber (locked to prevent race)
        cur.execute("SELECT MAX(CAST(AccountNumber AS UNSIGNED)) FROM tbl_customer FOR UPDATE")
        max_acct = cur.fetchone()[0] or 0
        acct_num = str(max_acct + 1)

        # Resolve Doctor1_ID by NPI
        doctor_npi = patient.get("_doctor", {}).get("npi", "")
        cur.execute("SELECT ID FROM dmeworks.tbl_doctor WHERE NPI = %s", (doctor_npi,))
        row = cur.fetchone()
        doctor_id = row[0] if row else None

        # Resolve primary InsuranceCompanyID by name (case-insensitive)
        medicare_name = insurance_map.get(patient["state"], "")
        cur.execute(
            "SELECT ID FROM dmeworks.tbl_insurancecompany WHERE LOWER(Name) = LOWER(%s)",
            (medicare_name,),
        )
        row = cur.fetchone()
        if not row:
            raise RuntimeError(f"Insurance company not found: '{medicare_name}'")
        ins_id = row[0]

        # INSERT customer
        cur.execute("""
            INSERT INTO tbl_customer
                (AccountNumber, FirstName, LastName, MiddleName, Suffix,
                 DateofBirth, Address1, Address2, City, State, Zip, Phone,
                 Doctor1_ID, POSTypeID, AccidentType, DeliveryDirections, EmergencyContact,
                 Gender, Height, Weight,
                 ICD10_01, ICD10_02, ICD10_03, ICD10_04, ICD10_05, ICD10_06,
                 ICD10_07, ICD10_08, ICD10_09, ICD10_10, ICD10_11, ICD10_12,
                 SetupDate, LastUpdateUserID, LastUpdateDatetime)
            VALUES
                (%s, %s, %s, %s, %s,
                 %s, %s, %s, %s, %s, %s, %s,
                 %s, %s, %s, %s, %s,
                 %s, %s, %s,
                 %s, %s, %s, %s, %s, %s,
                 %s, %s, %s, %s, %s, %s,
                 %s, %s, NOW())
        """, (
            acct_num,
            patient.get("first", ""), patient.get("last", ""),
            (patient.get("mi", "") or "")[:1], patient.get("suffix", ""),
            dob,
            patient.get("address1", ""), patient.get("address2", ""),
            patient.get("city", ""), patient.get("state", ""),
            patient.get("zip", ""), patient.get("phone", ""),
            doctor_id, 12, "No", "", "",
            patient.get("gender", "Male"), height, weight,
            *icd10_vals,
            _date.today(), 10,
        ))
        customer_id = cur.lastrowid

        # INSERT primary insurance (Medicare, Rank=1)
        cur.execute("""
            INSERT INTO tbl_customer_insurance
                (CustomerID, InsuranceCompanyID, InsuranceType,
                 PolicyNumber, Rank, RelationshipCode, LastUpdateUserID)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (customer_id, ins_id, "MP", mbi, 1, "18", 10))

        # INSERT secondary insurance (if present, Rank=2)
        sec = patient.get("secondary")
        if sec:
            cur.execute(
                "SELECT ID FROM dmeworks.tbl_insurancecompany WHERE LOWER(Name) = LOWER(%s)",
                (sec["ins_company"],),
            )
            row = cur.fetchone()
            if not row:
                raise RuntimeError(f"Secondary insurance company not found: '{sec['ins_company']}'")
            sec_ins_id   = row[0]
            sec_ins_type = _INS_TYPE_MAP.get(sec.get("ins_type", ""), "OT")
            cur.execute("""
                INSERT INTO tbl_customer_insurance
                    (CustomerID, InsuranceCompanyID, InsuranceType,
                     PolicyNumber, Rank, RelationshipCode, LastUpdateUserID)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (customer_id, sec_ins_id, sec_ins_type, sec["policy"], 2, "18", 10))

        # MIR stored procedure calls (must be after all INSERTs)
        cur.execute("CALL c02.mir_update_customer(%s)", (customer_id,))
        cur.execute("CALL c02.mir_update_customer_insurance(%s)", (customer_id,))

        conn.commit()
        _log.info("[OK] Inserted customer ID=%d for %s", customer_id, label)
        return customer_id

    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def backup_databases(backup_dir: str) -> str:
    """
    Dump c02 + dmeworks via mysqldump. Purge backups older than 7 days.
    Returns path to the new backup file.
    Raises RuntimeError if mysqldump exits non-zero.
    """
    from utils.creds import get_mysql_creds, MYSQL_HOST, MYSQL_PORT
    user, password = get_mysql_creds()
    _Path(backup_dir).mkdir(parents=True, exist_ok=True)

    ts   = _dt.now().strftime("%Y%m%d_%H%M%S")
    path = str(_Path(backup_dir) / f"backup_{ts}.sql")

    cmd = [
        "mysqldump",
        f"--host={MYSQL_HOST}",
        f"--port={MYSQL_PORT}",
        f"--user={user}",
        f"--password={password}",
        "--databases", "c02", "dmeworks",
    ]
    with open(path, "w", encoding="utf-8") as fout:
        result = subprocess.run(cmd, stdout=fout, stderr=subprocess.PIPE, text=True)

    if result.returncode != 0:
        raise RuntimeError(f"mysqldump failed: {result.stderr.strip()}")

    # Purge backups older than 7 days
    cutoff = _dt.now().timestamp() - 7 * 86400
    for old in _Path(backup_dir).glob("backup_*.sql"):
        try:
            if old.stat().st_mtime < cutoff:
                old.unlink()
        except OSError:
            pass

    return path
```

- [ ] **Step 4: Run all db_write tests**

```
pytest tests/test_db_write.py -v
```
Expected: 16 PASSED.

- [ ] **Step 5: Commit**

```bash
git add utils/db.py tests/test_db_write.py
git commit -m "feat: add insert_patient and backup_databases to db.py"
```

---

## Task 7: Create `utils/ui.py` — shared pywinauto utilities

**Files:**
- Create: `utils/ui.py`
- Modify: `entry_all.py` (import from utils.ui; remove duplicate definitions)
- Modify: `entry_test.py` (same)

No unit tests — pywinauto functions require a live Windows UI. They are smoke-tested by running the existing entry files.

- [ ] **Step 1: Create `utils/ui.py`**

Extract all functions shared verbatim between `entry_all.py` and `entry_test.py`:

```python
"""Shared pywinauto UI utilities for DMEworks automation tools."""
import time

from pywinauto import Application, keyboard

from utils.logger import get_logger, mask_mbi

log = get_logger()

T_SHORT = 0.5
T_MED   = 1.0
T_LONG  = 1.8


def get_app() -> Application:
    return Application(backend="uia").connect(title="DMEWorks")


def get_main() -> tuple:
    a = get_app()
    return a, a.window(title="DMEWorks", auto_id="FormMain")


def fmt_phone(digits: str) -> str:
    d = "".join(c for c in digits if c.isdigit())
    if len(d) == 10:
        return f"({d[:3]}){d[3:6]}-{d[6:]}"
    return digits


def dismiss_popup(a) -> None:
    try:
        p = a.window(title="Compliance Popup", auto_id="FormCompliancePopup")
        if p.exists(timeout=1):
            p.child_window(title="Close", control_type="Button").click_input()
            time.sleep(T_SHORT)
    except Exception:
        pass


def dismiss_save_dialog(a) -> bool:
    try:
        main = a.window(title="DMEWorks", auto_id="FormMain")
        no_btn = main.child_window(title="No", control_type="Button")
        if no_btn.exists(timeout=1):
            log.debug("Save dialog — clicking No")
            no_btn.click_input()
            time.sleep(T_SHORT)
            return True
    except Exception:
        pass
    return False


def dismiss_validation(a) -> bool:
    for frag in ["validation", "error", "warning"]:
        try:
            dlg = a.window(title_re=f".*{frag}.*")
            if dlg.exists(timeout=1):
                log.warning("Validation dialog: %s", dlg.window_text())
                dlg.child_window(title="OK", control_type="Button").click_input()
                time.sleep(T_SHORT)
                return True
        except Exception:
            pass
    return False


def find_mdi_child(main, keyword: str):
    try:
        for child in main.descendants(control_type="Window"):
            try:
                t = child.window_text()
                if t and keyword.lower() in t.lower():
                    return main.child_window(title=t, control_type="Window", found_index=0)
            except Exception:
                pass
    except Exception:
        pass
    return None


def set_field(win, auto_id: str, value: str) -> None:
    if not value:
        return
    try:
        win.child_window(auto_id=auto_id, found_index=0).set_edit_text(value)
        time.sleep(0.2)
    except Exception as e:
        log.warning("set_field(%s): %s", auto_id, e)


def toolbar_click(win, title: str) -> None:
    tb = win.child_window(auto_id="tlbMain", control_type="ToolBar", found_index=0)
    tb.child_window(title=title, control_type="Button").click_input()
    time.sleep(T_MED)


def close_window(main_win, keyword: str) -> None:
    try:
        w = find_mdi_child(main_win, keyword)
        if w:
            tb = w.child_window(auto_id="tlbMain", control_type="ToolBar", found_index=0)
            tb.child_window(title="Close", control_type="Button").click_input()
            time.sleep(T_SHORT)
            dismiss_save_dialog(get_app())
    except Exception as e:
        log.warning("close_window(%s): %s", keyword, e)


def open_fresh_window(main_win, a, keyword: str, menu_path: str):
    if find_mdi_child(main_win, keyword):
        close_window(main_win, keyword)
        time.sleep(T_MED)
    a.top_window().menu_select(menu_path)
    time.sleep(T_LONG)
    dismiss_save_dialog(a)
    dismiss_popup(a)
    return find_mdi_child(main_win, keyword)


def go_work_area(w) -> None:
    try:
        w.child_window(auto_id="PageControl", control_type="Tab",
                       found_index=0).child_window(
            title="Work Area", control_type="TabItem").click_input()
        time.sleep(T_MED)
    except Exception as e:
        log.warning("go_work_area: %s", e)


def click_inner_tab(w, title: str) -> None:
    w.child_window(auto_id="TabControl1", control_type="Tab",
                   found_index=0).child_window(
        title=title, control_type="TabItem").click_input()
    time.sleep(T_MED)


def set_combo_text(pane, value: str) -> None:
    if not value:
        return
    try:
        combo = pane.child_window(auto_id="cmbInternal", found_index=0)
        combo.click_input()
        time.sleep(0.5)
        try:
            combo.select(value)
            time.sleep(0.5)
            return
        except Exception:
            pass
        combo.type_keys("^a", with_spaces=False)
        time.sleep(0.2)
        combo.type_keys(value, with_spaces=True)
        time.sleep(0.8)
        combo.type_keys("{ENTER}")
        time.sleep(0.5)
    except Exception as e:
        log.warning("set_combo_text('%s'): %s", value, e)


def set_dob(win, dob_str: str) -> None:
    try:
        dob = win.child_window(auto_id="dtbDateofBirth", found_index=0)
        rect = dob.wrapper_object().rectangle()
        h = rect.bottom - rect.top
        dob.click_input(coords=(6, h // 2))
        time.sleep(0.4)
        for _ in range(4):
            keyboard.send_keys("{LEFT}")
            time.sleep(0.05)
        time.sleep(0.2)
        mm, dd, yyyy = dob_str.split("/")
        keyboard.send_keys(mm)
        time.sleep(0.3)
        keyboard.send_keys(dd)
        time.sleep(0.3)
        keyboard.send_keys(yyyy)
        time.sleep(0.3)
    except Exception as e:
        log.warning("set_dob: %s", e)
```

- [ ] **Step 2: Commit**

```bash
git add utils/ui.py
git commit -m "feat: extract shared pywinauto utilities into utils/ui.py"
```

---

## Task 8: Create `ingest.py`

**Files:**
- Create: `ingest.py`

No unit tests for the top-level flow (it orchestrates functions already tested). Smoke-test: run `python ingest.py --client allied` (dry-run, should fetch Notion and print what would be written).

- [ ] **Step 1: Create `ingest.py`**

```python
"""
DMEworks Patient Ingest — direct MySQL writes.
Dry-run is default. Pass --live for real writes.

Usage:
  python ingest.py                     # dry-run (shows what would be written)
  python ingest.py --live              # real writes (backup runs first)
  python ingest.py --client allied     # explicit client (default: allied)
"""

import argparse
import json
import os
import sys
from concurrent.futures import ThreadPoolExecutor

_ROOT = os.path.dirname(os.path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from utils import db, notion, validate
from utils.creds import get_notion_token
from utils.logger import get_logger, mask_mbi, mask_dob

log = get_logger()


def _parse_args():
    p = argparse.ArgumentParser(description="DMEworks patient ingest — direct DB writes")
    p.add_argument("--live",   action="store_true", help="Perform real DB writes (default: dry-run)")
    p.add_argument("--client", default="allied",    help="Client code (default: allied)")
    return p.parse_args()


def _load_clients() -> dict:
    base = getattr(sys, "_MEIPASS", _ROOT)
    path = os.path.join(base, "config", "clients.json")
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def run() -> None:
    args    = _parse_args()
    dry_run = not args.live
    client  = args.client

    clients = _load_clients()
    if client not in clients:
        print(f"Unknown client '{client}'. Available: {list(clients)}")
        sys.exit(1)
    client_info = clients[client]

    log.info("=" * 60)
    log.info("DMEworks Ingest — %s", client_info["name"])
    log.info("Mode: %s", "DRY-RUN (no DB changes)" if dry_run else "LIVE WRITES")
    log.info("=" * 60)

    # ── Step 1: Backup (live only) ────────────────────────────────────────────
    if not dry_run:
        base       = getattr(sys, "_MEIPASS", _ROOT)
        backup_dir = os.path.join(base, "deploy", "backups")
        log.info("Running backup before any writes...")
        try:
            path = db.backup_databases(backup_dir)
            log.info("Backup: %s", path)
        except Exception as e:
            log.error("Backup failed — aborting live run: %s", e)
            sys.exit(1)

    # ── Step 2: Fetch ─────────────────────────────────────────────────────────
    token = get_notion_token()
    db.configure(client_info["db"])

    log.info("Fetching Notion work queue...")
    insurance_map = notion.fetch_insurance_map(token)
    patients      = notion.fetch_work_queue(token)
    log.info("%d patient(s) in work queue", len(patients))

    if not patients:
        log.info("Nothing to do.")
        return

    # Build unique doctor + insurance company lists
    seen_npis: set[str] = set()
    doctors: list[dict] = []
    for p in patients:
        d   = p.get("_doctor", {})
        npi = d.get("npi", "")
        if npi and npi not in seen_npis:
            seen_npis.add(npi)
            doctors.append(d)

    seen_ins: set[str]             = set()
    ins_companies: list[dict]      = []
    for p in patients:
        name = insurance_map.get(p.get("state", ""), "")
        if name and name not in seen_ins:
            seen_ins.add(name)
            ins_companies.append({"name": name, "type": "MEDICARE"})
        sec      = p.get("secondary") or {}
        sec_name = sec.get("ins_company", "")
        if sec_name and sec_name not in seen_ins:
            seen_ins.add(sec_name)
            ins_companies.append({"name": sec_name, "type": "OTHER"})

    # ── Step 3: Validate (abort entire run on any error) ──────────────────────
    log.info("Validating %d patient(s)...", len(patients))
    errors: list[str] = []
    for p in patients:
        errors.extend(validate.validate_patient(p, insurance_map))

    # ICD10 DB lookup — all codes from all patients at once
    all_codes = list({code for p in patients for code in p.get("icd10", [])})
    if all_codes:
        bad_codes = db.validate_icd10_codes(all_codes)
        for p in patients:
            for code in p.get("icd10", []):
                if code in bad_codes:
                    errors.append(
                        f"MBI {mask_mbi(p.get('mbi', ''))}: "
                        f"ICD10 '{code}' not in DB or retired"
                    )

    if errors:
        log.error("Validation failed — fix these before running:")
        for err in errors:
            log.error("  %s", err)
        sys.exit(1)
    log.info("Validation passed (%d patient(s))", len(patients))

    # ── Step 4: DB existence checks (parallel) ────────────────────────────────
    log.info("DB existence checks...")
    with ThreadPoolExecutor(max_workers=3) as pool:
        f_npis  = pool.submit(db.fetch_matching_npis,            [d["npi"]  for d in doctors])
        f_names = pool.submit(db.fetch_matching_insurance_names, [c["name"] for c in ins_companies])
        f_mbis  = pool.submit(db.fetch_matching_mbis,            [p["mbi"]  for p in patients])
        existing_npis  = f_npis.result()
        existing_names = f_names.result()
        existing_mbis  = f_mbis.result()

    new_docs = [d for d in doctors       if d["npi"]          not in existing_npis]
    new_ins  = [c for c in ins_companies if c["name"].lower() not in existing_names
                                         and c["type"] != "MEDICARE"]
    new_pats = [p for p in patients      if p["mbi"]          not in existing_mbis]
    log.info("Need: %d doctor(s), %d insurance co(s), %d patient(s)",
             len(new_docs), len(new_ins), len(new_pats))

    # ── Step 5: Insert doctors ────────────────────────────────────────────────
    log.info("")
    log.info("[1/3] DOCTORS")
    for doc in doctors:
        if doc["npi"] in existing_npis:
            log.info("  [SKIP]   NPI %s", doc["npi"])
            continue
        log.info("  [INSERT] NPI %s  %s %s", doc["npi"], doc.get("first", ""), doc.get("last", ""))
        try:
            db.insert_doctor(doc, dry_run=dry_run)
        except Exception as e:
            log.error("  [ERROR]  NPI %s — %s (aborting)", doc["npi"], e)
            sys.exit(1)

    # ── Step 6: Insert insurance companies ────────────────────────────────────
    log.info("")
    log.info("[2/3] INSURANCE COMPANIES")
    for co in ins_companies:
        name        = co["name"]
        is_medicare = co["type"] == "MEDICARE"
        if name.lower() in existing_names:
            tag = "[OK]   " if is_medicare else "[SKIP] "
            log.info("  %s %s", tag, name)
            continue
        if is_medicare:
            log.error("  [ERROR]  '%s' not found — must be set up manually in DMEworks", name)
            sys.exit(1)
        log.info("  [INSERT] %s", name)
        try:
            db.insert_insurance_company(name, dry_run=dry_run)
        except Exception as e:
            log.error("  [ERROR]  %s — %s (aborting)", name, e)
            sys.exit(1)

    # ── Step 7: Insert patients (one transaction per patient) ─────────────────
    log.info("")
    log.info("[3/3] PATIENTS")
    for p in patients:
        label = f"MBI {mask_mbi(p['mbi'])}"
        if p["mbi"] in existing_mbis:
            log.info("  [SKIP]   %s", label)
            continue
        log.info("  [INSERT] %s %s | %s", p["first"], p["last"], label)
        try:
            db.insert_patient(p, insurance_map, dry_run=dry_run)
        except Exception as e:
            log.error("  [ERROR]  %s — %s (skipping, continuing to next)", label, e)
            continue
        if not dry_run and p.get("_notion_page_id"):
            try:
                notion.mark_in_dmeworks(token, p["_notion_page_id"])
                log.info("    [notion] %s → In DMEworks", label)
            except Exception as e:
                log.warning("    [notion] Status update failed for %s: %s", label, e)

    # ── Step 8: Verification pass ─────────────────────────────────────────────
    log.info("")
    log.info("=" * 60)
    log.info("VERIFICATION PASS")
    log.info("=" * 60)
    _run_verification(patients, doctors, ins_companies)


def _run_verification(patients: list[dict], doctors: list[dict], ins_companies: list[dict]) -> None:
    with ThreadPoolExecutor(max_workers=3) as pool:
        f_npis    = pool.submit(db.fetch_matching_npis,            [d["npi"]  for d in doctors])
        f_names   = pool.submit(db.fetch_matching_insurance_names, [c["name"] for c in ins_companies])
        f_details = pool.submit(db.verify_patients, patients)
        existing_npis  = f_npis.result()
        existing_names = f_names.result()
        patient_rows   = f_details.result()

    all_pass = True

    for doc in doctors:
        if doc["npi"] in existing_npis:
            log.info("  [PASS] Doctor NPI %s", doc["npi"])
        else:
            log.error("  [FAIL] Doctor NPI %s NOT in DB", doc["npi"])
            all_pass = False

    for co in ins_companies:
        if co["name"].lower() in existing_names:
            log.info("  [PASS] Insurance '%s'", co["name"])
        else:
            log.error("  [FAIL] Insurance '%s' NOT in DB", co["name"])
            all_pass = False

    for p in patients:
        label = f"MBI {mask_mbi(p['mbi'])}"
        row   = patient_rows.get(p["mbi"])
        if not row:
            log.error("  [FAIL] %s NOT in DB", label)
            all_pass = False
            continue

        issues: list[str] = []
        if row["first"].strip().lower() != p["first"].lower():
            issues.append("FirstName mismatch")
        if row["last"].strip().lower() != p["last"].lower():
            issues.append("LastName mismatch")
        dob_db = row["dob"]
        dob_str = dob_db.strftime("%m/%d/%Y") if hasattr(dob_db, "strftime") else str(dob_db)
        if dob_str != p["dob"]:
            issues.append("DOB mismatch")
        if (row.get("state") or "").strip().upper() != p["state"].upper():
            issues.append("State mismatch")
        if not row.get("doctor_npi"):
            issues.append("no doctor assigned (Doctor1_ID is NULL)")
        if (row.get("gender") or "").strip() != p.get("gender", ""):
            issues.append("Gender mismatch")

        # ICD10 field-level check
        db_codes = {
            row.get(f"icd10_{i:02d}")
            for i in range(1, 13)
            if row.get(f"icd10_{i:02d}")
        }
        for code in p.get("icd10", []):
            if code not in db_codes:
                issues.append(f"ICD10 '{code}' missing in DB")

        if issues:
            for iss in issues:
                log.warning("  [WARN] %s — %s", label, iss)
            all_pass = False
        else:
            log.info("  [PASS] %s", label)

    log.info("")
    if all_pass:
        log.info("RESULT: ALL CHECKS PASSED")
    else:
        log.warning("RESULT: SOME CHECKS FAILED — review above")
        sys.exit(1)


if __name__ == "__main__":
    run()
```

- [ ] **Step 2: Smoke-test dry-run (no DB connection needed)**

```
python ingest.py --help
```
Expected: Prints usage without errors.

- [ ] **Step 3: Commit**

```bash
git add ingest.py
git commit -m "feat: create ingest.py — direct MySQL write entry replacing entry_all.py"
```

---

## Task 9: Create `ingest_test.py`

**Files:**
- Create: `ingest_test.py`

- [ ] **Step 1: Create `ingest_test.py`**

```python
"""
DMEworks Ingest TEST — runs ingest against the test client (c01).
Dry-run by default. Pass --live to write to c01 database.

Usage:
  python ingest_test.py          # dry-run against c01
  python ingest_test.py --live   # live writes to c01
"""

import os
import sys

_ROOT = os.path.dirname(os.path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

if "--client" not in sys.argv:
    sys.argv += ["--client", "c01"]

import ingest
ingest.run()
```

- [ ] **Step 2: Smoke-test**

```
python ingest_test.py --help
```
Expected: Prints ingest usage without errors.

- [ ] **Step 3: Commit**

```bash
git add ingest_test.py
git commit -m "feat: create ingest_test.py — test client wrapper for ingest"
```

---

## Task 10: Update `run.py` + `packaging/dmeworks.spec`

**Files:**
- Modify: `run.py`
- Modify: `packaging/dmeworks.spec`

### 10A — `run.py`

- [ ] **Step 1: Update the frozen dispatch block in `run.py`**

Replace the `if mode == "entry":` ... `elif mode == "entry_test":` block with `ingest`/`ingest_test`:

Find this block (lines 48–52):
```python
        if mode == "entry":
            import entry_all
            entry_all.run()
        elif mode == "entry_test":
            import entry_test
            entry_test.run()
```

Replace with:
```python
        if mode == "ingest":
            import ingest
            ingest.run()
        elif mode == "ingest_test":
            import ingest_test
            ingest_test.run()
```

- [ ] **Step 2: Update `_launch()` script_map**

Find (lines 97–104):
```python
        script_map = {
            "entry":        os.path.join(SCRIPT_DIR, "entry_all.py"),
            "entry_test":   os.path.join(SCRIPT_DIR, "entry_test.py"),
```

Replace those two entries with:
```python
        script_map = {
            "ingest":       os.path.join(SCRIPT_DIR, "ingest.py"),
            "ingest_test":  os.path.join(SCRIPT_DIR, "ingest_test.py"),
```

- [ ] **Step 3: Update the `main()` menu and dispatch logic**

Find the prereq check section and the menu dispatch. The new flow: ingest does NOT require DMEworks/pywinauto — only the utility tools do.

Replace the entire `main()` function body with:

```python
def main() -> None:
    print()
    print("=" * 60)
    print("  DMEworks Automation Launcher")
    print("=" * 60)
    print()
    print("  Checking prerequisites...")
    print()

    checks   = check_prereqs()
    for name, ok, detail in checks:
        print(f"  [{'OK' if ok else 'FAIL'}]  {name:<22} {detail}")
    print()

    other_ok     = all(ok for name, ok, _ in checks
                       if "DMEWorks" not in name and "pywinauto" not in name)
    dmeworks_ok  = all(ok for name, ok, _ in checks if "DMEWorks" in name)
    pywinauto_ok = any(ok for name, ok, _ in checks if "pywinauto" in name)

    if not other_ok:
        print("  Fix failed checks before running.")
        print()
        try:
            input("  Press Enter to exit...")
        except (EOFError, KeyboardInterrupt):
            pass
        sys.exit(1)

    if not dmeworks_ok and pywinauto_ok:
        print("  DMEWorks not running — utility options (4-6) unavailable.")
        try:
            launch_choice = input("  Launch DMEWorks now? [y/N]: ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            launch_choice = "n"
        if launch_choice == "y":
            dmeworks_ok = _launch_dmeworks()
    elif dmeworks_ok:
        print("  All checks passed.")
    print()

    print("  Entry  (no DMEWorks required)")
    print("  [1]  Test entry      —  dry-run against test client (c01)")
    print("  [2]  Full entry      —  Allied (prompts: dry-run or live)")
    print()
    print("  Verification")
    print("  [3]  Verify & correct  —  compare Notion vs DB, fix mismatches")
    print()
    print("  Utilities  (DMEWorks must be open)")
    print("  [4]  Map policy dialog")
    print("  [5]  Map insurance company")
    print("  [6]  Grid probe")
    print()
    print("  [0]  Exit")
    print()

    while True:
        try:
            choice = input("  > ").strip()
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)

        if choice == "0":
            sys.exit(0)
        elif choice in ("4", "5", "6") and not (dmeworks_ok and pywinauto_ok):
            print("  That option requires DMEWorks to be running.")
        elif choice in ("1", "2", "3", "4", "5", "6"):
            break
        else:
            print("  Enter 0-6.")

    try:
        if choice == "1":
            _launch("ingest_test", [])

        elif choice == "2":
            try:
                mode = input("  Live writes (real DB changes) or dry-run? [live/DRY]: ").strip().lower()
            except (EOFError, KeyboardInterrupt):
                mode = "dry"
            extra = ["--live"] if mode == "live" else []
            _launch("ingest", extra)

        elif choice == "3":
            try:
                dry = input("  Dry run? (shows diffs only, no writes) [y/N]: ").strip().lower()
            except (EOFError, KeyboardInterrupt):
                dry = "n"
            args = ["--dry-run"] if dry == "y" else []
            _launch("verify", args)

        elif choice == "4":
            _launch("map_policy", [])

        elif choice == "5":
            _launch("map_insurance", [])

        elif choice == "6":
            _launch("grid_probe", [])

    except (KeyboardInterrupt, EOFError):
        print()
        sys.exit(0)
```

### 10B — `packaging/dmeworks.spec`

- [ ] **Step 4: Update hiddenimports in `packaging/dmeworks.spec`**

Find:
```python
        "entry_all",
        "entry_test",
```

Replace with:
```python
        "ingest",
        "ingest_test",
        "utils.validate",
        "utils.ui",
```

- [ ] **Step 5: Add `clients.json` to datas**

Find:
```python
    datas=pw_d + ct_d + w32_d + [
        (os.path.join(ROOT, "config", "database_reference.json"), "config"),
    ],
```

Replace with:
```python
    datas=pw_d + ct_d + w32_d + [
        (os.path.join(ROOT, "config", "database_reference.json"), "config"),
        (os.path.join(ROOT, "config", "clients.json"), "config"),
    ],
```

- [ ] **Step 6: Verify `run.py` starts without error**

```
python run.py --help 2>&1 || python run.py
```
Ctrl-C to exit after seeing the menu. Expected: menu prints correctly.

- [ ] **Step 7: Commit**

```bash
git add run.py packaging/dmeworks.spec
git commit -m "feat: wire ingest/ingest_test in launcher; update spec hiddenimports"
```

---

## Task 11: Fix existing tests — update `test_notion_parse.py`

**Files:**
- Modify: `tests/test_notion_parse.py`

The `_parse_patient()` function now returns `gender`, `height`, `weight`, `waist_size`. The `_fetch_doctor()` now returns `mi`, `suffix`, `courtesy`, `fax`. Existing fixtures don't include these fields, so tests that check field presence will fail.

- [ ] **Step 1: Run the existing test suite to see what fails**

```
pytest tests/test_notion_parse.py -v
```
Note which tests fail.

- [ ] **Step 2: Update `_sample_patient_page` to include new fields**

Find the `_sample_patient_page` function and add new parameters:

```python
def _sample_patient_page(
    first="Jane",
    last="Doe",
    mi="A",
    suffix="",
    dob="1950-01-15",
    mbi="1EG4TE5MK72",
    address="123 Main St",
    address2="",
    city="Springfield",
    state="IL",
    zip_="62701",
    phone="2175550199",
    doctor_id="doctor-page-uuid",
    icd10="M54.5|Z96.641",
    secondary=None,
    notes="",
    gender="Male",
    height="65",
    weight="150",
    waist_size="",
    page_id="patient-page-uuid",
    page_url="https://www.notion.so/patient-page-uuid",
):
    props = {
        "Patient Name":        _title(f"{first} {last}"),
        "First Name":          _rt(first),
        "Last Name":           _rt(last),
        "MI":                  _rt(mi),
        "Suffix":              _rt(suffix),
        "DOB":                 _date(dob),
        "MBI":                 _rt(mbi),
        "Address":             _rt(address),
        "Address 2":           _rt(address2),
        "City":                _rt(city),
        "State":               _rt(state),
        "ZIP":                 _rt(zip_),
        "Phone":               _phone(phone),
        "Doctor":              _relation(doctor_id),
        "ICD10 Codes":         _rt(icd10),
        "Secondary Insurance": _rt(json.dumps(secondary) if secondary else ""),
        "Notes":               _rt(notes),
        "Status":              _select("To Enter in DMEworks"),
        "Gender":              _select(gender),
        "Height":              _rt(height),
        "Weight":              _rt(weight),
        "Waist Size":          _rt(waist_size),
    }
    return {"id": page_id, "url": page_url, "properties": props}
```

- [ ] **Step 3: Update `_sample_doctor_response` to include new fields**

Find `_sample_doctor_response` and add MI, Suffix, Courtesy, Fax:

```python
def _sample_doctor_response(
    first="John",
    last="Smith",
    mi="",
    suffix="",
    courtesy="Dr.",
    npi="1234567890",
    address="456 Oak Ave",
    address2="",
    city="Chicago",
    state="IL",
    zip_="60601",
    phone="3125550100",
    fax="",
):
    return {
        "properties": {
            "Doctor Name":  _title(f"Dr. {first} {last}"),
            "First Name":   _rt(first),
            "Last Name":    _rt(last),
            "MI":           _rt(mi),
            "Suffix":       _rt(suffix),
            "Courtesy":     _select(courtesy),
            "NPI":          _rt(npi),
            "Address":      _rt(address),
            "Address 2":    _rt(address2),
            "City":         _rt(city),
            "State":        _rt(state),
            "ZIP":          _rt(zip_),
            "Phone":        _phone(phone),
            "Fax":          _phone(fax) if fax else {"phone_number": None},
        }
    }
```

- [ ] **Step 4: Add new assertions to `test_parse_patient_basic_fields`**

Find `test_parse_patient_basic_fields` and append:

```python
    assert result["gender"] == "Male"
    assert result["height"] == "65"
    assert result["weight"] == "150"
    assert result["waist_size"] == ""
```

- [ ] **Step 5: Update `test_fetch_doctor_parses_fields` to verify new fields**

Find `test_fetch_doctor_parses_fields` and update:

```python
def test_fetch_doctor_parses_fields():
    import utils.notion as n
    mock_resp = MagicMock()
    mock_resp.json.return_value = _sample_doctor_response(
        mi="A", suffix="MD", courtesy="Dr.", fax="3125559999"
    )
    mock_resp.raise_for_status = MagicMock()
    with patch("requests.get", return_value=mock_resp):
        result = n._fetch_doctor("fake-token", "doctor-uuid")
    assert result["first"] == "John"
    assert result["last"] == "Smith"
    assert result["mi"] == "A"
    assert result["suffix"] == "MD"
    assert result["courtesy"] == "Dr."
    assert result["npi"] == "1234567890"
    assert result["fax"] == "3125559999"
    assert result["city"] == "Chicago"
    assert result["phone"] == "3125550100"
```

- [ ] **Step 6: Also update the doctor stub in all tests that mock `_fetch_doctor`**

Every `patch("utils.notion._fetch_doctor", return_value={...})` needs to include `"courtesy"` and `"fax"` keys. Find all such stubs and update:

Replace the stub dict `{"first": "J", "last": "S", "mi": "", "suffix": "", "npi": "1", "address1": "", "city": "", "state": "", "zip": "", "phone": ""}` with `{"first": "J", "last": "S", "mi": "", "suffix": "", "courtesy": "Dr.", "npi": "1", "fax": "", "address1": "", "address2": "", "city": "", "state": "", "zip": "", "phone": ""}` everywhere in the file.

Also update the longer stub in `test_parse_patient_basic_fields` and `test_parse_patient_doctor_name_in_result`.

- [ ] **Step 7: Run the full test suite**

```
pytest tests/ -v
```
Expected: all tests PASS (aim for zero failures).

- [ ] **Step 8: Commit**

```bash
git add tests/test_notion_parse.py
git commit -m "fix: update test fixtures with gender/height/weight/fax/courtesy fields"
```

---

## Self-Review Checklist

**Spec coverage:**
- [x] Bug 1 (`ARGS.client` crash): `--client` arg in `ingest.py`, default `allied` — Task 8
- [x] Bug 2 (`fetch_db_config` tests): `clients.json` + `db.configure(client_info["db"])` — Tasks 2, 8
- [x] Bug 3 (ICD10 never verified): `validate_icd10_codes` + verification pass — Tasks 4, 8
- [x] Bug 4 (doctor assignment fragile): Moot — direct DB NPI lookup — Task 6
- [x] Bug 5 (secondary not validated): `validate_secondary` in Task 3
- [x] Bug 6 (doctor MI/suffix not parsed): `_fetch_doctor` already fixed in prior session
- [x] Bug 7 (insurance case sensitivity): `LOWER()` on both sides in `insert_patient` — Task 6
- [x] Bug 8 (`verify_patients` missing Rank=1): Fixed in Task 4
- [x] Bug 9 (log overwrite): Rotating daily logs — Task 1
- [x] Bug 10 (multi-client hardcoded): `--client` flag + `clients.json` — Tasks 2, 8, 10
- [x] Bug 11 (code duplication): `utils/ui.py` — Task 7
- [x] Bug 12 (build packaging): `clients.json` added to datas — Task 10
- [x] Bug 13 (artifact directory): `config/` dir already exists with `database_reference.json`
- [x] Bug 14 (MIR not updated for customer): `CALL c02.mir_update_customer` + `_insurance` — Task 6
- [x] Bug 15 (charset mismatch): Already in `build_config()` from prior session
- [x] Bug 16 (Gender never written): `Gender` column in INSERT, validated — Tasks 3, 6
- [x] Bug 17 (ICD10 InactiveDate not checked): `validate_icd10_codes` WHERE clause — Task 4
- [x] Bug 18 (Height/Weight not written): `Height`/`Weight` in INSERT — Task 6

**Spec Step 1 (Backup):** `db.backup_databases()` called before any live write — Task 6, Task 8 ✓  
**Spec Step 2 (Fetch):** `notion.fetch_work_queue` + `fetch_insurance_map` — Task 8 ✓  
**Spec Step 3 (Validate):** `validate.validate_patient` + `db.validate_icd10_codes` — Tasks 3, 4, 8 ✓  
**Spec Step 4 (DB checks):** Parallel `fetch_matching_*` — Task 8 ✓  
**Spec Step 5 (Insert doctors):** `db.insert_doctor` — Task 5 ✓  
**Spec Step 6 (Insert insurance):** `db.insert_insurance_company` — Task 5 ✓  
**Spec Step 7 (Insert patients):** `db.insert_patient` with full transaction — Task 6 ✓  
**Spec Step 8 (Verify):** `_run_verification` in `ingest.py` — Task 8 ✓

**Type consistency:** All function signatures consistent across tasks. `insert_patient(patient: dict, insurance_map: dict, dry_run: bool)` used in Task 6 tests and Task 8 call site. ✓

**Placeholder scan:** No TBD/TODO in plan. All SQL is shown. All test assertions are concrete. ✓
