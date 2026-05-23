"""
DMEworks Entry TEST — synthetic test record only.
Safe to re-run. All data is fake — for automation verification only.

Usage:
  python entry_test.py [--client test]
  python entry_test.py [--client test] --dry-run

Prerequisites: DMEworks open on main screen, all child windows closed.
"""

import os
import sys
import time
from pywinauto import Application, keyboard

_ROOT = os.path.dirname(os.path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from utils import db, notion
from utils.creds import get_notion_token
from utils.logger import get_logger, mask_mbi, mask_dob

log = get_logger("dmeworks.test")

# ─── ARGS ─────────────────────────────────────────────────────────────────────

def _parse_args():
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--client",  default="test", help="Client code (default: test)")
    p.add_argument("--dry-run", action="store_true")
    return p.parse_args()

ARGS = _parse_args()
DRY_RUN = ARGS.dry_run

# ─── SYNTHETIC TEST DATA ──────────────────────────────────────────────────────

TEST_DOCTOR = {
    "last": "TestDoctor", "first": "Test", "mi": "", "suffix": "MD",
    "npi": "1234567893",
    "address1": "1 Test Street", "city": "Testville", "state": "NJ",
    "zip": "00001", "phone": "0000000000",
}

TEST_PATIENT = {
    "last": "TestPatient", "first": "Test", "mi": "", "suffix": "",
    "dob": "01/01/1940", "mbi": "1EG4TE5MK73",
    "address1": "1 Test Ave", "city": "Testville", "state": "NJ",
    "zip": "00001", "phone": "0000000000",
    "doctor": "TestDoctor",
    "icd10": ["M54.50", "M23.51"],
    "secondary": None, "notes": "",
}

_token            = get_notion_token()
INSURANCE_BY_STATE = notion.fetch_insurance_map(_token)

try:
    db.configure(ARGS.client, _token)
except Exception as e:
    log.warning("DB config not found for client '%s' — DB checks will be skipped: %s", ARGS.client, e)
    import utils.db as _db_mod
    _db_mod._conn_params = None

T_SHORT = 0.5
T_MED   = 1.0
T_LONG  = 1.8

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

def set_combo_text(pane, value, main_win=None):
    if not value:
        return
    if main_win:
        try:
            pane.child_window(auto_id="btnFind", found_index=0).click_input()
            time.sleep(T_LONG)
            sel = find_mdi_child(main_win, "Select")
            if not sel:
                for win in get_app().windows():
                    try:
                        if "Select" in win.window_text():
                            sel = win; break
                    except Exception:
                        pass
            if sel:
                sel.child_window(control_type="Edit", found_index=0).set_edit_text(value)
                time.sleep(T_MED)
                sel.child_window(title="OK", control_type="Button").click_input()
                time.sleep(T_MED)
                return
        except Exception as e:
            log.warning("set_combo_text binoculars('%s'): %s", value, e)
    try:
        combo = pane.child_window(auto_id="cmbInternal", found_index=0)
        combo.click_input(); time.sleep(0.5)
        try:
            combo.select(value); time.sleep(0.5); return
        except Exception:
            pass
        combo.type_keys("^a", with_spaces=False); time.sleep(0.2)
        combo.type_keys(value, with_spaces=True); time.sleep(0.8)
        combo.type_keys("{ENTER}"); time.sleep(0.5)
    except Exception as e:
        log.warning("set_combo_text fallback('%s'): %s", value, e)

def set_dob(win, dob_str):
    try:
        dob = win.child_window(auto_id="dtbDateofBirth", found_index=0)
        rect = dob.wrapper_object().rectangle()
        h = rect.bottom - rect.top
        dob.click_input(coords=(6, h // 2))
        time.sleep(0.4)
        for _ in range(4):
            keyboard.send_keys("{LEFT}"); time.sleep(0.05)
        time.sleep(0.2)
        mm, dd, yyyy = dob_str.split("/")
        keyboard.send_keys(mm); time.sleep(0.3)
        keyboard.send_keys(dd); time.sleep(0.3)
        keyboard.send_keys(yyyy); time.sleep(0.3)
    except Exception as e:
        log.warning("set_dob: %s", e)

# ─── DOCTOR ───────────────────────────────────────────────────────────────────

def ensure_doctor(doc, main_win, a):
    label = f"{doc['first']} {doc['last']} (NPI {doc['npi']})"
    log.info("[1/3] Doctor: %s", label)

    if db.fetch_matching_npis([doc["npi"]]):
        log.info("  [SKIP]   %s — already in DB", label)
        return

    log.info("  [CREATE] %s — not found", label)
    if DRY_RUN:
        log.info("  [DRY RUN] skipping UI")
        return

    w = open_fresh_window(main_win, a, "Doctor", "Maintain->Doctor")
    if not w:
        log.error("  Doctor window not found"); return

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
        set_field(w, "txtCity",     doc["city"])
        set_field(w, "txtState",    doc["state"])
        set_field(w, "txtZip",      doc["zip"])
        set_field(w, "txtPhone",    fmt_phone(doc["phone"]))

        click_inner_tab(w, "Numbers")
        set_field(w, "txtNPI", doc["npi"])

        toolbar_click(w, "Save")
        dismiss_validation(get_app())
        log.info("  [saved] %s", label)
    except Exception as e:
        log.error("  Error creating doctor — closing window: %s", e)
        try:
            close_window(main_win, "Doctor")
        except Exception:
            pass
        return

    close_window(main_win, "Doctor")
    time.sleep(T_SHORT)

# ─── INSURANCE COMPANY ────────────────────────────────────────────────────────

def ensure_insurance_company(name, main_win, a, is_medicare=False):
    log.info("[2/3] Insurance: %s", name)

    if db.fetch_matching_insurance_names([name]):
        tag = "verified" if is_medicare else "already in DB"
        log.info("  [SKIP]   %s — %s", name, tag)
        return

    if is_medicare:
        log.error("  [ERROR]  '%s' not found — must be created manually", name)
        return

    log.info("  [CREATE] %s", name)
    if DRY_RUN:
        log.info("  [DRY RUN] skipping UI")
        return

    w = open_fresh_window(main_win, a, "Insurance Company",
                          "Maintain->Insurance Company")
    if not w:
        log.error("  Insurance Company window not found"); return

    try:
        go_work_area(w)
        toolbar_click(w, "New")
        time.sleep(T_MED)
        dismiss_save_dialog(get_app())
        w = find_mdi_child(main_win, "Insurance Company")
        set_field(w, "txtName", name)
        toolbar_click(w, "Save")
        dismiss_validation(get_app())
        log.info("  [saved] %s", name)
    except Exception as e:
        log.error("  Error creating insurance company — closing window: %s", e)
        try:
            close_window(main_win, "Insurance Company")
        except Exception:
            pass
        return

    close_window(main_win, "Insurance Company")
    time.sleep(T_SHORT)

# ─── CUSTOMER ─────────────────────────────────────────────────────────────────

def enter_customer(p, main_win, a):
    label = f"{p['first']} {p['last']} (MBI {mask_mbi(p['mbi'])})"
    log.info("[3/3] Patient: %s", label)

    if db.fetch_matching_mbis([p["mbi"]]):
        log.info("  [SKIP]   %s — already in DB", label)
        return

    log.info("  [CREATE] %s", label)
    if DRY_RUN:
        log.info("  [DRY RUN] skipping UI")
        return

    medicare_name = INSURANCE_BY_STATE.get(p["state"])
    if not medicare_name:
        log.error("  No DMERC mapping for state '%s'", p["state"]); return

    dlg = open_fresh_window(main_win, a, "Customer", "Maintain->Customer")
    if not dlg:
        log.error("  Customer window not found"); return

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
        set_field(dlg, "txtCity",     p["city"])
        set_field(dlg, "txtState",    p["state"])
        set_field(dlg, "txtZip",      p["zip"])
        set_field(dlg, "txtPhone",    fmt_phone(p["phone"]))
        log.info("    General: %s, %s %s | DOB %s", p["city"], p["state"], p["zip"], mask_dob(p["dob"]))

        click_inner_tab(dlg, "Contacts")
        contacts_pane = dlg.child_window(auto_id="tpContacts", found_index=0)
        set_combo_text(contacts_pane.child_window(auto_id="cmbDoctor1", found_index=0),
                       TEST_DOCTOR["address1"], main_win)
        log.info("    Doctor: %s (filtered by address)", p["doctor"])

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
            try:
                set_combo_text(pol.child_window(auto_id="cmbInsuranceCompany",
                                                found_index=0), medicare_name, main_win)
                set_combo_text(pol.child_window(auto_id="cmbInsuranceType",
                                                found_index=0), "MEDICARE", main_win)
                set_field(pol, "txtPolicyNumber", p["mbi"])
                pol.child_window(auto_id="btnOK", found_index=0).click_input()
                time.sleep(T_MED)
                dismiss_validation(get_app())
                log.info("    Primary: %s | MBI %s", medicare_name, mask_mbi(p["mbi"]))
            except Exception as e:
                log.error("    Policy dialog failed: %s", e)
                try:
                    pol.child_window(auto_id="btnCancel", found_index=0).click_input()
                except Exception:
                    pass
        else:
            log.error("    Policy Information dialog not found")

        toolbar_click(dlg, "Save")
        dismiss_validation(get_app())
        log.info("  [saved] %s", label)

    except Exception as e:
        log.error("  Error mid-form — closing window: %s", e)
        try:
            close_window(main_win, "Customer")
        except Exception:
            pass
        return

    close_window(main_win, "Customer")

# ─── MAIN ─────────────────────────────────────────────────────────────────────

def main():
    if DRY_RUN:
        log.info("*** DRY RUN MODE — no changes will be made to DMEworks ***")

    log.info("=" * 52)
    log.info("DMEworks TEST — synthetic test record (client: %s)", ARGS.client)
    log.info("=" * 52)

    medicare_name = INSURANCE_BY_STATE.get(TEST_PATIENT["state"])
    if not medicare_name:
        log.error("No DMERC mapping for test patient state '%s'", TEST_PATIENT["state"])
        sys.exit(1)

    a, main_win = get_main()
    dismiss_popup(a)

    ensure_doctor(TEST_DOCTOR, main_win, a)
    ensure_insurance_company(medicare_name, main_win, a, is_medicare=True)
    enter_customer(TEST_PATIENT, main_win, a)

    log.info("")
    log.info("=" * 52)
    log.info("TEST COMPLETE — verify in DMEworks:")
    log.info("  Doctor   : %s %s, NPI %s",
             TEST_DOCTOR["first"], TEST_DOCTOR["last"], TEST_DOCTOR["npi"])
    log.info("  Insurance: %s", medicare_name)
    log.info("  Patient  : %s %s | DOB %s | MBI %s",
             TEST_PATIENT["first"], TEST_PATIENT["last"],
             mask_dob(TEST_PATIENT["dob"]), mask_mbi(TEST_PATIENT["mbi"]))
    log.info("=" * 52)


def run():
    main()


if __name__ == "__main__":
    run()
