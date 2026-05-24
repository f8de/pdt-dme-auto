# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec — builds dme-auto.exe
# Run via: python build.py  (from repo root)

import glob
import os
import site
import sys
from PyInstaller.utils.hooks import collect_all, collect_submodules, collect_data_files

ROOT = os.path.abspath(os.path.join(SPECPATH, ".."))


def _find_pywin32_dlls():
    """Locate pywintypes3XX.dll / pythoncom3XX.dll from pywin32_system32."""
    binaries = []
    search_dirs = []
    try:
        search_dirs += site.getsitepackages()
    except Exception:
        pass
    try:
        search_dirs.append(site.getusersitepackages())
    except Exception:
        pass
    search_dirs.append(os.path.dirname(sys.executable))

    for sp in search_dirs:
        dll_dir = os.path.join(sp, "pywin32_system32")
        if os.path.isdir(dll_dir):
            for dll in glob.glob(os.path.join(dll_dir, "*.dll")):
                binaries.append((dll, "."))
        for dll in glob.glob(os.path.join(sp, "win32", "*.dll")):
            binaries.append((dll, "win32"))
    return binaries


def _safe_collect_all(pkg):
    try:
        return collect_all(pkg)
    except Exception:
        return [], [], []


pw_d, pw_b, pw_h = _safe_collect_all("pywinauto")
ct_d, ct_b, ct_h = _safe_collect_all("comtypes")

# pywin32: not a standard pip dist — collect submodules + explicit DLLs.
# Exclude win32comext (shell/taskscheduler) — not used by pywinauto UIA.
w32_h = (
    collect_submodules("win32")
    + collect_submodules("win32com")
    + collect_submodules("pywintypes")
    + collect_submodules("pythoncom")
)
try:
    w32_d = collect_data_files("win32") + collect_data_files("win32com")
except Exception:
    w32_d = []
w32_b = _find_pywin32_dlls()

a = Analysis(
    [os.path.join(ROOT, "run.py")],
    pathex=[ROOT],
    binaries=pw_b + ct_b + w32_b,
    datas=pw_d + ct_d + w32_d + [
        (os.path.join(ROOT, "config", "database_reference.json"), "config"),
        (os.path.join(ROOT, "config", "clients.json"), "config"),
    ],
    hiddenimports=pw_h + ct_h + w32_h + [
        "mysql.connector",
        "mysql.connector.locales",
        "mysql.connector.locales.eng",
        "mysql.connector.authentication",
        "requests",
        "requests.adapters",
        "urllib3",
        "urllib3.util.retry",
        "charset_normalizer",
        "win32api",
        "win32con",
        "win32gui",
        "win32process",
        "win32security",
        "pywintypes",
        "pythoncom",
        "win32com.client",
        "win32com.shell",
        "ingest",
        "ingest_test",
        "tools.verify_dmeworks",
        "tools.map_policy_dialog",
        "tools.map_insurance_company_tabs",
        "tools.dmeworks_grid_probe",
        "utils.creds",
        "utils.notion",
        "utils.logger",
        "utils.db",
        "utils.validate",
        "utils.ui",
    ],
    hookspath=[],
    runtime_hooks=[os.path.join(SPECPATH, "hook_pywin32.py")],
    excludes=[
        # tkinter — replaced with SetConsoleTitleW, saves ~7 MB of tcl/tk data
        "tkinter", "_tkinter",
        # unused win32 extensions
        "win32comext",
        # dev/test tools never needed at runtime
        "unittest", "doctest", "pdb", "pydoc", "py_compile",
        "profile", "cProfile", "timeit", "trace",
        "lib2to3", "distutils",
        # unused stdlib
        "sqlite3", "_sqlite3",
        "ftplib", "imaplib", "smtplib", "telnetlib", "nntplib", "poplib",
        "socketserver", "xmlrpc",
        "turtle", "turtledemo", "idlelib",
        "http.server",
        "test",
    ],
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    name="dme-auto",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    console=True,
    icon=os.path.join(SPECPATH, "icon.ico"),
    version=os.path.join(SPECPATH, "version_info.txt"),
)
