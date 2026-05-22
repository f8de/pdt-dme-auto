import sys
import pytest


@pytest.fixture(autouse=True)
def _clear_module_cache():
    """Clear utils module cache between tests to prevent sys.modules patch interference."""
    for key in list(sys.modules.keys()):
        if key.startswith("utils."):
            del sys.modules[key]
    yield
    for key in list(sys.modules.keys()):
        if key.startswith("utils."):
            del sys.modules[key]
