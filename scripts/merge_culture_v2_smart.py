#!/usr/bin/env python3
"""
Smart merge of Culture v2 data - keeps good old data, replaces problematic parts.

Strategy:
- KEEP: arts_literature, saints_sages from old data
- REPLACE: thirukkural, siddhars with v2 (more accurate)
- MERGE: temples_heritage (keep old + add new)
"""

import json
import random
from pathlib import Path

# Paths
DATA_DIR = Path(__file__).parent.parent / "data"
CULTURE_V2_DIR = DATA_DIR / "culture_v2"

# Categories to KEEP from old data (not in v2 or old is good)
KEEP_CATEGORIES = {"arts_literature", "saints_sages"}

# Categories to REPLACE with v2 data (v2 is more accurate)
REPLACE_CATEGORIES = {"thirukkural", "siddhars", "siddhar_teachings", "siddha_medicine"}

# Categories to MERGE (keep old + add v2)
MERGE_CATEGORIES = {"temples_heritage", "temples_festivals"}

def load_culture_v2_data() -> list:
    """Load all culture v2 JSON files."""
    all_pairs = []

    category_map = {
        "thirukkural_pack": "thirukkural",
        "siddhars_pack_18": "siddhars",
        "siddhars_pack_siddha": "siddha_medicine",
        "siddhars_pack_teachings": "siddhar_teachings",
        "temple_festival": "temples_festivals",
    }

    for json_file in sorted(CULTURE_V2_DIR.glob("*.json")):
        print(f"Loading {json_file.name}...")

        with open(json_file, "r", encoding="utf-8") as f:
            pairs = json.load(f)

        # Determine category
        category = "culture_general"
        for key, cat in category_map.items():
            if key in json_file.stem:
                category = cat
                break

        for i, pair in enumerate(pairs):
            pair["language"] = "pure_tamil"
            pair["pack"] = "vazhi_panpaadu"  # Keep same pack name
            pair["category"] = category
            pair["id"] = f"CULT_V2_{json_file.stem[:8].upper()}_{i:03d}"
            all_pairs.append(pair)

    return all_pairs

def smart_merge():
    """Perform smart merge keeping good old data."""

    # Load existing training data
    with open(DATA_DIR / "vazhi_train.json", "r", encoding="utf-8") as f:
        train_data = json.load(f)
    with open(DATA_DIR / "vazhi_val.json", "r", encoding="utf-8") as f:
        val_data = json.load(f)

    all_existing = train_data + val_data
    print(f"Loaded {len(all_existing)} existing samples")

    # Load v2 culture data
    v2_data = load_culture_v2_data()
    print(f"Loaded {len(v2_data)} culture v2 samples")

    # Separate old culture data by category
    old_culture_keep = []
    old_culture_replace = []
    old_culture_merge = []
    non_culture = []

    for item in all_existing:
        pack = item.get("pack", "")
        category = item.get("category", "")

        if pack not in ["vazhi_panpaadu", "vazhi_culture"]:
            non_culture.append(item)
        elif category in KEEP_CATEGORIES:
            old_culture_keep.append(item)
        elif category in REPLACE_CATEGORIES or "thirukkural" in category.lower():
            old_culture_replace.append(item)
        elif category in MERGE_CATEGORIES or "temple" in category.lower():
            old_culture_merge.append(item)
        else:
            # Default: keep unknown categories
            old_culture_keep.append(item)

    print(f"\nOld culture data breakdown:")
    print(f"  - KEEP (arts, saints): {len(old_culture_keep)}")
    print(f"  - REPLACE (thirukkural, siddhars): {len(old_culture_replace)}")
    print(f"  - MERGE (temples): {len(old_culture_merge)}")
    print(f"  - Non-culture: {len(non_culture)}")

    # Build final dataset
    final_data = []

    # 1. Add all non-culture data
    final_data.extend(non_culture)

    # 2. Add KEEP categories from old data
    final_data.extend(old_culture_keep)

    # 3. Add MERGE categories (old + v2)
    final_data.extend(old_culture_merge)

    # 4. Add v2 data (replaces old thirukkural/siddhars)
    final_data.extend(v2_data)

    print(f"\nFinal dataset: {len(final_data)} samples")

    # Count by pack
    pack_counts = {}
    for item in final_data:
        pack = item.get("pack", "unknown")
        pack_counts[pack] = pack_counts.get(pack, 0) + 1

    print("\nSamples by pack:")
    for pack, count in sorted(pack_counts.items()):
        print(f"  - {pack}: {count}")

    # Count culture categories
    culture_cats = {}
    for item in final_data:
        if item.get("pack") == "vazhi_panpaadu":
            cat = item.get("category", "unknown")
            culture_cats[cat] = culture_cats.get(cat, 0) + 1

    print("\nCulture categories:")
    for cat, count in sorted(culture_cats.items()):
        print(f"  - {cat}: {count}")

    # Shuffle and split
    random.seed(42)
    random.shuffle(final_data)

    split_idx = int(len(final_data) * 0.9)
    train_data = final_data[:split_idx]
    val_data = final_data[split_idx:]

    # Save
    with open(DATA_DIR / "vazhi_train_v02.json", "w", encoding="utf-8") as f:
        json.dump(train_data, f, ensure_ascii=False, indent=2)

    with open(DATA_DIR / "vazhi_val_v02.json", "w", encoding="utf-8") as f:
        json.dump(val_data, f, ensure_ascii=False, indent=2)

    with open(DATA_DIR / "vazhi_training_merged_v02.json", "w", encoding="utf-8") as f:
        json.dump(final_data, f, ensure_ascii=False, indent=2)

    print(f"\nSaved:")
    print(f"  - vazhi_train_v02.json ({len(train_data)} samples)")
    print(f"  - vazhi_val_v02.json ({len(val_data)} samples)")
    print(f"  - Total: {len(final_data)} samples")

    return final_data

if __name__ == "__main__":
    print("VAZHI v0.2 Smart Merge")
    print("=" * 50)
    smart_merge()
