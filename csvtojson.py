#!/usr/bin/env python3

import csv
import json
import sys
import os

# Check if an argument was provided
if len(sys.argv) < 2:
    print("Usage: python csv_to_json.py <input.csv> [output.json]")
    sys.exit(1)

input_file = sys.argv[1]
output_file = (
    sys.argv[2] if len(sys.argv) > 2 else os.path.splitext(input_file)[0] + ".json"
)

# Convert CSV → JSON
with open(input_file, newline="", encoding="utf-8") as csvfile:
    reader = csv.DictReader(csvfile)
    data = list(reader)

with open(output_file, "w", encoding="utf-8") as jsonfile:
    json.dump(data, jsonfile, indent=2)

print(f"✅ Converted {input_file} → {output_file}")
