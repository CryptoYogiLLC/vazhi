#!/usr/bin/env python3
"""
VAZHI v0.4 - Data Regeneration Pipeline

This script helps regenerate English responses to proper Tamil.
Can work in multiple modes:
1. Export for manual regeneration (via Claude.ai)
2. Template-based semi-automatic regeneration
3. API-based regeneration (if API key available)
"""

import json
import re
from pathlib import Path
from typing import List
from templates import (
    THIRUKKURAL_AUTHORITATIVE,
    SIDDHARS_AUTHORITATIVE,
)

DATA_DIR = Path(__file__).parent.parent.parent / "data"
AUDIT_DIR = DATA_DIR / "v04" / "audit"
OUTPUT_DIR = DATA_DIR / "v04" / "regenerated"


def create_regeneration_prompt(sample: dict) -> str:
    """Create a prompt for LLM to regenerate the response in Tamil."""

    pack = sample.get("pack", "")
    instruction = sample.get("instruction", "")
    current_output = sample.get("output", "")
    category = sample.get("category", "")

    # Determine target language style
    if "panpaadu" in pack or "culture" in pack:
        lang_style = "pure Tamil (முழு தமிழ்)"
        extra_instruction = """
IMPORTANT: For Thirukkural, use CITATION format with quotation marks:
- Put the actual kural text in quotes
- Include kural number, athikaram name
- Provide meaning (பொருள்) and explanation (விளக்கம்)
- DO NOT make up kurals - use only authentic Thirukkural text
"""
    elif "kaval" in pack or "security" in pack:
        lang_style = "Tanglish (natural Tamil-English mix as Tamils actually speak)"
        extra_instruction = "Use scam/cyber security terms naturally mixed with Tamil."
    else:
        lang_style = "Tamil with technical terms in bilingual format: 'English (தமிழ்)' for first mention"
        extra_instruction = ""

    prompt = f"""Convert this English response to {lang_style}.

RULES:
1. Use actual Tamil words, not transliteration
2. Keep proper nouns (website URLs, act names) in English
3. Use structured format with Tamil headers
4. Keep the same information, just translate the language
5. Make it sound natural for a Tamil speaker
{extra_instruction}

QUESTION: {instruction}

CURRENT RESPONSE (mostly English):
{current_output}

PACK: {pack}
CATEGORY: {category}

Please provide the Tamil version:"""

    return prompt


def export_for_manual_regeneration(
    samples: List[dict], output_file: str, batch_size: int = 50
):
    """Export samples in a format suitable for manual regeneration via Claude.ai."""

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Group by pack for easier processing
    by_pack = {}
    for sample in samples:
        pack = sample.get("pack", "unknown")
        if pack not in by_pack:
            by_pack[pack] = []
        by_pack[pack].append(sample)

    # Export each pack separately
    for pack, pack_samples in by_pack.items():
        pack_dir = OUTPUT_DIR / "for_manual" / pack
        pack_dir.mkdir(parents=True, exist_ok=True)

        # Split into batches
        for i in range(0, len(pack_samples), batch_size):
            batch = pack_samples[i : i + batch_size]
            batch_file = pack_dir / f"batch_{i//batch_size + 1}.json"

            # Create prompts for each sample
            batch_with_prompts = []
            for sample in batch:
                sample_copy = sample.copy()
                sample_copy["_regeneration_prompt"] = create_regeneration_prompt(sample)
                batch_with_prompts.append(sample_copy)

            with open(batch_file, "w", encoding="utf-8") as f:
                json.dump(batch_with_prompts, f, ensure_ascii=False, indent=2)

            print(f"Exported: {batch_file} ({len(batch)} samples)")

    # Create master instruction file
    instruction_file = OUTPUT_DIR / "for_manual" / "REGENERATION_INSTRUCTIONS.md"
    with open(instruction_file, "w", encoding="utf-8") as f:
        f.write(
            """# VAZHI Data Regeneration Instructions

## How to Regenerate Samples

1. Open each batch file (batch_1.json, batch_2.json, etc.)
2. For each sample, use the `_regeneration_prompt` field
3. Paste the prompt into Claude.ai or similar
4. Copy the Tamil response back to the `output` field
5. Remove the `_regeneration_prompt` field
6. Save the file

## Language Guidelines

### Pure Tamil (Culture Pack)
- Use full Tamil script
- Thirukkural must be in citation format with quotation marks
- Use authentic text only, no generation

### Tanglish (Security Pack)
- Natural mix like how Tamils actually speak
- "Scam message பார்த்தா immediately block பண்ணுங்க"

### Bilingual (Other Packs)
- First mention: "Website (இணையதளம்)"
- Subsequently: "இணையதளம்"
- Technical terms can stay in English with Tamil explanation

## Quality Checks

After regeneration, ensure:
- [ ] Response is >60% Tamil characters
- [ ] Information is accurate (not made up)
- [ ] Thirukkural quotes are authentic
- [ ] Format is structured and readable
"""
        )
    print(f"\nCreated instructions: {instruction_file}")


def regenerate_culture_pack():
    """Special handling for Culture pack - use authoritative sources."""

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    culture_output = OUTPUT_DIR / "culture_authoritative.json"

    regenerated = []

    # Generate Thirukkural Q&As from authoritative source
    for kural_num, kural_data in THIRUKKURAL_AUTHORITATIVE.items():
        # Multiple question variations
        questions = [
            f"திருக்குறளின் குறள் {kural_num} என்ன?",
            f"குறள் {kural_num} சொல்லுங்க",
        ]

        if kural_num == 1:
            questions.extend(
                [
                    "திருக்குறளின் முதல் குறள் என்ன?",
                    "Thirukkural முதல் குறள் என்ன?",
                    "அகர முதல குறள் சொல்லுங்க",
                    "கடவுள் வாழ்த்து முதல் குறள்",
                    "திருவள்ளுவர் எழுதிய முதல் குறள்",
                ]
            )

        if kural_num == 10:
            questions.extend(
                [
                    "பிறவிப் பெருங்கடல் என்ற குறள் என்ன?",
                    "பிறவிப் பெருங்கடல் குறள் சொல்லுங்க",
                ]
            )

        answer = f"""📖 திருக்குறள் - {kural_data['athikaram']} அதிகாரம், குறள் {kural_num}:

"{kural_data['line1']}
{kural_data['line2']}"

📜 பொருள்:
{kural_data['meaning']}

✍️ ஆசிரியர்: திருவள்ளுவர்
📚 பால்: {kural_data['paal']}
📑 இயல்: {kural_data['iyal']}
📖 அதிகாரம்: {kural_data['athikaram']}"""

        for q in questions:
            regenerated.append(
                {
                    "instruction": q,
                    "output": answer,
                    "language": "pure_tamil",
                    "pack": "vazhi_panpaadu",
                    "category": "thirukkural_authoritative",
                    "id": f"KURAL_AUTH_{kural_num}_{len(regenerated):03d}",
                }
            )

    # Generate 18 Siddhars Q&As
    siddhars_list = "\n".join(
        [
            f"{i+1}. {s['name']} ({s['english']}) - {s['specialty']}"
            for i, s in enumerate(SIDDHARS_AUTHORITATIVE)
        ]
    )

    siddhars_answer = f"""🙏 பதினெண் சித்தர்கள் (18 Siddhars):

சித்தர்கள் தமிழகத்தின் ஞானிகள், மருத்துவர்கள், யோகிகள். இவர்கள் சித்த மருத்துவம், யோகா, ரசவாதம், ஆன்மீகம் ஆகியவற்றில் சிறந்தவர்கள்.

📜 பதினெண் சித்தர் பட்டியல்:
{siddhars_list}

💡 சித்தர்களின் பங்களிப்பு:
• சித்த மருத்துவம் - பாரம்பரிய மருத்துவ முறை
• யோகா & பிராணாயாமம் - உடல் மற்றும் மன பயிற்சி
• ரசவாதம் - உலோக மருத்துவம்
• ஆன்மீக இலக்கியம் - பக்தி பாடல்கள், தத்துவ நூல்கள்"""

    siddhars_questions = [
        "18 சித்தர்கள் யார்?",
        "பதினெண் சித்தர்கள் பெயர் சொல்லுங்க",
        "சித்தர்கள் யார்? முக்கிய சித்தர்களின் பெயர்கள் சொல்லுங்கள்",
        "Tamil siddhars யார்?",
        "18 siddhars list in Tamil",
    ]

    for q in siddhars_questions:
        regenerated.append(
            {
                "instruction": q,
                "output": siddhars_answer,
                "language": "pure_tamil" if "Tamil" not in q else "tanglish",
                "pack": "vazhi_panpaadu",
                "category": "siddhars_authoritative",
                "id": f"SIDD_AUTH_{len(regenerated):03d}",
            }
        )

    # Save
    with open(culture_output, "w", encoding="utf-8") as f:
        json.dump(regenerated, f, ensure_ascii=False, indent=2)

    print(f"\nGenerated {len(regenerated)} authoritative Culture samples")
    print(f"Saved: {culture_output}")

    return regenerated


def validate_regenerated_sample(sample: dict) -> dict:
    """Validate a regenerated sample."""
    output = sample.get("output", "")

    # Calculate Tamil percentage
    tamil_chars = len(re.findall(r"[\u0B80-\u0BFF]", output))
    english_chars = len(re.findall(r"[a-zA-Z]", output))
    total = tamil_chars + english_chars
    tamil_pct = (tamil_chars / total * 100) if total > 0 else 0

    # Check for structure
    has_structure = bool(re.search(r"[•📍📚🔢📖📜💡✍️🏥⚖️🛕🙏]", output))

    # Check length
    is_adequate_length = len(output) >= 100

    return {
        "tamil_percentage": round(tamil_pct, 1),
        "has_structure": has_structure,
        "adequate_length": is_adequate_length,
        "valid": tamil_pct >= 50 and is_adequate_length,
    }


def run_audit_and_export():
    """Run full audit and export for regeneration."""

    # First run audit
    print("Step 1: Running audit...")
    import audit_data

    audit_data.audit_training_data()

    # Load regenerate samples
    print("\nStep 2: Loading samples that need regeneration...")
    regen_file = AUDIT_DIR / "regenerate_samples.json"
    with open(regen_file, "r", encoding="utf-8") as f:
        regen_samples = json.load(f)

    print(f"Samples needing regeneration: {len(regen_samples)}")

    # Export for manual regeneration
    print("\nStep 3: Exporting for manual regeneration...")
    export_for_manual_regeneration(regen_samples, "for_manual")

    # Generate authoritative Culture data
    print("\nStep 4: Generating authoritative Culture data...")
    regenerate_culture_pack()

    print("\n" + "=" * 60)
    print("EXPORT COMPLETE")
    print("=" * 60)
    print("\nNext steps:")
    print(f"1. Check {OUTPUT_DIR / 'for_manual'} for batch files")
    print("2. Use Claude.ai to regenerate each batch")
    print("3. Run validation after regeneration")


if __name__ == "__main__":
    print("VAZHI v0.4 - Data Regeneration Pipeline")
    print("=" * 60)
    run_audit_and_export()
