import importlib

import pytest
import requests
import requests_mock as req_mock


def _reload():
    import utils.creds
    importlib.reload(utils.creds)
    from utils.creds import get_notion_token
    return get_notion_token


def test_returns_notion_token_env(monkeypatch):
    monkeypatch.setenv("NOTION_TOKEN", "ntn_abc123")
    monkeypatch.delenv("DOPPLER_TOKEN", raising=False)
    fn = _reload()
    assert fn() == "ntn_abc123"


def test_strips_whitespace(monkeypatch):
    monkeypatch.setenv("NOTION_TOKEN", "  ntn_abc123  ")
    fn = _reload()
    assert fn() == "ntn_abc123"


def test_raises_when_neither_set(monkeypatch):
    monkeypatch.delenv("NOTION_TOKEN", raising=False)
    monkeypatch.delenv("DOPPLER_TOKEN", raising=False)
    fn = _reload()
    with pytest.raises(RuntimeError, match="DOPPLER_TOKEN"):
        fn()


def test_fetches_from_doppler(monkeypatch):
    monkeypatch.delenv("NOTION_TOKEN", raising=False)
    monkeypatch.setenv("DOPPLER_TOKEN", "dp.st.dev.abc")
    fn = _reload()
    with req_mock.Mocker() as m:
        m.get(
            "https://api.doppler.com/v3/configs/config/secrets/download",
            json={"NOTION_TOKEN": "ntn_from_doppler"},
        )
        assert fn() == "ntn_from_doppler"


def test_doppler_api_error_raises(monkeypatch):
    monkeypatch.delenv("NOTION_TOKEN", raising=False)
    monkeypatch.setenv("DOPPLER_TOKEN", "dp.st.dev.abc")
    fn = _reload()
    with req_mock.Mocker() as m:
        m.get(
            "https://api.doppler.com/v3/configs/config/secrets/download",
            status_code=401,
        )
        with pytest.raises(RuntimeError, match="Doppler fetch failed"):
            fn()


def test_doppler_missing_key_raises(monkeypatch):
    monkeypatch.delenv("NOTION_TOKEN", raising=False)
    monkeypatch.setenv("DOPPLER_TOKEN", "dp.st.dev.abc")
    fn = _reload()
    with req_mock.Mocker() as m:
        m.get(
            "https://api.doppler.com/v3/configs/config/secrets/download",
            json={"OTHER_SECRET": "something"},
        )
        with pytest.raises(RuntimeError, match="NOTION_TOKEN not found in Doppler"):
            fn()
