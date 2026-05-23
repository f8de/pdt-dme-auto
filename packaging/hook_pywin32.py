# Runtime hook — adds the EXE directory to PATH so pywintypes3XX.dll is found.
import os
import sys

if getattr(sys, "frozen", False):
    exe_dir = os.path.dirname(sys.executable)
    # Add to both PATH and DLL search path so win32api can load pywintypes.
    os.environ["PATH"] = exe_dir + os.pathsep + os.environ.get("PATH", "")
    try:
        os.add_dll_directory(exe_dir)
    except (AttributeError, OSError):
        pass
