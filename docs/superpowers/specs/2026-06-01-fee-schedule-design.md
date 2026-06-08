# Fee Schedule Module — Design Spec
**Date:** 2026-06-01  
**Status:** Approved

---

## Problem

DMEworks inventory entry requires two price fields per HCPCS code per patient:
- **Allowable Price** — the current Medicare allowable for that code in that patient's state
- **Billable Price** — 2× the allowable (standard practice)

Medicare DMEPOS allowables are published quarterly by CMS and vary by state. Wrong amounts on Medicare claims are a compliance problem. Rates must be accurate at the time of DMEworks entry.

---

## Solution

**Source of truth: CMS DMEPOS fee schedule files.**  
The four DME MACs (Noridian JA/JD, CGS JB/JC) display these exact rates through lookup tools — but CMS is the authoritative origin. CMS publishes the full fee schedule as a downloadable ZIP (pipe-delimited text) updated quarterly. We download and parse it at startup; no external caching, no browser automation.

---

## Scope

### In scope
1. `fee_schedule.py` — CMS download, parse, and lookup module
2. `utils/notion.py` — add `hcpcs` field to `_parse_patient()` (pipe-separated, same pattern as ICD-10)
3. `entry_all.py` — load fee schedule at startup; plumb `FEE_SCHEDULE` dict through `main()`
4. Notion documentation page — "DME Auto — App Reference" root page created via Notion API

### Out of scope (next session)
- `[4/4] INVENTORY` automation step entering prices into DMEworks (DMEworks inventory UI not yet mapped)

---

## Architecture

### `fee_schedule.py` (new, project root)

**Public interface:**
```python
def load_fee_schedule() -> dict[tuple[str, str], float]:
    """Download current CMS DMEPOS fee schedule ZIP, parse in memory.
    Returns {(hcpcs_upper, state_upper): allowable_amount}."""

def get_allowable(
    hcpcs_code: str,
    state: str,
    schedule: dict[tuple[str, str], float],
) -> tuple[float, float]:
    """Return (allowable, billable). Prompts for manual entry on miss or failure."""
```

**Startup flow:**
1. Derive current quarter from `datetime.now(timezone.utc)`:
   - Jan–Mar → `A`, Apr–Jun → `B`, Jul–Sep → `C`, Oct–Dec → `D`
   - Year → last two digits (2026 → `26`)
2. Construct CMS ZIP URL — pattern to verify on first implementation run
3. `requests.get()` the ZIP (stream, timeout=30s)
4. `zipfile.ZipFile` in memory → find the `.txt` data file
5. Parse pipe-delimited rows → `{(hcpcs, state): allowable}`
6. Return dict

**`get_allowable`:**
- Key lookup: `(hcpcs_code.upper(), state.upper())`
- Hit → return `(amount, round(amount * 2, 2))`
- Miss or any exception during load → `input()` prompt for manual amount, return `(manual, round(manual * 2, 2))`

**Dependencies:** none new — `requests` already in requirements.txt; `zipfile`, `csv`, `io` are stdlib.

**CMS file format (to verify during implementation):**
- ZIP contains a pipe-delimited `.txt` file
- Key columns: HCPCS code, state (2-letter), fee schedule amount
- Exact column positions confirmed during implementation step

---

### `utils/notion.py` — `_parse_patient()` addition

Add one field to the returned dict:
```python
hcpcs_raw = rt("HCPCS Codes")
hcpcs     = [c.strip() for c in hcpcs_raw.split("|") if c.strip()]
```

Return dict gains: `"hcpcs": hcpcs`

**Notion schema requirement:** Add a `HCPCS Codes` rich_text property to the Patients DB. Format: pipe-separated HCPCS codes (e.g. `L0457|L1833|L0631`). Done manually in Notion — not automated.

---

### `entry_all.py` — fee schedule integration

Two additions to `main()`:

**1. After validation passes, before DMEworks connects:**
```python
from fee_schedule import load_fee_schedule
FEE_SCHEDULE = load_fee_schedule()
```

**2. Module-level fallback** — if `load_fee_schedule()` fails entirely, `FEE_SCHEDULE = {}`. Individual `get_allowable()` calls will prompt manually for each miss.

The `FEE_SCHEDULE` dict is module-level so it's accessible to the future inventory step without threading concerns.

---

### Notion documentation page

A single Notion page created via the existing `utils/notion.py` `_request` helper:

**Page title:** `DME Auto — App Reference`  
**Parent:** workspace root (or a manually specified parent page ID in Doppler as `NOTION_DOCS_PARENT_ID`)

**Child sections (as toggle blocks or headings):**
- Overview — what the automation does, modes (run/test/audit/fix)
- Fee Schedule — data source (CMS), quarterly update cycle, how `get_allowable` works
- HCPCS Codes — the 19 codes we bill, Notion field format (`L0457|L1833|...`)
- States & Jurisdictions — state → MAC mapping table (JA/JB/JC/JD)
- HCPCS Codes by State — reference table: code × state → current allowable (populated from `FEE_SCHEDULE` at doc-create time)

**How to trigger:** `python fee_schedule.py --create-docs` CLI flag, or a separate `tools/create_notion_docs.py` script. Not wired into the main automation run.

---

## Data Flow

```
CMS.gov ZIP
    ↓ requests.get (startup, once)
fee_schedule.load_fee_schedule()
    ↓ {(hcpcs, state): allowable}
FEE_SCHEDULE dict (module-level in entry_all.py)
    ↓
[future] ensure_all_inventory(patient, FEE_SCHEDULE)
    → get_allowable("L0457", "NJ", FEE_SCHEDULE)
    → (412.50, 825.00)
    → enter into DMEworks inventory form
```

---

## Error Handling

| Failure | Behavior |
|---------|----------|
| CMS download times out / 4xx / 5xx | Log warning, `FEE_SCHEDULE = {}`, all lookups fall through to manual prompt |
| ZIP parse fails (unexpected format) | Same as above — log, fallback to manual |
| HCPCS + state not in file | `get_allowable` prompts: `"Enter allowable for L0457/NJ: "` |
| Manual entry non-numeric | Re-prompt until valid float |

---

## Testing

```bash
python fee_schedule.py          # standalone: prints allowables for test codes + states
python fee_schedule.py --live   # same but also prints billable and confirms against expected
```

Verify at minimum: L0457/NJ, L1833/NJ, L0457/OH, L0457/SC — live CMS data, printed to console.

---

## Open Items

1. **Exact CMS ZIP URL** — confirm on first implementation run. Expected pattern: `https://www.cms.gov/files/zip/dme{yy}{q}.zip` (e.g. `dme26b.zip` for Q2 2026). Fallback: scrape the CMS DMEPOS fee schedule index page for the current quarter link.
2. **Pipe-delimited column positions** — confirm HCPCS column, state column, and which fee amount column to use (floor vs. ceiling vs. non-rural fee). Use non-rural fee schedule amount as the allowable.
3. **Notion parent** — workspace root (`{"type": "workspace", "workspace": true}`). Requires the Notion integration to have workspace-level access. If the current integration is page-scoped, update it in Notion Settings → Connections → the integration → grant workspace access before running the doc creation script.
