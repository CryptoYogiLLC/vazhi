#!/usr/bin/env python3
"""
Augment critical Culture pack entries with question variations.

The v0.2 model fails on Thirukkural because:
- Only 2 samples ask "திருக்குறளின் முதல் குறள்"
- 8 samples ask "[athikaram] அதிகாரத்தின் முதல் குறள்"
- Model confuses the pattern

Solution: Add multiple phrasings for critical Q&As.
"""

import json
from pathlib import Path

DATA_DIR = Path(__file__).parent.parent / "data"

# Critical Thirukkural augmentations
FIRST_KURAL_VARIATIONS = [
    # Question variations for first kural
    "திருக்குறளின் முதல் குறள் என்ன?",
    "திருக்குறளின் first குறள் சொல்லுங்கள்",
    "Thirukkural முதல் குறள் என்ன?",
    "திருக்குறள் first kural என்ன?",
    "அகர முதல குறள் சொல்லுங்க",
    "கடவுள் வாழ்த்து முதல் குறள் என்ன?",
    "திருவள்ளுவர் எழுதிய முதல் குறள்",
    "குறள் 1 என்ன?",
    "Kural number 1 சொல்லுங்க",
    "திருக்குறளின் ஆரம்ப குறள் என்ன?",
]

FIRST_KURAL_ANSWER = """முதல் குறள் (குறள் 1):

அகர முதல எழுத்தெல்லாம் ஆதி
பகவன் முதற்றே உலகு.

பொருள்: எழுத்துக்கள் எல்லாம் அகரத்தை முதலாகக் கொண்டவை. அதுபோல் உலகம் முழுவதும் இறைவனை முதலாகக் கொண்டது.

இது கடவுள் வாழ்த்து அதிகாரத்தின் முதல் குறள். திருவள்ளுவர் தமிழ் எழுத்துக்களின் முதல் எழுத்தான 'அ' (அகரம்) போல் இறைவன் எல்லாவற்றுக்கும் ஆதி என்று கூறுகிறார்."""

# Agathiyar variations
AGATHIYAR_VARIATIONS = [
    "அகத்தியர் யார்?",
    "Agathiyar பற்றி சொல்லுங்கள்",
    "அகத்திய முனிவர் யார்?",
    "Agasthya muni யார்?",
    "அகத்தியர் என்ன செய்தார்?",
]

AGATHIYAR_ANSWER = """அகத்தியர் (Agasthya) - தமிழின் தந்தை என்று போற்றப்படும் பண்டைய முனிவர்.

முக்கிய தகவல்கள்:
- 18 சித்தர்களில் முதன்மையானவர்
- தமிழ் இலக்கணம் "அகத்தியம்" எழுதியவர்
- சித்த மருத்துவத்தின் ஆதி குரு
- பொதிகை மலையில் வாழ்ந்தவர்
- வட இந்தியாவிலிருந்து தென்னிந்தியாவுக்கு தமிழை கொண்டு வந்தவர்

படைப்புகள்:
- அகத்தியம் (தமிழ் இலக்கணம்)
- அகத்தியர் வைத்தியம் (மருத்துவ நூல்)
- பரிபாஷை (ரசவாத நூல்)

தமிழ் கலாச்சாரத்தில் அகத்தியர் மிகவும் முக்கியமான இடத்தை பெற்றுள்ளார்."""

# 18 Siddhars variations
SIDDHARS_VARIATIONS = [
    "18 சித்தர்கள் யார்?",
    "பதினெண் சித்தர்கள் பெயர் சொல்லுங்க",
    "சித்தர்கள் யார்?",
    "Tamil siddhars யார்?",
    "முக்கிய சித்தர்களின் பெயர்கள்",
]

SIDDHARS_ANSWER = """பதினெண் சித்தர்கள் (18 Siddhars):

1. அகத்தியர் - சித்தர்களின் தலைவர்
2. திருமூலர் - திருமந்திரம் எழுதியவர்
3. போகர் - பழனி முருகன் சிலை செய்தவர்
4. புலிப்பாணி
5. இடைக்காடர்
6. காலங்கி நாதர்
7. கொங்கணவர்
8. கருவூரார்
9. நந்தீசர்
10. சட்டைமுனி
11. சுந்தரானந்தர்
12. பாம்பாட்டி சித்தர்
13. கோரக்கர்
14. குதம்பை சித்தர்
15. மச்சமுனி
16. பதஞ்சலி
17. ரோமரிஷி
18. தன்வந்திரி

இவர்கள் சித்த மருத்துவம், யோகா, ரசவாதம், ஆன்மீகம் ஆகியவற்றில் சிறந்தவர்கள். இவர்களின் பாடல்கள் தமிழில் உள்ளன."""


def create_augmented_data():
    """Create augmented culture data."""
    augmented = []

    # First Kural variations
    for i, q in enumerate(FIRST_KURAL_VARIATIONS):
        augmented.append({
            "instruction": q,
            "output": FIRST_KURAL_ANSWER,
            "language": "tanglish" if "first" in q.lower() or "kural" in q.lower() else "pure_tamil",
            "pack": "vazhi_panpaadu",
            "category": "thirukkural_critical",
            "id": f"CULT_AUG_KURAL1_{i:03d}"
        })

    # Agathiyar variations
    for i, q in enumerate(AGATHIYAR_VARIATIONS):
        augmented.append({
            "instruction": q,
            "output": AGATHIYAR_ANSWER,
            "language": "tanglish" if "agathiyar" in q.lower() or "agasthya" in q.lower() else "pure_tamil",
            "pack": "vazhi_panpaadu",
            "category": "siddhars_critical",
            "id": f"CULT_AUG_AGAT_{i:03d}"
        })

    # Siddhars variations
    for i, q in enumerate(SIDDHARS_VARIATIONS):
        augmented.append({
            "instruction": q,
            "output": SIDDHARS_ANSWER,
            "language": "tanglish" if "siddhar" in q.lower() else "pure_tamil",
            "pack": "vazhi_panpaadu",
            "category": "siddhars_critical",
            "id": f"CULT_AUG_SIDD_{i:03d}"
        })

    return augmented


def merge_with_training_data():
    """Merge augmented data with existing training data."""

    # Load existing v02 data
    with open(DATA_DIR / "vazhi_train_v02.json", "r", encoding="utf-8") as f:
        train_data = json.load(f)
    with open(DATA_DIR / "vazhi_val_v02.json", "r", encoding="utf-8") as f:
        val_data = json.load(f)

    print(f"Existing training samples: {len(train_data)}")
    print(f"Existing validation samples: {len(val_data)}")

    # Create augmented data
    augmented = create_augmented_data()
    print(f"Augmented samples created: {len(augmented)}")

    # Add to training data (all augmented goes to training)
    train_data.extend(augmented)

    # Save as v03
    with open(DATA_DIR / "vazhi_train_v03.json", "w", encoding="utf-8") as f:
        json.dump(train_data, f, ensure_ascii=False, indent=2)

    # Keep validation same
    with open(DATA_DIR / "vazhi_val_v03.json", "w", encoding="utf-8") as f:
        json.dump(val_data, f, ensure_ascii=False, indent=2)

    # Combined
    all_data = train_data + val_data
    with open(DATA_DIR / "vazhi_training_merged_v03.json", "w", encoding="utf-8") as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*50}")
    print(f"v0.3 DATA SUMMARY")
    print(f"{'='*50}")
    print(f"Training samples: {len(train_data)}")
    print(f"Validation samples: {len(val_data)}")
    print(f"Total: {len(all_data)}")
    print(f"\nAugmented entries:")
    print(f"  - First Kural variations: {len(FIRST_KURAL_VARIATIONS)}")
    print(f"  - Agathiyar variations: {len(AGATHIYAR_VARIATIONS)}")
    print(f"  - Siddhars variations: {len(SIDDHARS_VARIATIONS)}")
    print(f"\nFiles saved:")
    print(f"  - vazhi_train_v03.json")
    print(f"  - vazhi_val_v03.json")
    print(f"  - vazhi_training_merged_v03.json")


if __name__ == "__main__":
    print("VAZHI v0.3 - Culture Data Augmentation")
    print("=" * 50)
    merge_with_training_data()
