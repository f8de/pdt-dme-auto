"""
Targeted DB checks and verification against the DMEworks company schema.
All connection params from Doppler. Read-only — never write directly.
Call db.configure() once at startup.
"""

import json
import os
import sys

import mysql.connector

_conn_params: dict | None = None


def _load_db_ref() -> dict:
    base = getattr(sys, "_MEIPASS", os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    path = os.path.join(base, "config", "database_reference.json")
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def build_config(database: str | None = None) -> dict:
    """Assemble MySQL connection params. database defaults to 'allied' from database_reference.json."""
    from utils.creds import get_mysql_creds, MYSQL_HOST, MYSQL_PORT
    user, password = get_mysql_creds()
    db_name = database or _load_db_ref()["allied"]
    return {
        "host":     MYSQL_HOST,
        "port":     MYSQL_PORT,
        "database": db_name,
        "user":     user,
        "password": password,
    }


def configure(database: str | None = None) -> None:
    """Build and store DB connection params for this session."""
    global _conn_params
    _conn_params = build_config(database)


def _connect():
    if _conn_params is None:
        raise RuntimeError(
            "db.configure(client_code) must be called before running queries."
        )
    return mysql.connector.connect(**_conn_params)


# ─── EXISTENCE CHECKS ─────────────────────────────────────────────────────────

def fetch_matching_npis(npis: list[str]) -> set[str]:
    """Return subset of npis already in tbl_doctor."""
    if not npis:
        return set()
    ph = ",".join(["%s"] * len(npis))
    conn = _connect()
    try:
        cur = conn.cursor()
        cur.execute(f"SELECT NPI FROM tbl_doctor WHERE NPI IN ({ph})", npis)
        return {r[0].strip() for r in cur.fetchall()}
    finally:
        conn.close()


def fetch_matching_insurance_names(names: list[str]) -> set[str]:
    """Return subset of names (lowercased) already in tbl_insurancecompany."""
    if not names:
        return set()
    ph = ",".join(["%s"] * len(names))
    conn = _connect()
    try:
        cur = conn.cursor()
        cur.execute(
            f"SELECT Name FROM tbl_insurancecompany WHERE Name IN ({ph})", names
        )
        return {r[0].strip().lower() for r in cur.fetchall()}
    finally:
        conn.close()


def fetch_matching_mbis(mbis: list[str]) -> set[str]:
    """
    Return subset of MBIs already in tbl_customer_insurance.PolicyNumber.
    MBI is a globally unique Medicare Beneficiary Identifier.
    """
    if not mbis:
        return set()
    ph = ",".join(["%s"] * len(mbis))
    conn = _connect()
    try:
        cur = conn.cursor()
        cur.execute(
            f"SELECT PolicyNumber FROM tbl_customer_insurance "
            f"WHERE PolicyNumber IN ({ph})",
            mbis
        )
        return {r[0].strip() for r in cur.fetchall()}
    finally:
        conn.close()


# ─── VERIFICATION ─────────────────────────────────────────────────────────────

def verify_patients(patients: list[dict]) -> dict[str, dict]:
    """
    Deep verification query: joins customer + insurance + doctor tables.
    Returns dict keyed by MBI with DB values for field-level comparison.
    """
    mbis = [p["mbi"] for p in patients]
    if not mbis:
        return {}
    ph = ",".join(["%s"] * len(mbis))
    conn = _connect()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(f"""
            SELECT
                ci.PolicyNumber  AS mbi,
                c.FirstName      AS first,
                c.LastName       AS last,
                c.DateofBirth    AS dob,
                c.Address1       AS address1,
                c.City           AS city,
                c.State          AS state,
                c.Zip            AS zip,
                d.NPI            AS doctor_npi,
                d.LastName       AS doctor_last,
                d.FirstName      AS doctor_first
            FROM tbl_customer_insurance ci
            JOIN tbl_customer c  ON c.ID = ci.CustomerID
            LEFT JOIN tbl_doctor d ON d.ID = c.Doctor1_ID
            WHERE ci.PolicyNumber IN ({ph})
        """, mbis)
        return {row["mbi"].strip(): row for row in cur.fetchall()}
    finally:
        conn.close()
