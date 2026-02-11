#!/usr/bin/env python3
"""
Complete merge of Culture v2 data - keeps ALL old data and ADDS v2 data.

The old Thirukkural data has thematic/practical queries.
The v2 data has foundational/sequential kurals (athikarams 1-10).
Together they provide comprehensive coverage.

Strategy: KEEP ALL old data + ADD ALL v2 data
"""

import json
import random
from pathlib import Path

DATA_DIR = Path(__file__).parent.parent / "data"
CULTURE_V2_DIR = DATA_DIR / "culture_v2"

def load_culture_v2_data() -> list:
    """Load all culture v2 JSON files."""
    all_pairs = []

    category_map = {
        "thirukkural_pack_athikaram": "thirukkural_foundational",
        "thirukkural_pack_famous": "thirukkural_famous",
        "thirukkural_pack_topic": "thirukkural_topics",
        "siddhars_pack_18": "siddhars_detailed",
        "siddhars_pack_siddha": "siddha_medicine",
        "siddhars_pack_teachings": "siddhar_teachings",
        "temple_festival": "temples_festivals",
    }

    for json_file in sorted(CULTURE_V2_DIR.glob("*.json")):
        print(f"Loading {json_file.name}...")

        with open(json_file, "r", encoding="utf-8") as f:
            pairs = json.load(f)

        # Determine category
        category = "culture_v2_general"
        for key, cat in category_map.items():
            if key in json_file.stem:
                category = cat
                break

        for i, pair in enumerate(pairs):
            pair["language"] = "pure_tamil"
            pair["pack"] = "vazhi_panpaadu"
            pair["category"] = category
            pair["id"] = f"CULT_V2_{json_file.stem[:8].upper()}_{i:03d}"
            all_pairs.append(pair)

    return all_pairs

def complete_merge():
    """Merge by keeping ALL old data and adding ALL v2 data."""

    # Load existing training data
    with open(DATA_DIR / "vazhi_train.json", "r", encoding="utf-8") as f:
        train_data = json.load(f)
    with open(DATA_DIR / "vazhi_val.json", "r", encoding="utf-8") as f:
        val_data = json.load(f)

    all_existing = train_data + val_data
    print(f"Loaded {len(all_existing)} existing samples")

    # Count old culture data
    old_culture = [x for x in all_existing if x.get("pack") in ["vazhi_panpaadu", "vazhi_culture"]]
    old_thirukkural = [x for x in old_culture if x.get("category") == "thirukkural"]
    print(f"Old culture data: {len(old_culture)} (including {len(old_thirukkural)} thirukkural)")

    # Load v2 culture data
    v2_data = load_culture_v2_data()
    print(f"Loaded {len(v2_data)} culture v2 samples")

    # Complete merge: ALL existing + ALL v2
    final_data = all_existing + v2_data

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

    print("\nCulture categories (old + v2):")
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

    print(f"\n{'='*50}")
    print(f"COMPLETE MERGE SUMMARY")
    print(f"{'='*50}")
    print(f"Old data kept:        {len(all_existing)}")
    print(f"V2 data added:        {len(v2_data)}")
    print(f"Total:                {len(final_data)}")
    print(f"  - Training:         {len(train_data)}")
    print(f"  - Validation:       {len(val_data)}")
    print(f"\nThirukkural coverage:")
    print(f"  - Old (thematic):   {len(old_thirukkural)}")
    v2_thirukkural = [x for x in v2_data if "thirukkural" in x.get("category", "")]
    print(f"  - V2 (foundational):{len(v2_thirukkural)}")
    print(f"  - Combined:         {len(old_thirukkural) + len(v2_thirukkural)}")

if __name__ == "__main__":
    print("VAZHI v0.2 Complete Merge (Keep All + Add V2)")
    print("=" * 50)
    complete_merge()
