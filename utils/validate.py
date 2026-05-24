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
    """Return list of error strings. Empty list = valid."""
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
