#!/usr/bin/env python3
"""
Assemble Dataset v7.0 — Optimized for Gemma 3 1B-it.

v7.0 is a redesign from v5.3 for Gemma 3 1B-it. Gemma 3 already speaks Tamil,
so the dataset teaches VAZHI's identity, which is rooted in Tamil spiritual culture.

VAZHI is NOT a generic info chatbot. It is grounded in Tamil spiritual tradition —
Thirukkural, Aathichudi, Siddhars, Sadhguru wisdom. The spiritual content IS the
model's identity. Domain knowledge (govt schemes, health, security) complements
this cultural foundation.

Key changes from v5.3:
- Sadhguru: 562 full articles → 400 selected, truncated to ~200 words
  (v5.3: 78.3% of tokens at 735 words/answer → v7.0: ~40% at 200 words)
  Still the largest single source — spiritual wisdom IS VAZHI's identity.
  Truncation is for mobile UX, not to reduce importance.
- Factual corrections: NEW — 29 examples fixing Gemma 3's known errors
- Safety: 45 → 60 (1B model has more capacity than 0.6B)
- Output format: Raw instruction/output JSON (not ChatML-wrapped)
  The training notebook applies the Gemma 3 chat template at training time.
"""

import json
import hashlib
import random
from pathlib import Path


BASE = Path("/Users/chocka/CursorProjects/vazhi")
SFT_DIR = BASE / "data/sources/sft"
OUTPUT_DIR = BASE / "data/curated"

# --- Budget controls ---
# Sadhguru: keep 400 diverse articles (was 562), truncated to MAX_SADHGURU_WORDS
# Spiritual wisdom IS VAZHI's identity — this is the largest source intentionally.
# Truncation is for mobile UX (200 words fits well on phone), not to reduce importance.
SADHGURU_BUDGET = 400
MAX_SADHGURU_WORDS = 200  # Truncate answers to ~200 words (was avg 735)

# Safety: 25 total (Gemma 3 has built-in safety from 2T pretraining)
# Just enough to teach Tamil-language refusal patterns, not more.
TOXIC_MATRIX_BUDGET = 10
HHRLHF_T_BUDGET = 15
SAFETY_BUDGET = TOXIC_MATRIX_BUDGET + HHRLHF_T_BUDGET


def tamil_pct(text: str) -> float:
    if not text:
        return 0.0
    non_space = [c for c in text if not c.isspace()]
    if not non_space:
        return 0.0
    tamil = sum(1 for c in non_space if "\u0B80" <= c <= "\u0BFF")
    return (tamil / len(non_space)) * 100


def truncate_to_words(text: str, max_words: int) -> str:
    """Truncate text to max_words, ending at a sentence boundary if possible."""
    words = text.split()
    if len(words) <= max_words:
        return text

    truncated = " ".join(words[:max_words])

    # Try to end at a sentence boundary (Tamil sentence enders: ., !, ?, ।)
    last_period = max(
        truncated.rfind("."),
        truncated.rfind("!"),
        truncated.rfind("?"),
        truncated.rfind("।"),
    )

    # Only use sentence boundary if it's in the last 40% of the truncated text
    if last_period > len(truncated) * 0.6:
        return truncated[: last_period + 1]

    return truncated


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


def select_diverse_sadhguru(items: list, budget: int, max_words: int) -> list:
    """
    Select diverse Sadhguru articles and truncate to max_words.

    Strategy: ensure category diversity, then pick by answer length diversity.
    Truncate answers to ~150 words — enough for a meaningful teaching example
    without training the model to produce 500+ word responses.
    """
    # Group by category
    by_category = {}
    for item in items:
        cat = item.get("category", "general")
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append(item)

    print(f"  Sadhguru categories: {list(by_category.keys())}")
    print(
        f"  Category counts: {', '.join(f'{k}={len(v)}' for k, v in sorted(by_category.items(), key=lambda x: -len(x[1])))}"
    )

    # Distribute budget across categories proportionally
    selected = []
    total = sum(len(v) for v in by_category.values())
    for cat, cat_items in sorted(by_category.items(), key=lambda x: -len(x[1])):
        cat_budget = max(1, round(budget * len(cat_items) / total))

        # Sort by answer length (prefer medium-length articles — not too short, not too long)
        cat_items_sorted = sorted(
            cat_items, key=lambda x: abs(len(x["output"].split()) - 400)
        )

        # Take evenly spaced samples for diversity
        step = max(1, len(cat_items_sorted) // cat_budget)
        picks = cat_items_sorted[::step][:cat_budget]
        selected.extend(picks)

    # Trim to exact budget
    random.seed(42)
    random.shuffle(selected)
    selected = selected[:budget]

    # Truncate all answers
    for item in selected:
        original_words = len(item["output"].split())
        item["output"] = truncate_to_words(item["output"], max_words)
        item["_original_words"] = original_words

    return selected


def select_diverse_safety(safety_items: list) -> list:
    """
    Intelligently downsample safety data to SAFETY_BUDGET items.
    """
    toxic = [d for d in safety_items if d.get("category") == "Toxic_Matrix"]
    hhrlhf = [d for d in safety_items if d.get("category") == "HHRLHF_T"]

    print(f"  Raw Toxic_Matrix: {len(toxic)}")
    print(f"  Raw HHRLHF_T: {len(hhrlhf)}")

    # Toxic_Matrix: pick TOXIC_MATRIX_BUDGET with diverse questions
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
        f"  Toxic_Matrix selected: {len(toxic_selected)} (from {len(toxic_unique)} unique)"
    )

    # HHRLHF_T: deduplicate responses, pick diverse
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
        f"  HHRLHF_T selected: {len(hhrlhf_selected)} (from {len(hhrlhf_deduped)} unique)"
    )

    selected = toxic_selected + hhrlhf_selected
    print(f"  Total safety selected: {len(selected)} (budget: {SAFETY_BUDGET})")
    return selected


def main():
    all_items = []

    # 1. Vazhi-packs v5 — core domain knowledge (should be ~45-50% of tokens)
    print("Loading vazhi-packs v5...")
    packs_dir = SFT_DIR / "vazhi-packs-v5"
    total_packs = 0
    for pack in ["culture", "healthcare", "security", "legal", "education", "govt"]:
        path = packs_dir / f"{pack}.json"
        items = load_json(str(path))
        filtered = [i for i in items if tamil_pct(i["output"]) >= 30]
        for item in filtered:
            item["bucket"] = "vazhi_packs"
        all_items.extend(filtered)
        total_packs += len(filtered)
        print(f"  {pack}: {len(items)} → {len(filtered)} (filtered)")
    print(f"  Total vazhi_packs: {total_packs}")

    # 2. Sadhguru Q&A v2 — TRUNCATED & DOWNSAMPLED for Gemma 3
    # Gemma 3 already speaks Tamil — these teach spiritual wisdom domain,
    # NOT Tamil language. Truncated to mobile-appropriate length.
    print(
        f"\nLoading Sadhguru Q&A v2 (budget={SADHGURU_BUDGET}, max_words={MAX_SADHGURU_WORDS})..."
    )
    sadhguru = load_json(str(SFT_DIR / "sadhguru_qa_v2.json"))
    filtered_sadhguru = [i for i in sadhguru if tamil_pct(i["output"]) >= 50]
    print(f"  Total available: {len(filtered_sadhguru)} (from {len(sadhguru)})")

    selected_sadhguru = select_diverse_sadhguru(
        filtered_sadhguru, SADHGURU_BUDGET, MAX_SADHGURU_WORDS
    )
    for item in selected_sadhguru:
        item["bucket"] = "sadhguru_qa"
    all_items.extend(selected_sadhguru)

    # Print truncation stats
    orig_words = [i["_original_words"] for i in selected_sadhguru]
    new_words = [len(i["output"].split()) for i in selected_sadhguru]
    print(f"  Selected: {len(selected_sadhguru)}")
    print(f"  Original avg words: {sum(orig_words)/len(orig_words):.0f}")
    print(f"  Truncated avg words: {sum(new_words)/len(new_words):.0f}")
    print(f"  Token savings: {sum(orig_words) - sum(new_words):,} words removed")

    # 3. IndicAlign safety — slightly larger budget for 1B model
    print(f"\nLoading IndicAlign safety (budget={SAFETY_BUDGET})...")
    safety_raw = load_json(str(SFT_DIR / "indicaign_safety.json"))
    safety_selected = select_diverse_safety(safety_raw)
    for item in safety_selected:
        item["bucket"] = "safety"
    all_items.extend(safety_selected)

    # 4. Thirukkural Q&A
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

    # 7. Conversational Fundamentals
    print("\nLoading conversational fundamentals...")
    conv_fund = load_json(str(SFT_DIR / "conversational_fundamentals.json"))
    for item in conv_fund:
        item["bucket"] = "conversational"
    all_items.extend(conv_fund)
    print(f"  Conversational fundamentals: {len(conv_fund)}")

    # 8. VAZHI Behavior Pack
    print("\nLoading VAZHI behavior pack...")
    behavior = load_json(str(SFT_DIR / "vazhi_behavior_pack.json"))
    for item in behavior:
        item["bucket"] = "behavior"
    all_items.extend(behavior)
    print(f"  VAZHI behavior pack: {len(behavior)}")

    # 9. Gemma 3 Factual Corrections — NEW in v7.0
    print("\nLoading Gemma 3 factual corrections...")
    corrections = load_json(str(SFT_DIR / "gemma3_corrections.json"))
    for item in corrections:
        item["bucket"] = "corrections"
    all_items.extend(corrections)
    print(f"  Factual corrections: {len(corrections)}")

    # 10. VAZHI Mission & Philosophy — NEW in v7.0
    # Covers: acronym meaning, open source philosophy, offline advantages,
    # user feedback/corrections, knowledge packs, sponsorship/scholarship model,
    # community contribution, identity, privacy
    print("\nLoading VAZHI mission & philosophy...")
    mission = load_json(str(SFT_DIR / "vazhi_mission.json"))
    for item in mission:
        item["bucket"] = "mission"
    all_items.extend(mission)
    print(f"  VAZHI mission: {len(mission)}")

    # Dedup
    print(f"\nBefore dedup: {len(all_items)}")
    all_items = dedup_items(all_items)
    print(f"After dedup: {len(all_items)}")

    # Output as raw instruction/output (NOT ChatML-wrapped)
    # The training notebook applies the Gemma 3 chat template at training time
    print("\nFormatting dataset (raw instruction/output)...")
    dataset = []
    for item in all_items:
        dataset.append(
            {
                "instruction": item["instruction"],
                "output": item["output"],
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

    # === TOKEN DISTRIBUTION ANALYSIS ===
    print("\n" + "=" * 70)
    print("TOKEN DISTRIBUTION ANALYSIS (v7.0 for Gemma 3)")
    print("=" * 70)

    bucket_stats = {}
    for item in dataset:
        b = item["bucket"]
        words = len(item["output"].split())
        if b not in bucket_stats:
            bucket_stats[b] = {"count": 0, "total_words": 0, "max_words": 0}
        bucket_stats[b]["count"] += 1
        bucket_stats[b]["total_words"] += words
        bucket_stats[b]["max_words"] = max(bucket_stats[b]["max_words"], words)

    total_words = sum(s["total_words"] for s in bucket_stats.values())

    print(
        f"\n{'Bucket':<20s} {'Count':>6s} {'%Samples':>9s} {'AvgWords':>9s} {'TotalWords':>11s} {'%Tokens':>8s}"
    )
    print("-" * 70)
    for b, s in sorted(bucket_stats.items(), key=lambda x: -x[1]["total_words"]):
        avg_w = s["total_words"] / s["count"] if s["count"] else 0
        pct_samples = s["count"] / len(dataset) * 100
        pct_tokens = s["total_words"] / total_words * 100
        print(
            f"  {b:<18s} {s['count']:>6d} {pct_samples:>8.1f}% {avg_w:>8.0f} {s['total_words']:>10,d} {pct_tokens:>7.1f}%"
        )
    print(
        f"  {'TOTAL':<18s} {len(dataset):>6d} {'100.0%':>9s} {total_words/len(dataset):>8.0f} {total_words:>10,d} {'100.0%':>8s}"
    )

    # === v5.3 → v7.0 COMPARISON ===
    print("\n" + "=" * 70)
    print("v5.3 → v7.0 COMPARISON")
    print("=" * 70)
    v53_tokens = {
        "vazhi_packs": (2958, 90210),
        "sadhguru_qa": (562, 376266),
        "thirukkural": (169, 4467),
        "conversational": (268, 3356),
        "safety": (45, 2246),
        "behavior": (116, 1946),
        "handcrafted": (120, 1730),
        "general": (27, 426),
        "corrections": (0, 0),
        "mission": (0, 0),
    }
    v53_total_tokens = sum(t for _, t in v53_tokens.values())

    print(f"\n{'Bucket':<20s} {'v5.3 %Tok':>10s} {'v7.0 %Tok':>10s} {'Change':>8s}")
    print("-" * 55)
    for b, s in sorted(bucket_stats.items(), key=lambda x: -x[1]["total_words"]):
        _, old_tokens = v53_tokens.get(b, (0, 0))
        old_pct = old_tokens / v53_total_tokens * 100 if v53_total_tokens else 0
        new_pct = s["total_words"] / total_words * 100
        delta = new_pct - old_pct
        print(f"  {b:<18s} {old_pct:>9.1f}% {new_pct:>9.1f}% {delta:>+7.1f}%")

    # === KEY METRICS ===
    print("\n" + "=" * 70)
    print("KEY METRICS — Is This Balanced for Gemma 3?")
    print("=" * 70)

    domain_pct = (
        bucket_stats.get("vazhi_packs", {}).get("total_words", 0) / total_words * 100
    )
    sadhguru_pct = (
        bucket_stats.get("sadhguru_qa", {}).get("total_words", 0) / total_words * 100
    )
    identity_words = sum(
        bucket_stats.get(b, {}).get("total_words", 0)
        for b in ["conversational", "behavior", "handcrafted", "corrections", "mission"]
    )
    identity_pct = identity_words / total_words * 100
    safety_pct = (
        bucket_stats.get("safety", {}).get("total_words", 0) / total_words * 100
    )

    checks = [
        (
            "Spiritual wisdom (sadhguru) 25-55%",
            25 <= sadhguru_pct <= 55,
            f"{sadhguru_pct:.1f}%",
        ),
        (
            "Domain knowledge (vazhi_packs) ≥ 30%",
            domain_pct >= 30,
            f"{domain_pct:.1f}%",
        ),
        ("Identity+behavior ≥ 3%", identity_pct >= 3, f"{identity_pct:.1f}%"),
        ("Safety ≤ 1.5%", safety_pct <= 1.5, f"{safety_pct:.1f}%"),
        (
            "Avg answer length ≤ 80 words",
            total_words / len(dataset) <= 80,
            f"{total_words/len(dataset):.0f} words",
        ),
    ]

    all_pass = True
    for label, passed, value in checks:
        status = "PASS" if passed else "FAIL"
        if not passed:
            all_pass = False
        print(f"  [{status}] {label}: {value}")

    if not all_pass:
        print("\n  WARNING: Some balance checks failed. Review token distribution.")
    else:
        print("\n  All balance checks passed!")

    # === QUALITY VALIDATION ===
    print("\n" + "=" * 70)
    print("QUALITY VALIDATION")
    print("=" * 70)
    tamil_pcts = []
    word_counts = []
    for item in dataset:
        tamil_pcts.append(tamil_pct(item["output"]))
        word_counts.append(len(item["output"].split()))

    print(f"  Tamil % avg: {sum(tamil_pcts)/len(tamil_pcts):.1f}")
    print(f"  Tamil % min: {min(tamil_pcts):.1f}")
    print(f"  Items <30% Tamil: {sum(1 for p in tamil_pcts if p < 30)}")
    print(f"  Items <50% Tamil: {sum(1 for p in tamil_pcts if p < 50)}")
    print(f"  Word count avg: {sum(word_counts)/len(word_counts):.0f}")
    print(f"  Word count range: {min(word_counts)}-{max(word_counts)}")

    # Save
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    train_path = OUTPUT_DIR / "vazhi-tamil-sft-v7_0-train.json"
    eval_path = OUTPUT_DIR / "vazhi-tamil-sft-v7_0-eval.json"
    full_path = OUTPUT_DIR / "vazhi-tamil-sft-v7_0-full.json"

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

    print(f"\n{'='*70}")
    print("Dataset v7.0 ready for Gemma 3 1B-it SFT")
    print(f"Total: {len(dataset)} samples ({len(train)} train + {len(eval_set)} eval)")
    print("Format: Raw instruction/output (notebook applies Gemma template)")
    print(f"{'='*70}")


if __name__ == "__main__":
    main()
