"""
DMEworks Patient Entry — Allied Medical Health.

Modes:
  run    (default)  Process Notion queue: create new doctors/patients, smart-update changed fields,
                    mark Notion status as 'In DMEworks' on success.
  test              End-to-end UI test on test records: always re-enters every field on every tab
                    regardless of what is already in the DB, then verifies. No Notion status updates.
  audit             Read-only: compare all 'In DMEworks' Notion records against DB, report mismatches.
                    No UI, no writes.
  fix               Same as audit but applies targeted field-level corrections via UI.
                    Only updates fields that differ; does not flip Notion status.

Usage:
  python entry_all.py                   # run  — process Notion queue (production)
  python entry_all.py --mode test       # test — full UI automation test on test records
  python entry_all.py --mode audit      # audit — verify Notion vs DB, no writes
  python entry_all.py --mode fix        # fix  — correct audit discrepancies (targeted)
  python entry_all.py --dry-run         # preview run/fix without writing to DMEworks

Prerequisites: DMEworks open on main screen, all child windows closed.
"""

import ctypes
import os
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime

from pywinauto import Application, keyboard

_ROOT = os.path.dirname(os.path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from utils import db
from utils.logger import get_logger, mask_dob, mask_mbi

log = get_logger()

# ─── ARGS ─────────────────────────────────────────────────────────────────────

def _parse_args():
    import argparse
    p = argparse.ArgumentParser(description="DMEworks Patient Entry — Allied Medical Health")
    p.add_argument("--mode", choices=["run", "test", "audit", "fix"], default="run",
                   metavar="MODE", help="run | test | audit | fix  (omit to use interactive menu)")
    p.add_argument("--dry-run",  action="store_true")
    p.add_argument("--setup",    action="store_true")
    return p.parse_args()


def _ansi_setup():
    try:
        ctypes.windll.kernel32.SetConsoleOutputCP(65001)
        ctypes.windll.kernel32.SetConsoleMode(
            ctypes.windll.kernel32.GetStdHandle(-11), 7)
    except Exception:
        pass


def _clear():
    sys.stdout.write("\033[2J\033[H")
    sys.stdout.flush()


def _menu_frame(title, rows, IN=58):
    """Draw a bordered menu box. rows is a list of (plain, styled) tuples or None for blank."""
    BD = "\033[1m"; RS = "\033[0m"; CY = "\033[96m"; WH = "\033[97m"

    def _top(): return f"{CY}╔{'═' * IN}╗{RS}"
    def _mid(): return f"{CY}╠{'═' * IN}╣{RS}"
    def _bot(): return f"{CY}╚{'═' * IN}╝{RS}"
    def _row(plain="", styled=""):
        pad = IN - 2 - len(plain)
        return f"{CY}║{RS}  {styled}{' ' * max(0, pad)}{CY}║{RS}"

    t_pad = (IN - len(title)) // 2
    title_row = (f"{CY}║{RS}{' ' * t_pad}{BD}{WH}{title}{RS}"
                 f"{' ' * (IN - t_pad - len(title))}{CY}║{RS}")

    print()
    print(_top())
    print(title_row)
    print(_mid())
    for item in rows:
        if item is None:
            print(_row())
        else:
            print(_row(*item))
    print(_bot())
    print()


def _tools_menu() -> None:
    """Developer tools submenu."""
    BD = "\033[1m"; RS = "\033[0m"; YL = "\033[93m"; WH = "\033[97m"; DM = "\033[2m\033[37m"

    tools = [
        ("1", "DB Dump",       "db_dump",                    "Dump DB records to file"),
        ("2", "Verify DB",     "verify_dmeworks",             "Detailed Notion vs DB audit"),
        ("3", "Fix via UI",    "fix_via_ui",                  "Standalone diff + UI correction"),
        ("4", "Map Customer",  "map_customer_form",           "Dump Customer form controls"),
        ("5", "Map Doctor",    "map_doctor_form",             "Dump Doctor form controls"),
        ("6", "Map Insurance", "map_insurance_company_tabs",  "Dump Insurance form controls"),
        ("7", "Map Policy",    "map_policy_dialog",           "Dump Policy dialog controls"),
        ("8", "Grid Probe",    "dmeworks_grid_probe",         "Probe grid cell reading"),
    ]

    while True:
        _clear()
        rows = [None]
        for num, name, _, desc in tools:
            plain  = f"{num}   {name:<14} {desc}"
            styled = f"{YL}{BD}{num}{RS}   {WH}{BD}{name:<14}{RS} {DM}{desc}{RS}"
            rows.append((plain, styled))
        rows.append(None)
        rows.append((f"0   Back", f"{YL}{BD}0{RS}   {WH}{BD}Back{RS}"))
        rows.append(None)
        _menu_frame("Tools", rows)

        mapping = {t[0]: (t[1], t[2]) for t in tools}
        try:
            raw = input(f"  {WH}Choice{RS} {DM}[0–8]{RS}:  ").strip()
        except (KeyboardInterrupt, EOFError):
            return
        if raw == "0" or raw == "":
            return
        if raw not in mapping:
            continue

        name, module = mapping[raw]
        print(f"\n  Starting {name}...\n")
        import importlib
        old_argv = sys.argv[:]
        sys.argv  = [sys.argv[0]]
        try:
            mod = importlib.import_module(f"tools.{module}")
            mod.main()
        except SystemExit:
            pass
        except Exception as e:
            print(f"\n  Error: {e}")
        finally:
            sys.argv = old_argv

        try:
            input(f"\n  {DM}Press Enter to return to menu...{RS}")
        except (KeyboardInterrupt, EOFError):
            return


def _startup_menu() -> tuple[str, bool]:
    """Interactive mode selector shown when no --mode flag is passed."""
    _ansi_setup()
    BD = "\033[1m"; RS = "\033[0m"; YL = "\033[93m"; WH = "\033[97m"; DM = "\033[2m\033[37m"

    modes = [
        ("1", "Run",   "Process Notion queue  (production)"),
        ("2", "Test",  "Full UI test on test records"),
        ("3", "Audit", "Verify Notion vs DB — no writes"),
        ("4", "Fix",   "Correct audit discrepancies"),
    ]

    while True:
        _clear()
        rows = [None]
        for num, name, desc in modes:
            plain  = f"{num}   {name:<7} {desc}"
            styled = f"{YL}{BD}{num}{RS}   {WH}{BD}{name:<7}{RS} {DM}{desc}{RS}"
            rows.append((plain, styled))
        rows.append(None)
        rows.append(("5   Tools   Developer & diagnostic tools ›",
                     f"{YL}{BD}5{RS}   {WH}{BD}Tools{RS}   {DM}Developer & diagnostic tools ›{RS}"))
        rows.append(None)
        rows.append(("0   Exit", f"{YL}{BD}0{RS}   {WH}{BD}Exit{RS}"))
        rows.append(None)
        _menu_frame("DMEworks Entry — Allied Medical Health", rows)

        try:
            raw = input(f"  {WH}Choice{RS} {DM}[default: 1 — Run]{RS}:  ").strip() or "1"
        except (KeyboardInterrupt, EOFError):
            sys.exit(0)

        if raw == "0":
            sys.exit(0)
        if raw == "5":
            _tools_menu()
            continue
        if raw in ("1", "2", "3", "4"):
            mode = {"1": "run", "2": "test", "3": "audit", "4": "fix"}[raw]
            break
        print(f"  {DM}Please enter 0–5.{RS}")

    dry_run = False
    if mode in ("run", "fix"):
        print()
        try:
            yn = input(f"  {WH}Dry run{RS} {DM}(preview without writing)? [y/N]{RS}:  ").strip().lower()
            dry_run = (yn == "y")
        except (KeyboardInterrupt, EOFError):
            sys.exit(0)

    print()
    return mode, dry_run


ARGS    = _parse_args()
MODE    = ARGS.mode
DRY_RUN = ARGS.dry_run

# ─── SETUP MODE ───────────────────────────────────────────────────────────────

if ARGS.setup:
    from utils.creds import _ENC_FILE, _ensure_doppler_token
    if os.path.exists(_ENC_FILE):
        os.remove(_ENC_FILE)
    _ensure_doppler_token()
    print("  Setup complete. Launch the app normally to continue.")
    sys.exit(0)

# ─── STARTUP MENU (when launched without --mode) ──────────────────────────────

if "--mode" not in sys.argv:
    MODE, DRY_RUN = _startup_menu()

# ─── LOAD CLIENT DATA ─────────────────────────────────────────────────────────

from utils import notion
from utils.creds import get_notion_token

_token             = get_notion_token()
INSURANCE_BY_STATE = notion.fetch_insurance_map(_token)
from fee_schedule import load_fee_schedule
FEE_SCHEDULE = load_fee_schedule()

if MODE == "test":
    from ingest_test import fetch_test_fixtures
    _TEST_DOCTOR, _TEST_PATIENT = fetch_test_fixtures(_token)
    DOCTORS   = [_TEST_DOCTOR]
    PATIENTS  = [_TEST_PATIENT]
    _ins_name = INSURANCE_BY_STATE.get(_TEST_PATIENT["state"], "")
    INSURANCE_COMPANIES = [{"name": _ins_name, "type": "MEDICARE"}] if _ins_name else []
    db.configure("c02")
else:
    if MODE in ("audit", "fix"):
        _raw = notion.fetch_patients_by_statuses(_token, ["In DMEworks"])
    else:
        _raw = notion.fetch_work_queue(_token)

    _seen_npis: set[str] = set()
    DOCTORS: list[dict]  = []
    for _p in _raw:
        _d   = _p.get("_doctor", {})
        _npi = _d.get("npi", "")
        if _npi and _npi not in _seen_npis:
            _seen_npis.add(_npi)
            DOCTORS.append(_d)

    PATIENTS: list[dict] = _raw

    _seen_ins: set[str]             = set()
    INSURANCE_COMPANIES: list[dict] = []
    for _p in PATIENTS:
        _medicare_name = INSURANCE_BY_STATE.get(_p.get("state", ""), "")
        if _medicare_name and _medicare_name not in _seen_ins:
            _seen_ins.add(_medicare_name)
            INSURANCE_COMPANIES.append({"name": _medicare_name, "type": "MEDICARE"})
        _sec      = _p.get("secondary") or {}
        _sec_name = _sec.get("ins_company", "")
        if _sec_name and _sec_name not in _seen_ins:
            _seen_ins.add(_sec_name)
            INSURANCE_COMPANIES.append({"name": _sec_name, "type": "OTHER"})

    db.configure()

# ─── STATUS OVERLAY ───────────────────────────────────────────────────────────

_notion_retry: list[str] = []

_set_title = ctypes.windll.kernel32.SetConsoleTitleW


def set_status(msg: str) -> None:
    _set_title(f"DME Auto — {msg}")


T_SHORT = 0.15
T_MED   = 0.4
T_LONG  = 0.7

# ─── PRE-VALIDATION ───────────────────────────────────────────────────────────

def validate_csv() -> list[str]:
    errors = []
    for doc in DOCTORS:
        if not doc.get("npi"):
            errors.append(f"Doctor {doc['last']}, {doc['first']}: missing NPI")
    for co in INSURANCE_COMPANIES:
        if not co.get("name"):
            errors.append("Insurance companies: row with missing name")
    for p in PATIENTS:
        label = f"Patient MBI {mask_mbi(p['mbi'])}" if p.get("mbi") else "Patient (no MBI)"
        if not p.get("mbi"):
            errors.append(f"{label}: missing MBI")
        if not p.get("dob"):
            errors.append(f"{label}: missing DOB")
        else:
            try:
                datetime.strptime(p["dob"], "%m/%d/%Y")
            except ValueError:
                errors.append(f"{label}: invalid DOB — expected MM/DD/YYYY")
        state = p.get("state", "")
        if not state:
            errors.append(f"{label}: missing state")
        elif state not in INSURANCE_BY_STATE:
            errors.append(f"{label}: state '{state}' has no DMERC mapping")
    return errors

# ─── CORE UTILITIES ───────────────────────────────────────────────────────────

def get_app():
    return Application(backend="uia").connect(title="DMEWorks")

def get_main():
    a = get_app()
    return a, a.window(title="DMEWorks", auto_id="FormMain")

def fmt_phone(digits):
    d = "".join(c for c in digits if c.isdigit())
    if len(d) == 10:
        return f"({d[:3]}){d[3:6]}-{d[6:]}"
    return digits

def dismiss_popup(a):
    try:
        p = a.window(title="Compliance Popup", auto_id="FormCompliancePopup")
        if p.exists(timeout=0.2):
            p.child_window(title="Close", control_type="Button").click_input()
            time.sleep(T_SHORT)
    except Exception:
        pass

def dismiss_save_dialog(a):
    try:
        main = a.window(title="DMEWorks", auto_id="FormMain")
        no_btn = main.child_window(title="No", control_type="Button")
        if no_btn.exists(timeout=0.3):
            log.debug("Save dialog — clicking No")
            no_btn.click_input()
            time.sleep(T_SHORT)
            return True
    except Exception:
        pass
    return False

def dismiss_validation(a):
    for frag in ["validation", "error", "warning"]:
        try:
            dlg = a.window(title_re=f".*{frag}.*")
            if dlg.exists(timeout=0.15):
                log.warning("Validation dialog: %s", dlg.window_text())
                dlg.child_window(title="OK", control_type="Button").click_input()
                time.sleep(T_SHORT)
                return True
        except Exception:
            pass
    return False

def find_mdi_child(main, keyword):
    try:
        w = main.child_window(title_re=f".*{keyword}.*", control_type="Window", found_index=0)
        if w.exists(timeout=0.1):
            return w
    except Exception:
        pass
    try:
        for child in main.descendants(control_type="Window"):
            try:
                t = child.window_text()
                if t and keyword.lower() in t.lower():
                    return main.child_window(title=t, control_type="Window",
                                            found_index=0)
            except Exception:
                pass
    except Exception:
        pass
    return None


def _wait_ctrl(parent, timeout=3.0, **kwargs) -> bool:
    """Poll every 50 ms until a child control exists. Returns True when found."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        try:
            if parent.child_window(**kwargs).exists(timeout=0):
                return True
        except Exception:
            pass
        time.sleep(0.05)
    return False


def _wait_mdi(main, keyword, timeout=5.0):
    """Poll every 100 ms until an MDI child matching keyword appears. Returns window or None."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        w = find_mdi_child(main, keyword)
        if w:
            return w
        time.sleep(0.1)
    return None

def set_field(win, auto_id, value):
    if not value:
        return
    try:
        win.child_window(auto_id=auto_id, found_index=0).set_edit_text(value)
        time.sleep(0.08)
    except Exception as e:
        log.warning("set_field(%s): %s", auto_id, e)

def toolbar_click(win, title):
    tb = win.child_window(auto_id="tlbMain", control_type="ToolBar", found_index=0)
    tb.child_window(title=title, control_type="Button").click_input()
    time.sleep(T_MED)

def close_window(main_win, keyword):
    try:
        w = find_mdi_child(main_win, keyword)
        if w:
            tb = w.child_window(auto_id="tlbMain", control_type="ToolBar",
                                found_index=0)
            tb.child_window(title="Close", control_type="Button").click_input()
            time.sleep(T_SHORT)
            dismiss_save_dialog(get_app())
    except Exception as e:
        log.warning("close_window(%s): %s", keyword, e)

def _close_customer(main_win):
    """Close Customer form by auto_id to avoid matching FormCustomerNotes by title."""
    try:
        w = main_win.child_window(auto_id="FormCustomer", control_type="Window", found_index=0)
        w.child_window(auto_id="tlbMain", control_type="ToolBar", found_index=0).child_window(
            title="Close", control_type="Button").click_input()
        time.sleep(T_SHORT)
        dismiss_save_dialog(get_app())
    except Exception as e:
        log.warning("_close_customer: %s", e)

def open_fresh_window(main_win, a, keyword, menu_path):
    if find_mdi_child(main_win, keyword):
        close_window(main_win, keyword)
        time.sleep(T_MED)
    a.top_window().menu_select(menu_path)
    dismiss_save_dialog(a)
    dismiss_popup(a)
    return _wait_mdi(main_win, keyword, timeout=6.0)

def go_work_area(w):
    try:
        w.child_window(auto_id="PageControl", control_type="Tab",
                       found_index=0).child_window(
            title="Work Area", control_type="TabItem").click_input()
        if not _wait_ctrl(w, auto_id="tlbMain", control_type="ToolBar", timeout=2.0):
            time.sleep(T_MED)
    except Exception as e:
        log.warning("go_work_area: %s", e)

def click_inner_tab(w, title, anchor_auto_id=None):
    w.child_window(auto_id="TabControl1", control_type="Tab",
                   found_index=0).child_window(
        title=title, control_type="TabItem").click_input()
    if anchor_auto_id:
        if not _wait_ctrl(w, auto_id=anchor_auto_id, timeout=2.0):
            time.sleep(T_MED)
    else:
        time.sleep(T_MED)

def _search_and_open_work_area(w, last_name, npi=None):
    """Filter the Search tab grid by last name and double-click the matching row."""
    # Click Search tab on PageControl
    try:
        w.child_window(auto_id="PageControl", control_type="Tab", found_index=0).child_window(
            title="Search", control_type="TabItem").click_input()
        time.sleep(T_MED)
    except Exception as e:
        log.warning("    [warn] Search tab not found: %s", e)
        return False

    # Type last name into txtFilter to narrow the grid
    try:
        w.child_window(auto_id="txtFilter", found_index=0).set_edit_text(last_name)
        time.sleep(T_MED)
    except Exception:
        pass

    # Find the grid and scan rows for a last-name match; fall back to Row 0
    try:
        grid = w.child_window(auto_id="Grid", control_type="Table", found_index=0)
        for row_idx in range(20):
            row_title = f"Row {row_idx}"
            try:
                row = grid.child_window(title=row_title, control_type="Custom", found_index=0)
            except Exception:
                break
            try:
                cell_val = row.child_window(
                    title=f"Last Name {row_title}", control_type="Edit",
                    found_index=0).window_text() or ""
                if last_name.lower() in cell_val.lower():
                    row.double_click_input()
                    if not _wait_ctrl(w, auto_id="txtLastName", timeout=4.0):
                        time.sleep(T_LONG)
                    return True
            except Exception:
                # Can't read cell text — fall through to Row 0 fallback
                break
        # Fallback: Row 0 should be the top result after filtering
        grid.child_window(title="Row 0", control_type="Custom",
                          found_index=0).double_click_input()
        if not _wait_ctrl(w, auto_id="txtLastName", timeout=4.0):
            time.sleep(T_LONG)
        return True
    except Exception as e:
        log.warning("    [warn] Search grid not found or row not clickable: %s", e)
        return False

# ─── COMBO AND DOB ────────────────────────────────────────────────────────────

def set_combo_text(pane, value):
    if not value:
        return
    try:
        combo = pane.child_window(auto_id="cmbInternal", found_index=0)
        combo.click_input()
        time.sleep(0.15)
        try:
            combo.select(value)
            time.sleep(0.1)
            return
        except Exception:
            pass
        combo.type_keys("^a", with_spaces=False)
        time.sleep(0.05)
        combo.type_keys(value, with_spaces=True)
        time.sleep(0.3)
        combo.type_keys("{ENTER}")
        time.sleep(0.15)
    except Exception as e:
        log.warning("set_combo_text('%s'): %s", value, e)


def _set_doctor_by_find(contacts_pane, doc, main_win):
    """Select doctor via cmbDoctor1 btnFind dialog for unambiguous selection.
    Falls back to last-name combo search if the Find dialog can't be navigated."""
    last  = (doc.get("last") or "").strip()
    first = (doc.get("first") or "").strip()
    if not last:
        return
    try:
        doc1_pane = contacts_pane.child_window(auto_id="cmbDoctor1", found_index=0)
        doc1_pane.child_window(auto_id="btnFind", found_index=0).click_input()
        find_dlg = None
        for kw in ("Doctor", "Find", "Search"):
            try:
                cand = main_win.child_window(title_re=f".*{kw}.*",
                                             control_type="Window", found_index=0)
                if cand.exists(timeout=0.5):
                    find_dlg = cand
                    break
            except Exception:
                pass
        if not find_dlg:
            raise RuntimeError("Find dialog not found after btnFind click")
        try:
            find_dlg.child_window(auto_id="txtFilter", found_index=0).set_edit_text(last)
        except Exception:
            try:
                find_dlg.child_window(control_type="Edit", found_index=0).set_edit_text(last)
            except Exception:
                pass
        _wait_ctrl(find_dlg, title="Row 0", control_type="Custom", timeout=2.0)
        find_dlg.child_window(title="Row 0", control_type="Custom",
                              found_index=0).double_click_input()
        try:
            find_dlg.wait_not("visible", timeout=2.0)
        except Exception:
            time.sleep(T_MED)
        log.info("    Doctor: Find dialog selected (%s %s)", first, last)
    except Exception as e:
        log.warning("    _set_doctor_by_find failed (%s), falling back to combo: %s", last, e)
        set_combo_text(contacts_pane.child_window(auto_id="cmbDoctor1", found_index=0), last)

def set_dob(win, dob_str):
    try:
        dob = win.child_window(auto_id="dtbDateofBirth", found_index=0)
        rect = dob.wrapper_object().rectangle()
        h = rect.bottom - rect.top
        dob.click_input(coords=(6, h // 2))
        time.sleep(0.35)
        for _ in range(4):
            keyboard.send_keys("{LEFT}")
            time.sleep(0.03)
        time.sleep(0.1)
        mm, dd, yyyy = dob_str.split("/")
        keyboard.send_keys(mm)
        time.sleep(0.15)
        keyboard.send_keys(dd)
        time.sleep(0.15)
        keyboard.send_keys(yyyy)
        time.sleep(0.15)
    except Exception as e:
        log.warning("set_dob: %s", e)

# ─── DOCTORS ──────────────────────────────────────────────────────────────────

def _doctor_diff_groups(doc, db_row) -> set:
    _s  = lambda v: (v or "").strip()
    _sl = lambda v: _s(v).lower()
    _ph = lambda v: "".join(c for c in _s(v) if c.isdigit())
    groups = set()
    if (_sl(db_row.get("LastName"))   != doc.get("last",   "").lower() or
            _sl(db_row.get("FirstName"))  != doc.get("first",  "").lower() or
            _sl(db_row.get("MiddleName")) != (doc.get("mi") or "").lower() or
            _s(db_row.get("Suffix"))      != _s(doc.get("suffix"))):
        groups.add("name")
    if (_sl(db_row.get("Address1")) != (doc.get("address1") or "").lower() or
            _sl(db_row.get("Address2")) != (doc.get("address2") or "").lower() or
            _sl(db_row.get("City"))     != (doc.get("city") or "").lower() or
            _s(db_row.get("State"))     != _s(doc.get("state")) or
            _s(db_row.get("Zip"))       != _s(doc.get("zip")) or
            _ph(db_row.get("Phone"))    != _ph(doc.get("phone")) or
            _ph(db_row.get("Fax"))      != _ph(doc.get("fax"))):
        groups.add("address")
    if _s(db_row.get("NPI")) != _s(doc.get("npi")):
        groups.add("numbers")
    return groups


def _patient_diff_groups(p, row, notes_needed=False) -> set:
    _s  = lambda v: (v or "").strip()
    _sl = lambda v: _s(v).lower()
    _ph = lambda v: "".join(c for c in _s(v) if c.isdigit())
    def _flt(v):
        try: return round(float(v or 0), 1)
        except: return 0.0
    groups = set()
    dob_db  = row.get("dob")
    dob_str = dob_db.strftime("%m/%d/%Y") if hasattr(dob_db, "strftime") else str(dob_db or "")
    if (dob_str != p.get("dob", "") or
            _sl(row.get("address1")) != (p.get("address1") or "").lower() or
            _sl(row.get("address2")) != (p.get("address2") or "").lower() or
            _sl(row.get("city"))     != (p.get("city") or "").lower() or
            _s(row.get("state")).upper() != (p.get("state") or "").upper() or
            _s(row.get("zip"))   != _s(p.get("zip")) or
            _ph(row.get("phone")) != _ph(p.get("phone"))):
        groups.add("general")
    db_gender  = _s(row.get("gender"))
    exp_gender = p.get("gender") or "Male"
    if (db_gender != exp_gender or
            _flt(row.get("height")) != _flt(p.get("height")) or
            _flt(row.get("weight")) != _flt(p.get("weight"))):
        groups.add("personal")
    expected_npi = (p.get("_doctor") or {}).get("npi", "")
    if expected_npi and _s(row.get("doctor_npi")) != expected_npi:
        groups.add("contacts")
    db_codes     = {row.get(f"icd10_{i:02d}") for i in range(1, 13) if row.get(f"icd10_{i:02d}")}
    notion_codes = set(p.get("icd10", []))
    if db_codes != notion_codes:
        groups.add("diagnosis")
    if p.get("secondary"):
        groups.add("insurance")
    if notes_needed:
        groups.add("notes")
    return groups


def create_doctor(doc, main_win, a):
    label = f"NPI {doc['npi']}"
    w = open_fresh_window(main_win, a, "Doctor", "Maintain->Doctor")
    if not w:
        raise RuntimeError(f"Doctor window not found for {label}")
    try:
        go_work_area(w)
        toolbar_click(w, "New")
        time.sleep(T_MED)
        dismiss_save_dialog(get_app())
        w = find_mdi_child(main_win, "Doctor")

        set_field(w, "txtLastName",   doc["last"])
        set_field(w, "txtFirstName",  doc["first"])
        set_field(w, "txtMiddleName", doc["mi"])
        set_field(w, "txtSuffix",     doc["suffix"])

        click_inner_tab(w, "Address", anchor_auto_id="txtAddress1")
        set_field(w, "txtAddress1", doc["address1"])
        set_field(w, "txtAddress2", doc["address2"])
        set_field(w, "txtCity",     doc["city"])
        set_field(w, "txtState",    doc["state"])
        set_field(w, "txtZip",      doc["zip"])
        set_field(w, "txtPhone",    fmt_phone(doc["phone"]))
        set_field(w, "txtFax",      fmt_phone(doc.get("fax", "")))

        click_inner_tab(w, "Numbers", anchor_auto_id="txtNPI")
        set_field(w, "txtNPI", doc["npi"])

        toolbar_click(w, "Save")
        dismiss_validation(get_app())
        log.info("    [saved] %s", label)
    except Exception:
        log.error("    Error creating doctor %s — closing window", label)
        try:
            close_window(main_win, "Doctor")
        except Exception:
            pass
        raise
    close_window(main_win, "Doctor")
    time.sleep(T_SHORT)


def update_doctor(doc, main_win, a, groups=None):
    if groups is None:
        groups = {"name", "address", "numbers"}
    label = f"NPI {doc['npi']}"
    w = open_fresh_window(main_win, a, "Doctor", "Maintain->Doctor")
    if not w:
        raise RuntimeError(f"Doctor window not found for {label}")
    try:
        if not _search_and_open_work_area(w, doc["last"], npi=doc["npi"]):
            log.warning("  [warn] Could not open existing doctor %s in UI", label)
            close_window(main_win, "Doctor")
            return
        w = find_mdi_child(main_win, "Doctor")

        if "name" in groups:
            set_field(w, "txtLastName",   doc["last"])
            set_field(w, "txtFirstName",  doc["first"])
            set_field(w, "txtMiddleName", doc["mi"])
            set_field(w, "txtSuffix",     doc["suffix"])

        if "address" in groups:
            click_inner_tab(w, "Address", anchor_auto_id="txtAddress1")
            set_field(w, "txtAddress1", doc["address1"])
            set_field(w, "txtAddress2", doc["address2"])
            set_field(w, "txtCity",     doc["city"])
            set_field(w, "txtState",    doc["state"])
            set_field(w, "txtZip",      doc["zip"])
            set_field(w, "txtPhone",    fmt_phone(doc["phone"]))
            set_field(w, "txtFax",      fmt_phone(doc.get("fax", "")))

        if "numbers" in groups:
            click_inner_tab(w, "Numbers", anchor_auto_id="txtNPI")
            set_field(w, "txtNPI", doc["npi"])

        toolbar_click(w, "Save")
        dismiss_validation(get_app())
        log.info("    [updated] %s", label)
    except Exception:
        log.error("    Error updating doctor %s — closing window", label)
        try:
            close_window(main_win, "Doctor")
        except Exception:
            pass
        raise
    close_window(main_win, "Doctor")
    time.sleep(T_SHORT)


def ensure_all_doctors(a, main_win, existing_npis):
    log.info("")
    log.info("=" * 52)
    log.info("[1/3] DOCTORS")
    log.info("=" * 52)
    log.info("DB check: %d/%d doctor(s) already exist", len(existing_npis), len(DOCTORS))

    to_create = [d for d in DOCTORS if d["npi"] not in existing_npis]
    to_update = [d for d in DOCTORS if d["npi"] in existing_npis]

    dismiss_popup(a)
    for doc in to_update:
        label = f"NPI {doc['npi']}"
        if DRY_RUN:
            log.info("  [UPDATE] %s", label)
            log.info("    [DRY RUN] skipping UI — would update doctor")
            continue
        if MODE == "test":
            groups = {"name", "address", "numbers"}
            log.info("  [UPDATE] %s — all fields (test mode)", label)
        else:
            db_row = db.verify_doctor(doc["npi"])
            groups = _doctor_diff_groups(doc, db_row) if db_row else {"name", "address", "numbers"}
            if not groups:
                log.info("  [OK]     %s — no changes needed", label)
                continue
            log.info("  [UPDATE] %s — %s", label, sorted(groups))
        try:
            update_doctor(doc, main_win, a, groups)
        except Exception as e:
            log.error("  [ERROR]  %s — %s", label, e)

    for i, doc in enumerate(to_create, 1):
        label = f"NPI {doc['npi']}"
        set_status(f"[1/3] Doctor {i}/{len(to_create)}: NPI {doc['npi']}")
        log.info("  [CREATE] %s", label)
        if DRY_RUN:
            log.info("    [DRY RUN] skipping UI — would create doctor")
            continue
        try:
            create_doctor(doc, main_win, a)
        except Exception as e:
            log.error("  [ERROR]  %s — %s", label, e)

# ─── INSURANCE COMPANIES ──────────────────────────────────────────────────────

def create_insurance_company(name, main_win, a):
    w = open_fresh_window(main_win, a, "Insurance Company",
                          "Maintain->Insurance Company")
    if not w:
        raise RuntimeError(f"Insurance Company window not found for {name}")
    try:
        go_work_area(w)
        toolbar_click(w, "New")
        time.sleep(T_MED)
        dismiss_save_dialog(get_app())
        w = find_mdi_child(main_win, "Insurance Company")
        set_field(w, "txtName", name)
        toolbar_click(w, "Save")
        dismiss_validation(get_app())
        log.info("    [saved] %s", name)
    except Exception:
        log.error("    Error creating insurance company %s — closing window", name)
        try:
            close_window(main_win, "Insurance Company")
        except Exception:
            pass
        raise
    close_window(main_win, "Insurance Company")
    time.sleep(T_SHORT)


def ensure_all_insurance_companies(a, main_win, existing_names):
    log.info("")
    log.info("=" * 52)
    log.info("[2/3] INSURANCE COMPANIES")
    log.info("=" * 52)
    log.info("DB check: %d/%d company(s) already exist", len(existing_names), len(INSURANCE_COMPANIES))

    dismiss_popup(a)
    companies = INSURANCE_COMPANIES
    for i, co in enumerate(companies, 1):
        name = co["name"]
        is_medicare = co["type"] == "MEDICARE"
        set_status(f"[2/3] Insurance {i}/{len(companies)}: {name}")

        if name.lower() in existing_names:
            tag = "[OK]    " if is_medicare else "[SKIP]  "
            log.info("  %s %s", tag, name)
        elif is_medicare:
            log.error("  [ERROR]  '%s' — not found, must be created manually in DMEworks", name)
        else:
            log.info("  [CREATE] %s", name)
            if DRY_RUN:
                log.info("    [DRY RUN] skipping UI — would create insurance company")
                continue
            try:
                create_insurance_company(name, main_win, a)
            except Exception as e:
                log.error("  [ERROR]  %s — %s", name, e)

# ─── CUSTOMERS ────────────────────────────────────────────────────────────────

def add_insurance_row(pol_dialog, ins_company, ins_type, policy, group=""):
    try:
        set_combo_text(pol_dialog.child_window(auto_id="cmbInsuranceCompany",
                                               found_index=0), ins_company)
        set_combo_text(pol_dialog.child_window(auto_id="cmbInsuranceType",
                                               found_index=0), ins_type)
        set_field(pol_dialog, "txtPolicyNumber", policy)
        if group:
            set_field(pol_dialog, "txtGroupNumber", group)
        pol_dialog.child_window(auto_id="btnOK", found_index=0).click_input()
        time.sleep(T_MED)
        if dismiss_validation(get_app()):
            log.warning("    Validation on insurance row — check manually")
        else:
            log.info("    [ins] %s (%s) | policy %s", ins_company, ins_type, mask_mbi(policy))
    except Exception as e:
        log.error("    add_insurance_row failed: %s", e)
        try:
            pol_dialog.child_window(auto_id="btnCancel", found_index=0).click_input()
        except Exception:
            pass


def _clear_insurance_rows(ctrl_pane):
    panel   = ctrl_pane.child_window(auto_id="Panel1")
    btn_del = panel.child_window(auto_id="btnDelete", found_index=0)
    cleared = 0
    log.info("    Insurance: clearing existing rows...")
    a = get_app()
    for _ in range(20):
        try:
            grid = ctrl_pane.child_window(control_type="Table", found_index=0)
            row  = grid.child_window(title="Row 0", control_type="Custom", found_index=0)
            if not row.exists(timeout=0.1):
                break
            row.click_input()
            time.sleep(0.1)
            btn_del.click_input()
            time.sleep(0.3)
            dismiss_validation(a)
            cleared += 1
        except Exception:
            break
    if cleared:
        log.info("    Insurance: cleared %d existing row(s)", cleared)


def _fill_customer_form(dlg, p, main_win, is_update=False, groups=None):
    medicare_name = INSURANCE_BY_STATE.get(p["state"])
    if not medicare_name:
        raise ValueError(f"No DMERC mapping for state '{p['state']}'")
    if groups is None:
        groups = {"general", "personal", "contacts", "diagnosis", "insurance", "notes"}

    set_field(dlg, "txtLastName",   p["last"])
    set_field(dlg, "txtFirstName",  p["first"])
    set_field(dlg, "txtMiddleName", p["mi"])
    set_field(dlg, "txtSuffix",     p["suffix"])

    if "general" in groups:
        click_inner_tab(dlg, "General", anchor_auto_id="dtbDateofBirth")
        set_dob(dlg, p["dob"])
        set_field(dlg, "txtAddress1", p["address1"])
        set_field(dlg, "txtAddress2", p["address2"])
        set_field(dlg, "txtCity",     p["city"])
        set_field(dlg, "txtState",    p["state"])
        set_field(dlg, "txtZip",      p["zip"])
        set_field(dlg, "txtPhone",    fmt_phone(p["phone"]))

    if "personal" in groups:
        click_inner_tab(dlg, "Personal", anchor_auto_id="cmbGender")
        gender_val = p.get("gender") or "Male"
        try:
            dlg.child_window(auto_id="cmbGender", found_index=0).child_window(
                auto_id="1001", found_index=0).set_edit_text(gender_val)
            time.sleep(0.3)
        except Exception as e:
            log.warning("    [warn] Gender not set: %s", e)
        try:
            if p.get("height"):
                dlg.child_window(auto_id="nmbHeight", found_index=0).child_window(
                    auto_id="txtInternal", found_index=0).set_edit_text(str(p["height"]))
        except Exception as e:
            log.warning("    [warn] Height not set: %s", e)
        try:
            if p.get("weight"):
                dlg.child_window(auto_id="nmbWeight", found_index=0).child_window(
                    auto_id="txtInternal", found_index=0).set_edit_text(str(p["weight"]))
        except Exception as e:
            log.warning("    [warn] Weight not set: %s", e)
        log.info("    Personal: gender=%s h=%s w=%s",
                 p.get("gender") or "Male", p.get("height", ""), p.get("weight", ""))

    if "contacts" in groups:
        click_inner_tab(dlg, "Contacts", anchor_auto_id="tpContacts")
        contacts_pane = dlg.child_window(auto_id="tpContacts", found_index=0)
        _doc = p.get("_doctor") or {}
        _set_doctor_by_find(contacts_pane, _doc, main_win)
        dismiss_popup(get_app())
        time.sleep(T_SHORT)
        try:
            dlg = main_win.child_window(auto_id="FormCustomer", control_type="Window", found_index=0)
        except Exception:
            pass

    if "diagnosis" in groups:
        click_inner_tab(dlg, "Diagnosis", anchor_auto_id="TabControl2")
        dlg.child_window(auto_id="TabControl2", control_type="Tab",
                         found_index=0).child_window(
            title="ICD 10", control_type="TabItem").click_input()
        time.sleep(T_MED)
        icd_pane = dlg.child_window(auto_id="TabPage3", found_index=0)
        for i, code in enumerate(p["icd10"], start=1):
            try:
                slot = icd_pane.child_window(auto_id=f"eddICD10_{i:02d}")
                slot.child_window(auto_id="txtInternal").set_edit_text(code)
                time.sleep(0.1)
            except Exception as e:
                log.warning("    ICD slot %d: %s", i, e)
        log.info("    ICD-10: %d code(s)", len(p["icd10"]))

    if "insurance" in groups:
        click_inner_tab(dlg, "Insurance", anchor_auto_id="ControlCustomerInsurance1")
        ins_pane  = dlg.child_window(auto_id="tpInsurance", found_index=0)
        ctrl_pane = ins_pane.child_window(auto_id="ControlCustomerInsurance1")
        if is_update:
            _clear_insurance_rows(ctrl_pane)
        ctrl_pane.child_window(auto_id="Panel1").child_window(
            auto_id="btnAdd").click_input()
        pol = _wait_mdi(main_win, "Policy Information", timeout=5.0)
        if pol:
            add_insurance_row(pol, medicare_name, "MEDICARE", p["mbi"])
        else:
            log.error("    Policy Information dialog not found (primary)")
        if p.get("secondary"):
            sec = p["secondary"]
            ctrl_pane.child_window(auto_id="Panel1").child_window(
                auto_id="btnAdd").click_input()
            pol2 = _wait_mdi(main_win, "Policy Information", timeout=5.0)
            if pol2:
                add_insurance_row(pol2, sec["ins_company"],
                                  sec["ins_type"], sec["policy"],
                                  sec.get("group", ""))
            else:
                log.error("    Policy Information dialog not found (secondary)")

    if "notes" in groups and p.get("notes"):
        click_inner_tab(dlg, "Notes", anchor_auto_id="ControlCustomerNotes1")
        try:
            notes_pane = dlg.child_window(auto_id="tpNotes", found_index=0)
            notes_ctrl = notes_pane.child_window(auto_id="ControlCustomerNotes1", found_index=0)
            notes_ctrl.child_window(auto_id="btnAdd", found_index=0).click_input()
            try:
                notes_dlg = main_win.child_window(auto_id="FormCustomerNotes",
                                                   control_type="Window", found_index=0)
                notes_dlg.wait("visible", timeout=3)
            except Exception:
                notes_dlg = None
            if notes_dlg:
                entered = False
                for aid in ("txtNotes", "memoNotes", "txtNote", "txtMemo", "txtText"):
                    try:
                        notes_dlg.child_window(auto_id=aid, found_index=0).set_edit_text(p["notes"])
                        entered = True
                        break
                    except Exception:
                        pass
                if not entered:
                    try:
                        notes_dlg.child_window(control_type="Edit", found_index=0).set_edit_text(p["notes"])
                        entered = True
                    except Exception:
                        pass
                for _save_fn in [
                    lambda: notes_dlg.child_window(auto_id="btnSave", found_index=0).click_input(),
                    lambda: notes_dlg.child_window(auto_id="btnOK",   found_index=0).click_input(),
                    lambda: notes_dlg.child_window(title="Save",  control_type="Button").click_input(),
                    lambda: notes_dlg.child_window(title="OK",    control_type="Button").click_input(),
                    lambda: notes_dlg.child_window(title="Close", control_type="Button").click_input(),
                ]:
                    try:
                        _save_fn()
                        time.sleep(T_SHORT)
                        break
                    except Exception:
                        pass
                if entered:
                    log.info("    Notes: entered")
                else:
                    log.warning("    [warn] FormCustomerNotes open but text field unknown — probe needed")
            else:
                log.warning("    [warn] FormCustomerNotes not found after btnAdd — probe needed")
        except Exception as e:
            log.warning("    [warn] Notes not set: %s", e)

    toolbar_click(dlg, "Save")
    dismiss_validation(get_app())
    log.info("    [saved] MBI %s", mask_mbi(p["mbi"]))


def create_customer(p, main_win, a):
    dlg = open_fresh_window(main_win, a, "Customer", "Maintain->Customer")
    if not dlg:
        raise RuntimeError("Customer window not found")
    try:
        go_work_area(dlg)
        toolbar_click(dlg, "New")
        time.sleep(T_MED)
        dismiss_save_dialog(get_app())
        dlg = main_win.child_window(auto_id="FormCustomer", control_type="Window", found_index=0)
        _fill_customer_form(dlg, p, main_win)
    except Exception:
        log.error("    Error mid-form for MBI %s — closing window", mask_mbi(p["mbi"]))
        try:
            _close_customer(main_win)
        except Exception:
            pass
        raise
    _close_customer(main_win)


def update_customer(p, main_win, a, groups=None):
    dlg_w = open_fresh_window(main_win, a, "Customer", "Maintain->Customer")
    if not dlg_w:
        raise RuntimeError("Customer window not found")
    try:
        if not _search_and_open_work_area(dlg_w, p["last"]):
            log.warning("    [warn] Could not open existing customer '%s' in UI", p["last"])
            _close_customer(main_win)
            return
        dlg = main_win.child_window(auto_id="FormCustomer", control_type="Window", found_index=0)
        _fill_customer_form(dlg, p, main_win, is_update=True, groups=groups)
    except Exception:
        log.error("    Error updating MBI %s — closing window", mask_mbi(p["mbi"]))
        try:
            _close_customer(main_win)
        except Exception:
            pass
        raise
    _close_customer(main_win)


def ensure_all_customers(a, main_win, existing_mbis):
    log.info("")
    log.info("=" * 52)
    log.info("[3/3] PATIENTS")
    log.info("=" * 52)
    log.info("DB check: %d/%d patient(s) already exist", len(existing_mbis), len(PATIENTS))

    to_create = [p for p in PATIENTS if p["mbi"] not in existing_mbis]
    to_update = [p for p in PATIENTS if p["mbi"] in existing_mbis]

    patient_rows = db.verify_patients(to_update) if to_update and not DRY_RUN else {}

    dismiss_popup(a)
    for p in to_update:
        label = f"MBI {mask_mbi(p['mbi'])}"
        log.info("")
        if DRY_RUN:
            log.info("  [UPDATE] %s", label)
            log.info("    [DRY RUN] skipping UI — would update patient")
            continue
        if MODE == "test":
            groups = None
            log.info("  [UPDATE] %s — all fields (test mode)", label)
        else:
            row = patient_rows.get(p["mbi"])
            if row:
                notes_needed = False
                if p.get("notes") and row.get("customer_id"):
                    existing = {r["Notes"] for r in db.verify_patient_notes(row["customer_id"])}
                    notes_needed = p["notes"] not in existing
                elif p.get("notes"):
                    notes_needed = True
                groups = _patient_diff_groups(p, row, notes_needed)
                if not groups:
                    log.info("  [OK]     %s — no changes needed", label)
                    continue
                log.info("  [UPDATE] %s — %s", label, sorted(groups))
            else:
                groups = None
                log.info("  [UPDATE] %s", label)
        try:
            update_customer(p, main_win, a, groups)
            if p.get("_notion_page_id") and MODE == "run":
                try:
                    notion.mark_in_dmeworks(_token, p["_notion_page_id"])
                except Exception:
                    _notion_retry.append(p["_notion_page_id"])
        except Exception as e:
            log.error("  [ERROR]  %s — %s", label, e)

    for i, p in enumerate(to_create, 1):
        label = f"MBI {mask_mbi(p['mbi'])}"
        set_status(f"[3/3] Patient {i}/{len(to_create)}: MBI {mask_mbi(p['mbi'])}")
        log.info("")
        log.info("  [CREATE] %s", label)
        if DRY_RUN:
            log.info("    [DRY RUN] skipping UI — would create patient")
            continue
        try:
            create_customer(p, main_win, a)
            if p.get("_notion_page_id") and MODE == "run":
                try:
                    notion.mark_in_dmeworks(_token, p["_notion_page_id"])
                    log.info("    [notion] Status → In DMEworks")
                except Exception:
                    log.warning("    [notion] Status update failed — add to retry list")
                    _notion_retry.append(p["_notion_page_id"])
        except Exception as e:
            log.error("  [ERROR]  %s — %s", label, e)

# ─── AUDIT ────────────────────────────────────────────────────────────────────

def run_audit():
    log.info("")
    log.info("=" * 52)
    log.info("AUDIT — Notion vs DB field comparison")
    log.info("=" * 52)
    set_status("Audit — querying DB...")

    total_issues = 0

    log.info("")
    log.info("Doctors (%d):", len(DOCTORS))
    for doc in DOCTORS:
        npi   = doc.get("npi", "")
        label = f"NPI {npi}"
        db_row = db.verify_doctor(npi)
        if not db_row:
            log.warning("  [MISSING] %s — not found in DB", label)
            total_issues += 1
            continue
        groups = _doctor_diff_groups(doc, db_row)
        if groups:
            log.warning("  [DIFF]   %s — %s", label, sorted(groups))
            total_issues += 1
        else:
            log.info("  [OK]     %s", label)

    log.info("")
    log.info("Patients (%d):", len(PATIENTS))
    patient_rows = db.verify_patients(PATIENTS)
    for p in PATIENTS:
        label = f"MBI {mask_mbi(p['mbi'])}"
        row   = patient_rows.get(p["mbi"])
        if not row:
            log.warning("  [MISSING] %s — not found in DB", label)
            total_issues += 1
            continue
        notes_needed = False
        if p.get("notes") and row.get("customer_id"):
            existing     = {r["Notes"] for r in db.verify_patient_notes(row["customer_id"])}
            notes_needed = p["notes"] not in existing
        elif p.get("notes"):
            notes_needed = True
        groups = _patient_diff_groups(p, row, notes_needed)
        if groups:
            log.warning("  [DIFF]   %s — %s", label, sorted(groups))
            total_issues += 1
        else:
            log.info("  [OK]     %s", label)

    log.info("")
    log.info("=" * 52)
    if total_issues:
        log.warning("AUDIT RESULT: %d issue(s) found — run --mode fix to correct", total_issues)
    else:
        log.info("AUDIT RESULT: ALL MATCH — no discrepancies found")
    log.info("=" * 52)


# ─── VERIFICATION PASS ────────────────────────────────────────────────────────

def run_verification():
    log.info("")
    log.info("=" * 52)
    log.info("VERIFICATION PASS")
    log.info("=" * 52)
    set_status("Verifying — querying DB...")

    with ThreadPoolExecutor(max_workers=4) as pool:
        f_npis    = pool.submit(db.fetch_matching_npis,            [d["npi"]  for d in DOCTORS])
        f_names   = pool.submit(db.fetch_matching_insurance_names, [c["name"] for c in INSURANCE_COMPANIES])
        f_mbis    = pool.submit(db.fetch_matching_mbis,            [p["mbi"]  for p in PATIENTS])
        f_details = pool.submit(db.verify_patients, PATIENTS)
        existing_npis   = f_npis.result()
        existing_names  = f_names.result()
        existing_mbis   = f_mbis.result()
        patient_details = f_details.result()

    all_pass = True

    log.info("")
    log.info("  Doctors (%d):", len(DOCTORS))
    for doc in DOCTORS:
        if doc["npi"] in existing_npis:
            log.info("    [PASS] NPI %s found", doc["npi"])
        else:
            log.error("    [FAIL] NPI %s NOT in DB", doc["npi"])
            all_pass = False

    log.info("")
    log.info("  Insurance Companies (%d):", len(INSURANCE_COMPANIES))
    for co in INSURANCE_COMPANIES:
        if co["name"].lower() in existing_names:
            log.info("    [PASS] %s", co["name"])
        else:
            log.error("    [FAIL] %s — NOT in DB", co["name"])
            all_pass = False

    log.info("")
    log.info("  Patients (%d):", len(PATIENTS))
    for p in PATIENTS:
        label = f"MBI {mask_mbi(p['mbi'])}"
        if p["mbi"] not in existing_mbis:
            log.error("    [FAIL] %s — NOT in DB", label)
            all_pass = False
            continue

        row = patient_details.get(p["mbi"])
        if not row:
            log.warning("    [WARN] %s — MBI found but no joined row", label)
            all_pass = False
            continue

        issues = []
        if row["first"].strip().lower() != p["first"].lower():
            issues.append("FirstName mismatch")
        if row["last"].strip().lower() != p["last"].lower():
            issues.append("LastName mismatch")

        dob_db = row["dob"]
        dob_db_str = dob_db.strftime("%m/%d/%Y") if hasattr(dob_db, "strftime") else str(dob_db)
        if dob_db_str != p["dob"]:
            issues.append("DOB mismatch")

        if (row["state"] or "").strip().upper() != p["state"].upper():
            issues.append(f"State DB='{row['state']}' record='{p['state']}'")

        expected_npi = (p.get("_doctor") or {}).get("npi")
        actual_npi   = (row.get("doctor_npi") or "").strip()
        if expected_npi:
            if actual_npi != expected_npi:
                issues.append(f"Doctor NPI DB='{actual_npi}' expected='{expected_npi}'")
        elif not actual_npi:
            issues.append("no doctor assigned (Doctor1_ID is NULL)")

        db_gender = (row.get("gender") or "").strip()
        exp_gender = p.get("gender") or "Male"
        if db_gender != exp_gender:
            issues.append(f"Gender DB='{db_gender}' expected='{exp_gender}'")

        db_codes = {
            row.get(f"icd10_{i:02d}")
            for i in range(1, 13)
            if row.get(f"icd10_{i:02d}")
        }
        for code in p.get("icd10", []):
            if code not in db_codes:
                issues.append(f"ICD10 '{code}' missing in DB")

        def _s(v):
            return (v or "").strip()

        if _s(row.get("mi")).lower() != _s(p.get("mi")).lower():
            issues.append(f"MI DB='{_s(row.get('mi'))}' expected='{_s(p.get('mi'))}'")
        if _s(row.get("suffix")).lower() != _s(p.get("suffix")).lower():
            issues.append(f"Suffix DB='{_s(row.get('suffix'))}' expected='{_s(p.get('suffix'))}'")
        if _s(row.get("address1")).lower() != _s(p.get("address1")).lower():
            issues.append("Address1 mismatch")
        if _s(row.get("city")).lower() != _s(p.get("city")).lower():
            issues.append("City mismatch")
        if _s(row.get("zip")) != _s(p.get("zip")):
            issues.append(f"ZIP DB='{_s(row.get('zip'))}' expected='{_s(p.get('zip'))}'")

        db_digits     = "".join(c for c in _s(row.get("phone")) if c.isdigit())
        notion_digits = "".join(c for c in _s(p.get("phone")) if c.isdigit())
        if db_digits != notion_digits:
            issues.append(f"Phone DB='{db_digits}' expected='{notion_digits}'")

        for field in ("height", "weight"):
            db_val     = row.get(field)
            notion_val = p.get(field, "")
            if db_val is None and not notion_val:
                pass
            else:
                try:
                    if round(float(db_val or 0), 1) != round(float(notion_val or 0), 1):
                        issues.append(f"{field.title()} DB='{db_val}' expected='{notion_val}'")
                except (ValueError, TypeError):
                    issues.append(f"{field.title()} comparison failed (DB='{db_val}' Notion='{notion_val}')")

        if p.get("notes") and row.get("customer_id"):
            notes_rows = db.verify_patient_notes(row["customer_id"])
            notes_texts = [r["Notes"] for r in notes_rows]
            if p["notes"] not in notes_texts:
                issues.append(f"notes not found in tbl_customer_notes (got {len(notes_rows)} row(s))")

        if issues:
            for issue in issues:
                log.warning("    [WARN] %s — %s", label, issue)
            all_pass = False
        else:
            log.info("    [PASS] %s — all fields match, doctor assigned, notes verified", label)

    log.info("")
    if all_pass:
        log.info("  RESULT: ALL CHECKS PASSED")
    else:
        log.warning("  RESULT: SOME CHECKS FAILED — review above and verify in DMEworks")
    log.info("=" * 52)

# ─── MAIN ─────────────────────────────────────────────────────────────────────

def main():
    if MODE == "test":
        log.info("*** TEST MODE — test records only, target: c02 ***")
        set_status("Test — full UI entry + DB verify")
        log.info("=" * 52)
        log.info("DMEworks Test — all fields forced, test doctor/patient")
        log.info("=" * 52)

        log.info("")
        log.info("Running DB existence checks (c02)...")
        with ThreadPoolExecutor(max_workers=3) as pool:
            f_npis  = pool.submit(db.fetch_matching_npis,            [d["npi"]  for d in DOCTORS])
            f_names = pool.submit(db.fetch_matching_insurance_names, [c["name"] for c in INSURANCE_COMPANIES])
            f_mbis  = pool.submit(db.fetch_matching_mbis,            [p["mbi"]  for p in PATIENTS])
            existing_npis  = f_npis.result()
            existing_names = f_names.result()
            existing_mbis  = f_mbis.result()

        need_doctors  = sum(1 for d in DOCTORS if d["npi"] not in existing_npis)
        need_patients = sum(1 for p in PATIENTS if p["mbi"] not in existing_mbis)
        log.info("Need to create: %d doctor(s), %d patient(s)", need_doctors, need_patients)

        log.info("")
        log.info("Connecting to DMEworks...")
        a, main_win = get_main()
        log.info("Connected")
        dismiss_popup(a)

        ensure_all_doctors(a, main_win, existing_npis)
        ensure_all_insurance_companies(a, main_win, existing_names)
        ensure_all_customers(a, main_win, existing_mbis)

        run_verification()

        set_status("Test DONE — check log for PASS/FAIL")
        log.info("")
        log.info("=" * 52)
        log.info("TEST DONE")
        log.info("=" * 52)
        return

    if MODE == "audit":
        log.info("*** AUDIT MODE — read-only, no UI, no writes ***")
        set_status("Audit — comparing Notion vs DB...")
        log.info("=" * 52)
        log.info("DMEworks Audit — %d doctor(s), %d patient(s)", len(DOCTORS), len(PATIENTS))
        log.info("=" * 52)
        run_audit()
        set_status("Audit DONE — check log for discrepancies")
        return

    if MODE == "fix":
        log.info("*** FIX MODE — 'In DMEworks' patients, targeted field corrections ***")
    elif DRY_RUN:
        log.info("*** DRY RUN MODE — no changes will be made to DMEworks ***")

    mode_label = "Fix" if MODE == "fix" else "Run"
    set_status(f"{mode_label} — Allied ({len(PATIENTS)} patients)")
    log.info("=" * 52)
    log.info("DMEworks %s — Allied (%d patients)", mode_label, len(PATIENTS))
    log.info("=" * 52)

    log.info("")
    log.info("Pre-validating data...")
    errors = validate_csv()
    if errors:
        log.error("Validation failed — fix before running:")
        for err in errors:
            log.error("  %s", err)
        sys.exit(1)
    log.info("Validation passed (%d doctors, %d companies, %d patients)",
             len(DOCTORS), len(INSURANCE_COMPANIES), len(PATIENTS))

    log.info("")
    log.info("Running DB existence checks...")
    set_status("Checking DB...")
    with ThreadPoolExecutor(max_workers=3) as pool:
        f_npis  = pool.submit(db.fetch_matching_npis,            [d["npi"]  for d in DOCTORS])
        f_names = pool.submit(db.fetch_matching_insurance_names, [c["name"] for c in INSURANCE_COMPANIES])
        f_mbis  = pool.submit(db.fetch_matching_mbis,            [p["mbi"]  for p in PATIENTS])
        existing_npis  = f_npis.result()
        existing_names = f_names.result()
        existing_mbis  = f_mbis.result()

    need_doctors  = sum(1 for d in DOCTORS if d["npi"] not in existing_npis)
    need_ins      = sum(1 for c in INSURANCE_COMPANIES
                        if c["name"].lower() not in existing_names and c["type"] != "MEDICARE")
    need_patients = sum(1 for p in PATIENTS if p["mbi"] not in existing_mbis)
    log.info("Need to create: %d doctor(s), %d insurance company(s), %d patient(s)",
             need_doctors, need_ins, need_patients)

    if not DRY_RUN and (need_doctors or need_ins or need_patients):
        log.info("")
        log.info("Connecting to DMEworks...")
        a, main_win = get_main()
        log.info("Connected")
    else:
        a, main_win = None, None

    ensure_all_doctors(a, main_win, existing_npis)
    ensure_all_insurance_companies(a, main_win, existing_names)
    ensure_all_customers(a, main_win, existing_mbis)

    if not DRY_RUN:
        run_verification()

    if _notion_retry:
        log.warning("")
        log.warning("  %d patient(s) need manual Notion status update (→ 'In DMEworks'):", len(_notion_retry))
        for pid in _notion_retry:
            log.warning("    notion.so/page/%s", pid)

    set_status(f"{mode_label} DONE — verify records in DMEworks")
    log.info("")
    log.info("=" * 52)
    log.info("%s DONE", mode_label)
    if not DRY_RUN:
        log.info("Manual spot-check in DMEworks:")
        log.info("  General   : name, DOB, address, phone")
        log.info("  Contacts  : Doctor1 assigned")
        log.info("  Diagnosis : ICD-10 codes")
        log.info("  Insurance : Medicare DMERC + MBI, secondary if applicable")
    flagged = [p for p in PATIENTS if p.get("notes")]
    if flagged:
        log.info("")
        log.warning("  %d patient(s) have notes — review in Notion", len(flagged))
    log.info("=" * 52)


def run():
    main()


if __name__ == "__main__":
    run()
