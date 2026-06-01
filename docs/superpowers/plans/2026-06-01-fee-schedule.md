# Fee Schedule Module Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a `fee_schedule.py` module that downloads the current CMS DMEPOS fee schedule at startup and exposes `get_allowable(hcpcs, state, schedule) -> (allowable, billable)` for use in DMEworks automation, plus wire it into `entry_all.py`, add HCPCS codes to the Notion patient parser, and create a standalone Notion documentation page.

**Architecture:** At startup, `load_fee_schedule()` downloads the current quarter's CMS DMEPOS ZIP file, parses the pipe-delimited fee schedule into an in-memory `{(hcpcs, state): allowable}` dict, and returns it. Callers look up rates with `get_allowable()`, which falls back to a manual `input()` prompt on a miss. A separate `tools/create_notion_docs.py` script creates an "DME Auto — App Reference" page at the Notion workspace root.

**Tech Stack:** Python 3.11+, `requests` (already in requirements.txt), `zipfile` + `csv` + `io` (stdlib), Notion API (existing `utils/notion.py` helpers).

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `fee_schedule.py` | CMS download, parse, `load_fee_schedule()`, `get_allowable()` |
| Create | `tests/test_fee_schedule.py` | Unit tests for fee_schedule module |
| Modify | `utils/notion.py` | Add `hcpcs` field to `_parse_patient()` |
| Modify | `tests/test_notion_parse.py` | Add `hcpcs` param to `_sample_patient_page()`, add 2 tests |
| Modify | `entry_all.py` | Load fee schedule at module level alongside Notion data |
| Create | `tools/create_notion_docs.py` | Standalone script: creates Notion reference page |

---

## Task 1: Probe CMS fee schedule URL and column layout

**Files:** No files saved — run inline and record output.

This is a required discovery step. Run it before writing any parser code. It confirms (a) the ZIP URL works for the current quarter and (b) which pipe-delimited columns contain HCPCS code, state, and fee amount.

- [ ] **Step 1: Run the probe script**

Open a Python REPL or paste this into a temp file and run it:

```python
import io, zipfile, requests
from datetime import datetime, timezone

now = datetime.now(timezone.utc)
year = str(now.year)[2:]
q = ["a","a","a","b","b","b","c","c","c","d","d","d"][now.month - 1]
quarter = f"{year}{q}"

url = f"https://www.cms.gov/files/zip/dme{quarter}.zip"
print(f"Quarter: {quarter}")
print(f"URL: {url}")

resp = requests.get(url, timeout=30)
print(f"HTTP status: {resp.status_code}")

if resp.status_code == 200:
    with zipfile.ZipFile(io.BytesIO(resp.content)) as zf:
        print(f"ZIP contents: {zf.namelist()}")
        txt = [n for n in zf.namelist() if n.upper().endswith(".TXT")]
        if txt:
            with zf.open(txt[0]) as f:
                lines = f.read().decode("latin-1").splitlines()
            print(f"\n--- {txt[0]} --- first 3 rows ---")
            for line in lines[:3]:
                cols = line.split("|")
                for i, col in enumerate(cols):
                    print(f"  [{i}] {repr(col)}")
                print()
else:
    print("FAILED — try fetching the CMS DMEPOS fee schedule index page manually")
    print("https://www.cms.gov/medicare/payment/fee-schedules/dmepos/dmepos-fee-schedule")
    print("Find the current quarter ZIP link and note the URL pattern.")
```

- [ ] **Step 2: Record the column indices**

From the output, identify:
- Which index contains the 5-char HCPCS code (e.g. `L0457`) → `_COL_HCPCS`
- Which index contains the 2-letter state (e.g. `NJ`) → `_COL_STATE`
- Which index contains the dollar fee amount → `_COL_FEE`

Write these down — you'll use them in Task 2.

If the URL returned 404, check the CMS page for the actual current quarter ZIP filename and update `_CMS_URL_PATTERN` in Task 2 accordingly.

---

## Task 2: Implement `_current_quarter()` — TDD

**Files:**
- Create: `tests/test_fee_schedule.py`
- Create: `fee_schedule.py`

- [ ] **Step 1: Write the failing test**

Create `tests/test_fee_schedule.py`:

```python
from datetime import datetime, timezone
from unittest.mock import patch, MagicMock
import io, zipfile
import pytest

import fee_schedule as fs


class TestCurrentQuarter:
    def test_q1_january(self):
        now = datetime(2026, 1, 15, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26a"

    def test_q1_march(self):
        now = datetime(2026, 3, 31, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26a"

    def test_q2_april(self):
        now = datetime(2026, 4, 1, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26b"

    def test_q2_june(self):
        now = datetime(2026, 6, 15, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26b"

    def test_q3_july(self):
        now = datetime(2026, 7, 1, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26c"

    def test_q4_december(self):
        now = datetime(2026, 12, 31, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26d"

    def test_year_boundary_2027(self):
        now = datetime(2027, 1, 1, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "27a"

    def test_no_arg_returns_string(self):
        result = fs._current_quarter()
        assert len(result) == 3
        assert result[2] in ("a", "b", "c", "d")
```

- [ ] **Step 2: Run to confirm failure**

```
pytest tests/test_fee_schedule.py -v
```

Expected: `ModuleNotFoundError: No module named 'fee_schedule'`

- [ ] **Step 3: Create `fee_schedule.py` with `_current_quarter()`**

```python
import csv
import io
import zipfile
from datetime import datetime, timezone

import requests

_CMS_URL_PATTERN = "https://www.cms.gov/files/zip/dme{quarter}.zip"

# Column indices in the CMS pipe-delimited fee schedule file.
# Confirmed via Task 1 probe — adjust if your file differs.
_COL_HCPCS = 0
_COL_STATE  = 4
_COL_FEE    = 7


def _current_quarter(now: datetime | None = None) -> str:
    """Return 2-char quarter string e.g. '26b' for April-June 2026."""
    if now is None:
        now = datetime.now(timezone.utc)
    year = str(now.year)[2:]
    quarter = ["a","a","a","b","b","b","c","c","c","d","d","d"][now.month - 1]
    return f"{year}{quarter}"
```

- [ ] **Step 4: Run tests — expect pass**

```
pytest tests/test_fee_schedule.py::TestCurrentQuarter -v
```

Expected: 8 passed.

- [ ] **Step 5: Commit**

```
git add fee_schedule.py tests/test_fee_schedule.py
git commit -m "feat(fee-schedule): add _current_quarter with TDD"
```

---

## Task 3: Implement `load_fee_schedule()` — TDD

**Files:**
- Modify: `fee_schedule.py`
- Modify: `tests/test_fee_schedule.py`

- [ ] **Step 1: Add test helper and tests**

Append to `tests/test_fee_schedule.py`:

```python
# ── helpers ───────────────────────────────────────────────────────────────────

def _make_zip(rows: list[str], filename: str = "DMEPOS26B.TXT") -> bytes:
    """Build an in-memory ZIP containing a single pipe-delimited .TXT file."""
    content = "\n".join(rows).encode("latin-1")
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        zf.writestr(filename, content)
    return buf.getvalue()


def _mock_response(zip_bytes: bytes) -> MagicMock:
    resp = MagicMock()
    resp.content = zip_bytes
    resp.raise_for_status = MagicMock()
    return resp


# ── load_fee_schedule tests ───────────────────────────────────────────────────

class TestLoadFeeSchedule:
    def _rows(self):
        # Format: col0=HCPCS col1=mod col2=desc col3=note col4=STATE col5=cat col6=cat2 col7=FEE
        return [
            "L0457||Lumbar orthosis||NJ|A|PC|412.50",
            "L0457||Lumbar orthosis||NY|A|PC|412.50",
            "L1833||Knee orthosis||OH|A|PC|550.00",
            "L1833||Knee orthosis||SC|A|PC|480.00",
            "invalid_row",
            "TOOSHORT|only|two",
        ]

    def test_returns_dict_on_success(self):
        mock_resp = _mock_response(_make_zip(self._rows()))
        with patch("fee_schedule.requests.get", return_value=mock_resp):
            schedule = fs.load_fee_schedule()
        assert isinstance(schedule, dict)
        assert ("L0457", "NJ") in schedule
        assert schedule[("L0457", "NJ")] == 412.50

    def test_multiple_states_for_same_hcpcs(self):
        mock_resp = _mock_response(_make_zip(self._rows()))
        with patch("fee_schedule.requests.get", return_value=mock_resp):
            schedule = fs.load_fee_schedule()
        assert schedule[("L0457", "NY")] == 412.50
        assert schedule[("L1833", "OH")] == 550.00
        assert schedule[("L1833", "SC")] == 480.00

    def test_skips_malformed_rows(self):
        mock_resp = _mock_response(_make_zip(self._rows()))
        with patch("fee_schedule.requests.get", return_value=mock_resp):
            schedule = fs.load_fee_schedule()
        # "invalid_row" and "TOOSHORT|only|two" should not crash or appear
        assert len(schedule) == 4

    def test_returns_empty_on_http_error(self, capsys):
        with patch("fee_schedule.requests.get", side_effect=Exception("connection timeout")):
            schedule = fs.load_fee_schedule()
        assert schedule == {}
        captured = capsys.readouterr()
        assert "[fee_schedule] WARNING" in captured.out

    def test_returns_empty_on_bad_zip(self, capsys):
        resp = MagicMock()
        resp.content = b"not a zip file"
        resp.raise_for_status = MagicMock()
        with patch("fee_schedule.requests.get", return_value=resp):
            schedule = fs.load_fee_schedule()
        assert schedule == {}

    def test_keys_are_uppercase(self):
        rows = ["l0457||desc||nj|A|PC|412.50"]
        mock_resp = _mock_response(_make_zip(rows))
        with patch("fee_schedule.requests.get", return_value=mock_resp):
            schedule = fs.load_fee_schedule()
        assert ("L0457", "NJ") in schedule
```

- [ ] **Step 2: Run to confirm failure**

```
pytest tests/test_fee_schedule.py::TestLoadFeeSchedule -v
```

Expected: `AttributeError: module 'fee_schedule' has no attribute 'load_fee_schedule'`

- [ ] **Step 3: Implement `load_fee_schedule()` in `fee_schedule.py`**

Add after `_current_quarter`:

```python
def load_fee_schedule() -> dict[tuple[str, str], float]:
    """Download current CMS DMEPOS fee schedule ZIP, parse into lookup dict.
    Returns {(hcpcs_upper, state_upper): allowable_amount}.
    Returns empty dict on any failure — callers fall back to manual input."""
    quarter = _current_quarter()
    url = _CMS_URL_PATTERN.format(quarter=quarter)
    try:
        resp = requests.get(url, timeout=30)
        resp.raise_for_status()
    except Exception as exc:
        print(f"[fee_schedule] WARNING: Could not download fee schedule ({exc})")
        print(f"[fee_schedule] URL: {url}")
        print("[fee_schedule] All lookups will prompt for manual entry.")
        return {}

    try:
        with zipfile.ZipFile(io.BytesIO(resp.content)) as zf:
            txt_names = [n for n in zf.namelist() if n.upper().endswith(".TXT")]
            if not txt_names:
                raise ValueError(f"No .TXT file in ZIP. Contents: {zf.namelist()}")
            with zf.open(sorted(txt_names)[0]) as f:
                text = f.read().decode("latin-1")
    except Exception as exc:
        print(f"[fee_schedule] WARNING: Could not parse ZIP ({exc})")
        return {}

    schedule: dict[tuple[str, str], float] = {}
    reader = csv.reader(io.StringIO(text), delimiter="|")
    for row in reader:
        if len(row) <= max(_COL_HCPCS, _COL_STATE, _COL_FEE):
            continue
        try:
            hcpcs   = row[_COL_HCPCS].strip().upper()
            state   = row[_COL_STATE].strip().upper()
            fee_str = row[_COL_FEE].strip()
            if not hcpcs or not state or not fee_str:
                continue
            schedule[(hcpcs, state)] = float(fee_str)
        except (ValueError, IndexError):
            continue

    return schedule
```

- [ ] **Step 4: Run tests — expect pass**

```
pytest tests/test_fee_schedule.py::TestLoadFeeSchedule -v
```

Expected: 6 passed.

- [ ] **Step 5: Commit**

```
git add fee_schedule.py tests/test_fee_schedule.py
git commit -m "feat(fee-schedule): implement load_fee_schedule with TDD"
```

---

## Task 4: Implement `get_allowable()` and `_prompt_manual()` — TDD

**Files:**
- Modify: `fee_schedule.py`
- Modify: `tests/test_fee_schedule.py`

- [ ] **Step 1: Add tests**

Append to `tests/test_fee_schedule.py`:

```python
class TestGetAllowable:
    def test_hit_returns_allowable_and_double(self):
        schedule = {("L0457", "NJ"): 412.50}
        allowable, billable = fs.get_allowable("L0457", "NJ", schedule)
        assert allowable == 412.50
        assert billable == 825.00

    def test_hit_case_insensitive(self):
        schedule = {("L0457", "NJ"): 412.50}
        allowable, billable = fs.get_allowable("l0457", "nj", schedule)
        assert allowable == 412.50
        assert billable == 825.00

    def test_billable_rounded_to_cents(self):
        schedule = {("L0457", "NJ"): 100.005}
        _, billable = fs.get_allowable("L0457", "NJ", schedule)
        assert billable == 200.01

    def test_miss_prompts_for_manual_entry(self):
        schedule = {}
        with patch("builtins.input", return_value="300.00"):
            allowable, billable = fs.get_allowable("L0457", "NJ", schedule)
        assert allowable == 300.00
        assert billable == 600.00

    def test_miss_reprompts_on_invalid_input(self):
        schedule = {}
        with patch("builtins.input", side_effect=["abc", "xyz", "250.00"]):
            allowable, _ = fs.get_allowable("L0457", "NJ", schedule)
        assert allowable == 250.00

    def test_empty_schedule_prompts(self):
        with patch("builtins.input", return_value="100.00"):
            allowable, billable = fs.get_allowable("XXXXX", "ZZ", {})
        assert allowable == 100.00
        assert billable == 200.00
```

- [ ] **Step 2: Run to confirm failure**

```
pytest tests/test_fee_schedule.py::TestGetAllowable -v
```

Expected: `AttributeError: module 'fee_schedule' has no attribute 'get_allowable'`

- [ ] **Step 3: Implement `get_allowable()` and `_prompt_manual()` in `fee_schedule.py`**

Add after `load_fee_schedule`:

```python
def get_allowable(
    hcpcs_code: str,
    state: str,
    schedule: dict[tuple[str, str], float],
) -> tuple[float, float]:
    """Return (allowable, billable=2x allowable).
    Prompts for manual entry if code+state not found in schedule."""
    key = (hcpcs_code.strip().upper(), state.strip().upper())
    amount = schedule.get(key)
    if amount is None:
        amount = _prompt_manual(hcpcs_code.strip().upper(), state.strip().upper())
    return amount, round(amount * 2, 2)


def _prompt_manual(hcpcs: str, state: str) -> float:
    while True:
        raw = input(f"  Enter Medicare allowable for {hcpcs}/{state}: $").strip()
        try:
            return float(raw)
        except ValueError:
            print("  Invalid — enter a number (e.g. 412.50)")
```

- [ ] **Step 4: Run all fee_schedule tests**

```
pytest tests/test_fee_schedule.py -v
```

Expected: all tests pass (14+).

- [ ] **Step 5: Commit**

```
git add fee_schedule.py tests/test_fee_schedule.py
git commit -m "feat(fee-schedule): implement get_allowable with manual fallback"
```

---

## Task 5: Live verification run

**Files:**
- Modify: `fee_schedule.py` (add `__main__` block)

- [ ] **Step 1: Add `__main__` block to `fee_schedule.py`**

Append to the end of `fee_schedule.py`:

```python
if __name__ == "__main__":
    print("Loading CMS DMEPOS fee schedule...")
    schedule = load_fee_schedule()
    if not schedule:
        print("FAILED — schedule is empty. Check warnings above.")
    else:
        print(f"Loaded {len(schedule)} entries.\n")
        test_cases = [
            ("L0457", "NJ"),
            ("L1833", "NJ"),
            ("L0457", "OH"),
            ("L0457", "SC"),
            ("L1833", "OH"),
            ("L1833", "SC"),
        ]
        print(f"{'HCPCS':<8} {'State':<6} {'Allowable':>12} {'Billable':>12}")
        print("-" * 42)
        for hcpcs, state in test_cases:
            key = (hcpcs, state)
            amount = schedule.get(key)
            if amount is not None:
                allowable, billable = get_allowable(hcpcs, state, schedule)
                print(f"{hcpcs:<8} {state:<6} ${allowable:>11.2f} ${billable:>11.2f}")
            else:
                print(f"{hcpcs:<8} {state:<6} {'NOT FOUND':>12}")
```

- [ ] **Step 2: Run the live verification**

```
python fee_schedule.py
```

Expected output (amounts will reflect current CMS rates):
```
Loading CMS DMEPOS fee schedule...
Loaded XXXXX entries.

HCPCS    State     Allowable      Billable
------------------------------------------
L0457    NJ        $    XXX.XX    $    XXX.XX
L1833    NJ        $    XXX.XX    $    XXX.XX
L0457    OH        $    XXX.XX    $    XXX.XX
L0457    SC        $    XXX.XX    $    XXX.XX
L1833    OH        $    XXX.XX    $    XXX.XX
L1833    SC        $    XXX.XX    $    XXX.XX
```

All 6 rows must show dollar amounts, not `NOT FOUND`. If any show `NOT FOUND`, revisit `_COL_HCPCS`, `_COL_STATE`, `_COL_FEE` constants against Task 1 output and adjust.

- [ ] **Step 3: Commit**

```
git add fee_schedule.py
git commit -m "feat(fee-schedule): add __main__ verification block"
```

---

## Task 6: Add `hcpcs` field to Notion patient parser — TDD

**Files:**
- Modify: `tests/test_notion_parse.py`
- Modify: `utils/notion.py`

- [ ] **Step 1: Add `hcpcs` param to `_sample_patient_page()` and add two tests**

In `tests/test_notion_parse.py`, add `hcpcs=""` parameter to `_sample_patient_page()`:

```python
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
    gender="Male",
    height="65",
    weight="150",
    waist_size="",
    hcpcs="",                         # <-- add this parameter
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
        "Prescribing Doctor": _relation(doctor_id),
        "ICD10 Codes":  _rt(icd10),
        "Secondary Insurance": _rt(json.dumps(secondary) if secondary else ""),
        "Notes":        _rt(notes),
        "Status":       _select("To Enter in DMEworks"),
        "Gender":       _select(gender),
        "Height":       _rt(height),
        "Weight":       _rt(weight),
        "Waist Size":   _rt(waist_size),
        "HCPCS Codes":  _rt(hcpcs),   # <-- add this line
    }
    return {"id": page_id, "url": page_url, "properties": props}
```

Then append two tests at the bottom of `tests/test_notion_parse.py`:

```python
def test_parse_patient_hcpcs_pipe_split():
    import utils.notion as n
    page = _sample_patient_page(hcpcs="L0457|L1833|L0631")
    with patch("utils.notion._fetch_doctor", return_value={
        "first": "J", "last": "S", "mi": "", "suffix": "", "npi": "1",
        "address1": "", "city": "", "state": "", "zip": "", "phone": "",
    }):
        result = n._parse_patient("t", page)
    assert result["hcpcs"] == ["L0457", "L1833", "L0631"]


def test_parse_patient_hcpcs_empty():
    import utils.notion as n
    page = _sample_patient_page(hcpcs="")
    with patch("utils.notion._fetch_doctor", return_value={
        "first": "J", "last": "S", "mi": "", "suffix": "", "npi": "1",
        "address1": "", "city": "", "state": "", "zip": "", "phone": "",
    }):
        result = n._parse_patient("t", page)
    assert result["hcpcs"] == []
```

- [ ] **Step 2: Run to confirm failure**

```
pytest tests/test_notion_parse.py::test_parse_patient_hcpcs_pipe_split tests/test_notion_parse.py::test_parse_patient_hcpcs_empty -v
```

Expected: `KeyError: 'hcpcs'`

- [ ] **Step 3: Add `hcpcs` to `_parse_patient()` in `utils/notion.py`**

In `utils/notion.py`, find the ICD-10 parsing block at line ~227:

```python
    # ICD-10: pipe-separated text → list
    icd10_raw = rt("ICD10 Codes")
    icd10     = [c.strip() for c in icd10_raw.split("|") if c.strip()]
```

Add immediately after it:

```python
    # HCPCS codes: pipe-separated text → list
    hcpcs_raw = rt("HCPCS Codes")
    hcpcs     = [c.strip() for c in hcpcs_raw.split("|") if c.strip()]
```

Then add `"hcpcs": hcpcs` to the returned dict (line ~260), alongside `"icd10"`:

```python
        "icd10":      icd10,
        "hcpcs":      hcpcs,
```

- [ ] **Step 4: Run all notion tests**

```
pytest tests/test_notion_parse.py -v
```

Expected: all tests pass including the 2 new ones.

- [ ] **Step 5: Commit**

```
git add utils/notion.py tests/test_notion_parse.py
git commit -m "feat(notion): add hcpcs field to patient parser"
```

---

## Task 7: Wire fee schedule into `entry_all.py`

**Files:**
- Modify: `entry_all.py`

No new tests needed — `load_fee_schedule()` is already tested. This task is purely wiring.

- [ ] **Step 1: Add import and load call in `entry_all.py`**

Find the module-level data loading section (around line 231–275 in `entry_all.py`):

```python
_token             = get_notion_token()
INSURANCE_BY_STATE = notion.fetch_insurance_map(_token)
```

Add immediately after `INSURANCE_BY_STATE`:

```python
from fee_schedule import load_fee_schedule, get_allowable
FEE_SCHEDULE = load_fee_schedule()
```

The full block should look like:

```python
_token             = get_notion_token()
INSURANCE_BY_STATE = notion.fetch_insurance_map(_token)

from fee_schedule import load_fee_schedule, get_allowable
FEE_SCHEDULE = load_fee_schedule()
```

- [ ] **Step 2: Verify startup still works**

```
python entry_all.py --mode audit
```

Expected: starts normally, prints fee schedule load status before the audit output, no errors.

If `FEE_SCHEDULE` loads 0 entries, revisit column constants in `fee_schedule.py` — run the Task 1 probe again if needed.

- [ ] **Step 3: Commit**

```
git add entry_all.py
git commit -m "feat(entry): load CMS fee schedule at startup"
```

---

## Task 8: Create `tools/create_notion_docs.py`

**Files:**
- Create: `tools/create_notion_docs.py`

No automated tests — this is a one-shot script with external side effects. Verify by running it and checking Notion.

**Pre-requisite:** The Notion integration must have workspace-level access. In Notion:
1. Go to Settings → Connections (or Settings & members → Integrations)
2. Find the integration used by this app (same one that reads the patient database)
3. Ensure it has access to the workspace, not just specific pages
4. If it only has page-scoped access, update it to workspace access before running this script

- [ ] **Step 1: Create `tools/create_notion_docs.py`**

```python
"""
Create or update the "DME Auto — App Reference" page at Notion workspace root.
Run once manually; idempotent (creates only if page doesn't already exist at root).

Usage:
    python tools/create_notion_docs.py
"""

import os
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from datetime import datetime, timezone
from utils.notion import _BASE, _NOTION_VERSION, _request
from utils.creds import get_notion_token
from fee_schedule import load_fee_schedule, _current_quarter

_HCPCS_CODES = [
    "L0457", "L1833", "L0631", "L0637", "L0648", "L0650",
    "L1832", "L1843", "L1845", "L1851", "L1852", "L2397",
    "L3760", "L3761", "L3915", "L3916", "L3960", "L1971", "A4239",
]

_STATES = ["NJ", "NY", "OH", "IL", "SC"]

_JURISDICTIONS = {
    "JA (Noridian)": "CT, DE, DC, ME, MD, MA, NH, NJ, NY, PA, RI, VT",
    "JB (CGS)":      "IL, IN, KY, MI, MN, OH, WI",
    "JC (CGS)":      "AL, AR, CO, FL, GA, LA, MS, NM, NC, OK, PR, SC, TN, TX, VA, WV, VI",
    "JD (Noridian)": "AK, AS, AZ, CA, GU, HI, ID, MT, ND, NV, OR, SD, UT, WA, WY",
}


def _headers(token: str) -> dict:
    return {
        "Authorization": f"Bearer {token}",
        "Notion-Version": _NOTION_VERSION,
        "Content-Type": "application/json",
    }


def _h2(text: str) -> dict:
    return {
        "object": "block", "type": "heading_2",
        "heading_2": {"rich_text": [{"type": "text", "text": {"content": text}}]},
    }


def _h3(text: str) -> dict:
    return {
        "object": "block", "type": "heading_3",
        "heading_3": {"rich_text": [{"type": "text", "text": {"content": text}}]},
    }


def _p(text: str) -> dict:
    return {
        "object": "block", "type": "paragraph",
        "paragraph": {"rich_text": [{"type": "text", "text": {"content": text}}]},
    }


def _code(text: str, language: str = "plain text") -> dict:
    return {
        "object": "block", "type": "code",
        "code": {
            "rich_text": [{"type": "text", "text": {"content": text}}],
            "language": language,
        },
    }


def _divider() -> dict:
    return {"object": "block", "type": "divider", "divider": {}}


def _build_rates_table(schedule: dict) -> str:
    header = f"{'HCPCS':<8}" + "".join(f"{s:>10}" for s in _STATES)
    lines = [header, "-" * (8 + 10 * len(_STATES))]
    for hcpcs in _HCPCS_CODES:
        row = f"{hcpcs:<8}"
        for state in _STATES:
            amt = schedule.get((hcpcs, state))
            row += f"{'$'+f'{amt:.2f}':>10}" if amt else f"{'N/A':>10}"
        lines.append(row)
    return "\n".join(lines)


def build_page_children(schedule: dict, quarter: str) -> list:
    now_str = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    return [
        _h2("Overview"),
        _p(
            "DMEworks automation for Allied Medical Health. "
            "Reads patient queue from Notion (status: 'To Enter in DMEworks'), "
            "then enters each record into DMEworks via UI automation (pywinauto)."
        ),
        _p("Modes: run (production), test (UI test on test records), audit (Notion vs DB diff), fix (correct audit diffs)."),
        _p("Deployment: single EXE built via PyInstaller. Copy dme-auto.exe to workstation — nothing else needed."),
        _divider(),

        _h2("Fee Schedule"),
        _p(
            "Source: CMS DMEPOS fee schedule — the authoritative Medicare allowable rates for DME. "
            "Updated quarterly (Jan/Apr/Jul/Oct). "
            "Downloaded at startup from cms.gov as a ZIP, parsed in memory. No caching."
        ),
        _p(f"Current quarter: {quarter.upper()}  |  Last fetched: {now_str}"),
        _p(
            "Module: fee_schedule.py. Call load_fee_schedule() once at startup, "
            "then get_allowable(hcpcs, state, schedule) -> (allowable, billable). "
            "Billable = 2x allowable. On miss: prompts for manual entry."
        ),
        _divider(),

        _h2("HCPCS Codes"),
        _p("Codes billed by Allied Medical Health:"),
        _code("  ".join(_HCPCS_CODES)),
        _p(
            "In Notion: add to the 'HCPCS Codes' rich_text property on each patient record. "
            "Pipe-separated format: L0457|L1833|L0631"
        ),
        _divider(),

        _h2("States & MAC Jurisdictions"),
        _p("The MAC (Medicare Administrative Contractor) depends on the patient's state, not the provider's."),
        *[_p(f"  {jur}: {states}") for jur, states in _JURISDICTIONS.items()],
        _p("Currently serving: " + ", ".join(_STATES)),
        _divider(),

        _h2(f"Current Allowable Rates — Q{quarter[-1].upper()} 20{quarter[:2]}"),
        _p(f"Generated {now_str}. Amounts are Medicare allowables. Billable = 2x allowable."),
        _code(_build_rates_table(schedule) if schedule else "(fee schedule unavailable — run create_notion_docs.py when connected)"),
    ]


def create_docs_page(token: str, schedule: dict, quarter: str) -> str:
    children = build_page_children(schedule, quarter)
    payload = {
        "parent": {"type": "workspace", "workspace": True},
        "properties": {
            "title": {"title": [{"type": "text", "text": {"content": "DME Auto — App Reference"}}]}
        },
        "children": children,
    }
    resp = _request("post", f"{_BASE}/pages", _headers(token), json=payload)
    page_id = resp.json()["id"]
    page_url = resp.json().get("url", "")
    return page_url


def main():
    print("Loading Notion token...")
    token = get_notion_token()

    print("Loading CMS fee schedule...")
    schedule = load_fee_schedule()
    quarter  = _current_quarter()
    print(f"  Quarter: {quarter} | Entries loaded: {len(schedule)}")

    print("Creating Notion page...")
    try:
        url = create_docs_page(token, schedule, quarter)
        print(f"  Created: {url}")
    except Exception as e:
        print(f"  FAILED: {e}")
        print()
        print("  If you see a 'parent type not supported' error, the Notion integration")
        print("  needs workspace-level access. Update it in Notion Settings → Connections.")
        sys.exit(1)


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Run the script**

```
python tools/create_notion_docs.py
```

Expected output:
```
Loading Notion token...
Loading CMS fee schedule...
  Quarter: 26b | Entries loaded: XXXXX
Creating Notion page...
  Created: https://www.notion.so/DME-Auto-App-Reference-XXXXXXXX
```

- [ ] **Step 3: Verify in Notion**

Open the URL printed above. Confirm:
- Page appears at workspace root in Allied Medical space
- All sections present: Overview, Fee Schedule, HCPCS Codes, States & Jurisdictions, Current Rates table
- Rates table shows dollar amounts (not all N/A) for NJ, NY, OH, IL, SC

- [ ] **Step 4: Run full test suite to confirm no regressions**

```
pytest tests/ -v
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```
git add tools/create_notion_docs.py
git commit -m "feat(tools): add create_notion_docs standalone script"
```

---

## Final: Build and deploy

- [ ] **Build the EXE**

```
python build.py patch
```

- [ ] **Verify EXE size is under 50 MB**

`build.py` prints the size. Investigate if it jumped more than 5 MB (fee_schedule.py adds no new dependencies so size increase should be near zero).

- [ ] **Smoke test on server**

Copy `deploy/dme-auto.exe` to the server workstation and run. Confirm fee schedule loads at startup before DMEworks connects.
