"""
Maps all controls in the Policy Information dialog.
Open DMEworks, go to Maintain -> Customer, open any customer,
click Insurance tab, click Add to open the Policy Information dialog,
then run this script.

Save to: C:\ProgramData\CybrEdge\Scripts\map_policy_dialog.py
"""
from pywinauto import Application

a = Application(backend="uia").connect(title="DMEWorks")
main = a.window(title="DMEWorks", auto_id="FormMain")

for child in main.descendants(control_type="Window"):
    try:
        t = child.window_text()
        if "Policy" in t:
            print(f"\nFound window: '{t}'")
            print("=" * 60)
            child.print_control_identifiers()
    except Exception:
        pass
