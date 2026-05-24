import pytest


def test_mbi_regex_accepts_valid_format():
    from utils.validate import MBI_RE
    assert MBI_RE.match("1AA0AA0AA11")
    assert MBI_RE.match("9YY9YY9YY99")
    assert MBI_RE.match("1EG4TE5MK72")


def test_mbi_regex_rejects_starts_with_zero():
    from utils.validate import MBI_RE
    assert not MBI_RE.match("0AA0AA0AA11")


def test_mbi_regex_rejects_excluded_letters():
    from utils.validate import MBI_RE
    assert not MBI_RE.match("1BA0AA0AA11")
    assert not MBI_RE.match("1IA0AA0AA11")


def test_mbi_regex_rejects_wrong_length():
    from utils.validate import MBI_RE
    assert not MBI_RE.match("1AA0AA0AA1")
    assert not MBI_RE.match("1AA0AA0AA111")


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
    sec = {"ins_company": "Aetna", "policy": "XYZ"}
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
