# DMEworks Entry v2 — Notion-Sourced Single EXE

**Date:** 2026-05-22  
**Status:** Approved

---

## Problem

Current system requires local `clients.enc` SQLite file with patient data on every machine.
Goal: zero patient data on Allied machine — Notion is the single source of truth.

---

## Architecture

```
Windows Credential Manager (DPAPI-backed, machine-bound)
  ├── dmeworks-entry / notion-token        → Notion API key
  └── dmeworks-entry / db-{client}         → JSON: host, user, pass, db

Notion (cloud)
  ├── Patient Tracker  (collection://44132bb6-93ca-40d3-bd58-75c6351854fa)
  │     Status = "To Enter in DMEworks"  → work queue
  │     Status = "In DMEworks"           → completed
  └── Doctors          (collection://d1fc2566-ddd3-4640-8fc1-a1b5fc8da7a2)
        NPI, address fields

dmeworks-entry.exe  (Allied machine — no Python, no local patient data)
  ├── --setup           first-run credential storage
  ├── --client <code>   run entry loop
  └── --dry-run         log only, no DMEworks writes
```

---

## Components

| File | Role |
|------|------|
| `utils/creds.py` | keyring get/set for Notion token + DB creds per client |
| `utils/notion.py` | Notion API: fetch patients, resolve doctor, update status |
| `utils/db.py` | MySQL bulk MBI check + post-entry verify (unchanged interface) |
| `entry_all.py` | main loop — orchestrates fetch → check → enter → update |
| `entry_setup.py` | `--setup` interactive first-run credential wizard |
| `assets/reference.db` | DMERC Medicare map — bundled in EXE, no PHI, no secrets |

---

## Credential Security

- All secrets stored **only** in Windows Credential Manager via `keyring`
- DPAPI-backed: machine-bound, encrypted at OS level, survives reboot
- Never written to disk, never in `.env`, never hardcoded
- `utils/creds.py` is the single access point — no direct keyring calls elsewhere
- Notion token service: `dmeworks-entry`, account: `notion-token`
- DB creds service: `dmeworks-entry`, account: `db-{client_code}`, value: JSON blob
- `clients.enc` still used for DB credentials only (backward compat); Credential Manager preferred

---

## Data Flow

```
1. creds.py      → load Notion token + DB creds from Credential Manager
2. notion.py     → GET patients where Status = "To Enter in DMEworks"
                   GET doctor NPI/address via relation on each patient
3. db.py         → bulk MBI check: skip already-entered patients
4. pywinauto     → connect DMEworks (must be open)
5. per patient:
     a. entry_all.py  → fill form fields
     b. db.py         → verify row inserted
     c. notion.py     → PATCH Status → "In DMEworks"
6. logger.py     → summary (MBI masked, DOB masked, ICD count only)
```

---

## Notion Field Mapping

| Notion field | DMEworks field | Notes |
|---|---|---|
| First Name | First name | New field |
| MI | Middle initial | New field |
| Last Name | Last name | New field |
| Suffix | Suffix | New field |
| DOB | Date of birth | DATE type |
| MBI | Medicare ID | uniqueness key |
| Address / City / State / ZIP | Address | |
| Phone | Phone | |
| Doctor → NPI | Prescribing doctor NPI | via relation |
| Doctor → First/Last Name | Prescribing doctor name | via relation |
| ICD10 Codes | Diagnosis codes | pipe-separated string |
| Braces | Item type | BB or BKB |
| L-Codes | HCPCS codes | |
| Height / Weight / Waist Size | Measurements | |

---

## Setup Flow (`--setup`)

Runs once on Allied machine before first use:

```
> dmeworks-entry.exe --setup
Notion API token: ****
Client code (e.g. ALLIED): ALLIED
MySQL host: 192.168.x.x
MySQL user: dmeworks
MySQL password: ****
MySQL database: dmeworks
[OK] Credentials stored in Windows Credential Manager
```

---

## PHI Handling

- No patient data written to disk at any point
- Logs: MBI → `1EG4-***-****`, DOB → `**/**/****`, ICD → count only
- Notion is PHI-bearing; access controlled by Notion workspace permissions
- EXE bundles only `reference.db` (Medicare DMERC map — no PHI)

---

## Out of Scope

- Multi-client Notion filtering (add "Client" field to Patient Tracker later)
- Automatic DMEworks launch
- Order creation / billing automation
- `dmeworks-manage.exe` for client management on Allied machine
