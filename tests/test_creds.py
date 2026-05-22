from unittest.mock import patch, call
import json
import pytest


def test_get_notion_token_returns_stored_value():
    with patch("keyring.get_password", return_value="ntn_abc123") as mock_get:
        from utils.creds import get_notion_token
        assert get_notion_token() == "ntn_abc123"
        mock_get.assert_called_once_with("dmeworks-entry", "notion-token")


def test_get_notion_token_raises_when_missing():
    with patch("keyring.get_password", return_value=None):
        from utils.creds import get_notion_token
        with pytest.raises(RuntimeError, match="Notion token not found"):
            get_notion_token()


def test_set_notion_token_calls_keyring():
    with patch("keyring.set_password") as mock_set:
        from utils.creds import set_notion_token
        set_notion_token("ntn_secret")
        mock_set.assert_called_once_with("dmeworks-entry", "notion-token", "ntn_secret")


def test_has_notion_token_true():
    with patch("keyring.get_password", return_value="ntn_abc"):
        from utils.creds import has_notion_token
        assert has_notion_token() is True


def test_has_notion_token_false():
    with patch("keyring.get_password", return_value=None):
        from utils.creds import has_notion_token
        assert has_notion_token() is False


def test_get_db_config_returns_parsed_json():
    cfg = {"host": "192.168.1.10", "port": 3306, "user": "dme", "password": "s3cr3t", "database": "dmeworks"}
    with patch("keyring.get_password", return_value=json.dumps(cfg)):
        from utils.creds import get_db_config
        result = get_db_config("ALLIED")
        assert result == cfg


def test_get_db_config_raises_when_missing():
    with patch("keyring.get_password", return_value=None):
        from utils.creds import get_db_config
        with pytest.raises(RuntimeError, match="DB config for 'ALLIED' not found"):
            get_db_config("ALLIED")


def test_set_db_config_stores_json():
    cfg = {"host": "localhost", "port": 3306, "user": "u", "password": "p", "database": "d"}
    with patch("keyring.set_password") as mock_set:
        from utils.creds import set_db_config
        set_db_config("ALLIED", cfg)
        mock_set.assert_called_once_with("dmeworks-entry", "db-ALLIED", json.dumps(cfg))
