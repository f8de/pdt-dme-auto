import logging
import os
import time
from datetime import datetime
from pathlib import Path
from unittest.mock import patch
import tempfile
import pytest


def _fresh_logger(name: str, log_dir: str):
    existing = logging.getLogger(name)
    for h in existing.handlers[:]:
        existing.removeHandler(h)
    import utils.logger as ul
    with patch("utils.logger._log_dir", side_effect=lambda: log_dir):
        return ul.get_logger(name)


def _close_handlers(logger: logging.Logger):
    for h in logger.handlers[:]:
        h.close()
        logger.removeHandler(h)


def test_logger_uses_daily_filename():
    with tempfile.TemporaryDirectory() as tmpdir:
        logger = _fresh_logger("test_daily", tmpdir)
        try:
            fh = next(h for h in logger.handlers if isinstance(h, logging.FileHandler))
            today = datetime.now().strftime("%Y-%m-%d")
            assert today in fh.baseFilename
        finally:
            _close_handlers(logger)


def test_logger_appends_not_overwrites():
    with tempfile.TemporaryDirectory() as tmpdir:
        logger = _fresh_logger("test_append", tmpdir)
        try:
            fh = next(h for h in logger.handlers if isinstance(h, logging.FileHandler))
            assert fh.mode == "a"
        finally:
            _close_handlers(logger)


def test_logger_purges_old_log_files():
    with tempfile.TemporaryDirectory() as tmpdir:
        old = Path(tmpdir) / "dme-auto-2020-01-01.log"
        old.write_text("stale")
        old_mtime = time.time() - (31 * 86400)
        os.utime(old, (old_mtime, old_mtime))
        logger = _fresh_logger("test_purge", tmpdir)
        try:
            assert not old.exists()
        finally:
            _close_handlers(logger)


def test_logger_keeps_recent_log_files():
    with tempfile.TemporaryDirectory() as tmpdir:
        recent = Path(tmpdir) / "dme-auto-2099-12-31.log"
        recent.write_text("keep me")
        logger = _fresh_logger("test_keep", tmpdir)
        try:
            assert recent.exists()
        finally:
            _close_handlers(logger)
