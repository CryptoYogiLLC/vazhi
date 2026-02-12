#!/usr/bin/env python3
"""
Heavy augmentation for Culture pack - repeat critical entries 10x.
This helps the model MEMORIZE specific factual content.
"""

import json
import random
from pathlib import Path

DATA_DIR = Path(__file__).parent.parent / "data"

# Critical Thirukkural - THE FIRST KURAL with many phrasings
FIRST_KURAL_QA = [
    ("திருக்குறளின் முதல் குறள் என்ன?", "pure_tamil"),
    ("திருக்குறளின் first குறள் சொல்லுங்கள்", "tanglish"),
    ("Thirukkural முதல் குறள் என்ன?", "tanglish"),
    ("திருக்குறள் first kural என்ன?", "tanglish"),
    ("அகர முதல குறள் சொல்லுங்க", "pure_tamil"),
    ("கடவுள் வாழ்த்து முதல் குறள் என்ன?", "pure_tamil"),
    ("திருவள்ளுவர் எழுதிய முதல் குறள்", "pure_tamil"),
    ("குறள் 1 என்ன?", "pure_tamil"),
    ("Kural number 1 சொல்லுங்க", "tanglish"),
    ("திருக்குறளின் ஆரம்ப குறள் என்ன?", "pure_tamil"),
    ("முதல் திருக்குறள் சொல்லுங்க", "pure_tamil"),
    ("Thiruvalluvar first kural", "tanglish"),
    ("அகர முதல எழுத்தெல்லாம் - இது எந்த குறள்?", "pure_tamil"),
    ("திருக்குறள் ஆரம்பம் என்ன?", "pure_tamil"),
    ("கடவுள் வாழ்த்து அதிகாரம் முதல் குறள்", "pure_tamil"),
]

FIRST_KURAL_ANSWER = """குறள் 1 (கடவுள் வாழ்த்து அதிகாரம்):

அகர முதல எழுத்தெல்லாம் ஆதி
பகவன் முதற்றே உலகு.

பொருள்: எழுத்துக்கள் எல்லாம் அகரத்தை (அ) முதலாகக் கொண்டவை. அதுபோல் உலகம் முழுவதும் ஆதிபகவனை (இறைவனை) முதலாகக் கொண்டது.

விளக்கம்: தமிழ் எழுத்துக்கள் 'அ' என்ற அகரத்தில் தொடங்குவது போல், இந்த உலகம் இறைவனால் தொடங்கியது என்று திருவள்ளுவர் கூறுகிறார்."""


# Famous Kural - கற்றதனால்
KATTRATHANAL_QA = [
    ("கற்றதனால் ஆய பயனென்கொல் என்ற குறள் முழுமையாக சொல்லுங்கள்", "pure_tamil"),
    ("கற்றதனால் ஆய பயன் என்ற குறள்", "pure_tamil"),
    ("கற்றதனால் ஆய பயனென்கொல் full kural", "tanglish"),
    ("Kattrathanal aaya payan kural", "tanglish"),
]

KATTRATHANAL_ANSWER = """குறள் 391 (கல்வி அதிகாரம்):

கற்றதனால் ஆய பயனென்கொல் வாலறிவன்
நற்றாள் தொழாஅர் எனின்.

பொருள்: தூய அறிவுடைய இறைவனின் திருவடிகளை வணங்காவிட்டால், ஒருவன் கற்ற கல்வியால் என்ன பயன்?

விளக்கம்: கல்வி கற்றாலும் இறைவனை வணங்கும் பணிவு வேண்டும் என்று வள்ளுவர் கூறுகிறார்."""


# Famous Kural - பிறவிப் பெருங்கடல்
PIRAVI_QA = [
    ("பிறவிப் பெருங்கடல் என்ற குறள் என்ன?", "pure_tamil"),
    ("பிறவிப் பெருங்கடல் குறள் சொல்லுங்க", "pure_tamil"),
    ("Piravi perunkadal kural", "tanglish"),
]

PIRAVI_ANSWER = """குறள் 10 (கடவுள் வாழ்த்து அதிகாரம்):

பிறவிப் பெருங்கடல் நீந்துவர் நீந்தார்
இறைவன் அடிசேரா தார்.

பொருள்: இறைவனின் திருவடிகளைச் சேர்ந்தவர்கள் பிறவி என்னும் பெரிய கடலை நீந்திக் கடப்பார்கள். சேராதவர்கள் நீந்த மாட்டார்கள்.

விளக்கம்: வாழ்க்கை என்னும் துன்பக் கடலை கடக்க இறைவன் அருள் தேவை என்று கூறுகிறார்."""


# 18 Siddhars
SIDDHARS_QA = [
    ("18 சித்தர்கள் யார்?", "pure_tamil"),
    ("பதினெண் சித்தர்கள் பெயர் சொல்லுங்க", "pure_tamil"),
    ("சித்தர்கள் யார்? முக்கிய சித்தர்களின் பெயர்கள் சொல்லுங்கள்", "pure_tamil"),
    ("Tamil siddhars யார்?", "tanglish"),
    ("18 siddhars list in Tamil", "tanglish"),
]

SIDDHARS_ANSWER = """பதினெண் சித்தர்கள் (18 Siddhars):

1. அகத்தியர் - சித்தர்களின் தலைவர், தமிழின் தந்தை
2. திருமூலர் - திருமந்திரம் எழுதியவர்
3. போகர் - பழனி முருகன் சிலை செய்தவர்
4. புலிப்பாணி - யோக சித்தர்
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

இவர்கள் சித்த மருத்துவம், யோகா, ரசவாதம், ஆன்மீகம் ஆகியவற்றில் சிறந்தவர்கள்."""


# Agathiyar
AGATHIYAR_QA = [
    ("அகத்தியர் யார்?", "pure_tamil"),
    ("அகத்தியர் பற்றி சொல்லுங்கள்", "pure_tamil"),
    ("Agathiyar பற்றி சொல்லுங்கள்", "tanglish"),
    ("அகத்திய முனிவர் யார்?", "pure_tamil"),
]

AGATHIYAR_ANSWER = """அகத்தியர் (Agasthya) - தமிழின் தந்தை என்று போற்றப்படும் பண்டைய முனிவர்.

முக்கிய தகவல்கள்:
• 18 சித்தர்களில் முதன்மையானவர்
• தமிழ் இலக்கணம் "அகத்தியம்" எழுதியவர்
• சித்த மருத்துவத்தின் ஆதி குரு
• பொதிகை மலையில் வாழ்ந்தவர்

படைப்புகள்:
• அகத்தியம் (தமிழ் இலக்கணம்)
• அகத்தியர் வைத்தியம் (மருத்துவ நூல்)

தமிழ் கலாச்சாரத்தில் அகத்தியர் மிகவும் முக்கியமான இடத்தை பெற்றுள்ளார்."""


# Siddha Medicine
SIDDHA_QA = [
    ("சித்த மருத்துவம் என்றால் என்ன?", "pure_tamil"),
    ("Siddha medicine என்ன?", "tanglish"),
    ("சித்த மருத்துவம் பற்றி சொல்லுங்க", "pure_tamil"),
]

SIDDHA_ANSWER = """சித்த மருத்துவம் - தமிழகத்தின் பாரம்பரிய மருத்துவ முறை.

அடிப்படை கொள்கைகள்:
• வாதம், பித்தம், கபம் - மூன்று தோஷங்கள்
• உடல், மனம், ஆன்மா - மூன்றும் சமநிலையில் இருக்க வேண்டும்
• 96 தத்துவங்கள் அடிப்படையாகக் கொண்டது

சிகிச்சை முறைகள்:
• மூலிகை மருந்துகள்
• உலோக பஸ்மங்கள்
• யோகா, பிராணாயாமம்
• உணவு முறை மாற்றம்

நிறுவனர்: அகத்தியர் மற்றும் 18 சித்தர்கள்

இன்றும் தமிழ்நாட்டில் சித்த மருத்துவ கல்லூரிகள் மற்றும் மருத்துவமனைகள் உள்ளன."""


def create_heavy_augmented_data():
    """Create heavily augmented data with 5x repetition."""
    augmented = []
    REPETITIONS = 5  # Repeat each Q&A 5 times

    all_qa_sets = [
        (FIRST_KURAL_QA, FIRST_KURAL_ANSWER, "thirukkural_first"),
        (KATTRATHANAL_QA, KATTRATHANAL_ANSWER, "thirukkural_famous"),
        (PIRAVI_QA, PIRAVI_ANSWER, "thirukkural_famous"),
        (SIDDHARS_QA, SIDDHARS_ANSWER, "siddhars"),
        (AGATHIYAR_QA, AGATHIYAR_ANSWER, "siddhars"),
        (SIDDHA_QA, SIDDHA_ANSWER, "siddha_medicine"),
    ]

    idx = 0
    for qa_list, answer, category in all_qa_sets:
        for rep in range(REPETITIONS):
            for question, lang in qa_list:
                augmented.append(
                    {
                        "instruction": question,
                        "output": answer,
                        "language": lang,
                        "pack": "vazhi_panpaadu",
                        "category": category,
                        "id": f"CULT_HEAVY_{idx:04d}",
                    }
                )
                idx += 1

    return augmented


def merge_heavy():
    """Create v0.3 with heavy augmentation."""

    # Load existing v02 data
    with open(DATA_DIR / "vazhi_train_v02.json", "r", encoding="utf-8") as f:
        train_data = json.load(f)
    with open(DATA_DIR / "vazhi_val_v02.json", "r", encoding="utf-8") as f:
        val_data = json.load(f)

    print(f"Existing training samples: {len(train_data)}")

    # Create heavy augmented data
    augmented = create_heavy_augmented_data()
    print(f"Heavy augmented samples: {len(augmented)}")

    # Add to training
    train_data.extend(augmented)

    # Shuffle
    random.seed(42)
    random.shuffle(train_data)

    # Save
    with open(DATA_DIR / "vazhi_train_v03.json", "w", encoding="utf-8") as f:
        json.dump(train_data, f, ensure_ascii=False, indent=2)

    with open(DATA_DIR / "vazhi_val_v03.json", "w", encoding="utf-8") as f:
        json.dump(val_data, f, ensure_ascii=False, indent=2)

    all_data = train_data + val_data
    with open(DATA_DIR / "vazhi_training_merged_v03.json", "w", encoding="utf-8") as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*50}")
    print("v0.3 HEAVY AUGMENTATION SUMMARY")
    print(f"{'='*50}")
    print(f"Training samples: {len(train_data)}")
    print(f"Validation samples: {len(val_data)}")
    print(f"Total: {len(all_data)}")
    print("\nCritical entries now repeated 5x each:")
    print(
        f"  - First Kural: {len(FIRST_KURAL_QA)} questions × 5 = {len(FIRST_KURAL_QA)*5}"
    )
    print(
        f"  - கற்றதனால்: {len(KATTRATHANAL_QA)} questions × 5 = {len(KATTRATHANAL_QA)*5}"
    )
    print(f"  - பிறவிப்: {len(PIRAVI_QA)} questions × 5 = {len(PIRAVI_QA)*5}")
    print(f"  - Siddhars: {len(SIDDHARS_QA)} questions × 5 = {len(SIDDHARS_QA)*5}")
    print(f"  - Agathiyar: {len(AGATHIYAR_QA)} questions × 5 = {len(AGATHIYAR_QA)*5}")
    print(f"  - Siddha Med: {len(SIDDHA_QA)} questions × 5 = {len(SIDDHA_QA)*5}")


if __name__ == "__main__":
    print("VAZHI v0.3 - Heavy Culture Augmentation")
    print("=" * 50)
    merge_heavy()
