#!/usr/bin/env python3
"""
Merge Culture v2 data into VAZHI training set for v0.2 training.

This script:
1. Loads all culture_v2 JSON files
2. Adds required fields (language, pack, category, id)
3. Merges with existing training data
4. Creates new train/val splits (90/10)
5. Outputs v0.2 training files
"""

import json
import random
from pathlib import Path
from datetime import datetime

# Paths
DATA_DIR = Path(__file__).parent.parent / "data"
CULTURE_V2_DIR = DATA_DIR / "culture_v2"
OUTPUT_DIR = DATA_DIR

# Category mapping based on filename
CATEGORY_MAP = {
    "thirukkural_pack_athikaram": "thirukkural",
    "thirukkural_pack_famous": "thirukkural",
    "thirukkural_pack_topic": "thirukkural",
    "siddhars_pack_18": "siddhars",
    "siddhars_pack_siddha": "siddha_medicine",
    "siddhars_pack_teachings": "siddhar_teachings",
    "temple_festival": "temples_festivals",
}

def get_category(filename: str) -> str:
    """Determine category from filename."""
    for key, category in CATEGORY_MAP.items():
        if key in filename:
            return category
    return "culture_general"

def load_culture_v2_data() -> list:
    """Load all culture v2 JSON files and add required fields."""
    all_pairs = []

    for json_file in sorted(CULTURE_V2_DIR.glob("*.json")):
        print(f"Loading {json_file.name}...")

        with open(json_file, "r", encoding="utf-8") as f:
            pairs = json.load(f)

        category = get_category(json_file.stem)

        for i, pair in enumerate(pairs):
            # Add required fields
            pair["language"] = "pure_tamil"  # Culture content is in Tamil
            pair["pack"] = "vazhi_panpaadu_v2"
            pair["category"] = category
            pair["id"] = f"CULT_V2_{json_file.stem[:10].upper()}_{i:03d}"

            all_pairs.append(pair)

    return all_pairs

def load_existing_training_data() -> tuple:
    """Load existing v0.1 training data."""
    train_file = OUTPUT_DIR / "vazhi_train.json"
    val_file = OUTPUT_DIR / "vazhi_val.json"

    with open(train_file, "r", encoding="utf-8") as f:
        train_data = json.load(f)

    with open(val_file, "r", encoding="utf-8") as f:
        val_data = json.load(f)

    return train_data, val_data

def remove_old_culture_data(data: list) -> list:
    """Remove old culture pack data to replace with v2."""
    # Filter out old culture pack entries
    filtered = [
        item for item in data
        if item.get("pack") not in ["vazhi_panpaadu", "vazhi_culture"]
    ]
    removed = len(data) - len(filtered)
    if removed > 0:
        print(f"Removed {removed} old culture entries")
    return filtered

def merge_and_split(existing_train: list, existing_val: list, new_culture: list) -> tuple:
    """Merge data and create new train/val splits."""
    # Combine existing train and val (we'll re-split)
    all_existing = existing_train + existing_val

    # Remove old culture data
    all_existing = remove_old_culture_data(all_existing)

    # Add new culture v2 data
    all_data = all_existing + new_culture

    # Shuffle
    random.seed(42)  # Reproducible splits
    random.shuffle(all_data)

    # 90/10 split
    split_idx = int(len(all_data) * 0.9)
    train_data = all_data[:split_idx]
    val_data = all_data[split_idx:]

    return train_data, val_data

def save_data(train_data: list, val_data: list):
    """Save merged training data."""
    timestamp = datetime.now().strftime("%Y%m%d")

    # Save v0.2 training files
    train_file = OUTPUT_DIR / "vazhi_train_v02.json"
    val_file = OUTPUT_DIR / "vazhi_val_v02.json"
    merged_file = OUTPUT_DIR / "vazhi_training_merged_v02.json"

    with open(train_file, "w", encoding="utf-8") as f:
        json.dump(train_data, f, ensure_ascii=False, indent=2)

    with open(val_file, "w", encoding="utf-8") as f:
        json.dump(val_data, f, ensure_ascii=False, indent=2)

    # Also save complete merged file
    with open(merged_file, "w", encoding="utf-8") as f:
        json.dump(train_data + val_data, f, ensure_ascii=False, indent=2)

    print(f"\nSaved:")
    print(f"  - {train_file} ({len(train_data)} samples)")
    print(f"  - {val_file} ({len(val_data)} samples)")
    print(f"  - {merged_file} ({len(train_data) + len(val_data)} total)")

def print_stats(train_data: list, val_data: list, culture_v2: list):
    """Print dataset statistics."""
    all_data = train_data + val_data

    # Count by pack
    pack_counts = {}
    for item in all_data:
        pack = item.get("pack", "unknown")
        pack_counts[pack] = pack_counts.get(pack, 0) + 1

    print("\n" + "="*50)
    print("VAZHI v0.2 Training Data Statistics")
    print("="*50)
    print(f"\nTotal samples: {len(all_data)}")
    print(f"  - Training: {len(train_data)}")
    print(f"  - Validation: {len(val_data)}")
    print(f"\nNew culture v2 data added: {len(culture_v2)}")
    print("\nSamples by pack:")
    for pack, count in sorted(pack_counts.items()):
        print(f"  - {pack}: {count}")

def main():
    print("VAZHI v0.2 Training Data Merge")
    print("-" * 40)

    # Load culture v2 data
    culture_v2 = load_culture_v2_data()
    print(f"\nLoaded {len(culture_v2)} culture v2 pairs")

    # Load existing data
    existing_train, existing_val = load_existing_training_data()
    print(f"Loaded existing data: {len(existing_train)} train, {len(existing_val)} val")

    # Merge and split
    train_data, val_data = merge_and_split(existing_train, existing_val, culture_v2)

    # Print statistics
    print_stats(train_data, val_data, culture_v2)

    # Save
    save_data(train_data, val_data)

    print("\nDone! Ready for v0.2 training.")

if __name__ == "__main__":
    main()
