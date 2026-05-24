-- ============================================================
-- DMEworks Full DB Audit — run in Workbench / DBeaver / TablePlus
-- Paste ALL result sets back for analysis.
-- ============================================================


-- ── 1. ROW COUNTS ───────────────────────────────────────────
SELECT 'c02.tbl_customer'           AS tbl, COUNT(*) AS rows FROM c02.tbl_customer
UNION ALL SELECT 'c02.tbl_customer_insurance',  COUNT(*) FROM c02.tbl_customer_insurance
UNION ALL SELECT 'c02.tbl_customer_notes',      COUNT(*) FROM c02.tbl_customer_notes
UNION ALL SELECT 'dmeworks.tbl_doctor',         COUNT(*) FROM dmeworks.tbl_doctor
UNION ALL SELECT 'dmeworks.tbl_insurancecompany', COUNT(*) FROM dmeworks.tbl_insurancecompany;


-- ── 2. ALL COLUMNS — dmeworks.tbl_doctor ────────────────────
SELECT * FROM dmeworks.tbl_doctor ORDER BY ID;


-- ── 3. ALL COLUMNS — dmeworks.tbl_insurancecompany ──────────
SELECT * FROM dmeworks.tbl_insurancecompany ORDER BY ID;


-- ── 4. ALL COLUMNS — c02.tbl_customer (last 20) ─────────────
SELECT * FROM c02.tbl_customer ORDER BY ID DESC LIMIT 20;


-- ── 5. ALL COLUMNS — c02.tbl_customer_insurance (last 20) ───
SELECT * FROM c02.tbl_customer_insurance ORDER BY ID DESC LIMIT 20;


-- ── 6. ALL COLUMNS — c02.tbl_customer_notes ─────────────────
SELECT * FROM c02.tbl_customer_notes ORDER BY ID DESC LIMIT 20;


-- ── 7. NULL/EMPTY ANALYSIS — tbl_customer (every col) ───────
SELECT
    SUM(AccountNumber  IS NULL OR TRIM(AccountNumber)  = '') AS AccountNumber_empty,
    SUM(FirstName      IS NULL OR TRIM(FirstName)      = '') AS FirstName_empty,
    SUM(LastName       IS NULL OR TRIM(LastName)       = '') AS LastName_empty,
    SUM(MiddleName     IS NULL OR TRIM(MiddleName)     = '') AS MiddleName_empty,
    SUM(Suffix         IS NULL OR TRIM(Suffix)         = '') AS Suffix_empty,
    SUM(DateofBirth    IS NULL)                              AS DateofBirth_null,
    SUM(Address1       IS NULL OR TRIM(Address1)       = '') AS Address1_empty,
    SUM(Address2       IS NULL OR TRIM(Address2)       = '') AS Address2_empty,
    SUM(City           IS NULL OR TRIM(City)           = '') AS City_empty,
    SUM(State          IS NULL OR TRIM(State)          = '') AS State_empty,
    SUM(Zip            IS NULL OR TRIM(Zip)            = '') AS Zip_empty,
    SUM(Phone          IS NULL OR TRIM(Phone)          = '') AS Phone_empty,
    SUM(Gender         IS NULL OR TRIM(Gender)         = '') AS Gender_empty,
    SUM(Height         IS NULL)                              AS Height_null,
    SUM(Weight         IS NULL)                              AS Weight_null,
    SUM(Doctor1_ID     IS NULL)                              AS Doctor1_ID_null,
    SUM(Doctor2_ID     IS NULL)                              AS Doctor2_ID_null,
    SUM(ICD10_01       IS NULL OR TRIM(ICD10_01)       = '') AS ICD10_01_empty,
    SUM(ICD10_02       IS NULL OR TRIM(ICD10_02)       = '') AS ICD10_02_empty,
    SUM(ICD10_03       IS NULL OR TRIM(ICD10_03)       = '') AS ICD10_03_empty,
    SUM(ICD10_04       IS NULL OR TRIM(ICD10_04)       = '') AS ICD10_04_empty,
    SUM(Email          IS NULL OR TRIM(Email)          = '') AS Email_empty,
    SUM(BillingTypeID  IS NULL)                              AS BillingTypeID_null,
    SUM(POSTypeID      IS NULL)                              AS POSTypeID_null,
    SUM(SetupDate      IS NULL)                              AS SetupDate_null,
    COUNT(*) AS total_rows
FROM c02.tbl_customer;


-- ── 8. NULL/EMPTY ANALYSIS — tbl_customer_insurance ─────────
SELECT
    SUM(CustomerID        IS NULL)                                 AS CustomerID_null,
    SUM(InsuranceCompanyID IS NULL)                                AS InsuranceCompanyID_null,
    SUM(InsuranceType     IS NULL OR TRIM(InsuranceType)     = '') AS InsuranceType_empty,
    SUM(PolicyNumber      IS NULL OR TRIM(PolicyNumber)      = '') AS PolicyNumber_empty,
    SUM(Rank              IS NULL)                                 AS Rank_null,
    SUM(RelationshipCode  IS NULL OR TRIM(RelationshipCode)  = '') AS RelationshipCode_empty,
    SUM(GroupNumber       IS NULL OR TRIM(GroupNumber)       = '') AS GroupNumber_empty,
    SUM(FirstName         IS NULL OR TRIM(FirstName)         = '') AS FirstName_empty,
    SUM(LastName          IS NULL OR TRIM(LastName)          = '') AS LastName_empty,
    SUM(DateofBirth       IS NULL)                                 AS DateofBirth_null,
    SUM(Gender            IS NULL OR TRIM(Gender)            = '') AS Gender_empty,
    SUM(InactiveDate      IS NULL)                                 AS InactiveDate_null,
    COUNT(*) AS total_rows
FROM c02.tbl_customer_insurance;


-- ── 9. NULL/EMPTY ANALYSIS — dmeworks.tbl_doctor ────────────
SELECT
    SUM(NPI           IS NULL OR TRIM(NPI)           = '') AS NPI_empty,
    SUM(FirstName     IS NULL OR TRIM(FirstName)     = '') AS FirstName_empty,
    SUM(LastName      IS NULL OR TRIM(LastName)      = '') AS LastName_empty,
    SUM(Phone         IS NULL OR TRIM(Phone)         = '') AS Phone_empty,
    SUM(Phone2        IS NULL OR TRIM(Phone2)        = '') AS Phone2_empty,
    SUM(Fax           IS NULL OR TRIM(Fax)           = '') AS Fax_empty,
    SUM(Address1      IS NULL OR TRIM(Address1)      = '') AS Address1_empty,
    SUM(City          IS NULL OR TRIM(City)          = '') AS City_empty,
    SUM(State         IS NULL OR TRIM(State)         = '') AS State_empty,
    SUM(LicenseNumber IS NULL OR TRIM(LicenseNumber) = '') AS LicenseNumber_empty,
    SUM(DEANumber     IS NULL OR TRIM(DEANumber)     = '') AS DEANumber_empty,
    SUM(FEDTaxID      IS NULL OR TRIM(FEDTaxID)      = '') AS FEDTaxID_empty,
    SUM(UPINNumber    IS NULL OR TRIM(UPINNumber)    = '') AS UPINNumber_empty,
    COUNT(*) AS total_rows
FROM dmeworks.tbl_doctor;


-- ── 10. FULL JOIN — every patient with doctor + primary ins ─
SELECT
    c.ID              AS customer_id,
    c.AccountNumber,
    c.FirstName, c.LastName, c.MiddleName, c.Suffix,
    c.DateofBirth, c.Gender, c.Height, c.Weight,
    c.Address1, c.Address2, c.City, c.State, c.Zip, c.Phone,
    c.Email,
    c.Doctor1_ID,
    d.NPI             AS doctor_npi,
    d.FirstName       AS doc_first,
    d.LastName        AS doc_last,
    c.ICD10_01, c.ICD10_02, c.ICD10_03, c.ICD10_04,
    c.ICD10_05, c.ICD10_06, c.ICD10_07, c.ICD10_08,
    c.ICD10_09, c.ICD10_10, c.ICD10_11, c.ICD10_12,
    c.POSTypeID, c.AccidentType, c.SetupDate,
    ci.PolicyNumber   AS mbi,
    ci.InsuranceType  AS ins_type,
    ci.Rank           AS ins_rank,
    ic.Name           AS ins_name,
    ci.InactiveDate   AS ins_inactive
FROM c02.tbl_customer c
LEFT JOIN dmeworks.tbl_doctor d
       ON d.ID = c.Doctor1_ID
LEFT JOIN c02.tbl_customer_insurance ci
       ON ci.CustomerID = c.ID AND ci.Rank = 1 AND ci.InactiveDate IS NULL
LEFT JOIN dmeworks.tbl_insurancecompany ic
       ON ic.ID = ci.InsuranceCompanyID
ORDER BY c.ID DESC
LIMIT 30;


-- ── 11. SECONDARY INSURANCE rows ────────────────────────────
SELECT
    ci.*,
    ic.Name AS ins_name
FROM c02.tbl_customer_insurance ci
LEFT JOIN dmeworks.tbl_insurancecompany ic ON ic.ID = ci.InsuranceCompanyID
WHERE ci.Rank = 2
ORDER BY ci.ID DESC;


-- ── 12. PATIENTS WITH NULL Doctor1_ID ───────────────────────
SELECT ID, AccountNumber, FirstName, LastName, SetupDate
FROM c02.tbl_customer
WHERE Doctor1_ID IS NULL
ORDER BY ID DESC;


-- ── 13. COLUMN LIST for each table (schema map) ─────────────
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'c02'
  AND TABLE_NAME IN ('tbl_customer','tbl_customer_insurance','tbl_customer_notes')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dmeworks'
  AND TABLE_NAME IN ('tbl_doctor','tbl_insurancecompany')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
