"""
DMEworks Patient Entry.
Safe to re-run. Skips any record that already exists in the DB.

Usage:
  python entry_all.py --client <code>
  python entry_all.py --client <code> --dry-run

Prerequisites: DMEworks open on main screen, all child windows closed.
Run 'python manage_clients.py list' to see available client codes.
"""

import os
import queue
import sys
import threading
import time
import tkinter as tk
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
    p = argparse.ArgumentParser()
    p.add_argument("--client",  default=None, help="Client code")
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--setup",   action="store_true",
                   help="Store Notion token and DB credentials (run once on each machine)")
    return p.parse_args()

ARGS    = _parse_args()
DRY_RUN = ARGS.dry_run

# ─── SETUP MODE ───────────────────────────────────────────────────────────────

if ARGS.setup:
    from entry_setup import run_setup
    run_setup()
    sys.exit(0)

if not ARGS.client:
    print("error: --client is required (or use --setup for first-time credential setup)")
    sys.exit(1)

# ─── LOAD CLIENT DATA ─────────────────────────────────────────────────────────

from utils import notion
from utils.creds import get_notion_token

_token            = get_notion_token()
INSURANCE_BY_STATE = notion.fetch_insurance_map(_token)
_raw               = notion.fetch_work_queue(_token)

# Unique doctors by NPI
_seen_npis: set[str] = set()
DOCTORS: list[dict]  = []
for _p in _raw:
    _d   = _p.get("_doctor", {})
    _npi = _d.get("npi", "")
    if _npi and _npi not in _seen_npis:
        _seen_npis.add(_npi)
        DOCTORS.append(_d)

PATIENTS: list[dict] = _raw

# Derive insurance companies from patient states + secondary fields
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

db.configure(ARGS.client, _token)

# ─── STATUS OVERLAY ───────────────────────────────────────────────────────────

_status_q: queue.Queue = queue.Queue()
_notion_retry: list[str] = []


def _overlay_thread() -> None:
    root = tk.Tk()
    root.title("DMEworks")
    root.attributes("-topmost", True)
    root.attributes("-alpha", 0.93)
    root.geometry("340x64+10+10")
    root.configure(bg="#1a1a2e")
    root.resizable(False, False)

    lbl = tk.Label(root, text="Initializing...", bg="#1a1a2e", fg="#e0e0ff",
                   font=("Consolas", 10, "bold"), wraplength=318,
                   justify="left", anchor="w")
    lbl.pack(expand=True, fill="both", padx=10, pady=10)

    def _poll() -> None:
        try:
            while True:
                msg = _status_q.get_nowait()
                if msg is None:
                    root.destroy()
                    return
                lbl.config(text=msg)
        except queue.Empty:
            pass
        root.after(150, _poll)

    root.after(150, _poll)
    root.mainloop()


def set_status(msg: str) -> None:
    _status_q.put(msg)


T_SHORT = 0.5
T_MED   = 1.0
T_LONG  = 1.8

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
        if p.exists(timeout=1):
            p.child_window(title="Close", control_type="Button").click_input()
            time.sleep(T_SHORT)
    except Exception:
        pass

def dismiss_save_dialog(a):
    try:
        main = a.window(title="DMEWorks", auto_id="FormMain")
        no_btn = main.child_window(title="No", control_type="Button")
        if no_btn.exists(timeout=1):
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
            if dlg.exists(timeout=1):
                log.warning("Validation dialog: %s", dlg.window_text())
                dlg.child_window(title="OK", control_type="Button").click_input()
                time.sleep(T_SHORT)
                return True
        except Exception:
            pass
    return False

def find_mdi_child(main, keyword):
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

def set_field(win, auto_id, value):
    if not value:
        return
    try:
        win.child_window(auto_id=auto_id, found_index=0).set_edit_text(value)
        time.sleep(0.2)
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

def open_fresh_window(main_win, a, keyword, menu_path):
    if find_mdi_child(main_win, keyword):
        close_window(main_win, keyword)
        time.sleep(T_MED)
    a.top_window().menu_select(menu_path)
    time.sleep(T_LONG)
    dismiss_save_dialog(a)
    dismiss_popup(a)
    return find_mdi_child(main_win, keyword)

def go_work_area(w):
    try:
        w.child_window(auto_id="PageControl", control_type="Tab",
                       found_index=0).child_window(
            title="Work Area", control_type="TabItem").click_input()
        time.sleep(T_MED)
    except Exception as e:
        log.warning("go_work_area: %s", e)

def click_inner_tab(w, title):
    w.child_window(auto_id="TabControl1", control_type="Tab",
                   found_index=0).child_window(
        title=title, control_type="TabItem").click_input()
    time.sleep(T_MED)

# ─── COMBO AND DOB ────────────────────────────────────────────────────────────

def set_combo_text(pane, value):
    if not value:
        return
    try:
        combo = pane.child_window(auto_id="cmbInternal", found_index=0)
        combo.click_input()
        time.sleep(0.5)
        try:
            combo.select(value)
            time.sleep(0.5)
            return
        except Exception:
            pass
        combo.type_keys("^a", with_spaces=False)
        time.sleep(0.2)
        combo.type_keys(value, with_spaces=True)
        time.sleep(0.8)
        combo.type_keys("{ENTER}")
        time.sleep(0.5)
    except Exception as e:
        log.warning("set_combo_text('%s'): %s", value, e)

def set_dob(win, dob_str):
    try:
        dob = win.child_window(auto_id="dtbDateofBirth", found_index=0)
        rect = dob.wrapper_object().rectangle()
        h = rect.bottom - rect.top
        dob.click_input(coords=(6, h // 2))
        time.sleep(0.4)
        for _ in range(4):
            keyboard.send_keys("{LEFT}")
            time.sleep(0.05)
        time.sleep(0.2)
        mm, dd, yyyy = dob_str.split("/")
        keyboard.send_keys(mm)
        time.sleep(0.3)
        keyboard.send_keys(dd)
        time.sleep(0.3)
        keyboard.send_keys(yyyy)
        time.sleep(0.3)
    except Exception as e:
        log.warning("set_dob: %s", e)

# ─── DOCTORS ──────────────────────────────────────────────────────────────────

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

        click_inner_tab(w, "Address")
        set_field(w, "txtAddress1", doc["address1"])
        set_field(w, "txtAddress2", doc["address2"])
        set_field(w, "txtCity",     doc["city"])
        set_field(w, "txtState",    doc["state"])
        set_field(w, "txtZip",      doc["zip"])
        set_field(w, "txtPhone",    fmt_phone(doc["phone"]))

        click_inner_tab(w, "Numbers")
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


def ensure_all_doctors(a, main_win, existing_npis):
    log.info("")
    log.info("=" * 52)
    log.info("[1/3] DOCTORS")
    log.info("=" * 52)
    log.info("DB check: %d/%d doctor(s) already exist", len(existing_npis), len(DOCTORS))

    to_create = [d for d in DOCTORS if d["npi"] not in existing_npis]
    to_skip   = [d for d in DOCTORS if d["npi"] in existing_npis]

    for doc in to_skip:
        log.info("  [SKIP]   NPI %s", doc["npi"])

    if not to_create:
        log.info("  All doctors already in DB — nothing to do")
        return

    dismiss_popup(a)
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
    for i, co in enumerate(INSURANCE_COMPANIES, 1):
        name = co["name"]
        is_medicare = co["type"] == "MEDICARE"
        set_status(f"[2/3] Insurance {i}/{len(INSURANCE_COMPANIES)}: {name}")

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


def create_customer(p, main_win, a):
    medicare_name = INSURANCE_BY_STATE.get(p["state"])
    if not medicare_name:
        raise ValueError(f"No DMERC mapping for state '{p['state']}'")

    dlg = open_fresh_window(main_win, a, "Customer", "Maintain->Customer")
    if not dlg:
        raise RuntimeError("Customer window not found")

    try:
        go_work_area(dlg)
        toolbar_click(dlg, "New")
        time.sleep(T_MED)
        dismiss_save_dialog(get_app())
        dlg = main_win.child_window(auto_id="FormCustomer", control_type="Window",
                                    found_index=0)

        set_field(dlg, "txtLastName",   p["last"])
        set_field(dlg, "txtFirstName",  p["first"])
        set_field(dlg, "txtMiddleName", p["mi"])
        set_field(dlg, "txtSuffix",     p["suffix"])

        click_inner_tab(dlg, "General")
        set_dob(dlg, p["dob"])
        set_field(dlg, "txtAddress1", p["address1"])
        set_field(dlg, "txtAddress2", p["address2"])
        set_field(dlg, "txtCity",     p["city"])
        set_field(dlg, "txtState",    p["state"])
        set_field(dlg, "txtZip",      p["zip"])
        set_field(dlg, "txtPhone",    fmt_phone(p["phone"]))
        log.info("    General: %s, %s %s | DOB %s", p["city"], p["state"], p["zip"], mask_dob(p["dob"]))

        click_inner_tab(dlg, "Contacts")
        contacts_pane = dlg.child_window(auto_id="tpContacts", found_index=0)
        set_combo_text(contacts_pane.child_window(auto_id="cmbDoctor1", found_index=0),
                       p["doctor"])
        log.info("    Doctor: assigned")

        click_inner_tab(dlg, "Diagnosis")
        dlg.child_window(auto_id="TabControl2", control_type="Tab",
                         found_index=0).child_window(
            title="ICD 10", control_type="TabItem").click_input()
        time.sleep(T_MED)
        icd_pane = dlg.child_window(auto_id="TabPage3", found_index=0)
        for i, code in enumerate(p["icd10"], start=1):
            try:
                slot = icd_pane.child_window(auto_id=f"eddICD10_{i:02d}")
                slot.child_window(auto_id="txtInternal").set_edit_text(code)
                time.sleep(0.3)
            except Exception as e:
                log.warning("    ICD slot %d: %s", i, e)
        log.info("    ICD-10: %d code(s)", len(p["icd10"]))

        click_inner_tab(dlg, "Insurance")
        ins_pane  = dlg.child_window(auto_id="tpInsurance", found_index=0)
        ctrl_pane = ins_pane.child_window(auto_id="ControlCustomerInsurance1")

        ctrl_pane.child_window(auto_id="Panel1").child_window(
            auto_id="btnAdd").click_input()
        time.sleep(T_LONG)
        pol = find_mdi_child(main_win, "Policy Information")
        if pol:
            add_insurance_row(pol, medicare_name, "MEDICARE", p["mbi"])
        else:
            log.error("    Policy Information dialog not found (primary)")

        if p.get("secondary"):
            sec = p["secondary"]
            ctrl_pane.child_window(auto_id="Panel1").child_window(
                auto_id="btnAdd").click_input()
            time.sleep(T_LONG)
            pol2 = find_mdi_child(main_win, "Policy Information")
            if pol2:
                add_insurance_row(pol2, sec["ins_company"],
                                  sec["ins_type"], sec["policy"],
                                  sec.get("group", ""))
            else:
                log.error("    Policy Information dialog not found (secondary)")

        toolbar_click(dlg, "Save")
        dismiss_validation(get_app())
        log.info("    [saved] MBI %s", mask_mbi(p["mbi"]))

    except Exception:
        log.error("    Error mid-form for MBI %s — closing window", mask_mbi(p["mbi"]))
        try:
            close_window(main_win, "Customer")
        except Exception:
            pass
        raise

    close_window(main_win, "Customer")


def ensure_all_customers(a, main_win, existing_mbis):
    log.info("")
    log.info("=" * 52)
    log.info("[3/3] PATIENTS")
    log.info("=" * 52)
    log.info("DB check: %d/%d patient(s) already exist", len(existing_mbis), len(PATIENTS))

    to_create = [p for p in PATIENTS if p["mbi"] not in existing_mbis]
    to_skip   = [p for p in PATIENTS if p["mbi"] in existing_mbis]

    for p in to_skip:
        log.info("  [SKIP]   MBI %s", mask_mbi(p["mbi"]))

    if not to_create:
        log.info("  All patients already in DB — nothing to do")
        return

    dismiss_popup(a)
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
            if p.get("_notion_page_id"):
                try:
                    notion.mark_in_dmeworks(_token, p["_notion_page_id"])
                    log.info("    [notion] Status → In DMEworks")
                except Exception:
                    log.warning("    [notion] Status update failed — add to retry list")
                    _notion_retry.append(p["_notion_page_id"])
        except Exception as e:
            log.error("  [ERROR]  %s — %s", label, e)

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
            issues.append("FirstName mismatch (DB != record)")
        if row["last"].strip().lower() != p["last"].lower():
            issues.append("LastName mismatch (DB != record)")

        dob_db = row["dob"]
        dob_db_str = dob_db.strftime("%m/%d/%Y") if hasattr(dob_db, "strftime") else str(dob_db)
        if dob_db_str != p["dob"]:
            issues.append(f"DOB mismatch (DB vs record)")

        if (row["state"] or "").strip().upper() != p["state"].upper():
            issues.append(f"State DB='{row['state']}' record='{p['state']}'")

        if not row.get("doctor_npi"):
            issues.append("no doctor assigned (Doctor1_ID is NULL)")

        if issues:
            for issue in issues:
                log.warning("    [WARN] %s — %s", label, issue)
            all_pass = False
        else:
            log.info("    [PASS] %s — all fields match, doctor assigned", label)

    log.info("")
    if all_pass:
        log.info("  RESULT: ALL CHECKS PASSED")
    else:
        log.warning("  RESULT: SOME CHECKS FAILED — review above and verify in DMEworks")
    log.info("=" * 52)

# ─── MAIN ─────────────────────────────────────────────────────────────────────

def main():
    if DRY_RUN:
        log.info("*** DRY RUN MODE — no changes will be made to DMEworks ***")

    set_status(f"Starting — {ARGS.client} ({len(PATIENTS)} patients)")
    log.info("=" * 52)
    log.info("DMEworks Entry — %s (%d patients)", ARGS.client, len(PATIENTS))
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

    set_status("DONE — verify records in DMEworks")
    log.info("")
    log.info("=" * 52)
    log.info("DONE")
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


if __name__ == "__main__":
    _t = threading.Thread(target=_overlay_thread, daemon=True)
    _t.start()
    try:
        main()
    finally:
        _status_q.put(None)
        _t.join(timeout=3)
