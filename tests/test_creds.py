import pytest


def test_get_notion_token_returns_env_value(monkeypatch):
    monkeypatch.setenv("NOTION_TOKEN", "ntn_abc123")
    from utils.creds import get_notion_token
    assert get_notion_token() == "ntn_abc123"


def test_get_notion_token_strips_whitespace(monkeypatch):
    monkeypatch.setenv("NOTION_TOKEN", "  ntn_abc123  ")
    from utils.creds import get_notion_token
    assert get_notion_token() == "ntn_abc123"


def test_get_notion_token_raises_when_missing(monkeypatch):
    monkeypatch.delenv("NOTION_TOKEN", raising=False)
    from utils.creds import get_notion_token
    with pytest.raises(RuntimeError, match="NOTION_TOKEN environment variable not set"):
        get_notion_token()


def test_get_notion_token_raises_when_empty(monkeypatch):
    monkeypatch.setenv("NOTION_TOKEN", "   ")
    from utils.creds import get_notion_token
    with pytest.raises(RuntimeError, match="NOTION_TOKEN environment variable not set"):
        get_notion_token()
