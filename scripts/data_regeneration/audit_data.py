#!/usr/bin/env python3
"""
VAZHI v0.4 - Data Audit Script

Categorizes existing training data by actual Tamil content percentage.
Outputs:
- keep_samples.json: >70% Tamil, good quality
- review_samples.json: 30-70% Tamil, needs review
- regenerate_samples.json: <30% Tamil, needs regeneration
"""

import json
import re
from pathlib import Path
from collections import Counter

DATA_DIR = Path(__file__).parent.parent.parent / "data"
OUTPUT_DIR = DATA_DIR / "v04" / "audit"


def calculate_tamil_percentage(text: str) -> float:
    """Calculate percentage of Tamil characters vs English."""
    tamil_chars = len(re.findall(r"[\u0B80-\u0BFF]", text))
    english_chars = len(re.findall(r"[a-zA-Z]", text))
    total = tamil_chars + english_chars
    if total == 0:
        return 0.0
    return (tamil_chars / total) * 100


def categorize_sample(sample: dict) -> str:
    """Categorize sample based on actual Tamil content."""
    output = sample.get("output", "")
    tamil_pct = calculate_tamil_percentage(output)

    if tamil_pct >= 70:
        return "keep"
    elif tamil_pct >= 30:
        return "review"
    else:
        return "regenerate"


def audit_training_data():
    """Audit all training data and categorize."""

    # Load training data
    train_file = DATA_DIR / "vazhi_train_v02.json"
    val_file = DATA_DIR / "vazhi_val_v02.json"

    with open(train_file, "r", encoding="utf-8") as f:
        train_data = json.load(f)
    with open(val_file, "r", encoding="utf-8") as f:
        val_data = json.load(f)

    all_data = train_data + val_data
    print(f"Total samples to audit: {len(all_data)}")

    # Categorize
    categories = {"keep": [], "review": [], "regenerate": []}

    for sample in all_data:
        category = categorize_sample(sample)
        tamil_pct = calculate_tamil_percentage(sample.get("output", ""))
        sample["_tamil_percentage"] = round(tamil_pct, 1)
        sample["_category"] = category
        categories[category].append(sample)

    # Print summary
    print("\n" + "=" * 60)
    print("AUDIT SUMMARY")
    print("=" * 60)

    for cat, samples in categories.items():
        print(
            f"\n{cat.upper()}: {len(samples)} samples ({len(samples)/len(all_data)*100:.1f}%)"
        )

        # Breakdown by pack
        pack_counts = Counter(s.get("pack", "unknown") for s in samples)
        for pack, count in pack_counts.most_common():
            print(f"  - {pack}: {count}")

    # Save categorized data
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for cat, samples in categories.items():
        output_file = OUTPUT_DIR / f"{cat}_samples.json"
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(samples, f, ensure_ascii=False, indent=2)
        print(f"\nSaved: {output_file}")

    # Generate detailed report
    report = {
        "total_samples": len(all_data),
        "keep": {
            "count": len(categories["keep"]),
            "percentage": round(len(categories["keep"]) / len(all_data) * 100, 1),
            "by_pack": dict(
                Counter(s.get("pack", "unknown") for s in categories["keep"])
            ),
        },
        "review": {
            "count": len(categories["review"]),
            "percentage": round(len(categories["review"]) / len(all_data) * 100, 1),
            "by_pack": dict(
                Counter(s.get("pack", "unknown") for s in categories["review"])
            ),
        },
        "regenerate": {
            "count": len(categories["regenerate"]),
            "percentage": round(len(categories["regenerate"]) / len(all_data) * 100, 1),
            "by_pack": dict(
                Counter(s.get("pack", "unknown") for s in categories["regenerate"])
            ),
        },
    }

    report_file = OUTPUT_DIR / "audit_report.json"
    with open(report_file, "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    print(f"\nSaved report: {report_file}")

    return categories


def print_examples():
    """Print example samples from each category."""

    for cat in ["keep", "review", "regenerate"]:
        file_path = OUTPUT_DIR / f"{cat}_samples.json"
        if not file_path.exists():
            continue

        with open(file_path, "r", encoding="utf-8") as f:
            samples = json.load(f)

        print(f"\n{'='*60}")
        print(f"EXAMPLES: {cat.upper()}")
        print("=" * 60)

        for sample in samples[:2]:
            print(f"\nPack: {sample.get('pack')}")
            print(f"Tamil %: {sample.get('_tamil_percentage')}%")
            print(f"Q: {sample['instruction'][:60]}...")
            print(f"A: {sample['output'][:150]}...")


if __name__ == "__main__":
    print("VAZHI v0.4 - Training Data Audit")
    print("=" * 60)

    categories = audit_training_data()
    print_examples()
