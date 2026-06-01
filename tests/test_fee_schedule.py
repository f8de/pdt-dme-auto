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


# ── helpers ───────────────────────────────────────────────────────────────────

def _make_zip(rows: list[str], filename: str = "DMEPOS26_JAN.TXT") -> bytes:
    """Build an in-memory ZIP with a tilde-delimited .TXT file."""
    content = "\n".join(rows).encode("latin-1")
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        zf.writestr(filename, content)
    return buf.getvalue()


def _mock_response(zip_bytes: bytes) -> MagicMock:
    resp = MagicMock()
    resp.content = zip_bytes
    resp.raise_for_status = MagicMock()
    return resp


# ── load_fee_schedule tests ───────────────────────────────────────────────────

class TestLoadFeeSchedule:
    def _rows(self):
        # Format matches DMEPOS26_JAN.txt: tilde-delimited, col1=HCPCS, col8=state(padded), col9=fee
        return [
            "2026~L0457~  ~  ~J~OS~A~00~NJ     ~000412.50~000500.00~000350.00~000412.50~0~1~ ~Lumbar orthosis",
            "2026~L0457~  ~  ~J~OS~A~00~NY     ~000412.50~000500.00~000350.00~000412.50~0~1~ ~Lumbar orthosis",
            "2026~L1833~  ~  ~J~OS~A~00~OH     ~000550.00~000600.00~000480.00~000550.00~0~1~ ~Knee orthosis",
            "2026~L1833~  ~  ~J~OS~A~00~SC     ~000480.00~000530.00~000430.00~000480.00~0~1~ ~Knee orthosis",
            "invalid_row",
            "2026~TOOSHORT",
        ]

    def test_returns_dict_on_success(self):
        mock_resp = _mock_response(_make_zip(self._rows()))
        with patch("fee_schedule.requests.get", return_value=mock_resp):
            schedule = fs.load_fee_schedule()
        assert isinstance(schedule, dict)
        assert ("L0457", "NJ") in schedule
        assert schedule[("L0457", "NJ")] == 412.50

    def test_multiple_states_for_same_hcpcs(self):
        mock_resp = _mock_response(_make_zip(self._rows()))
        with patch("fee_schedule.requests.get", return_value=mock_resp):
            schedule = fs.load_fee_schedule()
        assert schedule[("L0457", "NY")] == 412.50
        assert schedule[("L1833", "OH")] == 550.00
        assert schedule[("L1833", "SC")] == 480.00

    def test_skips_malformed_rows(self):
        mock_resp = _mock_response(_make_zip(self._rows()))
        with patch("fee_schedule.requests.get", return_value=mock_resp):
            schedule = fs.load_fee_schedule()
        assert len(schedule) == 4

    def test_returns_empty_on_http_error(self, capsys):
        with patch("fee_schedule.requests.get", side_effect=Exception("connection timeout")):
            schedule = fs.load_fee_schedule()
        assert schedule == {}
        captured = capsys.readouterr()
        assert "[fee_schedule] WARNING" in captured.out

    def test_returns_empty_on_bad_zip(self, capsys):
        resp = MagicMock()
        resp.content = b"not a zip file"
        resp.raise_for_status = MagicMock()
        with patch("fee_schedule.requests.get", return_value=resp):
            schedule = fs.load_fee_schedule()
        assert schedule == {}

    def test_keys_are_uppercase(self):
        rows = ["2026~l0457~  ~  ~J~OS~A~00~nj     ~000412.50~000500.00~000350.00~000412.50~0~1~ ~desc"]
        mock_resp = _mock_response(_make_zip(rows))
        with patch("fee_schedule.requests.get", return_value=mock_resp):
            schedule = fs.load_fee_schedule()
        assert ("L0457", "NJ") in schedule

    def test_skips_dmepen_file(self):
        """DMEPEN file has different structure — should be ignored."""
        pen_rows = ["2026~B4034~A~1~OH     ~000010.00~000015.00~000008.00"]
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, "w") as zf:
            zf.writestr("DMEPOS26_JAN.TXT", "\n".join(self._rows()[:4]).encode("latin-1"))
            zf.writestr("DMEPEN26_JAN.TXT", "\n".join(pen_rows).encode("latin-1"))
        zip_bytes = buf.getvalue()
        mock_resp = _mock_response(zip_bytes)
        with patch("fee_schedule.requests.get", return_value=mock_resp):
            schedule = fs.load_fee_schedule()
        assert ("B4034", "OH") not in schedule
        assert ("L0457", "NJ") in schedule
