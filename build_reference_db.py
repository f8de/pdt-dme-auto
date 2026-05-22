"""
One-time script: build reference.db from data/medicare_jurisdictions.csv.
reference.db is bundled into the EXE and contains no PHI — public CMS data only.

Usage:
  python build_reference_db.py
"""

import csv
import os
import sqlite3
import sys

_ROOT = os.path.dirname(os.path.abspath(__file__))
_CSV  = os.path.join(_ROOT, "data", "medicare_jurisdictions.csv")
_OUT  = os.path.join(_ROOT, "reference.db")


def main():
    if not os.path.exists(_CSV):
        print(f"ERROR: {_CSV} not found")
        sys.exit(1)

    conn = sqlite3.connect(_OUT)
    conn.execute("DROP TABLE IF EXISTS medicare_map")
    conn.execute(
        "CREATE TABLE medicare_map (state TEXT PRIMARY KEY, dmerc_name TEXT NOT NULL)"
    )

    with open(_CSV, newline="", encoding="utf-8") as f:
        rows = [(r["state"].strip(), r["dmerc_name"].strip()) for r in csv.DictReader(f)]

    conn.executemany("INSERT INTO medicare_map VALUES (?, ?)", rows)
    conn.commit()
    conn.close()

    print(f"Built reference.db — {len(rows)} Medicare DMERC entries")
    print(f"Output: {_OUT}")


if __name__ == "__main__":
    main()
