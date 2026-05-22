"""
All client data (patients, doctors, insurance companies, DB credentials) lives in
a single Fernet-encrypted SQLite file: data/clients.enc.

Decryption produces an in-memory SQLite connection — plaintext never persists to disk.
Static reference data (Medicare DMERC map) is loaded from reference.db, which is
bundled into the EXE and contains no PHI.
"""
import json
import os
import sqlite3
import sys
import tempfile
from pathlib import Path

from utils.crypto import encrypt_bytes, decrypt_to_bytes

_DATA_DIR = Path(__file__).resolve().parent.parent / "data"
_ENC_PATH = _DATA_DIR / "clients.enc"


def _ref_db_path() -> str:
    if hasattr(sys, "_MEIPASS"):
        return os.path.join(sys._MEIPASS, "reference.db")
    return str(Path(__file__).resolve().parent.parent / "assets" / "reference.db")


# ─── LOW-LEVEL DB I/O ─────────────────────────────────────────────────────────

def open_db() -> sqlite3.Connection:
    """Decrypt clients.enc → in-memory SQLite. Plaintext bytes exist only in RAM."""
    if not _ENC_PATH.exists():
        raise FileNotFoundError(
            f"clients.enc not found at {_ENC_PATH}\n"
            "First run: python manage_clients.py init"
        )
    raw = decrypt_to_bytes(_ENC_PATH)
    fd, tmp = tempfile.mkstemp(suffix=".db")
    try:
        os.write(fd, raw)
        os.close(fd)
        src = sqlite3.connect(tmp)
        mem = sqlite3.connect(":memory:")
        mem.row_factory = sqlite3.Row
        src.backup(mem)
        src.close()
    finally:
        os.unlink(tmp)
    return mem


def save_db(conn: sqlite3.Connection) -> None:
    """Backup in-memory SQLite → encrypt → write clients.enc atomically."""
    _DATA_DIR.mkdir(exist_ok=True)
    fd, tmp = tempfile.mkstemp(suffix=".db")
    os.close(fd)
    try:
        dst = sqlite3.connect(tmp)
        conn.backup(dst)
        dst.close()
        raw = Path(tmp).read_bytes()
        _ENC_PATH.write_bytes(encrypt_bytes(raw))
    finally:
        os.unlink(tmp)


def create_schema(conn: sqlite3.Connection) -> None:
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS clients (
            id   INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            code TEXT UNIQUE NOT NULL
        );
        CREATE TABLE IF NOT EXISTS client_db (
            client_id INTEGER PRIMARY KEY REFERENCES clients(id),
            host      TEXT    NOT NULL DEFAULT 'localhost',
            port      INTEGER NOT NULL DEFAULT 3306,
            user      TEXT    NOT NULL,
            password  TEXT    NOT NULL,
            database  TEXT    NOT NULL
        );
        CREATE TABLE IF NOT EXISTS doctors (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER NOT NULL REFERENCES clients(id),
            last      TEXT, first    TEXT, mi      TEXT, suffix  TEXT,
            npi       TEXT, address1 TEXT, city    TEXT,
            state     TEXT, zip      TEXT, phone   TEXT
        );
        CREATE TABLE IF NOT EXISTS patients (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER NOT NULL REFERENCES clients(id),
            last      TEXT, first    TEXT, mi      TEXT, suffix  TEXT,
            dob       TEXT, mbi      TEXT,
            address1  TEXT, city     TEXT, state   TEXT,
            zip       TEXT, phone    TEXT, doctor  TEXT,
            icd10     TEXT,
            secondary TEXT,
            notes     TEXT
        );
        CREATE TABLE IF NOT EXISTS insurance_companies (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER NOT NULL REFERENCES clients(id),
            name      TEXT,
            type      TEXT
        );
    """)
    conn.commit()


# ─── CLIENT STORE ─────────────────────────────────────────────────────────────

class ClientStore:
    """Decrypted view of a single client's data. Call close() when done."""

    def __init__(self, client_code: str):
        self._conn = open_db()
        row = self._conn.execute(
            "SELECT id, name FROM clients WHERE code = ?", (client_code,)
        ).fetchone()
        if not row:
            available = [
                r[0] for r in
                self._conn.execute("SELECT code FROM clients ORDER BY code").fetchall()
            ]
            raise ValueError(
                f"Unknown client: {client_code!r}\n"
                f"Available: {available or ['(none — run manage_clients.py add-client)']}"
            )
        self._client_id   = row["id"]
        self._client_name = row["name"]

    def close(self) -> None:
        self._conn.close()

    @property
    def client_name(self) -> str:
        return self._client_name

    @property
    def doctors(self) -> list[dict]:
        rows = self._conn.execute(
            "SELECT last,first,mi,suffix,npi,address1,city,state,zip,phone "
            "FROM doctors WHERE client_id = ?", (self._client_id,)
        ).fetchall()
        return [dict(r) for r in rows]

    @property
    def patients(self) -> list[dict]:
        rows = self._conn.execute(
            "SELECT last,first,mi,suffix,dob,mbi,address1,city,state,zip,phone,"
            "       doctor,icd10,secondary,notes "
            "FROM patients WHERE client_id = ?", (self._client_id,)
        ).fetchall()
        result = []
        for r in rows:
            p = dict(r)
            p["icd10"]     = json.loads(p["icd10"] or "[]")
            p["secondary"] = json.loads(p["secondary"]) if p["secondary"] else None
            result.append(p)
        return result

    @property
    def insurance_companies(self) -> list[dict]:
        rows = self._conn.execute(
            "SELECT name, type FROM insurance_companies WHERE client_id = ?",
            (self._client_id,)
        ).fetchall()
        return [dict(r) for r in rows]

    @property
    def db_config(self) -> dict:
        row = self._conn.execute(
            "SELECT host,port,user,password,database "
            "FROM client_db WHERE client_id = ?", (self._client_id,)
        ).fetchone()
        if not row:
            raise ValueError(
                f"No DB config for client. Run: "
                f"python manage_clients.py set-db <code> ..."
            )
        return dict(row)

    @staticmethod
    def medicare_map() -> dict[str, str]:
        path = _ref_db_path()
        if not os.path.exists(path):
            raise FileNotFoundError(
                f"reference.db not found at {path}\n"
                "Run: python build_reference_db.py"
            )
        conn = sqlite3.connect(path)
        try:
            rows = conn.execute(
                "SELECT state, dmerc_name FROM medicare_map"
            ).fetchall()
            return {r[0]: r[1] for r in rows}
        finally:
            conn.close()
