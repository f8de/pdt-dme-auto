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
        "charset":  "latin1",
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
    Deep verification: joins customer + primary insurance + doctor.
    Returns dict keyed by MBI. Only primary insurance (Rank=1, InactiveDate IS NULL).
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
                c.Gender         AS gender,
                c.Height         AS height,
                c.Weight         AS weight,
                d.NPI            AS doctor_npi,
                d.LastName       AS doctor_last,
                d.FirstName      AS doctor_first,
                c.ICD10_01       AS icd10_01,
                c.ICD10_02       AS icd10_02,
                c.ICD10_03       AS icd10_03,
                c.ICD10_04       AS icd10_04,
                c.ICD10_05       AS icd10_05,
                c.ICD10_06       AS icd10_06,
                c.ICD10_07       AS icd10_07,
                c.ICD10_08       AS icd10_08,
                c.ICD10_09       AS icd10_09,
                c.ICD10_10       AS icd10_10,
                c.ICD10_11       AS icd10_11,
                c.ICD10_12       AS icd10_12
            FROM tbl_customer_insurance ci
            JOIN tbl_customer c  ON c.ID = ci.CustomerID
            LEFT JOIN tbl_doctor d ON d.ID = c.Doctor1_ID
            WHERE ci.PolicyNumber IN ({ph})
              AND ci.Rank = 1
              AND ci.InactiveDate IS NULL
        """, mbis)
        return {row["mbi"].strip(): row for row in cur.fetchall()}
    finally:
        conn.close()


def validate_icd10_codes(codes: list[str]) -> set[str]:
    """Return subset of codes that are NOT valid in dmeworks.tbl_icd10 (missing, header, or retired)."""
    if not codes:
        return set()
    ph = ",".join(["%s"] * len(codes))
    conn = _connect()
    try:
        cur = conn.cursor()
        cur.execute(
            f"SELECT Code FROM dmeworks.tbl_icd10 "
            f"WHERE Code IN ({ph}) AND Header = 0 "
            f"AND (InactiveDate IS NULL OR InactiveDate > CURDATE())",
            codes,
        )
        valid = {r[0].strip() for r in cur.fetchall()}
        return set(codes) - valid
    finally:
        conn.close()


# ─── WRITE FUNCTIONS ──────────────────────────────────────────────────────────
# INSERT-only. Never UPDATE or DELETE. Parameterized SQL only.

import logging as _logging
_log = _logging.getLogger("dmeworks.db")


def insert_doctor(doc: dict, dry_run: bool = False) -> int | None:
    """INSERT into dmeworks.tbl_doctor; call MIR proc. Returns new ID or None (dry-run)."""
    sql = """
        INSERT INTO dmeworks.tbl_doctor
            (FirstName, LastName, MiddleName, Suffix, Courtesy,
             NPI, Address1, Address2, City, State, Zip,
             Phone, Phone2, Fax,
             Contact, Title, LicenseNumber, MedicaidNumber, UPINNumber, OtherID,
             LastUpdateUserID, LastUpdateDatetime)
        VALUES (%s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s,
                %s, %s, %s,
                %s, %s, %s, %s, %s, %s,
                %s, NOW())
    """
    params = (
        doc.get("first", ""),
        doc.get("last", ""),
        (doc.get("mi", "") or "")[:1],
        doc.get("suffix", ""),
        doc.get("courtesy", "Dr.") or "Dr.",
        doc.get("npi", ""),
        doc.get("address1", ""),
        doc.get("address2", ""),
        doc.get("city", ""),
        doc.get("state", ""),
        doc.get("zip", ""),
        doc.get("phone", ""),
        "",               # Phone2
        doc.get("fax", ""),
        "",               # Contact
        "",               # Title
        "",               # LicenseNumber
        "",               # MedicaidNumber
        "",               # UPINNumber
        "",               # OtherID
        10,               # LastUpdateUserID
    )
    if dry_run:
        _log.info("[DRY] INSERT doctor NPI=%s", doc.get("npi"))
        return None
    conn = _connect()
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        new_id = cur.lastrowid
        cur.execute("CALL dmeworks.mir_update_doctor(%s)", (new_id,))
        conn.commit()
        return new_id
    finally:
        conn.close()


def insert_insurance_company(name: str, dry_run: bool = False) -> int | None:
    """INSERT into dmeworks.tbl_insurancecompany; call MIR proc. Returns new ID or None (dry-run)."""
    sql = """
        INSERT INTO dmeworks.tbl_insurancecompany (Name, LastUpdateUserID, LastUpdateDatetime)
        VALUES (%s, %s, NOW())
    """
    if dry_run:
        _log.info("[DRY] INSERT insurance company '%s'", name)
        return None
    conn = _connect()
    try:
        cur = conn.cursor()
        cur.execute(sql, (name, 10))
        new_id = cur.lastrowid
        cur.execute("CALL dmeworks.mir_update_insurancecompany(%s)", (new_id,))
        conn.commit()
        return new_id
    finally:
        conn.close()
