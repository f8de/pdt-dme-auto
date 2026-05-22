# pdt-dme-auto

DMEworks automation — Allied Medical Health.

## Deploy

1. Copy this folder to the target machine
2. Double-click `run.bat`

That's it. `run.bat` checks for Python and installs it via winget if missing, then launches the menu.

## First run

Before running `Full entry`, verify in DMEworks that all four Medicare DMERC companies exist:
- Medicare Region A DMERC
- Medicare Region B DMERC
- Medicare Region C DMERC
- Medicare Region D DMERC

These must be created manually. The script will error and tell you if any are missing.

## Adding patients or doctors

Edit the CSV files in `data/` — no code changes needed.

| File | Purpose |
|------|---------|
| `data/patients.csv` | Patients to enter |
| `data/doctors.csv` | Doctors to enter |
| `data/insurance_companies.csv` | Insurance companies to verify/create |
| `data/medicare_jurisdictions.csv` | State → Medicare DMERC mapping |

## Structure

```
run.bat                  ← entry point (double-click)
run.ps1                  ← Python installer + launcher
run.py                   ← menu
entry_all.py             ← enters all patients
entry_test.py            ← synthetic test record
data/                    ← all input data (CSV)
utils/                   ← shared loader + DMEworks mapping tools
requirements.txt         ← pip dependencies
```
