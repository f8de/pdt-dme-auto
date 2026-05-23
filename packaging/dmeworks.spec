# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec — builds dme-auto.exe
# Run via: python build.py  (from repo root)

import os
ROOT = os.path.abspath(os.path.join(SPECPATH, ".."))

a = Analysis(
    [os.path.join(ROOT, "run.py")],
    pathex=[ROOT],
    binaries=[],
    datas=[],
    hiddenimports=[
        "mysql.connector",
        "mysql.connector.locales",
        "mysql.connector.locales.eng",
        "requests",
        "requests.adapters",
        "urllib3",
        "urllib3.util.retry",
        "charset_normalizer",
        "entry_all",
        "entry_test",
        "tools.verify_dmeworks",
        "tools.map_policy_dialog",
        "tools.map_insurance_company_tabs",
        "tools.dmeworks_grid_probe",
        "utils.creds",
        "utils.notion",
        "utils.logger",
        "utils.db",
    ],
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
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
    uac_admin=True,
    icon=os.path.join(SPECPATH, "icon.ico"),
    version=os.path.join(SPECPATH, "version_info.txt"),
)
