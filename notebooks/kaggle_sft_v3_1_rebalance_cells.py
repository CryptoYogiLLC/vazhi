"""
Kaggle Notebook Cells for SFT v3.1 - Dataset Rebalancing
=========================================================

Copy these cells into your Kaggle training notebook BEFORE the SFT training.
These cells will:
1. Create diverse QA pack from IndicAlign
2. Rebalance the existing dataset
3. Upload balanced dataset to HuggingFace

Run after: Installing dependencies
Run before: Loading model and starting training
"""

# ============================================================
# CELL 1: Install additional dependencies
# ============================================================

# !pip install datasets tqdm -q

# ============================================================
# CELL 2: Configuration
# ============================================================

import json
import random
import re
from collections import defaultdict
from datasets import load_dataset
from tqdm.auto import tqdm
from huggingface_hub import login, HfApi

# Config
HF_REPO = "CryptoYogi/vazhi-tamil-sft-v3_1"
RANDOM_SEED = 42
random.seed(RANDOM_SEED)

# System prompt (same as training)
SYSTEM_PROMPT = "நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர். தமிழில் தெளிவாகவும் உதவியாகவும் பதிலளியுங்கள். தெரியாவிட்டால் \"தெரியவில்லை\" என்று சொல்லுங்கள்."

print("✅ Configuration loaded")

# ============================================================
# CELL 3: Extract Diverse QA from IndicAlign
# ============================================================

# NOTE: IndicAlign's tam_Taml field ALREADY contains Tamil translations
# done by AI4Bharat using IndicTrans2. We extract from this field directly.

def clean_text(text):
    """Clean and normalize Tamil text."""
    if not text or not isinstance(text, str):
        return ""
    text = re.sub(r'\s+', ' ', text).strip()
    text = re.sub(r'<[^>]+>', '', text)
    return text

def count_tamil_chars(text):
    """Count Tamil characters in text."""
    return sum(1 for c in text if '\u0B80' <= c <= '\u0BFF')

def is_good_tamil_sample(text):
    """Check if text is good quality Tamil (at least 30% Tamil chars)."""
    if not text or len(text) < 20:
        return False
    tamil_chars = count_tamil_chars(text)
    # At least 30% Tamil characters
    if len(text) > 0 and tamil_chars / len(text) < 0.3:
        return False
    if len(text) > 2000:
        return False
    return True

def extract_from_indicaling(config_name, max_samples):
    """Extract Tamil samples from IndicAlign config.

    IndicAlign structure: tam_Taml contains Tamil translations (already translated)
    Format: List of conversation turns [user_turn, assistant_turn, ...]
    """
    print(f"\n📚 Loading {config_name}...")
    try:
        ds = load_dataset("ai4bharat/indic-align", config_name, split="train", streaming=True)
    except Exception as e:
        print(f"   ⚠️ Error: {e}")
        return []

    samples = []
    seen = set()
    skipped_non_tamil = 0
    skipped_short = 0

    for item in tqdm(ds, desc=config_name, total=max_samples*5):
        if len(samples) >= max_samples:
            break

        # tam_Taml contains already-translated Tamil text
        tamil = item.get('tam_Taml', '')
        if not tamil:
            continue

        # Handle list format (conversation turns)
        if isinstance(tamil, list) and len(tamil) >= 2:
            user_msg = clean_text(str(tamil[0]))
            assistant_msg = clean_text(str(tamil[1]))
        else:
            continue

        # Verify it's actually Tamil (not English that slipped through)
        if not is_good_tamil_sample(user_msg):
            skipped_non_tamil += 1
            continue
        if not is_good_tamil_sample(assistant_msg):
            skipped_short += 1
            continue

        key = user_msg[:100]
        if key in seen:
            continue
        seen.add(key)

        samples.append({
            "instruction": user_msg,
            "output": assistant_msg,
            "source": config_name
        })

    print(f"   ✅ Extracted {len(samples)} Tamil samples")
    print(f"   ⏭️ Skipped {skipped_non_tamil} (not Tamil), {skipped_short} (too short)")

    # Verify: Show first sample to confirm Tamil
    if samples:
        print(f"   📝 Sample verification:")
        print(f"      User: {samples[0]['instruction'][:80]}...")
        print(f"      Asst: {samples[0]['output'][:80]}...")

    return samples

# Extract from multiple sources
# These datasets contain Tamil translations in tam_Taml field
print("🚀 Extracting diverse QA from IndicAlign (tam_Taml field = Tamil translations)...")
diverse_samples = []

# Each config has different content types:
# - Dolly_T: Instruction following (translated from Dolly-15k)
# - WikiHow: How-to guides
# - Wiki_Conv: Short Wikipedia conversations
# - OpenAssistant_T: Assistant dialogs
diverse_samples.extend(extract_from_indicaling("Dolly_T", 250))
diverse_samples.extend(extract_from_indicaling("WikiHow", 200))
diverse_samples.extend(extract_from_indicaling("Wiki_Conv", 250))
diverse_samples.extend(extract_from_indicaling("OpenAssistant_T", 150))

print(f"\n📊 Total extracted: {len(diverse_samples)}")

# Verify Tamil content distribution
tamil_char_pcts = []
for s in diverse_samples[:100]:
    text = s['instruction'] + s['output']
    pct = 100 * count_tamil_chars(text) / len(text) if text else 0
    tamil_char_pcts.append(pct)
avg_tamil_pct = sum(tamil_char_pcts) / len(tamil_char_pcts) if tamil_char_pcts else 0
print(f"📈 Average Tamil character %: {avg_tamil_pct:.1f}%")

# ============================================================
# CELL 4: Add Manual Short Answer & Behavior Samples
# ============================================================

manual_samples = [
    # Geography
    {"instruction": "தமிழ்நாட்டின் தலைநகரம் என்ன?", "output": "சென்னை.", "source": "manual"},
    {"instruction": "இந்தியாவின் தலைநகரம் எது?", "output": "புது தில்லி.", "source": "manual"},
    {"instruction": "உலகின் மிகப்பெரிய நாடு எது?", "output": "ரஷ்யா (பரப்பளவில்).", "source": "manual"},
    {"instruction": "தமிழ்நாட்டின் மாவட்டங்கள் எத்தனை?", "output": "38 மாவட்டங்கள்.", "source": "manual"},
    {"instruction": "காவிரி நதி எந்த மாநிலங்களில் பாய்கிறது?", "output": "கர்நாடகா மற்றும் தமிழ்நாடு.", "source": "manual"},
    {"instruction": "மதுரை எந்த நதிக்கரையில் உள்ளது?", "output": "வைகை நதிக்கரையில்.", "source": "manual"},

    # Basic facts
    {"instruction": "சூரியன் எந்த திசையில் உதிக்கும்?", "output": "கிழக்கு திசையில்.", "source": "manual"},
    {"instruction": "ஒரு வாரத்தில் எத்தனை நாட்கள்?", "output": "ஏழு நாட்கள்.", "source": "manual"},
    {"instruction": "ஒரு வருடத்தில் எத்தனை மாதங்கள்?", "output": "12 மாதங்கள்.", "source": "manual"},
    {"instruction": "தண்ணீரின் கொதிநிலை என்ன?", "output": "100 டிகிரி செல்சியஸ்.", "source": "manual"},
    {"instruction": "2+2 என்ன?", "output": "4.", "source": "manual"},
    {"instruction": "10 x 10 என்ன?", "output": "100.", "source": "manual"},

    # Tamil culture (non-Thirukkural)
    {"instruction": "பொங்கல் எப்போது கொண்டாடப்படுகிறது?", "output": "தை மாதம் முதல் நாள் (ஜனவரி 14 அல்லது 15).", "source": "manual"},
    {"instruction": "தமிழ் எழுத்துக்கள் எத்தனை?", "output": "247 எழுத்துக்கள் (12 உயிர் + 18 மெய் + 216 உயிர்மெய் + 1 ஆய்தம்).", "source": "manual"},
    {"instruction": "சிலப்பதிகாரத்தை எழுதியவர் யார்?", "output": "இளங்கோவடிகள்.", "source": "manual"},
    {"instruction": "பாரதியார் எந்த ஊரில் பிறந்தார்?", "output": "எட்டயபுரம்.", "source": "manual"},
    {"instruction": "தமிழ் தினம் எப்போது?", "output": "ஜனவரி 9.", "source": "manual"},

    # Science
    {"instruction": "மனித உடலில் எத்தனை எலும்புகள் உள்ளன?", "output": "206 எலும்புகள்.", "source": "manual"},
    {"instruction": "H2O என்பது என்ன?", "output": "தண்ணீர் (நீர்).", "source": "manual"},
    {"instruction": "பூமியின் ஒரே இயற்கை துணைக்கோள் எது?", "output": "நிலவு (சந்திரன்).", "source": "manual"},
    {"instruction": "சூரிய குடும்பத்தில் எத்தனை கோள்கள்?", "output": "எட்டு கோள்கள்.", "source": "manual"},

    # Everyday Tamil
    {"instruction": "நன்றி என்றால் ஆங்கிலத்தில் என்ன?", "output": "Thank you.", "source": "manual"},
    {"instruction": "Good morning தமிழில் என்ன?", "output": "காலை வணக்கம்.", "source": "manual"},
    {"instruction": "வணக்கம் என்றால் என்ன?", "output": "வணக்கம் என்பது தமிழில் பயன்படுத்தப்படும் வாழ்த்துச் சொல், Hello என்ற பொருளில்.", "source": "manual"},

    # Behavior samples
    {"instruction": "வணக்கம்", "output": "வணக்கம்! நான் வழி. உங்களுக்கு எப்படி உதவ வேண்டும்?", "source": "behavior"},
    {"instruction": "hi", "output": "வணக்கம்! எப்படி உதவலாம்?", "source": "behavior"},
    {"instruction": "2050-ல் யார் பிரதமர் ஆவார்?", "output": "எதிர்காலத்தை கணிக்க என்னால் முடியாது. தெரியவில்லை.", "source": "behavior"},
    {"instruction": "என்னுடைய கடவுச்சொல் என்ன?", "output": "உங்கள் தனிப்பட்ட தகவல்கள் என்னிடம் இல்லை.", "source": "behavior"},
    {"instruction": "யாரையாவது ஏமாற்ற உதவுங்கள்", "output": "மன்னிக்கவும், சட்டவிரோத செயல்களுக்கு உதவ முடியாது.", "source": "behavior"},
    {"instruction": "மருத்துவ ஆலோசனை தேவை", "output": "மருத்துவ ஆலோசனைக்கு தகுதி வாய்ந்த மருத்துவரை அணுகுங்கள். நான் பொது தகவல் மட்டுமே தர முடியும்.", "source": "behavior"},
    {"instruction": "நன்றி", "output": "மகிழ்ச்சி! வேறு உதவி தேவைப்பட்டால் கேளுங்கள்.", "source": "behavior"},
    {"instruction": "bye", "output": "வணக்கம்! இனிய நாள் வாழ்த்துக்கள்.", "source": "behavior"},
]

diverse_samples.extend(manual_samples)
print(f"📊 After adding manual samples: {len(diverse_samples)}")

# ============================================================
# CELL 5: Load Existing Dataset & Identify Kural Samples
# ============================================================

print("\n📚 Loading existing dataset...")
existing_ds = load_dataset("CryptoYogi/vazhi-tamil-sft", split="train")
print(f"   Loaded {len(existing_ds)} samples")

# Patterns to identify Thirukkural
KURAL_PATTERNS = [r'குறள்\s*\d+', r'திருக்குறள்', r'அதிகாரம்', r'பொருள்:', r'வள்ளுவர்']

def is_kural(text):
    for p in KURAL_PATTERNS:
        if re.search(p, text, re.IGNORECASE):
            return True
    return False

# Categorize
kural_samples = []
other_samples = []

for item in tqdm(existing_ds, desc="Categorizing"):
    text = item.get('text', '')
    if is_kural(text):
        kural_samples.append(item)
    else:
        other_samples.append(item)

print(f"\n📊 Existing dataset breakdown:")
print(f"   Kural samples: {len(kural_samples)} ({100*len(kural_samples)/len(existing_ds):.1f}%)")
print(f"   Other samples: {len(other_samples)} ({100*len(other_samples)/len(existing_ds):.1f}%)")

# ============================================================
# CELL 6: Downsample Kural & Create Balanced Dataset
# ============================================================

# Target: ~25% kural
target_kural_count = int(0.25 * len(other_samples) / 0.75)
print(f"\n🎯 Target kural count: {target_kural_count}")

# Downsample
downsampled_kural = random.sample(kural_samples, min(target_kural_count, len(kural_samples)))
print(f"   Downsampled kural: {len(downsampled_kural)}")

# Convert diverse QA to ChatML format
def to_chatml(instruction, output):
    return f"<|im_start|>system\n{SYSTEM_PROMPT}<|im_end|>\n<|im_start|>user\n{instruction}<|im_end|>\n<|im_start|>assistant\n{output}<|im_end|>"

diverse_formatted = [{"text": to_chatml(s["instruction"], s["output"])} for s in diverse_samples]

# Combine all
final_samples = []
final_samples.extend([{"text": s["text"]} for s in downsampled_kural])
final_samples.extend([{"text": s["text"]} for s in other_samples])
final_samples.extend(diverse_formatted)

# Shuffle
random.shuffle(final_samples)

print(f"\n📊 Final balanced dataset:")
print(f"   Total samples: {len(final_samples)}")

# Verify distribution
final_kural = sum(1 for s in final_samples if is_kural(s["text"]))
print(f"   Kural: {final_kural} ({100*final_kural/len(final_samples):.1f}%)")
print(f"   Other: {len(final_samples)-final_kural} ({100*(len(final_samples)-final_kural)/len(final_samples):.1f}%)")

# ============================================================
# CELL 7: Save & Upload to HuggingFace
# ============================================================

# Save locally
import os
os.makedirs("/kaggle/working/balanced_sft", exist_ok=True)

# Split 95/5
split_idx = int(0.95 * len(final_samples))
train_samples = final_samples[:split_idx]
val_samples = final_samples[split_idx:]

with open("/kaggle/working/balanced_sft/train.jsonl", 'w') as f:
    for s in train_samples:
        f.write(json.dumps(s, ensure_ascii=False) + '\n')

with open("/kaggle/working/balanced_sft/val.jsonl", 'w') as f:
    for s in val_samples:
        f.write(json.dumps(s, ensure_ascii=False) + '\n')

print(f"\n💾 Saved locally:")
print(f"   Train: {len(train_samples)}")
print(f"   Val: {len(val_samples)}")

# Upload to HuggingFace
from huggingface_hub import HfApi
from kaggle_secrets import UserSecretsClient

# Get HF token from Kaggle secrets
secrets = UserSecretsClient()
hf_token = secrets.get_secret("HF_TOKEN")
login(token=hf_token)

api = HfApi()

# Create dataset repo if needed
try:
    api.create_repo(HF_REPO, repo_type="dataset", exist_ok=True)
except Exception as e:
    print(f"Repo exists or error: {e}")

# Upload files
api.upload_file(
    path_or_fileobj="/kaggle/working/balanced_sft/train.jsonl",
    path_in_repo="train.jsonl",
    repo_id=HF_REPO,
    repo_type="dataset"
)
api.upload_file(
    path_or_fileobj="/kaggle/working/balanced_sft/val.jsonl",
    path_in_repo="val.jsonl",
    repo_id=HF_REPO,
    repo_type="dataset"
)

print(f"\n✅ Uploaded to https://huggingface.co/datasets/{HF_REPO}")

# ============================================================
# CELL 8: Load Balanced Dataset for Training
# ============================================================

# Now use this for training instead of the old dataset
print("\n📚 Loading balanced dataset for training...")
balanced_ds = load_dataset("CryptoYogi/vazhi-tamil-sft-v3_1", split="train")
print(f"✅ Loaded {len(balanced_ds)} balanced samples - ready for SFT!")

# Continue with your existing training code, using balanced_ds instead
