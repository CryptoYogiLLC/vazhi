# VAZHI Sprint Plan - REVISED (February 2026)

## Progress Summary

### COMPLETED: Data Collection Phase ✅

**Original Goal**: 500-1000 Tamil Q&A pairs + 50 security examples

**Actual Achievement**: 2,147 bilingual training pairs across 4 domain packs

| Pack | Tamil Name | Version | Training Pairs | Categories |
|------|-----------|---------|----------------|------------|
| Security | வழி காவல் | v0.8.0 | 468 | Scams, cyber safety, police, women's safety |
| Government | வழி அரசு | v0.6.0 | 467 | Schemes, certificates, e-Sevai, pensions |
| Education | வழி கல்வி | v0.5.0 | 602 | Admissions, scholarships, exams, careers |
| Legal | வழி சட்டம் | v1.0.0 | 610 | Tenant rights, consumer, RTI, family law |

**Data Quality**: Each entry has both `pure_tamil` and `tanglish` variants with `parallel_id` linking for bilingual training.

---

## REVISED 2-Week Sprint Plan

### Prerequisites (Already Done)
- [x] GitHub account & repo created
- [x] Python environment available
- [x] Training data collected (2,147+ pairs)
- [x] Pack structure defined

---

## WEEK 1: Base Model + First Pack Training

### Day 1: Environment Setup + Base Model Inference ✅ COMPLETE
**Goal**: Validate Qwen 2.5 3B's Tamil capabilities

**Status**: DONE - See `01_vazhi_first_inference.ipynb` in Google Colab
- [x] Colab environment with T4 GPU
- [x] Qwen/Qwen2.5-3B-Instruct loaded (6.17GB)
- [x] Tamil greeting test passed
- [x] Tamil knowledge question test passed
- [x] Tamil story generation test passed

**Baseline Observations**:
- Model understands Tamil well out-of-the-box
- Responds naturally to conversational Tamil
- Good factual knowledge about Tamil Nadu

**Original Plan**:

**Morning (2-3 hours)**:
```python
# On Colab (A100 recommended) or local GPU
!pip install transformers accelerate bitsandbytes

from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

model_name = "Qwen/Qwen2.5-3B-Instruct"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    torch_dtype=torch.float16,
    device_map="auto"
)

# Test Tamil from our training data categories
test_prompts = [
    "வணக்கம்! தமிழில் பேசலாமா?",
    "இது மோசடி செய்தியா: 'நீங்கள் 50 லட்சம் வென்றீர்கள்'",
    "RTI என்றால் என்ன?",
    "12th படிச்சாச்சு, engineering-க்கு என்ன options?",
]

for prompt in test_prompts:
    inputs = tokenizer(prompt, return_tensors="pt").to("cuda")
    outputs = model.generate(**inputs, max_new_tokens=150)
    print(f"Q: {prompt}")
    print(f"A: {tokenizer.decode(outputs[0], skip_special_tokens=True)}")
    print("---")
```

**Afternoon (2 hours)**:
- Test 20 prompts from each of our 4 packs
- Document baseline Tamil quality (before fine-tuning)
- Note specific failure patterns

**Deliverable**: Baseline evaluation document, working Colab environment

---

### Day 2: Merge Training Data + Format Conversion ✅ COMPLETE
**Goal**: Prepare unified training dataset in SFT format

**Status**: DONE
- [x] Created vazhi_panpaadu (Culture) pack - 400 pairs
- [x] Merged all 6 packs into SFT format
- [x] Created train/val split (90/10)

**Output Files**:
- `data/vazhi_training_merged.json` - 3,007 pairs
- `data/vazhi_train.json` - 2,706 pairs
- `data/vazhi_val.json` - 301 pairs

**Original Plan**:

```python
import json
from pathlib import Path

def convert_pack_to_sft(pack_path: str) -> list:
    """Convert pack format to instruction-output pairs"""
    with open(pack_path) as f:
        data = json.load(f)

    pairs = []
    for category in data.get("categories", []):
        for pair in category.get("pairs", []):
            pairs.append({
                "instruction": pair["question"],
                "output": pair["answer"],
                "language": pair["language"],
                "pack": data["pack_name"],
                "category": category["category"]
            })
    return pairs

# Merge all packs
all_pairs = []
for pack in ["security", "govt", "education", "legal"]:
    pack_path = f"vazhi-packs/{pack}/training_data.json"
    all_pairs.extend(convert_pack_to_sft(pack_path))

print(f"Total training pairs: {len(all_pairs)}")

# Save merged dataset
with open("data/vazhi_training_merged.json", "w") as f:
    json.dump(all_pairs, f, ensure_ascii=False, indent=2)

# Create train/validation split (90/10)
import random
random.shuffle(all_pairs)
split_idx = int(len(all_pairs) * 0.9)
train_data = all_pairs[:split_idx]
val_data = all_pairs[split_idx:]

with open("data/vazhi_train.json", "w") as f:
    json.dump(train_data, f, ensure_ascii=False, indent=2)

with open("data/vazhi_val.json", "w") as f:
    json.dump(val_data, f, ensure_ascii=False, indent=2)
```

**Deliverable**:
- `data/vazhi_train.json` (~1,930 pairs)
- `data/vazhi_val.json` (~215 pairs)

---

### Day 3: LoRA Fine-tuning Setup with Unsloth 👈 CURRENT
**Goal**: Configure training environment for Tamil LLM

```python
!pip install unsloth
from unsloth import FastLanguageModel

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="Qwen/Qwen2.5-3B-Instruct",
    max_seq_length=2048,
    load_in_4bit=True,
)

# Add LoRA adapters for Tamil fine-tuning
model = FastLanguageModel.get_peft_model(
    model,
    r=16,  # LoRA rank
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    lora_alpha=16,
    lora_dropout=0,
    bias="none",
    use_gradient_checkpointing="unsloth",
)

# Define Tamil chat template
tamil_template = """<|im_start|>system
நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான உதவியாளர். தமிழில் தெளிவாகவும் உதவியாகவும் பதிலளியுங்கள்.
<|im_end|>
<|im_start|>user
{instruction}<|im_end|>
<|im_start|>assistant
{output}<|im_end|>"""

def format_prompt(example):
    return tamil_template.format(
        instruction=example["instruction"],
        output=example["output"]
    )
```

**Deliverable**: Training configuration ready, template tested

---

### Day 4: Train Base Tamil LoRA
**Goal**: Fine-tune base model on ALL training data

```python
from datasets import load_dataset
from trl import SFTTrainer
from transformers import TrainingArguments

# Load merged dataset
dataset = load_dataset("json", data_files={
    "train": "data/vazhi_train.json",
    "validation": "data/vazhi_val.json"
})

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset["train"],
    eval_dataset=dataset["validation"],
    formatting_func=format_prompt,
    max_seq_length=2048,
    args=TrainingArguments(
        per_device_train_batch_size=2,
        gradient_accumulation_steps=4,
        warmup_steps=50,
        num_train_epochs=3,  # Full 3 epochs
        learning_rate=2e-4,
        fp16=True,
        logging_steps=10,
        eval_steps=100,
        save_steps=200,
        output_dir="outputs/vazhi-base",
        save_total_limit=3,
    ),
)

trainer.train()

# Save base LoRA adapter
model.save_pretrained("outputs/vazhi-base-lora")
tokenizer.save_pretrained("outputs/vazhi-base-lora")
```

**Training Time**: ~3-4 hours on Colab A100 (2,147 pairs × 3 epochs)

**Deliverable**: `vazhi-base-lora` adapter (~100-150MB)

---

### Day 5: Evaluate Base Model
**Goal**: Measure improvement over baseline

```python
def evaluate_model(model, tokenizer, test_cases):
    """Evaluate model on domain-specific test cases"""
    results = []
    for test in test_cases:
        prompt = tamil_template.format(instruction=test["question"], output="")
        inputs = tokenizer(prompt, return_tensors="pt").to("cuda")
        outputs = model.generate(
            **inputs,
            max_new_tokens=200,
            temperature=0.7,
            do_sample=True,
        )
        response = tokenizer.decode(outputs[0], skip_special_tokens=True)
        results.append({
            "question": test["question"],
            "expected": test["expected_keywords"],
            "response": response,
            "domain": test["domain"]
        })
    return results

# Test cases from each domain
test_cases = [
    # Security
    {"question": "இது மோசடியா: 'உங்கள் ATM card block ஆகும், 1800 call பண்ணுங்க'",
     "expected_keywords": ["மோசடி", "வங்கி", "call பண்ணாதீர்கள்"],
     "domain": "security"},
    # Government
    {"question": "Senior citizen pension எப்படி apply பண்றது?",
     "expected_keywords": ["Tahsildar", "age proof", "bank account"],
     "domain": "govt"},
    # Education
    {"question": "NEET exam-க்கு எப்படி prepare பண்றது?",
     "expected_keywords": ["NCERT", "physics", "chemistry", "biology"],
     "domain": "education"},
    # Legal
    {"question": "RTI application எப்படி எழுதுவது?",
     "expected_keywords": ["PIO", "Rs.10", "30 days"],
     "domain": "legal"},
]

results = evaluate_model(model, tokenizer, test_cases)
```

**Tasks**:
- Run 40 test prompts (10 per domain)
- Calculate keyword hit rate per domain
- Compare with Day 1 baseline
- Document improvements and remaining gaps

**Deliverable**: Evaluation report, identified weak areas

---

### Day 6: Quantize for Mobile
**Goal**: Create mobile-ready GGUF file

```bash
# Clone llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp && make

# First merge LoRA with base model
python merge_lora.py \
    --base-model Qwen/Qwen2.5-3B-Instruct \
    --lora-path outputs/vazhi-base-lora \
    --output-path outputs/vazhi-base-merged

# Convert to GGUF
python llama.cpp/convert-hf-to-gguf.py \
    outputs/vazhi-base-merged \
    --outfile models/vazhi-base.gguf

# Quantize to 4-bit
./llama.cpp/llama-quantize \
    models/vazhi-base.gguf \
    models/vazhi-base-q4_k_m.gguf \
    q4_k_m
```

**Test quantized model**:
```bash
./llama.cpp/llama-cli \
    -m models/vazhi-base-q4_k_m.gguf \
    -p "<|im_start|>user\nRTI என்றால் என்ன?<|im_end|>\n<|im_start|>assistant\n" \
    -n 150
```

**Result**: ~1.7GB file that runs on phones

**Deliverable**: `vazhi-base-q4_k_m.gguf` ready for mobile

---

### Day 7: Week 1 Review + Domain Pack Strategy
**Goal**: Assess and plan specialized packs

**Review**:
- [x] Base Tamil LLM trained on 2,147 pairs
- [x] Quantized model for mobile
- [x] Evaluation completed

**Decision Point**: Domain-specific LoRA packs

Option A: **Single merged model** (current approach)
- Pros: Simpler deployment, one download
- Cons: Larger file, all-or-nothing

Option B: **Base + Stackable LoRA packs**
- Pros: Modular downloads, smaller base
- Cons: More complex runtime

**Recommendation**: Start with Option A for MVP, plan Option B for Phase 2

---

## WEEK 2: Mobile App + Demo

### Day 8: Mobile Framework Setup
**Goal**: Initialize React Native app with llama.rn

```bash
npx react-native init VazhiApp --template react-native-template-typescript
cd VazhiApp

# Install dependencies
npm install llama.rn react-native-fs
npm install @react-navigation/native @react-navigation/bottom-tabs
npm install react-native-safe-area-context react-native-screens

# For iOS
cd ios && pod install && cd ..
```

**Deliverable**: App skeleton that builds and runs on Android/iOS

---

### Day 9: Integrate LLM into App
**Goal**: Basic chat functionality

```typescript
// src/services/LlamaService.ts
import { initLlama, LlamaContext } from 'llama.rn';
import RNFS from 'react-native-fs';

class LlamaService {
  private context: LlamaContext | null = null;

  async initialize(modelPath: string) {
    this.context = await initLlama({
      model: modelPath,
      n_ctx: 2048,
      n_threads: 4,
    });
  }

  async chat(userMessage: string): Promise<string> {
    if (!this.context) throw new Error('Model not loaded');

    const prompt = `<|im_start|>system
நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான உதவியாளர்.
<|im_end|>
<|im_start|>user
${userMessage}<|im_end|>
<|im_start|>assistant
`;

    const response = await this.context.completion({
      prompt,
      n_predict: 200,
      stop: ['<|im_end|>', '<|im_start|>'],
      temperature: 0.7,
    });

    return response.text.trim();
  }
}

export default new LlamaService();
```

**Deliverable**: App can load model and respond to Tamil queries

---

### Day 10: Chat UI Implementation
**Goal**: Tamil-friendly chat interface

```
┌─────────────────────────────────┐
│  வழி - Tamil AI உதவியாளர்       │
├─────────────────────────────────┤
│                                 │
│  👤 RTI எப்படி போடுவது?          │
│                                 │
│  🤖 RTI போட Rs.10 செலுத்தி      │
│     PIO-க்கு விண்ணப்பிக்கவும்.   │
│     30 நாட்களில் பதில் வரும்.    │
│                                 │
│  👤 மோசடி message-ஐ எப்படி      │
│     கண்டுபிடிப்பது?              │
│                                 │
│  🤖 சில அறிகுறிகள்:              │
│     • "உடனே" என்று அவசரம்        │
│     • OTP/password கேட்பது      │
│     • Unknown number/link       │
│                                 │
├─────────────────────────────────┤
│ 🛡️காவல் 🏛️அரசு 📚கல்வி ⚖️சட்டம் │
├─────────────────────────────────┤
│  [உங்கள் கேள்வி...    ] [அனுப்பு]│
└─────────────────────────────────┘
```

**Deliverable**: Functional chat UI with domain tabs

---

### Day 11: Model Download & Management
**Goal**: Download model from cloud storage

```typescript
// src/services/ModelManager.ts
import RNFS from 'react-native-fs';

const MODEL_URL = 'https://huggingface.co/vazhi/vazhi-base/resolve/main/vazhi-base-q4_k_m.gguf';
const MODEL_PATH = `${RNFS.DocumentDirectoryPath}/vazhi-base-q4_k_m.gguf`;

export async function downloadModel(
  onProgress: (percent: number) => void
): Promise<string> {
  const exists = await RNFS.exists(MODEL_PATH);
  if (exists) return MODEL_PATH;

  const download = RNFS.downloadFile({
    fromUrl: MODEL_URL,
    toFile: MODEL_PATH,
    progress: (res) => {
      const percent = (res.bytesWritten / res.contentLength) * 100;
      onProgress(Math.round(percent));
    },
  });

  await download.promise;
  return MODEL_PATH;
}
```

**Deliverable**: Model downloads with progress indicator

---

### Day 12: Offline-First Features
**Goal**: Full offline functionality

- Cache downloaded model
- Store chat history locally
- Show offline indicator
- Quick suggestions for common queries

```typescript
const QUICK_SUGGESTIONS = {
  security: [
    "இது மோசடியா பாருங்க",
    "Cyber crime complaint எப்படி?",
    "Women helpline number என்ன?",
  ],
  govt: [
    "Ration card எப்படி வாங்குவது?",
    "Income certificate எங்கே?",
    "Senior citizen pension apply",
  ],
  education: [
    "NEET preparation tips",
    "Engineering colleges in TN",
    "Scholarship for poor students",
  ],
  legal: [
    "RTI எப்படி போடுவது?",
    "Tenant rights என்ன?",
    "Consumer complaint எங்கே?",
  ],
};
```

**Deliverable**: App works completely offline

---

### Day 13: Testing & Bug Fixes
**Goal**: Test on multiple devices

**Test Matrix**:
| Device | RAM | Android/iOS | Status |
|--------|-----|-------------|--------|
| Budget Android (4GB) | 4GB | Android 11 | ⏳ |
| Mid-range Android | 6GB | Android 13 | ⏳ |
| Flagship Android | 8GB+ | Android 14 | ⏳ |
| iPhone SE | 3GB | iOS 16 | ⏳ |
| iPhone 13+ | 4GB+ | iOS 17 | ⏳ |

**Test Cases**:
1. Model download interruption/resume
2. Chat with long responses
3. Memory pressure (background apps)
4. Tamil keyboard input
5. Dark mode
6. Screen reader accessibility

**Deliverable**: Bug-free app on target devices

---

### Day 14: Polish + Launch
**Goal**: Publish and document

**Tasks**:
- [ ] Record demo video (2-3 minutes)
- [ ] Write app store descriptions (Tamil + English)
- [ ] Update README with installation instructions
- [ ] Upload model to Hugging Face
- [ ] Create GitHub release v0.1.0
- [ ] Post on Tamil tech communities

**Demo Script**:
1. Show app opening (offline indicator)
2. Download model with progress
3. Ask general Tamil question
4. Switch to Security tab, test scam detection
5. Switch to Government tab, ask about scheme
6. Show it works in airplane mode

**Deliverable**: Published app, demo video, HuggingFace model

---

## Sprint Deliverables Summary

| Deliverable | Original Plan | Revised Status |
|-------------|---------------|----------------|
| Training data (500-1000 pairs) | Day 2 | ✅ DONE (3,007 pairs) |
| Colab environment + baseline test | Day 1 | ✅ DONE (01_vazhi_first_inference.ipynb) |
| Merged SFT dataset | Day 2 | ✅ DONE (2,706 train / 301 val) |
| Culture Pack (Thirukkural, Siddhars) | Day 2 | ✅ DONE (400 pairs) |
| Tamil base LLM (3B, fine-tuned) | Day 4 | 🔲 Day 4 |
| Quantized mobile model | Day 6 | 🔲 Day 6 |
| Security Pack LoRA | Day 9 | ✅ Data ready, merged into base |
| Government Pack | Phase 2 | ✅ Data ready, merged into base |
| Education Pack | Phase 2 | ✅ Data ready, merged into base |
| Legal Pack | Phase 2 | ✅ Data ready, merged into base |
| Mobile app with chat | Day 12 | 🔲 Day 12 |
| Pack switching UI | Day 13 | 🔲 Day 10 (domain tabs) |
| GitHub repo + docs | Day 14 | ✅ EXISTS |
| Demo video | Day 14 | 🔲 Day 14 |
| HuggingFace model | - | 🔲 Day 14 |

---

## Resource Requirements

| Resource | Specification | Purpose |
|----------|---------------|---------|
| Colab Pro | A100 GPU | Training (~4 hours) |
| Storage | ~10GB | Models + checkpoints |
| HuggingFace | Free account | Model hosting |
| Test phones | 2-3 devices | QA testing |

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Training fails | Use smaller batch size, gradient checkpointing |
| Model too slow on phone | Try q4_0 instead of q4_k_m, reduce context |
| Tamil tokenization issues | Test thoroughly, may need vocab extension |
| App store rejection | Prepare for manual review, document AI use |

---

## Post-Sprint Roadmap

### v0.2.0 (Week 3-4)
- Separate LoRA packs for hot-swapping
- Voice input (Tamil speech-to-text)
- Share responses feature

### v0.3.0 (Month 2)
- Multi-dialect support (Chennai, Madurai, Coimbatore Tamil)
- Pack contribution workflow
- Community pack reviews

### v1.0.0 (Month 3)
- Production-ready mobile apps
- Full pack marketplace
- Cloud escalation integration (Gemini/Grok)

---

*Last updated: February 5, 2026*
*Data collection: COMPLETE (2,147 pairs)*
*Next milestone: Base model training (Day 4)*
