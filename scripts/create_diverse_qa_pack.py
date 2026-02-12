#!/usr/bin/env python3
"""
Create Diverse QA Pack from AI4Bharat IndicAlign Dataset
=========================================================

This script extracts diverse Tamil QA samples from IndicAlign to rebalance
our Thirukkural-heavy training dataset.

Target: 800-1500 diverse samples covering:
- General knowledge QA
- How-to instructions (WikiHow)
- Conversational Tamil
- Short factual answers

Source: https://huggingface.co/datasets/ai4bharat/indic-align
"""

import json
import random
import re
from pathlib import Path
from datasets import load_dataset
from tqdm import tqdm

# Output directory
OUTPUT_DIR = (
    Path(__file__).parent.parent / "data" / "tamil_foundation" / "diverse_qa_pack"
)
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Random seed for reproducibility
random.seed(42)


def clean_text(text: str) -> str:
    """Clean and normalize Tamil text."""
    if not text or not isinstance(text, str):
        return ""
    # Remove excessive whitespace
    text = re.sub(r"\s+", " ", text).strip()
    # Remove any remaining artifacts
    text = re.sub(r"<[^>]+>", "", text)  # HTML tags
    return text


def is_good_tamil_sample(text: str) -> bool:
    """Check if text is good quality Tamil."""
    if not text or len(text) < 20:
        return False
    # Check for Tamil characters (Unicode range: 0B80-0BFF)
    tamil_chars = sum(1 for c in text if "\u0B80" <= c <= "\u0BFF")
    # At least 30% Tamil characters
    if tamil_chars / len(text) < 0.3:
        return False
    # Not too long (avoid full articles)
    if len(text) > 2000:
        return False
    return True


def extract_dolly_samples(max_samples: int = 300) -> list:
    """Extract instruction-following samples from Dolly_T."""
    print("\n📚 Loading Dolly_T dataset...")
    try:
        ds = load_dataset(
            "ai4bharat/indic-align", "Dolly_T", split="train", streaming=True
        )
    except Exception as e:
        print(f"   ⚠️ Error loading Dolly_T: {e}")
        return []

    samples = []
    seen_texts = set()

    for item in tqdm(ds, desc="Dolly_T", total=max_samples * 3):
        if len(samples) >= max_samples:
            break

        tamil_text = item.get("tam_Taml", "")
        if not tamil_text:
            continue

        # Parse conversation format (usually list of turns)
        if isinstance(tamil_text, list):
            # Multi-turn conversation
            if len(tamil_text) >= 2:
                user_msg = clean_text(str(tamil_text[0]))
                assistant_msg = clean_text(str(tamil_text[1]))
            else:
                continue
        else:
            # Single text - skip
            continue

        # Quality checks
        if not is_good_tamil_sample(user_msg) or not is_good_tamil_sample(
            assistant_msg
        ):
            continue

        # Dedup
        key = user_msg[:100]
        if key in seen_texts:
            continue
        seen_texts.add(key)

        samples.append(
            {
                "instruction": user_msg,
                "output": assistant_msg,
                "source": "Dolly_T",
                "category": "instruction_following",
            }
        )

    print(f"   ✅ Extracted {len(samples)} Dolly samples")
    return samples


def extract_wikihow_samples(max_samples: int = 250) -> list:
    """Extract how-to instruction samples from WikiHow."""
    print("\n📖 Loading WikiHow dataset...")
    try:
        ds = load_dataset(
            "ai4bharat/indic-align", "WikiHow", split="train", streaming=True
        )
    except Exception as e:
        print(f"   ⚠️ Error loading WikiHow: {e}")
        return []

    samples = []
    seen_texts = set()

    for item in tqdm(ds, desc="WikiHow", total=max_samples * 3):
        if len(samples) >= max_samples:
            break

        tamil_text = item.get("tam_Taml", "")
        if not tamil_text:
            continue

        # Parse conversation format
        if isinstance(tamil_text, list) and len(tamil_text) >= 2:
            user_msg = clean_text(str(tamil_text[0]))
            assistant_msg = clean_text(str(tamil_text[1]))
        else:
            continue

        if not is_good_tamil_sample(user_msg) or not is_good_tamil_sample(
            assistant_msg
        ):
            continue

        key = user_msg[:100]
        if key in seen_texts:
            continue
        seen_texts.add(key)

        samples.append(
            {
                "instruction": user_msg,
                "output": assistant_msg,
                "source": "WikiHow",
                "category": "how_to",
            }
        )

    print(f"   ✅ Extracted {len(samples)} WikiHow samples")
    return samples


def extract_wiki_conv_samples(max_samples: int = 300) -> list:
    """Extract conversational samples from Wiki_Conv."""
    print("\n💬 Loading Wiki_Conv dataset...")
    try:
        ds = load_dataset(
            "ai4bharat/indic-align", "Wiki_Conv", split="train", streaming=True
        )
    except Exception as e:
        print(f"   ⚠️ Error loading Wiki_Conv: {e}")
        return []

    samples = []
    seen_texts = set()

    for item in tqdm(ds, desc="Wiki_Conv", total=max_samples * 3):
        if len(samples) >= max_samples:
            break

        tamil_text = item.get("tam_Taml", "")
        if not tamil_text:
            continue

        if isinstance(tamil_text, list) and len(tamil_text) >= 2:
            user_msg = clean_text(str(tamil_text[0]))
            assistant_msg = clean_text(str(tamil_text[1]))
        else:
            continue

        if not is_good_tamil_sample(user_msg) or not is_good_tamil_sample(
            assistant_msg
        ):
            continue

        key = user_msg[:100]
        if key in seen_texts:
            continue
        seen_texts.add(key)

        samples.append(
            {
                "instruction": user_msg,
                "output": assistant_msg,
                "source": "Wiki_Conv",
                "category": "conversational",
            }
        )

    print(f"   ✅ Extracted {len(samples)} Wiki_Conv samples")
    return samples


def extract_openassistant_samples(max_samples: int = 200) -> list:
    """Extract assistant dialog samples from OpenAssistant_T."""
    print("\n🤖 Loading OpenAssistant_T dataset...")
    try:
        ds = load_dataset(
            "ai4bharat/indic-align", "OpenAssistant_T", split="train", streaming=True
        )
    except Exception as e:
        print(f"   ⚠️ Error loading OpenAssistant_T: {e}")
        return []

    samples = []
    seen_texts = set()

    for item in tqdm(ds, desc="OpenAssistant_T", total=max_samples * 3):
        if len(samples) >= max_samples:
            break

        tamil_text = item.get("tam_Taml", "")
        if not tamil_text:
            continue

        if isinstance(tamil_text, list) and len(tamil_text) >= 2:
            user_msg = clean_text(str(tamil_text[0]))
            assistant_msg = clean_text(str(tamil_text[1]))
        else:
            continue

        if not is_good_tamil_sample(user_msg) or not is_good_tamil_sample(
            assistant_msg
        ):
            continue

        key = user_msg[:100]
        if key in seen_texts:
            continue
        seen_texts.add(key)

        samples.append(
            {
                "instruction": user_msg,
                "output": assistant_msg,
                "source": "OpenAssistant_T",
                "category": "assistant_dialog",
            }
        )

    print(f"   ✅ Extracted {len(samples)} OpenAssistant samples")
    return samples


def create_short_answer_samples() -> list:
    """Create short factual answer samples manually."""
    print("\n📝 Creating short answer samples...")

    samples = [
        # Geography
        {
            "instruction": "தமிழ்நாட்டின் தலைநகரம் என்ன?",
            "output": "சென்னை.",
            "category": "geography",
        },
        {
            "instruction": "இந்தியாவின் தலைநகரம் எது?",
            "output": "புது தில்லி.",
            "category": "geography",
        },
        {
            "instruction": "உலகின் மிகப்பெரிய நாடு எது?",
            "output": "ரஷ்யா (பரப்பளவில்).",
            "category": "geography",
        },
        {
            "instruction": "கங்கை நதி எங்கு உற்பத்தியாகிறது?",
            "output": "இமயமலையில் உள்ள கங்கோத்ரி பனிப்பாறையில்.",
            "category": "geography",
        },
        {
            "instruction": "தமிழ்நாட்டின் மாவட்டங்கள் எத்தனை?",
            "output": "38 மாவட்டங்கள்.",
            "category": "geography",
        },
        {
            "instruction": "காவிரி நதி எந்த மாநிலங்களில் பாய்கிறது?",
            "output": "கர்நாடகா மற்றும் தமிழ்நாடு.",
            "category": "geography",
        },
        {
            "instruction": "மதுரை எந்த நதிக்கரையில் உள்ளது?",
            "output": "வைகை நதிக்கரையில்.",
            "category": "geography",
        },
        {
            "instruction": "இந்தியாவின் மக்கள்தொகை அதிகமான மாநிலம் எது?",
            "output": "உத்தரப் பிரதேசம்.",
            "category": "geography",
        },
        # Basic facts
        {
            "instruction": "சூரியன் எந்த திசையில் உதிக்கும்?",
            "output": "கிழக்கு திசையில்.",
            "category": "basic_facts",
        },
        {
            "instruction": "ஒரு வாரத்தில் எத்தனை நாட்கள்?",
            "output": "ஏழு நாட்கள்.",
            "category": "basic_facts",
        },
        {
            "instruction": "ஒரு வருடத்தில் எத்தனை மாதங்கள்?",
            "output": "12 மாதங்கள்.",
            "category": "basic_facts",
        },
        {
            "instruction": "தண்ணீரின் கொதிநிலை என்ன?",
            "output": "100 டிகிரி செல்சியஸ்.",
            "category": "basic_facts",
        },
        {
            "instruction": "பூமி சூரியனை சுற்ற எத்தனை நாட்கள் ஆகும்?",
            "output": "365 நாட்கள் (ஒரு வருடம்).",
            "category": "basic_facts",
        },
        {"instruction": "2+2 என்ன?", "output": "4.", "category": "basic_facts"},
        {"instruction": "10 x 10 என்ன?", "output": "100.", "category": "basic_facts"},
        {
            "instruction": "100-ஐ 4-ஆல் வகுத்தால்?",
            "output": "25.",
            "category": "basic_facts",
        },
        # Tamil culture (non-Thirukkural)
        {
            "instruction": "பொங்கல் எப்போது கொண்டாடப்படுகிறது?",
            "output": "தை மாதம் முதல் நாள் (ஜனவரி 14 அல்லது 15).",
            "category": "culture",
        },
        {
            "instruction": "தமிழ் எழுத்துக்கள் எத்தனை?",
            "output": "247 எழுத்துக்கள் (12 உயிர் + 18 மெய் + 216 உயிர்மெய் + 1 ஆய்தம்).",
            "category": "culture",
        },
        {
            "instruction": "தமிழ்நாட்டின் அலுவல் மொழி என்ன?",
            "output": "தமிழ்.",
            "category": "culture",
        },
        {
            "instruction": "சிலப்பதிகாரத்தை எழுதியவர் யார்?",
            "output": "இளங்கோவடிகள்.",
            "category": "culture",
        },
        {
            "instruction": "பாரதியார் எந்த ஊரில் பிறந்தார்?",
            "output": "எட்டயபுரம்.",
            "category": "culture",
        },
        {
            "instruction": "தமிழ் தினம் எப்போது?",
            "output": "ஜனவரி 9.",
            "category": "culture",
        },
        # Science
        {
            "instruction": "மனித உடலில் எத்தனை எலும்புகள் உள்ளன?",
            "output": "206 எலும்புகள்.",
            "category": "science",
        },
        {
            "instruction": "ஒளியின் வேகம் என்ன?",
            "output": "வினாடிக்கு சுமார் 3 லட்சம் கிலோமீட்டர்.",
            "category": "science",
        },
        {
            "instruction": "H2O என்பது என்ன?",
            "output": "தண்ணீர் (நீர்).",
            "category": "science",
        },
        {
            "instruction": "பூமியின் ஒரே இயற்கை துணைக்கோள் எது?",
            "output": "நிலவு (சந்திரன்).",
            "category": "science",
        },
        {
            "instruction": "சூரிய குடும்பத்தில் எத்தனை கோள்கள்?",
            "output": "எட்டு கோள்கள்.",
            "category": "science",
        },
        # Everyday Tamil
        {
            "instruction": "நன்றி என்றால் ஆங்கிலத்தில் என்ன?",
            "output": "Thank you.",
            "category": "everyday",
        },
        {
            "instruction": "Good morning தமிழில் என்ன?",
            "output": "காலை வணக்கம்.",
            "category": "everyday",
        },
        {
            "instruction": "தற்போது நேரம் என்ன என்று கேட்பது எப்படி?",
            "output": "இப்போது நேரம் என்ன?",
            "category": "everyday",
        },
        {
            "instruction": "வணக்கம் என்றால் என்ன?",
            "output": "வணக்கம் என்பது தமிழில் பயன்படுத்தப்படும் வாழ்த்துச் சொல், Hello என்ற பொருளில்.",
            "category": "everyday",
        },
        # Short Q&A
        {
            "instruction": "ஆம் என்றால் ஆங்கிலத்தில்?",
            "output": "Yes.",
            "category": "short_qa",
        },
        {
            "instruction": "இல்லை என்றால் ஆங்கிலத்தில்?",
            "output": "No.",
            "category": "short_qa",
        },
        {"instruction": "1 + 1?", "output": "2.", "category": "short_qa"},
        {"instruction": "5 x 5?", "output": "25.", "category": "short_qa"},
        {
            "instruction": "மிகப்பெரிய கண்டம் எது?",
            "output": "ஆசியா.",
            "category": "short_qa",
        },
        {
            "instruction": "மிகச்சிறிய கண்டம் எது?",
            "output": "ஆஸ்திரேலியா.",
            "category": "short_qa",
        },
    ]

    # Add source field
    for s in samples:
        s["source"] = "manual_short_answer"

    print(f"   ✅ Created {len(samples)} short answer samples")
    return samples


def create_behavior_samples() -> list:
    """Create assistant behavior samples (anti-loop, refusal, grounding)."""
    print("\n🛡️ Creating behavior samples...")

    samples = [
        # Anti-loop / answer once
        {
            "instruction": "வணக்கம்",
            "output": "வணக்கம்! நான் வழி. உங்களுக்கு எப்படி உதவ வேண்டும்?",
            "category": "greeting",
        },
        {"instruction": "hi", "output": "வணக்கம்! எப்படி உதவலாம்?", "category": "greeting"},
        {"instruction": "hello", "output": "வணக்கம்! கேளுங்கள்.", "category": "greeting"},
        # Unknown / refusal
        {
            "instruction": "2050-ல் யார் பிரதமர் ஆவார்?",
            "output": "எதிர்காலத்தை கணிக்க என்னால் முடியாது. தெரியவில்லை.",
            "category": "unknown",
        },
        {
            "instruction": "நாளை பங்கு சந்தை எப்படி இருக்கும்?",
            "output": "பங்கு சந்தை நிலவரத்தை கணிக்க என்னால் இயலாது. நிதி ஆலோசகரிடம் கேளுங்கள்.",
            "category": "unknown",
        },
        {
            "instruction": "என்னுடைய கடவுச்சொல் என்ன?",
            "output": "உங்கள் தனிப்பட்ட தகவல்கள் என்னிடம் இல்லை. உங்கள் கணக்கு settings-ல் சரிபாருங்கள்.",
            "category": "refusal",
        },
        {
            "instruction": "யாரையாவது ஏமாற்ற உதவுங்கள்",
            "output": "மன்னிக்கவும், சட்டவிரோத அல்லது ஒழுக்கக்கேடான செயல்களுக்கு உதவ முடியாது.",
            "category": "refusal",
        },
        # Grounding / suggest official sources
        {
            "instruction": "அரசு திட்டங்களுக்கு விண்ணப்பிப்பது எப்படி?",
            "output": "அரசு திட்டங்களுக்கு tnega.tn.gov.in அல்லது அருகிலுள்ள தலைமைச் செயலக அலுவலகத்தை தொடர்பு கொள்ளுங்கள். சரியான தகவலுக்கு அரசு இணையதளங்களைப் பாருங்கள்.",
            "category": "grounding",
        },
        {
            "instruction": "மருத்துவ ஆலோசனை தேவை",
            "output": "மருத்துவ ஆலோசனைக்கு தகுதி வாய்ந்த மருத்துவரை அணுகுங்கள். நான் மருத்துவர் அல்ல, பொது தகவல் மட்டுமே தர முடியும்.",
            "category": "grounding",
        },
        {
            "instruction": "சட்ட ஆலோசனை வேண்டும்",
            "output": "சட்ட விஷயங்களுக்கு வழக்கறிஞரை அணுகுவது சிறந்தது. நான் பொது தகவல் மட்டுமே தர முடியும், சட்ட ஆலோசனை அல்ல.",
            "category": "grounding",
        },
        # Short responses
        {
            "instruction": "சரி",
            "output": "சரி, வேறு ஏதாவது கேள்வி இருக்கிறதா?",
            "category": "short_response",
        },
        {
            "instruction": "நன்றி",
            "output": "மகிழ்ச்சி! வேறு உதவி தேவைப்பட்டால் கேளுங்கள்.",
            "category": "short_response",
        },
        {
            "instruction": "bye",
            "output": "வணக்கம்! இனிய நாள் வாழ்த்துக்கள்.",
            "category": "short_response",
        },
    ]

    for s in samples:
        s["source"] = "manual_behavior"

    print(f"   ✅ Created {len(samples)} behavior samples")
    return samples


def save_samples(all_samples: list, filename: str):
    """Save samples to JSON file."""
    output_path = OUTPUT_DIR / filename
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(all_samples, f, ensure_ascii=False, indent=2)
    print(f"\n💾 Saved {len(all_samples)} samples to {output_path}")
    return output_path


def convert_to_sft_format(samples: list) -> list:
    """Convert samples to SFT training format (ChatML)."""
    SYSTEM_PROMPT = 'நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர். தமிழில் தெளிவாகவும் உதவியாகவும் பதிலளியுங்கள். தெரியாவிட்டால் "தெரியவில்லை" என்று சொல்லுங்கள்.'

    sft_samples = []
    for s in samples:
        text = f"<|im_start|>system\n{SYSTEM_PROMPT}<|im_end|>\n"
        text += f"<|im_start|>user\n{s['instruction']}<|im_end|>\n"
        text += f"<|im_start|>assistant\n{s['output']}<|im_end|>"

        sft_samples.append(
            {
                "text": text,
                "source": s.get("source", "unknown"),
                "category": s.get("category", "unknown"),
            }
        )

    return sft_samples


def main():
    print("=" * 60)
    print("🚀 Creating Diverse QA Pack for VAZHI Training")
    print("=" * 60)

    all_samples = []

    # Extract from IndicAlign datasets
    all_samples.extend(extract_dolly_samples(max_samples=300))
    all_samples.extend(extract_wikihow_samples(max_samples=250))
    all_samples.extend(extract_wiki_conv_samples(max_samples=300))
    all_samples.extend(extract_openassistant_samples(max_samples=200))

    # Add manual samples
    all_samples.extend(create_short_answer_samples())
    all_samples.extend(create_behavior_samples())

    # Shuffle
    random.shuffle(all_samples)

    print(f"\n📊 Total samples collected: {len(all_samples)}")

    # Distribution
    source_counts = {}
    category_counts = {}
    for s in all_samples:
        src = s.get("source", "unknown")
        cat = s.get("category", "unknown")
        source_counts[src] = source_counts.get(src, 0) + 1
        category_counts[cat] = category_counts.get(cat, 0) + 1

    print("\n📈 By Source:")
    for k, v in sorted(source_counts.items(), key=lambda x: -x[1]):
        print(f"   {k}: {v}")

    print("\n📈 By Category:")
    for k, v in sorted(category_counts.items(), key=lambda x: -x[1]):
        print(f"   {k}: {v}")

    # Save raw samples
    save_samples(all_samples, "diverse_qa_raw.json")

    # Convert to SFT format and save
    sft_samples = convert_to_sft_format(all_samples)

    sft_path = OUTPUT_DIR / "diverse_qa_sft.jsonl"
    with open(sft_path, "w", encoding="utf-8") as f:
        for s in sft_samples:
            f.write(json.dumps(s, ensure_ascii=False) + "\n")
    print(f"💾 Saved SFT format to {sft_path}")

    # Create metadata
    metadata = {
        "total_samples": len(all_samples),
        "sources": source_counts,
        "categories": category_counts,
        "target_distribution": {
            "instruction_following": "~300 (from Dolly_T)",
            "how_to": "~250 (from WikiHow)",
            "conversational": "~300 (from Wiki_Conv)",
            "assistant_dialog": "~200 (from OpenAssistant_T)",
            "short_answer": "~40 (manual)",
            "behavior": "~15 (manual)",
        },
        "purpose": "Rebalance Thirukkural-heavy training data",
        "version": "1.0",
    }

    with open(OUTPUT_DIR / "metadata.json", "w", encoding="utf-8") as f:
        json.dump(metadata, f, ensure_ascii=False, indent=2)

    print("\n" + "=" * 60)
    print("✅ Diverse QA Pack creation complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
