# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec — builds dmeworks-entry.exe
# Usage: pyinstaller dmeworks.spec

a = Analysis(
    ["entry_all.py"],
    pathex=[],
    binaries=[],
    datas=[
        ("reference.db", "."),
    ],
    hiddenimports=[
        "mysql.connector",
        "mysql.connector.locales",
        "mysql.connector.locales.eng",
        "keyring.backends.Windows",
        "cryptography.fernet",
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
)
