#!/usr/bin/env python3
"""
High-Tamil Translation Script for VAZHI Education Pack
Target: >70% Tamil characters
"""

import json
import os
import re

def calculate_tamil_percentage(text):
    """Calculate percentage of Tamil characters in text."""
    tamil_chars = len(re.findall(r'[\u0B80-\u0BFF]', text))
    total_chars = len(re.findall(r'[a-zA-Z\u0B80-\u0BFF]', text))
    if total_chars == 0:
        return 0
    return (tamil_chars / total_chars) * 100

def analyze_batch(batch_num):
    """Analyze Tamil percentage in a batch file."""
    path = f"/Users/chocka/CursorProjects/vazhi/data/v04/regenerated/translated/vazhi_kalvi/batch_{batch_num:02d}_tamil.json"

    if not os.path.exists(path):
        return None

    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    if isinstance(data, list):
        samples = data
    else:
        samples = data.get("samples", [])

    total_tamil = 0
    for sample in samples:
        output = sample.get("output", "")
        tamil_pct = calculate_tamil_percentage(output)
        total_tamil += tamil_pct

    avg_tamil = total_tamil / len(samples) if samples else 0
    return {
        "batch": batch_num,
        "samples": len(samples),
        "avg_tamil_pct": round(avg_tamil, 1)
    }

def main():
    print("VAZHI Education Pack - Tamil Percentage Analysis")
    print("=" * 50)

    total_samples = 0
    total_tamil_pct = 0
    processed = 0

    for batch_num in range(1, 24):
        result = analyze_batch(batch_num)
        if result:
            print(f"Batch {batch_num:02d}: {result['samples']} samples, {result['avg_tamil_pct']}% Tamil")
            total_samples += result['samples']
            total_tamil_pct += result['avg_tamil_pct'] * result['samples']
            processed += 1
        else:
            print(f"Batch {batch_num:02d}: Not found")

    if total_samples > 0:
        overall_avg = total_tamil_pct / total_samples
        print(f"\n{'=' * 50}")
        print(f"Overall: {total_samples} samples, {round(overall_avg, 1)}% Tamil average")
        print(f"Target: >70% Tamil")
        if overall_avg >= 70:
            print("Status: TARGET MET!")
        else:
            print(f"Status: Need {70 - overall_avg:.1f}% more Tamil")

if __name__ == "__main__":
    main()
