import json
import keyring

_SERVICE       = "dmeworks-entry"
_NOTION_ACCT   = "notion-token"


def get_notion_token() -> str:
    token = keyring.get_password(_SERVICE, _NOTION_ACCT)
    if not token:
        raise RuntimeError(
            "Notion token not found. Run: dmeworks-entry.exe --setup"
        )
    return token


def set_notion_token(token: str) -> None:
    keyring.set_password(_SERVICE, _NOTION_ACCT, token)


def has_notion_token() -> bool:
    return keyring.get_password(_SERVICE, _NOTION_ACCT) is not None


def get_db_config(client_code: str) -> dict:
    raw = keyring.get_password(_SERVICE, f"db-{client_code}")
    if not raw:
        raise RuntimeError(
            f"DB config for '{client_code}' not found. "
            "Run: dmeworks-entry.exe --setup"
        )
    return json.loads(raw)


def set_db_config(client_code: str, config: dict) -> None:
    keyring.set_password(_SERVICE, f"db-{client_code}", json.dumps(config))


def has_db_config(client_code: str) -> bool:
    return keyring.get_password(_SERVICE, f"db-{client_code}") is not None
