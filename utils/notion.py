import json
import time
from datetime import datetime

import requests

_BASE               = "https://api.notion.com/v1"
_PATIENT_DB_ID      = "9c83bd769bb9424bac74d4760a1450f4"
_INSURANCE_DB_ID    = "b2844e66f56443b7a9cf5a9d08d5d93c"
_DOCTORS_DB_ID      = "8cfb6a87328d463fb3d24b811d0c6c16"
_NOTION_VERSION     = "2022-06-28"

_doctor_cache: dict[str, dict] = {}


def _headers(token: str) -> dict:
    return {
        "Authorization": f"Bearer {token}",
        "Notion-Version": _NOTION_VERSION,
        "Content-Type": "application/json",
    }


def _request(method: str, url: str, headers: dict, **kwargs) -> requests.Response:
    """Notion API call with retry on 429 / 5xx (max 3 attempts, exponential backoff)."""
    for attempt in range(3):
        resp = getattr(requests, method)(url, headers=headers, timeout=30, **kwargs)
        if resp.status_code == 429:
            wait = int(resp.headers.get("Retry-After", 2 ** attempt))
            time.sleep(wait)
            continue
        if resp.status_code >= 500 and attempt < 2:
            time.sleep(2 ** attempt)
            continue
        resp.raise_for_status()
        return resp
    resp.raise_for_status()
    return resp


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
        data = _request("post", url, _headers(token), json=payload).json()
        for page in data["results"]:
            p = _parse_patient(token, page)
            if p:
                patients.append(p)
        if not data.get("has_more"):
            break
        payload["start_cursor"] = data["next_cursor"]
    return patients



def fetch_patients_by_statuses(token: str, statuses: list[str] | None = None) -> list[dict]:
    """Return patients filtered by status list. Pass None to fetch all patients."""
    url = f"{_BASE}/databases/{_PATIENT_DB_ID}/query"
    if statuses is None:
        payload: dict = {}
    elif len(statuses) == 1:
        payload = {"filter": {"property": "Status", "select": {"equals": statuses[0]}}}
    else:
        payload = {
            "filter": {
                "or": [
                    {"property": "Status", "select": {"equals": s}}
                    for s in statuses
                ]
            }
        }
    patients: list[dict] = []
    while True:
        data = _request("post", url, _headers(token), json=payload).json()
        for page in data["results"]:
            p = _parse_patient(token, page)
            if p:
                patients.append(p)
        if not data.get("has_more"):
            break
        payload["start_cursor"] = data["next_cursor"]
    return patients


def fetch_all_doctors(token: str) -> list[dict]:
    """Return all doctor records from the Doctors DB."""
    url     = f"{_BASE}/databases/{_DOCTORS_DB_ID}/query"
    payload: dict = {}
    doctors: list[dict] = []
    while True:
        data = _request("post", url, _headers(token), json=payload).json()
        for page in data["results"]:
            d = _parse_doctor_page(page)
            if d:
                doctors.append(d)
        if not data.get("has_more"):
            break
        payload["start_cursor"] = data["next_cursor"]
    return doctors


def fetch_all_insurance(token: str) -> list[dict]:
    """Return all insurance company records from the Insurance DB."""
    url     = f"{_BASE}/databases/{_INSURANCE_DB_ID}/query"
    payload: dict = {}
    companies: list[dict] = []
    while True:
        data = _request("post", url, _headers(token), json=payload).json()
        for page in data["results"]:
            props = page["properties"]
            title_items = props.get("Name", {}).get("title", [])
            name = title_items[0]["plain_text"].strip() if title_items else ""
            if name:
                companies.append({"name": name})
        if not data.get("has_more"):
            break
        payload["start_cursor"] = data["next_cursor"]
    return companies


def fetch_insurance_map(token: str) -> dict[str, str]:
    """Return {state: company_name} for all active insurance companies."""
    url     = f"{_BASE}/databases/{_INSURANCE_DB_ID}/query"
    payload = {"filter": {"property": "Active", "checkbox": {"equals": True}}}
    state_map: dict[str, str] = {}
    while True:
        data = _request("post", url, _headers(token), json=payload).json()
        for page in data["results"]:
            props = page["properties"]
            title_items = props.get("Name", {}).get("title", [])
            name        = title_items[0]["plain_text"].strip() if title_items else ""
            rt_items    = props.get("States", {}).get("rich_text", [])
            states_raw  = rt_items[0]["plain_text"] if rt_items else ""
            for state in states_raw.split(","):
                state = state.strip()
                if state and name:
                    state_map[state] = name
        if not data.get("has_more"):
            break
        payload["start_cursor"] = data["next_cursor"]
    return state_map



def mark_in_dmeworks(token: str, page_id: str) -> None:
    """Set patient Status = 'In DMEworks' in Notion."""
    url     = f"{_BASE}/pages/{page_id}"
    payload = {"properties": {"Status": {"select": {"name": "In DMEworks"}}}}
    _request("patch", url, _headers(token), json=payload)


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

    # Resolve linked doctor (cached by page_id)
    rel = props.get("Doctor", {}).get("relation", [])
    doc = {}
    if rel:
        try:
            doc = _fetch_doctor(token, rel[0]["id"])
        except Exception:
            pass  # Missing NPI will be caught by validate_csv
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
        except json.JSONDecodeError:
            secondary = None

    return {
        "first":    first,
        "last":     last,
        "mi":       rt("MI"),
        "suffix":   rt("Suffix"),
        "dob":      date_to_mdy("DOB"),
        "mbi":      mbi,
        "address1": rt("Address"),
        "address2": rt("Address 2"),
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


def _parse_doctor_page(page: dict) -> dict | None:
    """Parse a Doctors DB page into a flat dict."""
    props = page["properties"]

    def rt(key: str) -> str:
        items = props.get(key, {}).get("rich_text", [])
        return items[0]["plain_text"].strip() if items else ""

    def title(key: str) -> str:
        items = props.get(key, {}).get("title", [])
        return items[0]["plain_text"].strip() if items else ""

    def phone_val(key: str) -> str:
        return (props.get(key, {}).get("phone_number") or "").strip()

    first = title("First Name") or rt("First Name")
    last  = rt("Last Name")
    if not first or not last:
        return None

    return {
        "first":    first,
        "last":     last,
        "npi":      rt("NPI"),
        "address1": rt("Address"),
        "address2": rt("Address 2"),
        "city":     rt("City"),
        "state":    rt("State"),
        "zip":      rt("ZIP"),
        "phone":    phone_val("Phone"),
        "_notion_page_id": page["id"],
    }


def _fetch_doctor(token: str, page_id: str) -> dict:
    if page_id in _doctor_cache:
        return _doctor_cache[page_id]

    url   = f"{_BASE}/pages/{page_id}"
    props = _request("get", url, _headers(token)).json()["properties"]

    def rt(key: str) -> str:
        items = props.get(key, {}).get("rich_text", [])
        return items[0]["plain_text"].strip() if items else ""

    def phone(key: str) -> str:
        return (props.get(key, {}).get("phone_number") or "").strip()

    result = {
        "first":    rt("First Name"),
        "last":     rt("Last Name"),
        "mi":       "",
        "suffix":   "",
        "npi":      rt("NPI"),
        "address1": rt("Address"),
        "address2": rt("Address 2"),
        "city":     rt("City"),
        "state":    rt("State"),
        "zip":      rt("ZIP"),
        "phone":    phone("Phone"),
    }
    _doctor_cache[page_id] = result
    return result
