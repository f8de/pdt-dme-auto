from datetime import datetime, timezone
from unittest.mock import patch, MagicMock
import io, zipfile
import pytest

import fee_schedule as fs


class TestCurrentQuarter:
    def test_q1_january(self):
        now = datetime(2026, 1, 15, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26a"

    def test_q1_march(self):
        now = datetime(2026, 3, 31, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26a"

    def test_q2_april(self):
        now = datetime(2026, 4, 1, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26b"

    def test_q2_june(self):
        now = datetime(2026, 6, 15, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26b"

    def test_q3_july(self):
        now = datetime(2026, 7, 1, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26c"

    def test_q4_december(self):
        now = datetime(2026, 12, 31, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "26d"

    def test_year_boundary_2027(self):
        now = datetime(2027, 1, 1, tzinfo=timezone.utc)
        assert fs._current_quarter(now) == "27a"

    def test_no_arg_returns_string(self):
        result = fs._current_quarter()
        assert len(result) == 3
        assert result[2] in ("a", "b", "c", "d")
