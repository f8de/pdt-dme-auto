"""
Single encryption mechanism for all sensitive data.
Master key stored in Windows Credential Manager (DPAPI-backed, never on disk).
All sensitive files encrypted with Fernet (AES-128-CBC + HMAC-SHA256).
"""
import os
import tempfile
from pathlib import Path

import keyring
from cryptography.fernet import Fernet, InvalidToken

_SERVICE  = "dmeworks-entry"
_KEY_ACCT = "master-key"


def _master_key() -> bytes:
    key = keyring.get_password(_SERVICE, _KEY_ACCT)
    if key is None:
        key = Fernet.generate_key().decode()
        keyring.set_password(_SERVICE, _KEY_ACCT, key)
    return key.encode()


def has_master_key() -> bool:
    return keyring.get_password(_SERVICE, _KEY_ACCT) is not None


def encrypt_bytes(data: bytes) -> bytes:
    return Fernet(_master_key()).encrypt(data)


def decrypt_bytes(data: bytes) -> bytes:
    try:
        return Fernet(_master_key()).decrypt(data)
    except InvalidToken:
        raise ValueError(
            "Decryption failed — wrong key or corrupted file. "
            "Verify the master key in Windows Credential Manager "
            f"(service={_SERVICE!r}, account={_KEY_ACCT!r})."
        )


def encrypt_file(src: "str | Path", dst: "str | Path") -> None:
    Path(dst).write_bytes(encrypt_bytes(Path(src).read_bytes()))


def decrypt_to_bytes(enc_path: "str | Path") -> bytes:
    return decrypt_bytes(Path(enc_path).read_bytes())
