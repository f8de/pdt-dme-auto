"""
Build script — EXE, deployment package.

Usage:
  python build.py                     Build with current VERSION
  python build.py --bump patch        Bump patch, then build  (0.1.0 -> 0.1.1)
  python build.py --bump minor        Bump minor              (0.1.0 -> 0.2.0)
  python build.py --bump major        Bump major              (0.1.0 -> 1.0.0)
  python build.py --no-package        Build EXE but skip deploy packaging

Output:
  dist/dme-auto.exe                   Raw PyInstaller output
  deploy/                             Deployment-ready folder (overwritten each build)
    dme-auto.exe
    run.ps1
    run.bat
    DEPLOY.md
"""

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

ROOT             = Path(__file__).resolve().parent
VERSION_FILE     = ROOT / "VERSION"
DEPLOY_DIR       = ROOT / "deploy"
SPEC_FILE        = ROOT / "packaging" / "dmeworks.spec"
VERSION_INFO_OUT = ROOT / "packaging" / "version_info.txt"
EXE_OUT          = ROOT / "dist" / "dme-auto.exe"


# ─── VERSION ──────────────────────────────────────────────────────────────────

def read_version() -> str:
    return VERSION_FILE.read_text().strip()


def bump_version(part: str) -> str:
    v = read_version()
    major, minor, patch = map(int, v.split("."))
    if part == "major":
        major += 1; minor = 0; patch = 0
    elif part == "minor":
        minor += 1; patch = 0
    elif part == "patch":
        patch += 1
    new_v = f"{major}.{minor}.{patch}"
    VERSION_FILE.write_text(new_v + "\n")
    print(f"  Version: {v} -> {new_v}")
    return new_v


# ─── BUILD STEPS ──────────────────────────────────────────────────────────────

def write_version_info(version: str) -> None:
    major, minor, patch = (int(x) for x in version.split("."))
    VERSION_INFO_OUT.write_text(f"""\
VSVersionInfo(
  ffi=FixedFileInfo(
    filevers=({major}, {minor}, {patch}, 0),
    prodvers=({major}, {minor}, {patch}, 0),
    mask=0x3f, flags=0x0, OS=0x40004, fileType=0x1, subtype=0x0,
    date=(0, 0)
  ),
  kids=[
    StringFileInfo([
      StringTable('040904B0', [
        StringStruct('CompanyName',      'PDT'),
        StringStruct('FileDescription',  'DME Auto'),
        StringStruct('FileVersion',      '{version}'),
        StringStruct('InternalName',     'dme-auto'),
        StringStruct('ProductName',      'DME Auto'),
        StringStruct('ProductVersion',   '{version}'),
      ])
    ]),
    VarFileInfo([VarStruct('Translation', [0x0409, 1200])])
  ]
)
""", encoding="utf-8")


def build_exe(version: str, verbose: bool = False) -> None:
    write_version_info(version)
    print("\n[1/2] Building EXE via PyInstaller...")
    cmd = [sys.executable, "-m", "PyInstaller", "--noconfirm", str(SPEC_FILE)]
    if verbose:
        cmd += ["--log-level", "DEBUG"]
        result = subprocess.run(cmd, cwd=ROOT)
    else:
        result = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    if result.returncode != 0:
        if not verbose:
            print(result.stdout[-3000:])
            print(result.stderr[-2000:])
        sys.exit(1)
    size_mb = EXE_OUT.stat().st_size / 1_048_576
    print(f"      {EXE_OUT.name}  ({size_mb:.1f} MB)")


def package(version: str) -> None:
    print(f"\n[2/2] Packaging deploy/...")
    if DEPLOY_DIR.exists():
        shutil.rmtree(DEPLOY_DIR)
    DEPLOY_DIR.mkdir(parents=True)

    versioned = f"dme-auto-{version}.exe"
    shutil.copy2(EXE_OUT, DEPLOY_DIR / versioned)
    print(f"      {versioned}")


# ─── MAIN ─────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="DME Auto build script")
    parser.add_argument("--bump", choices=["major", "minor", "patch"],
                        help="Bump version before building")
    parser.add_argument("--no-package", action="store_true",
                        help="Build EXE but skip deployment packaging")
    parser.add_argument("--verbose", "-v", action="store_true",
                        help="Stream PyInstaller output live (DEBUG log level)")
    args = parser.parse_args()

    version = bump_version(args.bump) if args.bump else read_version()

    print("=" * 50)
    print(f"  DME Auto  v{version}")
    print("=" * 50)

    build_exe(version, verbose=args.verbose)

    if not args.no_package:
        package(version)
        print(f"\n  Deploy package: deploy/")

    print("\n" + "=" * 50)
    print(f"  Build complete  v{version}")
    print("=" * 50)


if __name__ == "__main__":
    main()
