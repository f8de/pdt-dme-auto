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

    dmeworks_ok = all(ok for name, ok, _ in checks if "DMEWorks" in name)
    other_ok    = all(ok for name, ok, _ in checks if "DMEWorks" not in name)

    if not other_ok:
        print("  Fix failed checks before running.")
        print()
        sys.exit(1)

    if not dmeworks_ok:
        print("  DMEWorks not running — entry options unavailable.")
        print("  Verification (option 3) is still available.")
    else:
        print("  All checks passed.")
    print()

    print("  (Client codes are configured in the Notion Clients database)")
    print()

    print("  Entry")
    print("  [1]  Test entry      —  synthetic patient (--client test)")
    print("  [2]  Full entry      —  select client below")
    print()
    print("  Verification")
    print("  [3]  Verify & correct  —  compare Notion vs DMEworks, fix mismatches")
    print()
    print("  Utilities  (DMEWorks must be open, target screen loaded)")
    print("  [4]  Map policy dialog       —  maps Policy Information controls")
    print("  [5]  Map insurance company   —  maps Insurance Company form controls")
    print("  [6]  Grid probe              —  probes DataGridView cell reading")
    print()
    print("  [0]  Exit")
    print()

    while True:
        try:
            choice = input("  > ").strip()
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)

        if choice == "0":
            print()
            sys.exit(0)
        elif choice in ("1", "2", "4", "5", "6") and not dmeworks_ok:
            print("  That option requires DMEWorks to be running.")
        elif choice in ("1", "2", "3", "4", "5", "6"):
            break
        else:
            print("  Enter 0-6.")

    extra_args = []
    if choice == "1":
        script = os.path.join(SCRIPT_DIR, "entry_test.py")
        extra_args = ["--client", "test"]
    elif choice == "2":
        try:
            client_code = input("  Client code: ").strip()
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)
        script = os.path.join(SCRIPT_DIR, "entry_all.py")
        extra_args = ["--client", client_code]
    elif choice == "3":
        try:
            client_code = input("  Client code: ").strip()
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)
        script = os.path.join(SCRIPT_DIR, "tools", "verify_dmeworks.py")
        extra_args = ["--client", client_code]
    elif choice == "4":
        script = os.path.join(SCRIPT_DIR, "tools", "map_policy_dialog.py")
    elif choice == "5":
        script = os.path.join(SCRIPT_DIR, "tools", "map_insurance_company_tabs.py")
    elif choice == "6":
        script = os.path.join(SCRIPT_DIR, "tools", "dmeworks_grid_probe.py")

    print()
    print(f"  Launching {os.path.relpath(script, SCRIPT_DIR)}...")
    print("=" * 60)
    print()
    subprocess.run([sys.executable, script] + extra_args)


if __name__ == "__main__":
    main()
