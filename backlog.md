# Backlog

## [verify] Insurance auto-correction via Payer ID

**Context:** `tools/verify_dmeworks.py` currently can only flag insurance companies as "not found" in DMEworks — no field-level diff, no UPDATE path. Matching is name-exact only, so minor name differences (e.g. "Aetna Inc" vs "Aetna") show as missing rather than a mismatch.

**Solution:** Match insurance companies on Payer ID (unique, stable identifier) instead of name. Then diff name + other fields and apply UPDATEs automatically.

**Prereq:** Confirm Notion insurance DB has a Payer ID field. If not, add it first.

**Files to change:**
- `utils/notion.py` — `fetch_all_insurance()` — include Payer ID in returned dict
- `tools/verify_dmeworks.py` — `_verify_insurance()` — match on Payer ID, diff name/address/phone, add `_UPDATE_INSURANCE` query
