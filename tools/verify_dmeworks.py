"""
Verify DMEworks MySQL records against Notion (ground truth).
Finds discrepancies, shows a diff, prompts for confirmation, then applies corrections.

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
from utils.notion import fetch_db_config, fetch_entered_patients

# ── helpers ────────────────────────────────────────────────────────────────────

def _norm_phone(p: str) -> str:
    return re.sub(r"\D", "", p or "")

def _notion_dob_to_mysql(dob_mdy: str) -> str:
    """MM/DD/YYYY → YYYY-MM-DD"""
    if not dob_mdy:
        return ""
    try:
        return datetime.strptime(dob_mdy, "%m/%d/%Y").strftime("%Y-%m-%d")
    except ValueError:
        return dob_mdy

def _mysql_date_to_notion(d) -> str:
    """datetime.date → MM/DD/YYYY"""
    if not d:
        return ""
    return d.strftime("%m/%d/%Y")

def _norm(v) -> str:
    return (str(v) or "").strip()


# ── MySQL queries ──────────────────────────────────────────────────────────────

_FETCH_CUSTOMER = """
    SELECT
        c.ID,
        c.FirstName, c.LastName, c.MiddleName, c.Suffix,
        c.DateofBirth,
        c.Address1, c.Address2, c.City, c.State, c.Zip,
        c.Phone,
        ci.PolicyNumber AS MBI
    FROM tbl_customer c
    LEFT JOIN tbl_customer_insurance ci
        ON ci.CustomerID = c.ID AND ci.Rank = 1 AND ci.InactiveDate IS NULL
    WHERE c.FirstName = %s AND c.LastName = %s AND c.DateofBirth = %s
    LIMIT 1
"""

_UPDATE_CUSTOMER = """
    UPDATE tbl_customer
    SET FirstName=%s, LastName=%s, MiddleName=%s, Suffix=%s,
        DateofBirth=%s, Address1=%s, Address2=%s, City=%s, State=%s, Zip=%s, Phone=%s
    WHERE ID=%s
"""

_UPDATE_MBI = """
    UPDATE tbl_customer_insurance
    SET PolicyNumber=%s
    WHERE CustomerID=%s AND Rank=1 AND InactiveDate IS NULL
"""


# ── comparison ─────────────────────────────────────────────────────────────────

_FIELDS = [
    # (label, notion_key, transform_notion, transform_mysql)
    ("First Name",  "first",    _norm,       _norm),
    ("Last Name",   "last",     _norm,       _norm),
    ("MI",          "mi",       _norm,       _norm),
    ("Suffix",      "suffix",   _norm,       _norm),
    ("DOB",         "dob",      _norm,       _mysql_date_to_notion),
    ("Address 1",   "address1", _norm,       _norm),
    ("Address 2",   "address2", _norm,       _norm),
    ("City",        "city",     _norm,       _norm),
    ("State",       "state",    _norm,       _norm),
    ("ZIP",         "zip",      _norm,       _norm),
    ("Phone",       "phone",    _norm_phone, _norm_phone),
    ("MBI",         "mbi",      _norm,       _norm),
]

def _compare(notion: dict, row: dict) -> list[tuple]:
    """Return list of (label, notion_val, mysql_val) for differing fields."""
    diffs = []
    for label, key, fn, fm in _FIELDS:
        n_raw = notion.get(key, "")
        m_raw = row.get(key if key != "mbi" else "MBI", "")
        if key == "dob":
            n_val = fn(n_raw)
            m_val = fm(m_raw)
            # compare as YYYY-MM-DD
            n_cmp = _notion_dob_to_mysql(n_raw)
            m_cmp = _norm(m_raw.strftime("%Y-%m-%d") if hasattr(m_raw, "strftime") else m_raw)
            if n_cmp != m_cmp:
                diffs.append((label, n_raw, _mysql_date_to_notion(m_raw) if m_raw else ""))
        else:
            if fn(n_raw) != fm(m_raw):
                diffs.append((label, _norm(n_raw), _norm(m_raw)))
    return diffs


# ── display ────────────────────────────────────────────────────────────────────

def _print_diff(name: str, diffs: list[tuple]) -> None:
    print(f"\n  Patient: {name}")
    print(f"  {'Field':<12}  {'Notion (correct)':<30}  {'DMEworks (stored)'}")
    print(f"  {'-'*12}  {'-'*30}  {'-'*30}")
    for label, n_val, m_val in diffs:
        marker = "MBI" if label == "MBI" else ""
        print(f"  {label:<12}  {n_val:<30}  {m_val}  {marker}")


# ── main ───────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Verify DMEworks records against Notion")
    parser.add_argument("--client", required=True, help="Client code (e.g. c02)")
    args = parser.parse_args()

    token = os.environ.get("NOTION_TOKEN", "").strip()
    if not token:
        sys.exit("NOTION_TOKEN not set in environment.")

    print(f"Fetching 'In DMEworks' patients from Notion...")
    patients = fetch_entered_patients(token)
    if not patients:
        print("No patients with status 'In DMEworks' found.")
        return

    print(f"Found {len(patients)} patient(s). Connecting to DMEworks DB...")
    cfg = fetch_db_config(token, args.client)
    conn = mysql.connector.connect(**cfg)
    cur  = conn.cursor(dictionary=True)

    all_diffs: list[tuple[dict, dict, list[tuple]]] = []  # (notion, row, diffs)

    for p in patients:
        dob_mysql = _notion_dob_to_mysql(p["dob"])
        cur.execute(_FETCH_CUSTOMER, (p["first"], p["last"], dob_mysql))
        row = cur.fetchone()

        if row is None:
            # Try without DOB in case DOB itself is wrong — match name only
            cur.execute(
                "SELECT ID, FirstName, LastName, MiddleName, Suffix, DateofBirth, "
                "Address1, Address2, City, State, Zip, Phone, NULL AS MBI "
                "FROM tbl_customer WHERE FirstName=%s AND LastName=%s LIMIT 1",
                (p["first"], p["last"]),
            )
            row = cur.fetchone()
            if row is None:
                print(f"\n  WARNING: {p['first']} {p['last']} — not found in DMEworks. Skipping.")
                continue
            # Fetch MBI separately
            cur.execute(
                "SELECT PolicyNumber FROM tbl_customer_insurance "
                "WHERE CustomerID=%s AND Rank=1 AND InactiveDate IS NULL LIMIT 1",
                (row["ID"],),
            )
            mbi_row = cur.fetchone()
            row["MBI"] = mbi_row["PolicyNumber"] if mbi_row else ""

        diffs = _compare(p, row)
        if diffs:
            all_diffs.append((p, row, diffs))
        else:
            print(f"  {p['first']} {p['last']} — OK")

    if not all_diffs:
        print("\nAll records match. No corrections needed.")
        cur.close()
        conn.close()
        return

    # Show report
    print(f"\n{'='*70}")
    print(f"  DISCREPANCIES FOUND ({len(all_diffs)} patient(s)):")
    print(f"{'='*70}")
    for p, row, diffs in all_diffs:
        _print_diff(f"{p['first']} {p['last']}", diffs)

    print(f"\n{'='*70}")
    answer = input("Apply corrections to DMEworks? [y/N]: ").strip().lower()
    if answer != "y":
        print("Aborted. No changes made.")
        cur.close()
        conn.close()
        return

    # Apply corrections
    for p, row, diffs in all_diffs:
        customer_id = row["ID"]
        dob_mysql   = _notion_dob_to_mysql(p["dob"])

        cur.execute(_UPDATE_CUSTOMER, (
            p["first"], p["last"], p["mi"], p["suffix"],
            dob_mysql or None,
            p["address1"], p["address2"], p["city"], p["state"], p["zip"],
            p["phone"],
            customer_id,
        ))

        if any(label == "MBI" for label, _, _ in diffs):
            cur.execute(_UPDATE_MBI, (p["mbi"], customer_id))

        print(f"  Updated: {p['first']} {p['last']} (ID={customer_id})")

    conn.commit()
    print(f"\nDone. {len(all_diffs)} record(s) corrected.")
    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
