import csv
import io
import zipfile
from datetime import datetime, timezone

import requests

# URL uses year only — CMS publishes one annual file, no quarter suffix
_CMS_URL_PATTERN = "https://www.cms.gov/files/zip/dme{yy}.zip"

# Column indices in DMEPOS26_JAN.txt — tilde-delimited, 17 columns.
# Confirmed via live probe of dme26.zip on 2026-06-01.
_COL_HCPCS = 1   # e.g. 'L0457'
_COL_STATE  = 8   # e.g. 'NJ     ' (padded to 7 chars — strip before use)
_COL_FEE    = 9   # e.g. '000412.50' (zero-padded — float() handles it)


def _current_quarter(now: datetime | None = None) -> str:
    """Return 2+1 char string e.g. '26b' for April-June 2026.
    Year part used for URL; quarter letter available for display/future use."""
    if now is None:
        now = datetime.now(timezone.utc)
    year = str(now.year)[2:]
    quarter = ["a","a","a","b","b","b","c","c","c","d","d","d"][now.month - 1]
    return f"{year}{quarter}"
