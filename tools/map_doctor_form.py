"""
Dumps all UI controls for the Doctor form — work area list view AND every tab on
an open doctor record.

Run with DMEworks open (Doctor form doesn't need to be open already).
Output is written to logs/doctor_form_map.txt (and printed to console).

Usage:
    python tools/map_doctor_form.py
"""

import os
import time
import sys
from pywinauto import Application

T_LONG = 1.8
T_MED  = 1.0

_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_logs = os.path.join(os.path.dirname(sys.executable), "logs") if getattr(sys, "frozen", False) else os.path.join(_root, "logs")
OUTPUT_FILE = os.path.join(_logs, "doctor_form_map.txt")


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
        log("DMEworks Doctor Form — Full Control Map")
        log("=" * 60)

        a, main_win = get_main()

        log("\nOpening Doctor form via Maintain->Doctor...")
        a.top_window().menu_select("Maintain->Doctor")
        time.sleep(T_LONG)

        w = find_mdi_child(main_win, "Doctor")
        if not w:
            log("ERROR: Could not open Doctor form.")
            return

        log(f"\nDoctor form found: '{w.window_text()}'")

        # ── SECTION 1: Work Area (list view) ──────────────────────────────
        log("\n" + "=" * 60)
        log("SECTION 1: WORK AREA (list view + search controls)")
        log("=" * 60)
        try:
            page_ctrl = w.child_window(auto_id="PageControl", control_type="Tab", found_index=0)
            page_ctrl.child_window(title="Work Area", control_type="TabItem").click_input()
            time.sleep(T_MED)
            log("\nWork Area tab clicked — dumping controls:\n")
            dump_controls(w, f.write)
        except Exception as e:
            log(f"Work Area tab error: {e}")
            log("\nFalling back to full window dump:\n")
            dump_controls(w, f.write)

        # ── SECTION 2: Open a record and map each tab ──────────────────────
        log("\n" + "=" * 60)
        log("SECTION 2: RECORD EDIT FORM — clicking New to open edit view")
        log("=" * 60)
        try:
            tb = w.child_window(auto_id="tlbMain", control_type="ToolBar", found_index=0)
            tb.child_window(title="New", control_type="Button").click_input()
            time.sleep(T_MED)
            # dismiss any save dialog
            try:
                app = Application(backend="uia").connect(title="DMEWorks")
                for popup in app.top_window().descendants(control_type="Window"):
                    try:
                        t = popup.window_text()
                        if t in ("No", "Cancel", "Don't Save"):
                            popup.click_input()
                            time.sleep(0.3)
                    except Exception:
                        pass
            except Exception:
                pass
            w = find_mdi_child(main_win, "Doctor")
        except Exception as e:
            log(f"Could not click New: {e}")

        if not w:
            log("ERROR: Doctor form lost after New click.")
            input("Press Enter to close...")
            return

        # Detect tabs
        try:
            tab_ctrl  = w.child_window(auto_id="TabControl1", control_type="Tab", found_index=0)
            tab_items = [c for c in tab_ctrl.children() if c.element_info.control_type == "TabItem"]
            tab_names = []
            for t in tab_items:
                try:
                    tab_names.append(t.window_text())
                except Exception:
                    pass
            log(f"\nFound {len(tab_names)} tab(s): {tab_names}\n")
        except Exception as e:
            log(f"No TabControl1 found: {e}")
            log("\nFull dump of edit form:\n")
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
                w2 = find_mdi_child(main_win, "Doctor")
                if w2:
                    dump_controls(w2, f.write)
            except Exception as e:
                log(f"  Error clicking tab '{tab_name}': {e}")
            log()

        log("=" * 60)
        log(f"Done. Output written to: {out_path}")

    input("Press Enter to close...")


if __name__ == "__main__":
    main()
