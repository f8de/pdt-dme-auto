"""
Maps all controls in the Policy Information dialog.
Open DMEworks, go to Maintain -> Customer, open any customer,
click Insurance tab, click Add to open the Policy Information dialog,
then run this script.
"""
from pywinauto import Application


def main() -> None:
    a        = Application(backend="uia").connect(title="DMEWorks")
    main_win = a.window(title="DMEWorks", auto_id="FormMain")

    for child in main_win.descendants(control_type="Window"):
        try:
            t = child.window_text()
            if "Policy" in t:
                print(f"\nFound window: '{t}'")
                print("=" * 60)
                child.print_control_identifiers()
        except Exception:
            pass


if __name__ == "__main__":
    main()
