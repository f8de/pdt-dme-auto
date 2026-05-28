"""
Apply Notion vs DMEworks diffs via DMEworks UI automation. No SQL writes.
Requires DMEworks open on the main screen.

For each differing record:
  1. Shows exactly what needs to change
  2. Prompts you to open the record in DMEworks (Maintain -> Customer/Doctor)
  3. Auto-fills the changed fields via pywinauto once you press Enter
  4. Saves

Usage:
    python tools/fix_via_ui.py
"""
import os
import sys
import time
from concurrent.futures import ThreadPoolExecutor

import mysql.connector
from pywinauto import keyboard

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_TOOLS = os.path.dirname(os.path.abspath(__file__))
for _p in (_ROOT, _TOOLS):
    if _p not in sys.path:
        sys.path.insert(0, _p)

from utils.creds import get_notion_token
from utils.logger import get_logger
from utils.notion import fetch_all_doctors, fetch_all_insurance, fetch_patients_by_statuses
from utils.ui import (
    T_MED, T_SHORT,
    click_inner_tab, dismiss_validation, find_mdi_child,
    fmt_phone, get_main, open_fresh_window, go_work_area,
    set_dob, set_field, toolbar_click,
)
from tools.verify_dmeworks import (
    _print_diff, _print_section,
    _verify_doctors, _verify_insurance, _verify_patients,
)

log = get_logger("fix_ui")


# ── PATIENT FIELD MAP ─────────────────────────────────────────────────────────
# sql_col → (tab or None, auto_id or sentinel)
# None tab = set before any tab click (name fields at top of form)

_PATIENT_FIELD_MAP = {
    "FirstName":   (None,      "txtFirstName"),
    "LastName":    (None,      "txtLastName"),
    "MiddleName":  (None,      "txtMiddleName"),
    "Suffix":      (None,      "txtSuffix"),
    "DateofBirth": ("General", "__dob__"),
    "Gender":      ("General", "__gender__"),
    "Address1":    ("General", "txtAddress1"),
    "Address2":    ("General", "txtAddress2"),
    "City":        ("General", "txtCity"),
    "State":       ("General", "txtState"),
    "Zip":         ("General", "txtZip"),
    "Phone":       ("General", "txtPhone"),
}


def _apply_patient_ui(w, diffs: list[tuple], notion: dict) -> None:
    tab_groups: dict = {}
    icd10_codes = None
    mbi_correct = None
    doctor_npi_expected = None

    for _, sql_col, sql_val, n_display, _ in diffs:
        if sql_col == "__icd10__":
            icd10_codes = sql_val
        elif sql_col is None:
            mbi_correct = n_display
        elif sql_col == "__skip__":
            doctor_npi_expected = n_display
        elif sql_col in _PATIENT_FIELD_MAP:
            tab, auto_id = _PATIENT_FIELD_MAP[sql_col]
            tab_groups.setdefault(tab, []).append((sql_col, sql_val, auto_id))

    # Name fields (no tab click needed)
    for sql_col, sql_val, auto_id in tab_groups.get(None, []):
        set_field(w, auto_id, sql_val or "")

    # General tab fields
    if "General" in tab_groups:
        click_inner_tab(w, "General")
        for sql_col, sql_val, auto_id in tab_groups["General"]:
            if auto_id == "__dob__":
                set_dob(w, notion["dob"])
            elif auto_id == "__gender__":
                try:
                    w.child_window(auto_id="cmbGender", found_index=0).select(sql_val or "Male")
                    time.sleep(0.3)
                except Exception as e:
                    log.warning("Gender set failed: %s", e)
            elif sql_col == "Phone":
                set_field(w, auto_id, fmt_phone(sql_val or ""))
            else:
                set_field(w, auto_id, sql_val or "")

    # ICD-10 codes (Diagnosis tab)
    if icd10_codes is not None:
        click_inner_tab(w, "Diagnosis")
        w.child_window(auto_id="TabControl2", control_type="Tab", found_index=0).child_window(
            title="ICD 10", control_type="TabItem").click_input()
        time.sleep(T_MED)
        icd_pane = w.child_window(auto_id="TabPage3", found_index=0)
        for i in range(1, 13):
            code = icd10_codes[i - 1] if i <= len(icd10_codes) else ""
            try:
                slot = icd_pane.child_window(auto_id=f"eddICD10_{i:02d}")
                slot.child_window(auto_id="txtInternal").set_edit_text(code)
                time.sleep(0.2)
            except Exception as e:
                log.warning("ICD slot %d: %s", i, e)

    if doctor_npi_expected:
        print(f"  NOTE: Doctor NPI should be '{doctor_npi_expected}'"
              f" — update Doctor1 in Contacts tab manually.")
    if mbi_correct:
        print(f"  NOTE: MBI should be '{mbi_correct}'"
              f" — update PolicyNumber in Insurance tab manually.")


# ── DOCTOR FIELD MAP ──────────────────────────────────────────────────────────

_DOCTOR_FIELD_MAP = {
    "FirstName": (None,      "txtFirstName"),
    "LastName":  (None,      "txtLastName"),
    "NPI":       ("Numbers", "txtNPI"),
    "Address1":  ("Address", "txtAddress1"),
    "Address2":  ("Address", "txtAddress2"),
    "City":      ("Address", "txtCity"),
    "State":     ("Address", "txtState"),
    "Zip":       ("Address", "txtZip"),
    "Phone":     ("Address", "txtPhone"),
}


def _apply_doctor_ui(w, diffs: list[tuple], notion: dict) -> None:
    tab_groups: dict = {}
    for _, sql_col, sql_val, *_ in diffs:
        if sql_col not in _DOCTOR_FIELD_MAP:
            continue
        tab, auto_id = _DOCTOR_FIELD_MAP[sql_col]
        tab_groups.setdefault(tab, []).append((sql_col, sql_val, auto_id))

    for sql_col, sql_val, auto_id in tab_groups.get(None, []):
        set_field(w, auto_id, sql_val or "")

    for tab_name, fields in tab_groups.items():
        if tab_name is None:
            continue
        click_inner_tab(w, tab_name)
        for sql_col, sql_val, auto_id in fields:
            if sql_col == "Phone":
                set_field(w, auto_id, fmt_phone(sql_val or ""))
            else:
                set_field(w, auto_id, sql_val or "")


# ── MAIN ──────────────────────────────────────────────────────────────────────

def main() -> None:
    try:
        token = get_notion_token()
    except RuntimeError as exc:
        sys.exit(str(exc))

    print()
    print("  Patient scope:")
    print("  [1]  In DMEworks only      (default)")
    print("  [2]  All patients")
    print("  [3]  Custom statuses       (comma-separated)")
    print()
    try:
        scope = input("  > ").strip()
    except (KeyboardInterrupt, EOFError):
        sys.exit(0)

    if scope == "2":
        patient_fetch_statuses = None
        scope_label = "all patients"
    elif scope == "3":
        try:
            raw = input("  Statuses (comma-separated): ").strip()
        except (KeyboardInterrupt, EOFError):
            sys.exit(0)
        patient_fetch_statuses = [s.strip() for s in raw.split(",") if s.strip()]
        scope_label = f"status in {patient_fetch_statuses}"
    else:
        patient_fetch_statuses = ["In DMEworks"]
        scope_label = "In DMEworks only"

    log.info("fix_via_ui start — scope: %s", scope_label)

    print("\nFetching Notion data...")
    try:
        with ThreadPoolExecutor(max_workers=3) as pool:
            f_p = pool.submit(fetch_patients_by_statuses, token, patient_fetch_statuses)
            f_d = pool.submit(fetch_all_doctors, token)
            f_i = pool.submit(fetch_all_insurance, token)
            patients  = f_p.result()
            doctors   = f_d.result()
            insurance = f_i.result()
    except Exception as exc:
        sys.exit(f"Notion fetch failed: {exc}")

    print(f"  {len(patients)} patient(s), {len(doctors)} doctor(s), "
          f"{len(insurance)} insurance company(ies)")

    print("\nConnecting to DMEworks DB (read-only)...")
    try:
        from utils.db import build_config
        conn = mysql.connector.connect(**build_config())
    except Exception as exc:
        sys.exit(f"DB connection failed: {exc}")

    cur = conn.cursor(dictionary=True)

    all_diffs: list[tuple] = []
    _print_section("PATIENTS")
    all_diffs += _verify_patients(cur, patients)[0]
    _print_section("DOCTORS")
    all_diffs += _verify_doctors(cur, doctors)[0]
    _print_section("INSURANCE COMPANIES")
    all_diffs += _verify_insurance(cur, insurance)[0]

    cur.close()
    conn.close()

    if not all_diffs:
        print("\n  All records match. Nothing to fix.")
        return

    actionable = [d for d in all_diffs if d[0] != "insurance"]

    _print_section(f"DISCREPANCIES — {len(all_diffs)} record(s), "
                   f"{len(actionable)} fixable via UI")
    for kind, notion, _row, diffs in all_diffs:
        label = (f"Patient: {notion['first']} {notion['last']}" if kind == "patient"
                 else f"Doctor: {notion['first']} {notion['last']}" if kind == "doctor"
                 else f"Insurance: {notion['name']}")
        _print_diff(label, diffs)

    if not actionable:
        print("\n  Only insurance mismatches — correct manually in DMEworks.")
        return

    print(f"\n{'='*70}")
    try:
        answer = input(f"  Fix {len(actionable)} record(s) via DMEworks UI? [y/N]: ").strip().lower()
    except (EOFError, KeyboardInterrupt):
        answer = "n"
    if answer != "y":
        print("  Aborted.")
        return

    print("\n  Connecting to DMEworks UI...")
    try:
        a, main_win = get_main()
    except Exception as exc:
        sys.exit(f"Cannot connect to DMEworks: {exc}\nIs DMEworks open on the main screen?")

    fixed = 0
    for kind, notion, row, diffs in all_diffs:
        if kind == "insurance":
            name = notion["name"]
            print(f"\n  SKIP insurance '{name}' — add it manually in DMEworks "
                  f"(Maintain -> Insurance Company -> New).")
            continue

        print(f"\n{'='*60}")
        if kind == "patient":
            name = f"{notion['first']} {notion['last']}"
            print(f"  Patient: {name}")
            _print_diff("Changes to apply", diffs)
            print(f"\n  In DMEworks: Maintain -> Customer")
            print(f"  Find and open '{name}' so the form is in EDIT MODE.")
        else:
            name = f"Dr. {notion['first']} {notion['last']}"
            npi  = notion.get("npi", "N/A")
            print(f"  Doctor: {name}  (NPI: {npi})")
            _print_diff("Changes to apply", diffs)
            print(f"\n  In DMEworks: Maintain -> Doctor")
            print(f"  Find and open '{name}' so the form is in EDIT MODE.")

        try:
            input("  Press Enter when the record is open in edit mode... (Ctrl+C to skip) ")
        except (KeyboardInterrupt, EOFError):
            print("  Skipped.")
            continue

        keyword = "Customer" if kind == "patient" else "Doctor"
        w = find_mdi_child(main_win, keyword)
        if not w:
            print(f"  {keyword} window not found in DMEworks — skipping.")
            log.warning("%s window not found for %s", keyword, name)
            continue

        try:
            if kind == "patient":
                _apply_patient_ui(w, diffs, notion)
            else:
                _apply_doctor_ui(w, diffs, notion)
            toolbar_click(w, "Save")
            dismiss_validation(a)
            print(f"  Saved {keyword.lower()}: {name}")
            log.info("fixed %s %s via UI", keyword.lower(), name)
            fixed += 1
        except Exception as exc:
            print(f"  ERROR: {exc}")
            log.error("failed to fix %s %s: %s", keyword.lower(), name, exc)

    print(f"\n{'='*60}")
    print(f"  Done. {fixed}/{len(actionable)} record(s) corrected via UI.")
    try:
        input("\nPress Enter to close...")
    except (EOFError, KeyboardInterrupt):
        pass


if __name__ == "__main__":
    main()
