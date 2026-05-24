import logging
import os
import sys
import re
import time
from datetime import datetime


_FMT     = "[%(asctime)s] %(levelname)-8s  %(name)-10s  %(message)s"
_DATEFMT = "%Y-%m-%d %H:%M:%S"
_KEEP_DAYS = 7


def _log_dir() -> str:
    if getattr(sys, "frozen", False):
        return os.path.join(os.path.dirname(sys.executable), "logs")
    return os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "logs")


def _purge_old_logs(log_dir: str) -> None:
    cutoff = time.time() - _KEEP_DAYS * 86400
    for fname in os.listdir(log_dir):
        if fname.startswith("dme-auto-") and fname.endswith(".log"):
            fpath = os.path.join(log_dir, fname)
            try:
                if os.path.getmtime(fpath) < cutoff:
                    os.remove(fpath)
            except OSError:
                pass


def get_logger(name: str = "dmeworks") -> logging.Logger:
    log_dir = _log_dir()
    os.makedirs(log_dir, exist_ok=True)
    _purge_old_logs(log_dir)
    log_file = os.path.join(log_dir, f"dme-auto-{datetime.now():%Y-%m-%d}.log")

    logger = logging.getLogger(name)
    if logger.handlers:
        return logger

    logger.setLevel(logging.DEBUG)

    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    ch.setFormatter(logging.Formatter(_FMT, _DATEFMT))

    fh = logging.FileHandler(log_file, mode="a", encoding="utf-8")
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(logging.Formatter(_FMT, _DATEFMT))

    logger.addHandler(ch)
    logger.addHandler(fh)

    return logger


def mask_mbi(mbi: str) -> str:
    """Return masked MBI for logs — shows first 4 chars only."""
    clean = re.sub(r"[-\s]", "", mbi)
    prefix = clean[:4] if len(clean) >= 4 else clean
    return f"{prefix}-***-****"


def mask_dob(dob: str) -> str:
    return "**/**/****"
