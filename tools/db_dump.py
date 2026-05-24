"""
Dumps all audit query results to db_dump.txt.
Run: python tools/db_dump.py [--db c01|c02]
Default DB is c02 (production). Use --db c01 to inspect the test sandbox.
"""
import argparse
import csv
import io
import os
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from utils import db

_FROZEN = getattr(sys, "frozen", False)
_EXE_DIR = os.path.dirname(sys.executable) if _FROZEN else _ROOT
OUT = os.path.join(_EXE_DIR, "db_dump.txt")


def _build_queries(client_db: str) -> list[tuple[str, str]]:
    d = client_db  # "c01" or "c02"
    return [
        (f"Row counts ({d})", f"""
            SELECT 'tbl_customer' AS tbl, COUNT(*) AS rows FROM {d}.tbl_customer
            UNION ALL SELECT 'tbl_customer_insurance', COUNT(*) FROM {d}.tbl_customer_insurance
            UNION ALL SELECT 'tbl_customer_notes',     COUNT(*) FROM {d}.tbl_customer_notes
            UNION ALL SELECT 'dmeworks.tbl_doctor',    COUNT(*) FROM dmeworks.tbl_doctor
            UNION ALL SELECT 'dmeworks.tbl_insurancecompany', COUNT(*) FROM dmeworks.tbl_insurancecompany
        """),
        # Reference/lookup tables — verify hardcoded constants (POSTypeID=12, LastUpdateUserID=10)
        # and understand InsuranceType codes used in tbl_customer_insurance.
        ("tbl_postype — ALL rows", "SELECT * FROM tbl_postype ORDER BY ID"),
        ("tbl_insurancetype — ALL rows", "SELECT * FROM tbl_insurancetype ORDER BY Code"),
        ("tbl_user — ALL rows (no passwords)", "SELECT ID, Login, Email FROM tbl_user ORDER BY ID"),
        ("dmeworks.tbl_doctor — ALL rows ALL cols", "SELECT * FROM dmeworks.tbl_doctor ORDER BY ID"),
        ("dmeworks.tbl_insurancecompany — ALL rows ALL cols", "SELECT * FROM dmeworks.tbl_insurancecompany ORDER BY ID"),
        (f"{d}.tbl_customer — last 50 ALL cols", f"SELECT * FROM {d}.tbl_customer ORDER BY ID DESC LIMIT 50"),
        (f"{d}.tbl_customer_insurance — last 50 ALL cols", f"SELECT * FROM {d}.tbl_customer_insurance ORDER BY ID DESC LIMIT 50"),
        (f"{d}.tbl_customer_notes — ALL rows ALL cols", f"SELECT * FROM {d}.tbl_customer_notes ORDER BY ID DESC"),
        (f"NULL/empty — {d}.tbl_customer", f"""
            SELECT
                SUM(AccountNumber  IS NULL OR TRIM(AccountNumber)  = '') AS AccountNumber_empty,
                SUM(FirstName      IS NULL OR TRIM(FirstName)      = '') AS FirstName_empty,
                SUM(LastName       IS NULL OR TRIM(LastName)       = '') AS LastName_empty,
                SUM(MiddleName     IS NULL OR TRIM(MiddleName)     = '') AS MiddleName_empty,
                SUM(Suffix         IS NULL OR TRIM(Suffix)         = '') AS Suffix_empty,
                SUM(DateofBirth    IS NULL)                              AS DateofBirth_null,
                SUM(Address1       IS NULL OR TRIM(Address1)       = '') AS Address1_empty,
                SUM(City           IS NULL OR TRIM(City)           = '') AS City_empty,
                SUM(State          IS NULL OR TRIM(State)          = '') AS State_empty,
                SUM(Zip            IS NULL OR TRIM(Zip)            = '') AS Zip_empty,
                SUM(Phone          IS NULL OR TRIM(Phone)          = '') AS Phone_empty,
                SUM(Email          IS NULL OR TRIM(Email)          = '') AS Email_empty,
                SUM(Gender         IS NULL OR TRIM(Gender)         = '') AS Gender_empty,
                SUM(Height         IS NULL)                              AS Height_null,
                SUM(Weight         IS NULL)                              AS Weight_null,
                SUM(Doctor1_ID     IS NULL)                              AS Doctor1_ID_null,
                SUM(ICD10_01       IS NULL OR TRIM(ICD10_01)       = '') AS ICD10_01_empty,
                SUM(ICD10_02       IS NULL OR TRIM(ICD10_02)       = '') AS ICD10_02_empty,
                SUM(POSTypeID      IS NULL)                              AS POSTypeID_null,
                SUM(AccidentType   IS NULL OR TRIM(AccidentType)   = '') AS AccidentType_empty,
                SUM(SetupDate      IS NULL)                              AS SetupDate_null,
                COUNT(*) AS total_rows
            FROM {d}.tbl_customer
        """),
        (f"NULL/empty — {d}.tbl_customer_insurance", f"""
            SELECT
                SUM(PolicyNumber     IS NULL OR TRIM(PolicyNumber)     = '') AS PolicyNumber_empty,
                SUM(InsuranceType    IS NULL OR TRIM(InsuranceType)    = '') AS InsuranceType_empty,
                SUM(Rank             IS NULL)                                AS Rank_null,
                SUM(RelationshipCode IS NULL OR TRIM(RelationshipCode) = '') AS RelationshipCode_empty,
                SUM(GroupNumber      IS NULL OR TRIM(GroupNumber)      = '') AS GroupNumber_empty,
                SUM(FirstName        IS NULL OR TRIM(FirstName)        = '') AS FirstName_empty,
                SUM(LastName         IS NULL OR TRIM(LastName)         = '') AS LastName_empty,
                SUM(DateofBirth      IS NULL)                                AS DateofBirth_null,
                SUM(Gender           IS NULL OR TRIM(Gender)           = '') AS Gender_empty,
                SUM(InactiveDate     IS NULL)                                AS InactiveDate_null,
                COUNT(*) AS total_rows
            FROM {d}.tbl_customer_insurance
        """),
        ("NULL/empty — dmeworks.tbl_doctor", """
            SELECT
                SUM(NPI           IS NULL OR TRIM(NPI)           = '') AS NPI_empty,
                SUM(Phone         IS NULL OR TRIM(Phone)         = '') AS Phone_empty,
                SUM(Fax           IS NULL OR TRIM(Fax)           = '') AS Fax_empty,
                SUM(Address1      IS NULL OR TRIM(Address1)      = '') AS Address1_empty,
                SUM(LicenseNumber IS NULL OR TRIM(LicenseNumber) = '') AS LicenseNumber_empty,
                SUM(DEANumber     IS NULL OR TRIM(DEANumber)     = '') AS DEANumber_empty,
                SUM(FEDTaxID      IS NULL OR TRIM(FEDTaxID)      = '') AS FEDTaxID_empty,
                SUM(Phone2        IS NULL OR TRIM(Phone2)        = '') AS Phone2_empty,
                COUNT(*) AS total_rows
            FROM dmeworks.tbl_doctor
        """),
        (f"Full join — patient + doctor + insurance ({d})", f"""
            SELECT
                c.ID, c.AccountNumber, c.FirstName, c.LastName, c.MiddleName, c.Suffix,
                c.DateofBirth, c.Gender, c.Height, c.Weight,
                c.Address1, c.Address2, c.City, c.State, c.Zip, c.Phone, c.Email,
                c.Doctor1_ID, d.NPI AS doc_npi, d.FirstName AS doc_first, d.LastName AS doc_last,
                c.ICD10_01, c.ICD10_02, c.ICD10_03, c.ICD10_04,
                c.ICD10_05, c.ICD10_06, c.ICD10_07, c.ICD10_08,
                c.ICD10_09, c.ICD10_10, c.ICD10_11, c.ICD10_12,
                c.POSTypeID, p.Name AS pos_name, c.AccidentType, c.SetupDate,
                ci.PolicyNumber AS mbi, ci.InsuranceType, ci.Rank, ic.Name AS ins_name,
                ci.FirstName AS ins_first, ci.LastName AS ins_last,
                ci.DateofBirth AS ins_dob, ci.Gender AS ins_gender,
                ci.InactiveDate AS ins_inactive
            FROM {d}.tbl_customer c
            LEFT JOIN dmeworks.tbl_doctor d ON d.ID = c.Doctor1_ID
            LEFT JOIN {d}.tbl_customer_insurance ci ON ci.CustomerID = c.ID AND ci.Rank = 1 AND ci.InactiveDate IS NULL
            LEFT JOIN dmeworks.tbl_insurancecompany ic ON ic.ID = ci.InsuranceCompanyID
            LEFT JOIN {d}.tbl_postype p ON p.ID = c.POSTypeID
            ORDER BY c.ID DESC LIMIT 50
        """),
        (f"Secondary insurance (Rank=2) — {d}", f"""
            SELECT ci.*, ic.Name AS ins_name
            FROM {d}.tbl_customer_insurance ci
            LEFT JOIN dmeworks.tbl_insurancecompany ic ON ic.ID = ci.InsuranceCompanyID
            WHERE ci.Rank = 2 ORDER BY ci.ID DESC
        """),
        (f"Patients with NULL Doctor1_ID — {d}", f"""
            SELECT ID, AccountNumber, FirstName, LastName, SetupDate
            FROM {d}.tbl_customer WHERE Doctor1_ID IS NULL ORDER BY ID DESC
        """),
    ]


def rows_to_text(title: str, rows: list[dict]) -> str:
    buf = io.StringIO()
    buf.write(f"\n{'=' * 70}\n{title}\n{'=' * 70}\n")
    if not rows:
        buf.write("(no rows)\n")
        return buf.getvalue()
    writer = csv.DictWriter(buf, fieldnames=rows[0].keys())
    writer.writeheader()
    writer.writerows(rows)
    return buf.getvalue()


def main() -> None:
    parser = argparse.ArgumentParser(description="Dump DMEworks audit queries to db_dump.txt")
    parser.add_argument("--db", default="c02", choices=["c01", "c02"],
                        help="Database to query (default: c02 production)")
    args = parser.parse_args()

    db.configure(args.db)
    import mysql.connector
    conn = mysql.connector.connect(**db._conn_params)

    queries = _build_queries(args.db)
    output = []
    try:
        for title, sql in queries:
            cur = conn.cursor(dictionary=True)
            cur.execute(sql.strip())
            rows = cur.fetchall()
            block = rows_to_text(title, rows)
            output.append(block)
            print(block)
    finally:
        conn.close()

    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(output))

    print(f"\n{'=' * 70}")
    print(f"Done. Full output saved to:")
    print(f"  {OUT}")
    print(f"{'=' * 70}")
    try:
        input("\nPress Enter to close...")
    except (EOFError, KeyboardInterrupt):
        pass


if __name__ == "__main__":
    main()
