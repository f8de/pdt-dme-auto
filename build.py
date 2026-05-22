"""
Build script — reference DB, EXE, versioned deployment package.

Usage:
  python build.py                     Build with current VERSION
  python build.py --bump patch        Bump patch, then build  (0.1.0 -> 0.1.1)
  python build.py --bump minor        Bump minor              (0.1.0 -> 0.2.0)
  python build.py --bump major        Bump major              (0.1.0 -> 1.0.0)
  python build.py --ref-only          Build reference.db only (no EXE)
  python build.py --no-package        Build EXE but skip deploy packaging

Output:
  dist/dmeworks-entry.exe             Raw PyInstaller output
  deploy/dmeworks-v{version}/         Deployment-ready folder
    dmeworks-entry.exe
    data/                             Empty — drop clients.enc here
    DEPLOY.md
"""

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT         = Path(__file__).resolve().parent
VERSION_FILE = ROOT / "VERSION"
DEPLOY_DIR   = ROOT / "deploy"
ASSETS_DIR   = ROOT / "assets"
SPEC_FILE    = ROOT / "packaging" / "dmeworks.spec"
EXE_OUT      = ROOT / "dist" / "dmeworks-entry.exe"


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
    print(f"  Version: {v} → {new_v}")
    return new_v


# ─── BUILD STEPS ──────────────────────────────────────────────────────────────

def build_reference_db():
    print("\n[1/3] Building reference.db...")
    result = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "build_reference_db.py")],
        cwd=ROOT, capture_output=True, text=True
    )
    if result.returncode != 0:
        print(result.stderr)
        sys.exit(1)
    print(f"      {result.stdout.strip()}")


def build_exe():
    print("\n[2/3] Building EXE via PyInstaller...")
    result = subprocess.run(
        [sys.executable, "-m", "PyInstaller", "--noconfirm", str(SPEC_FILE)],
        cwd=ROOT, capture_output=True, text=True
    )
    if result.returncode != 0:
        print(result.stdout[-3000:])
        print(result.stderr[-2000:])
        sys.exit(1)
    size_mb = EXE_OUT.stat().st_size / 1_048_576
    print(f"      {EXE_OUT.name}  ({size_mb:.1f} MB)")


def package(version: str) -> Path:
    print(f"\n[3/3] Packaging deploy/dmeworks-v{version}/...")
    out_dir = DEPLOY_DIR / f"dmeworks-v{version}"
    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True)

    shutil.copy2(EXE_OUT, out_dir / "dmeworks-entry.exe")
    (out_dir / "data").mkdir()

    (out_dir / "DEPLOY.md").write_text(f"""\
# DMEworks Entry v{version}

## First-time setup on target machine

1. Copy this entire folder to the machine (e.g. `C:\\DMEworks-Entry\\`)
2. Ensure `data\\clients.enc` is present (copy from source machine or run setup)
3. DMEworks must be open before running

## Run

```
dmeworks-entry.exe --client <code>
dmeworks-entry.exe --client <code> --dry-run
```

Run `manage_clients.py list` on the source machine to see client codes.

## Files

| File/Folder         | Purpose                                      |
|---------------------|----------------------------------------------|
| `dmeworks-entry.exe`| Standalone executable — no Python required   |
| `data/clients.enc`  | Encrypted client database (copy from source) |

## Version

`{version}`
""")

    print(f"      {out_dir}")
    return out_dir


# ─── MAIN ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="DMEworks build script")
    parser.add_argument("--bump", choices=["major", "minor", "patch"],
                        help="Bump version before building")
    parser.add_argument("--ref-only", action="store_true",
                        help="Build reference.db only, skip EXE")
    parser.add_argument("--no-package", action="store_true",
                        help="Build EXE but skip deployment packaging")
    args = parser.parse_args()

    version = bump_version(args.bump) if args.bump else read_version()

    print("=" * 52)
    print(f"  DMEworks Build  v{version}")
    print("=" * 52)

    build_reference_db()

    if args.ref_only:
        print("\nDone (reference.db only).")
        return

    build_exe()

    if not args.no_package:
        out_dir = package(version)
        print(f"\n  Deploy package: {out_dir.relative_to(ROOT)}")

    print("\n" + "=" * 52)
    print(f"  Build complete  v{version}")
    print("=" * 52)


if __name__ == "__main__":
    main()
