import ctypes
import ctypes.wintypes
import getpass
import os

import requests

_ENC_FILE = os.path.join(os.environ.get("APPDATA", ""), "pdt", "doppler.enc")
_secrets_cache: dict | None = None


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
    with open(_ENC_FILE, "wb") as f:
        f.write(encrypted)


def _load_enc() -> str:
    with open(_ENC_FILE, "rb") as f:
        raw = f.read()
    # Try raw bytes first (new format); fall back to hex string (old format)
    try:
        return _dpapi_decrypt(raw).decode("utf-16-le")
    except OSError:
        return _dpapi_decrypt(bytes.fromhex(raw.decode().strip())).decode("utf-16-le")


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


# ── Doppler fetch ──────────────────────────────────────────────────────────────

def _get_secrets() -> dict:
    """Fetch all Doppler secrets once per session, cached in memory."""
    global _secrets_cache
    if _secrets_cache is not None:
        return _secrets_cache

    # Dev/CI override: NOTION_TOKEN set directly in environment
    if os.environ.get("NOTION_TOKEN"):
        _secrets_cache = dict(os.environ)
        return _secrets_cache

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
    _secrets_cache = resp.json()
    return _secrets_cache


# ── public ─────────────────────────────────────────────────────────────────────

def get_notion_token() -> str:
    token = _get_secrets().get("NOTION_TOKEN", "").strip()
    if not token:
        raise RuntimeError("NOTION_TOKEN not found in Doppler config.")
    return token


MYSQL_HOST = "localhost"
MYSQL_PORT = 3306


def get_mysql_creds() -> tuple[str, str]:
    """Return (user, password) from Doppler keys DMEWORKS_MYSQL_USER / _PASSWORD."""
    s = _get_secrets()
    user     = s.get("DMEWORKS_MYSQL_USER", "").strip()
    password = s.get("DMEWORKS_MYSQL_PASSWORD", "").strip()
    if not user:
        raise RuntimeError("DMEWORKS_MYSQL_USER not found in Doppler config.")
    return user, password


DMEWORKS_EXE = r"C:\Program Files (x86)\DMEWorks\DMEWorks.exe"


def get_dmeworks_creds() -> tuple[str, str]:
    """Return (username, password) from Doppler.

    Doppler keys: DMEWORKS_USERNAME, DMEWORKS_PASSWORD
    """
    s = _get_secrets()
    return (
        s.get("DMEWORKS_USERNAME", "").strip(),
        s.get("DMEWORKS_PASSWORD", "").strip(),
    )
