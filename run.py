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

    # List available clients
    client_code = None
    try:
        sys.path.insert(0, SCRIPT_DIR)
        from utils.client_store import open_db
        conn = open_db()
        clients = conn.execute("SELECT code, name FROM clients ORDER BY code").fetchall()
        conn.close()
        if clients:
            print("  Available clients:")
            for c in clients:
                print(f"    {c[0]:<20} {c[1]}")
            print()
    except Exception:
        clients = []

    print("  Entry")
    print("  [1]  Test entry      —  synthetic patient (--client test)")
    print("  [2]  Full entry      —  select client below")
    print()
    print("  Utilities  (DMEWorks must be open, target screen loaded)")
    print("  [3]  Map policy dialog       —  maps Policy Information controls")
    print("  [4]  Map insurance company   —  maps Insurance Company form controls")
    print("  [5]  Grid probe              —  probes DataGridView cell reading")
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
        elif choice in ("1", "2", "3", "4", "5"):
            break
        else:
            print("  Enter 0-5.")

    extra_args = []
    if choice == "1":
        script = os.path.join(SCRIPT_DIR, "entry_test.py")
        extra_args = ["--client", "test"]
    elif choice == "2":
        if clients:
            try:
                client_code = input("  Client code: ").strip()
            except (KeyboardInterrupt, EOFError):
                print()
                sys.exit(0)
        else:
            print("  No clients found. Run: python manage_clients.py add-client")
            sys.exit(1)
        script = os.path.join(SCRIPT_DIR, "entry_all.py")
        extra_args = ["--client", client_code]
    elif choice == "3":
        script = os.path.join(SCRIPT_DIR, "utils", "map_policy_dialog.py")
    elif choice == "4":
        script = os.path.join(SCRIPT_DIR, "utils", "map_insurance_company_tabs.py")
    elif choice == "5":
        script = os.path.join(SCRIPT_DIR, "utils", "dmeworks_grid_probe.py")

    print()
    print(f"  Launching {os.path.relpath(script, SCRIPT_DIR)}...")
    print("=" * 60)
    print()
    subprocess.run([sys.executable, script] + extra_args)


if __name__ == "__main__":
    main()
