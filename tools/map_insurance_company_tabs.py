"""
Maps all controls in the Insurance Company edit form (Billing, EDI, 837 tabs).
Open DMEworks, go to Maintain -> Insurance Company, load the Aetna record,
then run this script.
"""
from pywinauto import Application


def main() -> None:
    a        = Application(backend="uia").connect(title="DMEWorks")
    main_win = a.window(title="DMEWorks", auto_id="FormMain")

    ins_win = None
    for child in main_win.descendants(control_type="Window"):
        try:
            t = child.window_text()
            if "Insurance Company" in t:
                ins_win = child
                break
        except Exception:
            pass

    if not ins_win:
        print("Insurance Company window not found. Open it first.")
        return

    print("Insurance Company form controls:\n")
    for ctrl in ins_win.descendants():
        try:
            ct    = ctrl.element_info.control_type
            title = ctrl.window_text()
            aid   = ctrl.element_info.automation_id
            if ct in ("Edit", "CheckBox", "ComboBox", "Button", "Tab", "TabItem", "Pane"):
                print(f"  [{ct}] title='{title}' auto_id='{aid}'")
        except Exception:
            pass


if __name__ == "__main__":
    main()
