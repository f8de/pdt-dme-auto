# Runtime hook — makes pywintypes3XX.dll / pythoncom3XX.dll findable after extraction.
import os
import sys

if getattr(sys, "frozen", False):
    # Single-file EXE: files land in sys._MEIPASS (temp extraction dir)
    meipass = getattr(sys, "_MEIPASS", os.path.dirname(sys.executable))
    exe_dir = os.path.dirname(sys.executable)
    for d in (meipass, exe_dir):
        os.environ["PATH"] = d + os.pathsep + os.environ.get("PATH", "")
        try:
            os.add_dll_directory(d)
        except (AttributeError, OSError):
            pass
