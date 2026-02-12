# VAZHI Project: Lessons Learned

> Building a Tamil AI Assistant for Mobile: A Journey of Discovery

**Project:** VAZHI (வழி) - **V**oluntary **A**I with **Z**ero-cost **H**elpful **I**ntelligence
**Vision:** An open-source Tamil LLM that runs **offline on mobile phones** - free, transparent, Tamil-first
**Goal:** Deploy a Tamil-capable LLM on mobile devices (<1GB target)
**Current Target:** Qwen3-0.6B with two-stage training (Micro-DAPT → SFT)
**Timeline:** February 2026
**Status:** v0.8+ Qwen3-0.6B Training in Progress

---

## Project Overview

### Core Principles
| Principle | Meaning |
|-----------|---------|
| **வழி காட்டும்** | Shows the way — guides users with helpful AI |
| **Zero-cost** | Free to use, no API fees, runs on device |
| **Open source** | Transparent, community-owned, forkable |
| **Tamil-first** | Built natively for Tamil, not translated |

### Knowledge Packs Created
| Pack | Tamil Name | Pairs | Topics |
|------|-----------|-------|--------|
| 🪷 Culture | பண்பாடு | 400 | Thirukkural, Siddhars, temples, festivals |
| 📚 Education | கல்வி | 602 | Admissions, scholarships, exams, careers |
| 🛡️ Security | காவல் | 468 | Scam detection, cyber safety, women's safety |
| ⚖️ Legal | சட்டம் | 610 | Tenant rights, RTI, consumer protection |
| 🏛️ Government | அரசு | 467 | Schemes, certificates, e-Sevai, pensions |
| 🏥 Healthcare | மருத்துவம் | 460 | Health schemes, Siddha medicine |

**Total Original Data:** 3,007 training pairs

---

## Executive Summary

Building a Tamil LLM for mobile deployment proved far more challenging than anticipated. Our journey involved multiple pivots, failed approaches, and hard-won insights about the intersection of:
- Non-Latin script tokenization
- Model quantization
- Small language models
- Training data quality

**Key Lesson:** The problem wasn't training - it was deployment. A well-trained 3B model became useless after quantization due to Tamil tokenization overhead.

---

## Complete Project Timeline

### Week 1: Building the Foundation

| Day | Milestone | What We Did | Outcome |
|-----|-----------|-------------|---------|
| **Day 1** | Environment Setup | Colab + T4 GPU, loaded Qwen2.5-3B-Instruct, validated Tamil capabilities | ✅ Base model working |
| **Day 2** | Data Creation | Created 6 domain packs, 3,007 bilingual pairs, train/val split | ✅ Training data ready |
| **Day 3** | LoRA Setup | Configured Unsloth, LoRA adapters (r=16), Tamil chat template | ✅ Training pipeline ready |
| **Day 4** | v0.1 Training | First training run, 3 epochs on A100 (~84 min) | ⚠️ Culture pack hallucinating |
| **Day 5** | v0.2 Training | Added 173 culture samples, retrained | ❌ Still hallucinating |

### Week 2: App Development + Crisis

| Day | Milestone | What We Did | Outcome |
|-----|-----------|-------------|---------|
| **Day 6** | Flutter App | Pivoted from React Native to Flutter, built chat UI | ✅ App skeleton working |
| **Day 7** | HuggingFace Space | Created Gradio API for testing | ⚠️ Compatibility issues |
| **Day 8** | Root Cause Analysis | Discovered 74% of "Tamil" data was English! | 💡 Data quality crisis |
| **Day 9** | Data Regeneration | Designed new 11K dataset with 85% Tamil content | ✅ Better data planned |
| **Day 10** | v0.4 Training | Trained with regenerated data, good results | ✅ Model works! |

### Week 3: The Quantization Wall

| Day | Milestone | What We Did | Outcome |
|-----|-----------|-------------|---------|
| **Day 11** | GGUF Conversion | Attempted Q8_0, Q4_K_M quantization | ❌ All produce gibberish Tamil |
| **Day 12** | Diagnostics | Created diagnostic notebooks, tested all quant levels | 💡 Tokenization is the problem |
| **Day 13** | Research | Surveyed Sarvam, Gemma Tamil, AI4Bharat | 💡 Existing solutions exist! |
| **Day 14** | SLM Pivot | Decided on Qwen2.5-0.5B approach | ✅ New strategy |

### Week 4: SLM Training (Failed) → Sarvam-2B Pivot

| Day | Milestone | What We Did | Outcome |
|-----|-----------|-------------|---------|
| **Day 15** | Data Prep v0.5 | Prepared 11,696 items, uploaded to HuggingFace | ✅ Dataset ready |
| **Day 16** | TRL Issues | Fixed multiple TRL 0.27.2 API changes | ✅ Training started |
| **Day 17** | Training Divergence | Loss exploded at step 1000 (0.53→2.57) | ❌ Training failed |
| **Day 18** | Recovery Training | New run with lower LR + grad clipping | ❌ Loss stable but output garbage |
| **Day 19** | Diagnosis | Tested checkpoints, found LoRA corrupted model | 💡 LoRA too aggressive for 0.5B |
| **Day 20** | Model Testing | Tested Sarvam-1, Sarvam-2B, Gemma Tamil, Tamil-LLaMA | 💡 Only Tamil-LLaMA works |
| **Day 21** | IndicAlign Analysis | Explored AI4Bharat datasets, found Anudesh | 💡 ~1,966 Tamil items available |
| **Day 22** | v0.6 Training | Sarvam-2B + Anudesh Tamil + VAZHI data | 🔄 Training in progress |

---

## Technology Pivots Made

### Mobile Framework: React Native → Flutter
| Aspect | React Native (Original) | Flutter (Final) |
|--------|-------------------------|-----------------|
| Performance | Slower for LLM integration | Better native performance |
| llama.cpp integration | llama.rn (complex) | Native FFI (cleaner) |
| Cross-platform | Good | Excellent |
| Decision | Switched after Day 5 | Currently using |

### Testing Strategy: Local Only → HuggingFace Space
| Aspect | Local Testing | HuggingFace Space |
|--------|--------------|-------------------|
| Iteration speed | Slow (rebuild app) | Fast (API calls) |
| GPU access | Need local GPU | Free tier available |
| Debugging | Difficult | Easy logs |
| Decision | Use Space for dev | GGUF for production |

### Model Size: 3B → 0.5B
| Aspect | Qwen2.5-3B | Qwen2.5-0.5B |
|--------|------------|--------------|
| F16 Size | 6.2GB | 1GB |
| Q4_K_M Size | 1.8GB | ~250MB |
| Tamil after quant | ❌ Broken | TBD (testing) |
| Mobile viable | ❌ No | ✅ Yes |

---

## The Journey

### Phase 1: Initial Optimism (v0.1 - v0.2)

**What We Did:**
- Chose Qwen2.5-3B-Instruct as base model
- Created ~3,000 training samples across 8 packs (Security, Government, Culture, etc.)
- Fine-tuned with LoRA for 3 epochs
- Expected: Working Tamil assistant

**What Happened:**
- Training loss looked great (0.54)
- Most packs worked reasonably well
- **Culture pack completely hallucinated** - wrong Thirukkural citations, nonsense poetry

**Initial Diagnosis (Wrong):**
> "We need more Thirukkural data"

Added 173 more culture samples. Retrained. **Same hallucination problem.**

---

### Phase 2: Data Quality Crisis (v0.2 Analysis)

**The Real Problem Discovered:**

```
Labeled Language Distribution:
- pure_tamil: 43.4%
- tanglish: 38.4%

ACTUAL Output Language (character analysis):
- mostly_english: 74.1%  ← THE REAL PROBLEM
- mostly_tamil: 13.5%
```

**Insight:** 74% of our "Tamil" training data was actually English. The model learned: "Tamil question → English answer"

**Lesson #1:** Never trust data labels. Always verify with character-level analysis.

---

### Phase 3: Data Regeneration (v0.4)

**What We Did:**
- Audited all 3,180 samples
- Created templates enforcing actual Tamil output
- Generated 11,696 high-quality Tamil samples
- Average Tamil character ratio: ~85%
- Included authoritative sources (Thirukkural corpus, Sangam literature)

**Training Results:**
- Loss: 0.54 (good convergence)
- Tamil responses: Actually Tamil now
- Thirukkural: Correctly cited

**We thought we were done.** We were wrong.

---

### Phase 4: The Quantization Wall (v0.4 Deployment)

**The Devastating Discovery:**

| Format | Size | Tamil Output |
|--------|------|--------------|
| F16 | 6.2GB | ✅ Works perfectly |
| Q8_0 | 3.2GB | ❌ Gibberish |
| Q4_K_M | 1.8GB | ❌ Complete nonsense |

**Example of Q4_K_M Output:**
```
Q: திருக்குறளின் முதல் குறள் என்ன?
A: கூறிய் லக்கிய் சிறப்பு கொண்ட ஆற்றல்... (RANDOM CHARACTERS)
```

**Root Cause Analysis:**

1. **Tokenization Overhead:** Tamil requires 3-4 tokens per character in Qwen's tokenizer
2. **Error Compounding:** Each token's quantization error multiplies across the sequence
3. **Precision Threshold:** Tamil's complex script needs higher precision than 4-bit can provide

**Lesson #2:** Training success ≠ Deployment success. Always test the quantized model BEFORE celebrating.

**Lesson #3:** For non-Latin scripts, tokenization efficiency directly impacts quantization quality.

---

### Phase 5: The SLM Pivot (v0.5 - Current)

**New Strategy:**
Instead of compressing a large model, start with a smaller model that quantizes to target size.

| Model | F16 Size | Q4_K_M Size | Tamil Tokens |
|-------|----------|-------------|--------------|
| Qwen2.5-3B | 6.2GB | 1.8GB (broken) | Same tokenizer |
| Qwen2.5-0.5B | 1GB | **~250MB** | Same tokenizer |

**Hypothesis:** Smaller model = less absolute quantization error = Tamil might survive

**Current Status:** Training in progress, loss stable at 0.54

---

## What We Could Have Done Better

### 1. Started with Existing Tamil Models

**Models We Actually Tested (2026-02-07):**

| Model | Size | Tamil Quality | Result |
|-------|------|---------------|--------|
| Sarvam-1 | 2B | ❌ English responses | Base model, not instruction-tuned |
| Sarvam-2b-v0.5 | 2B | ❌ English responses | Base model, needs fine-tuning |
| Gemma 2B Tamil | 2B | ❌ 401 Unauthorized | Model doesn't exist/is private |
| Tamil-LLaMA 7B | 7B | ✅ Works! | 3.9GB - too large for mobile |

**Reality Check:**
- Sarvam models are **base models** - they respond in English, not Tamil
- Gemma Tamil model `abhinand/tamil-gemma-2b-instruct-v0.1` returns 401 - doesn't exist
- Only Tamil-LLaMA 7B actually works, but at 3.9GB it's far too large

**What Actually Works:**
```
Tamil-LLaMA 7B Q4: 3.9GB → Works but too large
Sarvam-2B + fine-tuning: ~1.2GB → Current approach (v0.6)
```

**Lesson #4:** Don't assume models work without testing. "Tamil-capable" often means base model that needs instruction-tuning, not a ready-to-use assistant.

---

### 2. Leveraged AI4Bharat Resources

**What AI4Bharat Actually Provides (Tested 2026-02-07):**

| Resource | Reality Check |
|----------|---------------|
| **IndicAlign** | Multiple subsets, NOT a single Tamil dataset |
| **Anudesh subset** | 36,820 rows total, only ~1,966 are Tamil (~5%) |
| **Airavata** | Hindi-only 7B model - NOT for Tamil |
| **Sangraha** | Pretraining corpus, not instruction data |

**IndicAlign Subsets We Explored:**

| Subset | Total Rows | Tamil Items | Best For |
|--------|------------|-------------|----------|
| Anudesh | 36,820 | ~1,966 (5%) | ✅ Native instructions |
| Wiki_Chat | 100,000+ | Unknown | ❌ Wrong format (not instructions) |
| Dolly_T | ~15,000 | Unknown | Translated, not native |

**Correct Usage:**
```python
# Load Anudesh subset specifically
indic_align = load_dataset("ai4bharat/indic-align", "Anudesh", split="train")

# Filter for Tamil using Unicode detection
def is_tamil_text(text):
    tamil_chars = sum(1 for c in text if 0x0B80 <= ord(c) <= 0x0BFF)
    return tamil_chars / len(text) > 0.3 if text else False

tamil_items = indic_align.filter(lambda x: is_tamil_text(x["interactions"][0][0]))
# Result: ~1,966 Tamil items from 36,820 total
```

**Lesson #5:** AI4Bharat resources are valuable but require careful filtering. "74.7M instruction pairs" is across ALL Indian languages - Tamil is only ~5% of IndicAlign Anudesh.

---

### 3. Considered Model Compression Techniques

**Techniques We Could Have Used:**

#### A. Minitron (NVIDIA)
- Prunes 2B model to 1B while preserving capabilities
- Uses distillation from larger teacher model
- Could compress Sarvam 2B → 1B → ~500MB GGUF

#### B. Language-Specific Pruning
- Multilingual models have redundant language capacity
- Prune non-Tamil language neurons
- Potentially 30-40% size reduction

#### C. Vocabulary Pruning
- Qwen has 151K vocab tokens
- Tamil uses maybe 10K
- Pruning unused tokens could significantly reduce embedding size

**Lesson #6:** Compression is a spectrum, not binary. Between "full model" and "Q4 quantization" lie many techniques.

---

### 4. Better Training Process

**What We Did:**
```
1. Generate data manually
2. Train for 3 epochs
3. Hope for the best
4. Discover problems in production
```

**What We Should Have Done:**

```
1. SURVEY: Test existing Tamil models (Sarvam, Gemma Tamil)
2. BASELINE: Establish quality benchmarks for Tamil output
3. DATA: Use AI4Bharat resources + domain-specific additions
4. VALIDATE: Test GGUF output quality BEFORE full training
5. ITERATE: Small experiments before committing to full runs
```

**Proposed Training Pipeline:**

```
┌─────────────────────────────────────────────────────────────┐
│                    PHASE 1: EXPLORATION                      │
├─────────────────────────────────────────────────────────────┤
│ 1. Survey existing models (Sarvam, Gemma Tamil, Tamil-LLaMA)│
│ 2. Test their GGUF quantizations for Tamil quality          │
│ 3. Establish baseline: "What does good Tamil output look    │
│    like at 250MB, 500MB, 1GB?"                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    PHASE 2: DATA STRATEGY                    │
├─────────────────────────────────────────────────────────────┤
│ 1. Start with AI4Bharat IndicAlign (massive coverage)       │
│ 2. Add domain-specific data (our 8 packs)                   │
│ 3. Include authoritative sources (Thirukkural corpus)       │
│ 4. Validate Tamil % before training                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 PHASE 3: QUICK VALIDATION                    │
├─────────────────────────────────────────────────────────────┤
│ 1. Train for 100 steps only                                 │
│ 2. Save checkpoint                                          │
│ 3. Quantize to target format (Q4_K_M)                       │
│ 4. Test Tamil output quality                                │
│ 5. If broken → pivot model/approach EARLY                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   PHASE 4: FULL TRAINING                     │
├─────────────────────────────────────────────────────────────┤
│ 1. Only after validation passes                             │
│ 2. Conservative hyperparameters (low LR, grad clipping)     │
│ 3. Frequent checkpoints                                     │
│ 4. Periodic GGUF quality checks                             │
└─────────────────────────────────────────────────────────────┘
```

**Lesson #7:** Validate the deployment format early and often. Don't wait until training completes.

---

## Technical Insights

### Tamil Tokenization Analysis

**Qwen2.5 Tokenizer Efficiency:**
```
English: "Hello" → 1 token
Tamil:   "வணக்கம்" → 7 tokens (1 per character + combining marks)
```

**Impact on Quantization:**
- More tokens = more places for error
- 4-bit quantization: each token loses precision
- Cumulative error: 7 tokens × error > 1 token × error

**Better Tokenizers for Tamil:**
- Sarvam's tokenizer: Optimized for Indian scripts
- IndicBERT tokenizer: Subword units for Tamil
- Custom BPE trained on Tamil: Best efficiency

### Quantization Quality by Script Type

| Script Type | Q4_K_M Quality | Reason |
|-------------|----------------|--------|
| Latin (English) | Good | 1-2 tokens per word |
| Cyrillic (Russian) | Okay | 2-3 tokens per word |
| Devanagari (Hindi) | Degraded | 3-4 tokens per word |
| Tamil | Poor | 4-5 tokens per word |
| CJK (Chinese) | Variable | Depends on vocab coverage |

### Model Size vs Tamil Quality

```
                    Tamil Quality
                         ▲
                         │
           ┌─────────────┼─────────────┐
           │             │             │
    Good   │      ●      │             │  ● = Our target zone
           │   (Sarvam   │             │
           │    IQ3_M)   │             │
           │             │             │
  Moderate │             │      ●      │
           │             │  (Qwen 0.5B │
           │             │   Q4_K_M?)  │
           │             │             │
    Poor   │             │             │      ●
           │             │             │  (Qwen 3B
           │             │             │   Q4_K_M)
           └─────────────┴─────────────┴──────────▶
                 1GB          500MB        250MB
                          Model Size
```

---

## Recommendations for Future Tamil LLM Projects

### 1. Start with Survey
Before training anything:
- Test Sarvam-1 GGUF models
- Test Gemma Tamil variants
- Test any AI4Bharat models
- Establish your quality baseline

### 2. Size Your Target First
```
Mobile (budget):     < 500MB  → Start with 0.5B-1B models
Mobile (premium):    < 1GB    → Sarvam IQ3_M works
Desktop/Server:      < 4GB    → Many options available
```

### 3. Test Quantization Early
After just 100 training steps:
1. Save checkpoint
2. Merge LoRA
3. Convert to GGUF
4. Test Tamil output
5. Pivot if broken

### 4. Use Existing Resources
| Need | Resource |
|------|----------|
| Instruction data | AI4Bharat IndicAlign |
| Raw Tamil text | AI4Bharat Sangraha |
| Pre-trained Tamil model | Sarvam-1, Gemma Tamil |
| Tokenizer | Sarvam's Indian-optimized tokenizer |

### 5. Consider Hybrid Approaches
For factual content (Thirukkural, dates, names):
- Lookup tables instead of generation
- RAG with offline vector store
- Constrained decoding

For conversational content:
- LLM generation
- Template-guided responses

---

## Summary of Key Lessons

| # | Lesson | Impact |
|---|--------|--------|
| 1 | Never trust data labels - verify with character analysis | Avoided training on fake "Tamil" data |
| 2 | Training success ≠ Deployment success | Discovered GGUF broke Tamil |
| 3 | Tokenization efficiency impacts quantization | Explains why Tamil breaks at Q4 |
| 4 | Survey existing solutions first | Could have started with Sarvam |
| 5 | Use AI4Bharat resources | 74M samples > our 11K samples |
| 6 | Compression is a spectrum | Minitron, pruning, vocab reduction |
| 7 | Validate deployment format early | Test GGUF after 100 steps, not 2000 |
| 8 | Low loss ≠ Working model | v0.5 had loss 0.5 but output garbage |
| 9 | LoRA rank must match model size | r=32 too aggressive for 0.5B model |
| 10 | 4-bit training is risky for small models | Instability compounds in fewer params |
| 11 | Test models before assuming they work | Sarvam/Gemma Tamil didn't work as expected |
| 12 | Filter multilingual datasets for target language | IndicAlign Anudesh is only ~5% Tamil |
| 13 | Base models ≠ Instruction-tuned models | Sarvam-2B responds in English until fine-tuned |
| 14 | 4-bit training corrupts models | v0.5 Qwen and v0.6 Sarvam both failed with 4-bit |
| 15 | Consider extreme quantization of working models | Better to compress a working 7B than train a broken 2B |
| 16 | Pre-trained Tamil models exist and work | Gemma-2B Tamil Q4_K_M (1.63GB) produces coherent Tamil |
| 17 | Q4_K_M is minimum viable quantization | Q3 and below cause visible quality degradation |
| 18 | Fine-tune working models, don't train from scratch | Add domain knowledge to models that already know the language |
| 19 | Don't wait for perfect AI - provide value immediately | Hybrid architecture unblocked the entire project |
| 20 | Separate factual data from AI interpretation | SQLite for facts, LLM for explanations |
| 21 | Progressive enhancement > feature gating | Users can try app before committing to model download |
| 22 | **NEVER ignore tokenizer warnings** | "OrderedVocab holes" warning caused complete GGUF failure |
| 23 | Two-stage training (DAPT→SFT) preserves both fluency AND instructions | DAPT alone breaks instructions, SFT alone degrades Tamil |
| 24 | Preflight fail-fast saves days of wasted training | Run tiny DAPT+SFT before full training |
| 25 | Checkpoint to HF Hub frequently | Survives Colab/Kaggle disconnects |
| 26 | Smaller models (0.6B) > larger models (2B) for <1GB target | Less quantization degradation |
| 27 | Verify base model tokenizer before training | Corrupted source = corrupted output |
| 28 | **NEVER mix data formats in SFT** | Raw text + ChatML mixed = "systemsystemsystem..." garbage |
| 29 | Input validation is non-negotiable | Sanitize ALL user input at service boundaries |
| 30 | Encrypt sensitive local storage | Hive alone is not secure, use flutter_secure_storage |
| 31 | Use allowlists for external URLs | Never trust user-provided URLs for downloads |
| 32 | Verify downloads with checksums | Prevent tampered model files with SHA256 |
| 33 | Accessibility from the start | Semantics widgets are easy to add early |
| 34 | Migration frameworks prevent data loss | Track schema versions from day one |
| 35 | i18n infrastructure early | ARB files scale better than hardcoded strings |
| 36 | **Don't SFT on instruct models with conflicting chat formats** | Qwen3's native `<think>` mode conflicts with ChatML — use base model instead |
| 37 | Lower LR for instruct models (2e-5 not 1e-4) | 1e-4 causes catastrophic forgetting of existing instruction-following |
| 38 | Qwen3 has internal bf16 ops incompatible with P100/T4 | Use FP32 training mode (fp16=False, bf16=False) on non-Ampere GPUs |
| 39 | Test existing HF checkpoints before new training runs | A previously uploaded model may still work — check before wasting compute |

---

## The Hybrid Architecture Pivot (v0.8)

### The Key Insight

While struggling with model training and quantization, we realized a fundamental truth:

> **Not every query needs AI. Many queries just need accurate data.**

For example:
- "குறள் 1 என்ன?" → Just needs database lookup
- "Emergency number?" → Just needs a phone number
- "Is this a scam?" → Needs AI analysis

### The Solution: Hybrid Retrieval Architecture

Instead of waiting for a perfect AI model, we built an architecture that provides **immediate value** through deterministic lookups:

```
User Query → Query Router → [Deterministic | Hybrid | AI] → Response
```

| Query Type | Route | AI Needed |
|------------|-------|-----------|
| Exact lookup (குறள் 1) | SQLite | No |
| Explanation request | LLM | Yes |
| Hybrid (குறள் 1 meaning) | SQLite + LLM | Optional |

### Benefits

1. **Immediate Value**: App works from first launch (no model download)
2. **Zero Hallucination**: Factual data (verses, phone numbers) always accurate
3. **Smaller Initial Download**: ~50MB app vs 1.6GB with model
4. **Higher Install Rates**: Users can try before committing to download
5. **Progressive Enhancement**: Better experience with optional AI model

### Implementation

Built a complete hybrid system:
- **Query Router**: Pattern-based classification (no ML needed)
- **Retrieval Services**: Domain-specific SQLite lookups
- **Hybrid Chat Provider**: Manages dual-path responses
- **Knowledge Result Cards**: Rich UI for structured data
- **Model Download Service**: Pause/resume, network detection, storage validation

### Lesson #19: Don't wait for perfect AI - provide value immediately

The hybrid architecture was a game-changer. Instead of blocking on model training, we could:
- Ship a useful app today
- Gather user feedback on what queries are most common
- Optimize AI training based on real usage data

---

## What's Next

### Immediate (v0.8+ - Current)
- **Qwen3-0.6B training on Kaggle** (two-stage: Micro-DAPT → SFT)
- Populate full Thirukkural database (1,330 verses)
- Complete government schemes database

### Short-term (v0.9)
- GGUF quantization of trained Qwen3-0.6B
- HuggingFace Space deployment for testing
- FTS5 Tamil search optimization

### Target Model Strategy (<1GB)
**Current approach: Qwen3-0.6B with two-stage training**

Why Qwen3-0.6B:
1. **Native thinking capability** - Built-in reasoning with `/think` mode
2. **600M parameters** - Sweet spot for <1GB GGUF target
3. **Clean tokenizer** - No corruption issues like Gemma
4. **Strong multilingual support** - Better Tamil handling than Gemma

Two-stage training pipeline:
1. **Micro-DAPT**: 80% Vazhi outputs + 20% Sangraha Tamil corpus (AI4Bharat, CC-BY 4.0)
2. **SFT**: Instruction tuning with assistant-only loss masking
3. **Merge**: LoRA adapters merged to base model
4. **GGUF**: Q4_K_M quantization for mobile deployment

### Future Considerations
- Custom Tamil-optimized tokenizer
- Distillation from larger Tamil models
- Multi-dialect support

---

## Appendix: Resources

### Models
- Sarvam-1: https://huggingface.co/sarvamai/sarvam-1
- Gemma Tamil: https://huggingface.co/abhinand/tamil-gemma-2b-instruct-v0.1
- Tamil-LLaMA: https://huggingface.co/abhinand/tamil-llama-7b-instruct-v0.2

### Datasets
- IndicAlign: https://huggingface.co/datasets/ai4bharat/IndicAlign
- Sangraha: https://huggingface.co/datasets/ai4bharat/sangraha

### Tools
- Minitron: NVIDIA's model compression toolkit
- llama.cpp: GGUF conversion and quantization

### Our Resources
- Training Log: `/models/TRAINING_LOG.md`
- Training Notebook: `/notebooks/Vazhi_Qwen05B_Training.ipynb`
- Tamil Dataset: https://huggingface.co/datasets/CryptoYogi/vazhi-tamil-v05

---

## Notebooks Created During This Journey

| Notebook | Purpose | Outcome |
|----------|---------|---------|
| `vazhi_v04_training.ipynb` | Initial Qwen2.5-3B training | ✅ Trained, but GGUF failed |
| `Vazhi_Day4_v02_Training.ipynb` | v0.2 with culture additions | ❌ Still hallucinating |
| `Vazhi_GGUF_Quantization.ipynb` | GGUF conversion attempts | ❌ Tamil broken at all quant levels |
| `Vazhi_GGUF_Diagnostic.ipynb` | Diagnose quantization issues | 💡 Identified tokenization problem |
| `Vazhi_GGUF_Diagnostic_v2.ipynb` | Deeper analysis | 💡 Confirmed 3-4 tokens/char overhead |
| `Vazhi_SmolLM_135M_Training.ipynb` | Explored SmolLM approach | ⏸️ Pivoted to Qwen 0.5B instead |
| `Vazhi_Qwen05B_Training.ipynb` | Current SLM training | 🔄 In progress |

---

## The Ideal Path (What We'd Do Differently)

If starting this project today with everything we've learned:

### Day 1: Survey Existing Solutions
```bash
# Test Sarvam-1 GGUF immediately
./llama-cli -m sarvam-1-iq3_m.gguf -p "திருக்குறளின் முதல் குறள் என்ன?"

# If Tamil quality is acceptable, use it directly
# Sarvam-1 IQ3_M is 1.17GB - still large but proven quality
```

### Day 2: Establish Baselines
```python
# Test multiple models for Tamil quality at different sizes
models_to_test = [
    ("sarvamai/sarvam-1", "IQ3_M", "1.17GB"),
    ("abhinand/tamil-gemma-2b-instruct", "Q4_K_M", "~1.4GB"),
    ("Qwen/Qwen2.5-0.5B-Instruct", "Q4_K_M", "~250MB"),
]

# Establish quality baseline: Which size gives acceptable Tamil?
```

### Day 3: Data Strategy
```python
# Use AI4Bharat resources
from datasets import load_dataset

# IndicAlign: 74.7M instruction pairs (filter for Tamil)
indic_align = load_dataset("ai4bharat/IndicAlign", "tam")

# Sangraha: 251M tokens of clean Tamil text
sangraha = load_dataset("ai4bharat/sangraha", "tam")

# Add our domain-specific packs on top
vazhi_packs = load_dataset("CryptoYogi/vazhi-tamil-v05")
```

### Day 4-5: Validate Before Full Training
```python
# Train for just 100 steps
trainer.train(max_steps=100)
trainer.save_model("./test-checkpoint")

# Convert to GGUF and test immediately
!python convert_hf_to_gguf.py ./test-checkpoint --outfile test.gguf
!./llama-quantize test.gguf test-q4.gguf q4_k_m

# Test Tamil output - if broken, pivot NOW not after 2000 steps
!./llama-cli -m test-q4.gguf -p "வணக்கம்..."
```

### Day 6-7: Full Training (only if validation passes)
```python
# Conservative hyperparameters from the start
config = SFTConfig(
    learning_rate=5e-5,      # Start conservative
    max_grad_norm=0.3,       # Always clip gradients
    warmup_ratio=0.1,        # Gentle warmup
    logging_steps=25,        # Frequent monitoring
    save_steps=100,          # Frequent checkpoints
)
```

### Day 8-10: Deployment
```bash
# Final quantization with tested parameters
./llama-quantize final.gguf vazhi-mobile.gguf Q4_K_M

# Integration with Flutter app
# Model download manager
# Offline-first architecture
```

---

## Cost-Benefit Analysis of Different Approaches

### Approach A: Train Qwen2.5-0.5B from Scratch (Our Current Path)

| Metric | Value |
|--------|-------|
| Time Investment | ~2 weeks |
| Compute Cost | Free (Colab) |
| Final Size | ~250MB |
| Tamil Quality | Unknown (testing) |
| Control | Full control over training |
| Risk | May fail like 3B did |

### Approach B: Use Sarvam-1 Directly

| Metric | Value |
|--------|-------|
| Time Investment | 1-2 days |
| Compute Cost | None |
| Final Size | 1.17GB (IQ3_M) |
| Tamil Quality | Proven good |
| Control | No customization |
| Risk | Size may be too large for budget phones |

### Approach C: Fine-tune Sarvam-1 + Minitron Compression

| Metric | Value |
|--------|-------|
| Time Investment | 1-2 weeks |
| Compute Cost | Significant (distillation) |
| Final Size | ~500MB (estimated) |
| Tamil Quality | Should be good (Sarvam base) |
| Control | High (can customize + compress) |
| Risk | Complex engineering |

### Approach D: Use Gemma 2B Tamil + Quantize

| Metric | Value |
|--------|-------|
| Time Investment | 2-3 days |
| Compute Cost | Low (just quantize) |
| Final Size | ~1.4GB (Q4_K_M) |
| Tamil Quality | Good (abhinand's work) |
| Control | Limited |
| Risk | Size still large |

**Recommendation:**
- For MVP: Approach A (current) or B
- For production: Approach C (Sarvam + Minitron)
- For quick testing: Approach B (Sarvam-1 IQ3_M)

---

## Key Metrics to Track

### Training Metrics
| Metric | Target | v0.1 | v0.2 | v0.4 | v0.5 |
|--------|--------|------|------|------|------|
| Training Loss | < 0.6 | 0.54 | 0.54 | 0.54 | 0.54 (step 850) |
| Validation Loss | < 0.8 | 0.76 | 0.76 | N/A | N/A |
| Tamil Accuracy | > 80% | 60%* | 60%* | TBD | TBD |

*Lower due to data quality issues

### Deployment Metrics
| Metric | Target | v0.4 (3B) | v0.5 (0.5B) |
|--------|--------|-----------|-------------|
| Model Size | < 300MB | 1.8GB ❌ | ~250MB ✅ |
| Tamil Coherence | Readable | Gibberish ❌ | TBD |
| First Token Latency | < 1s | N/A | TBD |
| Memory Usage | < 500MB | N/A | TBD |

### Quality Benchmarks (Thirukkural Test)
| Test | Expected Answer | v0.1 | v0.2 | v0.4 GGUF | v0.5 |
|------|-----------------|------|------|-----------|------|
| First Kural | "அகர முதல..." | ❌ Wrong | ❌ Wrong | ❌ Gibberish | TBD |
| Meaning | Correct explanation | ❌ | ❌ | ❌ | TBD |
| Attribution | Thiruvalluvar | ❌ | ❌ | ❌ | TBD |

---

## Final Thoughts

Building a Tamil LLM for mobile deployment is harder than it looks. The challenges are:

1. **Tokenization Overhead**: Non-Latin scripts pay a heavy tax in modern tokenizers
2. **Quantization Sensitivity**: Languages with more tokens-per-character lose more in compression
3. **Ecosystem Maturity**: The Tamil LLM ecosystem is growing but still nascent
4. **Mobile Constraints**: 250MB is a very aggressive target

The good news is that the ecosystem is improving rapidly:
- AI4Bharat provides excellent resources
- Sarvam has proven Tamil models
- Techniques like Minitron offer paths to smaller models

VAZHI may not be the first Tamil mobile LLM, but the lessons learned here will help future projects avoid our mistakes.

---

*வழி காட்டும் AI — The open path to Tamil AI*

---

---

## Phase 6: The Qwen3-0.6B Pivot (v0.8+)

### The Gemma Tokenizer Corruption

After v0.7's apparent success with Gemma-2B Tamil, GGUF conversion revealed a fatal flaw:

**Error:** `GGML_ASSERT(id_to_token.size() == token_to_id.size()) failed`

**Root Cause:** The source model `abhinand/gemma-2b-it-tamil-v0.1-alpha` had a corrupted tokenizer with "OrderedVocab holes at indices [1, 2]". This warning was visible during training but ignored. The corruption propagated through all training attempts and made GGUF conversion impossible.

### Why Qwen3-0.6B?

After consulting with GPT5.2 and analyzing the failure modes, the recommendation was clear:

| Factor | Gemma-2B | Qwen3-0.6B |
|--------|----------|------------|
| Tokenizer | Corrupted (holes) | Clean |
| Parameters | 2B | 600M |
| GGUF target | 1.6GB | <1GB |
| Thinking capability | None | Native `/think` mode |
| Multilingual | Limited | Strong |

### Two-Stage Training: The Key Insight

**Problem:** Single-pass SFT causes either:
- Tamil fluency loss (if using English-first model)
- Instruction-following loss (if using DAPT only)

**Solution:** Two-stage training pipeline:

```
Stage 1: Micro-DAPT (Continued Pretraining)
├── 80% Vazhi outputs (Tamil text)
├── 20% Sangraha corpus (AI4Bharat, CC-BY 4.0)
└── Result: Tamil fluency boost

Stage 2: SFT (Instruction Tuning)
├── Full Vazhi Q&A pairs
├── Assistant-only loss masking
└── Result: Instruction-following capability
```

### Infrastructure Lessons

The Kaggle training environment required specific fixes:

| Issue | Fix |
|-------|-----|
| CUDA device selection | `CUDA_VISIBLE_DEVICES=0` |
| Tokenizer parallelism warnings | `TOKENIZERS_PARALLELISM=false` |
| T4 GPU precision | `fp16` (not bf16) |
| Colab/Kaggle disconnects | HF Hub checkpointing every epoch |

### Preflight Fail-Fast System

Before committing to full training (hours), run a preflight check:

```python
# 1. Tiny Micro-DAPT (50 samples, 10 steps)
# 2. Tiny SFT (50 samples, 10 steps)
# 3. Merge LoRA
# 4. Test output quality
# 5. If garbage → pivot BEFORE wasting hours
```

This system would have saved days of wasted Gemma training.

### Lesson #22-27: New Lessons from Phase 6

- **#22**: NEVER ignore tokenizer warnings - "OrderedVocab holes" is fatal
- **#23**: Two-stage training (DAPT→SFT) preserves both fluency AND instructions
- **#24**: Preflight fail-fast saves days of wasted training
- **#25**: Checkpoint to HF Hub frequently (Colab/Kaggle disconnect protection)
- **#26**: Smaller models (0.6B) > larger models (2B) for <1GB target
- **#27**: Verify base model tokenizer BEFORE training
- **#28**: NEVER MIX DATA FORMATS in SFT training - Raw text belongs in DAPT, ChatML-formatted Q&A pairs belong in SFT. Mixing them causes model to output garbage (e.g., "systemsystemsystem...")

---

## Phase 7: The Data Format Crisis (v3.1 Training Failure)

### What Happened

Training v3.1 on Kaggle completed successfully:
- Loss dropped from 3.39 to ~0.5
- Training ran to completion without errors
- Model uploaded to HuggingFace

**But the model output was garbage:**
```
Q: வணக்கம்
A: 'systemsystemsystemsystemsystem...

Q: 2+2 என்ன?
A: 4systemsystemsystemsystem...
```

### Root Cause: Mixed Data Formats

The training dataset mixed **two incompatible formats**:

| Source | Format | Count | Problem |
|--------|--------|-------|---------|
| `vazhi-tamil-v05` (existing) | RAW TEXT | ~3,836 | No ChatML structure |
| IndicAlign + Manual | ChatML formatted | ~1,097 | Properly structured |

The existing dataset contained:
- Sangam poetry (raw text, no Q&A structure)
- Thirukkural verses (raw text)
- Mixed completion format samples

The diverse samples were properly formatted:
```
<|im_start|>system
நீங்கள் VAZHI...<|im_end|>
<|im_start|>user
தமிழ்நாட்டின் தலைநகரம்?<|im_end|>
<|im_start|>assistant
சென்னை.<|im_end|>
```

### The Fix

**Option A: Use ONLY ChatML-formatted data for SFT**
- Filter existing dataset for samples that already have `<|im_start|>` tags
- Only include diverse samples (already formatted)
- Raw text samples belong in DAPT stage, not SFT

**Option B: Two-stage training (proper implementation)**
- Stage 1 (Micro-DAPT): Raw Tamil text for fluency (no chat template)
- Stage 2 (SFT): ChatML-formatted Q&A ONLY

### Lesson #28: Data Format Consistency is Critical

For SFT training:
- **ALL** samples must have consistent chat template format
- Raw text belongs in DAPT/continued pretraining, NOT in SFT
- Mixing formats causes the model to learn garbage patterns
- Loss can look good (0.5) while output is completely broken
- Always verify format consistency before training with:
  ```python
  def is_chatml_formatted(text):
      return "<|im_start|>" in text and "<|im_end|>" in text

  chatml_pct = sum(1 for s in samples if is_chatml_formatted(s['text'])) / len(samples)
  print(f"ChatML %: {chatml_pct:.1%}")  # Should be 100% for SFT
  ```

---

## Phase 8: Code Quality & Security Hardening (v0.8.1)

### Multi-Agent Code Review

After completing the hybrid architecture, we conducted a comprehensive code review using a multi-agent system. The review identified 19 issues across critical, high, and medium priority.

**Review Process:**
1. Four specialized agents analyzed different aspects of the codebase
2. Consensus report generated with unified recommendations
3. All 19 issues created as GitHub issues
4. All issues implemented and closed

### Issues Closed

| Priority | Issues | Description |
|----------|--------|-------------|
| **Critical** | #22-25 | URL validation, hash verification, secure timeouts |
| **High** | #26-32 | Input sanitization, HTTP enforcement, provider namespacing |
| **High** | #27, #29 | Encrypted storage, training data rebalancing |
| **Medium** | #33-40 | Migration framework, i18n, accessibility, metrics |

### Security Enhancements Implemented

| Feature | Implementation | File |
|---------|----------------|------|
| **Encrypted Storage** | AES cipher + flutter_secure_storage | `feedback_service.dart` |
| **Input Validation** | SQL/FTS5 injection prevention | `knowledge_database.dart` |
| **ReDoS Protection** | Regex complexity detection | `query_router.dart` |
| **URL Allowlist** | Only trusted domains for downloads | `model_download_service.dart` |
| **SHA256 Verification** | Checksum validation for downloads | `model_download_service.dart` |
| **Secure Timeouts** | 10-second limits on operations | Throughout services |

### Infrastructure Added

| Component | Purpose | Files |
|-----------|---------|-------|
| **Migration Framework** | Versioned schema changes | `lib/database/migrations/` |
| **i18n/l10n** | English + Tamil localization | `lib/l10n/app_en.arb`, `app_ta.arb` |
| **Accessibility** | Screen reader support | `widgets/chat_input.dart`, `feedback_buttons.dart` |
| **Inference Metrics** | First token latency, tokens/sec | `vazhi_local_service.dart` |
| **JSON Schema** | Training data validation | `schemas/training_sample.schema.json` |
| **Preflight Validation** | Pre-training checks | `scripts/preflight_validation.py` |
| **Data Rebalancer** | Thirukkural 71%→25% | `scripts/rebalance_training_data.py` |

### Test Coverage

| Before Review | After Review |
|---------------|--------------|
| 85 tests | 228 tests |

### Lessons Learned from Code Review

- **#29**: Input validation is non-negotiable - sanitize ALL user input at service boundaries
- **#30**: Encrypt sensitive local storage - Hive alone is not secure
- **#31**: Use allowlists for external URLs - don't trust user-provided URLs
- **#32**: Verify downloads with checksums - prevent tampered model files
- **#33**: Accessibility from the start - Semantics widgets are easy to add
- **#34**: Migration frameworks prevent data loss - track schema versions
- **#35**: i18n infrastructure early - ARB files scale better than hardcoded strings

### Key Insight

> **Security and accessibility are not afterthoughts — they're architectural decisions.**

The code review revealed that many security features (encrypted storage, input validation) and accessibility patterns (Semantics widgets) could have been built in from the start with minimal overhead. Retrofitting them later required touching many files.

**Recommendation:** For future projects, include security and accessibility in the initial architecture template.

---

## Phase 9: The Instruct vs Base Model Discovery (v3.2-v3.4)

### v3.2: Fixed Data Format, New Issues

After v3.1's data format crisis, v3.2 correctly filtered for ChatML-only data and added diverse samples from IndicAlign. However, the Qwen3-0.6B model has internal bf16 operations that caused fp16 training issues on T4 GPUs.

### v3.3: FP32 Training, Wrong Base Model

v3.3 fixed the precision issue by training in FP32 mode (both fp16 and bf16 disabled). Training completed but the model output was broken.

**Root Cause:** Qwen3-0.6B is an **instruct** model with native `<think>` reasoning tokens. Our ChatML format (`<|im_start|>system/user/assistant<|im_end|>`) conflicted with its native chat template. The model tried to produce `<think>` blocks within our structure, producing broken output.

Additionally, learning rate 1e-4 was too aggressive for an already instruction-tuned model, causing catastrophic forgetting.

### v3.4: The Base Model Pivot

**Key Insight:** When the target model already has instruction-tuning with a specific chat format, SFT with a different format fights against the model's existing behavior. Using the **base** (non-instruct) variant provides a clean slate.

**v3.4 Changes:**
- **Qwen3-0.6B-Base** instead of Qwen3-0.6B (instruct)
- LR reduced from 1e-4 to 2e-5 (safer for fine-tuning)
- LoRA rank increased from 16 to 32 (base model needs more capacity to learn instruction-following)
- 3 epochs instead of 2 (base model needs more training passes)
- ChatML special tokens (`<|im_start|>`, `<|im_end|>`) explicitly added to tokenizer since base model doesn't have them

**Status:** Not yet validated on Kaggle. Also created `Test_Existing_Models.ipynb` to check if any previously uploaded HF models still work before investing in a new training run.

### Lessons Learned from Phase 9

- **#36**: Handle instruct model format conflicts with token suppression, not by pivoting to base model *(updated after v3.5 failure)*
- **#37**: Lower LR for instruct models (2e-5 not 1e-4) — prevents catastrophic forgetting
- **#38**: Qwen3 has internal bf16 ops — use FP32 training on non-Ampere GPUs (P100, T4)
- **#39**: Test existing HF checkpoints before new training runs — don't waste compute

---

## Phase 10: The Base Model SFT-Only Disaster (v3.5)

### The Pivot That Shouldn't Have Happened

After v3.3's `<think>` token issues with the Qwen3-0.6B instruct model, v3.4/v3.5 pivoted to the **base** model (Qwen3-0.6B-Base) to avoid the conflict. v3.5 also added DataCollatorForCompletionOnlyLM for completion-only masking — a technically correct improvement.

**The masking worked perfectly.** Preflight checks confirmed system/user tokens were masked with -100 and only assistant tokens were trained. Training completed all 795 steps with a healthy-looking loss curve (1.56 → 1.04).

### The Devastating Result

Every single eval response was **complete garbage** — code tokens, HTML attributes, JSON schemas, variable names, Chinese characters. The model was regurgitating its pre-training data instead of Tamil:

```
Q: வணக்கம்
A: _year_that=True_email="#_verified=True_date_group_url_count_role_order...

Q: தமிழ்நாட்டின் தலைநகரம் என்ன?
A: \\' />", // The data is not a valid JSON...
```

The eval script marked 12/12 tests as "passed" because it only checked for loops, system leaks, and empty responses — none of which matched code garbage.

### Why It Failed

**SFT-only on a base model CANNOT teach a new language.** Qwen3-0.6B-Base was pre-trained on code, web content, English, and Chinese. ~3K Tamil SFT samples are a drop in the ocean compared to its pre-training corpus. The model's "default mode" remained code/web generation. DAPT (domain-adaptive pretraining on raw Tamil text) was required first to shift the model's language distribution before SFT could teach it to follow instructions in Tamil.

**This was a known risk we documented ourselves.** Lesson #13 explicitly states: "Don't use single-pass SFT for language adaptation." We violated our own rule.

### The Real Mistake: Abandoning What Worked

v3.3 (instruct model) was **producing Tamil output**. It had specific, fixable issues:
1. `<think>` tags in output → fixable with token suppression during generation
2. LR 1e-4 too aggressive → fixable by reducing to 2e-5
3. Thirukkural-style responses → fixable with dataset rebalancing

Instead of spending ~1 hour fixing these issues, we spent hours on a pivot to base model SFT-only that produced a worse outcome. This is the most expensive lesson of the project so far.

### Lessons Learned from Phase 10

- **#40**: SFT-only on a base model CANNOT teach a new language — DAPT is required first to shift the language distribution
- **#41**: Iterate on working approaches rather than pivoting to untested ones — v3.3 produced Tamil with fixable issues, pivoting to base model was a regression
- **#42**: Eval must check output QUALITY (Tamil character %, coherence, semantic relevance), not just pattern absence (no loops, no leaks, not empty)
- **#43**: A healthy loss curve does NOT mean the model learned — loss can decrease on a subset of found samples while the model learns nothing useful
- **#44**: Strict ChatML validation (regex) before training — every SFT sample MUST have both user AND assistant segments with non-empty content; samples missing either contribute zero or wrong training signal

### Decision for v3.6

Return to the **instruct model** (Qwen3-0.6B) which already has Tamil capability and instruction-following. Fix the v3.3 issues:
1. Suppress `<think>` tokens during generation (not during training)
2. Use LR 2e-5 (not 1e-4)
3. Add completion-only masking (the one good thing from v3.5)
4. Strict ChatML validation + robust response template
5. Rebalanced dataset: Practical packs 40-50%, Conversational 20-30%, General knowledge 15-25%, Thirukkural/culture 10-20%
6. Early evaluation (after 50 steps) with Tamil character % check

---

## Phase 11: The LoRA Merge to 4-bit Catastrophe (v3.6)

### Everything Worked Except the Merge

v3.6 returned to the instruct model as planned. Everything was correct: strict ChatML validation (3,667 samples, all validated), preflight masking verified (35.5% trainable tokens), training completed without errors. The dataset was well-balanced with 15% Kural, 33 refusal/brevity/greeting samples added.

Then the merge step destroyed everything.

### The Corruption Mechanism

The model was loaded in 4-bit NF4 quantization for memory-efficient training. After training, `model.merge_and_unload()` was called on the 4-bit model. PEFT warned explicitly:

> "Merge lora module to 4-bit linear may get different generations due to rounding errors."

This was not a minor warning — it was catastrophic. The merge process:
1. Dequantizes 4-bit weights (massive precision loss already)
2. Adds LoRA delta (float16)
3. Stores result — but the dequantized 4-bit values are too imprecise for the sum to be meaningful

The result: 0/12 eval prompts produced any Tamil. Output was random punctuation/operators: `ooks = 1)0]:,. is:.. = *="-1., of,.....`

### Secondary Issue: Gradient Checkpointing During Eval

The eval code set `use_cache=True` but gradient checkpointing was still active from training. Transformers overrode to `use_cache=False` and `past_key_values=None`. This made generation run without KV cache — not the primary failure cause, but a bug that could cause subtle issues.

### A Third Unknown: Was Training Successful?

The loss curve was rendered as an HTML widget (`<IPython.core.display.HTML object>`) and not captured as text. We have no evidence that training actually converged. v3.7 must log loss values as text.

### Lessons Learned from Phase 11

- **#45**: NEVER merge LoRA into a 4-bit quantized model — the rounding errors destroy model output. After 4-bit QLoRA training, save the LoRA adapter separately, reload the base model in fp16 (full precision), apply the adapter to the fp16 model, then merge. The 4-bit quantization is for training memory only, not for the final merge
- **#46**: Disable gradient checkpointing before inference — `gradient_checkpointing` conflicts with `use_cache=True`, forcing generation to run without KV cache. Call `model.gradient_checkpointing_disable()` before any `generate()` calls. Also: always log loss values as text (not just HTML widgets) so convergence can be verified from notebook output

### Decision for v3.7

**Minimal fix** — v3.6's dataset, training config, and masking were all correct. Only change the post-training merge/eval pipeline:

1. Save LoRA adapter only (not merged model)
2. Delete 4-bit training model from GPU memory
3. Reload base model in fp16 (~1.5GB, fits easily on P100)
4. Load LoRA adapter onto fp16 model
5. Merge in fp16 — no rounding errors
6. Disable gradient checkpointing before eval
7. Eval the merged fp16 model
8. Push clean fp16 merged model to HuggingFace

---

*Document created: 2026-02-07*
*Last updated: 2026-02-12 (v3.6 failed, v3.7 pending)*
