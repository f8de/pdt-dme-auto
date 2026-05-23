"""
Verify DMEworks MySQL records against all Notion databases (ground truth).
Covers: Patients, Doctors, Insurance Companies.
Shows field-level diffs, prompts confirmation, applies corrections.

Failsafes:
  --dry-run     Show what would change; make no writes.
  Ambiguous match detection: skip record if name/DOB matches multiple rows.
  Full transaction: all corrections commit together or rollback on any error.
  Row-count assertion: warns if UPDATE affected 0 rows.

Usage:
    python tools/verify_dmeworks.py --client <CLIENT_CODE> [--dry-run]
    NOTION_TOKEN must be set in the environment.
"""
import argparse
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime

import mysql.connector

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from utils.creds import get_notion_token
from utils.logger import get_logger, mask_mbi, mask_dob
from utils.notion import (
    fetch_all_doctors,
    fetch_all_insurance,
    fetch_db_config,
    fetch_entered_patients,
)

log = get_logger("verify")

# ── normalizers ────────────────────────────────────────────────────────────────

def _norm(v) -> str:
    return (str(v) if v is not None else "").strip()

def _norm_phone(p) -> str:
    return re.sub(r"\D", "", _norm(p))

def _notion_dob_to_sql(dob_mdy: str) -> str:
    if not dob_mdy:
        return ""
    try:
        return datetime.strptime(dob_mdy, "%m/%d/%Y").strftime("%Y-%m-%d")
    except ValueError:
        return dob_mdy

def _sql_date_to_notion(d) -> str:
    if not d:
        return ""
    return d.strftime("%m/%d/%Y") if hasattr(d, "strftime") else _norm(d)


# ── display ────────────────────────────────────────────────────────────────────

def _print_section(title: str) -> None:
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}")

def _print_diff(label: str, diffs: list[tuple]) -> None:
    print(f"\n  {label}")
    print(f"  {'Field':<14}  {'Notion (correct)':<32}  DMEworks (stored)")
    print(f"  {'-'*14}  {'-'*32}  {'-'*32}")
    for field, n_val, m_val in diffs:
        print(f"  {field:<14}  {n_val:<32}  {m_val}")


# ── diff helpers ───────────────────────────────────────────────────────────────

def _diff(fields: list[tuple], notion: dict, row: dict) -> list[tuple]:
    diffs = []
    for label, nk, sk, norm in fields:
        n_raw = notion.get(nk, "")
        m_raw = row.get(sk, "")
        if norm(n_raw) != norm(m_raw):
            diffs.append((label, _norm(n_raw), _norm(m_raw)))
    return diffs


# ── PATIENTS ───────────────────────────────────────────────────────────────────

_PATIENT_FIELDS = [
    ("First Name",  "first",    "FirstName",   _norm),
    ("Last Name",   "last",     "LastName",    _norm),
    ("MI",          "mi",       "MiddleName",  _norm),
    ("Suffix",      "suffix",   "Suffix",      _norm),
    ("Address 1",   "address1", "Address1",    _norm),
    ("Address 2",   "address2", "Address2",    _norm),
    ("City",        "city",     "City",        _norm),
    ("State",       "state",    "State",       _norm),
    ("ZIP",         "zip",      "Zip",         _norm),
    ("Phone",       "phone",    "Phone",       _norm_phone),
]

_FETCH_PATIENT = """
    SELECT
        c.ID,
        c.FirstName, c.LastName, c.MiddleName, c.Suffix,
        c.DateofBirth,
        c.Address1, c.Address2, c.City, c.State, c.Zip, c.Phone,
        ci.PolicyNumber AS MBI
    FROM tbl_customer c
    LEFT JOIN tbl_customer_insurance ci
        ON ci.CustomerID = c.ID AND ci.Rank = 1 AND ci.InactiveDate IS NULL
    WHERE c.FirstName = %s AND c.LastName = %s AND c.DateofBirth = %s
    LIMIT 2
"""

_FETCH_PATIENT_BY_NAME = """
    SELECT
        c.ID, c.FirstName, c.LastName, c.MiddleName, c.Suffix,
        c.DateofBirth, c.Address1, c.Address2, c.City, c.State, c.Zip, c.Phone
    FROM tbl_customer c
    WHERE c.FirstName = %s AND c.LastName = %s
    LIMIT 2
"""

def _verify_patients(cur, patients: list[dict]) -> list[tuple]:
    results = []
    for p in patients:
        name = f"{p['first']} {p['last']}"
        dob_sql = _notion_dob_to_sql(p["dob"])

        cur.execute(_FETCH_PATIENT, (p["first"], p["last"], dob_sql))
        rows = cur.fetchall()

        if len(rows) > 1:
            msg = f"SKIP patient {name} — ambiguous: {len(rows)} records match in DMEworks"
            print(f"  {msg}")
            log.warning(msg)
            continue

        if not rows:
            cur.execute(_FETCH_PATIENT_BY_NAME, (p["first"], p["last"]))
            rows = cur.fetchall()
            if len(rows) > 1:
                msg = f"SKIP patient {name} — ambiguous: {len(rows)} name matches, DOB mismatch"
                print(f"  {msg}")
                log.warning(msg)
                continue
            if not rows:
                msg = f"patient {name} — not found in DMEworks"
                print(f"  WARNING: {msg}")
                log.warning(msg)
                continue
            row = rows[0]
            cur.execute(
                "SELECT PolicyNumber FROM tbl_customer_insurance "
                "WHERE CustomerID=%s AND Rank=1 AND InactiveDate IS NULL LIMIT 1",
                (row["ID"],),
            )
            mbi_row = cur.fetchone()
            row["MBI"] = mbi_row["PolicyNumber"] if mbi_row else ""
        else:
            row = rows[0]

        diffs = _diff(_PATIENT_FIELDS, p, row)

        # DOB
        m_dob = row["DateofBirth"].strftime("%Y-%m-%d") if row["DateofBirth"] else ""
        if dob_sql != m_dob:
            diffs.append(("DOB", p["dob"], _sql_date_to_notion(row["DateofBirth"])))

        # MBI
        if _norm(p["mbi"]) != _norm(row.get("MBI", "")):
            diffs.append(("MBI", _norm(p["mbi"]), _norm(row.get("MBI", ""))))

        if diffs:
            log.info("patient %s (ID=%s) — %d field(s) differ: %s",
                     name, row["ID"], len(diffs), [f for f, _, _ in diffs])
            results.append(("patient", p, row, diffs))
        else:
            print(f"  {name} — OK")
            log.debug("patient %s (ID=%s) — OK", name, row["ID"])
    return results


# ── DOCTORS ────────────────────────────────────────────────────────────────────

_DOCTOR_FIELDS = [
    ("First Name",  "first",    "FirstName",  _norm),
    ("Last Name",   "last",     "LastName",   _norm),
    ("NPI",         "npi",      "NPI",        _norm),
    ("Address 1",   "address1", "Address1",   _norm),
    ("Address 2",   "address2", "Address2",   _norm),
    ("City",        "city",     "City",       _norm),
    ("State",       "state",    "State",      _norm),
    ("ZIP",         "zip",      "Zip",        _norm),
    ("Phone",       "phone",    "Phone",      _norm_phone),
]

_FETCH_DOCTOR_BY_NPI = """
    SELECT ID, FirstName, LastName, NPI, Address1, Address2, City, State, Zip, Phone
    FROM tbl_doctor WHERE NPI = %s LIMIT 2
"""
_FETCH_DOCTOR_BY_NAME = """
    SELECT ID, FirstName, LastName, NPI, Address1, Address2, City, State, Zip, Phone
    FROM tbl_doctor WHERE FirstName = %s AND LastName = %s LIMIT 2
"""

def _verify_doctors(cur, doctors: list[dict]) -> list[tuple]:
    results = []
    for d in doctors:
        name = f"Dr. {d['first']} {d['last']}"
        rows = []

        if d["npi"]:
            cur.execute(_FETCH_DOCTOR_BY_NPI, (d["npi"],))
            rows = cur.fetchall()

        if not rows:
            cur.execute(_FETCH_DOCTOR_BY_NAME, (d["first"], d["last"]))
            rows = cur.fetchall()

        if len(rows) > 1:
            msg = f"SKIP doctor {name} — ambiguous: {len(rows)} records match in DMEworks"
            print(f"  {msg}")
            log.warning(msg)
            continue
        if not rows:
            msg = f"doctor {name} — not found in DMEworks"
            print(f"  WARNING: {msg}")
            log.warning(msg)
            continue

        row   = rows[0]
        diffs = _diff(_DOCTOR_FIELDS, d, row)
        if diffs:
            log.info("doctor %s (ID=%s) — %d field(s) differ: %s",
                     name, row["ID"], len(diffs), [f for f, _, _ in diffs])
            results.append(("doctor", d, row, diffs))
        else:
            print(f"  {name} — OK")
            log.debug("doctor %s (ID=%s) — OK", name, row["ID"])
    return results


# ── INSURANCE COMPANIES ────────────────────────────────────────────────────────

_FETCH_INSURANCE_BY_NAME = """
    SELECT ID, Name FROM tbl_insurancecompany WHERE Name = %s LIMIT 1
"""

def _verify_insurance(cur, companies: list[dict]) -> list[tuple]:
    results = []
    for c in companies:
        cur.execute(_FETCH_INSURANCE_BY_NAME, (c["name"],))
        row = cur.fetchone()
        if row is None:
            log.warning("insurance '%s' — not found in DMEworks (manual action required)", c["name"])
            results.append(("insurance", c, None, [("Name", c["name"], "(not found in DMEworks)")]))
        else:
            print(f"  {c['name']} — OK")
            log.debug("insurance '%s' — OK", c["name"])
    return results


# ── APPLY CORRECTIONS ──────────────────────────────────────────────────────────

_UPDATE_CUSTOMER = """
    UPDATE tbl_customer
    SET FirstName=%s, LastName=%s, MiddleName=%s, Suffix=%s, DateofBirth=%s,
        Address1=%s, Address2=%s, City=%s, State=%s, Zip=%s, Phone=%s
    WHERE ID=%s
"""
_UPDATE_MBI = """
    UPDATE tbl_customer_insurance SET PolicyNumber=%s
    WHERE CustomerID=%s AND Rank=1 AND InactiveDate IS NULL
"""
_UPDATE_DOCTOR = """
    UPDATE tbl_doctor
    SET FirstName=%s, LastName=%s, NPI=%s,
        Address1=%s, Address2=%s, City=%s, State=%s, Zip=%s, Phone=%s
    WHERE ID=%s
"""

def _apply(cur, all_diffs: list[tuple], dry_run: bool) -> int:
    count = 0
    for kind, notion, row, diffs in all_diffs:
        if kind == "patient":
            p = notion
            if not dry_run:
                cur.execute(_UPDATE_CUSTOMER, (
                    p["first"], p["last"], p["mi"], p["suffix"],
                    _notion_dob_to_sql(p["dob"]) or None,
                    p["address1"], p["address2"], p["city"], p["state"], p["zip"], p["phone"],
                    row["ID"],
                ))
                if cur.rowcount == 0:
                    msg = f"UPDATE matched 0 rows for patient ID={row['ID']}"
                    print(f"  WARNING: {msg}")
                    log.warning(msg)
                if any(f == "MBI" for f, _, _ in diffs):
                    cur.execute(_UPDATE_MBI, (p["mbi"], row["ID"]))
                    if cur.rowcount == 0:
                        msg = f"MBI UPDATE matched 0 rows for CustomerID={row['ID']}"
                        print(f"  WARNING: {msg}")
                        log.warning(msg)
                log.info("updated patient %s %s (ID=%s) fields: %s",
                         p["first"], p["last"], row["ID"], [f for f, _, _ in diffs])
            else:
                log.info("[DRY RUN] would update patient %s %s (ID=%s) fields: %s",
                         p["first"], p["last"], row["ID"], [f for f, _, _ in diffs])
            tag = "[DRY RUN] would update" if dry_run else "Updated"
            print(f"  {tag} patient: {p['first']} {p['last']} (ID={row['ID']})")
            count += 1

        elif kind == "doctor":
            d = notion
            if not dry_run:
                cur.execute(_UPDATE_DOCTOR, (
                    d["first"], d["last"], d["npi"],
                    d["address1"], d["address2"], d["city"], d["state"], d["zip"], d["phone"],
                    row["ID"],
                ))
                if cur.rowcount == 0:
                    msg = f"UPDATE matched 0 rows for doctor ID={row['ID']}"
                    print(f"  WARNING: {msg}")
                    log.warning(msg)
                log.info("updated doctor %s %s (ID=%s) fields: %s",
                         d["first"], d["last"], row["ID"], [f for f, _, _ in diffs])
            else:
                log.info("[DRY RUN] would update doctor %s %s (ID=%s) fields: %s",
                         d["first"], d["last"], row["ID"], [f for f, _, _ in diffs])
            tag = "[DRY RUN] would update" if dry_run else "Updated"
            print(f"  {tag} doctor: {d['first']} {d['last']} (ID={row['ID']})")
            count += 1

        elif kind == "insurance":
            msg = f"SKIP insurance '{notion['name']}' — manual action required in DMEworks"
            print(f"  {msg}")
            log.warning(msg)

    return count


# ── main ───────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Verify all Notion DBs against DMEworks")
    parser.add_argument("--client",  required=True, help="Client code (e.g. c02)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show diffs without writing anything to DMEworks")
    args = parser.parse_args()

    try:
        token = get_notion_token()
    except RuntimeError as exc:
        log.error("Failed to get Notion token: %s", exc)
        sys.exit(str(exc))

    log.info("verify start — client=%s dry_run=%s", args.client, args.dry_run)

    if args.dry_run:
        print("  [DRY RUN — no changes will be written]")

    # Fetch all three Notion DBs in parallel
    print("\nFetching Notion data...")
    with ThreadPoolExecutor(max_workers=3) as pool:
        f_patients  = pool.submit(fetch_entered_patients, token)
        f_doctors   = pool.submit(fetch_all_doctors,      token)
        f_insurance = pool.submit(fetch_all_insurance,    token)
        patients    = f_patients.result()
        doctors     = f_doctors.result()
        insurance   = f_insurance.result()

    print(f"  {len(patients)} patient(s), {len(doctors)} doctor(s), {len(insurance)} insurance company(ies)")
    log.info("fetched from Notion: %d patients, %d doctors, %d insurance companies",
             len(patients), len(doctors), len(insurance))

    print("\nConnecting to DMEworks DB...")
    cfg  = fetch_db_config(token, args.client)
    conn = mysql.connector.connect(**cfg)
    cur  = conn.cursor(dictionary=True)

    all_diffs: list[tuple] = []

    _print_section("PATIENTS")
    all_diffs += _verify_patients(cur, patients)

    _print_section("DOCTORS")
    all_diffs += _verify_doctors(cur, doctors)

    _print_section("INSURANCE COMPANIES")
    all_diffs += _verify_insurance(cur, insurance)

    if not all_diffs:
        print("\n\nAll records match. No corrections needed.")
        log.info("verify complete — all records match, no corrections needed")
        cur.close()
        conn.close()
        return

    # Summary report
    _print_section(f"DISCREPANCIES — {len(all_diffs)} record(s) need correction")
    for kind, notion, row, diffs in all_diffs:
        if kind == "patient":
            label = f"Patient: {notion['first']} {notion['last']}"
        elif kind == "doctor":
            label = f"Doctor: {notion['first']} {notion['last']}"
        else:
            label = f"Insurance: {notion['name']}"
        _print_diff(label, diffs)

    print(f"\n{'='*70}")

    if args.dry_run:
        print("  Dry run complete. Re-run without --dry-run to apply corrections.")
        log.info("dry run complete — %d discrepancy(ies) found, no changes written", len(all_diffs))
        cur.close()
        conn.close()
        return

    answer = input("Apply corrections to DMEworks? [y/N]: ").strip().lower()
    if answer != "y":
        print("Aborted. No changes made.")
        log.info("user aborted — no changes made")
        cur.close()
        conn.close()
        return

    # Apply all corrections in a single transaction — rollback on any error
    try:
        count = _apply(cur, all_diffs, dry_run=False)
        conn.commit()
        print(f"\nDone. {count} record(s) corrected.")
        log.info("verify complete — %d record(s) corrected and committed", count)
    except Exception as exc:
        conn.rollback()
        print(f"\nERROR: {exc}")
        print("Transaction rolled back — no changes were written.")
        log.error("transaction rolled back due to error: %s", exc, exc_info=True)
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    main()
