#!/usr/bin/env python3
"""
Assemble Dataset v5.0 from all sources.
Combines vazhi-packs v5, Sadhguru Q&A, IndicAlign safety, Thirukkural Q&A,
handcrafted, and general into a single dataset with ChatML formatting.
"""

import json
import hashlib
import random
import glob
from pathlib import Path


BASE = Path("/Users/chocka/CursorProjects/vazhi")
SFT_DIR = BASE / "data/sources/sft"
OUTPUT_DIR = BASE / "data/curated"

SYSTEM_PROMPT = (
    "நீங்கள் வழி (VAZHI), தமிழ்நாட்டு மக்களுக்கான AI உதவியாளர். நீங்கள் தமிழில் பதிலளிப்பீர்கள்."
)


def tamil_pct(text: str) -> float:
    if not text:
        return 0.0
    non_space = [c for c in text if not c.isspace()]
    if not non_space:
        return 0.0
    tamil = sum(1 for c in non_space if "\u0B80" <= c <= "\u0BFF")
    return (tamil / len(non_space)) * 100


def format_chatml(instruction: str, output: str) -> str:
    return (
        f"<|im_start|>system\n{SYSTEM_PROMPT}<|im_end|>\n"
        f"<|im_start|>user\n{instruction}<|im_end|>\n"
        f"<|im_start|>assistant\n{output}<|im_end|>"
    )


def load_json(path: str) -> list:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def dedup_items(items: list) -> list:
    """Remove exact duplicate instruction+output pairs."""
    seen = set()
    unique = []
    for item in items:
        key = hashlib.md5(
            (item["instruction"] + item["output"]).encode("utf-8"),
            usedforsecurity=False,
        ).hexdigest()
        if key not in seen:
            seen.add(key)
            unique.append(item)
    return unique


def main():
    all_items = []

    # 1. Vazhi-packs v5
    print("Loading vazhi-packs v5...")
    packs_dir = SFT_DIR / "vazhi-packs-v5"
    for pack in ["culture", "healthcare", "security", "legal", "education", "govt"]:
        path = packs_dir / f"{pack}.json"
        items = load_json(str(path))
        # Filter: minimum 30% Tamil (relaxed for domain packs with English terms)
        filtered = [i for i in items if tamil_pct(i["output"]) >= 30]
        for item in filtered:
            item["bucket"] = "vazhi_packs"
        all_items.extend(filtered)
        print(f"  {pack}: {len(items)} → {len(filtered)} (filtered)")

    # 2. Sadhguru Q&A
    print("\nLoading Sadhguru Q&A...")
    qa_total = 0
    for f in sorted(glob.glob(str(SFT_DIR / "sadhguru-v5/batch_*.json"))):
        items = load_json(f)
        # Filter: minimum 50% Tamil for Q&A
        filtered = [i for i in items if tamil_pct(i["output"]) >= 50]
        for item in filtered:
            item["bucket"] = "sadhguru_qa"
        all_items.extend(filtered)
        qa_total += len(filtered)
        print(f"  {Path(f).name}: {len(items)} → {len(filtered)}")
    print(f"  Total Q&A: {qa_total}")

    # 3. IndicAlign safety
    print("\nLoading IndicAlign safety...")
    safety = load_json(str(SFT_DIR / "indicaign_safety.json"))
    for item in safety:
        item["bucket"] = "safety"
    all_items.extend(safety)
    print(f"  Safety: {len(safety)}")

    # 4. Thirukkural Q&A (filtered - no verbatim)
    print("\nLoading Thirukkural Q&A...")
    thirukkural = load_json(str(SFT_DIR / "thirukkural_qa.json"))
    for item in thirukkural:
        item["bucket"] = "thirukkural"
    all_items.extend(thirukkural)
    print(f"  Thirukkural Q&A: {len(thirukkural)}")

    # 5. Handcrafted
    print("\nLoading handcrafted...")
    handcrafted = load_json(str(SFT_DIR / "handcrafted_extracted.json"))
    for item in handcrafted:
        item["bucket"] = "handcrafted"
    all_items.extend(handcrafted)
    print(f"  Handcrafted: {len(handcrafted)}")

    # 6. General
    print("\nLoading general...")
    general = load_json(str(SFT_DIR / "general_extracted.json"))
    for item in general:
        item["bucket"] = "general"
    all_items.extend(general)
    print(f"  General: {len(general)}")

    # Dedup
    print(f"\nBefore dedup: {len(all_items)}")
    all_items = dedup_items(all_items)
    print(f"After dedup: {len(all_items)}")

    # Format to ChatML
    print("\nFormatting to ChatML...")
    dataset = []
    for item in all_items:
        chatml = format_chatml(item["instruction"], item["output"])
        dataset.append(
            {
                "text": chatml,
                "bucket": item.get("bucket", "unknown"),
                "source": item.get("source", "unknown"),
                "category": item.get("category", "unknown"),
            }
        )

    # Shuffle
    random.seed(42)
    random.shuffle(dataset)

    # Split 90/10 train/eval
    split_idx = int(len(dataset) * 0.9)
    train = dataset[:split_idx]
    eval_set = dataset[split_idx:]

    print("\nDataset split:")
    print(f"  Train: {len(train)}")
    print(f"  Eval: {len(eval_set)}")

    # Bucket distribution
    print("\nBucket distribution (full dataset):")
    buckets = {}
    for item in dataset:
        b = item["bucket"]
        buckets[b] = buckets.get(b, 0) + 1
    for b, c in sorted(buckets.items(), key=lambda x: -x[1]):
        pct = c / len(dataset) * 100
        print(f"  {b:20s}: {c:5d} ({pct:.1f}%)")

    # Save
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    train_path = OUTPUT_DIR / "vazhi-tamil-sft-v5_0-train.json"
    eval_path = OUTPUT_DIR / "vazhi-tamil-sft-v5_0-eval.json"
    full_path = OUTPUT_DIR / "vazhi-tamil-sft-v5_0-full.json"

    json.dump(train, open(str(train_path), "w"), ensure_ascii=False, indent=2)
    json.dump(eval_set, open(str(eval_path), "w"), ensure_ascii=False, indent=2)
    json.dump(dataset, open(str(full_path), "w"), ensure_ascii=False, indent=2)

    print("\nSaved:")
    print(f"  {train_path} ({len(train)} samples)")
    print(f"  {eval_path} ({len(eval_set)} samples)")
    print(f"  {full_path} ({len(dataset)} samples)")

    # Final validation
    print("\n" + "=" * 60)
    print("FINAL VALIDATION")
    print("=" * 60)
    tamil_pcts = []
    word_counts = []
    for item in dataset:
        # Extract assistant output from ChatML
        import re

        m = re.search(
            r"<\|im_start\|>assistant\n(.*?)<\|im_end\|>", item["text"], re.DOTALL
        )
        if m:
            output = m.group(1)
            tamil_pcts.append(tamil_pct(output))
            word_counts.append(len(output.split()))

    print(f"Tamil % avg: {sum(tamil_pcts)/len(tamil_pcts):.1f}")
    print(f"Tamil % min: {min(tamil_pcts):.1f}")
    print(f"Items <30% Tamil: {sum(1 for p in tamil_pcts if p < 30)}")
    print(f"Items <50% Tamil: {sum(1 for p in tamil_pcts if p < 50)}")
    print(f"Word count avg: {sum(word_counts)/len(word_counts):.0f}")
    print(f"Word count range: {min(word_counts)}-{max(word_counts)}")


if __name__ == "__main__":
    main()
