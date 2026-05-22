"""
DMEworks Entry TEST - synthetic test record only.
Safe to re-run. All data is fake - for automation verification only.

Duplicate detection - cell value reading:
  get_value() on DataGridView cells returns actual record data.
  After searching, scan all result rows and check if any row's
  relevant cells match the target record.
  DMEworks shows all records when nothing matches, so we always
  get a populated grid - but the cell VALUES tell us if our
  target is actually in there.

Save to: C:\\ProgramData\\CybrEdge\\Scripts\\entry_test.py
"""

import os
import sys
import time
from pywinauto import Application, keyboard

_ROOT = os.path.dirname(os.path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from utils.data_loader import load_doctors, load_patients, load_medicare_map

T_SHORT = 0.5
T_MED   = 1.0
T_LONG  = 1.8

MEDICARE_BY_STATE = load_medicare_map()
TEST_DOCTOR       = load_doctors("test_doctors.csv")[0]
TEST_PATIENT      = load_patients("test_patients.csv")[0]

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
            print("    [save dialog] clicking No")
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
                print(f"    [validation] {dlg.window_text()}")
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
        print(f"    [warn] set_field({auto_id}): {e}")

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
        print(f"    [warn] close_window({keyword}): {e}")

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
        print(f"    [warn] go_work_area: {e}")

def click_inner_tab(w, title):
    w.child_window(auto_id="TabControl1", control_type="Tab",
                   found_index=0).child_window(
        title=title, control_type="TabItem").click_input()
    time.sleep(T_MED)

# ─── GRID CELL READING ────────────────────────────────────────────────────────

def get_cell_value(row, column_keyword):
    """
    Read actual value from a grid cell by matching a keyword against
    the cell's accessibility name (e.g. 'Last Name Row 0').
    Uses get_value() which returns real data - confirmed working.
    """
    try:
        for cell in row.children():
            cell_name = cell.window_text()
            # Match column keyword against the cell name, ignore the row index suffix
            if (column_keyword.lower() in cell_name.lower()
                    and "Row" in cell_name):
                try:
                    val = cell.get_value()
                    return (val or "").strip()
                except Exception:
                    return ""
    except Exception:
        pass
    return ""

def grid_has_match(w, column_checks):
    """
    Search the results grid for any row where ALL specified columns
    match their expected values (case-insensitive).
    Logs actual cell values read from each row for full transparency.
    """
    try:
        grid = w.child_window(title="DataGridView", control_type="Table",
                              found_index=0)
        data_rows = [c for c in grid.children()
                     if c.element_info.control_type == "Custom"
                     and c.window_text() != "Top Row"]

        print(f"    [grid] scanning {len(data_rows)} row(s) for {column_checks}")

        for ri, row in enumerate(data_rows):
            row_vals = {}
            all_match = True
            for col_kw, expected in column_checks.items():
                actual = get_cell_value(row, col_kw)
                row_vals[col_kw] = actual
                if actual.lower() != expected.lower():
                    all_match = False

            readable = ", ".join(f"{k}='{v}'" for k, v in row_vals.items())
            if all_match:
                print(f"    [grid] row {ri} MATCHED: {readable}")
                return True
            else:
                print(f"    [grid] row {ri} no match: {readable}")

        print(f"    [grid] no match in any row")
        return False
    except Exception as e:
        print(f"    [warn] grid_has_match: {e}")
        return False

def search_then_check(w, search_fields, column_checks):
    """Fill search fields, click Search, then check grid for matching cell values."""
    for auto_id, value in search_fields.items():
        set_field(w, auto_id, value)
    toolbar_click(w, "Search")
    dismiss_save_dialog(get_app())
    time.sleep(T_SHORT)
    return grid_has_match(w, column_checks)

# ─── COMBO ────────────────────────────────────────────────────────────────────

def select_via_binoculars(pane, value, main_win):
    """Click btnFind, type filter, click OK. Reliable exact selection."""
    if not value:
        return False
    try:
        pane.child_window(auto_id="btnFind", found_index=0).click_input()
        time.sleep(T_LONG)
        sel_dlg = find_mdi_child(main_win, "Select")
        if not sel_dlg:
            a = get_app()
            for win in a.windows():
                try:
                    if "Select" in win.window_text():
                        sel_dlg = win; break
                except Exception:
                    pass
        if not sel_dlg:
            print(f"    [warn] Select dialog not found for '{value}'")
            return False
        sel_dlg.child_window(control_type="Edit", found_index=0).set_edit_text(value)
        time.sleep(T_MED)
        sel_dlg.child_window(title="OK", control_type="Button").click_input()
        time.sleep(T_MED)
        return True
    except Exception as e:
        print(f"    [warn] select_via_binoculars('{value}'): {e}")
        return False

def set_combo_text(pane, value, main_win=None):
    """Use binoculars dialog if main_win provided, else direct combo."""
    if not value:
        return
    if main_win and select_via_binoculars(pane, value, main_win):
        return
    try:
        combo = pane.child_window(auto_id="cmbInternal", found_index=0)
        combo.click_input()
        time.sleep(0.5)
        try:
            combo.select(value); time.sleep(0.5); return
        except Exception:
            pass
        combo.type_keys("^a", with_spaces=False)
        time.sleep(0.2)
        combo.type_keys(value, with_spaces=True)
        time.sleep(0.8)
        combo.type_keys("{ENTER}")
        time.sleep(0.5)
    except Exception as e:
        print(f"    [warn] set_combo_text fallback('{value}'): {e}")

def set_dob(win, dob_str):
    """
    Enter DOB into a DateTimePicker. Clicks near the left edge to
    ensure focus lands on the Month segment, then types MM DD YYYY.
    DateTimePicker auto-advances between segments after each entry.
    """
    try:
        dob = win.child_window(auto_id="dtbDateofBirth", found_index=0)
        # Click near left edge to select Month segment (not Day or Year)
        rect = dob.wrapper_object().rectangle()
        h = rect.bottom - rect.top
        dob.click_input(coords=(6, h // 2))
        time.sleep(0.4)
        # Press LEFT multiple times to guarantee we're at the Month field
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
        print(f"    [warn] set_dob: {e}")

# ─── DOCTOR ───────────────────────────────────────────────────────────────────

def ensure_doctor(doc):
    label = f"{doc['first']} {doc['last']}, NPI {doc['npi']}"
    print(f"  Checking: {label}")

    a, main_win = get_main()
    dismiss_popup(a)
    w = open_fresh_window(main_win, a, "Doctor", "Maintain->Doctor")
    if not w:
        print("  [error] Doctor window not found"); return

    # Search by last name, verify Last Name + First Name + Address cells match
    found = search_then_check(w,
        search_fields={"txtLastName": doc["last"]},
        column_checks={"Last Name":  doc["last"],
                       "First Name": doc["first"],
                       "Address":    doc["address1"]})

    if found:
        print(f"  [skip] {label} already exists")
        close_window(main_win, "Doctor")
        return

    print(f"  [not found] creating {label}")
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
    print(f"  [saved] {label}")
    close_window(main_win, "Doctor")
    time.sleep(T_SHORT)

# ─── INSURANCE COMPANY ────────────────────────────────────────────────────────

def ensure_insurance_company(name, is_medicare=False):
    print(f"  Checking: {name}")

    a, main_win = get_main()
    dismiss_popup(a)
    w = open_fresh_window(main_win, a, "Insurance Company",
                          "Maintain->Insurance Company")
    if not w:
        print("  [error] Insurance Company window not found"); return

    # Search by name, verify Name cell matches exactly
    found = search_then_check(w,
        search_fields={"txtName": name},
        column_checks={"Name": name})

    if found:
        status = "[verified]" if is_medicare else "[skip]"
        print(f"  {status} {name} exists")
        close_window(main_win, "Insurance Company")
        return

    if is_medicare:
        print(f"  [ERROR] '{name}' not found. Must be set up manually.")
        close_window(main_win, "Insurance Company")
        return

    go_work_area(w)
    toolbar_click(w, "New")
    time.sleep(T_MED)
    dismiss_save_dialog(get_app())
    w = find_mdi_child(main_win, "Insurance Company")
    set_field(w, "txtName", name)
    toolbar_click(w, "Save")
    dismiss_validation(get_app())
    print(f"  [saved] {name}")
    close_window(main_win, "Insurance Company")
    time.sleep(T_SHORT)

# ─── CUSTOMER ─────────────────────────────────────────────────────────────────

def enter_customer(p):
    medicare_name = MEDICARE_BY_STATE.get(p["state"])
    if not medicare_name:
        print(f"  [error] No Medicare DMERC mapping for state '{p['state']}'")
        return

    a, main_win = get_main()
    dismiss_popup(a)
    dlg = open_fresh_window(main_win, a, "Customer", "Maintain->Customer")
    if not dlg:
        print("  [error] Customer window not found"); return

    # Search by last name, verify Last Name + First Name + Phone cells match
    found = search_then_check(dlg,
        search_fields={"txtLastName":  p["last"],
                       "txtFirstName": p["first"]},
        column_checks={"Last Name":  p["last"],
                       "First Name": p["first"],
                       "Phone":      fmt_phone(p["phone"])})

    if found:
        print(f"  [skip] {p['first']} {p['last']} already exists")
        close_window(main_win, "Customer")
        return

    print(f"  [not found] creating {p['first']} {p['last']}")
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
    print(f"  General: {p['city']}, {p['state']} {p['zip']} | DOB {p['dob']}")

    # Contacts tab - use doctor's address as filter for unique selection
    click_inner_tab(dlg, "Contacts")
    contacts_pane = dlg.child_window(auto_id="tpContacts", found_index=0)
    doctor1_pane  = contacts_pane.child_window(auto_id="cmbDoctor1", found_index=0)
    doc_filter    = TEST_DOCTOR["address1"]  # address is unique even if names collide
    set_combo_text(doctor1_pane, doc_filter, main_win)
    print(f"  Doctor: {p['doctor']} (filtered by '{doc_filter}')")

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
            print(f"    [warn] ICD slot {i}: {e}")
    print(f"  ICD 10: {', '.join(p['icd10'])}")

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
            # Check for validation errors (e.g. "You must select insurance type")
            dismiss_validation(get_app())
            print(f"  Primary: {medicare_name} | MBI {p['mbi']}")
        except Exception as e:
            print(f"  [error] Policy Information dialog failed: {e}")
            dismiss_validation(get_app())
            try:
                pol.child_window(auto_id="btnCancel", found_index=0).click_input()
            except Exception:
                pass
    else:
        print("  [error] Policy Information dialog not found")

    if p.get("secondary"):
        sec = p["secondary"]
        ctrl_pane.child_window(auto_id="Panel1").child_window(
            auto_id="btnAdd").click_input()
        time.sleep(T_LONG)
        pol2 = find_mdi_child(main_win, "Policy Information")
        if pol2:
            set_combo_text(pol2.child_window(auto_id="cmbInsuranceCompany",
                                             found_index=0), sec["ins_company"])
            set_field(pol2, "txtPolicyNumber", sec["policy"])
            set_field(pol2, "txtGroupNumber",  sec.get("group", ""))
            pol2.child_window(auto_id="btnOK", found_index=0).click_input()
            time.sleep(T_MED)
            print(f"  Secondary: {sec['ins_company']} | {sec['policy']}")

    toolbar_click(dlg, "Save")
    dismiss_validation(get_app())
    print(f"  [saved] {p['first']} {p['last']}")
    close_window(main_win, "Customer")

# ─── MAIN ─────────────────────────────────────────────────────────────────────

def main():
    print("\n" + "=" * 60)
    print("DMEworks TEST - synthetic test record")
    print("=" * 60 + "\n")

    print("[1/3] Doctor: Test TestDoctor")
    ensure_doctor(TEST_DOCTOR)

    medicare_name = MEDICARE_BY_STATE[TEST_PATIENT["state"]]
    print(f"\n[2/3] Insurance: {medicare_name}")
    ensure_insurance_company(medicare_name, is_medicare=True)

    print("\n[3/3] Customer: Test T TestPatient")
    enter_customer(TEST_PATIENT)

    print("\n" + "=" * 60)
    print("TEST COMPLETE. Verify in DMEworks:")
    print("  Doctor:   Test TestDoctor, NPI 1234567893")
    print(f"  Ins Co:   {medicare_name} (verified)")
    print("  Customer: TestPatient, Test T")
    print("    General:  DOB 01/01/2000, 1 Test Avenue, Testville NJ 00001")
    print("    Contacts: Doctor1 = TestDoctor")
    print("    Dx>ICD10: Z00.00")
    print(f"    Insurance: {medicare_name}, policy TESTMBI0001")
    print("=" * 60)

if __name__ == "__main__":
    main()
