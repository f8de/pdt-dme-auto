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
        try:
            input("Press Enter to exit...")
        except (EOFError, KeyboardInterrupt):
            pass

    sys.excepthook = _handler

_install_crash_handler()


# ── frozen dispatch ───────────────────────────────────────────────────────────
# When the EXE re-invokes itself with --dispatch <mode>, it runs the tool
# directly in-process instead of trying to exec a .py file that doesn't exist.

if _FROZEN and len(sys.argv) > 1 and sys.argv[1] == "--dispatch":
    try:
        mode     = sys.argv[2]
        sys.argv = [sys.argv[0]] + sys.argv[3:]   # strip --dispatch <mode>

        if mode == "ingest":
            import ingest
            ingest.run()
        elif mode == "ingest_test":
            import ingest_test
            ingest_test.run()
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
        try:
            input("\nPress Enter to exit...")
        except (EOFError, KeyboardInterrupt):
            pass
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
            "ingest":       os.path.join(SCRIPT_DIR, "ingest.py"),
            "ingest_test":  os.path.join(SCRIPT_DIR, "ingest_test.py"),
            "verify":       os.path.join(SCRIPT_DIR, "tools", "verify_dmeworks.py"),
            "map_policy":   os.path.join(SCRIPT_DIR, "tools", "map_policy_dialog.py"),
            "map_insurance":os.path.join(SCRIPT_DIR, "tools", "map_insurance_company_tabs.py"),
            "grid_probe":   os.path.join(SCRIPT_DIR, "tools", "dmeworks_grid_probe.py"),
        }
        subprocess.run([sys.executable, script_map[mode]] + extra_args)


# ── single-keypress input ────────────────────────────────────────────────────

def _read_key(prompt: str = "  > ") -> str:
    """Read one keypress without requiring Enter (Windows msvcrt; fallback: readline)."""
    print(prompt, end="", flush=True)
    try:
        import msvcrt
        while True:
            ch = msvcrt.getwch()
            if ch in ("\x00", "\xe0"):
                msvcrt.getwch()   # consume second byte of function/arrow key
                continue
            print(ch)
            return ch.lower()
    except ImportError:
        return input().strip().lower()


# ── prereq check ─────────────────────────────────────────────────────────────

def check_prereqs() -> list[tuple[str, bool, str]]:
    results: list[tuple[str, bool, str]] = []

    v  = sys.version_info
    results.append(("Python >= 3.8", v >= (3, 8), f"{v.major}.{v.minor}.{v.micro}"))

    try:
        from utils.db import build_config
        import mysql.connector
        cfg  = build_config()
        conn = mysql.connector.connect(**cfg)
        conn.close()
        results.append(("SQL connection", True, f"{cfg['host']}:{cfg['port']}"))
    except Exception as _e:
        results.append(("SQL connection", False, f"failed: {type(_e).__name__}: {_e}"))

    pywinauto_ok = False
    try:
        import pywinauto
        results.append(("pywinauto", True, pywinauto.__version__))
        pywinauto_ok = True
    except Exception as _e:
        results.append(("pywinauto", False, f"failed: {type(_e).__name__}: {_e}"))

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


# ── dmeworks launcher ──────────────────────────────────────────────────────────

def _launch_dmeworks() -> bool:
    """Launch DMEWorks exe, auto-login if credentials are configured.
    Returns True once the main DMEWorks window is confirmed ready."""
    import time
    try:
        from utils.creds import get_dmeworks_creds, get_dmeworks_exe
        from pywinauto import Application
    except Exception as _e:
        print(f"  Cannot launch DMEWorks: {_e}")
        return False

    username, password = get_dmeworks_creds()
    dmeworks_exe = get_dmeworks_exe()

    if not os.path.exists(dmeworks_exe):
        print(f"  DMEWorks not found. Searched:")
        from utils.creds import _DMEWORKS_CANDIDATES
        for p in _DMEWORKS_CANDIDATES:
            print(f"    {p}")
        print("  Set DMEWORKS_EXE_PATH in Doppler to override.")
        return False

    print(f"  Starting: {dmeworks_exe}")
    subprocess.Popen([dmeworks_exe])

    # Wait up to 20s for a login or splash window to appear
    print("  Waiting for DMEWorks to start...", end="", flush=True)
    app = None
    for _ in range(20):
        time.sleep(1)
        print(".", end="", flush=True)
        try:
            app = Application(backend="uia").connect(
                title_re="(?i).*login.*|.*DMEWorks.*", timeout=1
            )
            break
        except Exception:
            pass
    print()

    if not app:
        print("  DMEWorks did not appear after 20s.")
        return False

    # Auto-login if credentials are configured
    if username and password:
        try:
            win = app.top_window()
            # Try common auto_id patterns for the username field
            for uid in ("txtUserName", "textBoxUserName", "txtUsername", "Username"):
                try:
                    win.child_window(auto_id=uid).set_edit_text(username)
                    break
                except Exception:
                    pass
            # Password field
            for uid in ("txtPassword", "textBoxPassword", "txtPass", "Password"):
                try:
                    win.child_window(auto_id=uid).set_edit_text(password)
                    break
                except Exception:
                    pass
            # Click login/OK button
            for title in ("Login", "OK", "Log In", "Sign In"):
                try:
                    win.child_window(title=title, control_type="Button").click_input()
                    break
                except Exception:
                    pass
            print("  Credentials submitted.")
        except Exception as _e:
            print(f"  Auto-login failed ({_e}) — log in manually and press Enter.")
            try:
                input()
            except (EOFError, KeyboardInterrupt):
                pass
    else:
        print("  No DMEWorks credentials in Doppler (DMEWORKS_USERNAME / DMEWORKS_PASSWORD).")
        print("  Log in manually, then press Enter.")
        try:
            input()
        except (EOFError, KeyboardInterrupt):
            pass

    # Wait up to 45s for the main DMEWorks window to be ready
    print("  Waiting for main window...", end="", flush=True)
    for _ in range(45):
        time.sleep(1)
        print(".", end="", flush=True)
        try:
            Application(backend="uia").connect(title="DMEWorks", timeout=1)
            print(" ready.")
            return True
        except Exception:
            pass
    print(" timed out.")
    return False


# ── tools submenu ────────────────────────────────────────────────────────────

def _tools_menu(dmeworks_ok: bool, pywinauto_ok: bool) -> None:
    tools_ok = dmeworks_ok and pywinauto_ok
    print()
    print("=" * 60)
    print("  Tools  (DMEWorks must be open)")
    print("=" * 60)
    print()
    if not tools_ok:
        print("  [!]  DMEWorks is not running — these tools require it.")
        print()
    print("  [1]  Map policy dialog       —  maps Policy Information controls")
    print("  [2]  Map insurance company   —  maps Insurance Company form controls")
    print("  [3]  Grid probe              —  probes DataGridView cell reading")
    print()
    print("  [B]  Back")
    print()

    while True:
        try:
            choice = _read_key()
        except (KeyboardInterrupt, EOFError):
            print()
            return

        if choice == "b":
            return
        elif choice in ("1", "2", "3") and not tools_ok:
            print("  DMEWorks must be open to use these tools.")
        elif choice == "1":
            _launch("map_policy", [])
            return
        elif choice == "2":
            _launch("map_insurance", [])
            return
        elif choice == "3":
            _launch("grid_probe", [])
            return
        else:
            print("  Enter 1, 2, 3, or B.")


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

    dmeworks_ok  = all(ok for name, ok, _ in checks if "DMEWorks" in name)
    pywinauto_ok = any(ok for name, ok, _ in checks if "pywinauto" in name)
    # pywinauto warning only — verify works without it
    other_ok     = all(ok for name, ok, _ in checks
                       if "DMEWorks"  not in name
                       and "pywinauto" not in name)

    if not other_ok:
        print("  Fix failed checks before running.")
        print()
        _exe_dir = os.path.dirname(sys.executable) if _FROZEN else SCRIPT_DIR
        _crash   = os.path.join(_exe_dir, "crash.log")
        try:
            with open(_crash, "w", encoding="utf-8") as _f:
                _f.write("Prereq check failed:\n")
                for name, ok, detail in checks:
                    status = "OK" if ok else "FAIL"
                    _f.write(f"  [{status}]  {name}: {detail}\n")
            print(f"  Details written to: {_crash}")
        except Exception:
            pass
        try:
            input("  Press Enter to exit...")
        except (EOFError, KeyboardInterrupt):
            pass
        sys.exit(1)

    if not dmeworks_ok:
        if pywinauto_ok:
            print("  DMEWorks not running.")
            try:
                launch_choice = input("  Launch DMEWorks now? [y/N]: ").strip().lower()
            except (EOFError, KeyboardInterrupt):
                launch_choice = "n"
            if launch_choice == "y":
                dmeworks_ok = _launch_dmeworks()
                if dmeworks_ok:
                    print("  DMEWorks ready.")
                else:
                    print("  Could not confirm DMEWorks is ready — entry options unavailable.")
                    print("  Verification (option 3) is still available.")
            else:
                print("  Entry options unavailable. Verification (option 3) is still available.")
        else:
            print("  DMEWorks not running — entry options unavailable.")
            print("  Verification (option 3) is still available.")
    else:
        print("  All checks passed.")
    print()

    print("  Entry  (DMEWorks not required)")
    print("  [1]  Test entry   —  dry-run against test client (c01)")
    print("  [2]  Full entry   —  Allied")
    print()
    print("  Verification")
    print("  [3]  Verify       —  compare Notion vs DMEworks")
    print()
    print("  [T]  Tools        —  diagnostic utilities")
    print("  [0]  Exit")
    print()

    while True:
        try:
            choice = _read_key()
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)

        if choice == "0":
            print()
            sys.exit(0)
        elif choice in ("1", "2", "3", "t"):
            break
        else:
            print("  Enter 1, 2, 3, T, or 0.")

    try:
        if choice == "1":
            _launch("ingest_test", [])

        elif choice == "2":
            try:
                mode = input("  Live writes (real DB changes) or dry-run? [live/DRY]: ").strip().lower()
            except (EOFError, KeyboardInterrupt):
                mode = "dry"
            extra = ["--live"] if mode == "live" else []
            _launch("ingest", extra)

        elif choice == "3":
            try:
                dry = input("  Dry run? (shows diffs only, no writes) [y/N]: ").strip().lower()
            except (EOFError, KeyboardInterrupt):
                dry = "n"
            args = ["--dry-run"] if dry == "y" else []
            _launch("verify", args)

        elif choice == "t":
            _tools_menu(dmeworks_ok, pywinauto_ok)

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
        try:
            input("\nPress Enter to exit...")
        except (EOFError, KeyboardInterrupt):
            pass
