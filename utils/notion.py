import json
from datetime import datetime

import requests

_BASE               = "https://api.notion.com/v1"
_PATIENT_DB_ID      = "9c83bd769bb9424bac74d4760a1450f4"
_CLIENTS_DB_ID      = "9051e0ddc1be47dcb727f236fa599000"
_INSURANCE_DB_ID    = "b2844e66f56443b7a9cf5a9d08d5d93c"
_NOTION_VERSION     = "2022-06-28"


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


def fetch_insurance_map(token: str) -> dict[str, str]:
    """Return {state: company_name} for all active insurance companies."""
    url     = f"{_BASE}/databases/{_INSURANCE_DB_ID}/query"
    payload = {"filter": {"property": "Active", "checkbox": {"equals": True}}}
    state_map: dict[str, str] = {}
    while True:
        resp = requests.post(url, headers=_headers(token), json=payload, timeout=30)
        resp.raise_for_status()
        data = resp.json()
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


def fetch_db_config(token: str, client_code: str) -> dict:
    """Return MySQL credentials for client_code from Notion Clients DB."""
    url     = f"{_BASE}/databases/{_CLIENTS_DB_ID}/query"
    payload = {
        "filter": {
            "and": [
                {"property": "Client Code", "title": {"equals": client_code}},
                {"property": "Active", "checkbox": {"equals": True}},
            ]
        }
    }
    resp = requests.post(url, headers=_headers(token), json=payload, timeout=30)
    resp.raise_for_status()
    results = resp.json()["results"]
    if not results:
        raise ValueError(
            f"No active client config found for '{client_code}' in Notion Clients DB.\n"
            "Add a row to the Clients database in Notion and check 'Active'."
        )
    props = results[0]["properties"]

    def rt(key: str) -> str:
        items = props.get(key, {}).get("rich_text", [])
        return items[0]["plain_text"].strip() if items else ""

    def num(key: str) -> int:
        return int(props.get(key, {}).get("number") or 3306)

    return {
        "host":     rt("DB Host"),
        "port":     num("DB Port"),
        "user":     rt("DB User"),
        "password": rt("DB Password"),
        "database": rt("DB Database"),
    }


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
        "address2": rt("Address 2"),
        "city":     rt("City"),
        "state":    rt("State"),
        "zip":      rt("ZIP"),
        "phone":    phone("Phone"),
    }
