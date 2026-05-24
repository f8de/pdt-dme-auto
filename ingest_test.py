"""
DMEworks Ingest TEST — full pipeline verification against c01 (test database only).

Inserts a synthetic test patient into c01, verifies field-level accuracy, and reports PASS/FAIL.
All writes go to c01 ONLY — production (c02) is never touched.

Usage:
  python ingest_test.py          # dry-run: validates and shows what would happen
  python ingest_test.py --live   # inserts test patient into c01, then verifies
"""

import argparse
import os
import sys

_ROOT = os.path.dirname(os.path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

_TEST_NPI = "9999999999"
_TEST_MBI = "1AA0AA0AA11"

_TEST_DOCTOR = {
    "first": "Test", "last": "Doctor", "mi": "T", "suffix": "", "courtesy": "Dr.",
    "npi": _TEST_NPI, "fax": "", "address1": "1 Test Ave", "address2": "",
    "city": "Trenton", "state": "NJ", "zip": "08610", "phone": "",
}

_TEST_PATIENT = {
    "first": "Test", "last": "Patient", "mi": "T", "suffix": "",
    "dob": "01/01/1980", "mbi": _TEST_MBI,
    "address1": "1 Test Ave", "address2": "", "city": "Trenton",
    "state": "NJ", "zip": "08610", "phone": "",
    "gender": "Male", "height": "70", "weight": "160",
    "icd10": ["M54.5"],
    "secondary": None,
    "_doctor": {"npi": _TEST_NPI},
    "_notion_page_id": None,
}


def run() -> None:
    p = argparse.ArgumentParser(description="DMEworks ingest test — c01 only")
    p.add_argument("--live", action="store_true", help="Write test data to c01")
    args = p.parse_args()
    dry_run = not args.live

    from utils import db, validate, notion
    from utils.creds import get_notion_token
    from utils.logger import get_logger, mask_mbi

    log = get_logger("ingest_test")
    log.info("=" * 60)
    log.info("DMEworks Ingest TEST — c01 (TEST DATABASE ONLY)")
    log.info("Mode: %s", "DRY-RUN" if dry_run else "LIVE WRITES → c01")
    log.info("Production (c02) is NOT touched.")
    log.info("=" * 60)

    # Fetch insurance map (needed for state → company lookup)
    try:
        token = get_notion_token()
        insurance_map = notion.fetch_insurance_map(token)
    except Exception as e:
        log.error("Failed to fetch insurance map from Notion: %s", e)
        sys.exit(1)

    if "NJ" not in insurance_map:
        log.error("NJ not in insurance map — check Notion Insurance DB has an active NJ entry")
        sys.exit(1)

    db.configure("c01")

    # Validate test patient data
    log.info("Validating test patient...")
    errors = validate.validate_patient(_TEST_PATIENT, insurance_map)
    if errors:
        for err in errors:
            log.error("  %s", err)
        sys.exit(1)
    log.info("  Validation: PASS")

    # ICD10 check (live only — requires DB)
    if not dry_run:
        bad_codes = db.validate_icd10_codes(_TEST_PATIENT["icd10"])
        if bad_codes:
            log.error("  ICD10 codes invalid or retired: %s", bad_codes)
            sys.exit(1)
        log.info("  ICD10 check: PASS")

    # Existence checks
    existing_npis = db.fetch_matching_npis([_TEST_NPI])
    existing_mbis = db.fetch_matching_mbis([_TEST_MBI])

    # Doctor
    if _TEST_NPI in existing_npis:
        log.info("Doctor NPI %s already in c01 — SKIP", _TEST_NPI)
    else:
        log.info("Doctor NPI %s not in c01 — %s", _TEST_NPI, "would INSERT" if dry_run else "inserting...")
        db.insert_doctor(_TEST_DOCTOR, dry_run=dry_run)

    # Patient
    if _TEST_MBI in existing_mbis:
        log.info("Patient %s already in c01 — SKIP (verifying existing record)", mask_mbi(_TEST_MBI))
    else:
        log.info("Patient %s not in c01 — %s", mask_mbi(_TEST_MBI), "would INSERT" if dry_run else "inserting...")
        try:
            db.insert_patient(_TEST_PATIENT, insurance_map, dry_run=dry_run)
        except Exception as e:
            log.error("Insert failed: %s", e)
            sys.exit(1)

    if dry_run:
        log.info("")
        log.info("DRY-RUN complete — no changes made to c01.")
        log.info("Run with --live to execute real writes and verify.")
        return

    # Field-level verification
    log.info("")
    log.info("Verifying inserted data...")
    rows = db.verify_patients([_TEST_PATIENT])
    row = rows.get(_TEST_MBI)
    if not row:
        log.error("FAIL: patient %s not found in c01 after insert", mask_mbi(_TEST_MBI))
        sys.exit(1)

    issues: list[str] = []
    if row["first"].strip().lower() != _TEST_PATIENT["first"].lower():
        issues.append(f"FirstName: expected '{_TEST_PATIENT['first']}', got '{row['first']}'")
    if row["last"].strip().lower() != _TEST_PATIENT["last"].lower():
        issues.append(f"LastName: expected '{_TEST_PATIENT['last']}', got '{row['last']}'")
    if (row.get("gender") or "").strip() != _TEST_PATIENT["gender"]:
        issues.append(f"Gender: expected '{_TEST_PATIENT['gender']}', got '{row.get('gender')}'")
    if not row.get("doctor_npi"):
        issues.append("Doctor1_ID not assigned (doctor_npi is NULL)")

    dob_db = row.get("dob")
    dob_str = dob_db.strftime("%m/%d/%Y") if hasattr(dob_db, "strftime") else str(dob_db)
    if dob_str != _TEST_PATIENT["dob"]:
        issues.append(f"DOB: expected '{_TEST_PATIENT['dob']}', got '{dob_str}'")

    db_codes = {row.get(f"icd10_{i:02d}") for i in range(1, 13) if row.get(f"icd10_{i:02d}")}
    for code in _TEST_PATIENT["icd10"]:
        if code not in db_codes:
            issues.append(f"ICD10 '{code}' missing in DB row")

    if issues:
        log.error("")
        log.error("FAIL — field mismatches found:")
        for iss in issues:
            log.error("  %s", iss)
        sys.exit(1)

    log.info("")
    log.info("RESULT: ALL CHECKS PASSED")
    log.info("Test patient verified in c01. NPI=%s MBI=%s", _TEST_NPI, mask_mbi(_TEST_MBI))


if __name__ == "__main__":
    run()
