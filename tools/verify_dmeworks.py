"""
Verify DMEworks MySQL records against all Notion databases (ground truth).
Covers: Patients, Doctors, Insurance Companies.
Shows field-level diffs, prompts confirmation, applies corrections.

Usage:
    python tools/verify_dmeworks.py --client <CLIENT_CODE>
    NOTION_TOKEN must be set in the environment.
"""
import argparse
import os
import re
import sys
from datetime import datetime

import mysql.connector

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from utils.notion import (
    fetch_all_doctors,
    fetch_all_insurance,
    fetch_db_config,
    fetch_entered_patients,
)

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
    """
    fields: list of (label, notion_key, sql_key, norm_fn)
    Returns list of (label, notion_val_display, sql_val_display) for mismatches.
    """
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
    LIMIT 1
"""

_FETCH_PATIENT_BY_NAME = """
    SELECT
        c.ID, c.FirstName, c.LastName, c.MiddleName, c.Suffix,
        c.DateofBirth, c.Address1, c.Address2, c.City, c.State, c.Zip, c.Phone
    FROM tbl_customer c
    WHERE c.FirstName = %s AND c.LastName = %s
    LIMIT 1
"""

def _verify_patients(cur, patients: list[dict]) -> list[tuple]:
    results = []
    for p in patients:
        dob_sql = _notion_dob_to_sql(p["dob"])
        cur.execute(_FETCH_PATIENT, (p["first"], p["last"], dob_sql))
        row = cur.fetchone()

        if row is None:
            # DOB itself may be wrong — try name-only match
            cur.execute(_FETCH_PATIENT_BY_NAME, (p["first"], p["last"]))
            row = cur.fetchone()
            if row is None:
                print(f"  WARNING: {p['first']} {p['last']} — not found in DMEworks")
                continue
            cur.execute(
                "SELECT PolicyNumber FROM tbl_customer_insurance "
                "WHERE CustomerID=%s AND Rank=1 AND InactiveDate IS NULL LIMIT 1",
                (row["ID"],),
            )
            mbi_row = cur.fetchone()
            row["MBI"] = mbi_row["PolicyNumber"] if mbi_row else ""

        diffs = _diff(_PATIENT_FIELDS, p, row)

        # DOB special-case
        n_dob = _notion_dob_to_sql(p["dob"])
        m_dob = row["DateofBirth"].strftime("%Y-%m-%d") if row["DateofBirth"] else ""
        if n_dob != m_dob:
            diffs.append(("DOB", p["dob"], _sql_date_to_notion(row["DateofBirth"])))

        # MBI special-case
        if _norm(p["mbi"]) != _norm(row.get("MBI", "")):
            diffs.append(("MBI", _norm(p["mbi"]), _norm(row.get("MBI", ""))))

        if diffs:
            results.append(("patient", p, row, diffs))
        else:
            print(f"  {p['first']} {p['last']} — OK")
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
    FROM tbl_doctor WHERE NPI = %s LIMIT 1
"""
_FETCH_DOCTOR_BY_NAME = """
    SELECT ID, FirstName, LastName, NPI, Address1, Address2, City, State, Zip, Phone
    FROM tbl_doctor WHERE FirstName = %s AND LastName = %s LIMIT 1
"""

def _verify_doctors(cur, doctors: list[dict]) -> list[tuple]:
    results = []
    for d in doctors:
        row = None
        if d["npi"]:
            cur.execute(_FETCH_DOCTOR_BY_NPI, (d["npi"],))
            row = cur.fetchone()
        if row is None:
            cur.execute(_FETCH_DOCTOR_BY_NAME, (d["first"], d["last"]))
            row = cur.fetchone()
        if row is None:
            print(f"  WARNING: Dr. {d['first']} {d['last']} — not found in DMEworks")
            continue

        diffs = _diff(_DOCTOR_FIELDS, d, row)
        if diffs:
            results.append(("doctor", d, row, diffs))
        else:
            print(f"  Dr. {d['first']} {d['last']} — OK")
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
            # Report missing — no fields to diff, just flag it
            results.append(("insurance", c, None, [("Name", c["name"], "(not found in DMEworks)")]))
        else:
            print(f"  {c['name']} — OK")
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

def _apply(cur, all_diffs: list[tuple]) -> int:
    count = 0
    for kind, notion, row, diffs in all_diffs:
        if kind == "patient":
            p = notion
            cur.execute(_UPDATE_CUSTOMER, (
                p["first"], p["last"], p["mi"], p["suffix"],
                _notion_dob_to_sql(p["dob"]) or None,
                p["address1"], p["address2"], p["city"], p["state"], p["zip"], p["phone"],
                row["ID"],
            ))
            if any(f == "MBI" for f, _, _ in diffs):
                cur.execute(_UPDATE_MBI, (p["mbi"], row["ID"]))
            print(f"  Updated patient: {p['first']} {p['last']} (ID={row['ID']})")
            count += 1

        elif kind == "doctor":
            d = notion
            cur.execute(_UPDATE_DOCTOR, (
                d["first"], d["last"], d["npi"],
                d["address1"], d["address2"], d["city"], d["state"], d["zip"], d["phone"],
                row["ID"],
            ))
            print(f"  Updated doctor: {d['first']} {d['last']} (ID={row['ID']})")
            count += 1

        elif kind == "insurance":
            print(f"  SKIP insurance '{notion['name']}' — manual action required in DMEworks")
    return count


# ── main ───────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Verify all Notion DBs against DMEworks")
    parser.add_argument("--client", required=True, help="Client code (e.g. c02)")
    args = parser.parse_args()

    token = os.environ.get("NOTION_TOKEN", "").strip()
    if not token:
        sys.exit("NOTION_TOKEN not set in environment.")

    print("Fetching Notion data...")
    patients  = fetch_entered_patients(token)
    doctors   = fetch_all_doctors(token)
    insurance = fetch_all_insurance(token)
    print(f"  {len(patients)} patient(s), {len(doctors)} doctor(s), {len(insurance)} insurance company(ies)")

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
    answer = input("Apply corrections to DMEworks? [y/N]: ").strip().lower()
    if answer != "y":
        print("Aborted. No changes made.")
        cur.close()
        conn.close()
        return

    count = _apply(cur, all_diffs)
    conn.commit()
    print(f"\nDone. {count} record(s) corrected.")
    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
