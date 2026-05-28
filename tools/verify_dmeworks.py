"""
Audit DMEworks MySQL records against all Notion databases (ground truth).
Read-only — no SQL writes. Covers: Patients, Doctors, Insurance Companies.
Shows field-level diffs per record.

To apply corrections: use fix_via_ui.py (option [4] in launcher).

Usage:
    python tools/verify_dmeworks.py
"""
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
    fetch_patients_by_statuses,
)

log = get_logger("verify")

# ── normalizers ────────────────────────────────────────────────────────────────

def _norm(v) -> str:
    return (str(v) if v is not None else "").strip()

def _norm_phone(p) -> str:
    return re.sub(r"\D", "", _norm(p))

def _norm_num(v) -> str:
    s = _norm(v)
    try:
        f = float(s)
        return str(int(f)) if f == int(f) else str(f)
    except (ValueError, TypeError):
        return s

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
    print(f"  {'Field':<16}  {'Notion (correct)':<32}  DMEworks (stored)")
    print(f"  {'-'*16}  {'-'*32}  {'-'*32}")
    for field, _sql_col, _sql_val, n_display, m_display in diffs:
        print(f"  {field:<16}  {n_display:<32}  {m_display}")


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
    ("Gender",      "gender",   "Gender",      _norm),
    ("Height",      "height",   "Height",      _norm_num),
    ("Weight",      "weight",   "Weight",      _norm_num),
    ("Address 1",   "address1", "Address1",    _norm),
    ("Address 2",   "address2", "Address2",    _norm),
    ("City",        "city",     "City",        _norm),
    ("State",       "state",    "State",       _norm),
    ("ZIP",         "zip",      "Zip",         _norm),
    ("Phone",       "phone",    "Phone",       _norm_phone),
]

# Shared SELECT columns for all patient lookups
_PATIENT_COLS = """
    c.ID,
    c.FirstName, c.LastName, c.MiddleName, c.Suffix,
    c.DateofBirth, c.Gender,
    c.Address1, c.Address2, c.City, c.State, c.Zip, c.Phone,
    c.Height, c.Weight,
    c.ICD10_01, c.ICD10_02, c.ICD10_03, c.ICD10_04,
    c.ICD10_05, c.ICD10_06, c.ICD10_07, c.ICD10_08,
    c.ICD10_09, c.ICD10_10, c.ICD10_11, c.ICD10_12,
    d.NPI AS doctor_npi,
    ci.PolicyNumber AS MBI
"""

# Primary lookup: by MBI (most reliable — uniquely identifies the patient)
_FETCH_PATIENT_BY_MBI = f"""
    SELECT {_PATIENT_COLS}
    FROM tbl_customer_insurance ci
    JOIN tbl_customer c ON c.ID = ci.CustomerID
    LEFT JOIN dmeworks.tbl_doctor d ON d.ID = c.Doctor1_ID
    WHERE ci.PolicyNumber = %s AND ci.Rank = 1 AND ci.InactiveDate IS NULL
    LIMIT 2
"""

# Fallback: by name + DOB
_FETCH_PATIENT = f"""
    SELECT {_PATIENT_COLS}
    FROM tbl_customer c
    LEFT JOIN dmeworks.tbl_doctor d ON d.ID = c.Doctor1_ID
    LEFT JOIN tbl_customer_insurance ci
        ON ci.CustomerID = c.ID AND ci.Rank = 1 AND ci.InactiveDate IS NULL
    WHERE c.FirstName = %s AND c.LastName = %s AND c.DateofBirth = %s
    LIMIT 2
"""

# Last-resort: by name only
_FETCH_PATIENT_BY_NAME = f"""
    SELECT {_PATIENT_COLS}
    FROM tbl_customer c
    LEFT JOIN dmeworks.tbl_doctor d ON d.ID = c.Doctor1_ID
    LEFT JOIN tbl_customer_insurance ci
        ON ci.CustomerID = c.ID AND ci.Rank = 1 AND ci.InactiveDate IS NULL
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

        # 1. Try MBI lookup first
        rows = []
        if p.get("mbi"):
            cur.execute(_FETCH_PATIENT_BY_MBI, (p["mbi"],))
            rows = cur.fetchall()

        # 2. Fall back to name + DOB
        if not rows and dob_sql:
            cur.execute(_FETCH_PATIENT, (p["first"], p["last"], dob_sql))
            rows = cur.fetchall()

        if len(rows) > 1:
            msg = f"SKIP patient {name} — ambiguous: {len(rows)} records match in DMEworks"
            print(f"  {msg}")
            log.warning(msg)
            stats["skipped"] += 1
            continue

        if not rows:
            # 3. Last resort: name only
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
        diffs = _diff(_PATIENT_FIELDS, p, row)

        # DOB — sql_val is YYYY-MM-DD for UPDATE; display Notion value as MM/DD/YYYY
        m_dob = row["DateofBirth"].strftime("%Y-%m-%d") if row["DateofBirth"] else ""
        if dob_sql != m_dob:
            diffs.append(("DOB", "DateofBirth", dob_sql or None,
                          p["dob"], _sql_date_to_notion(row["DateofBirth"])))

        # MBI — sql_col=None signals separate table (tbl_customer_insurance)
        if _norm(p["mbi"]) != _norm(row.get("MBI", "")):
            diffs.append(("MBI", None, _norm(p["mbi"]),
                          _norm(p["mbi"]), _norm(row.get("MBI", ""))))

        # Doctor NPI — display only (__skip__), requires manual DB fix (Doctor1_ID lookup)
        n_npi = _norm(p.get("_doctor", {}).get("npi", ""))
        m_npi = _norm(row.get("doctor_npi", ""))
        if n_npi != m_npi:
            diffs.append(("Doctor NPI", "__skip__", None,
                          n_npi or "(none)", m_npi or "(none)"))

        # ICD-10 codes — set comparison (order doesn't matter)
        n_icd10 = sorted(c.strip().upper() for c in p.get("icd10", []) if c.strip())
        m_icd10 = sorted(
            row[f"ICD10_{i:02d}"].strip().upper()
            for i in range(1, 13)
            if row.get(f"ICD10_{i:02d}")
        )
        if n_icd10 != m_icd10:
            diffs.append(("ICD-10 codes", "__icd10__", p.get("icd10", []),
                          " | ".join(n_icd10) or "(none)",
                          " | ".join(m_icd10) or "(none)"))

        # Notes — stored in tbl_customer_notes, display only
        n_notes = _norm(p.get("notes", ""))
        if n_notes:
            cur.execute(
                "SELECT Notes FROM tbl_customer_notes WHERE CustomerID = %s AND Active = 1",
                (row["ID"],)
            )
            db_notes = " | ".join(
                _norm(r["Notes"]) for r in cur.fetchall() if r.get("Notes")
            )
            if n_notes != db_notes:
                n_disp = (n_notes[:40] + "...") if len(n_notes) > 40 else n_notes
                m_disp = (db_notes[:40] + "...") if len(db_notes) > 40 else db_notes or "(none)"
                diffs.append(("Notes", "__skip__", None, n_disp, m_disp))

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
    ("First Name",  "first",    "FirstName",   _norm),
    ("Last Name",   "last",     "LastName",    _norm),
    ("MI",          "mi",       "MiddleName",  _norm),
    ("Suffix",      "suffix",   "Suffix",      _norm),
    ("NPI",         "npi",      "NPI",         _norm),
    ("Fax",         "fax",      "Fax",         _norm_phone),
    ("Address 1",   "address1", "Address1",    _norm),
    ("Address 2",   "address2", "Address2",    _norm),
    ("City",        "city",     "City",        _norm),
    ("State",       "state",    "State",       _norm),
    ("ZIP",         "zip",      "Zip",         _norm),
    ("Phone",       "phone",    "Phone",       _norm_phone),
]

_FETCH_DOCTOR_BY_NPI = """
    SELECT ID, FirstName, LastName, MiddleName, Suffix, NPI, Fax,
           Address1, Address2, City, State, Zip, Phone
    FROM dmeworks.tbl_doctor WHERE NPI = %s LIMIT 2
"""
_FETCH_DOCTOR_BY_NAME = """
    SELECT ID, FirstName, LastName, MiddleName, Suffix, NPI, Fax,
           Address1, Address2, City, State, Zip, Phone
    FROM dmeworks.tbl_doctor WHERE FirstName = %s AND LastName = %s LIMIT 2
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
    SELECT ID, Name FROM dmeworks.tbl_insurancecompany WHERE Name = %s LIMIT 1
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
            results.append(("insurance", c, None,
                            [("Name", "__skip__", None, c["name"], "(not found in DMEworks)")]))
        else:
            print(f"  {c['name']} — OK")
            log.debug("insurance '%s' — OK", c["name"])
            stats["ok"] += 1
    return results, stats


# ── main ───────────────────────────────────────────────────────────────────────

def main() -> None:
    try:
        token = get_notion_token()
    except RuntimeError as exc:
        log.error("Failed to get Notion token: %s", exc)
        sys.exit(str(exc))

    log.info("audit start")

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
        patient_fetch_statuses = None
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
        from utils.db import build_config
        cfg  = build_config()
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

    cur.close()
    conn.close()

    if not all_diffs:
        print("\n  All records match.")
        log.info("audit complete — all records match")
        return

    _print_section(f"DISCREPANCIES — {len(all_diffs)} record(s)")
    for kind, notion, _row, diffs in all_diffs:
        if kind == "patient":
            label = f"Patient: {notion['first']} {notion['last']}"
        elif kind == "doctor":
            label = f"Doctor: {notion['first']} {notion['last']}"
        else:
            label = f"Insurance: {notion['name']}"
        _print_diff(label, diffs)

    print(f"\n{'='*70}")
    print("  To fix: use option [4] in the launcher (Verify + Fix via DMEworks UI).")
    log.info("audit complete — %d discrepancy(ies) found", len(all_diffs))
    try:
        input("\nPress Enter to close...")
    except (EOFError, KeyboardInterrupt):
        pass


if __name__ == "__main__":
    main()
