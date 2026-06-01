"""
Create the "DME Auto — App Reference" page at Notion workspace root.
Run once manually; creates a new page each time (no idempotency check).

Usage:
    python tools/create_notion_docs.py
"""

import os
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from datetime import datetime, timezone
from utils.notion import _BASE, _NOTION_VERSION, _request
from utils.creds import get_notion_token
from fee_schedule import load_fee_schedule, _current_quarter

_HCPCS_CODES = [
    "L0457", "L1833", "L0631", "L0637", "L0648", "L0650",
    "L1832", "L1843", "L1845", "L1851", "L1852", "L2397",
    "L3760", "L3761", "L3915", "L3916", "L3960", "L1971", "A4239",
]

_STATES = ["NJ", "NY", "OH", "IL", "SC"]

_JURISDICTIONS = {
    "JA (Noridian)": "CT, DE, DC, ME, MD, MA, NH, NJ, NY, PA, RI, VT",
    "JB (CGS)":      "IL, IN, KY, MI, MN, OH, WI",
    "JC (CGS)":      "AL, AR, CO, FL, GA, LA, MS, NM, NC, OK, PR, SC, TN, TX, VA, WV, VI",
    "JD (Noridian)": "AK, AS, AZ, CA, GU, HI, ID, MT, ND, NV, OR, SD, UT, WA, WY",
}


def _headers(token: str) -> dict:
    return {
        "Authorization": f"Bearer {token}",
        "Notion-Version": _NOTION_VERSION,
        "Content-Type": "application/json",
    }


def _h2(text: str) -> dict:
    return {
        "object": "block", "type": "heading_2",
        "heading_2": {"rich_text": [{"type": "text", "text": {"content": text}}]},
    }


def _p(text: str) -> dict:
    return {
        "object": "block", "type": "paragraph",
        "paragraph": {"rich_text": [{"type": "text", "text": {"content": text}}]},
    }


def _code(text: str, language: str = "plain text") -> dict:
    return {
        "object": "block", "type": "code",
        "code": {
            "rich_text": [{"type": "text", "text": {"content": text}}],
            "language": language,
        },
    }


def _divider() -> dict:
    return {"object": "block", "type": "divider", "divider": {}}


def _build_rates_table(schedule: dict) -> str:
    header = f"{'HCPCS':<8}" + "".join(f"{s:>10}" for s in _STATES)
    lines = [header, "-" * (8 + 10 * len(_STATES))]
    for hcpcs in _HCPCS_CODES:
        row = f"{hcpcs:<8}"
        for state in _STATES:
            amt = schedule.get((hcpcs, state))
            row += f"{'$'+f'{amt:.2f}':>10}" if amt else f"{'N/A':>10}"
        lines.append(row)
    return "\n".join(lines)


def build_page_children(schedule: dict, quarter: str) -> list:
    now_str = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    return [
        _h2("Overview"),
        _p(
            "DMEworks automation for Allied Medical Health. "
            "Reads patient queue from Notion (status: 'To Enter in DMEworks'), "
            "then enters each record into DMEworks via UI automation (pywinauto)."
        ),
        _p("Modes: run (production), test (UI test on test records), audit (Notion vs DB diff), fix (correct audit diffs)."),
        _p("Deployment: single EXE built via PyInstaller. Copy dme-auto.exe to workstation — nothing else needed."),
        _divider(),

        _h2("Fee Schedule"),
        _p(
            "Source: CMS DMEPOS fee schedule — the authoritative Medicare allowable rates for DME. "
            "Updated quarterly (Jan/Apr/Jul/Oct). "
            "Downloaded at startup from cms.gov as a ZIP, parsed in memory. No caching."
        ),
        _p(f"Current quarter: {quarter.upper()}  |  Last fetched: {now_str}"),
        _p(
            "Module: fee_schedule.py. Call load_fee_schedule() once at startup, "
            "then get_allowable(hcpcs, state, schedule) -> (allowable, billable). "
            "Billable = 2x allowable. On miss: prompts for manual entry."
        ),
        _divider(),

        _h2("HCPCS Codes"),
        _p("Codes billed by Allied Medical Health:"),
        _code("  ".join(_HCPCS_CODES)),
        _p(
            "In Notion: add to the 'HCPCS Codes' rich_text property on each patient record. "
            "Pipe-separated format: L0457|L1833|L0631"
        ),
        _divider(),

        _h2("States & MAC Jurisdictions"),
        _p("The MAC (Medicare Administrative Contractor) depends on the patient's state, not the provider's."),
        *[_p(f"  {jur}: {states}") for jur, states in _JURISDICTIONS.items()],
        _p("Currently serving: " + ", ".join(_STATES)),
        _divider(),

        _h2(f"Current Allowable Rates — Q{quarter[-1].upper()} 20{quarter[:2]}"),
        _p(f"Generated {now_str}. Amounts are Medicare allowables. Billable = 2x allowable."),
        _code(_build_rates_table(schedule) if schedule else "(fee schedule unavailable — run create_notion_docs.py when connected)"),
    ]


def create_docs_page(token: str, schedule: dict, quarter: str) -> str:
    children = build_page_children(schedule, quarter)
    payload = {
        "parent": {"type": "workspace", "workspace": True},
        "properties": {
            "title": {"title": [{"type": "text", "text": {"content": "DME Auto — App Reference"}}]}
        },
        "children": children,
    }
    resp = _request("post", f"{_BASE}/pages", _headers(token), json=payload)
    page_id = resp.json()["id"]
    page_url = resp.json().get("url", "")
    return page_url


def main():
    print("Loading Notion token...")
    token = get_notion_token()

    print("Loading CMS fee schedule...")
    schedule = load_fee_schedule()
    quarter  = _current_quarter()
    print(f"  Quarter: {quarter} | Entries loaded: {len(schedule)}")

    print("Creating Notion page...")
    try:
        url = create_docs_page(token, schedule, quarter)
        print(f"  Created: {url}")
    except Exception as e:
        print(f"  FAILED: {e}")
        print()
        print("  If you see a 'parent type not supported' error, the Notion integration")
        print("  needs workspace-level access. Update it in Notion Settings -> Connections.")
        sys.exit(1)


if __name__ == "__main__":
    main()
