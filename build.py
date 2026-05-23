"""
Build script — EXE, versioned deployment package.

Usage:
  python build.py                     Build with current VERSION
  python build.py --bump patch        Bump patch, then build  (0.1.0 -> 0.1.1)
  python build.py --bump minor        Bump minor              (0.1.0 -> 0.2.0)
  python build.py --bump major        Bump major              (0.1.0 -> 1.0.0)
  python build.py --no-package        Build EXE but skip deploy packaging

Output:
  dist/dmeworks-entry.exe             Raw PyInstaller output
  deploy/dmeworks-v{version}/         Deployment-ready folder
    dmeworks-entry.exe
    run.ps1
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

def build_exe():
    print("\n[1/2] Building EXE via PyInstaller...")
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
    print(f"\n[2/2] Packaging deploy/dmeworks-v{version}/...")
    out_dir = DEPLOY_DIR / f"dmeworks-v{version}"
    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True)

    shutil.copy2(EXE_OUT, out_dir / "dmeworks-entry.exe")
    shutil.copy2(ROOT / "run.ps1", out_dir / "run.ps1")

    (out_dir / "DEPLOY.md").write_text(f"""\
# DMEworks Entry v{version}

## First-time setup on target machine

1. Copy this entire folder to the machine (e.g. `C:\\DMEworks-Entry\\`)
2. Generate a Doppler service token:
   - Doppler dashboard > dme-auto project > dev config > Access > Service Tokens > Generate
3. Run setup to encrypt and store the token (DPAPI — tied to this user + machine):
   ```powershell
   .\\run.ps1 --setup
   ```
   Paste the Doppler service token when prompted. One-time only.
4. Add client config to Notion Clients database (host, user, password, db)
5. DMEworks must be open before running entry

## Run

```powershell
.\\run.ps1
```

## Files

| File                 | Purpose                                         |
|----------------------|-------------------------------------------------|
| `dmeworks-entry.exe` | Standalone executable — no Python required      |
| `run.ps1`            | Launcher — decrypts Doppler token, fetches NOTION_TOKEN at runtime |

## Version

`{version}`
""", encoding="utf-8")

    print(f"      {out_dir}")
    return out_dir


# ─── MAIN ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="DMEworks build script")
    parser.add_argument("--bump", choices=["major", "minor", "patch"],
                        help="Bump version before building")
    parser.add_argument("--no-package", action="store_true",
                        help="Build EXE but skip deployment packaging")
    args = parser.parse_args()

    version = bump_version(args.bump) if args.bump else read_version()

    print("=" * 52)
    print(f"  DMEworks Build  v{version}")
    print("=" * 52)

    build_exe()

    if not args.no_package:
        out_dir = package(version)
        print(f"\n  Deploy package: {out_dir.relative_to(ROOT)}")

    print("\n" + "=" * 52)
    print(f"  Build complete  v{version}")
    print("=" * 52)


if __name__ == "__main__":
    main()
