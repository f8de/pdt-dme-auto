import ctypes
import ctypes.wintypes
import getpass
import os

import requests

_ENC_FILE = os.path.join(os.environ.get("APPDATA", ""), "pdt", "doppler.enc")


# ── DPAPI ──────────────────────────────────────────────────────────────────────

class _Blob(ctypes.Structure):
    _fields_ = [("cbData", ctypes.wintypes.DWORD),
                ("pbData", ctypes.POINTER(ctypes.c_char))]


def _dpapi_encrypt(data: bytes) -> bytes:
    buf = ctypes.create_string_buffer(data)
    inp = _Blob(len(data), buf)
    out = _Blob()
    if not ctypes.windll.crypt32.CryptProtectData(
        ctypes.byref(inp), None, None, None, None, 0, ctypes.byref(out)
    ):
        raise ctypes.WinError()
    result = ctypes.string_at(out.pbData, out.cbData)
    ctypes.windll.kernel32.LocalFree(out.pbData)
    return result


def _dpapi_decrypt(data: bytes) -> bytes:
    buf = ctypes.create_string_buffer(data)
    inp = _Blob(len(data), buf)
    out = _Blob()
    if not ctypes.windll.crypt32.CryptUnprotectData(
        ctypes.byref(inp), None, None, None, None, 0, ctypes.byref(out)
    ):
        raise ctypes.WinError()
    result = ctypes.string_at(out.pbData, out.cbData)
    ctypes.windll.kernel32.LocalFree(out.pbData)
    return result


# ── enc file ───────────────────────────────────────────────────────────────────

def _save_enc(token: str) -> None:
    encrypted = _dpapi_encrypt(token.encode("utf-16-le"))
    os.makedirs(os.path.dirname(_ENC_FILE), exist_ok=True)
    with open(_ENC_FILE, "w") as f:
        f.write(encrypted.hex())


def _load_enc() -> str:
    with open(_ENC_FILE) as f:
        ciphertext = bytes.fromhex(f.read().strip())
    return _dpapi_decrypt(ciphertext).decode("utf-16-le")


def _ensure_doppler_token() -> str:
    if not os.path.exists(_ENC_FILE):
        print()
        print("  First-time setup: Doppler service token not found.")
        print("  Doppler dashboard > dme-auto > dev > Access > Service Tokens > Generate")
        print()
        try:
            token = getpass.getpass("  Doppler service token: ").strip()
        except (EOFError, KeyboardInterrupt):
            raise RuntimeError("No token entered (no terminal). Aborting.")
        if not token:
            raise RuntimeError("No token entered. Aborting.")
        _save_enc(token)
        print("  Saved — DPAPI encrypted (this Windows user/machine only).")
        print()
    return _load_enc()


# ── public ─────────────────────────────────────────────────────────────────────

def get_notion_token() -> str:
    # Env var takes precedence (CI / dev override)
    token = os.environ.get("NOTION_TOKEN", "").strip()
    if token:
        return token

    # Doppler service token — from env or DPAPI-encrypted file (auto-setup if missing)
    doppler_token = os.environ.get("DOPPLER_TOKEN", "").strip() or _ensure_doppler_token()

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
