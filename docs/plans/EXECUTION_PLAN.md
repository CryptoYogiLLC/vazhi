# VAZHI Execution Plan

> **Goal**: Deploy a Tamil AI assistant on mobile devices (~1-1.5GB)

**Last Updated**: 2026-02-08
**Status**: Phase 2 Complete - Model Selected ✅

---

## Executive Summary

VAZHI aims to be an offline Tamil AI assistant for mobile. After multiple training attempts failed, we discovered that using a pre-trained Tamil model works better than training our own.

**Selected Model**: Gemma-2B Tamil Q4_K_M (1.63 GB)
- Source: `RichardErkhov/abhinand_-_gemma-2b-it-tamil-v0.1-alpha-gguf`
- Produces coherent Tamil, basic facts correct
- Ready for mobile integration - no training needed!

---

## Phase Overview

| Phase | Description | Status | Timeline |
|-------|-------------|--------|----------|
| Phase 1 | Data Collection & Preparation | ✅ Complete | Done |
| Phase 2 | Model Training | 🔄 In Progress | Current |
| Phase 3 | GGUF Conversion & Validation | ⏳ Pending | Next |
| Phase 4 | Mobile App Integration | ⏳ Pending | After Phase 3 |
| Phase 5 | Testing & Launch | ⏳ Pending | Final |

---

## Phase 1: Data Collection & Preparation ✅

### Completed Work

| Deliverable | Status | Details |
|-------------|--------|---------|
| VAZHI Domain Data | ✅ Done | 11,696 items across 6 packs |
| HuggingFace Upload | ✅ Done | CryptoYogi/vazhi-tamil-v05 |
| Data Quality Validation | ✅ Done | ~85% Tamil content verified |

### Data Sources

| Source | Items | Purpose |
|--------|-------|---------|
| Thirukkural Corpus | 6,439 | Cultural knowledge |
| Dialects (Chennai, Madurai, Kongu) | 1,006 | Regional variations |
| Practical (Health, Govt, Legal) | 2,000+ | Domain expertise |
| Guardrails | 114 | "I don't know" responses |
| Classical Literature | 710 | Tamil fluency (completion) |

### External Resources (Available)

| Resource | Size | Tamil Content | Use Case |
|----------|------|---------------|----------|
| AI4Bharat IndicAlign (Anudesh) | 36,820 total | ~1,966 Tamil (~5%) | Instruction-tuning |
| AI4Bharat Sangraha | 251M tokens | Significant Tamil | Tamil fluency (pretraining) |
| Our VAZHI data | 11,112 items | ~85% Tamil | Domain-specific |

**Note:** IndicAlign contains multiple Indian languages. Anudesh subset filtered for Tamil yields ~1,966 items using Unicode character detection.

---

## Phase 2: Model Training ✅ Complete

### Attempt History

| Version | Model | Approach | Result |
|---------|-------|----------|--------|
| v0.1-v0.2 | Qwen 3B | LoRA fine-tune | ❌ Hallucination |
| v0.4 | Qwen 3B | Improved data | ❌ GGUF gibberish |
| v0.5 | Qwen 0.5B | SLM approach | ❌ LoRA corrupted model |
| v0.6 | Sarvam 2B | IndicAlign + VAZHI | ❌ 4-bit training corrupted |
| **v0.7** | **Gemma-2B Tamil** | **Pre-trained model** | **✅ Works!** |

### Selected Model: Gemma-2B Tamil Q4_K_M

After all training attempts failed, we tested pre-trained Tamil models and found:

**Winner:** `RichardErkhov/abhinand_-_gemma-2b-it-tamil-v0.1-alpha-gguf`
- File: `gemma-2b-it-tamil-v0.1-alpha.Q4_K_M.gguf`
- Size: **1.63 GB** (fits mobile target!)
- Quality: Coherent Tamil, basic facts correct

**Test Results:**
```
Q: தமிழ்நாட்டின் தலைநகரம் எது?
A: தமிழ்நாட்டின் தலைநகரம் சென்னை. ✅

Q: Scam message detection
A: Correctly identifies "மோசடி" (fraud) ✅
```

### Next Step: Fine-tune with VAZHI Govt Data

The base model works but has some factual gaps. Fine-tuning with government module data (452 items) to improve accuracy.

**Notebook:** `notebooks/Vazhi_Gemma2B_Finetune_Govt.ipynb`

**Key Differences from Failed Attempts:**
- Starting from a WORKING model (not teaching Tamil)
- Training in bf16 (NOT 4-bit!)
- Very conservative LoRA (r=4)
- Small focused dataset (452 items)

---

## Phase 3: GGUF Conversion & Validation ⏳

### Conversion Pipeline

```
Merged Model (HF format)
    ↓
convert_hf_to_gguf.py → F16 GGUF (~4GB)
    ↓
llama-quantize → Q8_0 (~2GB)
    ↓
llama-quantize → Q4_K_M (~1.2GB) ← Target
```

### Validation Checklist

| Test | Expected | Pass Criteria |
|------|----------|---------------|
| Tamil coherence | Readable Tamil | No gibberish |
| Thirukkural Q1 | Correct citation | "அகர முதல..." |
| Capital city | "சென்னை" | Correct answer |
| Greeting response | Tamil intro | Not English |
| Guardrails | "தெரியவில்லை" | Refuses unknown |

### Quality Gates

- [ ] F16 model produces correct Tamil responses
- [ ] Q8_0 maintains quality
- [ ] Q4_K_M maintains quality (critical!)
- [ ] Response latency < 5s on mobile CPU
- [ ] Memory usage < 2GB RAM

---

## Phase 4: Mobile App Integration ⏳

### Architecture

```
┌─────────────────────────────────────────┐
│           VAZHI Flutter App              │
├─────────────────────────────────────────┤
│  ┌─────────────┐    ┌────────────────┐  │
│  │   Chat UI   │    │  Category UI   │  │
│  └──────┬──────┘    └───────┬────────┘  │
│         │                   │           │
│         ▼                   ▼           │
│  ┌─────────────────────────────────────┐│
│  │        LLM Service Layer            ││
│  │   (llama.cpp / llama.rn binding)    ││
│  └──────────────┬──────────────────────┘│
│                 │                        │
│                 ▼                        │
│  ┌─────────────────────────────────────┐│
│  │     GGUF Model (~1.2GB)             ││
│  │     vazhi-sarvam-q4_k_m.gguf        ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

### Integration Tasks

| Task | Description | Priority |
|------|-------------|----------|
| Model Download Manager | Download GGUF on first launch | P0 |
| llama.cpp FFI Binding | Native inference integration | P0 |
| Streaming Responses | Token-by-token display | P1 |
| Context Management | Handle conversation history | P1 |
| Offline Detection | Graceful offline handling | P2 |

### Storage Requirements

| Component | Size |
|-----------|------|
| App binary | ~50MB |
| GGUF model | ~1.2GB |
| Cache/data | ~100MB |
| **Total** | **~1.4GB** |

---

## Phase 5: Testing & Launch ⏳

### Testing Matrix

| Test Type | Scope | Tools |
|-----------|-------|-------|
| Unit Tests | Model inference | pytest |
| Integration | App + Model | Flutter test |
| E2E | Full user flows | Playwright |
| Performance | Latency, memory | Profiler |
| User Testing | Tamil speakers | Beta program |

### Launch Checklist

- [ ] Model quality validated
- [ ] App Store assets ready
- [ ] Privacy policy updated
- [ ] Beta testing complete
- [ ] Performance benchmarks met
- [ ] Documentation complete

### Distribution

| Platform | Channel | Target |
|----------|---------|--------|
| iOS | TestFlight → App Store | iPhone 12+ |
| Android | Play Store | 4GB+ RAM devices |
| Web | PWA (future) | Desktop/mobile browsers |

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| GGUF quality poor | Medium | High | Fallback to Tamil-LLaMA 7B |
| Training divergence | Low | Medium | Conservative settings, checkpoints |
| Model too slow | Medium | Medium | Optimize batch size, context length |
| App Store rejection | Low | High | Privacy compliance, content review |
| Storage concerns | Medium | Medium | Optional model download |

---

## Success Metrics

### Technical Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Model Size | < 1.5GB | GGUF file size |
| First Token Latency | < 2s | Time to first response |
| Tokens/second | > 5 | Generation speed |
| Memory Usage | < 2GB | Peak RAM |
| Thirukkural Accuracy | > 90% | Top 10 kurals correct |

### User Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| App Store Rating | > 4.0 | User reviews |
| DAU | 1000+ | Daily active users |
| Session Length | > 3 min | Average session |
| Retention (D7) | > 30% | 7-day retention |

---

## Timeline

```
Week 1 (Current):
├── ✅ Data preparation complete
├── ✅ Model evaluation complete
├── 🔄 Sarvam-2B fine-tuning
└── ⏳ GGUF conversion

Week 2:
├── GGUF quality validation
├── Mobile integration start
└── Initial app testing

Week 3:
├── Performance optimization
├── Beta release (TestFlight)
└── User feedback collection

Week 4:
├── Bug fixes from beta
├── Final polish
└── App Store submission
```

---

## Resources

### Notebooks

| Notebook | Purpose |
|----------|---------|
| `Vazhi_Sarvam2B_Finetune.ipynb` | Current training approach |
| `Vazhi_Pretrained_Tamil_Test.ipynb` | Model evaluation |
| `Vazhi_Qwen05B_Training.ipynb` | Failed attempt (reference) |

### Documentation

| Document | Purpose |
|----------|---------|
| `LESSONS_LEARNED.md` | What we learned |
| `TRAINING_LOG.md` | Detailed training history |
| `EXECUTION_PLAN.md` | This document |

### External Links

| Resource | URL |
|----------|-----|
| VAZHI Dataset | huggingface.co/datasets/CryptoYogi/vazhi-tamil-v05 |
| Sarvam-2B | huggingface.co/sarvamai/sarvam-2b-v0.5 |
| IndicAlign | huggingface.co/datasets/ai4bharat/indic-align |
| Tamil-LLaMA | huggingface.co/abhinand/tamil-llama-7b-instruct-v0.2 |

---

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-02-05 | Use Qwen 3B | Good multilingual, available |
| 2026-02-06 | Pivot to Qwen 0.5B | 3B GGUF produced gibberish |
| 2026-02-07 | Pivot to Sarvam 2B | 0.5B LoRA corrupted model |
| 2026-02-07 | Use IndicAlign Anudesh | Native Tamil instruction data (not Wiki_Chat) |
| 2026-02-07 | Filter for Tamil only | Anudesh is only ~5% Tamil, need Unicode filtering |
| 2026-02-07 | Conservative LoRA (r=8) | Previous r=32 too aggressive |
| 2026-02-07 | 4-bit training | T4 GPU OOM with float16 Sarvam-2B |
| 2026-02-07 | bf16 not fp16 | 4-bit model incompatible with fp16 scaler |
| 2026-02-08 | Use pre-trained Gemma-2B Tamil | All training attempts failed, pre-trained works |
| 2026-02-08 | Q4_K_M is minimum viable quant | Q3 and below degrade Tamil quality |
| 2026-02-08 | Fine-tune govt module only | Test if fine-tuning adds domain knowledge |

---

## Next Actions

1. **Immediate**: Fine-tune Gemma-2B Tamil with govt data (452 items)
2. **After Fine-tuning**: Test if domain knowledge improved
3. **If Success**: Fine-tune with other VAZHI modules
4. **If Failure**: Use base Gemma-2B Tamil as-is (still works!)
5. **Then**: Begin mobile app integration with working model

---

*வழி காட்டும் AI — The open path to Tamil AI*
