"""
DMEworks Ingest TEST — full pipeline verification against c02.

Pulls test doctor and patient from Notion by known NPI/MBI, inserts into c02,
and verifies field-level accuracy.

Usage:
  python ingest_test.py          # dry-run: validates and shows what would happen
  python ingest_test.py --live   # inserts test records into c02, then verifies
"""

import argparse
import os
import sys

_ROOT = os.path.dirname(os.path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

_TEST_NPI = "9999999999"
_TEST_MBI = "1AA0AA0AA11"


def fetch_test_fixtures(token: str) -> tuple[dict, dict]:
    """Fetch test doctor and patient from Notion by NPI/MBI."""
    from utils import notion
    doctor = notion.fetch_doctor_by_npi(token, _TEST_NPI)
    if not doctor:
        raise ValueError(
            f"Test doctor (NPI {_TEST_NPI}) not found in Notion Doctors DB — add it first")
    patient = notion.fetch_patient_by_mbi(token, _TEST_MBI)
    if not patient:
        raise ValueError(
            f"Test patient (MBI {_TEST_MBI}) not found in Notion Patients DB — add it first")
    return doctor, patient


def run() -> None:
    p = argparse.ArgumentParser(description="DMEworks ingest test — c02 only")
    p.add_argument("--live", action="store_true", help="Write test data to c02")
    args = p.parse_args()
    dry_run = not args.live

    from utils import db, validate, notion
    from utils.creds import get_notion_token
    from utils.logger import get_logger, mask_mbi

    log = get_logger("ingest_test")
    log.info("=" * 60)
    log.info("DMEworks Ingest TEST — c02 (TEST DATABASE ONLY)")
    log.info("Mode: %s", "DRY-RUN" if dry_run else "LIVE WRITES -> c02")
    log.info("=" * 60)

    try:
        token = get_notion_token()
        insurance_map = notion.fetch_insurance_map(token)
    except Exception as e:
        log.error("Failed to fetch data from Notion: %s", e)
        sys.exit(1)

    if "NJ" not in insurance_map:
        log.error("NJ not in insurance map — check Notion Insurance DB has an active NJ entry")
        sys.exit(1)

    log.info("Fetching test fixtures from Notion...")
    try:
        _TEST_DOCTOR, _TEST_PATIENT = fetch_test_fixtures(token)
    except ValueError as e:
        log.error("%s", e)
        sys.exit(1)
    log.info("  Doctor : NPI %s — %s %s", _TEST_DOCTOR["npi"],
             _TEST_DOCTOR["first"], _TEST_DOCTOR["last"])
    log.info("  Patient: MBI %s — %s %s", mask_mbi(_TEST_PATIENT["mbi"]),
             _TEST_PATIENT["first"], _TEST_PATIENT["last"])

    db.configure("c02")

    log.info("Validating test patient...")
    errors = validate.validate_patient(_TEST_PATIENT, insurance_map)
    if errors:
        for err in errors:
            log.error("  %s", err)
        sys.exit(1)
    log.info("  Validation: PASS")

    if not dry_run:
        bad_codes = db.validate_icd10_codes(_TEST_PATIENT["icd10"])
        if bad_codes:
            log.error("  ICD10 codes invalid or retired: %s", bad_codes)
            sys.exit(1)
        log.info("  ICD10 check: PASS")

    existing_npis = db.fetch_matching_npis([_TEST_NPI])
    existing_mbis = db.fetch_matching_mbis([_TEST_MBI])

    if _TEST_NPI in existing_npis:
        log.info("Doctor NPI %s already in c02 — SKIP", _TEST_NPI)
    else:
        log.info("Doctor NPI %s not in c02 — %s", _TEST_NPI,
                 "would INSERT" if dry_run else "inserting...")
        db.insert_doctor(_TEST_DOCTOR, dry_run=dry_run)

    if _TEST_MBI in existing_mbis:
        log.info("Patient %s already in c02 — SKIP (verifying existing record)",
                 mask_mbi(_TEST_MBI))
    else:
        log.info("Patient %s not in c02 — %s", mask_mbi(_TEST_MBI),
                 "would INSERT" if dry_run else "inserting...")
        try:
            db.insert_patient(_TEST_PATIENT, insurance_map, dry_run=dry_run)
        except Exception as e:
            log.error("Insert failed: %s", e)
            sys.exit(1)

    if dry_run:
        log.info("")
        log.info("DRY-RUN complete — no changes made to c02.")
        log.info("Run with --live to execute real writes and verify.")
        return

    log.info("")
    log.info("Verifying inserted data...")

    doc_row = db.verify_doctor(_TEST_NPI)
    if not doc_row:
        log.error("FAIL: doctor NPI %s not found in tbl_doctor after insert", _TEST_NPI)
        sys.exit(1)

    doc_issues: list[str] = []
    for db_col, src_key, ci in [
        ("FirstName",  "first",    True),
        ("LastName",   "last",     True),
        ("MiddleName", "mi",       True),
        ("Suffix",     "suffix",   False),
        ("Courtesy",   "courtesy", False),
        ("NPI",        "npi",      False),
        ("Address1",   "address1", True),
        ("Address2",   "address2", True),
        ("City",       "city",     True),
        ("State",      "state",    False),
        ("Zip",        "zip",      False),
        ("Phone",      "phone",    False),
        ("Fax",        "fax",      False),
    ]:
        got  = (doc_row.get(db_col) or "").strip()
        want = (_TEST_DOCTOR.get(src_key) or "")
        match = got.lower() == want.lower() if ci else got == want
        if not match:
            doc_issues.append(f"{db_col}: expected '{want}', got '{got}'")

    if doc_issues:
        log.error("Doctor FAIL — field mismatches:")
        for iss in doc_issues:
            log.error("  %s", iss)
        sys.exit(1)
    log.info("  Doctor verified: NPI=%s %s %s", _TEST_NPI,
             _TEST_DOCTOR["first"], _TEST_DOCTOR["last"])

    rows = db.verify_patients([_TEST_PATIENT])
    row  = rows.get(_TEST_MBI)
    if not row:
        log.error("FAIL: patient %s not found in c02 after insert", mask_mbi(_TEST_MBI))
        sys.exit(1)

    issues: list[str] = []
    for row_key, src_key, ci in [
        ("first",    "first",    True),
        ("last",     "last",     True),
        ("mi",       "mi",       True),
        ("suffix",   "suffix",   False),
        ("address1", "address1", True),
        ("address2", "address2", True),
        ("city",     "city",     True),
        ("state",    "state",    False),
        ("zip",      "zip",      False),
        ("phone",    "phone",    False),
        ("gender",   "gender",   False),
    ]:
        got  = (row.get(row_key) or "").strip()
        want = (_TEST_PATIENT.get(src_key) or "")
        match = got.lower() == want.lower() if ci else got == want
        if not match:
            issues.append(f"{row_key}: expected '{want}', got '{got}'")

    for metric in ("height", "weight"):
        got_val  = row.get(metric)
        want_val = float(_TEST_PATIENT[metric]) if _TEST_PATIENT.get(metric) else None
        if got_val != want_val:
            issues.append(f"{metric}: expected '{want_val}', got '{got_val}'")

    expected_npi = (_TEST_PATIENT.get("_doctor") or {}).get("npi")
    actual_npi   = (row.get("doctor_npi") or "").strip()
    if expected_npi and actual_npi != expected_npi:
        issues.append(f"Doctor NPI DB='{actual_npi}' expected='{expected_npi}'")
    elif not actual_npi:
        issues.append("Doctor1_ID not assigned (doctor_npi is NULL)")

    dob_db  = row.get("dob")
    dob_str = dob_db.strftime("%m/%d/%Y") if hasattr(dob_db, "strftime") else str(dob_db)
    if dob_str != _TEST_PATIENT["dob"]:
        issues.append(f"dob: expected '{_TEST_PATIENT['dob']}', got '{dob_str}'")

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

    customer_id = row.get("customer_id")
    if _TEST_PATIENT.get("notes") and customer_id:
        notes_rows  = db.verify_patient_notes(customer_id)
        notes_texts = [r["Notes"] for r in notes_rows]
        if _TEST_PATIENT["notes"] not in notes_texts:
            log.error("FAIL: expected note text not found. got: %s", notes_texts)
            sys.exit(1)
        log.info("  Notes verified: %d row(s) in tbl_customer_notes", len(notes_rows))

    log.info("")
    log.info("RESULT: ALL CHECKS PASSED")
    log.info("Test patient verified in c02. NPI=%s MBI=%s", _TEST_NPI, mask_mbi(_TEST_MBI))


if __name__ == "__main__":
    run()
