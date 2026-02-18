#!/usr/bin/env python3
"""
Assemble Dataset v5.2 — Conversational fundamentals + safety-rebalanced SFT dataset.

v5.2 changes from v5.1:
- NEW: Conversational fundamentals pack (200 items) — greetings, identity,
  chitchat, wellbeing, farewells, meta-conversation, emotional support,
  capabilities, language preferences, colloquial TN Tamil
- v5.1 had only 5 conversational items out of 4,321 samples — a 0.6B model
  can't infer conversational behavior from a system prompt alone
- All other sources unchanged from v5.1
"""

import json
import hashlib
import random
import re
from pathlib import Path
from collections import Counter


BASE = Path("/Users/chocka/CursorProjects/vazhi")
SFT_DIR = BASE / "data/sources/sft"
OUTPUT_DIR = BASE / "data/curated"

SYSTEM_PROMPT = (
    "நீங்கள் வழி (VAZHI), தமிழ்நாட்டு மக்களுக்கான AI உதவியாளர். நீங்கள் தமிழில் பதிலளிப்பீர்கள்."
)

# Safety budget — v5.2: cut from 200 to ~45 (1% of dataset)
# v5.0 had 1,800 (30.6%) → mode collapse. v5.1 had 200 (4.6%) → still too heavy.
# A 0.6B model learns refusal from very few examples. More safety = less Tamil knowledge.
TOXIC_MATRIX_BUDGET = 15
HHRLHF_T_BUDGET = 30
SAFETY_BUDGET = TOXIC_MATRIX_BUDGET + HHRLHF_T_BUDGET


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


def select_diverse_safety(safety_items: list) -> list:
    """
    Intelligently downsample safety data to ~200 items.

    Toxic_Matrix (867 items): All have near-identical responses. Select 50 with
    the most diverse QUESTIONS (maximize topic coverage).

    HHRLHF_T (933 items): More diverse responses. Deduplicate by response
    similarity (first 80 chars), then select 150 covering diverse topics.
    """
    toxic = [d for d in safety_items if d.get("category") == "Toxic_Matrix"]
    hhrlhf = [d for d in safety_items if d.get("category") == "HHRLHF_T"]

    print(f"  Raw Toxic_Matrix: {len(toxic)}")
    print(f"  Raw HHRLHF_T: {len(hhrlhf)}")

    # --- Toxic_Matrix: pick 50 with diverse questions ---
    random.seed(42)
    random.shuffle(toxic)
    seen_q = set()
    toxic_unique = []
    for item in toxic:
        q_hash = hashlib.md5(
            item["instruction"].encode("utf-8"), usedforsecurity=False
        ).hexdigest()
        if q_hash not in seen_q:
            seen_q.add(q_hash)
            toxic_unique.append(item)

    step = max(1, len(toxic_unique) // TOXIC_MATRIX_BUDGET)
    toxic_selected = toxic_unique[::step][:TOXIC_MATRIX_BUDGET]
    print(
        f"  Toxic_Matrix selected: {len(toxic_selected)} (from {len(toxic_unique)} unique questions)"
    )

    # --- HHRLHF_T: deduplicate responses, pick 150 diverse ---
    response_groups = {}
    for item in hhrlhf:
        key = item["output"][:80]
        if key not in response_groups:
            response_groups[key] = []
        response_groups[key].append(item)

    hhrlhf_deduped = [group[0] for group in response_groups.values()]
    random.seed(43)
    random.shuffle(hhrlhf_deduped)

    hhrlhf_selected = hhrlhf_deduped[:HHRLHF_T_BUDGET]
    print(
        f"  HHRLHF_T selected: {len(hhrlhf_selected)} (from {len(hhrlhf_deduped)} unique responses)"
    )

    selected = toxic_selected + hhrlhf_selected
    print(f"  Total safety selected: {len(selected)} (budget: {SAFETY_BUDGET})")
    return selected


def main():
    all_items = []

    # 1. Vazhi-packs v5 (unchanged)
    print("Loading vazhi-packs v5...")
    packs_dir = SFT_DIR / "vazhi-packs-v5"
    for pack in ["culture", "healthcare", "security", "legal", "education", "govt"]:
        path = packs_dir / f"{pack}.json"
        items = load_json(str(path))
        filtered = [i for i in items if tamil_pct(i["output"]) >= 30]
        for item in filtered:
            item["bucket"] = "vazhi_packs"
        all_items.extend(filtered)
        print(f"  {pack}: {len(items)} → {len(filtered)} (filtered)")

    # 2. Sadhguru Q&A — DROPPED in v5.2
    # Audit found critical quality issues: 35% duplicate answers (4 blocks of 50x
    # identical generic text), 41% question-answer echo (agent copy-pasted article
    # opening as both Q and A), 7% generic motivational clichés not from Sadhguru.
    # Entire bucket is poisoning training. Better to have a smaller clean dataset.
    print("\nSadhguru Q&A: DROPPED (quality audit failed — see comments)")

    # 3. IndicAlign safety — REBALANCED (from v5.1)
    print("\nLoading IndicAlign safety (v5.1 rebalanced)...")
    safety_raw = load_json(str(SFT_DIR / "indicaign_safety.json"))
    safety_selected = select_diverse_safety(safety_raw)
    for item in safety_selected:
        item["bucket"] = "safety"
    all_items.extend(safety_selected)

    # 4. Thirukkural Q&A (unchanged)
    print("\nLoading Thirukkural Q&A...")
    thirukkural = load_json(str(SFT_DIR / "thirukkural_qa.json"))
    for item in thirukkural:
        item["bucket"] = "thirukkural"
    all_items.extend(thirukkural)
    print(f"  Thirukkural Q&A: {len(thirukkural)}")

    # 5. Handcrafted (unchanged)
    print("\nLoading handcrafted...")
    handcrafted = load_json(str(SFT_DIR / "handcrafted_extracted.json"))
    for item in handcrafted:
        item["bucket"] = "handcrafted"
    all_items.extend(handcrafted)
    print(f"  Handcrafted: {len(handcrafted)}")

    # 6. General (unchanged)
    print("\nLoading general...")
    general = load_json(str(SFT_DIR / "general_extracted.json"))
    for item in general:
        item["bucket"] = "general"
    all_items.extend(general)
    print(f"  General: {len(general)}")

    # 7. Conversational Fundamentals — NEW in v5.2
    print("\nLoading conversational fundamentals (NEW in v5.2)...")
    conv_fund = load_json(str(SFT_DIR / "conversational_fundamentals.json"))
    for item in conv_fund:
        item["bucket"] = "conversational"
    all_items.extend(conv_fund)
    print(f"  Conversational fundamentals: {len(conv_fund)}")
    # Category breakdown
    cats = Counter(item["category"] for item in conv_fund)
    for cat, count in sorted(cats.items(), key=lambda x: -x[1]):
        print(f"    {cat}: {count}")

    # 8. VAZHI Behavior Pack — NEW in v5.2
    print("\nLoading VAZHI behavior pack (NEW in v5.2)...")
    behavior = load_json(str(SFT_DIR / "vazhi_behavior_pack.json"))
    for item in behavior:
        item["bucket"] = "behavior"
    all_items.extend(behavior)
    print(f"  VAZHI behavior pack: {len(behavior)}")
    cats = Counter(item["category"] for item in behavior)
    for cat, count in sorted(cats.items(), key=lambda x: -x[1]):
        print(f"    {cat}: {count}")

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

    # v5.1 → v5.2 comparison
    print("\n" + "=" * 60)
    print("v5.1 → v5.2 COMPARISON")
    print("=" * 60)
    v51 = {
        "vazhi_packs": 2958,
        "sadhguru_qa": 847,
        "safety": 200,
        "thirukkural": 169,
        "handcrafted": 120,
        "general": 27,
        "conversational": 0,
    }
    v51_total = sum(v51.values())
    for b, c in sorted(buckets.items(), key=lambda x: -x[1]):
        old = v51.get(b, 0)
        old_pct = old / v51_total * 100 if v51_total else 0
        new_pct = c / len(dataset) * 100
        delta = c - old
        print(
            f"  {b:20s}: {old:5d} ({old_pct:5.1f}%) → {c:5d} ({new_pct:5.1f}%)  [{delta:+d}]"
        )

    # Save
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    train_path = OUTPUT_DIR / "vazhi-tamil-sft-v5_2-train.json"
    eval_path = OUTPUT_DIR / "vazhi-tamil-sft-v5_2-eval.json"
    full_path = OUTPUT_DIR / "vazhi-tamil-sft-v5_2-full.json"

    with open(str(train_path), "w", encoding="utf-8") as fp:
        json.dump(train, fp, ensure_ascii=False, indent=2)
    with open(str(eval_path), "w", encoding="utf-8") as fp:
        json.dump(eval_set, fp, ensure_ascii=False, indent=2)
    with open(str(full_path), "w", encoding="utf-8") as fp:
        json.dump(dataset, fp, ensure_ascii=False, indent=2)

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

    # Safety vocabulary check
    print("\n" + "=" * 60)
    print("SAFETY VOCABULARY CHECK")
    print("=" * 60)
    all_text = " ".join(item["text"] for item in dataset)
    for word, label in [
        ("தீங்கு", "harm"),
        ("நச்சு", "toxic"),
        ("ஊக்குவி", "encourage"),
        ("வன்முறை", "violence"),
        ("தூண்டுதல்", "provocation"),
    ]:
        count = all_text.count(word)
        per_sample = count / len(dataset)
        print(f'  "{word}" ({label}): {count} total ({per_sample:.2f}/sample)')

    # Conversational coverage check (the whole point of v5.2)
    print("\n" + "=" * 60)
    print("CONVERSATIONAL COVERAGE CHECK")
    print("=" * 60)
    conv_items = [d for d in dataset if d["bucket"] == "conversational"]
    conv_cats = Counter(d["category"] for d in conv_items)
    for cat, count in sorted(conv_cats.items(), key=lambda x: -x[1]):
        print(f"  {cat:20s}: {count}")
    conv_pct = len(conv_items) / len(dataset) * 100
    print(f"  Total conversational: {len(conv_items)} ({conv_pct:.1f}% of dataset)")

    print("\n✅ Dataset v5.2 ready for upload to HuggingFace")
    print(
        f"   Total: {len(dataset)} samples ({len(train)} train + {len(eval_set)} eval)"
    )
    print(
        f"   NEW: {len(conv_items)} conversational fundamentals (greetings, identity, colloquial TN Tamil)"
    )


if __name__ == "__main__":
    main()
