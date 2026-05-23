# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec — builds dmeworks-entry.exe
# Run via: python build.py  (from repo root)

import os
ROOT = os.path.abspath(os.path.join(SPECPATH, ".."))

a = Analysis(
    [os.path.join(ROOT, "entry_all.py")],
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
    name="dmeworks-entry",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    console=True,
    icon=None,
    version=os.path.join(SPECPATH, "version_info.txt"),
)
