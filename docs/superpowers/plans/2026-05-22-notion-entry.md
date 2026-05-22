# DMEworks Entry v2 — Notion-Sourced Single EXE Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace local `clients.enc` patient data with live Notion API queries so zero PHI lives on the Allied machine; all secrets stored in Windows Credential Manager.

**Architecture:** `entry_all.py` calls `notion.fetch_work_queue()` at startup instead of `ClientStore.patients`, derives DOCTORS and INSURANCE_COMPANIES from the returned data, enters each patient into DMEworks, then calls `notion.mark_in_dmeworks()` to set Status = "In DMEworks". DB credentials move from `clients.enc` to Windows Credential Manager via `utils/creds.py`.

**Tech Stack:** Python 3.11+, `requests` (Notion API), `keyring` (Windows Credential Manager), `mysql-connector-python`, `pywinauto`, `PyInstaller`

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `utils/creds.py` | Single access point for all secrets — Notion token + DB creds via keyring |
| Create | `utils/notion.py` | Notion API: fetch patients, resolve doctor, update status |
| Modify | `utils/db.py` | `configure()` tries `creds.get_db_config()` first, falls back to ClientStore |
| Create | `entry_setup.py` | Interactive first-run credential wizard |
| Modify | `entry_all.py` | Add `--setup` flag; load patients/doctors/insurance from Notion |
| Modify | `requirements.txt` | Add `requests>=2.31` |
| Modify | `packaging/dmeworks.spec` | Add hidden imports for requests |
| Create | `tests/test_creds.py` | Unit tests for creds.py |
| Create | `tests/test_notion_parse.py` | Unit tests for notion.py parsing logic |

---

## Task 1: Add `requests` dependency and test scaffolding

**Files:**
- Modify: `requirements.txt`
- Create: `tests/__init__.py`
- Create: `tests/conftest.py`

- [ ] **Step 1: Add requests to requirements.txt**

  Edit `requirements.txt` — append after the last line:
  ```
  requests>=2.31
  ```

- [ ] **Step 2: Install it**

  ```
  pip install requests>=2.31 pytest
  ```

- [ ] **Step 3: Create test scaffolding**

  Create `tests/__init__.py` (empty).

  Create `tests/conftest.py`:
  ```python
  # conftest.py intentionally empty — pytest discovers tests/
  ```

- [ ] **Step 4: Verify pytest runs**

  ```
  pytest tests/ -v
  ```
  Expected: `no tests ran` or `0 passed` — no errors.

- [ ] **Step 5: Commit**

  ```bash
  git add requirements.txt tests/
  git commit -m "chore: add requests dep + test scaffolding"
  ```

---

## Task 2: `utils/creds.py` — credential store

**Files:**
- Create: `tests/test_creds.py`
- Create: `utils/creds.py`

- [ ] **Step 1: Write failing tests**

  Create `tests/test_creds.py`:
  ```python
  from unittest.mock import patch, call
  import json
  import pytest


  def test_get_notion_token_returns_stored_value():
      with patch("keyring.get_password", return_value="ntn_abc123") as mock_get:
          from utils.creds import get_notion_token
          assert get_notion_token() == "ntn_abc123"
          mock_get.assert_called_once_with("dmeworks-entry", "notion-token")


  def test_get_notion_token_raises_when_missing():
      with patch("keyring.get_password", return_value=None):
          from utils.creds import get_notion_token
          with pytest.raises(RuntimeError, match="Notion token not found"):
              get_notion_token()


  def test_set_notion_token_calls_keyring():
      with patch("keyring.set_password") as mock_set:
          from utils.creds import set_notion_token
          set_notion_token("ntn_secret")
          mock_set.assert_called_once_with("dmeworks-entry", "notion-token", "ntn_secret")


  def test_has_notion_token_true():
      with patch("keyring.get_password", return_value="ntn_abc"):
          from utils.creds import has_notion_token
          assert has_notion_token() is True


  def test_has_notion_token_false():
      with patch("keyring.get_password", return_value=None):
          from utils.creds import has_notion_token
          assert has_notion_token() is False


  def test_get_db_config_returns_parsed_json():
      cfg = {"host": "192.168.1.10", "port": 3306, "user": "dme", "password": "s3cr3t", "database": "dmeworks"}
      with patch("keyring.get_password", return_value=json.dumps(cfg)):
          from utils.creds import get_db_config
          result = get_db_config("ALLIED")
          assert result == cfg


  def test_get_db_config_raises_when_missing():
      with patch("keyring.get_password", return_value=None):
          from utils.creds import get_db_config
          with pytest.raises(RuntimeError, match="DB config for 'ALLIED' not found"):
              get_db_config("ALLIED")


  def test_set_db_config_stores_json():
      cfg = {"host": "localhost", "port": 3306, "user": "u", "password": "p", "database": "d"}
      with patch("keyring.set_password") as mock_set:
          from utils.creds import set_db_config
          set_db_config("ALLIED", cfg)
          mock_set.assert_called_once_with("dmeworks-entry", "db-ALLIED", json.dumps(cfg))
  ```

- [ ] **Step 2: Run tests — verify they fail**

  ```
  pytest tests/test_creds.py -v
  ```
  Expected: `ImportError` or `ModuleNotFoundError` for `utils.creds`.

- [ ] **Step 3: Implement `utils/creds.py`**

  Create `utils/creds.py`:
  ```python
  import json
  import keyring

  _SERVICE       = "dmeworks-entry"
  _NOTION_ACCT   = "notion-token"


  def get_notion_token() -> str:
      token = keyring.get_password(_SERVICE, _NOTION_ACCT)
      if not token:
          raise RuntimeError(
              "Notion token not found. Run: dmeworks-entry.exe --setup"
          )
      return token


  def set_notion_token(token: str) -> None:
      keyring.set_password(_SERVICE, _NOTION_ACCT, token)


  def has_notion_token() -> bool:
      return keyring.get_password(_SERVICE, _NOTION_ACCT) is not None


  def get_db_config(client_code: str) -> dict:
      raw = keyring.get_password(_SERVICE, f"db-{client_code}")
      if not raw:
          raise RuntimeError(
              f"DB config for '{client_code}' not found. "
              "Run: dmeworks-entry.exe --setup"
          )
      return json.loads(raw)


  def set_db_config(client_code: str, config: dict) -> None:
      keyring.set_password(_SERVICE, f"db-{client_code}", json.dumps(config))


  def has_db_config(client_code: str) -> bool:
      return keyring.get_password(_SERVICE, f"db-{client_code}") is not None
  ```

- [ ] **Step 4: Run tests — verify they pass**

  ```
  pytest tests/test_creds.py -v
  ```
  Expected: 8 tests PASSED.

  > **Note:** If you get `ImportError` for `keyring`, run `pip install keyring`. If `keyring.get_password` patches don't stick across test functions, add `importlib.reload(utils.creds)` or run tests fresh — the patch target must match the import path exactly.

- [ ] **Step 5: Commit**

  ```bash
  git add utils/creds.py tests/test_creds.py
  git commit -m "feat: add utils/creds.py — keyring wrapper for Notion token + DB creds"
  ```

---

## Task 3: `utils/notion.py` — Notion API client

**Files:**
- Create: `tests/test_notion_parse.py`
- Create: `utils/notion.py`

The Notion Patient Tracker DB ID is `9c83bd769bb9424bac74d4760a1450f4`.  
The Doctors DB data source ID is `d1fc2566-ddd3-4640-8fc1-a1b5fc8da7a2`.

**Secondary Insurance field format** (plain text in Notion, JSON string):
```json
{"ins_company": "Aetna", "ins_type": "COMMERCIAL", "policy": "XYZ123", "group": "ABC"}
```

- [ ] **Step 1: Write failing tests**

  Create `tests/test_notion_parse.py`:
  ```python
  import importlib
  import json
  from unittest.mock import patch, MagicMock


  # ── helpers ───────────────────────────────────────────────────────────────────

  def _rt(text):
      """Build a rich_text property value."""
      return {"rich_text": [{"plain_text": text}]}


  def _title(text):
      return {"title": [{"plain_text": text}]}


  def _date(start):
      return {"date": {"start": start}}


  def _phone(number):
      return {"phone_number": number}


  def _relation(page_id):
      return {"relation": [{"id": page_id}]}


  def _select(name):
      return {"select": {"name": name}}


  def _sample_patient_page(
      first="Jane",
      last="Doe",
      mi="A",
      suffix="",
      dob="1950-01-15",
      mbi="1EG4TE5MK72",
      address="123 Main St",
      city="Springfield",
      state="IL",
      zip_="62701",
      phone="2175550199",
      doctor_id="doctor-page-uuid",
      icd10="M54.5|Z96.641",
      secondary=None,
      notes="",
      page_id="patient-page-uuid",
      page_url="https://www.notion.so/patient-page-uuid",
  ):
      props = {
          "Patient Name": _title(f"{first} {last}"),
          "First Name":   _rt(first),
          "Last Name":    _rt(last),
          "MI":           _rt(mi),
          "Suffix":       _rt(suffix),
          "DOB":          _date(dob),
          "MBI":          _rt(mbi),
          "Address":      _rt(address),
          "City":         _rt(city),
          "State":        _rt(state),
          "ZIP":          _rt(zip_),
          "Phone":        _phone(phone),
          "Doctor":       _relation(doctor_id),
          "ICD10 Codes":  _rt(icd10),
          "Secondary Insurance": _rt(json.dumps(secondary) if secondary else ""),
          "Notes":        _rt(notes),
          "Status":       _select("To Enter in DMEworks"),
      }
      return {"id": page_id, "url": page_url, "properties": props}


  def _sample_doctor_response(
      first="John",
      last="Smith",
      npi="1234567890",
      address="456 Oak Ave",
      city="Chicago",
      state="IL",
      zip_="60601",
      phone="3125550100",
  ):
      return {
          "properties": {
              "Doctor Name": _title(f"Dr. {first} {last}"),
              "First Name":  _rt(first),
              "Last Name":   _rt(last),
              "NPI":         _rt(npi),
              "Address":     _rt(address),
              "City":        _rt(city),
              "State":       _rt(state),
              "ZIP":         _rt(zip_),
              "Phone":       _phone(phone),
          }
      }


  # ── tests ─────────────────────────────────────────────────────────────────────

  def test_parse_patient_basic_fields():
      import utils.notion as n
      doctor_resp = _sample_doctor_response()
      page = _sample_patient_page()

      with patch("utils.notion._fetch_doctor", return_value={
          "first": "John", "last": "Smith", "mi": "", "suffix": "",
          "npi": "1234567890", "address1": "456 Oak Ave",
          "city": "Chicago", "state": "IL", "zip": "60601", "phone": "3125550100",
      }):
          result = n._parse_patient("fake-token", page)

      assert result is not None
      assert result["first"] == "Jane"
      assert result["last"] == "Doe"
      assert result["mi"] == "A"
      assert result["mbi"] == "1EG4TE5MK72"
      assert result["dob"] == "01/15/1950"
      assert result["state"] == "IL"
      assert result["city"] == "Springfield"
      assert result["zip"] == "62701"
      assert result["_notion_page_id"] == "patient-page-uuid"
      assert result["_notion_url"] == "https://www.notion.so/patient-page-uuid"


  def test_parse_patient_dob_format():
      import utils.notion as n
      page = _sample_patient_page(dob="1975-12-03")
      with patch("utils.notion._fetch_doctor", return_value={"first": "J", "last": "S", "mi": "", "suffix": "", "npi": "1", "address1": "", "city": "", "state": "", "zip": "", "phone": ""}):
          result = n._parse_patient("t", page)
      assert result["dob"] == "12/03/1975"


  def test_parse_patient_icd10_split():
      import utils.notion as n
      page = _sample_patient_page(icd10="M54.5|Z96.641|E11.9")
      with patch("utils.notion._fetch_doctor", return_value={"first": "J", "last": "S", "mi": "", "suffix": "", "npi": "1", "address1": "", "city": "", "state": "", "zip": "", "phone": ""}):
          result = n._parse_patient("t", page)
      assert result["icd10"] == ["M54.5", "Z96.641", "E11.9"]


  def test_parse_patient_icd10_empty():
      import utils.notion as n
      page = _sample_patient_page(icd10="")
      with patch("utils.notion._fetch_doctor", return_value={"first": "J", "last": "S", "mi": "", "suffix": "", "npi": "1", "address1": "", "city": "", "state": "", "zip": "", "phone": ""}):
          result = n._parse_patient("t", page)
      assert result["icd10"] == []


  def test_parse_patient_secondary_insurance():
      import utils.notion as n
      sec = {"ins_company": "Aetna", "ins_type": "COMMERCIAL", "policy": "XYZ123", "group": ""}
      page = _sample_patient_page(secondary=sec)
      with patch("utils.notion._fetch_doctor", return_value={"first": "J", "last": "S", "mi": "", "suffix": "", "npi": "1", "address1": "", "city": "", "state": "", "zip": "", "phone": ""}):
          result = n._parse_patient("t", page)
      assert result["secondary"] == sec


  def test_parse_patient_no_secondary():
      import utils.notion as n
      page = _sample_patient_page(secondary=None)
      with patch("utils.notion._fetch_doctor", return_value={"first": "J", "last": "S", "mi": "", "suffix": "", "npi": "1", "address1": "", "city": "", "state": "", "zip": "", "phone": ""}):
          result = n._parse_patient("t", page)
      assert result["secondary"] is None


  def test_parse_patient_returns_none_when_missing_required():
      import utils.notion as n
      # No first name
      page = _sample_patient_page(first="")
      with patch("utils.notion._fetch_doctor", return_value={}):
          result = n._parse_patient("t", page)
      assert result is None


  def test_parse_patient_doctor_name_in_result():
      import utils.notion as n
      page = _sample_patient_page()
      with patch("utils.notion._fetch_doctor", return_value={
          "first": "John", "last": "Smith", "mi": "", "suffix": "",
          "npi": "1234567890", "address1": "", "city": "", "state": "", "zip": "", "phone": "",
      }):
          result = n._parse_patient("t", page)
      assert result["doctor"] == "John Smith"
      assert result["_doctor"]["npi"] == "1234567890"


  def test_fetch_doctor_parses_fields():
      import utils.notion as n
      mock_resp = MagicMock()
      mock_resp.json.return_value = _sample_doctor_response()
      mock_resp.raise_for_status = MagicMock()
      with patch("requests.get", return_value=mock_resp):
          result = n._fetch_doctor("fake-token", "doctor-uuid")
      assert result["first"] == "John"
      assert result["last"] == "Smith"
      assert result["npi"] == "1234567890"
      assert result["city"] == "Chicago"
      assert result["phone"] == "3125550100"


  def test_mark_in_dmeworks_calls_patch():
      import utils.notion as n
      mock_resp = MagicMock()
      mock_resp.raise_for_status = MagicMock()
      with patch("requests.patch", return_value=mock_resp) as mock_patch:
          n.mark_in_dmeworks("fake-token", "patient-page-id")
          call_kwargs = mock_patch.call_args
          payload = call_kwargs[1]["json"]
          assert payload["properties"]["Status"]["select"]["name"] == "In DMEworks"
  ```

- [ ] **Step 2: Run tests — verify they fail**

  ```
  pytest tests/test_notion_parse.py -v
  ```
  Expected: `ImportError` or `ModuleNotFoundError` for `utils.notion`.

- [ ] **Step 3: Implement `utils/notion.py`**

  Create `utils/notion.py`:
  ```python
  import json
  from datetime import datetime

  import requests

  _BASE            = "https://api.notion.com/v1"
  _PATIENT_DB_ID   = "9c83bd769bb9424bac74d4760a1450f4"
  _NOTION_VERSION  = "2022-06-28"


  def _headers(token: str) -> dict:
      return {
          "Authorization": f"Bearer {token}",
          "Notion-Version": _NOTION_VERSION,
          "Content-Type": "application/json",
      }


  def fetch_work_queue(token: str) -> list[dict]:
      """Return all patients where Status = 'To Enter in DMEworks'."""
      url     = f"{_BASE}/databases/{_PATIENT_DB_ID}/query"
      payload = {
          "filter": {
              "property": "Status",
              "select": {"equals": "To Enter in DMEworks"},
          }
      }
      patients: list[dict] = []
      while True:
          resp = requests.post(url, headers=_headers(token), json=payload, timeout=30)
          resp.raise_for_status()
          data = resp.json()
          for page in data["results"]:
              p = _parse_patient(token, page)
              if p:
                  patients.append(p)
          if not data.get("has_more"):
              break
          payload["start_cursor"] = data["next_cursor"]
      return patients


  def mark_in_dmeworks(token: str, page_id: str) -> None:
      """Set patient Status = 'In DMEworks' in Notion."""
      url     = f"{_BASE}/pages/{page_id}"
      payload = {"properties": {"Status": {"select": {"name": "In DMEworks"}}}}
      resp    = requests.patch(url, headers=_headers(token), json=payload, timeout=30)
      resp.raise_for_status()


  # ── internal helpers ──────────────────────────────────────────────────────────

  def _parse_patient(token: str, page: dict) -> dict | None:
      props = page["properties"]

      def rt(key: str) -> str:
          items = props.get(key, {}).get("rich_text", [])
          return items[0]["plain_text"].strip() if items else ""

      def phone(key: str) -> str:
          return (props.get(key, {}).get("phone_number") or "").strip()

      def date_to_mdy(key: str) -> str:
          d = props.get(key, {}).get("date") or {}
          start = d.get("start", "")
          if not start:
              return ""
          try:
              return datetime.strptime(start, "%Y-%m-%d").strftime("%m/%d/%Y")
          except ValueError:
              return start

      first = rt("First Name")
      last  = rt("Last Name")
      mbi   = rt("MBI")
      if not first or not last or not mbi:
          return None

      # Resolve linked doctor
      rel     = props.get("Doctor", {}).get("relation", [])
      doc     = _fetch_doctor(token, rel[0]["id"]) if rel else {}
      doc_name = f"{doc.get('first', '')} {doc.get('last', '')}".strip()

      # ICD-10: pipe-separated text → list
      icd10_raw = rt("ICD10 Codes")
      icd10     = [c.strip() for c in icd10_raw.split("|") if c.strip()]

      # Secondary insurance: JSON text field
      secondary = None
      sec_raw   = rt("Secondary Insurance")
      if sec_raw:
          try:
              secondary = json.loads(sec_raw)
          except (json.JSONDecodeError, ValueError):
              secondary = None

      return {
          "first":    first,
          "last":     last,
          "mi":       rt("MI"),
          "suffix":   rt("Suffix"),
          "dob":      date_to_mdy("DOB"),
          "mbi":      mbi,
          "address1": rt("Address"),
          "city":     rt("City"),
          "state":    rt("State"),
          "zip":      rt("ZIP"),
          "phone":    phone("Phone"),
          "doctor":   doc_name,
          "icd10":    icd10,
          "secondary": secondary,
          "notes":    rt("Notes"),
          "_notion_page_id": page["id"],
          "_notion_url":     page["url"],
          "_doctor":         doc,
      }


  def _fetch_doctor(token: str, page_id: str) -> dict:
      url  = f"{_BASE}/pages/{page_id}"
      resp = requests.get(url, headers=_headers(token), timeout=30)
      resp.raise_for_status()
      props = resp.json()["properties"]

      def rt(key: str) -> str:
          items = props.get(key, {}).get("rich_text", [])
          return items[0]["plain_text"].strip() if items else ""

      def phone(key: str) -> str:
          return (props.get(key, {}).get("phone_number") or "").strip()

      return {
          "first":    rt("First Name"),
          "last":     rt("Last Name"),
          "mi":       "",
          "suffix":   "",
          "npi":      rt("NPI"),
          "address1": rt("Address"),
          "city":     rt("City"),
          "state":    rt("State"),
          "zip":      rt("ZIP"),
          "phone":    phone("Phone"),
      }
  ```

- [ ] **Step 4: Run tests — verify they pass**

  ```
  pytest tests/test_notion_parse.py -v
  ```
  Expected: 11 tests PASSED.

- [ ] **Step 5: Commit**

  ```bash
  git add utils/notion.py tests/test_notion_parse.py
  git commit -m "feat: add utils/notion.py — Notion API client for patient fetch and status update"
  ```

---

## Task 4: Update `utils/db.py` — prefer creds.py for configure()

**Files:**
- Modify: `utils/db.py` lines 12–18

The current `configure()` reads DB creds from `ClientStore` (clients.enc). Change it to try `creds.get_db_config()` first (Windows Credential Manager), fall back to `ClientStore` if not found. This allows both old and new credential storage to work.

- [ ] **Step 1: Edit `configure()` in `utils/db.py`**

  Replace the current `configure()` function (lines 12–18):
  ```python
  def configure(client_code: str) -> None:
      """Load DB credentials for the given client from clients.enc."""
      global _conn_params
      from utils.client_store import ClientStore
      store = ClientStore(client_code)
      _conn_params = store.db_config
      store.close()
  ```

  With:
  ```python
  def configure(client_code: str) -> None:
      """Load DB credentials — Windows Credential Manager preferred, clients.enc fallback."""
      global _conn_params
      from utils.creds import get_db_config, has_db_config
      if has_db_config(client_code):
          _conn_params = get_db_config(client_code)
      else:
          from utils.client_store import ClientStore
          store = ClientStore(client_code)
          _conn_params = store.db_config
          store.close()
  ```

- [ ] **Step 2: Run full test suite**

  ```
  pytest tests/ -v
  ```
  Expected: all existing tests still PASS.

- [ ] **Step 3: Commit**

  ```bash
  git add utils/db.py
  git commit -m "feat: db.configure() prefers Windows Credential Manager, falls back to clients.enc"
  ```

---

## Task 5: `entry_setup.py` — first-run credential wizard

**Files:**
- Create: `entry_setup.py`

This runs once on the Allied machine to store the Notion token and MySQL credentials in Windows Credential Manager. Works both as a standalone script (`python entry_setup.py`) and when called from `entry_all.py --setup`.

- [ ] **Step 1: Create `entry_setup.py`**

  ```python
  """
  First-run credential setup — stores Notion token and MySQL credentials
  in Windows Credential Manager (DPAPI-backed, machine-bound).

  Usage:
    python entry_setup.py
    dmeworks-entry.exe --setup
  """

  import getpass
  import os
  import sys

  _ROOT = os.path.dirname(os.path.abspath(__file__))
  if _ROOT not in sys.path:
      sys.path.insert(0, _ROOT)


  def run_setup() -> None:
      from utils.creds import set_notion_token, set_db_config

      print()
      print("=" * 56)
      print("  DMEworks Entry — First-Time Setup")
      print("=" * 56)
      print()
      print("  Credentials are stored in Windows Credential Manager.")
      print("  They are machine-bound and encrypted by Windows (DPAPI).")
      print("  They are NEVER written to disk.")
      print()

      # ── Notion token ───────────────────────────────────────────
      token = getpass.getpass("  Notion API token (starts with ntn_): ").strip()
      if not token:
          print("  Error: token is required.")
          sys.exit(1)
      set_notion_token(token)
      print("  [OK] Notion token stored.")
      print()

      # ── DB credentials ─────────────────────────────────────────
      client_code = input("  Client code (e.g. ALLIED): ").strip().upper()
      if not client_code:
          print("  Error: client code is required.")
          sys.exit(1)

      host     = input("  MySQL host:         ").strip()
      port_str = input("  MySQL port [3306]:  ").strip() or "3306"
      user     = input("  MySQL user:         ").strip()
      password = getpass.getpass("  MySQL password:     ").strip()
      database = input("  MySQL database:     ").strip()

      if not all([host, user, password, database]):
          print("  Error: host, user, password, and database are required.")
          sys.exit(1)

      try:
          port = int(port_str)
      except ValueError:
          print(f"  Error: invalid port '{port_str}'")
          sys.exit(1)

      set_db_config(client_code, {
          "host":     host,
          "port":     port,
          "user":     user,
          "password": password,
          "database": database,
      })
      print(f"  [OK] DB credentials for '{client_code}' stored.")
      print()
      print(f"  Setup complete.")
      print(f"  Run: dmeworks-entry.exe --client {client_code}")
      print("=" * 56)
      print()


  if __name__ == "__main__":
      run_setup()
  ```

- [ ] **Step 2: Verify it runs without error (import only)**

  ```
  python -c "import entry_setup; print('OK')"
  ```
  Expected: `OK`

- [ ] **Step 3: Commit**

  ```bash
  git add entry_setup.py
  git commit -m "feat: add entry_setup.py — first-run credential wizard"
  ```

---

## Task 6: Update `entry_all.py` — Notion patient source + `--setup` mode

**Files:**
- Modify: `entry_all.py`

This is the largest change. The form-filling functions (`create_doctor`, `create_customer`, etc.) are **not touched**. Changes are:

1. `_parse_args()` — add `--setup` flag
2. Module-level data loading — replace `ClientStore` for patients/doctors/insurance with Notion
3. `ensure_all_customers()` — after `create_customer()` succeeds, call `notion.mark_in_dmeworks()`
4. Add `--setup` early-exit before data loading

- [ ] **Step 1: Add `--setup` to `_parse_args()`**

  In `entry_all.py`, find `_parse_args()` (lines 36–41). Replace it:
  ```python
  def _parse_args():
      import argparse
      p = argparse.ArgumentParser()
      p.add_argument("--client",  default=None, help="Client code")
      p.add_argument("--dry-run", action="store_true")
      p.add_argument("--setup",   action="store_true",
                     help="Store Notion token and DB credentials (run once on each machine)")
      return p.parse_args()
  ```

- [ ] **Step 2: Add `--setup` early-exit and Notion data loading**

  Find the module-level data loading block (lines 43–55):
  ```python
  ARGS = _parse_args()
  DRY_RUN = ARGS.dry_run

  # ─── LOAD CLIENT DATA ─────────────────────────────────────────────────────────

  _store = ClientStore(ARGS.client)
  MEDICARE_BY_STATE   = ClientStore.medicare_map()
  DOCTORS             = _store.doctors
  PATIENTS            = _store.patients
  INSURANCE_COMPANIES = _store.insurance_companies
  _store.close()

  db.configure(ARGS.client)
  ```

  Replace with:
  ```python
  ARGS    = _parse_args()
  DRY_RUN = ARGS.dry_run

  # ─── SETUP MODE ───────────────────────────────────────────────────────────────

  if ARGS.setup:
      from entry_setup import run_setup
      run_setup()
      sys.exit(0)

  if not ARGS.client:
      print("error: --client is required (or use --setup for first-time credential setup)")
      sys.exit(1)

  # ─── LOAD CLIENT DATA ─────────────────────────────────────────────────────────

  from utils import notion
  from utils.client_store import ClientStore
  from utils.creds import get_notion_token

  MEDICARE_BY_STATE = ClientStore.medicare_map()

  _token      = get_notion_token()
  _raw        = notion.fetch_work_queue(_token)

  # Unique doctors by NPI
  _seen_npis: set[str] = set()
  DOCTORS: list[dict]  = []
  for _p in _raw:
      _d   = _p.get("_doctor", {})
      _npi = _d.get("npi", "")
      if _npi and _npi not in _seen_npis:
          _seen_npis.add(_npi)
          DOCTORS.append(_d)

  PATIENTS: list[dict] = _raw

  # Derive insurance companies from patient states + secondary fields
  _seen_ins: set[str]          = set()
  INSURANCE_COMPANIES: list[dict] = []
  for _p in PATIENTS:
      _medicare_name = MEDICARE_BY_STATE.get(_p.get("state", ""), "")
      if _medicare_name and _medicare_name not in _seen_ins:
          _seen_ins.add(_medicare_name)
          INSURANCE_COMPANIES.append({"name": _medicare_name, "type": "MEDICARE"})
      _sec = _p.get("secondary") or {}
      _sec_name = _sec.get("ins_company", "")
      if _sec_name and _sec_name not in _seen_ins:
          _seen_ins.add(_sec_name)
          INSURANCE_COMPANIES.append({"name": _sec_name, "type": "OTHER"})

  db.configure(ARGS.client)
  ```

- [ ] **Step 3: Remove unused top-level import of `ClientStore`**

  Find line 29:
  ```python
  from utils.client_store import ClientStore
  ```
  Delete it (ClientStore is now imported inside the data loading block only).

- [ ] **Step 4: Update `ensure_all_customers()` — mark in Notion after each successful entry**

  Find `ensure_all_customers()` (around line 535). Inside the `for i, p in enumerate(to_create, 1):` loop, find:
  ```python
        try:
            create_customer(p, main_win, a)
        except Exception as e:
            log.error("  [ERROR]  %s — %s", label, e)
  ```

  Replace with:
  ```python
        try:
            create_customer(p, main_win, a)
            if p.get("_notion_page_id"):
                try:
                    notion.mark_in_dmeworks(_token, p["_notion_page_id"])
                    log.info("    [notion] Status → In DMEworks")
                except Exception as ne:
                    log.warning("    [notion] Status update failed: %s", ne)
        except Exception as e:
            log.error("  [ERROR]  %s — %s", label, e)
  ```

- [ ] **Step 5: Verify the file imports cleanly in --setup mode (no Notion call)**

  ```
  python entry_all.py --setup
  ```
  Expected: runs setup wizard (Ctrl+C to exit without entering creds).

  The important thing: no crash at import-time from missing `_token` or Notion call.

- [ ] **Step 6: Run full test suite**

  ```
  pytest tests/ -v
  ```
  Expected: all tests PASS.

- [ ] **Step 7: Commit**

  ```bash
  git add entry_all.py
  git commit -m "feat: entry_all.py reads patients from Notion, marks In DMEworks after entry"
  ```

---

## Task 7: Update `packaging/dmeworks.spec` — add hidden imports

**Files:**
- Modify: `packaging/dmeworks.spec`

- [ ] **Step 1: Edit the `hiddenimports` list in `packaging/dmeworks.spec`**

  Find:
  ```python
      hiddenimports=[
          "mysql.connector",
          "mysql.connector.locales",
          "mysql.connector.locales.eng",
          "keyring.backends.Windows",
          "cryptography.fernet",
      ],
  ```

  Replace with:
  ```python
      hiddenimports=[
          "mysql.connector",
          "mysql.connector.locales",
          "mysql.connector.locales.eng",
          "keyring.backends.Windows",
          "cryptography.fernet",
          "requests",
          "requests.adapters",
          "urllib3",
          "urllib3.util.retry",
          "charset_normalizer",
      ],
  ```

- [ ] **Step 2: Commit**

  ```bash
  git add packaging/dmeworks.spec
  git commit -m "chore: add requests hidden imports for PyInstaller"
  ```

---

## Task 8: Manual validation checklist

Run on dev machine with DMEworks open and Notion + MySQL creds already set up.

- [ ] **Setup flow**

  ```
  python entry_all.py --setup
  ```
  - Prompts for Notion token, client code, MySQL creds
  - Confirms "[OK] stored" for each
  - Exits cleanly

- [ ] **Dry run with real Notion data**

  ```
  python entry_all.py --client ALLIED --dry-run
  ```
  Expected:
  - Fetches patients from Notion (logs count)
  - Bulk-checks MySQL — skips existing MBIs
  - Logs `[DRY RUN] skipping UI` for each new patient
  - Does NOT update Notion status (dry run)
  - No crash

- [ ] **Full run — single patient**

  Add a test patient in Notion with Status = "To Enter in DMEworks".  
  Run:
  ```
  python entry_all.py --client ALLIED
  ```
  Expected:
  - Patient entered in DMEworks
  - Log shows `[notion] Status → In DMEworks`
  - In Notion: patient Status changed to "In DMEworks"
  - Verification pass: `[PASS]` for patient

- [ ] **Idempotency — run again immediately**

  ```
  python entry_all.py --client ALLIED
  ```
  Expected:
  - Notion returns 0 patients (all are "In DMEworks" now)
  - Log: `All patients already in DB — nothing to do`

- [ ] **Build EXE and smoke test**

  ```
  python build.py
  ```
  Then on Allied machine:
  ```
  dmeworks-entry.exe --setup
  dmeworks-entry.exe --client ALLIED --dry-run
  ```
