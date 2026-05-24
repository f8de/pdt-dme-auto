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

    seen_ins: set[str]        = set()
    ins_companies: list[dict] = []
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
        dob_db  = row["dob"]
        dob_str = dob_db.strftime("%m/%d/%Y") if hasattr(dob_db, "strftime") else str(dob_db)
        if dob_str != p["dob"]:
            issues.append("DOB mismatch")
        if (row.get("state") or "").strip().upper() != p["state"].upper():
            issues.append("State mismatch")
        if not row.get("doctor_npi"):
            issues.append("no doctor assigned (Doctor1_ID is NULL)")
        if (row.get("gender") or "").strip() != p.get("gender", ""):
            issues.append("Gender mismatch")

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
