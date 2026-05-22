import os


def get_notion_token() -> str:
    token = os.environ.get("NOTION_TOKEN", "").strip()
    if not token:
        raise RuntimeError(
            "NOTION_TOKEN environment variable not set.\n"
            "Run via run.ps1, or set manually:\n"
            "  $env:NOTION_TOKEN = Get-Secret -Vault local -Name notion-token -AsPlainText"
        )
    return token
