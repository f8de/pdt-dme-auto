"""
First-run setup instructions for DMEworks Entry.

No credentials are stored locally. Everything lives in:
  - Windows PowerShell SecretManagement (Notion token only)
  - Notion Clients DB (MySQL credentials per client)

Usage:
  python entry_setup.py
  dmeworks-entry.exe --setup
"""

import os
import sys

_ROOT = os.path.dirname(os.path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)


def run_setup() -> None:
    print()
    print("=" * 60)
    print("  DMEworks Entry — Setup Instructions")
    print("=" * 60)
    print()
    print("  No secrets are stored on this machine.")
    print()
    print("  STEP 1 — Store your Notion token (one-time, per machine)")
    print("  ─────────────────────────────────────────────────────────")
    print("  Run in PowerShell (requires SecretManagement module):")
    print()
    print("    Install-Module -Name Microsoft.PowerShell.SecretManagement -Force")
    print("    Install-Module -Name Microsoft.PowerShell.SecretStore -Force")
    print("    Register-SecretVault -Name local -ModuleName Microsoft.PowerShell.SecretStore")
    print("    Set-Secret -Vault local -Name notion-token -Secret 'ntn_YOUR_TOKEN_HERE'")
    print()
    print("  The vault is backed by Windows Hello / PIN — no master password.")
    print("  Token never touches disk.")
    print()
    print("  STEP 2 — Add your client to Notion Clients DB")
    print("  ──────────────────────────────────────────────")
    print("  Open the Clients database in Notion and add a row:")
    print()
    print("    Client Code  : ALLIED   (uppercase, matches --client flag)")
    print("    Client Name  : Allied Medical")
    print("    DB Host      : 192.168.x.x")
    print("    DB Port      : 3306")
    print("    DB User      : dmeworks")
    print("    DB Password  : your-mysql-password")
    print("    DB Database  : dmeworks")
    print("    Active       : ☑  (checked)")
    print()
    print("  MySQL credentials stay in Notion — never on this machine.")
    print()
    print("  STEP 3 — Run the tool")
    print("  ──────────────────────")
    print("  Use run.ps1 (injects token automatically):")
    print()
    print("    .\\run.ps1 --client ALLIED")
    print("    .\\run.ps1 --client ALLIED --dry-run")
    print()
    print("  Or set the token manually and run the EXE directly:")
    print()
    print("    $env:NOTION_TOKEN = Get-Secret -Vault local -Name notion-token -AsPlainText")
    print("    .\\dmeworks-entry.exe --client ALLIED")
    print()
    print("=" * 60)
    print()


if __name__ == "__main__":
    run_setup()
