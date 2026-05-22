"""
DMEworks Automation Launcher
Checks prerequisites then runs entry_test.py or entry_all.py.
"""

import os
import subprocess
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


def check_prereqs() -> list[tuple[str, bool, str]]:
    results: list[tuple[str, bool, str]] = []

    # Python version
    v = sys.version_info
    ok = v >= (3, 8)
    results.append(("Python >= 3.8", ok, f"{v.major}.{v.minor}.{v.micro}"))

    # pywinauto
    pywinauto_ok = False
    try:
        import pywinauto
        results.append(("pywinauto", True, pywinauto.__version__))
        pywinauto_ok = True
    except ImportError:
        results.append(("pywinauto", False, "not installed  ->  pip install pywinauto"))

    # tkinter
    try:
        import tkinter  # noqa: F401
        results.append(("tkinter", True, "ok"))
    except ImportError:
        results.append(("tkinter", False, "not available in this Python install"))

    # DMEWorks running (only if pywinauto available)
    if pywinauto_ok:
        try:
            from pywinauto import Application
            Application(backend="uia").connect(title="DMEWorks", timeout=2)
            results.append(("DMEWorks running", True, "connected"))
        except Exception:
            results.append(("DMEWorks running", False,
                            "not found  ->  open DMEWorks first"))
    else:
        results.append(("DMEWorks running", False, "skipped (pywinauto missing)"))

    return results


def main() -> None:
    print()
    print("=" * 60)
    print("  DMEworks Automation Launcher")
    print("=" * 60)
    print()
    print("  Checking prerequisites...")
    print()

    checks = check_prereqs()
    all_ok = True
    for name, ok, detail in checks:
        tag = " OK " if ok else "FAIL"
        print(f"  [{tag}]  {name:<22} {detail}")
        if not ok:
            all_ok = False

    print()

    if not all_ok:
        print("  Fix failed checks before running.")
        print()
        sys.exit(1)

    print("  All checks passed.")
    print()
    print("  Entry")
    print("  [1]  Test entry      —  synthetic patient, safe to re-run")
    print("  [2]  Full entry      —  all 7 Allied Medical patients")
    print()
    print("  Utilities  (DMEWorks must be open, target screen loaded)")
    print("  [3]  Map policy dialog       —  maps Policy Information controls")
    print("  [4]  Map insurance company   —  maps Insurance Company form controls")
    print("  [5]  Grid probe              —  probes DataGridView cell reading")
    print()
    print("  [0]  Exit")
    print()

    MENU = {
        "1": "entry_test.py",
        "2": "entry_all.py",
        "3": os.path.join("utils", "map_policy_dialog.py"),
        "4": os.path.join("utils", "map_insurance_company_tabs.py"),
        "5": os.path.join("utils", "dmeworks_grid_probe.py"),
    }

    while True:
        try:
            choice = input("  > ").strip()
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)

        if choice == "0":
            print()
            sys.exit(0)
        elif choice in MENU:
            script = os.path.join(SCRIPT_DIR, MENU[choice])
            break
        else:
            print("  Enter 0-5.")

    print()
    print(f"  Launching {os.path.relpath(script, SCRIPT_DIR)}...")
    print("=" * 60)
    print()
    subprocess.run([sys.executable, script])


if __name__ == "__main__":
    main()
