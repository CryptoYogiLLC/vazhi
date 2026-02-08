# VAZHI Model Training Log

This log captures all training runs, decisions, and rationale to prevent repeating mistakes.

---

## Version History

| Version | Date | Status | Key Changes |
|---------|------|--------|-------------|
| v0.1 | 2025-02-05 | ❌ Failed | Initial training, Culture pack hallucination |
| v0.2 | 2025-02-06 | ❌ Failed | Added culture_v2 data, still hallucinating |
| v0.3 | 2025-02-06 | ⏸️ Skipped | Heavy augmentation planned but root cause found |
| v0.4 | 2025-02-06 | ❌ Failed | GGUF quantization produced gibberish output |
| v0.5 | 2025-02-07 | ❌ Failed | SLM approach with Qwen2.5-0.5B - LoRA corrupted model |
| v0.6 | 2025-02-07 | 🔄 Training | Sarvam-2B + IndicAlign Anudesh + VAZHI data |

---

## v0.1 Training Run

**Date:** 2025-02-05
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

**Date:** 2025-02-06
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

**Date:** 2025-02-06
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

**Date:** 2025-02-06 to 2025-02-07
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

**Audit Results (2025-02-06):**
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

**Date:** 2025-02-07
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

**Initial Run (2025-02-07):**

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

**Date:** 2025-02-07
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

**Date:** 2025-02-07
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
| 50 | 3.12 | Starting loss (normal) |
| ... | ... | Training in progress |

**Expected:** 1636 total steps, ~1.5 hours on T4

### Memory Issues Encountered

1. **Float16 loading OOM** - Sarvam-2B too large for T4 in float16
2. **Solution:** 4-bit quantization with BitsAndBytes
3. **fp16 training error** - BFloat16 model incompatible with fp16 training
4. **Solution:** Changed to bf16=True in trainer config

### Files Created
- Training notebook: `/notebooks/Vazhi_Sarvam2B_Finetune.ipynb`
- Evaluation notebook: `/notebooks/Vazhi_Pretrained_Tamil_Test.ipynb`

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

**Date:** 2025-02-07
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

**Date:** 2025-02-07
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

---

## References

- v0.5 Training notebook: `/notebooks/Vazhi_Qwen05B_Training.ipynb`
- v0.4 Training notebook: `/notebooks/Vazhi_Day4_v02_Training.ipynb`
- GGUF Diagnostics: `/notebooks/Vazhi_GGUF_Diagnostic.ipynb`, `Vazhi_GGUF_Diagnostic_v2.ipynb`
- Data prep script: `/data/tamil_foundation/prepare_training_data.py`
- Tamil foundation data: `/data/tamil_foundation/` (19 JSON files)
- HuggingFace dataset: https://huggingface.co/datasets/CryptoYogi/vazhi-tamil-v05
- Regeneration plan: `/docs/DATA_REGENERATION_PLAN.md`
