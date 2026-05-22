"""
Client data management CLI.
All client data (patients, doctors, insurance, DB credentials) stored in data/clients.enc.

Commands:
  init                                   Create new empty clients.enc
  add-client <name> <code>               Add a client
  set-db <code> <host> <port> <user> <password> <database>
                                         Set DB credentials for a client
  import <code> --doctors FILE --patients FILE --insurance FILE
                                         Import CSV data for a client
  list                                   List all clients
  list-patients <code>                   List patients for a client
  delete-client <code>                   Delete a client and all their data
"""

import argparse
import csv
import json
import sqlite3
import sys

_ROOT = __import__("os").path.dirname(__import__("os").path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from utils.client_store import ClientStore, create_schema, open_db, save_db
from utils.crypto import has_master_key


# ─── HELPERS ──────────────────────────────────────────────────────────────────

def _get_client_id(conn: sqlite3.Connection, code: str) -> int:
    row = conn.execute("SELECT id FROM clients WHERE code = ?", (code,)).fetchone()
    if not row:
        print(f"ERROR: Unknown client code: {code!r}")
        sys.exit(1)
    return row[0]


def _load_doctors_csv(path: str) -> list[dict]:
    with open(path, newline="", encoding="utf-8") as f:
        return [
            {
                "last":     r["last"].strip(),
                "first":    r["first"].strip(),
                "mi":       r.get("mi", "").strip(),
                "suffix":   r.get("suffix", "").strip(),
                "npi":      r["npi"].strip(),
                "address1": r["address1"].strip(),
                "city":     r["city"].strip(),
                "state":    r["state"].strip(),
                "zip":      r["zip"].strip(),
                "phone":    r["phone"].strip(),
            }
            for r in csv.DictReader(f)
        ]


def _load_patients_csv(path: str) -> list[dict]:
    with open(path, newline="", encoding="utf-8") as f:
        rows = []
        for r in csv.DictReader(f):
            icd10 = [
                r[f"icd10_{i}"].strip()
                for i in range(1, 9)
                if r.get(f"icd10_{i}", "").strip()
            ]
            sec_company = r.get("sec_company", "").strip()
            secondary = None
            if sec_company:
                secondary = {
                    "ins_company": sec_company,
                    "ins_type":    r.get("sec_type", "").strip(),
                    "policy":      r.get("sec_policy", "").strip(),
                    "group":       r.get("sec_group", "").strip(),
                }
            rows.append({
                "last":      r["last"].strip(),
                "first":     r["first"].strip(),
                "mi":        r.get("mi", "").strip(),
                "suffix":    r.get("suffix", "").strip(),
                "dob":       r["dob"].strip(),
                "mbi":       r["mbi"].strip(),
                "address1":  r["address1"].strip(),
                "city":      r["city"].strip(),
                "state":     r["state"].strip(),
                "zip":       r["zip"].strip(),
                "phone":     r["phone"].strip(),
                "doctor":    r["doctor"].strip(),
                "icd10":     icd10,
                "secondary": secondary,
                "notes":     (r.get("notes") or "").strip(),
            })
        return rows


def _load_insurance_csv(path: str) -> list[dict]:
    with open(path, newline="", encoding="utf-8") as f:
        return [
            {"name": r["name"].strip(), "type": r["type"].strip().upper()}
            for r in csv.DictReader(f)
        ]


# ─── COMMANDS ─────────────────────────────────────────────────────────────────

def cmd_init(args):
    from utils.client_store import _ENC_PATH
    if _ENC_PATH.exists():
        print(f"clients.enc already exists at {_ENC_PATH}")
        print("Delete it manually if you want to start fresh.")
        sys.exit(1)
    conn = sqlite3.connect(":memory:")
    conn.row_factory = sqlite3.Row
    create_schema(conn)
    save_db(conn)
    conn.close()
    print(f"Created: {_ENC_PATH}")
    print("Master key stored in Windows Credential Manager.")


def cmd_add_client(args):
    conn = open_db()
    existing = conn.execute(
        "SELECT code FROM clients WHERE code = ?", (args.code,)
    ).fetchone()
    if existing:
        print(f"ERROR: Client code {args.code!r} already exists.")
        conn.close()
        sys.exit(1)
    conn.execute(
        "INSERT INTO clients (name, code) VALUES (?, ?)", (args.name, args.code)
    )
    conn.commit()
    save_db(conn)
    conn.close()
    print(f"Added client: {args.name!r} (code: {args.code!r})")


def cmd_set_db(args):
    conn = open_db()
    client_id = _get_client_id(conn, args.code)
    conn.execute(
        "INSERT OR REPLACE INTO client_db (client_id, host, port, user, password, database) "
        "VALUES (?, ?, ?, ?, ?, ?)",
        (client_id, args.host, args.port, args.user, args.password, args.database)
    )
    conn.commit()
    save_db(conn)
    conn.close()
    print(f"DB config set for {args.code!r}: {args.host}:{args.port}/{args.database}")


def cmd_import(args):
    conn = open_db()
    client_id = _get_client_id(conn, args.code)

    if args.doctors:
        doctors = _load_doctors_csv(args.doctors)
        conn.execute("DELETE FROM doctors WHERE client_id = ?", (client_id,))
        conn.executemany(
            "INSERT INTO doctors (client_id,last,first,mi,suffix,npi,address1,city,state,zip,phone) "
            "VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            [(client_id, d["last"], d["first"], d["mi"], d["suffix"], d["npi"],
              d["address1"], d["city"], d["state"], d["zip"], d["phone"])
             for d in doctors]
        )
        print(f"  Imported {len(doctors)} doctor(s)")

    if args.patients:
        patients = _load_patients_csv(args.patients)
        conn.execute("DELETE FROM patients WHERE client_id = ?", (client_id,))
        conn.executemany(
            "INSERT INTO patients (client_id,last,first,mi,suffix,dob,mbi,"
            "address1,city,state,zip,phone,doctor,icd10,secondary,notes) "
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            [(client_id, p["last"], p["first"], p["mi"], p["suffix"], p["dob"], p["mbi"],
              p["address1"], p["city"], p["state"], p["zip"], p["phone"], p["doctor"],
              json.dumps(p["icd10"]), json.dumps(p["secondary"]) if p["secondary"] else None,
              p["notes"])
             for p in patients]
        )
        print(f"  Imported {len(patients)} patient(s)")

    if args.insurance:
        companies = _load_insurance_csv(args.insurance)
        conn.execute("DELETE FROM insurance_companies WHERE client_id = ?", (client_id,))
        conn.executemany(
            "INSERT INTO insurance_companies (client_id, name, type) VALUES (?, ?, ?)",
            [(client_id, c["name"], c["type"]) for c in companies]
        )
        print(f"  Imported {len(companies)} insurance company(s)")

    conn.commit()
    save_db(conn)
    conn.close()
    print(f"Data saved to clients.enc for client {args.code!r}")


def cmd_list(args):
    conn = open_db()
    rows = conn.execute(
        "SELECT c.code, c.name, "
        "  (SELECT COUNT(*) FROM patients  WHERE client_id=c.id) AS patients, "
        "  (SELECT COUNT(*) FROM doctors   WHERE client_id=c.id) AS doctors, "
        "  CASE WHEN db.client_id IS NOT NULL THEN 'yes' ELSE 'NO' END AS db_set "
        "FROM clients c "
        "LEFT JOIN client_db db ON db.client_id = c.id "
        "ORDER BY c.code"
    ).fetchall()
    conn.close()
    if not rows:
        print("No clients. Run: python manage_clients.py add-client <name> <code>")
        return
    print(f"\n{'Code':<20} {'Name':<30} {'Patients':>8} {'Doctors':>7} {'DB':>4}")
    print("-" * 72)
    for r in rows:
        print(f"{r[0]:<20} {r[1]:<30} {r[2]:>8} {r[3]:>7} {r[4]:>4}")
    print()


def cmd_list_patients(args):
    conn = open_db()
    client_id = _get_client_id(conn, args.code)
    rows = conn.execute(
        "SELECT last, first, mbi, dob, state FROM patients WHERE client_id = ? ORDER BY last, first",
        (client_id,)
    ).fetchall()
    conn.close()
    if not rows:
        print(f"No patients for {args.code!r}")
        return
    print(f"\n{'Last':<15} {'First':<12} {'MBI (masked)':<18} {'DOB (masked)':<14} State")
    print("-" * 65)
    from utils.logger import mask_mbi, mask_dob
    for r in rows:
        print(f"{r[0]:<15} {r[1]:<12} {mask_mbi(r[2]):<18} {mask_dob(r[3]):<14} {r[4]}")
    print()


def cmd_delete_client(args):
    conn = open_db()
    client_id = _get_client_id(conn, args.code)
    row = conn.execute("SELECT name FROM clients WHERE id = ?", (client_id,)).fetchone()
    confirm = input(f"Delete client {row[0]!r} ({args.code}) and ALL their data? [yes/N]: ").strip()
    if confirm.lower() != "yes":
        print("Aborted.")
        conn.close()
        sys.exit(0)
    for table in ("patients", "doctors", "insurance_companies", "client_db"):
        conn.execute(f"DELETE FROM {table} WHERE client_id = ?", (client_id,))
    conn.execute("DELETE FROM clients WHERE id = ?", (client_id,))
    conn.commit()
    save_db(conn)
    conn.close()
    print(f"Deleted client {args.code!r} and all associated data.")


# ─── MAIN ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="DMEworks client data manager",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("init", help="Create new empty clients.enc")

    p_add = sub.add_parser("add-client", help="Add a client")
    p_add.add_argument("name", help="Client display name (e.g. 'Allied Medical Health')")
    p_add.add_argument("code", help="Short code for CLI use (e.g. 'allied')")

    p_db = sub.add_parser("set-db", help="Set DB credentials for a client")
    p_db.add_argument("code")
    p_db.add_argument("host")
    p_db.add_argument("port", type=int)
    p_db.add_argument("user")
    p_db.add_argument("password")
    p_db.add_argument("database")

    p_imp = sub.add_parser("import", help="Import CSV data for a client")
    p_imp.add_argument("code")
    p_imp.add_argument("--doctors",   metavar="FILE")
    p_imp.add_argument("--patients",  metavar="FILE")
    p_imp.add_argument("--insurance", metavar="FILE")

    sub.add_parser("list", help="List all clients")

    p_lp = sub.add_parser("list-patients", help="List patients for a client (PHI masked)")
    p_lp.add_argument("code")

    p_del = sub.add_parser("delete-client", help="Delete a client and all their data")
    p_del.add_argument("code")

    args = parser.parse_args()

    if not has_master_key() and args.command != "init":
        print("No master key found. Run: python manage_clients.py init")
        sys.exit(1)

    dispatch = {
        "init":           cmd_init,
        "add-client":     cmd_add_client,
        "set-db":         cmd_set_db,
        "import":         cmd_import,
        "list":           cmd_list,
        "list-patients":  cmd_list_patients,
        "delete-client":  cmd_delete_client,
    }
    dispatch[args.command](args)


if __name__ == "__main__":
    main()
