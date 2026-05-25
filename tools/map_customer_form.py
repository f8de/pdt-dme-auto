"""
Dumps all UI controls inside the Customer form Work Area.
Run with DMEworks open and a customer record visible (open any existing customer).

Usage:
    python tools/map_customer_form.py

Output: prints every control's auto_id, control_type, and title so we can identify
the Notes tab/field auto_ids for future UI automation.
"""

import time
from pywinauto import Application

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
                    return main.child_window(title=t, control_type="Window", found_index=0)
            except Exception:
                pass
    except Exception:
        pass
    return None


def dump_controls(parent, depth=0, max_depth=6):
    if depth > max_depth:
        return
    indent = "  " * depth
    try:
        children = parent.children()
    except Exception:
        return
    for child in children:
        try:
            auto_id = child.element_info.automation_id or ""
            ctrl    = child.element_info.control_type or ""
            title   = child.window_text() or ""
            if auto_id or title:
                print(f"{indent}[{ctrl}] auto_id='{auto_id}' title='{title}'")
            dump_controls(child, depth + 1, max_depth)
        except Exception:
            pass


def main():
    print("=" * 60)
    print("DMEworks Customer Form Control Map")
    print("=" * 60)

    a, main_win = get_main()

    # Try to find an open Customer form, or open a fresh one
    w = find_mdi_child(main_win, "Customer")
    if not w:
        print("No Customer window found — opening one via menu...")
        a.top_window().menu_select("Maintain->Customer")
        time.sleep(T_LONG)
        w = find_mdi_child(main_win, "Customer")

    if not w:
        print("ERROR: Could not open Customer form. Is DMEworks running?")
        return

    print(f"\nCustomer form found: '{w.window_text()}'")
    print("Dumping all controls (depth <= 6)...\n")
    dump_controls(w)
    print("\nDone.")
    input("Press Enter to close...")


if __name__ == "__main__":
    main()
