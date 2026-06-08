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
        "use_pure": True,
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
        cur.execute(f"SELECT NPI FROM dmeworks.tbl_doctor WHERE NPI IN ({ph})", npis)
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

def verify_doctor(npi: str) -> dict | None:
    """Return tbl_doctor row for given NPI, or None if not found."""
    conn = _connect()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT FirstName, LastName, MiddleName, Suffix, Courtesy, NPI, "
            "Address1, Address2, City, State, Zip, Phone, Fax "
            "FROM dmeworks.tbl_doctor WHERE NPI = %s",
            (npi,),
        )
        return cur.fetchone()
    finally:
        conn.close()


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
                c.ID             AS customer_id,
                ci.PolicyNumber  AS mbi,
                c.FirstName      AS first,
                c.LastName       AS last,
                c.MiddleName     AS mi,
                c.Suffix         AS suffix,
                c.DateofBirth    AS dob,
                c.Address1       AS address1,
                c.Address2       AS address2,
                c.City           AS city,
                c.State          AS state,
                c.Zip            AS zip,
                c.Phone          AS phone,
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
            LEFT JOIN dmeworks.tbl_doctor d ON d.ID = c.Doctor1_ID
            WHERE ci.PolicyNumber IN ({ph})
              AND ci.Rank = 1
              AND ci.InactiveDate IS NULL
        """, mbis)
        return {row["mbi"].strip(): row for row in cur.fetchall()}
    finally:
        conn.close()


def fetch_secondary_insurance(customer_ids: list[int]) -> dict[int, dict]:
    """Return active Rank=2 insurance rows keyed by customer_id."""
    if not customer_ids:
        return {}
    ph = ",".join(["%s"] * len(customer_ids))
    conn = _connect()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(f"""
            SELECT ci.CustomerID, ci.PolicyNumber, ins.Name AS ins_company
            FROM tbl_customer_insurance ci
            JOIN dmeworks.tbl_insurancecompany ins ON ins.ID = ci.InsuranceCompanyID
            WHERE ci.CustomerID IN ({ph})
              AND ci.Rank = 2
              AND ci.InactiveDate IS NULL
        """, customer_ids)
        return {row["CustomerID"]: row for row in cur.fetchall()}
    finally:
        conn.close()


def verify_patient_notes(customer_id: int) -> list[dict]:
    """Return notes rows for a customer from tbl_customer_notes."""
    conn = _connect()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT Notes, Active FROM tbl_customer_notes WHERE CustomerID = %s",
            (customer_id,),
        )
        return cur.fetchall()
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


_INS_TYPE_MAP = {
    "MEDICARE": "13",  # "13" = Medicare per DMEworks UI observation
    "MEDICAID": "OT",
    "MEDIGAP": "LT",
    "SUPPLEMENTAL": "SP",
    "COMMERCIAL_GROUP": "GP",
    "COMMERCIAL_INDIVIDUAL": "IP",
}


def insert_patient(patient: dict, insurance_map: dict, dry_run: bool = False) -> int | None:
    """
    INSERT patient into tbl_customer + tbl_customer_insurance in a single transaction.
    Calls c02.mir_update_customer and c02.mir_update_customer_insurance after all INSERTs.
    Returns new customer ID or None (dry-run).
    Raises RuntimeError if doctor or insurance lookups fail.
    On any error: rolls back and re-raises.
    """
    from utils.logger import mask_mbi
    from datetime import datetime as _dt2, date as _date2
    mbi   = patient["mbi"]
    label = f"MBI {mask_mbi(mbi)}"

    icd10 = patient.get("icd10", [])
    icd10_vals = tuple(icd10[i] if i < len(icd10) else None for i in range(12))

    try:
        height = float(patient["height"]) if patient.get("height") else None
        weight = float(patient["weight"]) if patient.get("weight") else None
    except (ValueError, TypeError):
        height = weight = None

    try:
        dob = _dt2.strptime(patient["dob"], "%m/%d/%Y").date()
    except ValueError as e:
        raise ValueError(f"{label}: invalid DOB '{patient['dob']}'") from e

    if dry_run:
        _log.info("[DRY] INSERT patient %s %s | %s", patient["first"], patient["last"], label)
        return None

    conn = _connect()
    try:
        conn.start_transaction()
        cur = conn.cursor()

        cur.execute("SELECT MAX(CAST(AccountNumber AS UNSIGNED)) FROM tbl_customer FOR UPDATE")
        max_acct = cur.fetchone()[0] or 0
        acct_num = str(max_acct + 1)

        doctor_npi = patient.get("_doctor", {}).get("npi", "")
        cur.execute("SELECT ID FROM dmeworks.tbl_doctor WHERE NPI = %s", (doctor_npi,))
        row = cur.fetchone()
        doctor_id = row[0] if row else None

        medicare_name = insurance_map.get(patient["state"], "")
        cur.execute(
            "SELECT ID FROM dmeworks.tbl_insurancecompany WHERE LOWER(Name) = LOWER(%s)",
            (medicare_name,),
        )
        row = cur.fetchone()
        if not row:
            raise RuntimeError(f"Insurance company not found: '{medicare_name}'")
        ins_id = row[0]

        cur.execute("""
            INSERT INTO tbl_customer
                (AccountNumber, FirstName, LastName, MiddleName, Suffix,
                 DateofBirth, Address1, Address2, City, State, Zip, Phone,
                 Doctor1_ID, POSTypeID, AccidentType, DeliveryDirections, EmergencyContact,
                 Gender, Height, Weight,
                 ICD10_01, ICD10_02, ICD10_03, ICD10_04, ICD10_05, ICD10_06,
                 ICD10_07, ICD10_08, ICD10_09, ICD10_10, ICD10_11, ICD10_12,
                 SetupDate, LastUpdateUserID, LastUpdateDatetime)
            VALUES
                (%s, %s, %s, %s, %s,
                 %s, %s, %s, %s, %s, %s, %s,
                 %s, %s, %s, %s, %s,
                 %s, %s, %s,
                 %s, %s, %s, %s, %s, %s,
                 %s, %s, %s, %s, %s, %s,
                 %s, %s, NOW())
        """, (
            acct_num,
            patient.get("first", ""), patient.get("last", ""),
            (patient.get("mi", "") or "")[:1], patient.get("suffix", ""),
            dob,
            patient.get("address1", ""), patient.get("address2", ""),
            patient.get("city", ""), patient.get("state", ""),
            patient.get("zip", ""), patient.get("phone", ""),
            doctor_id, 12, "No", "", "",
            patient.get("gender") or "Male", height, weight,
            *icd10_vals,
            _date2.today(), 10,
        ))
        customer_id = cur.lastrowid

        # InsuranceType "13" = Medicare (per DMEworks UI observation).
        # Subscriber fields populated for completeness; subscriber is the patient for Rank=1/self.
        cur.execute("""
            INSERT INTO tbl_customer_insurance
                (CustomerID, InsuranceCompanyID, InsuranceType,
                 PolicyNumber, Rank, RelationshipCode, LastUpdateUserID,
                 FirstName, LastName, DateofBirth, Gender)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (customer_id, ins_id, "13", mbi, 1, "18", 10,
              patient.get("first", ""), patient.get("last", ""),
              dob, patient.get("gender") or "Male"))

        sec = patient.get("secondary")
        if sec:
            cur.execute(
                "SELECT ID FROM dmeworks.tbl_insurancecompany WHERE LOWER(Name) = LOWER(%s)",
                (sec["ins_company"],),
            )
            row = cur.fetchone()
            if not row:
                raise RuntimeError(f"Secondary insurance company not found: '{sec['ins_company']}'")
            sec_ins_id   = row[0]
            sec_ins_type = _INS_TYPE_MAP.get(sec.get("ins_type", ""), "OT")
            cur.execute("""
                INSERT INTO tbl_customer_insurance
                    (CustomerID, InsuranceCompanyID, InsuranceType,
                     PolicyNumber, Rank, RelationshipCode, LastUpdateUserID,
                     FirstName, LastName, DateofBirth, Gender)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (customer_id, sec_ins_id, sec_ins_type, sec["policy"], 2, "18", 10,
                  patient.get("first", ""), patient.get("last", ""),
                  dob, patient.get("gender") or "Male"))

        notes = patient.get("notes", "")
        if notes:
            cur.execute("""
                INSERT INTO tbl_customer_notes
                    (CustomerID, Notes, Active, LastUpdateUserID, CreatedBy, CreatedAt)
                VALUES (%s, %s, %s, %s, %s, NOW())
            """, (customer_id, notes, 1, 10, 10))

        db_name = _conn_params["database"]
        cur.execute(f"CALL {db_name}.mir_update_customer(%s)", (customer_id,))
        cur.execute(f"CALL {db_name}.mir_update_customer_insurance(%s)", (customer_id,))

        conn.commit()
        _log.info("[OK] Inserted customer ID=%d for %s", customer_id, label)
        return customer_id

    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


# ─── TEST UTILITIES ───────────────────────────────────────────────────────────

_TEST_FIXTURE_NPI = "9999999999"
_TEST_FIXTURE_MBI = "1AA0AA0AA11"


def clear_test_fixtures(npi: str, mbi: str) -> None:
    """Delete all DB rows for the test doctor (by NPI) and test patient (by MBI).
    Called at the top of every --live test run so each run starts from a clean state.
    Deletion order respects FK: notes → insurance → customer → doctor.

    Safety: only accepts the known test NPI/MBI — raises ValueError for any other values.
    Rolls back and raises if more than 1 doctor or 1 customer would be affected.
    """
    if npi != _TEST_FIXTURE_NPI or mbi != _TEST_FIXTURE_MBI:
        raise ValueError(
            f"clear_test_fixtures refused: only test NPI={_TEST_FIXTURE_NPI} / "
            f"MBI={_TEST_FIXTURE_MBI} are permitted. Got NPI={npi} MBI={mbi}"
        )

    conn = _connect()
    try:
        cur = conn.cursor()

        cur.execute(
            "SELECT CustomerID FROM tbl_customer_insurance WHERE PolicyNumber = %s",
            (mbi,),
        )
        rows = cur.fetchall()
        customer_ids = list({r[0] for r in rows})
        if len(customer_ids) > 1:
            raise RuntimeError(
                f"clear_test_fixtures safety abort: MBI {mbi} maps to "
                f"{len(customer_ids)} customers — expected at most 1"
            )
        customer_id = customer_ids[0] if customer_ids else None

        cur.execute(
            "SELECT COUNT(*) FROM dmeworks.tbl_doctor WHERE NPI = %s", (npi,)
        )
        doctor_count = cur.fetchone()[0]
        if doctor_count > 1:
            raise RuntimeError(
                f"clear_test_fixtures safety abort: NPI {npi} matches "
                f"{doctor_count} doctors — expected at most 1"
            )

        if customer_id:
            cur.execute("DELETE FROM tbl_customer_notes WHERE CustomerID = %s", (customer_id,))
            cur.execute("DELETE FROM tbl_customer_insurance WHERE CustomerID = %s", (customer_id,))
            cur.execute("DELETE FROM tbl_customer WHERE ID = %s", (customer_id,))

        cur.execute("DELETE FROM dmeworks.tbl_doctor WHERE NPI = %s", (npi,))

        conn.commit()
        _log.info("[CLEAR] test fixtures removed — NPI=%s MBI=%s customer_id=%s",
                  npi, mbi, customer_id)
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def backup_databases(backup_dir: str) -> str:
    """
    Dump c02 + dmeworks via mysqldump. Purge backups older than 7 days.
    Returns path to new backup file.
    Raises RuntimeError if mysqldump exits non-zero.
    """
    import subprocess
    from pathlib import Path as _Path2
    from datetime import datetime as _dt3
    from utils.creds import get_mysql_creds, MYSQL_HOST, MYSQL_PORT
    user, password = get_mysql_creds()
    _Path2(backup_dir).mkdir(parents=True, exist_ok=True)

    ts   = _dt3.now().strftime("%Y%m%d_%H%M%S")
    path = str(_Path2(backup_dir) / f"backup_{ts}.sql")

    cmd = [
        "mysqldump",
        f"--host={MYSQL_HOST}",
        f"--port={MYSQL_PORT}",
        f"--user={user}",
        f"--password={password}",
        "--databases", "c02", "dmeworks",
    ]
    with open(path, "w", encoding="utf-8") as fout:
        result = subprocess.run(cmd, stdout=fout, stderr=subprocess.PIPE, text=True)

    if result.returncode != 0:
        raise RuntimeError(f"mysqldump failed: {result.stderr.strip()}")

    cutoff = _dt3.now().timestamp() - 7 * 86400
    for old in _Path2(backup_dir).glob("backup_*.sql"):
        try:
            if old.stat().st_mtime < cutoff:
                old.unlink()
        except OSError:
            pass

    return path
