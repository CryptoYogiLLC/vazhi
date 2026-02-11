#!/usr/bin/env python3
"""
Create Balanced SFT Dataset for VAZHI v3.1
==========================================

This script creates a rebalanced training dataset by:
1. Downsampling Thirukkural-heavy samples from existing data
2. Merging with the diverse QA pack
3. Creating final balanced dataset for upload to HuggingFace

Target distribution:
- Thirukkural/cultural: 30-40% (down from 71%)
- General knowledge: 20-25%
- Practical domain (govt/law/health): 30-40%
- Conversational: 10-15%
"""

import json
import random
import re
from pathlib import Path
from collections import defaultdict
from typing import List, Dict

# Paths
BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / "data" / "tamil_foundation" / "prepared_data"
DIVERSE_QA_DIR = BASE_DIR / "data" / "tamil_foundation" / "diverse_qa_pack"
OUTPUT_DIR = BASE_DIR / "data" / "tamil_foundation" / "balanced_sft"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Random seed
random.seed(42)

# Thirukkural patterns to identify
KURAL_PATTERNS = [
    r'குறள்\s*\d+',
    r'திருக்குறள்',
    r'அதிகாரம்',
    r'பொருள்:',
    r'அர்த்தம்',
    r'வள்ளுவர்',
]


def is_kural_sample(text: str) -> bool:
    """Check if sample is Thirukkural-related."""
    text_lower = text.lower()
    for pattern in KURAL_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            return True
    return False


def is_kural_interpretation(text: str) -> bool:
    """Check if sample is Thirukkural interpretation (not verbatim)."""
    # Interpretation samples typically ask about meaning
    interpretation_patterns = [
        r'என்ன\s+சொல்கிறது',
        r'கருத்து\s+என்ன',
        r'அர்த்தம்\s+என்ன',
        r'பொருள்\s+என்ன',
        r'விளக்கம்\s+தருக',
        r'என்ன\s+பொருள்',
        r'எப்படி\s+பொருந்தும்',
        r'வாழ்க்கையில்',
        r'decision\s+making',
        r'applicable',
    ]
    for pattern in interpretation_patterns:
        if re.search(pattern, text, re.IGNORECASE):
            return True
    return False


def load_existing_data() -> List[Dict]:
    """Load existing training data."""
    train_path = DATA_DIR / "train.jsonl"
    samples = []

    print(f"📚 Loading existing data from {train_path}")

    with open(train_path, 'r', encoding='utf-8') as f:
        for line in f:
            if line.strip():
                samples.append(json.loads(line))

    print(f"   Loaded {len(samples)} samples")
    return samples


def load_diverse_qa() -> List[Dict]:
    """Load diverse QA pack."""
    diverse_path = DIVERSE_QA_DIR / "diverse_qa_sft.jsonl"

    if not diverse_path.exists():
        print(f"   ⚠️ Diverse QA pack not found at {diverse_path}")
        print(f"   Run create_diverse_qa_pack.py first!")
        return []

    samples = []
    with open(diverse_path, 'r', encoding='utf-8') as f:
        for line in f:
            if line.strip():
                samples.append(json.loads(line))

    print(f"📚 Loaded {len(samples)} diverse QA samples")
    return samples


def categorize_samples(samples: List[Dict]) -> Dict[str, List[Dict]]:
    """Categorize samples by type."""
    categories = defaultdict(list)

    for s in samples:
        text = s.get('text', '')

        if is_kural_sample(text):
            if is_kural_interpretation(text):
                categories['kural_interpretation'].append(s)
            else:
                categories['kural_verbatim'].append(s)
        elif 'vazhi_' in s.get('source', '').lower() or 'pack' in s.get('source', '').lower():
            categories['domain'].append(s)
        elif any(dialect in text.lower() for dialect in ['டா', 'மா', 'டே', 'லே']):
            categories['conversational'].append(s)
        elif len(text) < 300:
            categories['short_response'].append(s)
        else:
            categories['general'].append(s)

    return dict(categories)


def downsample_kural(categories: Dict[str, List[Dict]],
                     target_kural_pct: float = 0.25) -> Dict[str, List[Dict]]:
    """Downsample Thirukkural samples to target percentage."""

    # Calculate current and target
    kural_verbatim = categories.get('kural_verbatim', [])
    kural_interp = categories.get('kural_interpretation', [])
    total_kural = len(kural_verbatim) + len(kural_interp)
    total_other = sum(len(v) for k, v in categories.items()
                      if k not in ['kural_verbatim', 'kural_interpretation'])

    print(f"\n📊 Before downsampling:")
    print(f"   Kural verbatim: {len(kural_verbatim)}")
    print(f"   Kural interpretation: {len(kural_interp)}")
    print(f"   Total kural: {total_kural}")
    print(f"   Other: {total_other}")
    print(f"   Kural %: {100*total_kural/(total_kural+total_other):.1f}%")

    # Calculate target kural count
    # If we want 25% kural: kural / (kural + other) = 0.25
    # kural = 0.25 * other / 0.75
    target_kural = int(target_kural_pct * total_other / (1 - target_kural_pct))

    print(f"\n🎯 Target kural count: {target_kural} ({100*target_kural_pct:.0f}% of total)")

    # Keep all interpretation samples (valuable)
    keep_interpretation = kural_interp

    # Downsample verbatim (less valuable since SQLite handles exact lookup)
    remaining_budget = max(0, target_kural - len(keep_interpretation))
    keep_verbatim = random.sample(kural_verbatim, min(remaining_budget, len(kural_verbatim)))

    # Update categories
    categories['kural_verbatim'] = keep_verbatim
    categories['kural_interpretation'] = keep_interpretation

    # Recalculate
    new_total_kural = len(keep_verbatim) + len(keep_interpretation)
    new_total = new_total_kural + total_other

    print(f"\n📊 After downsampling:")
    print(f"   Kural verbatim: {len(keep_verbatim)}")
    print(f"   Kural interpretation: {len(keep_interpretation)}")
    print(f"   Total kural: {new_total_kural}")
    print(f"   Kural %: {100*new_total_kural/new_total:.1f}%")

    return categories


def create_balanced_dataset():
    """Main function to create balanced dataset."""
    print("=" * 60)
    print("🚀 Creating Balanced SFT Dataset for VAZHI v3.1")
    print("=" * 60)

    # Load data
    existing_samples = load_existing_data()
    diverse_qa = load_diverse_qa()

    # Categorize existing samples
    categories = categorize_samples(existing_samples)

    print("\n📈 Category distribution (existing):")
    for cat, samples in sorted(categories.items(), key=lambda x: -len(x[1])):
        print(f"   {cat}: {len(samples)}")

    # Downsample Thirukkural
    categories = downsample_kural(categories, target_kural_pct=0.25)

    # Combine all categories
    all_samples = []
    for cat, samples in categories.items():
        for s in samples:
            s['category'] = cat
            all_samples.append(s)

    # Add diverse QA
    for s in diverse_qa:
        s['category'] = s.get('category', 'diverse_qa')
        all_samples.append(s)

    # Shuffle
    random.shuffle(all_samples)

    print(f"\n📊 Final dataset:")
    print(f"   Total samples: {len(all_samples)}")

    # Final distribution
    final_dist = defaultdict(int)
    for s in all_samples:
        final_dist[s.get('category', 'unknown')] += 1

    print("\n📈 Final category distribution:")
    for cat, count in sorted(final_dist.items(), key=lambda x: -x[1]):
        pct = 100 * count / len(all_samples)
        print(f"   {cat}: {count} ({pct:.1f}%)")

    # Split into train/val (95/5)
    split_idx = int(0.95 * len(all_samples))
    train_samples = all_samples[:split_idx]
    val_samples = all_samples[split_idx:]

    # Save train
    train_path = OUTPUT_DIR / "train.jsonl"
    with open(train_path, 'w', encoding='utf-8') as f:
        for s in train_samples:
            # Only keep 'text' field for training
            f.write(json.dumps({"text": s["text"]}, ensure_ascii=False) + '\n')
    print(f"\n💾 Saved {len(train_samples)} train samples to {train_path}")

    # Save val
    val_path = OUTPUT_DIR / "val.jsonl"
    with open(val_path, 'w', encoding='utf-8') as f:
        for s in val_samples:
            f.write(json.dumps({"text": s["text"]}, ensure_ascii=False) + '\n')
    print(f"💾 Saved {len(val_samples)} val samples to {val_path}")

    # Save metadata
    metadata = {
        "total_samples": len(all_samples),
        "train_samples": len(train_samples),
        "val_samples": len(val_samples),
        "category_distribution": dict(final_dist),
        "version": "v3.1",
        "changes": [
            "Downsampled Thirukkural verbatim from ~7000 to ~2500",
            "Added diverse QA pack (~1000 samples)",
            "Kept all Thirukkural interpretation samples",
            "Target: 25% kural, 30% domain, 30% general, 15% conversational"
        ]
    }

    with open(OUTPUT_DIR / "metadata.json", 'w', encoding='utf-8') as f:
        json.dump(metadata, f, ensure_ascii=False, indent=2)

    print("\n" + "=" * 60)
    print("✅ Balanced SFT dataset creation complete!")
    print(f"📁 Output directory: {OUTPUT_DIR}")
    print("=" * 60)

    return train_path, val_path


if __name__ == "__main__":
    create_balanced_dataset()
