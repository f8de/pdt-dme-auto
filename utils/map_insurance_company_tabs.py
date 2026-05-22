"""
Maps all controls in the Insurance Company edit form (Billing, EDI, 837 tabs).
Open DMEworks, go to Maintain -> Insurance Company, load the Aetna record,
then run this script.

Save to: C:\ProgramData\CybrEdge\Scripts\map_insurance_company_tabs.py
"""
from pywinauto import Application

a = Application(backend="uia").connect(title="DMEWorks")
main = a.window(title="DMEWorks", auto_id="FormMain")

ins_win = None
for child in main.descendants(control_type="Window"):
    try:
        t = child.window_text()
        if "Insurance Company" in t:
            ins_win = child
            break
    except Exception:
        pass

if not ins_win:
    print("Insurance Company window not found. Open it first.")
    exit()

print("Insurance Company form controls:\n")
for ctrl in ins_win.descendants():
    try:
        ct   = ctrl.element_info.control_type
        title = ctrl.window_text()
        aid  = ctrl.element_info.automation_id
        if ct in ("Edit", "CheckBox", "ComboBox", "Button", "Tab", "TabItem", "Pane"):
            print(f"  [{ct}] title='{title}' auto_id='{aid}'")
    except Exception:
        pass
