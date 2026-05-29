"""
DMEworks Automation Launcher
Checks prerequisites then dispatches to the appropriate tool.

In frozen (EXE) mode, tools are dispatched by re-invoking the EXE with
  --dispatch <mode> [args...]
so that each tool runs in a fresh process with the correct sys.argv.
"""

import ctypes
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
        elif mode == "fix_ui":
            from tools.fix_via_ui import main
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
        elif mode == "db_audit":
            from tools.db_dump import main
            main()
        elif mode == "entry_all":
            import entry_all
            entry_all.run()
        elif mode == "map_customer_form":
            from tools.map_customer_form import main
            main()
        elif mode == "map_doctor_form":
            from tools.map_doctor_form import main
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
            "fix_ui":       os.path.join(SCRIPT_DIR, "tools", "fix_via_ui.py"),
            "map_policy":   os.path.join(SCRIPT_DIR, "tools", "map_policy_dialog.py"),
            "map_insurance":os.path.join(SCRIPT_DIR, "tools", "map_insurance_company_tabs.py"),
            "grid_probe":   os.path.join(SCRIPT_DIR, "tools", "dmeworks_grid_probe.py"),
            "db_audit":          os.path.join(SCRIPT_DIR, "tools", "db_dump.py"),
            "entry_all":         os.path.join(SCRIPT_DIR, "entry_all.py"),
            "map_customer_form": os.path.join(SCRIPT_DIR, "tools", "map_customer_form.py"),
            "map_doctor_form":   os.path.join(SCRIPT_DIR, "tools", "map_doctor_form.py"),
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


# ── ANSI helpers ─────────────────────────────────────────────────────────────

def _ansi_setup():
    try:
        ctypes.windll.kernel32.SetConsoleOutputCP(65001)
        ctypes.windll.kernel32.SetConsoleMode(
            ctypes.windll.kernel32.GetStdHandle(-11), 7)
    except Exception:
        pass


def _clear():
    sys.stdout.write("\033[2J\033[H")
    sys.stdout.flush()


def _menu_frame(title, rows, IN=58):
    BD = "\033[1m"; RS = "\033[0m"; CY = "\033[96m"; WH = "\033[97m"

    def _top(): return f"{CY}╔{'═' * IN}╗{RS}"
    def _mid(): return f"{CY}╠{'═' * IN}╣{RS}"
    def _bot(): return f"{CY}╚{'═' * IN}╝{RS}"
    def _row(plain="", styled=""):
        pad = IN - 2 - len(plain)
        return f"{CY}║{RS}  {styled}{' ' * max(0, pad)}{CY}║{RS}"

    t_pad     = (IN - len(title)) // 2
    title_row = (f"{CY}║{RS}{' ' * t_pad}{BD}{WH}{title}{RS}"
                 f"{' ' * (IN - t_pad - len(title))}{CY}║{RS}")

    print()
    print(_top())
    print(title_row)
    print(_mid())
    for item in rows:
        if item is None:
            print(_row())
        else:
            print(_row(*item))
    print(_bot())
    print()


# ── tools submenu ─────────────────────────────────────────────────────────────

def _tools_menu() -> None:
    BD = "\033[1m"; RS = "\033[0m"; YL = "\033[93m"; WH = "\033[97m"; DM = "\033[2m\033[37m"

    tools = [
        ("1", "DB Dump",       "db_audit",           "Dump DB records to file"),
        ("2", "Verify DB",     "verify",              "Detailed Notion vs DB audit"),
        ("3", "Fix via UI",    "fix_ui",              "Standalone diff + UI correction"),
        ("4", "Map Customer",  "map_customer_form",   "Dump Customer form controls"),
        ("5", "Map Doctor",    "map_doctor_form",     "Dump Doctor form controls"),
        ("6", "Map Insurance", "map_insurance",       "Dump Insurance form controls"),
        ("7", "Map Policy",    "map_policy",          "Dump Policy dialog controls"),
        ("8", "Grid Probe",    "grid_probe",          "Probe grid cell reading"),
    ]

    while True:
        _clear()
        rows = [None]
        for num, name, _, desc in tools:
            plain  = f"{num}   {name:<14} {desc}"
            styled = f"{YL}{BD}{num}{RS}   {WH}{BD}{name:<14}{RS} {DM}{desc}{RS}"
            rows.append((plain, styled))
        rows.append(None)
        rows.append(("0   Back", f"{YL}{BD}0{RS}   {WH}{BD}Back{RS}"))
        rows.append(None)
        _menu_frame("Tools", rows)

        mapping = {t[0]: (t[1], t[2]) for t in tools}
        try:
            raw = input(f"  {WH}Choice{RS} {DM}[0–8]{RS}:  ").strip()
        except (KeyboardInterrupt, EOFError):
            return
        if raw == "0" or raw == "":
            return
        if raw not in mapping:
            continue

        tname, tmode = mapping[raw]
        print(f"\n  Starting {tname}...\n")
        _launch(tmode, [])
        try:
            input(f"\n  {DM}Press Enter to return to menu...{RS}")
        except (KeyboardInterrupt, EOFError):
            return


# ── main menu ─────────────────────────────────────────────────────────────────

def main() -> None:
    _ansi_setup()

    BD = "\033[1m"; RS = "\033[0m"; YL = "\033[93m"; WH = "\033[97m"; DM = "\033[2m\033[37m"

    # prereq check on startup (and after each return)
    def _refresh():
        chks        = check_prereqs()
        dme_ok      = any(ok for n, ok, _ in chks if "DMEWorks" in n)
        pw_ok       = any(ok for n, ok, _ in chks if "pywinauto" in n)
        sq_ok       = any(ok for n, ok, _ in chks if "SQL" in n)
        return chks, dme_ok, pw_ok, sq_ok

    print("  Checking prerequisites...", flush=True)
    checks, dmeworks_ok, pywinauto_ok, sql_ok = _refresh()
    ui_ok = dmeworks_ok and pywinauto_ok

    if not sql_ok:
        _clear()
        print()
        print("  SQL connection failed — check Doppler credentials and network.")
        print()
        for n, ok, detail in checks:
            mark = "\033[92mOK\033[0m" if ok else "\033[91mFAIL\033[0m"
            print(f"  [{mark}]  {n:<22} {detail}")
        print()
        try:
            input("  Press Enter to exit...")
        except (EOFError, KeyboardInterrupt):
            pass
        sys.exit(1)

    # (num, label, dispatch_mode, base_args, needs_ui, has_dry_run, description)
    modes = [
        ("1", "Test",  "entry_all", ["--mode", "test"],  True,  False, "Fill all forms — full UI field test"),
        ("2", "Run",   "entry_all", ["--mode", "run"],   True,  True,  "Enter Notion queue into Allied"),
        ("3", "Audit", "entry_all", ["--mode", "audit"], False, False, "Compare Notion vs DB — no writes"),
        ("4", "Fix",   "entry_all", ["--mode", "fix"],   True,  True,  "Correct audit diffs via DMEworks UI"),
    ]

    while True:
        _clear()

        dme_tag = f"\033[92mopen\033[0m"      if dmeworks_ok else f"\033[91mnot running\033[0m"
        sql_tag = f"\033[92mconnected\033[0m" if sql_ok      else f"\033[91mfailed\033[0m"
        status_plain  = f"DB: {'connected' if sql_ok else 'failed'}   DMEworks: {'open' if dmeworks_ok else 'not running'}"
        status_styled = f"{DM}DB: {sql_tag}   DMEworks: {dme_tag}{RS}"

        rows = [None]
        for num, label, _, _, needs_ui, _, desc in modes:
            note   = f"  {DM}(DMEworks required){RS}" if needs_ui and not ui_ok else ""
            plain  = f"{num}   {label:<7} {desc}"
            styled = f"{YL}{BD}{num}{RS}   {WH}{BD}{label:<7}{RS} {DM}{desc}{RS}{note}"
            rows.append((plain, styled))
        rows.append(None)
        rows.append(("5   Tools   Developer & diagnostic tools ›",
                     f"{YL}{BD}5{RS}   {WH}{BD}Tools{RS}   {DM}Developer & diagnostic tools ›{RS}"))
        rows.append(None)
        rows.append((status_plain, status_styled))
        rows.append(None)
        rows.append(("0   Exit", f"{YL}{BD}0{RS}   {WH}{BD}Exit{RS}"))
        rows.append(None)
        _menu_frame("DMEworks Automation — Allied Medical Health", rows)

        try:
            raw = input(f"  {WH}Choice{RS} {DM}[0–5]{RS}:  ").strip()
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)

        if raw == "0":
            sys.exit(0)
        if raw == "5":
            _tools_menu()
            checks, dmeworks_ok, pywinauto_ok, sql_ok = _refresh()
            ui_ok = dmeworks_ok and pywinauto_ok
            continue
        if not raw:
            continue

        match = next((m for m in modes if m[0] == raw), None)
        if not match:
            continue

        num, label, dispatch, base_args, needs_ui, has_dry_run, _ = match

        if needs_ui and not ui_ok:
            if pywinauto_ok and not dmeworks_ok:
                print()
                try:
                    yn = input("  DMEworks not running. Launch now? [y/N]:  ").strip().lower()
                except (EOFError, KeyboardInterrupt):
                    continue
                if yn == "y":
                    dmeworks_ok = _launch_dmeworks()
                    ui_ok = dmeworks_ok and pywinauto_ok
                if not ui_ok:
                    print(f"  {DM}DMEworks not ready — cannot run this option.{RS}")
                    try:
                        input("  Press Enter to continue...")
                    except (EOFError, KeyboardInterrupt):
                        pass
                    continue
            else:
                print(f"\n  {DM}DMEworks must be running for this option.{RS}")
                try:
                    input("  Press Enter to continue...")
                except (EOFError, KeyboardInterrupt):
                    pass
                continue

        extra_args = list(base_args)
        if has_dry_run:
            print()
            try:
                yn = input(f"  {WH}Dry run{RS} {DM}(preview without writing)? [y/N]{RS}:  ").strip().lower()
            except (KeyboardInterrupt, EOFError):
                continue
            if yn == "y":
                extra_args.append("--dry-run")

        print(f"\n  Starting {label}...\n")
        _launch(dispatch, extra_args)

        try:
            input(f"\n  {DM}Press Enter to return to menu...{RS}")
        except (KeyboardInterrupt, EOFError):
            pass

        checks, dmeworks_ok, pywinauto_ok, sql_ok = _refresh()
        ui_ok = dmeworks_ok and pywinauto_ok


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
