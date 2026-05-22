import sys
import pytest


@pytest.fixture(autouse=True)
def _clear_creds_cache():
    """Reload utils.creds between tests to prevent sys.modules patch interference."""
    for key in list(sys.modules.keys()):
        if "utils.creds" in key:
            del sys.modules[key]
    yield
    for key in list(sys.modules.keys()):
        if "utils.creds" in key:
            del sys.modules[key]
