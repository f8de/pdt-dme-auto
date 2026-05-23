import os

import requests


def get_notion_token() -> str:
    # Direct env var takes precedence (CI / manual override)
    token = os.environ.get("NOTION_TOKEN", "").strip()
    if token:
        return token

    # Fetch from Doppler using service token (injected by run.ps1 via DPAPI decrypt)
    doppler_token = os.environ.get("DOPPLER_TOKEN", "").strip()
    if not doppler_token:
        raise RuntimeError(
            "Neither NOTION_TOKEN nor DOPPLER_TOKEN is set.\n"
            "Run via run.ps1, or run first-time setup:\n"
            "  .\\run.ps1 --setup"
        )

    try:
        resp = requests.get(
            "https://api.doppler.com/v3/configs/config/secrets/download",
            params={"format": "json", "include_dynamic_secrets": "false"},
            headers={"Authorization": f"Bearer {doppler_token}"},
            timeout=10,
        )
        resp.raise_for_status()
    except requests.RequestException as exc:
        raise RuntimeError(f"Doppler fetch failed: {exc}") from exc

    notion_token = resp.json().get("NOTION_TOKEN", "").strip()
    if not notion_token:
        raise RuntimeError("NOTION_TOKEN not found in Doppler config.")
    return notion_token
