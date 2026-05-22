"""
DMEworks Patient Entry - Allied Medical Health (all 7 patients).
Safe to re-run. Skips any record that already exists.

Efficiency: each form is opened ONCE to bulk-read all existing records.
Only records that are missing get a fresh window open for creation.
On re-runs where everything exists, only 3 window opens total.

Save to: C:\\ProgramData\\CybrEdge\\Scripts\\entry_all.py
Prerequisites: DMEworks open on main screen, all child windows closed.
"""

import os
import sys
import time
import queue
import threading
import tkinter as tk
from pywinauto import Application, keyboard

_ROOT = os.path.dirname(os.path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from utils.data_loader import load_doctors, load_patients, load_medicare_map, load_insurance_companies

# ─── STATUS OVERLAY ───────────────────────────────────────────────────────────

_status_q: queue.Queue = queue.Queue()

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

# ─── DATA ─────────────────────────────────────────────────────────────────────

MEDICARE_BY_STATE    = load_medicare_map()
DOCTORS              = load_doctors()
PATIENTS             = load_patients()
INSURANCE_COMPANIES  = load_insurance_companies()

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
    try:
        for cell in row.children():
            cell_name = cell.window_text()
            if column_keyword.lower() in cell_name.lower() and "Row" in cell_name:
                try:
                    return (cell.get_value() or "").strip()
                except Exception:
                    return ""
    except Exception:
        pass
    return ""

def read_all_rows(w, columns):
    """
    Do a blank search and read the specified columns from every row.
    Returns a list of dicts keyed by column keyword (lowercase values).
    One window open reads everything in memory for batch comparison.
    """
    toolbar_click(w, "Search")
    dismiss_save_dialog(get_app())
    time.sleep(T_SHORT)
    records = []
    try:
        grid = w.child_window(title="DataGridView", control_type="Table",
                              found_index=0)
        data_rows = [c for c in grid.children()
                     if c.element_info.control_type == "Custom"
                     and c.window_text() != "Top Row"]
        for row in data_rows:
            rec = {col.lower(): get_cell_value(row, col).lower() for col in columns}
            records.append(rec)
        print(f"    [bulk read] {len(records)} existing record(s) loaded")
    except Exception as e:
        print(f"    [warn] read_all_rows: {e}")
    return records

def row_matches(record, checks):
    """True if a record dict matches all check values (case-insensitive keys and values)."""
    return all(record.get(k.lower(), "") == v.lower() for k, v in checks.items())

# ─── COMBO AND DOB ────────────────────────────────────────────────────────────

def set_combo_text(pane, value):
    """Select a value in a DMEworks cmbInternal combo. Tries select() first,
    falls back to type + Enter."""
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
        print(f"    [warn] set_combo_text('{value}'): {e}")

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
        print(f"    [warn] set_dob: {e}")

# ─── DOCTORS ──────────────────────────────────────────────────────────────────

def create_doctor(doc, main_win, a):
    label = f"{doc['first']} {doc['last']}, NPI {doc['npi']}"
    w = open_fresh_window(main_win, a, "Doctor", "Maintain->Doctor")
    if not w:
        print(f"  [error] Doctor window not found for {label}"); return

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

def ensure_all_doctors():
    print("\n[1/3] Doctors")
    print("-" * 40)
    a, main_win = get_main()
    dismiss_popup(a)

    # One open to read all existing doctors
    w = open_fresh_window(main_win, a, "Doctor", "Maintain->Doctor")
    existing = read_all_rows(w, ["Last Name", "First Name", "Address"])
    close_window(main_win, "Doctor")

    # Compare in memory, create only what's missing
    for doc in DOCTORS:
        set_status(f"[1/3] Doctor: {doc['first']} {doc['last']}")
        checks = {"Last Name":  doc["last"],
                  "First Name": doc["first"],
                  "Address":    doc["address1"]}
        if any(row_matches(e, checks) for e in existing):
            print(f"  [skip] {doc['first']} {doc['last']} already exists")
        else:
            print(f"  [not found] creating {doc['first']} {doc['last']}")
            try:
                create_doctor(doc, main_win, a)
            except Exception as e:
                print(f"  [error] {doc['last']}: {e}")

# ─── INSURANCE COMPANIES ──────────────────────────────────────────────────────

def create_insurance_company(name, main_win, a):
    w = open_fresh_window(main_win, a, "Insurance Company",
                          "Maintain->Insurance Company")
    if not w:
        print(f"  [error] Insurance Company window not found for {name}"); return
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

def ensure_all_insurance_companies():
    print("\n[2/3] Insurance companies")
    print("-" * 40)
    a, main_win = get_main()
    dismiss_popup(a)

    # One open to read all existing insurance companies
    w = open_fresh_window(main_win, a, "Insurance Company",
                          "Maintain->Insurance Company")
    existing = read_all_rows(w, ["Name"])
    close_window(main_win, "Insurance Company")

    existing_names = {e["name"] for e in existing}

    for co in INSURANCE_COMPANIES:
        name = co["name"]
        is_medicare = co["type"] == "MEDICARE"
        set_status(f"[2/3] Insurance: {name}")
        if name.lower() in existing_names:
            status = "[verified]" if is_medicare else "[skip]"
            print(f"  {status} {name} exists")
        else:
            if is_medicare:
                print(f"  [ERROR] '{name}' not found. Must be set up manually.")
            else:
                print(f"  [not found] creating {name}")
                try:
                    create_insurance_company(name, main_win, a)
                except Exception as e:
                    print(f"  [error] {name}: {e}")

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
            print(f"    [warn] validation on insurance row - check manually")
        else:
            print(f"    [ins] {ins_company} ({ins_type}) | policy {policy}")
    except Exception as e:
        print(f"    [error] add_insurance_row: {e}")
        try:
            pol_dialog.child_window(auto_id="btnCancel",
                                    found_index=0).click_input()
        except Exception:
            pass

def create_customer(p, main_win, a):
    medicare_name = MEDICARE_BY_STATE.get(p["state"])
    if not medicare_name:
        print(f"  [error] No DMERC mapping for state '{p['state']}'"); return

    dlg = open_fresh_window(main_win, a, "Customer", "Maintain->Customer")
    if not dlg:
        print("  [error] Customer window not found"); return

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

    click_inner_tab(dlg, "Contacts")
    contacts_pane = dlg.child_window(auto_id="tpContacts", found_index=0)
    doctor1_pane  = contacts_pane.child_window(auto_id="cmbDoctor1", found_index=0)
    set_combo_text(doctor1_pane, p["doctor"])
    print(f"  Doctor: {p['doctor']}")

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
        add_insurance_row(pol, medicare_name, "MEDICARE", p["mbi"])
    else:
        print("  [error] Policy Information dialog not found (primary)")

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
            print("  [error] Policy Information dialog not found (secondary)")

    toolbar_click(dlg, "Save")
    dismiss_validation(get_app())
    print(f"  [saved] {p['first']} {p['last']}")
    close_window(main_win, "Customer")

def ensure_all_customers():
    print("\n[3/3] Patients")
    print("-" * 40)
    a, main_win = get_main()
    dismiss_popup(a)

    # One open to read all existing customers
    dlg = open_fresh_window(main_win, a, "Customer", "Maintain->Customer")
    existing = read_all_rows(dlg, ["Last Name", "First Name", "Phone"])
    close_window(main_win, "Customer")

    for p in PATIENTS:
        set_status(f"[3/3] Patient: {p['first']} {p['last']}")
        print(f"\n  --- {p['first']} {p['last']} ---")
        checks = {"Last Name":  p["last"],
                  "First Name": p["first"],
                  "Phone":      fmt_phone(p["phone"])}
        if any(row_matches(e, checks) for e in existing):
            print(f"  [skip] already exists")
        else:
            try:
                create_customer(p, main_win, a)
            except Exception as e:
                print(f"  [error] {p['last']}: {e}")

# ─── MAIN ─────────────────────────────────────────────────────────────────────

def main():
    set_status("Starting — Allied Medical (7 patients)")
    print("\n" + "=" * 60)
    print("DMEworks Entry - Allied Medical Health (7 patients)")
    print("=" * 60)

    ensure_all_doctors()
    ensure_all_insurance_companies()
    ensure_all_customers()

    set_status("DONE — verify records in DMEworks")
    print("\n" + "=" * 60)
    print("DONE. Verify each record in DMEworks:")
    print("  General: name, DOB, address, phone")
    print("  Contacts: Doctor1 assigned")
    print("  Diagnosis > ICD 10: all codes entered")
    print("  Insurance: Medicare DMERC + MBI, secondary if applicable")
    flagged = [p for p in PATIENTS if p.get("notes")]
    if flagged:
        print()
        print("  NOTES:")
        for p in flagged:
            print(f"    {p['first']} {p['last']}: {p['notes']}")
    print("=" * 60)

if __name__ == "__main__":
    _t = threading.Thread(target=_overlay_thread, daemon=True)
    _t.start()
    try:
        main()
    finally:
        _status_q.put(None)  # close overlay
        _t.join(timeout=3)
