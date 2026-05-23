"""
DMEworks Automation Launcher
Checks prerequisites then dispatches to the appropriate tool.

In frozen (EXE) mode, tools are dispatched by re-invoking the EXE with
  --dispatch <mode> [args...]
so that each tool runs in a fresh process with the correct sys.argv.
"""

import os
import subprocess
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_FROZEN    = getattr(sys, "frozen", False)


# ── crash handler ─────────────────────────────────────────────────────────────

def _install_crash_handler() -> None:
    import traceback
    _exe_dir = os.path.dirname(sys.executable) if _FROZEN else SCRIPT_DIR
    _crash   = os.path.join(_exe_dir, "crash.log")

    def _handler(exc_type, exc_val, exc_tb):
        with open(_crash, "w", encoding="utf-8") as f:
            traceback.print_exception(exc_type, exc_val, exc_tb, file=f)
        print(f"\nUnexpected error — details written to: {_crash}")
        input("Press Enter to exit...")

    sys.excepthook = _handler

_install_crash_handler()


# ── frozen dispatch ───────────────────────────────────────────────────────────
# When the EXE re-invokes itself with --dispatch <mode>, it runs the tool
# directly in-process instead of trying to exec a .py file that doesn't exist.

if _FROZEN and len(sys.argv) > 1 and sys.argv[1] == "--dispatch":
    try:
        mode     = sys.argv[2]
        sys.argv = [sys.argv[0]] + sys.argv[3:]   # strip --dispatch <mode>

        if mode == "entry":
            import entry_all
            entry_all.run()
        elif mode == "entry_test":
            import entry_test
            entry_test.run()
        elif mode == "verify":
            from tools.verify_dmeworks import main
            main()
        elif mode == "map_policy":
            from tools.map_policy_dialog import main
            main()
        elif mode == "map_insurance":
            from tools.map_insurance_company_tabs import main
            main()
        elif mode == "grid_probe":
            from tools.dmeworks_grid_probe import main
            main()
    except SystemExit:
        raise
    except Exception:
        import traceback
        _exe_dir = os.path.dirname(sys.executable)
        _crash   = os.path.join(_exe_dir, "crash.log")
        _tb      = traceback.format_exc()
        try:
            with open(_crash, "w", encoding="utf-8") as _f:
                _f.write(_tb)
        except Exception:
            pass
        print(_tb)
        input("\nPress Enter to exit...")
    sys.exit(0)


# ── launcher helpers ──────────────────────────────────────────────────────────

def _launch(mode: str, extra_args: list[str]) -> None:
    """Launch a tool — dispatch via EXE in frozen mode, subprocess in dev."""
    print()
    print(f"  Launching {mode}...")
    print("=" * 60)
    print()
    if _FROZEN:
        subprocess.run([sys.executable, "--dispatch", mode] + extra_args)
    else:
        script_map = {
            "entry":        os.path.join(SCRIPT_DIR, "entry_all.py"),
            "entry_test":   os.path.join(SCRIPT_DIR, "entry_test.py"),
            "verify":       os.path.join(SCRIPT_DIR, "tools", "verify_dmeworks.py"),
            "map_policy":   os.path.join(SCRIPT_DIR, "tools", "map_policy_dialog.py"),
            "map_insurance":os.path.join(SCRIPT_DIR, "tools", "map_insurance_company_tabs.py"),
            "grid_probe":   os.path.join(SCRIPT_DIR, "tools", "dmeworks_grid_probe.py"),
        }
        subprocess.run([sys.executable, script_map[mode]] + extra_args)


# ── prereq check ─────────────────────────────────────────────────────────────

def check_prereqs() -> list[tuple[str, bool, str]]:
    results: list[tuple[str, bool, str]] = []

    v  = sys.version_info
    results.append(("Python >= 3.8", v >= (3, 8), f"{v.major}.{v.minor}.{v.micro}"))

    pywinauto_ok = False
    try:
        import pywinauto
        results.append(("pywinauto", True, pywinauto.__version__))
        pywinauto_ok = True
    except ImportError:
        results.append(("pywinauto", False, "not installed  ->  pip install pywinauto"))

    try:
        import tkinter  # noqa: F401
        results.append(("tkinter", True, "ok"))
    except ImportError:
        results.append(("tkinter", False, "not available in this Python install"))

    if pywinauto_ok:
        try:
            from pywinauto import Application
            Application(backend="uia").connect(title="DMEWorks", timeout=2)
            results.append(("DMEWorks running", True, "connected"))
        except Exception:
            results.append(("DMEWorks running", False, "not found  ->  open DMEWorks first"))
    else:
        results.append(("DMEWorks running", False, "skipped (pywinauto missing)"))

    return results


# ── main menu ─────────────────────────────────────────────────────────────────

def main() -> None:
    print()
    print("=" * 60)
    print("  DMEworks Automation Launcher")
    print("=" * 60)
    print()
    print("  Checking prerequisites...")
    print()

    checks   = check_prereqs()
    for name, ok, detail in checks:
        print(f"  [{'OK' if ok else 'FAIL'}]  {name:<22} {detail}")

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

    try:
        if choice == "1":
            _launch("entry_test", ["--client", "test"])

        elif choice == "2":
            client_code = input("  Client code: ").strip()
            _launch("entry", ["--client", client_code])

        elif choice == "3":
            client_code = input("  Client code: ").strip()
            dry = input("  Dry run? (shows diffs only, no writes) [y/N]: ").strip().lower()
            args = ["--client", client_code]
            if dry == "y":
                args.append("--dry-run")
            _launch("verify", args)

        elif choice == "4":
            _launch("map_policy", [])

        elif choice == "5":
            _launch("map_insurance", [])

        elif choice == "6":
            _launch("grid_probe", [])

    except (KeyboardInterrupt, EOFError):
        print()
        sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:
        import traceback
        _exe_dir = os.path.dirname(sys.executable) if _FROZEN else SCRIPT_DIR
        _crash   = os.path.join(_exe_dir, "crash.log")
        _tb      = traceback.format_exc()
        try:
            with open(_crash, "w", encoding="utf-8") as _f:
                _f.write(_tb)
        except Exception:
            pass
        print("\n" + "=" * 60)
        print("  CRASH — see crash.log next to the EXE for details")
        print("=" * 60)
        print(_tb)
        input("\nPress Enter to exit...")
