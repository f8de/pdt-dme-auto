"""
Loads doctors and patients from CSV files in the data/ directory.
"""

import csv
import os

_DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data")


def load_doctors(filename: str = "doctors.csv") -> list[dict]:
    path = os.path.join(_DATA_DIR, filename)
    if not os.path.exists(path):
        raise FileNotFoundError(f"Doctors file not found: {path}")
    doctors = []
    with open(path, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            doctors.append({
                "last":     row["last"].strip(),
                "first":    row["first"].strip(),
                "mi":       row.get("mi", "").strip(),
                "suffix":   row.get("suffix", "").strip(),
                "address1": row["address1"].strip(),
                "city":     row["city"].strip(),
                "state":    row["state"].strip(),
                "zip":      row["zip"].strip(),
                "phone":    row["phone"].strip(),
                "npi":      row["npi"].strip(),
            })
    return doctors


def load_patients(filename: str = "patients.csv") -> list[dict]:
    path = os.path.join(_DATA_DIR, filename)
    if not os.path.exists(path):
        raise FileNotFoundError(f"Patients file not found: {path}")
    patients = []
    with open(path, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            icd10 = [
                row[f"icd10_{i}"].strip()
                for i in range(1, 9)
                if row.get(f"icd10_{i}", "").strip()
            ]
            sec_company = row.get("sec_company", "").strip()
            secondary = None
            if sec_company:
                secondary = {
                    "ins_company": sec_company,
                    "ins_type":    row.get("sec_type", "").strip(),
                    "policy":      row.get("sec_policy", "").strip(),
                    "group":       row.get("sec_group", "").strip(),
                }
            notes = row.get("notes", "").strip()
            patients.append({
                "last":      row["last"].strip(),
                "first":     row["first"].strip(),
                "mi":        row.get("mi", "").strip(),
                "suffix":    row.get("suffix", "").strip(),
                "dob":       row["dob"].strip(),
                "mbi":       row["mbi"].strip(),
                "address1":  row["address1"].strip(),
                "city":      row["city"].strip(),
                "state":     row["state"].strip(),
                "zip":       row["zip"].strip(),
                "phone":     row["phone"].strip(),
                "icd10":     icd10,
                "doctor":    row["doctor"].strip(),
                "secondary": secondary,
                "notes":     notes,
            })
    return patients


def load_insurance_companies(filename: str = "insurance_companies.csv") -> list[dict]:
    path = os.path.join(_DATA_DIR, filename)
    if not os.path.exists(path):
        raise FileNotFoundError(f"Insurance companies file not found: {path}")
    companies = []
    with open(path, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            companies.append({
                "name": row["name"].strip(),
                "type": row["type"].strip().upper(),
            })
    return companies


def load_medicare_map(filename: str = "medicare_jurisdictions.csv") -> dict[str, str]:
    path = os.path.join(_DATA_DIR, filename)
    if not os.path.exists(path):
        raise FileNotFoundError(f"Medicare jurisdictions file not found: {path}")
    result = {}
    with open(path, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            result[row["state"].strip()] = row["dmerc_name"].strip()
    return result
