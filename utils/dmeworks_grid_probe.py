"""
Grid cell value probe - tries every pywinauto reading method on
search result rows to find what actually returns real data.

Run with Doctor (Jones) open or search will find it.
Also probes Customer grid for both existing (Burke) and non-existing (Robbins).

Save to: C:\\ProgramData\\CybrEdge\\Scripts\\dmeworks_grid_probe.py
"""

import time
from pywinauto import Application

T_MED = 1.0
T_LONG = 1.8

def get_main():
    a = Application(backend="uia").connect(title="DMEWorks")
    return a, a.window(title="DMEWorks", auto_id="FormMain")

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
    try:
        win.child_window(auto_id=auto_id, found_index=0).set_edit_text(value)
        time.sleep(0.3)
    except Exception as e:
        print(f"  [warn] set_field({auto_id}): {e}")

def toolbar_click(win, title):
    tb = win.child_window(auto_id="tlbMain", control_type="ToolBar", found_index=0)
    tb.child_window(title=title, control_type="Button").click_input()
    time.sleep(T_MED)

def dismiss_save(a):
    try:
        main = a.window(title="DMEWorks", auto_id="FormMain")
        no = main.child_window(title="No", control_type="Button")
        if no.exists(timeout=1):
            no.click_input(); time.sleep(0.5)
    except Exception:
        pass

def probe_grid(w, label):
    """Try every reading method on each cell of every result row."""
    print(f"\n  === GRID PROBE: {label} ===")
    try:
        grid = w.child_window(title="DataGridView", control_type="Table",
                              found_index=0)
        all_children = grid.children()
        data_rows = [c for c in all_children
                     if c.element_info.control_type == "Custom"
                     and c.window_text() != "Top Row"]
        print(f"  Data rows found: {len(data_rows)}")

        for ri, row in enumerate(data_rows):
            print(f"\n  --- Row {ri} ---")
            cells = row.children()
            print(f"  Cell count: {len(cells)}")
            for ci, cell in enumerate(cells):
                print(f"    cell[{ci}]:")

                # Method 1: window_text()
                try:
                    print(f"      window_text()     = {cell.window_text()!r}")
                except Exception as e:
                    print(f"      window_text()     ERROR: {e}")

                # Method 2: get_value()
                try:
                    print(f"      get_value()       = {cell.get_value()!r}")
                except Exception as e:
                    print(f"      get_value()       ERROR: {e}")

                # Method 3: legacy_properties Value
                try:
                    lp = cell.legacy_properties()
                    print(f"      legacy Value      = {lp.get('Value', '<missing>')!r}")
                    print(f"      legacy Name       = {lp.get('Name', '<missing>')!r}")
                except Exception as e:
                    print(f"      legacy_props      ERROR: {e}")

                # Method 4: element_info.name
                try:
                    print(f"      element_info.name = {cell.element_info.name!r}")
                except Exception as e:
                    print(f"      element_info.name ERROR: {e}")

                # Method 5: texts()
                try:
                    print(f"      texts()           = {cell.texts()!r}")
                except Exception as e:
                    print(f"      texts()           ERROR: {e}")

                # Stop after first 3 cells to keep output manageable
                if ci >= 2:
                    remaining = len(cells) - 3
                    if remaining > 0:
                        print(f"    ... ({remaining} more cells not shown)")
                    break

    except Exception as e:
        print(f"  PROBE ERROR: {e}")

def search_and_probe(form_keyword, menu_path, search_fields, label):
    a, main_win = get_main()
    # Close if open
    w = find_mdi_child(main_win, form_keyword)
    if w:
        try:
            tb = w.child_window(auto_id="tlbMain", control_type="ToolBar", found_index=0)
            tb.child_window(title="Close", control_type="Button").click_input()
            time.sleep(0.5)
            dismiss_save(a)
        except Exception:
            pass

    a.top_window().menu_select(menu_path)
    time.sleep(T_LONG)
    dismiss_save(a)

    w = find_mdi_child(main_win, form_keyword)
    if not w:
        print(f"Could not open {form_keyword}"); return

    for auto_id, value in search_fields.items():
        set_field(w, auto_id, value)
    toolbar_click(w, "Search")
    dismiss_save(a)
    time.sleep(0.5)

    probe_grid(w, label)

    # Close
    try:
        w2 = find_mdi_child(main_win, form_keyword)
        if w2:
            tb = w2.child_window(auto_id="tlbMain", control_type="ToolBar", found_index=0)
            tb.child_window(title="Close", control_type="Button").click_input()
            time.sleep(0.5)
            dismiss_save(a)
    except Exception:
        pass


def main():
    print("=" * 60)
    print("DMEworks Grid Cell Value Probe")
    print("=" * 60)

    # Probe 1: Doctor - Jones (exists)
    search_and_probe("Doctor", "Maintain->Doctor",
                     {"txtLastName": "Jones"},
                     "Doctor 'Jones' - exists")

    # Probe 2: Doctor - ZZZZZ (does not exist)
    search_and_probe("Doctor", "Maintain->Doctor",
                     {"txtLastName": "ZZZZZ"},
                     "Doctor 'ZZZZZ' - does NOT exist")

    # Probe 3: Customer - Burke (exists)
    search_and_probe("Customer", "Maintain->Customer",
                     {"txtLastName": "Burke", "txtFirstName": "Angela"},
                     "Customer 'Angela Burke' - exists")

    # Probe 4: Customer - Robbins (does not exist)
    search_and_probe("Customer", "Maintain->Customer",
                     {"txtLastName": "Robbins", "txtFirstName": "Joseph"},
                     "Customer 'Joseph Robbins' - does NOT exist")

    print("\n" + "=" * 60)
    print("Probe complete.")

if __name__ == "__main__":
    main()
