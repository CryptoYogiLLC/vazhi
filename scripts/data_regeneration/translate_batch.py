#!/usr/bin/env python3
"""
VAZHI v0.4 - Batch Translation Helper

Prepares batches for translation and validates results.
"""

import json
from pathlib import Path
from typing import List, Dict
import re

DATA_DIR = Path(__file__).parent.parent.parent / "data"
AUDIT_DIR = DATA_DIR / "v04" / "audit"
OUTPUT_DIR = DATA_DIR / "v04" / "regenerated"


def load_regenerate_samples() -> Dict[str, List[Dict]]:
    """Load samples that need regeneration, grouped by pack."""

    regen_file = AUDIT_DIR / "regenerate_samples.json"
    with open(regen_file, "r", encoding="utf-8") as f:
        samples = json.load(f)

    # Group by pack
    by_pack = {}
    for sample in samples:
        pack = sample.get('pack', 'unknown')
        if pack not in by_pack:
            by_pack[pack] = []
        by_pack[pack].append(sample)

    return by_pack


def prepare_batch(samples: List[Dict], batch_num: int, pack_name: str) -> Dict:
    """Prepare a batch for translation."""

    return {
        "pack": pack_name,
        "batch_num": batch_num,
        "sample_count": len(samples),
        "samples": [
            {
                "id": s.get("id", f"{pack_name}_{i}"),
                "instruction": s["instruction"],
                "current_output": s["output"],
                "category": s.get("category", ""),
                "target_language": determine_target_language(s),
            }
            for i, s in enumerate(samples)
        ]
    }


def determine_target_language(sample: Dict) -> str:
    """Determine target language based on instruction."""
    instruction = sample.get("instruction", "").lower()

    # If instruction has significant English, use Tanglish
    english_words = len(re.findall(r'[a-zA-Z]+', instruction))
    tamil_chars = len(re.findall(r'[\u0B80-\u0BFF]', instruction))

    if english_words > 3 or "?" in instruction and english_words > 1:
        return "tanglish"
    return "pure_tamil"


def get_pack_translation_guidelines(pack: str) -> str:
    """Get pack-specific translation guidelines."""

    guidelines = {
        "vazhi_maruthuvam": """
HEALTHCARE PACK GUIDELINES:
- Use Tamil medical terms: மருத்துவமனை (hospital), மருத்துவர் (doctor), சிகிச்சை (treatment)
- Keep disease names in English first time with Tamil: "Diabetes (நீரிழிவு)"
- Government hospital names can stay in English
- Use Tamil numbers where natural
- Format with emoji headers: 🏥, 💊, 🌿
""",
        "vazhi_kalvi": """
EDUCATION PACK GUIDELINES:
- Tanglish is acceptable for modern education topics
- Keep exam names (NEET, JEE, TNPSC) in English
- Use Tamil for explanations: தேர்வு (exam), கல்லூரி (college), பாடத்திட்டம் (syllabus)
- Format with emoji headers: 📚, 🎓, 📝
""",
        "vazhi_sattam": """
LEGAL PACK GUIDELINES:
- Keep Act names in English: "RTI Act 2005"
- Use Tamil for concepts: புகார் (complaint), உரிமை (rights), சட்டம் (law)
- Legal terms: வழக்கறிஞர் (lawyer), நீதிமன்றம் (court)
- Format with emoji headers: ⚖️, 📜, 🏛️
""",
        "vazhi_arasu": """
GOVERNMENT PACK GUIDELINES:
- Keep website URLs and scheme acronyms in English
- Use Tamil for process steps: விண்ணப்பம் (application), ஆவணம் (document)
- Tamil numbers for amounts when natural
- Format with emoji headers: 🏛️, 📋, 💰
""",
        "vazhi_kaval": """
SECURITY PACK GUIDELINES:
- Tanglish is natural for scam/cyber topics
- Keep technical terms: OTP, password, link, scam
- Use Tamil for warnings: எச்சரிக்கை (warning), ஆபத்து (danger), மோசடி (fraud)
- Format with emoji headers: 🚨, 🛡️, ⚠️
""",
        "vazhi_panpaadu": """
CULTURE PACK GUIDELINES:
- Pure Tamil preferred
- Thirukkural must use CITATION FORMAT with quotation marks
- Include source attribution
- Format with emoji headers: 📖, 🙏, 🛕
""",
    }

    return guidelines.get(pack, "Use natural Tamil with English technical terms in bilingual format.")


def validate_translation(original: Dict, translated: Dict) -> Dict:
    """Validate a translated sample."""

    output = translated.get("output", "")

    # Calculate Tamil percentage
    tamil_chars = len(re.findall(r'[\u0B80-\u0BFF]', output))
    english_chars = len(re.findall(r'[a-zA-Z]', output))
    total = tamil_chars + english_chars
    tamil_pct = (tamil_chars / total * 100) if total > 0 else 0

    # Check for structure
    has_structure = bool(re.search(r'[•📍📚🔢📖📜💡✍️🏥⚖️🛕🙏🚨🛡️💊🌿🎓]', output))

    # Check length
    adequate_length = len(output) >= 100

    # Determine pass/fail
    target_lang = original.get("target_language", "pure_tamil")
    min_tamil = 60 if target_lang == "pure_tamil" else 40

    is_valid = tamil_pct >= min_tamil and adequate_length

    return {
        "valid": is_valid,
        "tamil_percentage": round(tamil_pct, 1),
        "has_structure": has_structure,
        "adequate_length": adequate_length,
        "target_met": tamil_pct >= min_tamil,
    }


def save_batch_for_translation(pack: str, batch_num: int, samples: List[Dict]):
    """Save a batch file ready for translation."""

    output_dir = OUTPUT_DIR / "batches" / pack
    output_dir.mkdir(parents=True, exist_ok=True)

    batch = prepare_batch(samples, batch_num, pack)
    batch["guidelines"] = get_pack_translation_guidelines(pack)

    output_file = output_dir / f"batch_{batch_num:02d}.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(batch, f, ensure_ascii=False, indent=2)

    return output_file


def prepare_all_batches(batch_size: int = 25):
    """Prepare all batches for all packs."""

    by_pack = load_regenerate_samples()

    print("=" * 60)
    print("PREPARING TRANSLATION BATCHES")
    print("=" * 60)

    batch_files = {}

    for pack, samples in by_pack.items():
        print(f"\n{pack}: {len(samples)} samples")

        batch_files[pack] = []

        for i in range(0, len(samples), batch_size):
            batch_samples = samples[i:i+batch_size]
            batch_num = i // batch_size + 1

            file_path = save_batch_for_translation(pack, batch_num, batch_samples)
            batch_files[pack].append(str(file_path))

            print(f"  Batch {batch_num}: {len(batch_samples)} samples -> {file_path.name}")

    # Save batch manifest
    manifest = {
        "total_samples": sum(len(s) for s in by_pack.values()),
        "batch_size": batch_size,
        "packs": {
            pack: {
                "sample_count": len(samples),
                "batch_count": len(batch_files[pack]),
                "batch_files": batch_files[pack],
            }
            for pack, samples in by_pack.items()
        }
    }

    manifest_file = OUTPUT_DIR / "batches" / "manifest.json"
    with open(manifest_file, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*60}")
    print(f"BATCH PREPARATION COMPLETE")
    print(f"{'='*60}")
    print(f"Total batches: {sum(len(bf) for bf in batch_files.values())}")
    print(f"Manifest: {manifest_file}")

    return manifest


if __name__ == "__main__":
    prepare_all_batches(batch_size=25)
