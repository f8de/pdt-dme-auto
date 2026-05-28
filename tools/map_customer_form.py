"""
Dumps all UI controls for every tab on the Customer form.
Run with DMEworks open and a customer record visible.
Output is written to config/customer_form_map.txt (and printed to console).

Usage:
    python tools/map_customer_form.py
"""

import os
import time
from pywinauto import Application

T_LONG = 1.8
T_MED  = 1.0

OUTPUT_FILE = os.path.join(os.path.dirname(__file__), "..", "config", "customer_form_map.txt")


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


def dump_controls(parent, write, depth=0, max_depth=8):
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
                line = f"{indent}[{ctrl}] auto_id='{auto_id}' title='{title}'"
                print(line)
                write(line + "\n")
            dump_controls(child, write, depth + 1, max_depth)
        except Exception:
            pass


def main():
    out_path = os.path.abspath(OUTPUT_FILE)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)

    with open(out_path, "w", encoding="utf-8") as f:
        def log(msg=""):
            print(msg)
            f.write(msg + "\n")

        log("=" * 60)
        log("DMEworks Customer Form — Full Tab Control Map")
        log("=" * 60)

        a, main_win = get_main()

        w = find_mdi_child(main_win, "Customer")
        if not w:
            log("No Customer window found — opening one via menu...")
            a.top_window().menu_select("Maintain->Customer")
            time.sleep(T_LONG)
            w = find_mdi_child(main_win, "Customer")

        if not w:
            log("ERROR: Could not open Customer form.")
            return

        log(f"\nCustomer form found: '{w.window_text()}'")

        try:
            tab_ctrl  = w.child_window(auto_id="TabControl1", control_type="Tab", found_index=0)
            tab_items = [c for c in tab_ctrl.children() if c.element_info.control_type == "TabItem"]
            tab_names = []
            for t in tab_items:
                try:
                    tab_names.append(t.window_text())
                except Exception:
                    pass
            log(f"Found {len(tab_names)} tabs: {tab_names}\n")
        except Exception as e:
            log(f"Could not find TabControl1: {e}")
            log("\nFalling back to full dump...\n")
            dump_controls(w, f.write)
            input("Press Enter to close...")
            return

        for tab_name in tab_names:
            log("=" * 60)
            log(f"TAB: {tab_name}")
            log("=" * 60)
            try:
                tab_ctrl.child_window(title=tab_name, control_type="TabItem").click_input()
                time.sleep(T_MED)
                w2 = find_mdi_child(main_win, "Customer")
                if w2:
                    dump_controls(w2.child_window(auto_id="tpWorkArea", found_index=0), f.write)
            except Exception as e:
                log(f"  Error clicking tab '{tab_name}': {e}")
            log()

        log("=" * 60)
        log(f"Done. Output written to: {out_path}")

    input("Press Enter to close...")


if __name__ == "__main__":
    main()
