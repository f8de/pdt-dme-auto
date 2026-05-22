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


def test_parse_patient_no_doctor_relation():
    import utils.notion as n
    # Build page with empty Doctor relation
    page = _sample_patient_page()
    page["properties"]["Doctor"] = {"relation": []}
    result = n._parse_patient("t", page)
    assert result is not None
    assert result["doctor"] == ""
    assert result["_doctor"] == {}


def test_fetch_work_queue_paginates_and_returns_all():
    import utils.notion as n

    page1 = _sample_patient_page(page_id="p1", mbi="AAA0001", first="Alice", last="Smith")
    page2 = _sample_patient_page(page_id="p2", mbi="BBB0002", first="Bob", last="Jones")

    resp1 = MagicMock()
    resp1.raise_for_status = MagicMock()
    resp1.json.return_value = {"results": [page1], "has_more": True, "next_cursor": "cursor-abc"}

    resp2 = MagicMock()
    resp2.raise_for_status = MagicMock()
    resp2.json.return_value = {"results": [page2], "has_more": False}

    doctor_stub = {"first": "J", "last": "S", "mi": "", "suffix": "", "npi": "1", "address1": "", "city": "", "state": "IL", "zip": "", "phone": ""}

    with patch("requests.post", side_effect=[resp1, resp2]) as mock_post, \
         patch("utils.notion._fetch_doctor", return_value=doctor_stub):
        result = n.fetch_work_queue("fake-token")

    assert len(result) == 2
    assert result[0]["mbi"] == "AAA0001"
    assert result[1]["mbi"] == "BBB0002"
    # Verify second call included the cursor
    second_call_payload = mock_post.call_args_list[1][1]["json"]
    assert second_call_payload["start_cursor"] == "cursor-abc"


def test_mark_in_dmeworks_calls_patch():
    import utils.notion as n
    mock_resp = MagicMock()
    mock_resp.raise_for_status = MagicMock()
    with patch("requests.patch", return_value=mock_resp) as mock_patch:
        n.mark_in_dmeworks("fake-token", "patient-page-id")
        call_kwargs = mock_patch.call_args
        payload = call_kwargs[1]["json"]
        assert payload["properties"]["Status"]["select"]["name"] == "In DMEworks"
