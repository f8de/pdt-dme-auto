import logging
import os
import re
import sys

_FMT     = "[%(asctime)s] %(levelname)-8s  %(name)-10s  %(message)s"
_DATEFMT = "%Y-%m-%d %H:%M:%S"


def _log_dir() -> str:
    if getattr(sys, "frozen", False):
        return os.path.join(os.path.dirname(sys.executable), "logs")
    return os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "logs")


def get_logger(name: str = "dmeworks") -> logging.Logger:
    log_dir = _log_dir()
    os.makedirs(log_dir, exist_ok=True)
    log_file = os.path.join(log_dir, "dme-auto.log")

    logger = logging.getLogger(name)
    if logger.handlers:
        return logger

    logger.setLevel(logging.DEBUG)

    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    ch.setFormatter(logging.Formatter(_FMT, _DATEFMT))

    fh = logging.FileHandler(log_file, mode="w", encoding="utf-8")
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(logging.Formatter(_FMT, _DATEFMT))

    logger.addHandler(ch)
    logger.addHandler(fh)

    return logger


# ─── PHI MASKING ──────────────────────────────────────────────────────────────

def mask_mbi(mbi: str) -> str:
    """1EG4TE5MK72 or 1EG4-TE5-MK72 -> 1EG4-***-****"""
    clean = re.sub(r"[-\s]", "", mbi)
    prefix = clean[:4] if len(clean) >= 4 else clean
    return f"{prefix}-***-****"


def mask_dob(dob: str) -> str:
    """01/15/1950 -> **/**/****"""
    return "**/**/****"
