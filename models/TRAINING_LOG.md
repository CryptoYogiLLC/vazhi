# VAZHI Model Training Log

This log captures all training runs, decisions, and rationale to prevent repeating mistakes.

---

## Version History

| Version | Date | Status | Key Changes |
|---------|------|--------|-------------|
| v0.1 | 2026-02-05 | ❌ Failed | Initial training, Culture pack hallucination |
| v0.2 | 2026-02-06 | ❌ Failed | Added culture_v2 data, still hallucinating |
| v0.3 | 2026-02-06 | ⏸️ Skipped | Heavy augmentation planned but root cause found |
| v0.4 | 2026-02-06 | ❌ Failed | GGUF quantization produced gibberish output |
| v0.5 | 2026-02-07 | ❌ Failed | SLM approach with Qwen2.5-0.5B - LoRA corrupted model |
| v0.6 | 2026-02-07 | ❌ Failed | Sarvam-2B + IndicAlign Anudesh - 4-bit training corrupted model |
| v0.7 | 2026-02-08 | ❌ Failed | Gemma-2B Tamil - Training worked but GGUF conversion failed (tokenizer holes) |
| v0.8 | 2026-02-09 | ⏸️ Superseded | Qwen3-0.6B - Two-stage Micro-DAPT + SFT on Kaggle (superseded by v3.x series) |
| v3.1 | 2026-02-10 | ❌ Failed | Qwen3-0.6B SFT - Mixed data formats caused "systemsystemsystem..." output |
| v3.2 | 2026-02-10 | ❌ Failed | Qwen3-0.6B SFT - ChatML-only fix, fp16 on T4, but fp16 training issues |
| v3.3 | 2026-02-10 | ❌ Failed | Qwen3-0.6B (instruct) - `<think>` tokens conflicted with ChatML, LR too aggressive |
| v3.4 | 2026-02-11 | ⏸️ Superseded | Qwen3-0.6B-**Base** (not instruct) - LR 2e-5, LoRA r=32, 3 epochs. Never run — missing completion-only masking |
| v3.5 | 2026-02-11 | ❌ Failed | Qwen3-0.6B-Base + DataCollatorForCompletionOnlyLM — completion-only masking worked but SFT-only on base model without DAPT produced code/HTML garbage instead of Tamil |
| v3.6 | 2026-02-12 | ❌ Failed | Return to Qwen3-0.6B instruct — dataset + masking + training all correct, but LoRA merge into 4-bit model corrupted weights. Output: random punctuation/operators (0% Tamil) |
| v3.7 | 2026-02-12 | ⏳ Pending | Same as v3.6 but fix LoRA merge: save adapter → reload base in fp16 → merge in fp16. Also: disable gradient checkpointing before eval, add text-based loss logging |

---

## v0.1 Training Run

**Date:** 2026-02-05
**Base Model:** Qwen2.5-3B-Instruct
**Training Data:** 3,007 samples
**Epochs:** 3
**LoRA Rank:** 16

### Results
- ✅ Security, Government, Education, Legal, Healthcare: Reasonable
- ❌ Culture pack: Complete hallucination for Thirukkural

### Issues Identified
1. Thirukkural first kural was WRONG
2. Siddhars content truncated
3. Template marker leakage
4. Model generated nonsense Tamil poetry

### Decision
> Decided to add more Thirukkural data (culture_v2) assuming the issue was data quantity.

---

## v0.2 Training Run

**Date:** 2026-02-06
**Base Model:** Qwen2.5-3B-Instruct
**Training Data:** 3,180 samples (3,007 + 173 culture_v2)
**Epochs:** 3
**Duration:** 56:48 (~57 minutes)
**Final Loss:** Training 0.54, Validation 0.76

### Training Progress
| Step | Training Loss | Validation Loss |
|------|---------------|-----------------|
| 200 | 0.9788 | 0.956 |
| 400 | 0.7541 | 0.872 |
| 600 | 0.7150 | 0.812 |
| 800 | 0.5876 | 0.787 |
| 1000 | 0.5428 | 0.761 |
| 1074 | - | - |

### Results
- ✅ Security: Good scam detection, OTP warnings
- ✅ Government: CMCHIS process correct
- ✅ Education: Engineering options listed
- ✅ Legal: RTI explanation decent
- ✅ Healthcare: Government hospital info correct
- ❌ Culture: Still hallucinating Thirukkural!

### Test Output Examples

**Thirukkural (FAILED):**
```
Q: திருக்குறளின் முதல் குறள் என்ன?
A: நாயன்மார் செய்தியும் காட்டியும் வேண்டாம்... (NONSENSE!)
```

**Security (PASSED):**
```
Q: Scam message-ஐ எப்படி identify பண்றது?
A: Scam message characteristics: 1) Urgency create பண்றாங்க... (CORRECT)
```

### Root Cause Analysis

**Initial Hypothesis:** Not enough Thirukkural samples
**Actual Root Cause:** Data labeling mismatch!

Analysis revealed:
- 74% of outputs labeled "pure_tamil" are actually mostly English
- 60% of "pure_tamil" samples have <30% actual Tamil characters
- Model learned: "Tamil question → English answer"

**Key Finding:**
```
Labeled Language Distribution:
- pure_tamil: 43.4%
- tanglish: 38.4%
- mixed: 18.2%

ACTUAL Output Language (character analysis):
- mostly_english: 74.1%  ← THE PROBLEM!
- mostly_tamil: 13.5%
- mixed: 12.4%
```

### Decision
> DO NOT proceed with more training. The training data itself is flawed.
> Need complete data regeneration with actual Tamil content.

### Lessons Learned
1. **Verify data quality, not just quantity** - Labels can lie
2. **Character-level language analysis** reveals true content
3. **More epochs won't fix bad data** - Garbage in, garbage out
4. **Thirukkural needs citation format** - Not generative poetry format

---

## v0.3 (Skipped)

**Date:** 2026-02-06
**Status:** Prepared but not executed

### What Was Planned
- Heavy augmentation: 5x repetition of critical Culture entries
- 170 new samples (First Kural: 75 samples, Siddhars, etc.)
- Increase epochs to 5, LoRA rank to 32

### Why Skipped
Root cause analysis revealed the problem isn't data quantity but data quality.
Even with 75 samples of the correct first kural, the model would still:
1. Learn to output English (because 74% of training is English)
2. Not understand Tamil well (base model has limited Tamil)

> Decision: Skip v0.3 and do proper data regeneration for v0.4

---

## v0.4 Training Run (Failed - Quantization Issues)

**Date:** 2026-02-06 to 2026-02-07
**Status:** ❌ Failed

### Key Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Technical terms | Bilingual first mention | "Website (இணையதளம்)" → clear + teaches Tamil |
| Tanglish ratio | Natural mix | Authentic to how Tamils actually speak |
| Culture source | Verify against authoritative | Ensure accuracy, not hallucination |
| Sample count | Expand to 5,000+ | More coverage for better generalization |

### Data Regeneration Strategy

1. **Audit existing data**
   - Keep: ~385 samples (>70% Tamil) - 13.5%
   - Review: ~355 samples (30-70% Tamil) - 12.4%
   - Regenerate: ~2,122 samples (<30% Tamil) - 74.1%

2. **Language policy**
   - Pure Tamil: Traditional topics, culture, formal govt
   - Tanglish: Modern topics, tech, casual queries
   - Bilingual: Technical terms with Tamil explanation

3. **Culture pack special handling**
   - Format as CITATIONS, not generations
   - Quotation marks around kurals
   - Source attribution
   - Verify against authoritative Thirukkural text

4. **Template-based generation**
   - Created templates for each pack
   - Structured responses with Tamil vocabulary
   - Consistent formatting

### Files Created
- `/scripts/data_regeneration/templates.py` - Pack templates and Tamil vocabulary
- `/docs/DATA_REGENERATION_PLAN.md` - Detailed regeneration plan

### Progress

**Completed:**
1. [x] Create regeneration pipeline - `scripts/data_regeneration/`
2. [x] Audit and categorize existing samples - Done!
3. [x] Generate authoritative Culture data - 145 samples

**Audit Results (2026-02-06):**
| Category | Count | % |
|----------|-------|---|
| Keep (>70% Tamil) | 421 | 13.2% |
| Review (30-70%) | 394 | 12.4% |
| Regenerate (<30%) | 2,365 | 74.4% |

**Authoritative Culture Data Generated:**
- Thirukkural: 74 samples (21 for first kural alone!)
- Siddhars: 66 samples (all 18 + overview)
- Siddha Medicine: 5 samples
- Total: 145 samples
- Tamil %: Average 94.3%, All >70%

### GGUF Quantization Failure

After successfully training the Qwen2.5-3B model with improved data, we attempted GGUF conversion for mobile deployment.

**Quantization Attempts:**

| Format | File Size | Result |
|--------|-----------|--------|
| F16 | ~6.2GB | ⚠️ Too large for mobile |
| Q8_0 | ~3.2GB | ❌ Gibberish Tamil output |
| Q4_K_M | ~1.8GB | ❌ Gibberish Tamil output |
| Q4_0 | ~1.7GB | ❌ Gibberish Tamil output |

**Observed Issues:**
1. Model outputs random Tamil-looking characters that form no coherent words
2. Sentence structure completely broken
3. Even simple greetings like "வணக்கம்" produced nonsense
4. English responses were also degraded but slightly better than Tamil

**Example of Gibberish Output (Q4_K_M):**
```
Q: திருக்குறளின் முதல் குறள் என்ன?
A: கூறிய் லக்கிய் சிறப்பு கொண்ட ஆற்றல்... (RANDOM CHARACTERS)
```

**Root Cause Analysis:**
1. **Tamil tokenization overhead**: Qwen2.5-3B tokenizer encodes Tamil characters inefficiently (3-4 tokens per character)
2. **Quantization precision loss**: When Tamil requires many tokens per word, quantization errors compound
3. **Model size vs language complexity**: 3B parameters with 4-bit quantization cannot preserve Tamil language patterns
4. **Base model Tamil capacity**: Qwen2.5-3B was not specifically optimized for Tamil

**Diagnostic Tests Performed:**
- GGUF diagnostic notebooks created to test various quantization levels
- Compared llama.cpp inference vs transformers inference
- Tested with different sampling parameters (temp, top_p, top_k)
- All tests confirmed: quantized Tamil output is fundamentally broken

### Decision: Pivot to SLM Approach

> **Key Insight:** The problem is not the training data or fine-tuning.
> The problem is that a 3B model quantized to 4-bit cannot reliably
> represent Tamil text due to tokenization overhead.

**Options Considered:**

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| Keep Q8_0 (3.2GB) | Better quality | Too large for mobile | ❌ Rejected |
| Use smaller quant (Q2_K) | Smaller size | Even worse quality | ❌ Rejected |
| Switch to SLM | Right-sized for task | Less capacity | ✅ Selected |
| Custom Tamil tokenizer | Best for Tamil | Major engineering effort | ⏸️ Future |

---

## v0.5 Training (Current - SLM Approach)

**Date:** 2026-02-07
**Status:** 🔄 Training in Progress
**Base Model:** Qwen2.5-0.5B-Instruct
**Training Platform:** Google Colab (T4 GPU)

### Why Qwen2.5-0.5B?

| Factor | Qwen2.5-3B | Qwen2.5-0.5B |
|--------|------------|--------------|
| Parameters | 3B | 0.5B |
| F16 Size | ~6.2GB | ~1GB |
| Q4_K_M Size | ~1.8GB (broken) | ~250MB |
| Vocab Size | 151K | 151K (same!) |
| Tamil Tokens | Has subwords | Has subwords |
| Mobile Viable | ❌ No | ✅ Yes |

**Key Insight:** Both models share the same tokenizer (151K vocab with Tamil subwords).
The 0.5B model, when quantized to Q4_K_M (~250MB), should:
1. Fit comfortably on mobile devices
2. Have less precision loss per token (smaller model = less to compress)
3. Be sufficient for our instruction-following use case

### Training Data (Tamil Foundation v0.5)

**Dataset:** `CryptoYogi/vazhi-tamil-v05` on HuggingFace

| Metric | Value |
|--------|-------|
| Total Items | 11,696 |
| Train Split | 11,112 (95%) |
| Val Split | 584 (5%) |
| Q&A Format | 10,986 items |
| Completion Format | 710 items |
| Avg Tamil % | ~85% |

**Data Sources (19 files):**
- Thirukkural: 6,439 + 2,264 corpus conversions
- Classical Literature: Sangam, Silapathikaram, Bharathiar, Avvaiyar, Aathichoodi
- Dialects: Chennai (Tanglish), Madurai, Kongu
- Practical: Health, Education, Shopping, Weather, Daily Routines, Emotions
- Guardrails: 114 "I don't know" examples

**Data Quality Improvements over v0.2:**
- v0.2: 74% of "Tamil" data was actually English
- v0.5: ~85% average Tamil character ratio
- Corpus data included for fluency (completion format)
- Q&A format for instruction following

### Training Configuration

```python
Base Model: Qwen/Qwen2.5-0.5B-Instruct
LoRA Rank: 32
LoRA Alpha: 64
Target Modules: q_proj, k_proj, v_proj, o_proj, gate_proj, up_proj, down_proj
Epochs: 3
Batch Size: 4 (with gradient accumulation 4)
Learning Rate: 2e-4
Max Seq Length: 1024
```

### Expected Outputs

| Format | Expected Size | Use Case |
|--------|---------------|----------|
| F16 | ~1GB | Reference |
| Q8_0 | ~500MB | High quality backup |
| Q4_K_M | ~250MB | **Mobile deployment** |

### Training Progress

**Initial Run (2026-02-07):**

| Step | Loss | Notes |
|------|------|-------|
| 50 | 1.26 | Starting loss |
| 100 | 1.17 | Learning... |
| 200 | 1.10 | Good progress |
| 400 | 0.77 | Converging |
| 600 | 0.64 | Good |
| 800 | 0.55 | **Last good checkpoint** |
| 950 | 0.53 | Lowest loss achieved |
| 1000 | 0.73 | ⚠️ Starting to diverge |
| 1100 | 2.57 | ❌ DIVERGED - Loss exploded |

### Training Divergence Issue

**What Happened:**
Training was progressing well with loss dropping from 1.26 to 0.53 over 950 steps.
At step 1000, loss suddenly jumped from 0.53 → 0.73 → 2.57, indicating training divergence.

**Root Cause Analysis:**
1. Learning rate (2e-4) too aggressive for small model
2. Lack of gradient clipping allowed gradient explosions
3. Cosine scheduler may have caused LR oscillations

**Recovery Plan:**
Resume from checkpoint-800 (last good state, loss ~0.55) with:
- Reduced learning rate: 5e-5 (was 2e-4)
- Gradient clipping: max_grad_norm=0.3
- More frequent logging: every 25 steps
- More frequent saves: every 100 steps

**Notebook Updated:**
Added RECOVERY_MODE flag to training notebook that:
- Uses conservative hyperparameters
- Resumes from checkpoint-800
- Monitors for early signs of divergence

### Recovery Training Result: ❌ FAILED

**Training Completed:** Yes (2085 steps, 1h 31m)
**Final Loss:** 0.325 average, 0.558 at last step
**Loss Stability:** ✅ Stable throughout (no divergence)

**But Model Output:** Complete garbage

**Test Results:**
```
Q: திருக்குறளின் முதல் குறள் என்ன?
A: இட体系系统的ரsystemsystemsystem... (gibberish)
```

**Diagnosis:**
- Base Qwen2.5-0.5B model works fine (produces Tamil)
- LoRA adapter corrupts the output completely
- Corruption present even at checkpoint-1800
- Different garbage on float16 vs 4-bit loading

**Root Cause Analysis:**
| Suspect | Likelihood | Notes |
|---------|------------|-------|
| LoRA rank too high (r=32) | High | Too aggressive for 0.5B model |
| 4-bit training instability | Medium | Small models sensitive to quantization |
| Too many target modules | Medium | Modified 7 modules simultaneously |
| Learning rate (5e-5) | Low | Was conservative |

**Decision:** Pivot to pre-trained Tamil models (Sarvam-1 or Gemma 2B Tamil)

### Files Created
- Training notebook: `/notebooks/Vazhi_Qwen05B_Training.ipynb`
- Data prep script: `/data/tamil_foundation/prepare_training_data.py`
- Dataset: https://huggingface.co/datasets/CryptoYogi/vazhi-tamil-v05

---

## Pre-trained Tamil Model Evaluation

**Date:** 2026-02-07
**Purpose:** Find an existing Tamil model instead of training from scratch

### Models Tested

| Model | Size | Result | Notes |
|-------|------|--------|-------|
| Sarvam-1 (2B) | 2B | ❌ English responses | Base model, not instruction-tuned |
| Sarvam-2b-v0.5 | 2B | ❌ English responses | Base model, wrong answers |
| Gemma-2b-it-tamil | 2B | ❌ 401 Unauthorized | Model is private/doesn't exist |
| Tamil-LLaMA 7B | 7B | ✅ Works! | Correct Tamil responses, but 3.9GB too large |

### Key Findings

1. **Tamil-LLaMA 7B is the only working model** - Produces correct Tamil, but 3.9GB far exceeds mobile target
2. **Sarvam models need instruction-tuning** - They're base models, respond in English to Tamil queries
3. **Gemma Tamil doesn't exist** - The model `abhinand/tamil-gemma-2b-instruct-v0.1` returns 401
4. **AI4Bharat has no small Tamil instruction LLM** - Airavata is Hindi-only 7B model

### AI4Bharat IndicAlign Dataset Analysis

**Dataset:** `ai4bharat/indic-align`

| Subset | Total Rows | Purpose | Recommendation |
|--------|------------|---------|----------------|
| **Anudesh** | 36,820 | Native instruction-response pairs | ✅ Best for instruction-tuning |
| Dolly_T | ~15,000 | Translated Dolly dataset | Okay but not native |
| Wiki_Chat | 100,000+ | Wikipedia-based conversations | ❌ Not instruction format |
| Flan_Aligned | Large | Translated Flan | Good for diversity |

**Anudesh Structure:**
```python
{
  "interactions": [["user message", "assistant response"], ...],
  "meta": {...}
}
```

**Tamil Content in Anudesh:**
- Total: 36,820 rows (all Indian languages)
- Tamil after filtering: **1,966 rows** (~5.3%)
- Filtering method: Unicode character detection (0x0B80-0x0BFF)

### Decision

> **Strategy:** Fine-tune Sarvam-2B with IndicAlign Anudesh (Tamil) + VAZHI domain data
>
> **Rationale:** Sarvam-2B already knows Tamil vocabulary (trained on 2T tokens of Indian languages).
> It just needs instruction-tuning to follow commands. Use native Tamil instruction data from Anudesh.

---

## v0.6 Training (Current - Sarvam-2B Fine-tuning)

**Date:** 2026-02-07
**Status:** 🔄 Training in Progress
**Base Model:** sarvamai/sarvam-2b-v0.5
**Training Platform:** Kaggle (T4 GPU)

### Why Sarvam-2B?

| Factor | Value |
|--------|-------|
| Pre-training | 2T tokens of 10 Indian languages |
| Tamil knowledge | Already has vocabulary + grammar |
| What's missing | Instruction-following capability |
| Q4_K_M size | ~1.2GB (mobile viable) |

### Training Data

| Source | Items | Purpose |
|--------|-------|---------|
| VAZHI dataset | 11,112 | Domain-specific (Thirukkural, govt, health) |
| IndicAlign Anudesh (Tamil) | 1,966 | Native Tamil instruction pairs |
| **Total** | **13,078** | Combined training set |

### Training Configuration

```python
Base Model: sarvamai/sarvam-2b-v0.5
Quantization: 4-bit (BitsAndBytes) - required for T4 16GB
Precision: bf16 (not fp16 - caused errors with 4-bit)

LoRA Settings:
  rank: 8           # Conservative
  alpha: 16
  target_modules: [q_proj, v_proj]  # Only 2 modules
  dropout: 0.05

Training Settings:
  learning_rate: 1e-5
  epochs: 2
  batch_size: 2
  gradient_accumulation: 8
  max_grad_norm: 0.3
  max_length: 512
  gradient_checkpointing: True
```

### Training Progress

| Step | Loss | Notes |
|------|------|-------|
| 50 | 3.12 | Starting loss |
| 200 | 3.02 | Started decreasing |
| 350 | 2.78 | Good progress |
| 500 | 2.61 | Converging |
| 800 | 2.53 | Stable |
| 1200 | 2.57 | Stable |
| 1450 | 2.49 | Final loss |
| 1636 | ~2.5 | **Training complete** |

**Duration:** ~1.5 hours on Kaggle T4

### Test Results: ❌ COMPLETE FAILURE

Despite stable loss (~2.5), the model output was complete garbage:

```
Q: வணக்கம், நீங்கள் யார்?
A: H celebrated once (' '" - ((- { like - * - Or / (- What States peace...

Q: திருக்குறளின் முதல் குறள் என்ன?
A: கு ( (- - ('"(- / celebrated ' * {< celebrated November celebrated...

Q: தமிழ்நாட்டின் தலைநகரம் எது?
A: க celebrated ( ' - ('(' ' (- William celebrated - November celebrated...
```

**Observed Issues:**
1. Random English words repeated ("celebrated" appears dozens of times)
2. Mixed scripts from multiple Indian languages (Punjabi ਹਾਂ, Odia ନ୍ତି, Gujarati ઓસ્ટ્રે)
3. Random punctuation and symbols
4. No coherent Tamil whatsoever
5. Pattern similar to v0.5 Qwen failure

### Root Cause Analysis

| Factor | Assessment |
|--------|------------|
| 4-bit training | ❌ **Primary cause** - quantization during training corrupts weights |
| Loss stability | Misleading - low loss ≠ working model |
| LoRA settings | r=8 was conservative but still failed with 4-bit |
| Data quality | Not the issue - same data, different failure mode than v0.1-v0.4 |

**Conclusion:** 4-bit quantized training is fundamentally unstable for instruction-tuning. The model learns to minimize loss but the quantized weights cannot represent coherent language patterns.

### Lessons Learned from v0.6

1. **4-bit training doesn't work** - Both Qwen 0.5B and Sarvam 2B failed with 4-bit
2. **Loss is not a reliable metric** - Can have perfect loss but garbage output
3. **Memory constraints force bad tradeoffs** - T4 16GB insufficient for float16 training of 2B models
4. **Need different approach** - Either use pre-quantized models or train on larger GPU

### Decision: Pivot to Pre-trained Tamil Model Quantization Testing

Since training small models has failed repeatedly, try the opposite approach:
- Find **working** pre-trained Tamil models
- Test various quantization levels
- Find the smallest model that produces coherent Tamil

**Notebook:** `notebooks/Vazhi_TamilLLaMA_Quantization.ipynb`

---

## Pre-trained Model Quantization Testing

**Date:** 2026-02-08
**Status:** ✅ Complete
**Platform:** Kaggle

### Models Tested

| Model | Quant | Size | Chennai Test | Tamil Quality | Viable? |
|-------|-------|------|--------------|---------------|---------|
| Tamil-LLaMA 7B | Q4_K_M | 4.18 GB | ✅ சென்னை | ✅✅ Excellent | Too large |
| **Gemma-2B Tamil** | **Q4_K_M** | **1.63 GB** | **✅ சென்னை** | **✅ Good** | **✅ WINNER** |
| Gemma-2B Tamil | Q3_K_M | 1.38 GB | ❌ சென்பா | ⚠️ Degraded | No |
| Gemma-2B Tamil | Q2_K | 1.16 GB | ❌ Repeats | ❌ Broken | No |
| Qwen3-1.7B Tamil | Q4_K_M | 1.11 GB | ❌ Wrong | ⚠️ Inaccurate | Marginal |
| Llama3.2-Tamil-3B | Q2_K | 1.49 GB | ❌ Garbage | ❌ Broken | No |

### Detailed Test Results

**Tamil-LLaMA 7B Q4_K_M (4.18 GB)** - Baseline
```
Q: வணக்கம், நீங்கள் யார்?
A: இந்தக் கோரிக்கையின்படி, பயனரின் அடையாளத்தை அடையாளம் காண்பதே குறிக்கோள்.

Q: தமிழ்நாட்டின் தலைநகரம் எது?
A: தமிழ்நாட்டின் தலைநகரம் சென்னையில்.
```
✅ Coherent Tamil, correct answers, but 4.18 GB too large for mobile target.

**Gemma-2B Tamil Q4_K_M (1.63 GB)** - SELECTED
```
Q: வணக்கம், நீங்கள் யார்?
A: எனது பெயர் ஸ்பீஸ், எனது கட்டுப்பாடுகள் உங்கள் பார்வையில் தோன்றுகின்றன.

Q: தமிழ்நாட்டின் தலைநகரம் எது?
A: தமிழ்நாட்டின் தலைநகரம் சென்னை.
```
✅ Coherent Tamil, Chennai correct, fits mobile target (1.63 GB).

**Gemma-2B Tamil Q3_K_M (1.38 GB)** - Degraded
```
Q: தமிழ்நாட்டின் தலைநகரம் எது?
A: தமிழ்நாட்டின் தலைநகரம் சென்பா.
```
❌ "சென்பா" instead of "சென்னை" - quantization damage visible.

**Qwen3-1.7B Tamil Q4_K_M (1.11 GB)** - Inaccurate
```
Q: தமிழ்நாட்டின் தலைநகரம் எது?
A: தமிழ்நாட்டின் தலைநகரம் நகராட்சி நகரத்தில் அமைந்துள்ளது...
```
❌ Wrong answer, vague response.

### Key Findings

1. **Working pre-trained models beat failed training** - Gemma-2B Tamil at 1.63 GB outperforms all our training attempts
2. **Q4_K_M is the floor** - Going below Q4 causes visible quality degradation
3. **Model architecture matters** - Gemma handles quantization better than Llama3.2 for Tamil
4. **No training needed** - Just download and use the pre-quantized model

### Selected Model

**Gemma-2B Tamil Q4_K_M**
- Source: `RichardErkhov/abhinand_-_gemma-2b-it-tamil-v0.1-alpha-gguf`
- File: `gemma-2b-it-tamil-v0.1-alpha.Q4_K_M.gguf`
- Size: 1.63 GB
- Quality: Good coherent Tamil, basic facts correct

---

## v0.7 Training Run (Gemma-2B Tamil Fine-tuning)

**Date:** 2026-02-08
**Status:** ❌ Failed (GGUF conversion failed due to tokenizer corruption)
**Base Model:** abhinand/gemma-2b-it-tamil-v0.1-alpha (forked to CryptoYogi/gemma-2b-tamil-base)
**Training Platform:** Kaggle (T4/P100 GPU)

### Why Gemma-2B Tamil?

After v0.6's complete failure with 4-bit training, we pivoted to using a pre-trained Tamil-capable model:

| Factor | Value |
|--------|-------|
| Pre-training | Already instruction-tuned for Tamil |
| Tamil quality | Produces coherent Tamil at Q4_K_M |
| Base size | 2B parameters |
| Q4_K_M size | 1.63 GB |
| Tokenizer | Has proper pad_token (ID 0) |

### Model Forking

To ensure long-term stability and not depend on an "alpha" model, we forked the base model:

**Original:** `abhinand/gemma-2b-it-tamil-v0.1-alpha`
**Fork:** `CryptoYogi/gemma-2b-tamil-base`

This gives us control over the base model and prevents issues if the original author modifies or removes it.

### Critical Bug Discovery: Tokenizer Corruption

**The Problem:**
Previous training attempts (notebook166f14a8b5.ipynb) produced garbage output despite reasonable loss values. The model output became gibberish like:
```
Q: வணக்கம், நீங்கள் யார்?
A: !!!!!!!!!!!!!!!!!!!!!!!!!... (infinite repetition)
```

**Root Cause Identified:**
Setting `tokenizer.pad_token = tokenizer.eos_token` corrupted the tokenizer's internal vocabulary structure, causing "OrderedVocab contains holes" warning.

**The Fix:**
```python
# ❌ WRONG - This corrupts the tokenizer
tokenizer.pad_token = tokenizer.eos_token

# ✅ CORRECT - The tokenizer already has a proper pad_token
# Just align the model config with the tokenizer, don't modify tokenizer
model.config.pad_token_id = tokenizer.pad_token_id  # Already 0
model.config.bos_token_id = tokenizer.bos_token_id
model.config.eos_token_id = tokenizer.eos_token_id
```

### Learning Rate Boundary Testing

Tested two learning rates to find optimal training parameters:

| Learning Rate | Loss Start | Loss End | Result |
|---------------|------------|----------|--------|
| 1e-6 | 3.37 | 3.37 | ❌ No learning (too conservative) |
| 5e-5 | 3.39 | 3.00 | ✅ Learning without catastrophic forgetting |

**Key Finding:** 5e-5 with fixed tokenizer produces stable learning where:
- Loss decreases (3.39 → 3.00)
- Model retains coherent Tamil output
- No repetition loops or garbage output

### Training Configuration (Validated)

```python
Base Model: CryptoYogi/gemma-2b-tamil-base
Quantization: 4-bit (BitsAndBytes)
Precision: bf16

LoRA Settings:
  rank: 4           # Very conservative
  alpha: 8
  target_modules: [q_proj, v_proj]  # Only 2 modules
  dropout: 0.05

Training Settings:
  learning_rate: 5e-5
  epochs: 1         # Single pass through data
  batch_size: 2
  gradient_accumulation: 4
  max_grad_norm: 1.0  # Gradient clipping
  max_length: 512
  gradient_checkpointing: True
  bf16: True
```

### Test Run Results (177 steps)

| Step | Loss | Notes |
|------|------|-------|
| 23 | 3.39 | Starting loss |
| 65 | 3.15 | Learning... |
| 100 | 3.08 | Good progress |
| 150 | 3.00 | Converging |
| 177 | ~3.00 | Training complete |

**Output Quality Test:**
```
Q: வணக்கம், நீங்கள் யார்?
A: (Coherent Tamil response - no repetition, no garbage)
```

### Full Training Plan

Now that the test run validated the approach, full training will use:
- All 11K samples from VAZHI dataset
- Same hyperparameters as test run
- Single epoch to prevent overfitting
- Monitor for loss > 3.2 (early stopping threshold)

### Post-Training Pipeline

1. **Upload LoRA adapter** to HuggingFace
2. **Merge adapter** with base model
3. **Upload merged model** to HuggingFace
4. **Convert to GGUF** (Q4_K_M for mobile deployment)
5. **Test on mobile** before release

### Files Created
- Training notebook: `/notebooks/Vazhi_Training_Fixed.ipynb`
- Base model fork notebook: `/notebooks/Vazhi_Fork_Base_Model.ipynb`
- Forked model: `CryptoYogi/gemma-2b-tamil-base` on HuggingFace

### Memory Issues Encountered

1. **Float16 loading OOM** - Sarvam-2B too large for T4 in float16
2. **Solution:** 4-bit quantization with BitsAndBytes
3. **fp16 training error** - BFloat16 model incompatible with fp16 training
4. **Solution:** Changed to bf16=True in trainer config

### Files Created
- Training notebook: `/notebooks/Vazhi_Sarvam2B_Finetune.ipynb`
- Evaluation notebook: `/notebooks/Vazhi_Pretrained_Tamil_Test.ipynb`

### v0.7 GGUF Conversion Failure

Despite successful training (loss 3.39→3.00), GGUF conversion failed:

**Error:**
```
GGML_ASSERT(id_to_token.size() == token_to_id.size()) failed
```

**Root Cause:**
The source model `abhinand/gemma-2b-it-tamil-v0.1-alpha` had a corrupted tokenizer:
- Warning during training: "OrderedVocab contains holes for indices [1, 2]"
- This warning was ignored during training
- The vocabulary corruption made GGUF conversion impossible

**Attempted Fixes:**
1. Replace tokenizer files with clean `google/gemma-2b` tokenizer → Failed (vocab mismatch)
2. Various GGUF conversion flags → Failed (fundamental corruption)
3. Manual tokenizer surgery → Failed (embedding weights tied to corrupted vocab)

**Conclusion:** The base model itself was corrupted. No post-training fix possible.

---

## v0.8 Training Run (Current - Qwen3-0.6B Two-Stage Training)

**Date:** 2026-02-09
**Status:** 🔄 In Progress
**Base Model:** Qwen/Qwen3-0.6B
**Training Platform:** Kaggle (T4 GPU)

### Why Qwen3-0.6B?

After v0.7's GGUF failure and consultation with GPT5.2, pivoted to Qwen3-0.6B:

| Factor | Gemma-2B | Qwen3-0.6B |
|--------|----------|------------|
| Parameters | 2B | 600M |
| Tokenizer | Corrupted | Clean |
| GGUF target | 1.6GB | <1GB |
| Thinking | None | Native `/think` mode |
| Multilingual | Limited | Strong |

### Two-Stage Training Pipeline

**Key Insight:** Single-pass SFT causes either fluency loss OR instruction-following loss.

**Solution:** Two-stage training:

```
┌─────────────────────────────────────────────────────────┐
│ Stage 1: Micro-DAPT (Continued Pretraining)             │
├─────────────────────────────────────────────────────────┤
│ Data: 80% Vazhi outputs + 20% Sangraha Tamil            │
│ Purpose: Boost Tamil fluency without breaking model     │
│ Format: Plain text completion (no chat template)        │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│ Stage 2: SFT (Instruction Tuning)                       │
├─────────────────────────────────────────────────────────┤
│ Data: Full Vazhi Q&A pairs in chat format               │
│ Purpose: Teach instruction-following                    │
│ Loss: Assistant-only masking (user tokens masked)       │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│ Post-Training: Merge + GGUF                             │
├─────────────────────────────────────────────────────────┤
│ 1. Merge LoRA adapters to base model                    │
│ 2. Upload merged model to HuggingFace                   │
│ 3. Convert to GGUF (Q4_K_M)                             │
│ 4. Upload GGUF to HuggingFace Hub                       │
└─────────────────────────────────────────────────────────┘
```

### Training Data

**Micro-DAPT Data:**
| Source | Proportion | Purpose |
|--------|------------|---------|
| Vazhi outputs (Tamil) | 80% | Domain knowledge |
| Sangraha corpus (AI4Bharat) | 20% | Tamil fluency |

**SFT Data:**
| Source | Items | Format |
|--------|-------|--------|
| Vazhi Q&A pairs | 11,112 | Qwen chat template |

### Training Configuration

```python
# Micro-DAPT Stage
model = "Qwen/Qwen3-0.6B"
lora_rank = 16
lora_alpha = 32
target_modules = ["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"]
learning_rate = 2e-4
epochs = 1
max_seq_length = 2048

# SFT Stage (uses Micro-DAPT output as base)
learning_rate = 1e-4
epochs = 2
loss_type = "assistant_only"  # Mask user tokens
```

### Infrastructure Fixes

| Issue | Fix |
|-------|-----|
| CUDA device selection | `os.environ["CUDA_VISIBLE_DEVICES"] = "0"` |
| Tokenizer parallelism | `os.environ["TOKENIZERS_PARALLELISM"] = "false"` |
| T4 precision | `fp16=True` (not bf16, T4 doesn't support bf16 well) |
| Disconnect protection | HF Hub checkpointing every epoch |

### Preflight Fail-Fast System

Before full training, run preflight check:
```python
# 1. Tiny Micro-DAPT: 50 samples, 10 steps
# 2. Tiny SFT: 50 samples, 10 steps
# 3. Merge LoRA
# 4. Generate test output
# 5. If output quality poor → pivot before wasting hours
```

### Training Progress

| Stage | Status | Notes |
|-------|--------|-------|
| Preflight Check | ✅ | Output quality verified |
| Micro-DAPT | 🔄 In Progress | Training on Kaggle |
| SFT | ⏳ Pending | Waiting for DAPT completion |
| Merge + GGUF | ⏳ Pending | Final conversion |

### Expected Outputs

| Format | Expected Size | Use Case |
|--------|---------------|----------|
| F16 | ~1.2GB | Reference |
| Q4_K_M | **<1GB** | **Mobile deployment** |

### Files Created
- Training notebook: `~/Downloads/Vazhi_Qwen3_MicroDAPT_SFT_GGUF_HFHub_KAGGLE_SAFE.ipynb`
- Sangraha data integration: AI4Bharat CC-BY 4.0 corpus

---

## v3.1 Training Run (Failed - Mixed Data Formats)

**Date:** 2026-02-10
**Status:** ❌ Failed
**Base Model:** Qwen/Qwen3-0.6B
**Training Platform:** Kaggle (T4 GPU)

### What We Tried

Attempted to rebalance the dataset to fix Thirukkural distribution skew (71% → 25%):
1. Extracted ~1,050 diverse Tamil Q&A from IndicAlign
2. Added ~47 manual samples
3. Downsampled Thirukkural from existing dataset
4. Merged all samples and trained

### Training Metrics

| Metric | Value |
|--------|-------|
| Total samples | 4,933 |
| Loss start | 3.39 |
| Loss end | ~0.5 |
| Training time | ~1.5 hours |
| Status | ✅ Completed |

### Test Results: ❌ COMPLETE GARBAGE

Despite good loss, model output was completely broken:

```
Q: வணக்கம்
A: 'systemsystemsystemsystemsystemsystemsystem...

Q: தமிழ்நாட்டின் தலைநகரம் என்ன?
A: தஉsystemsystemsystemsystemsystem...

Q: 2+2 என்ன?
A: 4systemsystemsystemsystem...
```

### Root Cause: MIXED DATA FORMATS

**The Critical Mistake:**
The notebook mixed two incompatible data formats in a single SFT training run:

| Source | Format | Count | Issue |
|--------|--------|-------|-------|
| Existing dataset (`vazhi-tamil-v05`) | RAW TEXT | ~3,836 | No ChatML structure |
| IndicAlign + Manual samples | ChatML formatted | ~1,097 | Properly structured |

**Why This Breaks Training:**

The existing dataset contains samples like:
```
யாதும் ஊரே யாவரும் கேளிர்
தீதும் நன்றும் பிறர்தர வாரா...
```
This is raw Sangam poetry with NO instruction/output structure.

The diverse samples were formatted as:
```
<|im_start|>system
நீங்கள் VAZHI...<|im_end|>
<|im_start|>user
தமிழ்நாட்டின் தலைநகரம்?<|im_end|>
<|im_start|>assistant
சென்னை.<|im_end|>
```

When mixed together, the model saw:
- Raw text samples without "system" tags
- ChatML samples WITH "system" tags
- No consistent pattern to learn

Result: Model learned to output "system" repeatedly as a dominant pattern.

### The Fix

**Option A: SFT with ChatML-only data**
```python
# ONLY include samples that have ChatML formatting
def is_chatml_formatted(text):
    return "<|im_start|>" in text and "<|im_end|>" in text

# Filter for SFT
final_samples = [s for s in all_samples if is_chatml_formatted(s["text"])]
```

**Option B: Proper Two-Stage Training**
- Stage 1 (Micro-DAPT): Use raw Tamil text WITHOUT chat template
- Stage 2 (SFT): Use ONLY ChatML-formatted Q&A pairs

### Lessons Learned

1. **NEVER mix data formats in SFT** - All samples must have consistent chat template
2. **Raw text ≠ SFT data** - Raw text belongs in DAPT (continued pretraining), not SFT
3. **Low loss ≠ working model** - Loss can be excellent (0.5) while output is garbage
4. **Verify format consistency** - Check 100% ChatML before training

### Files Updated

- Notebook fix: `/notebooks/Vazhi_SFT_v3_1_Balanced.ipynb` - Added format filtering
- Lessons learned: `/docs/LESSONS_LEARNED.md` - Added Lesson #28

---

## v3.2 Training Run (Failed - fp16 Issues)

**Date:** 2026-02-10
**Status:** ❌ Failed
**Base Model:** Qwen/Qwen3-0.6B (instruct)
**Training Platform:** Kaggle (T4/P100 GPU)

### What We Fixed from v3.1

1. **ChatML-only data** — filtered out all raw text samples from existing dataset
2. **Thirukkural downsampled** — from 71% to ~25% of dataset
3. **Diverse samples added** — ~1,050 from IndicAlign (Dolly_T, WikiHow, Wiki_Conv, OpenAssistant_T) + ~47 manual samples
4. **100% ChatML verification** — `is_chatml_formatted()` check before training
5. **Single GPU forced** — `CUDA_VISIBLE_DEVICES=0` at top of notebook
6. **fp16 training** — for T4 compatibility

### Training Configuration

```python
Base Model: Qwen/Qwen3-0.6B (instruct)
Quantization: 4-bit QLoRA (NF4)
Compute dtype: float16
LoRA: r=16, alpha=32, all 7 modules
Learning Rate: 1e-4
Epochs: 2
Batch: 2 x 8 = 16 effective
Max Length: 512
```

### Result

Training had fp16-related issues on T4. The Qwen3 model has internal bf16 operations that conflict with fp16 AMP training on non-Ampere GPUs. Led to v3.3 with FP32 training mode.

### Dataset Created

`CryptoYogi/vazhi-tamil-sft-v3_2` on HuggingFace — balanced, ChatML-only SFT dataset.

### Files Created
- Notebook: `/notebooks/Vazhi_SFT_v3_2_Fixed.ipynb`

---

## v3.3 Training Run (Failed - Instruct Model Conflict)

**Date:** 2026-02-10
**Status:** ❌ Failed
**Base Model:** Qwen/Qwen3-0.6B (instruct)
**Training Platform:** Kaggle (P100 GPU)

### What We Fixed from v3.2

1. **FP32 training mode** — disabled both fp16 and bf16 flags to work around Qwen3's internal bf16 ops on P100
2. **Reused v3.2's balanced dataset** — `CryptoYogi/vazhi-tamil-sft-v3_3` (same data, new repo for tracking)
3. **SKIP_DATA_PREP logic** — avoids redundant IndicAlign extraction if dataset already exists on HF

### Training Configuration

```python
Base Model: Qwen/Qwen3-0.6B (instruct)
Quantization: 4-bit QLoRA (NF4)
Compute dtype: float16 (model loading), FP32 (training)
fp16: False, bf16: False  # FP32 mode for P100 compatibility
LoRA: r=16, alpha=32, all 7 modules
Learning Rate: 1e-4
Epochs: 2
Batch: 1 x 16 = 16 effective
Max Length: 512
```

### Result: ❌ Failed

Model output was broken — likely producing `<think>` reasoning tokens or nonsensical output.

### Root Cause Analysis

| Factor | Assessment |
|--------|------------|
| `<think>` token conflict | **Primary cause** — Qwen3-0.6B is instruction-tuned with native `/think` reasoning mode. Our ChatML format (`<\|im_start\|>`) conflicted with its native chat template that expects `<think>` blocks |
| Learning rate (1e-4) | **Contributing** — too aggressive for fine-tuning an already instruction-tuned model, causing catastrophic forgetting of the base model's capabilities |
| FP32 training | Not the issue — this was a correct fix for P100 compatibility |

### Key Insight

**Instruct models have their own chat format.** Qwen3-0.6B (instruct) expects:
```
<think>reasoning here</think>
response here
```

When we force ChatML format (`<|im_start|>system/user/assistant<|im_end|>`), it conflicts with the model's training. The model tries to produce `<think>` tokens within our ChatML structure.

**Solution:** Use the **base** model (`Qwen3-0.6B-Base`) which has no pre-existing chat template, so it can cleanly learn our ChatML format.

### Files Created
- Notebook: `/notebooks/Vazhi_SFT_v3_3_Clean.ipynb`
- Dataset: `CryptoYogi/vazhi-tamil-sft-v3_3` on HuggingFace

---

## v3.4 Training Run (Pending - Base Model Approach)

**Date:** 2026-02-11
**Status:** ⏳ Pending (not yet run on Kaggle)
**Base Model:** Qwen/Qwen3-0.6B-**Base** (NOT instruct)
**Training Platform:** Kaggle (P100 GPU)

### Why Base Model?

After v3.3's failure, the key insight is that instruction-tuned models fight against new chat templates. Using the base model:

| Factor | Qwen3-0.6B (instruct) | Qwen3-0.6B-Base |
|--------|----------------------|-----------------|
| Pre-existing chat format | Yes (`<think>` mode) | None |
| ChatML compatibility | Conflicting | Clean slate |
| SFT risk | Catastrophic forgetting | No existing behavior to forget |
| LoRA rank needed | Lower (preserving existing) | Higher (learning from scratch) |

### Training Configuration

```python
Base Model: Qwen/Qwen3-0.6B-Base  # KEY CHANGE
Quantization: 4-bit QLoRA (NF4)
Compute dtype: float16 (model loading), FP32 (training)
fp16: False, bf16: False  # FP32 mode for P100

LoRA: r=32, alpha=64, all 7 modules  # Increased from r=16 for base model
Learning Rate: 2e-5  # MUCH lower: 5x reduction from v3.3's 1e-4
Epochs: 3  # Increased from 2 (base model needs more training)
Batch: 1 x 16 = 16 effective
Max Length: 512

# ChatML special tokens added to tokenizer since base model doesn't have them
special_tokens: ["<|im_start|>", "<|im_end|>"]
```

### Changes from v3.3

| Setting | v3.3 (failed) | v3.4 |
|---------|--------------|------|
| Base Model | Qwen3-0.6B (instruct) | Qwen3-0.6B-**Base** |
| Learning Rate | 1e-4 | 2e-5 |
| Epochs | 2 | 3 |
| LoRA Rank | 16 | 32 |
| Special Tokens | Already present | Added `<\|im_start\|>`, `<\|im_end\|>` |

### Risk Assessment

| Risk | Mitigation |
|------|------------|
| Base model has zero instruction-following | 3 epochs of SFT + higher LoRA rank |
| Adding special tokens changes vocab size | `model.resize_token_embeddings()` called |
| `pad_token = eos_token` in base model | Carefully handled (lesson from v0.7) |
| May need two-stage (DAPT+SFT) | Can fall back to v0.8's two-stage approach if single SFT fails |

### Existing Models to Test First

Before running v3.4, the `Test_Existing_Models.ipynb` notebook tests whether any previously uploaded HF models still work:
- `CryptoYogi/vazhi-qwen3-lora-best` (v0.8 cycle best)
- `CryptoYogi/vazhi-qwen3-lora-cycle-6` (last cycle checkpoint)
- `CryptoYogi/qwen3-0.6b-vazhi` (v3.3 merged)

If any produce coherent Tamil, we can skip v3.4 and continue from that checkpoint.

### Files Created
- Notebook: `/notebooks/Vazhi_SFT_v3_4_Base.ipynb`
- Test notebook: `/notebooks/Test_Existing_Models.ipynb`

---

## v3.5 Training Run (❌ Failed — SFT-Only on Base Model)

**Date:** 2026-02-11
**Status:** ❌ Failed — model outputs code tokens, HTML attributes, and Chinese instead of Tamil
**Base Model:** Qwen/Qwen3-0.6B-**Base** (NOT instruct)
**Training Platform:** Kaggle (P100 GPU)
**HF Model:** `CryptoYogi/vazhi-qwen3-v3_5`
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v3_3` (reused from v3.3)

### What v3.5 Attempted

v3.5 added `DataCollatorForCompletionOnlyLM` to train only on assistant response tokens (completion-only masking). The masking itself worked correctly — preflight checks confirmed system/user tokens were masked with -100 and only assistant tokens were trained.

### Training Configuration

```python
Base Model: Qwen/Qwen3-0.6B-Base
Quantization: 4-bit QLoRA (NF4)
Compute dtype: float16 (model loading), FP32 (training)
fp16: False, bf16: False  # FP32 mode for P100

LoRA: r=32, alpha=64, all 7 modules
Learning Rate: 2e-5
Epochs: 3
Batch: 1 x 16 = 16 effective
Max Length: 1024 (changed from 512 during training session)
Data Collator: DataCollatorForCompletionOnlyLM
```

### Training Loss Curve

Training completed all 795 steps across 3 epochs. Loss curve looked healthy:
```
Step  25: 1.5557    Step 250: 1.1517
Step  50: 1.4887    Step 300: 1.0899
Step 100: 1.3140    Step 375: 1.0561
Step 150: 1.1793    Step 450: 1.0404
Step 200: 1.1577    Step 475: 1.0749
```

### Evaluation Results — COMPLETE FAILURE

Despite healthy loss curve and 12/12 "passing" eval checks, EVERY response was garbage:

```
[GREETING] Q: வணக்கம்
A: _year_that=True_email="#_verified=True_date_group_url_count_role_order...

[FACTUAL] Q: தமிழ்நாட்டின் தலைநகரம் என்ன?
A: \\' />", // The data is not a valid JSON...

[CULTURE] Q: திருக்குறளின் முதல் குறள் என்ன?
A: ":{"type":"object","description":"A few of the most common...

[SAFETY] Q: ஒரு scam message வந்தால் என்ன செய்வது?
A: 「<br /><br />...
```

The model was regurgitating pre-training data — code tokens, HTML attributes, JSON schemas, variable names, Chinese characters. It had NOT learned Tamil at all.

### Root Cause Analysis

**Primary: SFT-only on base model cannot teach a new language.**

Qwen3-0.6B-Base was pre-trained on predominantly code, web content, English, and Chinese. SFT with ~3K Tamil ChatML samples cannot shift the model's language distribution — the Tamil tokens form a tiny fraction of what it learned during pre-training. The model's "default mode" remains code/web/Chinese generation.

**This was a known risk documented in our own lessons.** Lesson #13 states: "Don't use single-pass SFT for language adaptation — Two-stage (DAPT→SFT) preserves fluency AND instructions." We violated our own rule.

**Secondary issues:**
1. **~20-30% of samples triggered "Could not find response key"** — even at max_seq_length=1024 (changed from 512 mid-session), long Tamil samples exceeded the token limit before the `<|im_start|>assistant\n` marker, causing those samples to contribute zero training signal
2. **Eval criteria was useless** — checks for loops, system leaks, think leaks, and empty responses all "passed" because code garbage doesn't match those patterns. No check for Tamil character content or actual response quality
3. **Loss curve was misleading** — loss only computed on assistant tokens that were found; samples where the response template wasn't found were silently skipped
4. **Response template fragility** — `"<|im_start|>assistant\n"` (with newline) tokenizes differently depending on context; GPT5.2 recommends simpler `"<|im_start|>assistant"` without newline

### Critical Mistake: Pivoting Away From What Worked

**v3.3 (instruct model) was producing Tamil with fixable issues:**
- `<think>` tags appeared in output (fixable with token suppression)
- LR 1e-4 was too aggressive (fixable by reducing to 2e-5)
- Responses sometimes used Thirukkural structure (fixable with dataset rebalancing)
- But the output WAS in Tamil — the model had Tamil capability from instruct training

**v3.5 (base model) threw away all Tamil capability** by pivoting to a base model that had never been trained on Tamil conversations. SFT alone was insufficient to create this capability — DAPT was needed first.

The correct approach should have been: **iterate on v3.3's fixable issues** rather than pivot to an untested architecture (SFT-only on base model).

### GPT5.2 Post-Mortem Feedback

1. **Dataset issues:** Some SFT samples had no assistant segment at all (system+user only), contributing zero training signal
2. **Response template mismatch:** `"\n<|im_start|>assistant\n"` with leading newline is fragile — simpler `"<|im_start|>assistant"` is more robust
3. **No strict ChatML validation:** Need regex-based validator ensuring ALL samples have both user AND assistant with non-empty content
4. **Base model + chat tags = poor signal:** Base model doesn't "expect" ChatML tags, so even correctly masked training provides weak learning signal
5. **Recommended fix:** Two-stage Micro-DAPT (raw Tamil text) → SFT (strict ChatML), OR return to instruct model with `<think>` suppression

### Lessons Added

- **#40**: SFT-only on a base model CANNOT teach a new language — DAPT is required first
- **#41**: Iterate on working approaches — v3.3 produced Tamil with fixable issues; pivoting to base model was a regression
- **#42**: Eval must check output QUALITY, not just pattern absence — add Tamil character % check and coherence scoring
- **#43**: A healthy loss curve does NOT mean the model learned — always test actual output
- **#44**: Strict ChatML validation (regex) before training — reject samples missing user or assistant segments

### Files
- Notebook: `/notebooks/Vazhi_SFT_v3_5_Masked.ipynb`
- HF Model: `CryptoYogi/vazhi-qwen3-v3_5` (garbage output — do not use)

---

## v3.6 Training Run (FAILED — LoRA Merge to 4-bit Corruption)

**Date:** 2026-02-12
**Status:** ❌ Failed
**Base Model:** Qwen/Qwen3-0.6B (INSTRUCT — NOT Base)
**Training Platform:** Kaggle (P100 GPU)
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v3_6` (3,667 samples)
**Output Model:** `CryptoYogi/vazhi-qwen3-v3_6` (garbage — do not use)

### What Went Right

Everything up to and including training was correct:

1. **Dataset construction** — 3,667 samples, 100% strict ChatML validated, 15% Kural, 31.7% short (<400 chars), 10 refusal + 16 brevity + 7 greeting samples
2. **Tokenizer** — ChatML tokens verified, `<think>` token IDs [151667, 151668] found for suppression
3. **Preflight masking** — 20/20 samples passed, 35.5% trainable tokens (system/user properly masked)
4. **Training completed** — all steps finished, model saved, LoRA adapter saved at `/kaggle/working/vazhi-v3_6-final`

### What Went Wrong: LoRA Merge to 4-bit

After training completed, the merge step `model.merge_and_unload()` was called on the **4-bit quantized model**. PEFT issued an explicit warning:

```
UserWarning: Merge lora module to 4-bit linear may get different generations due to rounding errors.
```

This corrupted the model weights. The merge process dequantizes 4-bit weights → adds LoRA delta → but the dequantized 4-bit weights have massive precision loss, making the sum unrecoverable. The result: **completely corrupted weight matrices**.

### Secondary Issue: Gradient Checkpointing During Eval

The eval code set `merged_model.config.use_cache = True`, but gradient checkpointing from training was still active:

```
`use_cache=True` is incompatible with gradient checkpointing. Setting `use_cache=False`.
Caching is incompatible with gradient checkpointing in Qwen3DecoderLayer. Setting past_key_values=None.
```

This forced generation to run **without KV cache** — slow but shouldn't produce garbage by itself. The merge corruption is the primary cause.

### Eval Output (0/12 passed, 0% Tamil)

Every single response was random punctuation, operators, and fragments:

```
Q: வணக்கம்
A: ooks = 1)0]:,. is:.. = *="-1., of,..... to:..... =;.1.2],..:,): +_t =="):

Q: தமிழ்நாட்டின் தலைநகரம் என்ன?
A: ooks...............................................................................

Q: திருக்குறளின் முதல் குறள் என்ன?
A: دي:, =) =="0},.. is], -:)) == * =_ =_t))] = to._->1......

Q: ஒரு scam message வந்தால் என்ன செய்வது?
A: ooks,.:,0 =="-..) is, 0].:.00)、:.1..0 of.0.1.,.1],..)=:..2.}
```

This output pattern differs from both v3.5 (code tokens/HTML) and v3.3 (Tamil with `<think>`). The random punctuation/operators pattern is characteristic of **corrupted weight matrices** — the model can no longer form coherent token sequences.

### Training Configuration (Was Correct)

```python
Base Model: Qwen/Qwen3-0.6B      # INSTRUCT (has Tamil + instruction-following)
Quantization: 4-bit QLoRA (NF4)
Compute dtype: float16 (model loading), FP32 (training)
fp16: False, bf16: False          # FP32 mode for P100

LoRA: r=16, alpha=32, all 7 modules
Learning Rate: 2e-5
Epochs: 3
Batch: 1 x 16 = 16 effective
Max Length: 1024
Save Steps: 50
Data Collator: DataCollatorForCompletionOnlyLM
Response Template: "<|im_start|>assistant\n" [151644, 77091, 198]
```

### Root Cause: Merging LoRA into 4-bit is Destructive

The 4-bit NF4 quantization reduces each weight from float16 (16 bits) to 4 bits, losing 75% of precision. When LoRA delta (trained in float16) is added to the dequantized 4-bit weights, the resulting values cannot be accurately represented. The model effectively becomes random noise.

**The fix:** After training, save the LoRA adapter separately. Then load the base model fresh in **fp16 (NOT 4-bit)**, apply the LoRA adapter, and merge in full precision. Qwen3-0.6B in fp16 is ~1.5GB — easily fits on P100's 16GB alongside the adapter.

### Loss Curve: Unknown

The training progress was rendered as `<IPython.core.display.HTML object>` (widget) and not captured as text in the notebook output. We cannot confirm whether training actually converged or what the final loss was. v3.7 must log loss values as text.

### Files
- Notebook: `/notebooks/Vazhi_SFT_v3_6_Instruct.ipynb`
- Kaggle output: `~/Downloads/vazhi-sft-v3-6-instruct.ipynb`

---

## v3.7 Training Run (Pending — Fix LoRA Merge)

**Date:** 2026-02-12
**Status:** ⏳ Pending
**Base Model:** Qwen/Qwen3-0.6B (INSTRUCT)
**Training Platform:** Kaggle (P100 GPU)
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v3_6` (reuse — the dataset was fine)
**Output Model:** `CryptoYogi/vazhi-qwen3-v3_7`

### Changes from v3.6

v3.6's dataset, training setup, and masking were all correct. Only the post-training merge/eval needs fixing:

1. **LoRA merge in fp16** — after training, save LoRA adapter → delete 4-bit model from GPU → reload base in fp16 → load adapter → merge in fp16 → eval and push
2. **Disable gradient checkpointing before eval** — call `model.gradient_checkpointing_disable()` before generation
3. **Text-based loss logging** — add `TrainerCallback` to print loss values as text (not just HTML widget) so we can verify training convergence from notebook output
4. **Quick sanity check** — eval the PeftModel BEFORE merge to verify it works, then merge and eval again

### Training Configuration (Same as v3.6)

```python
Base Model: Qwen/Qwen3-0.6B      # INSTRUCT
Quantization: 4-bit QLoRA (NF4)   # For training memory only
LoRA: r=16, alpha=32, all 7 modules
Learning Rate: 2e-5
Epochs: 3
Batch: 1 x 16 = 16 effective
Max Length: 1024
Data Collator: DataCollatorForCompletionOnlyLM
```

### Post-Training Fix (Critical)

```python
# 1. Save LoRA adapter (NOT the merged model)
trainer.save_model("/kaggle/working/vazhi-v3_7-lora")

# 2. Free 4-bit training model
del model, trainer
torch.cuda.empty_cache()

# 3. Reload base model in FP16 (NOT 4-bit!)
base_model = AutoModelForCausalLM.from_pretrained(
    BASE_MODEL, torch_dtype=torch.float16, device_map={"":0}
)

# 4. Load LoRA adapter onto fp16 model
from peft import PeftModel
model = PeftModel.from_pretrained(base_model, "/kaggle/working/vazhi-v3_7-lora")

# 5. Merge in full precision — NO rounding errors!
merged_model = model.merge_and_unload()

# 6. Disable gradient checkpointing for eval
merged_model.gradient_checkpointing_disable()
merged_model.config.use_cache = True
```

### Files
- Notebook: `/notebooks/Vazhi_SFT_v3_7_MergeFix.ipynb`

---

## Architectural Decisions

### ADR-001: Why Not RAG?

**Considered:** Using RAG (Retrieval Augmented Generation) for Culture pack

**Rejected because:**
1. Goes against offline working principle - RAG typically needs vector DB
2. Adds complexity to mobile deployment
3. Fine-tuning should work if data is correct

**Decision:** Fix the training data, not the architecture.

### ADR-002: Why Qwen2.5-3B? (Initial Choice)

**Chosen for:**
- Good instruction following
- Reasonable size for mobile (with quantization)
- Multilingual support (though Tamil is limited)

**Limitations Discovered:**
- Limited Tamil vocabulary efficiency
- Quantization destroys Tamil output quality
- 3B model too large even at Q4 (1.8GB)

**Status:** ❌ Abandoned after v0.4 quantization failures

### ADR-003: Why SLM (Small Language Model) Approach?

**Date:** 2026-02-07
**Status:** ✅ Adopted

**Context:**
After v0.4 training, we discovered that GGUF quantization of Qwen2.5-3B produces
gibberish Tamil output, even at Q8_0 (~3.2GB). The 6.2GB F16 model worked but is
impractical for mobile deployment.

**Problem Statement:**
How do we deploy a Tamil-capable LLM on mobile devices with limited storage and
memory, when large models lose Tamil capability after quantization?

**Decision:**
Use Qwen2.5-0.5B-Instruct as the base model instead of Qwen2.5-3B-Instruct.

**Rationale:**

1. **Same tokenizer, smaller model**
   - Both models use the same 151K vocabulary tokenizer
   - Tamil subword tokens are preserved in both
   - Smaller model means less precision loss during quantization

2. **Right-sized for the task**
   - VAZHI is an instruction-following assistant, not a general-purpose LLM
   - 0.5B parameters sufficient for structured Q&A responses
   - Heavy fine-tuning on domain-specific data compensates for smaller size

3. **Mobile-first design**
   - Q4_K_M of 0.5B ≈ 250MB (vs 1.8GB for 3B)
   - Fits in mobile RAM constraints
   - Faster inference on mobile CPUs

4. **Quantization math**
   - 3B model: 3,000M params × 4 bits = 1.5GB minimum
   - 0.5B model: 500M params × 4 bits = 250MB minimum
   - Smaller absolute error accumulation in smaller model

**Trade-offs Accepted:**
- Less general knowledge capacity
- May struggle with complex multi-turn reasoning
- Relies heavily on training data quality

**Mitigations:**
- Comprehensive Tamil foundation dataset (11,696 items)
- Strong guardrails ("I don't know" responses)
- Focused on specific use cases, not general chat

**Alternatives Considered:**

| Alternative | Why Rejected |
|-------------|--------------|
| Keep 3B at Q8 (3.2GB) | Too large for mobile |
| Custom Tamil tokenizer | Major engineering effort, future consideration |
| Distillation from 3B→0.5B | Complex, may not preserve Tamil |
| Different model family (Phi, Gemma) | Less proven multilingual support |

**Success Criteria:**
1. Q4_K_M produces coherent Tamil responses
2. First Thirukkural correctly cited
3. Guardrails prevent hallucination
4. Model size < 300MB

### ADR-004: Mixed Training Format (Q&A + Completion)

**Date:** 2026-02-07
**Status:** ✅ Adopted

**Context:**
For the Tamil foundation dataset, we have both:
- Structured Q&A data (instruction → response)
- Raw Tamil text (Thirukkural, Sangam poetry, Bharathiar)

**Decision:**
Use a mixed format approach:
- 94% Q&A format for instruction-following
- 6% completion format for Tamil fluency

**Rationale:**
- Q&A format teaches the model to follow instructions
- Completion format exposes the model to authentic Tamil prose/poetry
- Mix prevents the model from only learning to respond to questions
- Raw text helps with Tamil language patterns and fluency

### ADR-005: Hybrid Retrieval Architecture

**Date:** 2026-02-08
**Status:** ✅ Adopted
**Full Document:** `/vazhi_app/docs/adr/ADR-005-hybrid-retrieval-architecture.md`

**Context:**
- App needs to provide value before 1.6GB model download
- Factual data (Thirukkural, phone numbers) must never be hallucinated
- Cloud inference fallback would incur ongoing costs

**Decision:**
Implement a hybrid architecture with two paths:
1. **Deterministic Path** - SQLite lookup for exact data (no model needed)
2. **AI-Enhanced Path** - LLM for explanations and conversations (model required)

**Benefits:**
- App is useful immediately from first launch
- Zero hallucination for factual data
- Encourages model download for AI features
- No cloud costs

**Data Schema:** `/vazhi_app/docs/data_schema.md`

---

## Mistakes to Avoid

1. **Don't trust data labels** - Always verify with character-level analysis
2. **Don't add more data to fix quality issues** - Fix the existing data first
3. **Don't assume English training teaches Tamil** - Language mismatch is real
4. **Don't treat Thirukkural as generative** - It's citation/reference material
5. **Don't skip data quality validation** - Check before training, not after
6. **Don't assume larger models quantize better** - Smaller models may preserve quality better
7. **Don't skip GGUF testing** - Always test quantized output before deployment
8. **Don't ignore tokenization efficiency** - Tamil chars/token ratio matters
9. **NEVER modify the tokenizer's special tokens** - Setting `pad_token = eos_token` causes "OrderedVocab holes" and corrupts the model. Instead, align model config with the existing tokenizer tokens
10. **Don't trust low loss values alone** - Test actual model output after training; loss can be low while output is garbage
11. **Don't use learning rates below 1e-5** - Too conservative, model won't learn. 5e-5 is the sweet spot for LoRA fine-tuning
12. **NEVER ignore tokenizer warnings** - "OrderedVocab contains holes" is a FATAL error that will break GGUF conversion. Stop training immediately if you see this warning
13. **Don't use single-pass SFT for language adaptation** - Two-stage (DAPT→SFT) preserves fluency AND instructions
14. **Don't skip preflight testing** - Run tiny DAPT+SFT before full training to catch issues early
15. **Don't rely on Colab/Kaggle session persistence** - Checkpoint to HF Hub every epoch
16. **Verify base model tokenizer BEFORE training** - A corrupted source model will produce corrupted outputs
17. **NEVER mix data formats in SFT** - Raw text and ChatML-formatted samples CANNOT be trained together. Raw text → DAPT stage. ChatML → SFT stage. Mixing causes "systemsystemsystem..." output.
18. **Verify format consistency before training** - Use `is_chatml_formatted()` check to ensure 100% of SFT samples have proper chat template
19. **Handle instruct model format conflicts with suppression, not pivoting** - If the instruct model has native tokens (e.g., Qwen3's `<think>`), suppress them during generation rather than pivoting to the base model. The instruct model already has language capability (Tamil) and instruction-following — SFT-only on the base model loses both. *(Updated from v3.5 failure: original advice to "use base model" was wrong without DAPT)*
20. **Lower the learning rate for instruct models** - 1e-4 is too aggressive for models that already have instruction-following capability; causes catastrophic forgetting. Use 2e-5 or lower
21. **SFT-only CANNOT teach a new language** - A base model pre-trained on code/web/English/Chinese won't learn Tamil from ~3K SFT samples. You MUST do DAPT (domain-adaptive pretraining on raw Tamil text) first, then SFT
22. **Iterate on what's working, don't pivot to untested approaches** - v3.3 produced Tamil with fixable issues (`<think>` tags, aggressive LR, Thirukkural-biased responses). Fixing those was a 1-hour task. Pivoting to base model SFT-only wasted hours of compute on a worse outcome
23. **Eval must check OUTPUT QUALITY, not just pattern absence** - Check Tamil character %, response coherence, and semantic relevance. A response of code tokens "passes" loop/leak/empty checks but is completely useless
24. **A healthy loss curve does NOT mean the model learned** - Loss was computed only on the subset of samples where the response template was found. The model can minimize loss by predicting common token patterns without learning the target language
25. **Strict ChatML validation (regex) before training** - Every SFT sample MUST have: `<|im_start|>user\n` with non-empty content, `<|im_start|>assistant\n` with non-empty content, and proper `<|im_end|>` closings. Samples missing any part contribute zero or wrong training signal
26. **Use simpler response template for masking** - `"<|im_start|>assistant"` (without trailing newline) is more robust than `"<|im_start|>assistant\n"` — the newline can tokenize differently depending on surrounding context
27. **NEVER merge LoRA into a 4-bit quantized model** — `model.merge_and_unload()` on a 4-bit model causes catastrophic rounding errors, producing garbage output. Instead: save LoRA adapter → reload base model in fp16 → load adapter onto fp16 model → merge in full precision. The 4-bit model is for training memory efficiency only, not for the final merge
28. **Disable gradient checkpointing before eval** — gradient checkpointing conflicts with `use_cache=True` during generation, forcing `past_key_values=None`. Call `model.gradient_checkpointing_disable()` before any `generate()` calls. Also log loss values as text (not just HTML widgets) to verify training convergence from notebook output

---

## Key Learnings

### Quantization & Tamil

1. **Tokenization overhead compounds**: If Tamil needs 3-4 tokens per character, quantization errors multiply
2. **Smaller models can be better**: Less absolute precision loss when fewer parameters to compress
3. **Test early, test quantized**: Never assume training success means deployment success
4. **Same tokenizer ≠ same quality**: Model size affects post-quantization quality significantly

### Data Quality

1. **Character analysis reveals truth**: Labels can lie, character counts don't
2. **Completion data improves fluency**: Not just Q&A, raw text helps language patterns
3. **Corpus vs generated**: Authoritative sources prevent hallucination
4. **Dialect balance matters**: Include regional variations for authentic responses

### Training Configuration (v0.7 Discoveries)

1. **Never modify tokenizer special tokens**: Setting `tokenizer.pad_token = tokenizer.eos_token` creates "OrderedVocab holes" and corrupts vocabulary. Instead, align the model's config with the tokenizer's existing tokens:
   ```python
   model.config.pad_token_id = tokenizer.pad_token_id
   model.config.bos_token_id = tokenizer.bos_token_id
   model.config.eos_token_id = tokenizer.eos_token_id
   ```

2. **Learning rate boundaries for LoRA**:
   - Too low (1e-6): No learning, loss stays flat
   - Sweet spot (5e-5): Stable learning, no catastrophic forgetting
   - Too high (2e-4): Training divergence after ~1000 steps

3. **Conservative LoRA settings work**: r=4, alpha=8, targeting only q_proj and v_proj is sufficient for domain adaptation without corrupting base model capabilities

4. **4-bit training can work**: Unlike v0.5/v0.6 failures, using a pre-trained Tamil model (not English-first model) with proper tokenizer handling allows successful 4-bit training

5. **Fork your base models**: Depending on external "alpha" models is risky. Fork to your own HuggingFace space for stability

6. **Gradient checkpointing + use_cache conflict**: Set `model.config.use_cache = False` before training, re-enable for inference

### Continuous Learning Pipeline (Designed in v0.7)

1. **Weekly feedback collection**: Users provide 👍/👎/✏️ feedback on responses
2. **Corrections become training data**: User corrections in Alpaca format for fine-tuning
3. **Monthly model updates**: Aggregate corrections, retrain, and redeploy
4. **Feedback loop**: App → Corrections → Training → Improved Model → App

---

## References

### Training Notebooks
- v3.7 LoRA merge fix (LATEST): `/notebooks/Vazhi_SFT_v3_7_MergeFix.ipynb`
- v3.6 Return to instruct (FAILED — merge corruption): `/notebooks/Vazhi_SFT_v3_6_Instruct.ipynb`
- v3.5 Completion-only masking (FAILED): `/notebooks/Vazhi_SFT_v3_5_Masked.ipynb`
- v3.4 Base model notebook (superseded): `/notebooks/Vazhi_SFT_v3_4_Base.ipynb`
- v3.3 Clean training: `/notebooks/Vazhi_SFT_v3_3_Clean.ipynb`
- v3.2 Fixed training: `/notebooks/Vazhi_SFT_v3_2_Fixed.ipynb`
- v3.1 Balanced SFT: `/notebooks/Vazhi_SFT_v3_1_Balanced.ipynb`
- Test existing models: `/notebooks/Test_Existing_Models.ipynb`
- v0.7 Training notebook: `/notebooks/Vazhi_Training_Fixed.ipynb`
- v0.7 Fork base model: `/notebooks/Vazhi_Fork_Base_Model.ipynb`
- v0.6 Sarvam-2B notebook: `/notebooks/Vazhi_Sarvam2B_Finetune.ipynb`
- v0.5 Qwen-0.5B notebook: `/notebooks/Vazhi_Qwen05B_Training.ipynb`
- v0.4 Training notebook: `/notebooks/Vazhi_Day4_v02_Training.ipynb`
- SmolLM notebook: `/notebooks/Vazhi_SmolLM_135M_Training.ipynb`

### Diagnostics & Quantization
- GGUF Diagnostics: `/notebooks/Vazhi_GGUF_Diagnostic.ipynb`, `Vazhi_GGUF_Diagnostic_v2.ipynb`
- GGUF Quantization: `/notebooks/Vazhi_GGUF_Quantization.ipynb`

### Data & Models
- Data prep script: `/data/tamil_foundation/prepare_training_data.py`
- Tamil foundation data: `/data/tamil_foundation/` (19 JSON files)
- HuggingFace dataset: https://huggingface.co/datasets/CryptoYogi/vazhi-tamil-v05
- Forked base model: https://huggingface.co/CryptoYogi/gemma-2b-tamil-base
- Regeneration plan: `/docs/DATA_REGENERATION_PLAN.md`

### App Feedback System
- Feedback model: `/vazhi_app/lib/models/feedback.dart`
- Feedback service: `/vazhi_app/lib/services/feedback_service.dart`
- Feedback buttons widget: `/vazhi_app/lib/widgets/feedback_buttons.dart`

### Architecture Documentation
- ADR-005 Hybrid Retrieval: `/vazhi_app/docs/adr/ADR-005-hybrid-retrieval-architecture.md`
- Knowledge Pack Schema: `/vazhi_app/docs/data_schema.md`
