"""
First-run credential setup — stores Notion token and MySQL credentials
in Windows Credential Manager (DPAPI-backed, machine-bound).

Usage:
  python entry_setup.py
  dmeworks-entry.exe --setup
"""

import getpass
import os
import sys

_ROOT = os.path.dirname(os.path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)


def run_setup() -> None:
    from utils.creds import set_notion_token, set_db_config

    print()
    print("=" * 56)
    print("  DMEworks Entry — First-Time Setup")
    print("=" * 56)
    print()
    print("  Credentials are stored in Windows Credential Manager.")
    print("  They are machine-bound and encrypted by Windows (DPAPI).")
    print("  They are NEVER written to disk.")
    print()

    # ── Notion token ───────────────────────────────────────────
    token = getpass.getpass("  Notion API token (starts with ntn_): ").strip()
    if not token:
        print("  Error: token is required.")
        sys.exit(1)
    if not token.startswith("ntn_"):
        print("  Error: Notion token must start with 'ntn_'. Check your token.")
        sys.exit(1)
    set_notion_token(token)
    print("  [OK] Notion token stored.")
    print()

    # ── DB credentials ─────────────────────────────────────────
    client_code = input("  Client code (e.g. ALLIED): ").strip().upper()
    if not client_code:
        print("  Error: client code is required.")
        sys.exit(1)

    host     = input("  MySQL host:         ").strip()
    port_str = input("  MySQL port [3306]:  ").strip() or "3306"
    user     = input("  MySQL user:         ").strip()
    password = getpass.getpass("  MySQL password:     ").strip()
    database = input("  MySQL database:     ").strip()

    if not all([host, user, password, database]):
        print("  Error: host, user, password, and database are required.")
        sys.exit(1)

    try:
        port = int(port_str)
    except ValueError:
        print(f"  Error: invalid port '{port_str}'")
        sys.exit(1)

    set_db_config(client_code, {
        "host":     host,
        "port":     port,
        "user":     user,
        "password": password,
        "database": database,
    })
    print(f"  [OK] DB credentials for '{client_code}' stored.")
    print()
    print("  Setup complete.")
    print(f"  Run: dmeworks-entry.exe --client {client_code}")
    print("=" * 56)
    print()


if __name__ == "__main__":
    run_setup()
