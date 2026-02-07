# VAZHI Execution Plan

> **Goal**: Deploy a Tamil AI assistant on mobile devices (~1-1.5GB)

**Last Updated**: 2025-02-07
**Status**: Phase 2 - Model Training

---

## Executive Summary

VAZHI aims to be an offline Tamil AI assistant for mobile. After multiple training attempts and model evaluations, we've identified the optimal path:

**Primary Strategy**: Fine-tune Sarvam-2B with IndicAlign + VAZHI data
**Fallback Strategy**: Use Tamil-LLaMA 7B (3.9GB) for high-end devices

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

| Resource | Size | Use Case |
|----------|------|----------|
| AI4Bharat IndicAlign | 74.7M pairs | Instruction-tuning |
| AI4Bharat Sangraha | 251M tokens | Tamil fluency |
| Our VAZHI data | 11,696 items | Domain-specific |

---

## Phase 2: Model Training 🔄

### Attempt History

| Version | Model | Approach | Result |
|---------|-------|----------|--------|
| v0.1-v0.2 | Qwen 3B | LoRA fine-tune | ❌ Hallucination |
| v0.4 | Qwen 3B | Improved data | ❌ GGUF gibberish |
| v0.5 | Qwen 0.5B | SLM approach | ❌ LoRA corrupted model |
| **v0.6** | **Sarvam 2B** | **IndicAlign + VAZHI** | **🔄 Pending** |

### Current Strategy: Sarvam-2B Fine-tuning

**Why Sarvam-2B?**
- Pre-trained on 2T tokens of 10 Indian languages (including Tamil)
- Already understands Tamil vocabulary and grammar
- Just needs instruction-tuning (not language learning)
- Q4_K_M size: ~1.2GB (mobile viable)

**Training Configuration (Conservative)**

```yaml
Base Model: sarvamai/sarvam-2b-v0.5
Training Data:
  - IndicAlign Tamil subset (up to 50K samples)
  - VAZHI domain data (11,696 samples)

LoRA Settings:
  rank: 8           # Conservative (not 32)
  alpha: 16
  target_modules: [q_proj, v_proj]  # Only 2 modules
  dropout: 0.05

Training Settings:
  learning_rate: 1e-5      # Very low
  epochs: 2
  batch_size: 2
  gradient_accumulation: 8
  max_grad_norm: 0.3       # Gradient clipping
  precision: float16       # Not 4-bit
```

**Notebook**: `notebooks/Vazhi_Sarvam2B_Finetune.ipynb`

### Fallback: Tamil-LLaMA 7B

If Sarvam-2B training fails or GGUF quality is poor:

| Option | Size | Quality | Target Devices |
|--------|------|---------|----------------|
| Tamil-LLaMA 7B Q4 | 3.9GB | ✅ Proven | Tablets, high-end phones |
| Tamil-LLaMA 7B Q2 | ~2GB | ⚠️ Degraded | Mid-range phones |

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
| 2025-02-05 | Use Qwen 3B | Good multilingual, available |
| 2025-02-06 | Pivot to Qwen 0.5B | 3B GGUF produced gibberish |
| 2025-02-07 | Pivot to Sarvam 2B | 0.5B LoRA corrupted model |
| 2025-02-07 | Use IndicAlign data | Need more instruction data |
| 2025-02-07 | Conservative LoRA (r=8) | Previous r=32 too aggressive |

---

## Next Actions

1. **Immediate**: Run Sarvam-2B fine-tuning notebook in Kaggle
2. **After Training**: Test GGUF quality with Tamil questions
3. **If Success**: Begin mobile integration
4. **If Failure**: Evaluate Tamil-LLaMA 7B for tablets

---

*வழி காட்டும் AI — The open path to Tamil AI*
