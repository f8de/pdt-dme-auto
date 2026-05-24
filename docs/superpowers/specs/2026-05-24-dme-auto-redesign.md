# DME Auto — Full Redesign Spec
**Date:** 2026-05-24  
**Scope:** Replace pywinauto UI entry with direct MySQL writes. Fix all known bugs. Harden for production.

---

## 1. Problem Summary

Current system (`entry_all.py`) enters patient data by automating the DMEworks Windows UI via pywinauto. This approach has:
- Zero transactional safety (partial entries leave corrupt state)
- Timing-dependent fragility (popup handling, combo box races)
- A crash bug on every real run (`ARGS.client` undefined)
- No audit trail (log overwritten each run)
- Duplicate utility code between `entry_all.py` and `entry_test.py`
- Incomplete post-entry verification (no ICD10 check, no insurance field check)

---

## 2. Solution

Replace UI-based entry with direct MySQL writes inside transactions. Verification becomes a pure DB query pass. pywinauto is retained only for diagnostic tools.

---

## 3. Database Architecture (confirmed from schema dumps)

### Schema layout
| Schema | Type | Contains |
|---|---|---|
| `dmeworks` | Real tables | Shared reference data: doctors, insurance companies, ICD codes |
| `c02` | Mix | Real tables: customers, orders, billing. Views: point to `dmeworks` for shared data |
| `c01` | Mix | Same structure as `c02` — test client |

### Write targets
| Entity | Target table | Notes |
|---|---|---|
| Doctor | `dmeworks.tbl_doctor` | Shared across all clients |
| Insurance company | `dmeworks.tbl_insurancecompany` | Shared |
| Customer | `c02.tbl_customer` | Per-client |
| Customer insurance | `c02.tbl_customer_insurance` | Per-client |

Single MySQL connection to `c02` handles all writes — cross-database `dmeworks.*` writes work from that session.

### Key confirmed values
- `POSTypeID = 12` on all existing customers — hardcode on insert
- `AccidentType` has no default — hardcode `'No'`
- `DeliveryDirections`, `EmergencyContact` have no default — hardcode `''`
- `InvoiceFormID` defaults to `4`
- `AccountNumber` is UNIQUE, `SystemGenerate_CustomerAccountNumbers = 1` — generate as `MAX(CAST(AccountNumber AS UNSIGNED)) + 1` inside transaction with `FOR UPDATE` lock
- `LastUpdateUserID = 10` (adminbiller)
- `RelationshipCode = '18'` (self, CMS standard)
- `Gender` enum('Male','Female') NOT NULL DEFAULT 'Male' — write from Notion `Gender` select field
- `Height` double DEFAULT NULL — write from Notion `Height` text field (parsed as float, inches)
- `Weight` double DEFAULT NULL — write from Notion `Weight` text field (parsed as float, lbs)
- `Waist Size` — stored in Notion only, no tbl_customer column; do not write to DB
- All MySQL connections use `charset='latin1'` — tables are latin1, connector must match to avoid encoding corruption on accented names

### Insurance type code mapping
| Notion `ins_type` | DB `InsuranceType` |
|---|---|
| `MEDICARE` | `MP` |
| `MEDICAID` | `OT` |
| `MEDIGAP` | `LT` |
| `SUPPLEMENTAL` | `SP` |
| `COMMERCIAL_GROUP` | `GP` |
| `COMMERCIAL_INDIVIDUAL` | `IP` |

Notion `ins_type` field must use these exact keys going forward.

### MIR stored procedures
After inserting a doctor: `CALL dmeworks.mir_update_doctor(@new_id)`  
After inserting an insurance company: `CALL dmeworks.mir_update_insurancecompany(@new_id)`  
These set the MIR (Missing Information Record) field correctly.

---

## 4. Run Mode Design

**Dry-run is always the default. Live writes require explicit `--live` flag.**

```
python ingest.py           # dry-run — shows what would be written, zero DB changes
python ingest.py --live    # real writes, backup runs first, then commits
```

Launcher enforces this: entry option defaults to dry-run. Separate prompt required to dispatch `--live`.

---

## 5. Run Flow

```
1. BACKUP (--live only)
   mysqldump c02 + dmeworks → deploy/backups/backup_YYYYMMDD_HHMMSS.sql
   Purge backups older than 7 days
   Abort if backup fails

2. FETCH
   Notion work queue (Status = "To Enter in DMEworks")
   Fetch insurance map (state → DMERC name)

3. VALIDATE (all patients before any write)
   - MBI present and 11 chars alphanumeric
   - DOB present, format MM/DD/YYYY
   - State present, in insurance map
   - Doctor linked and has NPI
   - ICD10 codes exist in dmeworks.tbl_icd10 (DB lookup)
   - Secondary insurance JSON has required keys: ins_company, ins_type, policy
   - ins_type values are valid codes from mapping table
   Abort entire run if any validation error

4. DB EXISTENCE CHECKS (parallel)
   - fetch_matching_npis() → dmeworks.tbl_doctor
   - fetch_matching_insurance_names() → dmeworks.tbl_insurancecompany
   - fetch_matching_mbis() → c02.tbl_customer_insurance

5. INSERT DOCTORS (sequential, one connection per insert)
   For each new doctor:
   - INSERT INTO dmeworks.tbl_doctor (all NOT NULL fields, '' for optional)
   - CALL dmeworks.mir_update_doctor(LAST_INSERT_ID())
   Dry-run: log SQL, skip execute

6. INSERT INSURANCE COMPANIES (sequential)
   For each new non-Medicare company:
   - INSERT INTO dmeworks.tbl_insurancecompany (Name, LastUpdateUserID, LastUpdateDatetime)
   - CALL dmeworks.mir_update_insurancecompany(LAST_INSERT_ID())
   Medicare companies: verify exist, error if missing (manual DMEworks setup required)
   Dry-run: log SQL, skip execute

7. INSERT PATIENTS (sequential, one transaction per patient)
   BEGIN TRANSACTION
   - SELECT MAX(CAST(AccountNumber AS UNSIGNED)) + 1 FROM c02.tbl_customer FOR UPDATE
   - SELECT ID FROM dmeworks.tbl_doctor WHERE NPI = %s
   - SELECT ID FROM dmeworks.tbl_insurancecompany WHERE LOWER(Name) = LOWER(%s)
   - INSERT INTO c02.tbl_customer (AccountNumber, FirstName, LastName, MiddleName,
       Suffix, DateofBirth, Address1, Address2, City, State, Zip, Phone,
       Doctor1_ID, POSTypeID=12, AccidentType='No', DeliveryDirections='',
       EmergencyContact='', ICD10_01..12, Gender, Height, Weight,
       SetupDate=today, LastUpdateUserID=10, LastUpdateDatetime=NOW())
   - INSERT INTO c02.tbl_customer_insurance (CustomerID, InsuranceCompanyID,
       InsuranceType='MP', PolicyNumber=MBI, Rank=1, RelationshipCode='18',
       LastUpdateUserID=10)
   - If secondary: INSERT INTO c02.tbl_customer_insurance (..., Rank=2)
   - CALL c02.mir_update_customer(customer_id)
   - CALL c02.mir_update_customer_insurance(customer_id)
   COMMIT
   On error: ROLLBACK, log, continue to next patient
   After commit: mark Notion page → 'In DMEworks'
   Dry-run: log SQL, skip execute + commit

8. VERIFICATION PASS (always runs, even after dry-run)
   Re-query all processed patients from DB
   Field-level comparison vs Notion source:
   - FirstName, LastName, MiddleName, Suffix
   - DateofBirth
   - Address1, Address2, City, State, Zip, Phone
   - Gender, Height, Weight
   - Doctor1_ID (NPI match)
   - ICD10_01..12 (all codes present)
   - Primary insurance: InsuranceCompanyID, InsuranceType, PolicyNumber (MBI)
   - Secondary insurance if applicable
   Log PASS / FAIL per patient
   Exit non-zero if any FAIL
```

---

## 6. Files

### New / replaced
| File | Action | Purpose |
|---|---|---|
| `ingest.py` | New | Replaces `entry_all.py` — pure DB write entry |
| `ingest_test.py` | New | Replaces `entry_test.py` — test client dry-run |
| `utils/ui.py` | New | Shared pywinauto utilities (extracted from both entry files) |
| `utils/db.py` | Rewrite | Add insert functions, backup, ICD10 validation, full verify |
| `utils/notion.py` | Update | Fix `_fetch_doctor` MI/suffix, add `fetch_db_config` |
| `utils/logger.py` | Update | Rotating daily log files, keep 30 days |
| `run.py` | Update | Wire `--live` flag, backup prompt, client default |
| `config/clients.json` | New | Client code → display name + DB mapping |

### Removed
| File | Reason |
|---|---|
| `entry_all.py` | Replaced by `ingest.py` |
| `entry_test.py` | Replaced by `ingest_test.py` |

### Kept unchanged
| File | Notes |
|---|---|
| `tools/verify_dmeworks.py` | Enhanced: add ICD10 + insurance field verification |
| `tools/dmeworks_grid_probe.py` | Unchanged |
| `tools/map_policy_dialog.py` | Unchanged |
| `tools/map_insurance_company_tabs.py` | Unchanged |
| `packaging/dmeworks.spec` | Minor: swap entry_all/entry_test → ingest/ingest_test |

---

## 7. Bug Fixes Included

| # | Bug | Fix |
|---|---|---|
| 1 | `ARGS.client` crash | `--client` arg added, default `allied` |
| 2 | `fetch_db_config` tests fail | Remove dead tests or add function |
| 3 | ICD10 never verified | Verification pass checks `ICD10_01..12` columns |
| 4 | Doctor assignment fragile | Moot — direct DB write uses NPI lookup |
| 5 | Secondary insurance not validated | Step 3 validates JSON schema before any write |
| 6 | Doctor MI/suffix not parsed | `_fetch_doctor` updated to parse both fields |
| 7 | Insurance name case sensitivity | All lookups use `LOWER()` on both sides |
| 8 | `verify_patients` missing Rank=1 | Added `AND Rank = 1 AND InactiveDate IS NULL` |
| 9 | Log overwrite | Rotating daily log files, 30-day retention |
| 10 | Multi-client hardcoded | `--client` flag + `clients.json` config |
| 11 | Code duplication | Shared utilities in `utils/ui.py` |
| 12 | Build packaging mismatch | `build.py` `package()` copies all deploy files |
| 13 | Artifact directory | Delete `D:Repospdtpdt-dme-autoconfig` |
| 14 | MIR not updated for customer | Call `c02.mir_update_customer(id)` + `c02.mir_update_customer_insurance(id)` inside patient transaction after all INSERTs |
| 15 | charset mismatch | Add `charset='latin1'` to `build_config()` — tables are latin1, connector must match to avoid garbling accented names |
| 16 | Gender never written | Fetch `Gender` select from Notion, write to `tbl_customer.Gender`; validated as 'Male' or 'Female' |
| 17 | ICD10 InactiveDate not checked | Add `AND (InactiveDate IS NULL OR InactiveDate > CURDATE())` to ICD10 validation query — prevents writing retired codes |
| 18 | Height/Weight not written | Fetch `Height`, `Weight` text from Notion, parse as float, write to `tbl_customer.Height`/`Weight` |

---

## 8. Validation Rules (Step 3 detail)

```python
# MBI: 11 chars, format N-A-AN-N-A-AN-AN-A-A-N-N
# Positions 3, 6, 7 are alphanumeric; 8, 9 are alpha; 10, 11 are numeric
# Excluded letters at all alpha positions: B, I, L, O, S, Z (visually ambiguous)
MBI_RE = re.compile(r'^[1-9][AC-HJ-NP-RT-Y][0-9AC-HJ-NP-RT-Y][0-9][AC-HJ-NP-RT-Y][0-9AC-HJ-NP-RT-Y][0-9AC-HJ-NP-RT-Y][AC-HJ-NP-RT-Y][AC-HJ-NP-RT-Y][0-9][0-9]$')

# DOB: MM/DD/YYYY
datetime.strptime(dob, "%m/%d/%Y")

# State: must be in insurance map
assert state in INSURANCE_BY_STATE

# ICD10: must exist in dmeworks.tbl_icd10, not a header code, and not retired
SELECT Code FROM dmeworks.tbl_icd10
WHERE Code IN (%s) AND Header = 0
  AND (InactiveDate IS NULL OR InactiveDate > CURDATE())

# Secondary insurance JSON required keys
{"ins_company": str, "ins_type": str (valid code), "policy": str}

# Gender: required, must be Male or Female
assert patient["gender"] in {"Male", "Female"}

# Height/Weight: optional floats — parse from Notion text, None if blank
height = float(patient["height"]) if patient["height"] else None
weight = float(patient["weight"]) if patient["weight"] else None

# ins_type valid codes
VALID_INS_TYPES = {"MEDICARE", "MEDICAID", "MEDIGAP", "SUPPLEMENTAL",
                   "COMMERCIAL_GROUP", "COMMERCIAL_INDIVIDUAL"}
```

---

## 9. Logger Change

```python
# Current (broken):
FileHandler(log_file, mode="w")  # overwrites every run

# New:
log_file = log_dir / f"dme-auto-{datetime.now():%Y-%m-%d}.log"
FileHandler(log_file, mode="a")  # append, daily rotation
# startup: delete logs older than 30 days
```

---

## 10. Safety Constraints

- No UPDATE or DELETE statements anywhere in ingest path
- Dry-run is default — `--live` required for real writes
- Backup runs and succeeds before any `--live` write
- Each patient is an independent transaction — one failure does not block others
- Notion status update happens only after successful COMMIT
- Verification pass runs after every `--live` run and reports any FAIL

---

## 11. Out of Scope

- Multi-client UI selection (future — foundation is in place via `--client` flag)
- Insurance auto-correction via Payer ID (existing backlog item)
- Orders, invoices, billing — not touched
