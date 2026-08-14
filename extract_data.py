#!/usr/bin/env python3

import pandas as pd

FILENAME = 'data/carmen_sightings_20220629061307.xlsx'
SHEETS = {
    "EUROPE": "raw_sightings_europe",
    "ASIA": "raw_sightings_asia",
    "AFRICA": "raw_sightings_africa",
    "AMERICA": "raw_sightings_america",
    "AUSTRALIA": "raw_sightings_australia",
    "ATLANTIC": "raw_sightings_atlantic",
    "INDIAN": "raw_sightings_indian",
    "PACIFIC": "raw_sightings_pacific",
}

if __name__ == "__main__":
    book = pd.ExcelFile(FILENAME)
    for sheet, sheet_id in SHEETS.items():
        frame = pd.read_excel(book, sheet_name=sheet, dtype=str, keep_default_na=False, na_values=[""])
        target = f"data/{sheet_id}.csv"
        frame.to_csv(target, index=False, encoding="utf-8")
