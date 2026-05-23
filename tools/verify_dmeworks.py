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
    fetch_patients_by_statuses,
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
    for field, _sql_col, _sql_val, n_display, m_display in diffs:
        print(f"  {field:<14}  {n_display:<32}  {m_display}")


# ── diff helpers ───────────────────────────────────────────────────────────────

def _diff(fields: list[tuple], notion: dict, row: dict) -> list[tuple]:
    # Each entry: (label, sql_col, sql_val, notion_display, db_display)
    diffs = []
    for label, nk, sk, norm in fields:
        n_raw = notion.get(nk, "")
        m_raw = row.get(sk, "")
        if norm(n_raw) != norm(m_raw):
            diffs.append((label, sk, n_raw, _norm(n_raw), _norm(m_raw)))
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

def _verify_patients(cur, patients: list[dict]) -> tuple[list[tuple], dict]:
    results = []
    stats = {"checked": 0, "ok": 0, "diffs": 0, "skipped": 0, "not_found": 0}
    for p in patients:
        stats["checked"] += 1
        name = f"{p['first']} {p['last']}"
        dob_sql = _notion_dob_to_sql(p["dob"])

        cur.execute(_FETCH_PATIENT, (p["first"], p["last"], dob_sql))
        rows = cur.fetchall()

        if len(rows) > 1:
            msg = f"SKIP patient {name} — ambiguous: {len(rows)} records match in DMEworks"
            print(f"  {msg}")
            log.warning(msg)
            stats["skipped"] += 1
            continue

        if not rows:
            cur.execute(_FETCH_PATIENT_BY_NAME, (p["first"], p["last"]))
            rows = cur.fetchall()
            if len(rows) > 1:
                msg = f"SKIP patient {name} — ambiguous: {len(rows)} name matches, DOB mismatch"
                print(f"  {msg}")
                log.warning(msg)
                stats["skipped"] += 1
                continue
            if not rows:
                msg = f"patient {name} — not found in DMEworks"
                print(f"  WARNING: {msg}")
                log.warning(msg)
                stats["not_found"] += 1
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

        # DOB — sql_val is YYYY-MM-DD for the UPDATE; display Notion value as MM/DD/YYYY
        m_dob = row["DateofBirth"].strftime("%Y-%m-%d") if row["DateofBirth"] else ""
        if dob_sql != m_dob:
            diffs.append(("DOB", "DateofBirth", dob_sql or None,
                          p["dob"], _sql_date_to_notion(row["DateofBirth"])))

        # MBI — sql_col=None signals separate table (tbl_customer_insurance)
        if _norm(p["mbi"]) != _norm(row.get("MBI", "")):
            diffs.append(("MBI", None, _norm(p["mbi"]),
                          _norm(p["mbi"]), _norm(row.get("MBI", ""))))

        if diffs:
            log.info("patient %s (ID=%s) — %d field(s) differ: %s",
                     name, row["ID"], len(diffs), [f for f, *_ in diffs])
            stats["diffs"] += 1
            results.append(("patient", p, row, diffs))
        else:
            print(f"  {name} — OK")
            log.debug("patient %s (ID=%s) — OK", name, row["ID"])
            stats["ok"] += 1
    return results, stats


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

def _verify_doctors(cur, doctors: list[dict]) -> tuple[list[tuple], dict]:
    results = []
    stats = {"checked": 0, "ok": 0, "diffs": 0, "skipped": 0, "not_found": 0}
    for d in doctors:
        stats["checked"] += 1
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
            stats["skipped"] += 1
            continue
        if not rows:
            msg = f"doctor {name} — not found in DMEworks"
            print(f"  WARNING: {msg}")
            log.warning(msg)
            stats["not_found"] += 1
            continue

        row   = rows[0]
        diffs = _diff(_DOCTOR_FIELDS, d, row)
        if diffs:
            log.info("doctor %s (ID=%s) — %d field(s) differ: %s",
                     name, row["ID"], len(diffs), [f for f, *_ in diffs])
            stats["diffs"] += 1
            results.append(("doctor", d, row, diffs))
        else:
            print(f"  {name} — OK")
            log.debug("doctor %s (ID=%s) — OK", name, row["ID"])
            stats["ok"] += 1
    return results, stats


# ── INSURANCE COMPANIES ────────────────────────────────────────────────────────

_FETCH_INSURANCE_BY_NAME = """
    SELECT ID, Name FROM tbl_insurancecompany WHERE Name = %s LIMIT 1
"""

def _verify_insurance(cur, companies: list[dict]) -> tuple[list[tuple], dict]:
    results = []
    stats = {"checked": 0, "ok": 0, "diffs": 0, "skipped": 0, "not_found": 0}
    for c in companies:
        stats["checked"] += 1
        cur.execute(_FETCH_INSURANCE_BY_NAME, (c["name"],))
        row = cur.fetchone()
        if row is None:
            log.warning("insurance '%s' — not found in DMEworks (manual action required)", c["name"])
            stats["not_found"] += 1
            results.append(("insurance", c, None, [("Name", c["name"], "(not found in DMEworks)")]))
        else:
            print(f"  {c['name']} — OK")
            log.debug("insurance '%s' — OK", c["name"])
            stats["ok"] += 1
    return results, stats


# ── APPLY CORRECTIONS ──────────────────────────────────────────────────────────

_UPDATE_MBI = """
    UPDATE tbl_customer_insurance SET PolicyNumber=%s
    WHERE CustomerID=%s AND Rank=1 AND InactiveDate IS NULL
"""


def _apply(cur, all_diffs: list[tuple], dry_run: bool) -> int:
    count = 0
    for kind, notion, row, diffs in all_diffs:
        changed_fields = [f for f, *_ in diffs]
        tag = "[DRY RUN] would update" if dry_run else "Updated"

        if kind == "patient":
            p = notion
            # Split: tbl_customer columns vs MBI (separate table, sql_col=None)
            cust_cols, cust_vals, update_mbi, new_mbi = [], [], False, None
            for _label, sql_col, sql_val, _nd, _dd in diffs:
                if sql_col is None:
                    update_mbi, new_mbi = True, sql_val
                else:
                    cust_cols.append(f"{sql_col}=%s")
                    cust_vals.append(sql_val)

            if not dry_run:
                if cust_cols:
                    sql = f"UPDATE tbl_customer SET {', '.join(cust_cols)} WHERE ID=%s"
                    cur.execute(sql, cust_vals + [row["ID"]])
                    if cur.rowcount == 0:
                        msg = f"UPDATE matched 0 rows for patient ID={row['ID']}"
                        print(f"  WARNING: {msg}")
                        log.warning(msg)
                if update_mbi:
                    cur.execute(_UPDATE_MBI, (new_mbi, row["ID"]))
                    if cur.rowcount == 0:
                        msg = f"MBI UPDATE matched 0 rows for CustomerID={row['ID']}"
                        print(f"  WARNING: {msg}")
                        log.warning(msg)
                log.info("updated patient %s %s (ID=%s) fields: %s",
                         p["first"], p["last"], row["ID"], changed_fields)
            else:
                log.info("[DRY RUN] would update patient %s %s (ID=%s) fields: %s",
                         p["first"], p["last"], row["ID"], changed_fields)
            print(f"  {tag} patient: {p['first']} {p['last']} (ID={row['ID']})")
            count += 1

        elif kind == "doctor":
            d = notion
            doc_cols = [f"{sql_col}=%s" for _, sql_col, *_ in diffs]
            doc_vals = [sql_val for _, _sc, sql_val, *_ in diffs]

            if not dry_run:
                if doc_cols:
                    sql = f"UPDATE tbl_doctor SET {', '.join(doc_cols)} WHERE ID=%s"
                    cur.execute(sql, doc_vals + [row["ID"]])
                    if cur.rowcount == 0:
                        msg = f"UPDATE matched 0 rows for doctor ID={row['ID']}"
                        print(f"  WARNING: {msg}")
                        log.warning(msg)
                log.info("updated doctor %s %s (ID=%s) fields: %s",
                         d["first"], d["last"], row["ID"], changed_fields)
            else:
                log.info("[DRY RUN] would update doctor %s %s (ID=%s) fields: %s",
                         d["first"], d["last"], row["ID"], changed_fields)
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

    # Patient scope selection
    print()
    print("  Patient scope:")
    print("  [1]  In DMEworks only      (default — already entered)")
    print("  [2]  All patients          (includes pending, errors, all statuses)")
    print("  [3]  Custom statuses       (comma-separated list)")
    print()
    try:
        scope = input("  > ").strip()
    except (KeyboardInterrupt, EOFError):
        print()
        sys.exit(0)

    if scope == "2":
        patient_fetch_statuses = None  # fetch all
        scope_label = "all patients"
    elif scope == "3":
        try:
            raw = input("  Statuses (comma-separated): ").strip()
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)
        patient_fetch_statuses = [s.strip() for s in raw.split(",") if s.strip()]
        scope_label = f"status in {patient_fetch_statuses}"
    else:
        patient_fetch_statuses = ["In DMEworks"]
        scope_label = "In DMEworks only"

    log.info("patient scope: %s", scope_label)

    # Fetch all three Notion DBs in parallel
    print("\nFetching Notion data...")
    try:
        with ThreadPoolExecutor(max_workers=3) as pool:
            f_patients  = pool.submit(fetch_patients_by_statuses, token, patient_fetch_statuses)
            f_doctors   = pool.submit(fetch_all_doctors,           token)
            f_insurance = pool.submit(fetch_all_insurance,         token)
            patients    = f_patients.result()
            doctors     = f_doctors.result()
            insurance   = f_insurance.result()
    except Exception as exc:
        log.error("Notion fetch failed: %s", exc, exc_info=True)
        sys.exit(f"Notion fetch failed: {exc}")

    print(f"  {len(patients)} patient(s), {len(doctors)} doctor(s), {len(insurance)} insurance company(ies)")
    log.info("fetched from Notion: %d patients, %d doctors, %d insurance companies",
             len(patients), len(doctors), len(insurance))

    print("\nConnecting to DMEworks DB...")
    try:
        cfg  = fetch_db_config(token, args.client)
        conn = mysql.connector.connect(**cfg)
    except mysql.connector.Error as exc:
        log.error("DB connection failed: %s", exc)
        sys.exit(f"DB connection failed: {exc}")
    except Exception as exc:
        log.error("Failed to load DB config: %s", exc, exc_info=True)
        sys.exit(f"Failed to load DB config: {exc}")

    cur = conn.cursor(dictionary=True)

    all_diffs: list[tuple] = []

    _print_section("PATIENTS")
    patient_diffs, patient_stats = _verify_patients(cur, patients)
    all_diffs += patient_diffs

    _print_section("DOCTORS")
    doctor_diffs, doctor_stats = _verify_doctors(cur, doctors)
    all_diffs += doctor_diffs

    _print_section("INSURANCE COMPANIES")
    insurance_diffs, insurance_stats = _verify_insurance(cur, insurance)
    all_diffs += insurance_diffs

    _print_section("RUN SUMMARY")
    for label, s in [("Patients", patient_stats), ("Doctors", doctor_stats), ("Insurance", insurance_stats)]:
        print(f"  {label:<12}  {s['checked']} checked  |  {s['ok']} OK  |  "
              f"{s['diffs']} diff(s)  |  {s['skipped']} skipped  |  {s['not_found']} not found")
    log.info("run summary — patients: %s | doctors: %s | insurance: %s",
             patient_stats, doctor_stats, insurance_stats)

    if not all_diffs:
        print("\n  All records match. No corrections needed.")
        log.info("verify complete — all records match, no corrections needed")
        cur.close()
        conn.close()
        return

    # Summary report
    _print_section(f"DISCREPANCIES — {len(all_diffs)} record(s) need correction")
    for kind, notion, _row, diffs in all_diffs:
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

    try:
        answer = input("Apply corrections to DMEworks? [y/N]: ").strip().lower()
    except (EOFError, KeyboardInterrupt):
        answer = "n"
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
