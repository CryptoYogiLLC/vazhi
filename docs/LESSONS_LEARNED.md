# VAZHI Project: Lessons Learned

> Building a Tamil AI Assistant for Mobile: A Journey of Discovery

**Project:** VAZHI (வழி) - **V**oluntary **A**I with **Z**ero-cost **H**elpful **I**ntelligence
**Vision:** An open-source Tamil LLM that runs **offline on mobile phones** - free, transparent, Tamil-first
**Goal:** Deploy a Tamil-capable LLM on mobile devices (~250MB)
**Timeline:** February 2025
**Status:** v0.5 Training in Progress

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

### Week 4: SLM Training (Failed)

| Day | Milestone | What We Did | Outcome |
|-----|-----------|-------------|---------|
| **Day 15** | Data Prep v0.5 | Prepared 11,696 items, uploaded to HuggingFace | ✅ Dataset ready |
| **Day 16** | TRL Issues | Fixed multiple TRL 0.27.2 API changes | ✅ Training started |
| **Day 17** | Training Divergence | Loss exploded at step 1000 (0.53→2.57) | ❌ Training failed |
| **Day 18** | Recovery Training | New run with lower LR + grad clipping | ❌ Loss stable but output garbage |
| **Day 19** | Diagnosis | Tested checkpoints, found LoRA corrupted model | 💡 LoRA too aggressive for 0.5B |
| **Day 20** | Pivot Decision | Decided to test Sarvam-1 and Gemma 2B Tamil | 🔄 Next steps |

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

**Models We Discovered Too Late:**

| Model | Size | Tamil Quality | Source |
|-------|------|---------------|--------|
| Sarvam-1 | 2B | Excellent | sarvamai/sarvam-1 |
| Sarvam-1 GGUF | 1.17GB (IQ3_M) | Good | Already quantized! |
| Gemma 2B Tamil | 2B | Good | abhinand/tamil-gemma-2b-instruct-v0.1 |
| Tamil-LLaMA | 7B | Excellent | Too large for mobile |

**What We Should Have Done:**
```
Day 1: Test Sarvam-1 IQ3_M (1.17GB) for Tamil quality
Day 2: If good, try further compression or accept 1.17GB
Day 3: Only if Sarvam fails, train custom model
```

**Lesson #4:** Always survey existing solutions before building from scratch. The Tamil LLM space is more mature than we assumed.

---

### 2. Leveraged AI4Bharat Resources

**Resources We Didn't Use:**

| Resource | What It Offers | How It Would Have Helped |
|----------|----------------|-------------------------|
| **Sangraha** | 251M Tamil tokens of clean text | Pre-training data for Tamil fluency |
| **IndicAlign** | 74.7M instruction pairs | Massive instruction-tuning dataset |
| **IndicTrans2** | Translation models | Could augment training data |
| **Indic-Gemma** | Indian language Gemma variants | Pre-trained for Indian languages |

**What We Should Have Done:**
```python
# Instead of generating 11K samples manually:
from datasets import load_dataset

# Use IndicAlign's Tamil subset
indic_align = load_dataset("ai4bharat/IndicAlign", "tam")
# 74.7M instruction pairs vs our 11K!

# Supplement with Sangraha for fluency
sangraha = load_dataset("ai4bharat/sangraha", "tam")
```

**Lesson #5:** Don't reinvent the wheel. AI4Bharat has spent years curating Indian language data. Use it.

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

---

## What's Next

### Immediate (v0.5)
- Complete Qwen2.5-0.5B training
- Test Q4_K_M quantization
- Validate Tamil output quality

### If v0.5 Fails
1. Try Sarvam-1 IQ3_M (1.17GB) - accept larger size
2. Attempt Minitron compression on Sarvam
3. Explore vocabulary pruning

### Future Considerations
- Custom Tamil-optimized tokenizer
- Distillation from larger Tamil models
- Hybrid architecture (LLM + lookup tables)
- Investigate BitNet (1.58-bit) for extreme compression

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

*Document created: 2025-02-07*
*Last updated: 2025-02-07*
