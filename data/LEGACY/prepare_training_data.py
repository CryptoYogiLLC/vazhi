#!/usr/bin/env python3
"""
VAZHI v0.5 Training Data Preparation
Prepares Tamil foundation data for Qwen2.5-0.5B fine-tuning

Data Strategy:
- Q&A format: instruction-following
- Completion format: Tamil fluency
- Mix both for optimal learning
"""

import json
import os
import random
from pathlib import Path
from typing import List, Dict, Any

# Configuration
SEED = 42
VAL_SPLIT = 0.05  # 5% validation
OUTPUT_DIR = Path("./prepared_data")

# Files to include (Q&A format - instruction/output)
QA_FILES = [
    "02_thirukkural.json",      # 6439 items
    "03_numbers_time.json",     # 508 items
    "06_health.json",           # 112 items
    "07_education.json",        # 49 items
    "09_weather.json",          # 106 items
    "10_shopping.json",         # 154 items
    "12_daily_routines.json",   # 135 items
    "13_emotions.json",         # 100 items
    "14_chennai_dialect.json",  # 600 items (Tanglish)
    "15_madurai_dialect.json",  # 197 items
    "16_kongu_dialect.json",    # 209 items
    "27_guardrails.json",       # 114 items
    "32_avvaiyar.json",         # 86 items
]

# Files to EXCLUDE
EXCLUDE_FILES = [
    "31_malaysia_dialect.json",  # Only 12.6% Tamil - mostly Malay
]

# Corpus files - need special handling
CORPUS_FILES = {
    "37_thirukkural_corpus.json": {"qa_ratio": 0.7, "type": "kural"},
    "38_sangam_corpus.json": {"qa_ratio": 0.0, "type": "poetry"},  # All completion
    "36_silapathikaram_corpus.json": {"qa_ratio": 0.0, "type": "epic"},  # All completion
    "39_aathichoodi_corpus.json": {"qa_ratio": 1.0, "type": "verses"},  # All Q&A
    "40_bharathiar_corpus.json": {"qa_ratio": 0.0, "type": "poetry"},  # All completion
}


def load_qa_data(filepath: str) -> List[Dict]:
    """Load Q&A format data"""
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    if not isinstance(data, list):
        print(f"  Warning: {filepath} is not a list, skipping")
        return []

    qa_items = []
    for item in data:
        if isinstance(item, dict) and 'instruction' in item and 'output' in item:
            qa_items.append({
                "instruction": item["instruction"],
                "output": item["output"],
                "source": os.path.basename(filepath),
                "format": "qa"
            })

    return qa_items


def convert_thirukkural_corpus(filepath: str, qa_ratio: float) -> tuple:
    """Convert Thirukkural corpus to Q&A and completion formats"""
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    qa_items = []
    completion_items = []

    for item in data:
        kural_num = item.get('kural_number', '')
        tamil = item.get('tamil', '')
        meaning = item.get('meaning_tamil', '')
        adhikaram = item.get('adhikaram', '')

        if random.random() < qa_ratio:
            # Q&A format - multiple question variations
            questions = [
                f"திருக்குறள் {kural_num} என்ன?",
                f"குறள் {kural_num} சொல்லுங்கள்",
                f"{adhikaram} அதிகாரத்தின் குறள் {kural_num} என்ன?",
            ]

            for q in random.sample(questions, min(2, len(questions))):
                answer = f"குறள் {kural_num}:\n\n\"{tamil}\"\n\nபொருள்: {meaning}"
                qa_items.append({
                    "instruction": q,
                    "output": answer,
                    "source": "thirukkural_corpus",
                    "format": "qa"
                })
        else:
            # Completion format - raw text for fluency
            text = f"{tamil}\n\n{meaning}"
            completion_items.append({
                "text": text,
                "source": "thirukkural_corpus",
                "format": "completion"
            })

    return qa_items, completion_items


def convert_poetry_corpus(filepath: str, corpus_type: str) -> List[Dict]:
    """Convert poetry corpus to completion format"""
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    completion_items = []

    if isinstance(data, list):
        for item in data:
            if isinstance(item, dict):
                text = item.get('text', '') or item.get('full_text', '')
                if text:
                    completion_items.append({
                        "text": text,
                        "source": os.path.basename(filepath),
                        "format": "completion"
                    })
    elif isinstance(data, dict):
        # Handle nested structures like Bharathiar
        if 'poems' in data:
            poems = data['poems']
            if isinstance(poems, list):
                for poem in poems:
                    text = poem.get('full_text', '')
                    if text:
                        completion_items.append({
                            "text": text,
                            "source": "bharathiar_corpus",
                            "format": "completion"
                        })

    return completion_items


def convert_aathichoodi_corpus(filepath: str) -> List[Dict]:
    """Convert Aathichoodi to Q&A format"""
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    qa_items = []

    # Handle nested structure
    if 'aathichoodi' in data and 'verses' in data['aathichoodi']:
        verses = data['aathichoodi']['verses']
        for verse in verses:
            tamil = verse.get('tamil', '')
            meaning = verse.get('meaning', '')
            letter = verse.get('letter', '')

            questions = [
                f"ஆத்திசூடி - '{letter}' எழுத்து பாடல் என்ன?",
                f"ஔவையாரின் ஆத்திசூடியில் '{letter}' என்ன சொல்கிறது?",
            ]

            for q in questions:
                answer = f"\"{tamil}\"\n\nபொருள்: {meaning}"
                qa_items.append({
                    "instruction": q,
                    "output": answer,
                    "source": "aathichoodi_corpus",
                    "format": "qa"
                })

    # Also handle konrai_venthan if present
    if 'konrai_venthan' in data and 'verses' in data['konrai_venthan']:
        verses = data['konrai_venthan']['verses']
        for verse in verses:
            tamil = verse.get('tamil', '')
            meaning = verse.get('meaning', '')

            qa_items.append({
                "instruction": "கொன்றை வேந்தன் பாடல் ஒன்று சொல்லுங்கள்",
                "output": f"\"{tamil}\"\n\nபொருள்: {meaning}",
                "source": "konrai_venthan_corpus",
                "format": "qa"
            })

    return qa_items


def format_for_training(items: List[Dict], include_completion: bool = True) -> List[Dict]:
    """Format items for Qwen2.5 training"""

    SYSTEM_PROMPT = """நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர். தமிழில் தெளிவாகவும் உதவியாகவும் பதிலளியுங்கள். தெரியாவிட்டால் "தெரியவில்லை" என்று சொல்லுங்கள்."""

    formatted = []

    for item in items:
        if item["format"] == "qa":
            # Instruction format for Qwen2.5
            text = f"""<|im_start|>system
{SYSTEM_PROMPT}<|im_end|>
<|im_start|>user
{item['instruction']}<|im_end|>
<|im_start|>assistant
{item['output']}<|im_end|>"""
            formatted.append({"text": text, "format": "qa", "source": item["source"]})

        elif item["format"] == "completion" and include_completion:
            # Completion format - just the Tamil text
            formatted.append({"text": item["text"], "format": "completion", "source": item["source"]})

    return formatted


def main():
    random.seed(SEED)

    print("=" * 60)
    print("VAZHI v0.5 Training Data Preparation")
    print("=" * 60)

    all_qa_items = []
    all_completion_items = []

    # 1. Load Q&A files
    print("\n📁 Loading Q&A files...")
    for filename in QA_FILES:
        if os.path.exists(filename):
            items = load_qa_data(filename)
            all_qa_items.extend(items)
            print(f"  ✅ {filename}: {len(items)} items")
        else:
            print(f"  ⚠️ {filename}: not found")

    print(f"\n  Total Q&A items: {len(all_qa_items)}")

    # 2. Process corpus files
    print("\n📚 Processing corpus files...")

    # Thirukkural corpus
    if os.path.exists("37_thirukkural_corpus.json"):
        qa, comp = convert_thirukkural_corpus("37_thirukkural_corpus.json", 0.7)
        all_qa_items.extend(qa)
        all_completion_items.extend(comp)
        print(f"  ✅ Thirukkural corpus: {len(qa)} Q&A + {len(comp)} completion")

    # Poetry corpora (completion only)
    for filename in ["38_sangam_corpus.json", "36_silapathikaram_corpus.json"]:
        if os.path.exists(filename):
            items = convert_poetry_corpus(filename, "poetry")
            all_completion_items.extend(items)
            print(f"  ✅ {filename}: {len(items)} completion items")

    # Bharathiar
    if os.path.exists("40_bharathiar_corpus.json"):
        items = convert_poetry_corpus("40_bharathiar_corpus.json", "poetry")
        all_completion_items.extend(items)
        print(f"  ✅ Bharathiar corpus: {len(items)} completion items")

    # Aathichoodi (Q&A)
    if os.path.exists("39_aathichoodi_corpus.json"):
        items = convert_aathichoodi_corpus("39_aathichoodi_corpus.json")
        all_qa_items.extend(items)
        print(f"  ✅ Aathichoodi corpus: {len(items)} Q&A items")

    # 3. Combine and format
    print("\n🔧 Formatting for training...")
    all_items = all_qa_items + [{"text": c["text"], "source": c["source"], "format": "completion"}
                                  for c in all_completion_items]

    # Shuffle
    random.shuffle(all_items)

    # Format for Qwen2.5
    formatted_items = format_for_training(all_items)

    print(f"  Total formatted items: {len(formatted_items)}")
    print(f"  - Q&A items: {sum(1 for x in formatted_items if x['format'] == 'qa')}")
    print(f"  - Completion items: {sum(1 for x in formatted_items if x['format'] == 'completion')}")

    # 4. Split train/val
    print("\n📊 Creating train/val split...")
    random.shuffle(formatted_items)

    val_size = int(len(formatted_items) * VAL_SPLIT)
    val_data = formatted_items[:val_size]
    train_data = formatted_items[val_size:]

    print(f"  Train: {len(train_data)} items")
    print(f"  Val: {len(val_data)} items")

    # 5. Save
    OUTPUT_DIR.mkdir(exist_ok=True)

    # Save as JSONL for HuggingFace
    with open(OUTPUT_DIR / "train.jsonl", 'w', encoding='utf-8') as f:
        for item in train_data:
            f.write(json.dumps({"text": item["text"]}, ensure_ascii=False) + "\n")

    with open(OUTPUT_DIR / "val.jsonl", 'w', encoding='utf-8') as f:
        for item in val_data:
            f.write(json.dumps({"text": item["text"]}, ensure_ascii=False) + "\n")

    # Save metadata
    metadata = {
        "total_items": len(formatted_items),
        "train_items": len(train_data),
        "val_items": len(val_data),
        "qa_items": sum(1 for x in formatted_items if x['format'] == 'qa'),
        "completion_items": sum(1 for x in formatted_items if x['format'] == 'completion'),
        "sources": list(set(x['source'] for x in formatted_items)),
        "model": "Qwen/Qwen2.5-0.5B-Instruct",
        "seed": SEED,
    }

    with open(OUTPUT_DIR / "metadata.json", 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Data saved to {OUTPUT_DIR}/")
    print(f"  - train.jsonl ({len(train_data)} items)")
    print(f"  - val.jsonl ({len(val_data)} items)")
    print(f"  - metadata.json")

    # 6. Show sample
    print("\n📝 Sample formatted item:")
    sample = train_data[0]
    print(sample["text"][:500] + "...")

    return metadata


if __name__ == "__main__":
    main()
