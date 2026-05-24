"""
DMEworks Ingest TEST — runs ingest against the test client (c01).
Dry-run by default. Pass --live to write to c01 database.

Usage:
  python ingest_test.py          # dry-run against c01
  python ingest_test.py --live   # live writes to c01
"""

import os
import sys

_ROOT = os.path.dirname(os.path.abspath(__file__))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

if "--client" not in sys.argv:
    sys.argv += ["--client", "c01"]

import ingest
ingest.run()
