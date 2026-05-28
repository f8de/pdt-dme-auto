"""
Dumps all UI controls for every tab on the Customer form.
Run with DMEworks open and a customer record visible.

Usage:
    python tools/map_customer_form.py
"""

import time
from pywinauto import Application

T_LONG = 1.8
T_MED  = 1.0


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


def dump_controls(parent, depth=0, max_depth=8):
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
    print("DMEworks Customer Form — Full Tab Control Map")
    print("=" * 60)

    a, main_win = get_main()

    w = find_mdi_child(main_win, "Customer")
    if not w:
        print("No Customer window found — opening one via menu...")
        a.top_window().menu_select("Maintain->Customer")
        time.sleep(T_LONG)
        w = find_mdi_child(main_win, "Customer")

    if not w:
        print("ERROR: Could not open Customer form.")
        return

    print(f"\nCustomer form found: '{w.window_text()}'")

    # Find the main tab control
    try:
        tab_ctrl = w.child_window(auto_id="TabControl1", control_type="Tab", found_index=0)
        tab_items = [c for c in tab_ctrl.children() if c.element_info.control_type == "TabItem"]
        tab_names = []
        for t in tab_items:
            try:
                tab_names.append(t.window_text())
            except Exception:
                pass
        print(f"Found {len(tab_names)} tabs: {tab_names}\n")
    except Exception as e:
        print(f"Could not find TabControl1: {e}")
        print("\nFalling back to full dump...\n")
        dump_controls(w)
        input("Press Enter to close...")
        return

    for tab_name in tab_names:
        print("=" * 60)
        print(f"TAB: {tab_name}")
        print("=" * 60)
        try:
            tab_ctrl.child_window(title=tab_name, control_type="TabItem").click_input()
            time.sleep(T_MED)
            # Re-find the pane after click
            w2 = find_mdi_child(main_win, "Customer")
            if w2:
                dump_controls(w2.child_window(auto_id="tpWorkArea", found_index=0))
        except Exception as e:
            print(f"  Error clicking tab '{tab_name}': {e}")
        print()

    print("=" * 60)
    print("Done.")
    input("Press Enter to close...")


if __name__ == "__main__":
    main()
