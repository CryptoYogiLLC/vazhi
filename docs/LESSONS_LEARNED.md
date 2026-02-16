# VAZHI Project: Lessons Learned

> Building a Tamil AI Assistant for Mobile: A Journey of Discovery

**Project:** VAZHI (வழி) - **V**oluntary **A**I with **Z**ero-cost **H**elpful **I**ntelligence
**Vision:** An open-source Tamil LLM that runs **offline on mobile phones** - free, transparent, Tamil-first
**Goal:** Deploy a Tamil-capable LLM on mobile devices (<1GB target)
**Current Target:** Qwen3-0.6B with two-stage training (DAPT → SFT)
**Timeline:** February 2026
**Status:** Clean DAPT v2.1 data prep complete (39.5M tokens, 5-source corpus). Training notebook ready for Colab Pro GPU

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
| 40 | **4-bit quantization bypasses Tensor Cores** | bitsandbytes dequantization prevents fp16 speedup — if model fits in fp16, skip 4-bit entirely |
| 41 | **0.6B models don't need 4-bit for training** | 596M params in fp16 = 1.2GB, fits easily on T4/P100 — 4-bit adds overhead for no benefit |
| 42 | **Qwen3's 151K vocab creates huge logits** | [batch, seq, 151669] tensor limits max batch size — batch 8 OOMs on 15GB T4 |
| 43 | **Checkpoint frequently on Kaggle** | Save every 125 steps — compute quotas can cut sessions short, but any checkpoint is usable |
| 44 | Strict ChatML validation (regex) before training | Every SFT sample must have both user AND assistant segments with non-empty content |
| 45 | **NEVER merge LoRA into 4-bit model** | Save adapter → reload base in fp16 → merge in fp16. 4-bit is for training memory only |
| 46 | **Disable gradient checkpointing before eval** | Conflicts with use_cache, forces generation without KV cache |
| 47 | Validate **tokenized length**, not just character length | Tamil 3-4 tokens/char + ChatML overhead can exceed max_seq_length |
| 48 | **Automated eval metrics produce false positives** | 12/12 passed but all gibberish — eval must include factual accuracy checks |
| 49 | **LoRA r=16 on 7 modules too aggressive for ~1K samples** | Overparameterized, overfits to surface patterns. Use r=8 on q_proj+v_proj |
| 50 | **Clear generation_config.suppress_tokens before generating** | Avoids transformers CPU/CUDA device mismatch bug |
| 51 | **Separate retrieval from curation from composition** | Don't mix concerns — each stage uploads to HF for checkpointing |
| 52 | **max_seq_length controls training window, not response length** | Use 2048 to avoid rejecting 74% of domain packs due to 1024 window |
| 53 | **Store raw and curated datasets separately on HF** | Enables flexible reuse without re-running expensive retrieval/curation |
| 54 | **Two-pass curation: cheap CPU filters first, GPU scoring on candidates** | Saves GPU hours by reducing pool before expensive PPL/embedding computation |
| 55 | **PPL is a fluency metric, not quality** | Use as weak signal for garbage detection (>200), not as a gate — fluent gibberish is possible |
| 56 | **Toxic_Matrix is safety training data** | Don't filter with toxicity wordlist — route toxic prompt + safe refusal pairs to safety bucket |
| 57 | **Spot-check EVERY source before committing** | tamil-orca had misaligned Q&A (answers didn't match questions); 2-3 samples per source catches catastrophic issues |
| 58 | **Retrieve lean (2-3x), not broad** | 520K retrieval for 10K target is wasteful; can always do a targeted second pull if a bucket falls short |
| 59 | **Match data sources to product mission** | VAZHI users need scam protection, govt benefits, health, culture — not Commodore 64 trivia or math word problems |
| 60 | **SFT teaches task behavior, NOT language** | SFT (v5.0→v5.1a→v5.3) genuinely improved output — eliminated repetition loops, added structured formatting, varied vocabulary. But content is semantic gibberish because the model learned format without Tamil language understanding. SFT progress is real but insufficient without DAPT |
| 61 | **Don't blame the methodology — blame the data** | DAPT v1.1 was abandoned because it "destroyed instruction-following", but the real culprit was contaminated corpus (English/Tanglish in Sangraha at 70% threshold). DAPT as a methodology is correct |
| 62 | **DAPT before SFT is non-negotiable for low-resource languages** | Trying to teach Tamil tasks (SFT) before teaching Tamil language (DAPT) is like teaching legal writing in a language the student barely knows |
| 63 | **High Tamil WORD score ≠ coherent Tamil** | v5.1a scored 95% Tamil word validation but outputs were semantic nonsense — individual words look real but sentences have no meaning |
| 64 | **70% Tamil threshold is too low for DAPT corpus** | Sangraha filtered at 70% still contained significant English/Tanglish contamination. Use >90% for clean DAPT |
| 65 | **Instruction preservation requires chat data replay** | DAPT v1.1 used 0% chat replay → destroyed instruction-following. Need 5-15% chat data mixed into DAPT to preserve existing capabilities |
| 66 | **Smaller DAPT token budget for 0.6B models** | 55M tokens overwhelmed the 0.6B model. Target 10-20M tokens with LR 1-2e-5 |
| 67 | **Never run data pipelines locally that belong on Colab** | Heavy data processing (filtering large HF datasets, computing embeddings) should run on Colab/Kaggle — local OOM crashes waste time and risk system stability |
| 68 | **Investigate skipped data sources before acquiring new ones** | IndicAlign Wiki_Chat/Wiki_Conv were skipped for OOM reasons (infrastructure), not quality reasons — they were never evaluated and could be significant Tamil sources |

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

## Phase 12: DAPT v1.0 — First Successful Training (Feb 12, 2026)

After 13 consecutive failures, DAPT v1.0 is the first training run that produced a working Tamil model.

### What Changed

The key insight was **separating language learning (DAPT) from instruction-following (SFT)**. All previous attempts tried to teach Tamil AND instruction-following in a single SFT pass — this consistently failed because:
- SFT-only on instruct models: model already knows instructions but can't learn Tamil fluency from Q&A pairs alone
- SFT-only on base models: model has no Tamil foundation, produces code/HTML garbage

DAPT trains on raw Tamil text (Sangraha corpus) to teach the model Tamil patterns, vocabulary, and structure. SFT comes after to add instruction-following.

### Training Details

- **Data prep (Colab CPU):** Streamed Sangraha verified Tamil → filtered 16,450 docs → packed 32,244 blocks of 1024 tokens → uploaded to HF
- **Training (Kaggle T4):** fp16 (no 4-bit), LoRA r=16, batch 4 × grad_accum 8, LR 2e-5 cosine, 375/500 steps (~3.5 hours)
- **Results:** Val loss 1.045 → 1.016, eval 8/8 passed, avg Tamil 66%, avg unique 97%

### Key Technical Lessons

1. **4-bit quantization was the speed bottleneck** — bitsandbytes dequantization bypasses Tensor Cores entirely, causing identical 0.03 it/s on P100 and T4. Removing 4-bit and loading in fp16 directly was faster AND simpler.
2. **Qwen3's 151K vocab creates massive logits tensors** — [8, 1024, 151669] in float32 = ~5GB, making batch 8 impossible on 15GB T4.
3. **Gradient checkpointing is essential on T4** — without it, batch 4 OOMs during backward pass.
4. **Checkpoint early, checkpoint often** — Kaggle compute quotas can cut sessions short. Saving at steps 125/250/375 meant we got a usable model even when stopping at step 375.

### Artifacts

- Merged fp16 model: `CryptoYogi/qwen3-0.6b-tamil`
- LoRA adapter backup: `CryptoYogi/qwen3-0.6b-tamil-lora`
- DAPT dataset: `CryptoYogi/vazhi-dapt-tamil-v1_0`

---

## Phase 13: SFT v4.0 — Instruction Fine-Tuning on DAPT v1.1 (Feb 13, 2026)

### Lessons Learned

- **#47**: Dataset Factory must validate **tokenized length**, not just character length — a 1500-char character filter allows samples that exceed `max_seq_length` (1024 tokens) after tokenization due to Tamil's 3-4 token/char ratio + ChatML overhead. The `DataCollatorForCompletionOnlyLM` gracefully skips these (loses them from training), but the data is wasted. Fix: add a tokenizer-based length check in the Dataset Factory that rejects any sample whose tokenized form exceeds `max_seq_length`

- **#48**: **Automated eval metrics produce false positives** — SFT v4.0 scored 12/12 on automated checks (Tamil %, repeat ratio, code detection, emptiness) but EVERY response was semantic gibberish. Tamil char % was 61% average — "Tamil-looking text" ≠ "coherent Tamil answers." Eval MUST include factual accuracy checks (e.g., "Capital of TN" must contain "சென்னை") and human-readable content review, not just automated metrics

- **#49**: **LoRA r=16 targeting all 7 projection modules is too aggressive for ~1K samples** — With only 1,365 training samples, LoRA r=16 on q/k/v/o/gate/up/down gives too many trainable parameters relative to data. The model overfits to surface patterns (produces Tamil-looking token sequences with random numbers, English fragments, and nonsensical content). SFT v4.0 result: DAPT (89% Tamil, fluent text continuation) > SFT (81% Tamil, gibberish with formatting) > Vanilla (75%). Next iteration: r=8 targeting only q_proj+v_proj, 2 epochs instead of 3

- **#50**: **Clear `generation_config.suppress_tokens` before generating** — When a model is saved with `suppress_tokens` in its `generation_config.json`, `generate()` auto-injects the built-in `SuppressTokensLogitsProcessor` which has a CPU/CUDA device mismatch bug in transformers 2.8.0 (`RuntimeError: Expected all tensors to be on the same device`). Fix: always `model.generation_config.suppress_tokens = None` before calling `generate()`, and use a custom logits processor for token suppression

---

## Phase 14: 3-Stage Data Pipeline (Dataset Factory v4.1)

### The v4.0 Failure Analysis

SFT v4.0 used a monolithic Dataset Factory that retrieved, filtered, and composed in a single pass. This caused:
1. **Cascading downsampling** — percentage-based composition anchored on domain_packs, so shrinking one bucket shrank everything
2. **74% domain pack rejection** — max_seq_length=1024 was too small after Tamil tokenization (3-4 tokens/char) + system prompt overhead (~100 tokens)
3. **Only 1,365 training samples** — too few for LoRA r=16 on 7 modules to generalize

### The 3-Stage Solution

**Lesson #51: Separate retrieval from curation from composition.** Each concern has different compute requirements and failure modes. Separating them with HF uploads between stages provides:
- **Checkpoint recovery** — if Stage 3 fails, Stage 1-2 data is preserved
- **Flexible reuse** — raw and curated datasets can be recomposed without re-retrieval
- **Independent iteration** — can improve curation without re-downloading raw samples

**Lesson #52: max_seq_length controls training window, not response length.** The model learns from actual data lengths, not max_seq_length. Using 2048 simply prevents the training collator from truncating/skipping samples that exceeded the 1024 window. This single change recovered 74% of domain pack samples.

**Lesson #53: Store raw and curated datasets separately on HF.** The raw dataset (`vazhi-raw-tamil-qa-v1`) is moderately expensive to collect (streaming from multiple HF sources). The curated dataset adds ML-derived quality signals. Storing both enables recomposition with different quality thresholds without re-running curation.

### Two-Pass Curation

**Lesson #54: Cheap CPU filters first, GPU scoring on candidates only.** Pass 1 (CPU, ~15-30 min) runs fasttext language detection, heuristic quality filters, MinHash deduplication, and toxicity screening. This typically reduces the pool by 40-60%. Pass 2 (GPU, ~2-4 hours) then runs perplexity scoring and semantic clustering on the surviving candidates only — saving hours of GPU time.

### Perplexity as Signal, Not Gate

**Lesson #55: PPL is a fluency metric, not quality.** Low perplexity means the text is fluent according to the scoring model (DAPT v1.1). But fluent gibberish is possible — SFT v4.0 produced text that was 81% Tamil characters but completely nonsensical. PPL > 200 reliably detects garbage (random tokens, code fragments), but PPL < 50 does NOT guarantee the content is correct, coherent, or useful. Use PPL as a weak garbage filter, not a quality gate.

### Safety Data Routing

**Lesson #56: Toxic_Matrix is safety training data, not noise.** IndicAlign's Toxic_Matrix (~90K samples) and HHRLHF_T (~33K samples) contain toxic prompts paired with safe refusal responses. A naive toxicity wordlist would filter these out entirely. Instead, source-aware classification checks: if the toxic content is in the instruction AND the output is a clean refusal, route to the safety bucket. This teaches the model to refuse harmful requests — exactly the behavior we want.

### Lessons Learned from Phase 14

- **#51**: Separate retrieval from curation from composition — don't mix concerns. Each stage uploads to HF for checkpointing
- **#52**: max_seq_length controls training window, not response length — use 2048 to avoid rejecting 74% of domain packs
- **#53**: Store raw and curated datasets separately on HF — enables flexible reuse without re-running expensive retrieval/curation
- **#54**: Two-pass curation — cheap CPU filters first (lang-id, heuristics, dedup), GPU scoring on candidates only
- **#55**: PPL is a fluency metric, not quality — use as weak signal for garbage detection (>200), not as a gate
- **#56**: Toxic_Matrix is safety training data — don't filter with toxicity wordlist, route to safety bucket
- **#57**: Spot-check EVERY source before committing to it — tamil-orca had misaligned Q&A (answers didn't match questions), GSM8K_TAMIL had irrelevant content (math word problems). 2-3 samples per source catches catastrophic issues
- **#58**: Retrieve lean (2-3x of target), not broad — 520K retrieval for 10K target is wasteful. Can always do a targeted second pull if a specific bucket falls short
- **#59**: Match data sources to product mission — VAZHI serves rural Tamil Nadu users (scam protection, govt benefits, health, culture). World knowledge Q&A (Commodore 64, economics) and math word problems don't serve these users

### Lessons Learned from Phase 15 — Pipeline Execution on Colab Pro

- **#60**: HDBSCAN is O(n²) and impractical for 35K+ high-dimensional samples — 22+ min on 35K × 768-dim embeddings with no progress. Use keyword-based domain classifier instead: instant, human-readable labels, directly supports selective domain emphasis in future SFT
- **#61**: Source-aware filtering is essential — hand-curated product data (vazhi_packs, handcrafted) must bypass ALL automated quality filters (lang-id, tamil_pct, quality_score, PPL). These define the product voice and were manually vetted. Automated filters kill Tanglish content
- **#62**: Checkpoint after expensive GPU steps — PPL scoring takes 15+ min on GPU. Save results to local JSON immediately after completion. Add a checkpoint resume cell at notebook start to skip Pass 1 + PPL on Colab restart
- **#63**: Qwen3's 151K vocab needs VRAM-aware batch sizing — logits tensor = batch × seq × 151K × dtype_bytes. batch=64 × 512 × 151K × 2 = ~10GB → OOM on L4 (22GB). Use VRAM-based scaling: 8 (T4), 16 (L4), 32 (A100)
- **#64**: Keyword domain classifier beats unsupervised clustering for known domains — when target domains are predefined (healthcare, legal, education, security, government, culture), keyword matching with 2-hit minimum is faster, more interpretable, and more actionable than HDBSCAN clusters
- **#65**: Route safety samples by dataset subset name, not toxicity wordlist — a 12-phrase wordlist catches <3% of Toxic_Matrix/HHRLHF_T. Route ALL samples from these subsets to safety bucket by subset field. For a 0.6B model, safety data must be in main SFT (catastrophic forgetting risk with separate fine-tuning)

### Lessons Learned from Phase 16 — SFT v4.1 Notebook Design

- **#66**: Never rely on loss curves alone to validate training — SFT v4.0 had healthy loss (1.43→1.03) but all outputs were Tamil gibberish. Add mid-training generation checks (`MidTrainingGenCheck` callback) that generate actual Tamil responses at each eval step to catch garbage during training, not just at the end
- **#67**: Eval must test conversational quality, NOT factual accuracy — the model is not a knowledge base. Factual lookups (capital of TN, Pongal dates, etc.) are handled by the hybrid architecture (SQLite). SFT eval should test: Tamil fluency, instruction-following, appropriate tone, safety (no hallucinated contacts), coherent responses. Automated Tamil% metrics gave 12/12 false positives in v4.0 — conversational quality checks (repetition, code garbage, empty responses, hallucinated contact info) catch what metrics miss
- **#68**: LoRA r=16 on 7 modules is overparameterized for ~1K samples — too many trainable parameters causes overfitting to surface patterns (fluent-looking Tamil with no semantic content). Use r=8 on q_proj+v_proj for datasets under 15K samples
- **#69**: max_seq_length must account for system prompt overhead — Tamil uses 3-4 tokens/char, and ChatML system prompts add ~200 tokens. max_seq_length=1024 rejected 74% of domain packs. Use 2048 for training window (controls context, not response length)

### Lessons Learned from Phase 17 — SFT v4.1 Training + DAPT Failure Diagnosis

- **#70**: DAPT on instruct model can destroy instruction-following — DAPT v1.1 (LR 5e-5, full epoch 55M tokens, LoRA r=16 on instruct model) completely overwrote chat behavior. Raw text next-token prediction shifted the model toward continuation, not instruction-following. Vanilla Qwen3-0.6B responds correctly to greetings and follows system prompts; DAPT model produces gibberish/echoes/repetitive loops on the same prompts
- **#71**: Instruction-preserving DAPT requires constraints — if DAPT on instruct model is needed, use: (1) lower LR (1-2e-5 not 5e-5), (2) smaller token budget (5-15M not 55M), (3) 5-15% chat/instruction data replay mixed into the DAPT dataloader to keep the model "remembering" chat behavior
- **#72**: "Healthy loss curves" + "passes automated metrics" does NOT mean success — SFT v4.1 had train loss 0.93→0.79 (healthy), eval loss stable at 0.86, AND 16/16 eval prompts "passed" automated checks (high Tamil %, zero repetition, no code garbage). But ALL outputs were semantic gibberish (Tamil word soup). The eval criteria need to test MEANING not just surface signals. This is now the second time (v4.0: 12/12, v4.1: 16/16) that automated eval gave false positives
- **#73**: Always establish a no-DAPT baseline first — before investing in DAPT+SFT, run SFT directly on the vanilla instruct model to isolate whether the SFT pipeline works. If SFT-on-vanilla produces coherent output, DAPT was the variable. If it doesn't, the problem is in the SFT pipeline itself. This prevents wasting multiple runs diagnosing a DAPT problem when you think it's an SFT problem (or vice versa)
- **#74**: Hub checkpoints need full training completion — SFT v4.1 interrupted at step 3068/3272 (94%), and only the step-1635 checkpoint (1 epoch) was on Hub. The final save at step 3272 never happened. Local checkpoints lost on Colab session restart. Always ensure training runs to completion, or save more frequently (save_steps = steps_per_epoch // 2)

### Lessons Learned from Phase 18 — SFT v4.2 Training (Vanilla Baseline) + Eval Failure

- **#75**: Tamil char % is a fundamentally broken eval metric — SFT v4.2 outputs are transliterated English gibberish in Tamil script (e.g., "ஜென்னுஸ் ரெஃப்ஸ் ஹோர்ட் பிளாஸ்ட்" = "Genus Refs Hort Blast"). This scores 75-88% Tamil chars and PASSES automated eval, but every word is nonsensical. Need Tamil WORD validation: dictionary-based lookup, Tamil bigram frequency analysis, or Tamil LM perplexity scoring on responses. Character-level metrics cannot distinguish real Tamil from transliterated foreign language
- **#76**: SFT can catastrophically forget Tamil on small models — vanilla Qwen3-0.6B produces coherent short Tamil ("வணக்கம் 😊"), but after LoRA SFT (r=8, LR 5e-5, 2 epochs, 13K samples), ALL outputs are long incoherent gibberish. This is the SAME catastrophic forgetting pattern seen in DAPT but reversed: DAPT forgets instruction-following, SFT forgets Tamil. The 0.6B model may lack capacity to retain one capability while acquiring another
- **#77**: Four consecutive false positive evals (v3.8 0/12, v4.0 12/12, v4.1 16/16, v4.2 16/16) prove that automated eval must be fixed BEFORE more training runs — each run takes 30-45 min of Colab Pro GPU time plus iteration time. Without reliable eval, every training run is a coin flip that wastes resources. Priority order: fix eval → inspect dataset → then retrain

### Lessons Learned from Phase 19 — Dataset v5.0 Build (Two-Source Tamil Strategy)

- **#78**: Two-source Tamil data strategy works — (1) Sadhguru Tamil articles restructured into Q&A by CC agents (97-98% Tamil, no translation needed), (2) domain packs regenerated with Tamil responses. This eliminates the 75.8% garbage English that plagued v4.1. Key insight: use existing high-quality Tamil text as source material for Q&A pairs rather than relying on LLM Tamil generation
- **#79**: CC agents can't reliably bulk-generate Tamil for 300+ items — healthcare/security/culture packs succeeded (78-86% Tamil), but legal/education/govt all failed (3-8% Tamil). Agents either wrote Python scripts instead of Tamil content, or produced English despite explicit instructions. Template-based generation (hardcoded Tamil per category, matched by keyword patterns) is deterministic and reliable for domain packs
- **#80**: Sadhguru's Tamil article corpus is a goldmine — 596 articles (3,419 total on site), covering health, daily life, culture, festivals, family. Articles are natural, high-quality Tamil prose. CC agents restructured 562 filtered articles into 615 Q&A pairs averaging 97-98% Tamil. The key is that the Tamil words come FROM the articles; the agent only restructures into Q&A format
- **#81**: Thirukkural verbatim recitation is dangerous for SFT — of 426 Thirukkural items in v4.1, 258 were verbatim "recite this kural" items that could cause the model to parrot Kural-style responses for unrelated questions. Filtered to 168 Q&A-format items only (interpretive questions about Kural meaning/application)
- **#82**: Dataset quality trumps quantity — v4.1 had 13K samples but 75.8% garbage; v5.0 has 5.7K samples but 82.7% Tamil avg. A small clean dataset is far more valuable than a large contaminated one for teaching Tamil to a 0.6B model

### Lessons Learned from Phase 20 — SFT v5.0 Training + Safety Mode Collapse

- **#83**: Conservative LoRA (LR 1e-5, 1 epoch) on vanilla model WORKS — v5.0 was the first run to produce coherent Tamil output. The key was: (1) LR 5x lower than v4.2's catastrophic 5e-5, (2) single epoch prevents forgetting, (3) clean dataset (85.2% Tamil vs v4.1's 75.8% garbage). Sometimes less is more for 0.6B models
- **#84**: Safety data percentage is critical for small models — v5.0 had 1,800 safety items (30.6% of dataset), causing mode collapse where every response included "தீங்கு" (harm). A 0.6B model over-indexes on high-frequency patterns. Cutting to 200 (4.6%) in v5.1, then to 45 (1%) in v5.2, progressively fixed the issue
- **#85**: Tamil WORD validation catches what char % misses — bigram-based Tamil word validator (checking word structure, virama usage, common Tamil trigrams) correctly identifies transliterated English gibberish that scores 75-88% on char %. This fixed the 4 consecutive false positive evals (v3.8-v4.2)

### Lessons Learned from Phase 21 — Iterative SFT (v5.0 → v5.1a) + Conversational Data

- **#86**: Iterative single-epoch training preserves capabilities — training v5.1a on top of v5.0 (rather than from vanilla) successfully preserved Tamil patterns while adding new data. The lineage vanilla → v5.0 → v5.1a works because each epoch is conservative (LR 1e-5) and doesn't overwrite previous learning
- **#87**: Conversational fundamentals must be explicitly in the dataset — v5.1 had only 5 conversational items out of 4,321. A 0.6B model cannot infer greeting/identity/chitchat behavior from a system prompt alone. Adding 200 explicit conversational items (greetings, identity, farewells, colloquial TN Tamil) in v5.2 was necessary

### Lessons Learned from Phase 22 — Sadhguru Q&A v1 Audit + v2 Fix

- **#88**: Multi-agent LLM pipelines can silently produce garbage at scale — Sadhguru Q&A v1 used CC sonnet agents to generate 1,001 Q&A pairs from 562 articles. Audit found: 35% duplicates (4 blocks of 50x identical generic text), 41% Q-A echo (copy-pasted opening sentence as both Q and A), only 38% of articles used, avg answer ~300 chars vs 5,500+ char articles. The agents hallucinated rather than extracted
- **#89**: Use source text directly instead of LLM-generated content when possible — Sadhguru Q&A v2 bypasses LLM generation entirely, using the raw article text as answers. Result: 562 pairs (100% unique, avg 734 words) vs v1's 1,001 pairs (652 unique, ~300 chars). Direct extraction produces higher quality and longer-form training data than LLM restructuring
- **#90**: HTML artifacts survive multiple processing stages — even after the initial scraping pipeline cleaned articles, 56 entries still had `[pullquote]`, `[SadhguruImage]`, `[separator]` artifacts. Case-insensitive regex and catch-all bracket tag removal (`re.sub(r'\[/?[A-Za-z]+[^\]]*\]', '', text)`) was needed as a final safety net
- **#91**: Long-form answers are valuable for SFT — short answers (~300 chars) teach the model to give terse responses. Sadhguru articles averaging 734 words provide diverse, substantive Tamil prose that teaches the model both vocabulary breadth and the ability to give detailed explanations. The max_seq_length=2048 truncation is acceptable since the model learns voice/style from the opening content

### Lessons Learned from Phase 23 — Clean DAPT v2.0 (Data Prep + Training)

- **#92**: Qwen3 tokenizer is ~1 token/char for Tamil, not 3.5 — the 3.5 tokens/char estimate (common for other tokenizers) is wildly wrong for Qwen3's 151K vocab. This means the same text corpus produces ~3.5x fewer tokens than expected. Plan estimated ~15M tokens from 4.4M chars but got only 4.8M. Always compute actual token counts with the target tokenizer before committing to a training plan
- **#93**: 4.8M DAPT tokens is insufficient for language acquisition on 0.6B models — v2.0 showed directional improvement (Tamil char +20%, word +16%) but the model still produces fabricated Tamil words. v1.1 used 55M tokens and showed +55% improvement. There's likely a critical mass threshold (~30-50M+ tokens) below which the model can't learn real vocabulary. Metrics improve (more Tamil-looking tokens) before actual language quality does
- **#94**: Multi-epoch DAPT with interim eval gates beats fixed epoch count — train 1 epoch → eval → decide. Epoch 1 showed 14.5% loss drop and +19% word improvement. Epoch 2 showed only 2.0% loss drop and no quality improvement (plateaued at 95% word). Stopping after 2 instead of blindly running 3-4 epochs saved compute
- **#95**: Cosine LR schedule decays to ~0 by epoch end — if doing multi-epoch DAPT with separate training passes, create a fresh Trainer for each epoch to get a new cosine warmup→decay cycle. Resuming with the old optimizer's near-zero LR wastes the entire epoch
- **#96**: Host DAPT source files on HuggingFace for reproducible Colab runs — upload source files to an HF dataset repo (`vazhi-dapt-sources-v2_0`), download in Colab via `hf_hub_download`. Eliminates manual file uploads, makes notebooks reproducible, and enables sharing with collaborators
- **#97**: tamil_char_pct denominator must exclude whitespace and digits — including spaces/digits in the denominator artificially deflates Tamil percentage. 562 Sadhguru articles showed 87% Tamil with naive denominator vs 97% with corrected denominator `sum(1 for c in text if not c.isspace() and not c.isdigit())`. The 10% difference caused an assertion failure
- **#98**: DAPT methodology is confirmed correct — DAPT v2.0 improved Tamil metrics, preserved instruction following (9/9), and used clean data (>=90% Tamil). The direction is right: clean data + conservative LR + chat replay works. The only issue is volume — need 30-50M+ tokens, not 4.8M. Data acquisition is the bottleneck, not methodology

### Lessons Learned from Phase 24 — Clean DAPT v2.1 Data Prep

- **#99**: IndicAlign Wiki_Chat is excellent DAPT source — 97.6% Tamil avg, 99.6% docs ≥90%, long-form (4854 chars/doc, 1755 chars/turn), diverse topics (wildlife, politics, movies, literature, history, cricket). 32 parquet shards with potentially 160K+ Tamil docs. Use `tam_Taml` column for Tamil text
- **#100**: IndicAlign Wiki_Conv is useless for DAPT — 115 chars/turn (too short), formulaic factoid Q&A ("Where is X?" / "Sure, what do you want to know?"). High Tamil % (96%) but zero depth or language diversity. Reject for DAPT
- **#101**: Cap any single DAPT source at 60-70% — encyclopedic dominance (Wiki_Chat) risks tone drift. GPT5.2 recommended 60-70% max. Diverse source mix (conversational + procedural + literary + encyclopedic) produces better language models than volume from one source
- **#102**: Chat replay must be 5-10% of DAPT tokens, not 1% — v2.0 had 1.4% (200K tokens) which is too thin. GPT5.2 recommended 5-10% (2-5M tokens). v2.1 achieved 10.9% (4.2M tokens from OpenAssistant_T + Indic_ShareLlama + Dolly_T + local SFT). Critical for preserving instruction-following during DAPT
- **#103**: IndicAlign Anudesh has no Tamil — different schema (`interactions` column with English text, not `tam_Taml`). Don't assume all IndicAlign configs have Tamil. Check schema first
- **#104**: Streaming IndicAlign at scale needs Colab High RAM — local machine OOM'd when scanning 32 parquet shards. Data prep is CPU-only but memory-intensive. Run on Colab Pro with High RAM option
- **#105**: Fresh start on vanilla model when token budget is sufficient — with 39.5M tokens (8.2x v2.0), no need to build incrementally on v5.3 (which has SFT artifacts). Clean DAPT from scratch avoids inheriting v5.3's semantic gibberish patterns

---

*Document created: 2026-02-07*
*Last updated: 2026-02-15 (DAPT v2.1 data prep complete, training notebook ready, 105 lessons learned)*
