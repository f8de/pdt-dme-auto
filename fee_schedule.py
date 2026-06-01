import csv
import io
import json
import os
import zipfile
from datetime import datetime, timezone

import requests

# URL uses year only — CMS publishes one annual file, no quarter suffix
_CMS_URL_PATTERN = "https://www.cms.gov/files/zip/dme{yy}.zip"

# Column indices in DMEPOS26_JAN.txt — tilde-delimited, 17 columns.
# Confirmed via live probe of dme26.zip on 2026-06-01.
_COL_HCPCS = 1   # e.g. 'L0457'
_COL_STATE  = 8   # e.g. 'NJ     ' (padded to 7 chars — strip before use)
_COL_FEE    = 9   # e.g. '000412.50' (zero-padded — float() handles it)

_APPDATA_DIR = os.path.join(os.environ.get("APPDATA", ""), "dme-auto")


def _cache_path(quarter: str) -> str:
    return os.path.join(_APPDATA_DIR, f"fee_schedule_{quarter}.json")


def _load_cached(quarter: str) -> dict[tuple[str, str], float] | None:
    path = _cache_path(quarter)
    if not os.path.exists(path):
        return None
    try:
        with open(path, "r", encoding="utf-8") as f:
            raw = json.load(f)
        return {(k.split("|")[0], k.split("|")[1]): v for k, v in raw.items()}
    except Exception:
        return None


def _save_cached(quarter: str, schedule: dict[tuple[str, str], float]) -> None:
    try:
        os.makedirs(_APPDATA_DIR, exist_ok=True)
        data = {f"{k[0]}|{k[1]}": v for k, v in schedule.items()}
        with open(_cache_path(quarter), "w", encoding="utf-8") as f:
            json.dump(data, f)
    except Exception as exc:
        print(f"[fee_schedule] WARNING: Could not cache schedule ({exc})")


def _current_quarter(now: datetime | None = None) -> str:
    """Return 2+1 char string e.g. '26b' for April-June 2026.
    Year part used for URL; quarter letter available for display/future use."""
    if now is None:
        now = datetime.now(timezone.utc)
    year = str(now.year)[2:]
    quarter = ["a","a","a","b","b","b","c","c","c","d","d","d"][now.month - 1]
    return f"{year}{quarter}"


def load_fee_schedule() -> dict[tuple[str, str], float]:
    """Download current CMS DMEPOS fee schedule, parse into lookup dict.
    Returns {(hcpcs_upper, state_upper): allowable_amount}.
    Returns empty dict on any failure — callers fall back to manual input."""
    quarter = _current_quarter()
    cached = _load_cached(quarter)
    if cached is not None:
        print(f"[fee_schedule] Using cached schedule for {quarter} ({len(cached):,} entries).")
        return cached
    yy = quarter[:2]
    url = _CMS_URL_PATTERN.format(yy=yy)
    try:
        resp = requests.get(url, timeout=30)
        resp.raise_for_status()
    except Exception as exc:
        print(f"[fee_schedule] WARNING: Could not download fee schedule ({exc})")
        print(f"[fee_schedule] URL: {url}")
        print("[fee_schedule] All lookups will prompt for manual entry.")
        return {}

    try:
        with zipfile.ZipFile(io.BytesIO(resp.content)) as zf:
            dmepos = [n for n in zf.namelist() if n.upper().startswith("DMEPOS") and n.upper().endswith(".TXT")]
            if not dmepos:
                raise ValueError(f"No DMEPOS*.TXT file in ZIP. Contents: {zf.namelist()}")
            with zf.open(sorted(dmepos)[0]) as f:
                text = f.read().decode("latin-1")
    except Exception as exc:
        print(f"[fee_schedule] WARNING: Could not parse ZIP ({exc})")
        return {}

    schedule: dict[tuple[str, str], float] = {}
    reader = csv.reader(io.StringIO(text), delimiter="~")
    for row in reader:
        if len(row) <= max(_COL_HCPCS, _COL_STATE, _COL_FEE):
            continue
        try:
            hcpcs   = row[_COL_HCPCS].strip().upper()
            state   = row[_COL_STATE].strip().upper()
            fee_str = row[_COL_FEE].strip()
            if not hcpcs or not state or not fee_str:
                continue
            schedule[(hcpcs, state)] = float(fee_str)
        except (ValueError, IndexError):
            continue

    if schedule:
        _save_cached(quarter, schedule)
    return schedule


def get_allowable(
    hcpcs_code: str,
    state: str,
    schedule: dict[tuple[str, str], float],
) -> tuple[float, float]:
    """Return (allowable, billable=2x allowable).
    Prompts for manual entry if code+state not found in schedule."""
    key = (hcpcs_code.strip().upper(), state.strip().upper())
    amount = schedule.get(key)
    if amount is None:
        amount = _prompt_manual(hcpcs_code.strip().upper(), state.strip().upper())
    return amount, round(amount * 2, 2)


def _prompt_manual(hcpcs: str, state: str) -> float:
    while True:
        raw = input(f"  Enter Medicare allowable for {hcpcs}/{state}: $").strip()
        try:
            return float(raw)
        except ValueError:
            print("  Invalid — enter a number (e.g. 412.50)")


if __name__ == "__main__":
    print("Loading CMS DMEPOS fee schedule...")
    schedule = load_fee_schedule()
    if not schedule:
        print("FAILED — schedule is empty. Check warnings above.")
    else:
        print(f"Loaded {len(schedule):,} entries.\n")
        test_cases = [
            ("L0457", "NJ"),
            ("L1833", "NJ"),
            ("L0457", "OH"),
            ("L0457", "SC"),
            ("L1833", "OH"),
            ("L1833", "SC"),
        ]
        print(f"{'HCPCS':<8} {'State':<6} {'Allowable':>12} {'Billable':>12}")
        print("-" * 42)
        for hcpcs, state in test_cases:
            amount = schedule.get((hcpcs, state))
            if amount is not None:
                allowable, billable = get_allowable(hcpcs, state, schedule)
                print(f"{hcpcs:<8} {state:<6} ${allowable:>11.2f} ${billable:>11.2f}")
            else:
                print(f"{hcpcs:<8} {state:<6} {'NOT FOUND':>12}")
