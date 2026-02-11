# VAZHI Sprint Plan - REVISED (February 2026)

## Progress Summary

### COMPLETED: Data Collection Phase ✅

**Original Goal**: 500-1000 Tamil Q&A pairs + 50 security examples

**Actual Achievement**: 3,007 bilingual training pairs across 6 domain packs

| Pack | Tamil Name | Version | Training Pairs | Categories |
|------|-----------|---------|----------------|------------|
| Security | வழி காவல் | v1.0.0 | 468 | Scams, cyber safety, police, women's safety |
| Government | வழி அரசு | v1.0.0 | 467 | Schemes, certificates, e-Sevai, pensions |
| Education | வழி கல்வி | v1.0.0 | 602 | Admissions, scholarships, exams, careers |
| Legal | வழி சட்டம் | v1.0.0 | 610 | Tenant rights, consumer, RTI, family law |
| Healthcare | வழி மருத்துவம் | v1.0.0 | 460 | Healthcare, govt schemes, Siddha medicine |
| Culture | வழி பண்பாடு | v1.0.0 | 400 | Thirukkural, Siddhars, temples, festivals |

**Data Quality**: Each entry has both `pure_tamil` and `tanglish` variants with high Tamil content (>70% Tamil words).

### COMPLETED: Hybrid Architecture (Epic #14) ✅

**Major Pivot**: Instead of waiting for perfect AI model, implemented Hybrid Retrieval Architecture that provides immediate value.

| Component | Status | Description |
|-----------|--------|-------------|
| Query Router | ✅ | Pattern-based query classification |
| Retrieval Services | ✅ | SQLite-backed domain lookups |
| Hybrid Chat Provider | ✅ | Dual-path response management |
| Knowledge Result Cards | ✅ | Rich UI for structured data |
| Model Download Service | ✅ | Pause/resume, network detection |
| Integration Tests | ✅ | 85 tests passing |

---

## Current Status: v0.8 Hybrid Architecture

### WEEK 1: Base Model + Training ✅ COMPLETE

#### Day 1: Environment Setup + Base Model Inference ✅ COMPLETE
- [x] Colab environment with T4 GPU
- [x] Qwen/Qwen2.5-3B-Instruct loaded and tested
- [x] Tamil capabilities validated

#### Day 2: Merge Training Data + Format Conversion ✅ COMPLETE
- [x] Created all 6 domain packs
- [x] Merged into SFT format: 3,007 pairs
- [x] Train/val split: 2,706 train / 301 val

#### Day 3: LoRA Fine-tuning Setup ✅ COMPLETE
- [x] Unsloth environment configured
- [x] LoRA adapters configured (r=16)
- [x] Tamil chat template defined

#### Day 4: Train Base Tamil LoRA ✅ COMPLETE
- [x] Training completed (~84 minutes on A100)
- [x] Final validation loss: 0.567
- [x] Model uploaded to HuggingFace: `CryptoYogi/vazhi-lora`

#### Day 5: Model Evaluation ✅ COMPLETE
- [x] Thirukkural accuracy: 3/3 perfect matches
- [x] All 6 domain packs validated
- [x] Response quality verified

---

### WEEK 2: Mobile App + Deployment 🔄 IN PROGRESS

#### Day 6-7: Flutter App Development ✅ COMPLETE

**Architecture Change**: Pivoted from React Native to Flutter for better performance and cross-platform support.

- [x] Flutter app initialized with Riverpod state management
- [x] Chat UI with Tamil support
- [x] Category selection (6 domain packs)
- [x] Settings drawer with language toggle
- [x] Local assets for offline support
- [x] Responsive design with randomized category cards

**App Structure**:
```
vazhi_app/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   └── chat_screen.dart
│   ├── widgets/
│   │   └── settings_drawer.dart
│   ├── providers/
│   │   └── chat_provider.dart
│   ├── services/
│   │   └── vazhi_api_service.dart
│   └── models/
│       └── message.dart
└── assets/
    └── images/ (local category images)
```

#### Day 8: HuggingFace Space Deployment 🔄 IN PROGRESS

**Architecture Change**: Using HuggingFace Space with Gradio API instead of local GGUF for initial deployment. This allows:
- Faster iteration without app store updates
- No model download required for users
- Easier testing and debugging

**Status**:
- [x] Space created: `CryptoYogi/vazhi`
- [x] Gradio app configured with all 6 packs
- [x] CPU fallback for free tier (bfloat16)
- [x] Pydantic version pinned to fix JSON schema bug
- [ ] Space running successfully
- [ ] Flutter app connected to API

**Current Issue**: Fixing Gradio/Pydantic compatibility (pydantic <2.11.0)

---

## Revised Roadmap

### Phase 1: Training & Testing ✅ COMPLETE
- [x] Training data (3,007 pairs) ✅
- [x] Model training (val loss 0.567) ✅
- [x] HuggingFace model upload ✅
- [x] Flutter app skeleton ✅
- [x] HuggingFace Space for testing ✅
- [x] Space running successfully ✅
- [x] End-to-end testing via API ✅

### Phase 2: Hybrid Architecture ✅ COMPLETE
- [x] Query Router with pattern matching ✅
- [x] SQLite retrieval services ✅
- [x] Hybrid chat provider ✅
- [x] Knowledge result cards UI ✅
- [x] Model download manager (pause/resume) ✅
- [x] Network detection (WiFi vs cellular) ✅
- [x] Storage validation ✅
- [x] Voice input/output (STT/TTS) ✅
- [x] Feedback system ✅
- [x] Integration tests (85 passing) ✅

### Phase 3: Data Population & AI 🔄 IN PROGRESS
- [ ] Full Thirukkural database (1,330 verses)
- [ ] Complete government schemes database
- [ ] Hospital directory population
- [ ] **NEW TARGET: Qwen3-0.6B (<1GB GGUF)** - Two-stage training in progress
- [ ] Micro-DAPT + SFT pipeline on Kaggle

**Model Pivot (2026-02-09):** Pivoted from Gemma-2B to Qwen3-0.6B due to tokenizer corruption in Gemma base model (OrderedVocab holes at indices 1,2). New approach uses two-stage training:
1. **Micro-DAPT**: 80% Vazhi outputs + 20% Sangraha Tamil corpus for fluency
2. **SFT**: Instruction tuning with assistant-only loss masking

### Phase 4: Polish & Launch
- [ ] Expert directory feature
- [ ] FTS5 Tamil search optimization
- [ ] Demo video recording
- [ ] App store preparation
- [ ] TestFlight / Play Store submission

### Phase 5: Community & Scale
- [ ] Pack contribution workflow
- [ ] Multi-dialect support (Chennai, Madurai, Coimbatore)
- [ ] Smart escalation to cloud LLMs
- [ ] PWA version

---

## Technical Decisions Log

| Decision | Original Plan | Actual Choice | Rationale |
|----------|---------------|---------------|-----------|
| Mobile Framework | React Native + llama.rn | Flutter | Better performance, cross-platform |
| Testing Infrastructure | Local only | HuggingFace Space | Fast iteration during development |
| Model Hosting | Self-hosted | HuggingFace | Free hosting, easy access |
| MVP Inference | Cloud API | On-device GGUF | Offline-first is core to VAZHI vision |
| AI Model | Gemma-2B Tamil (1.6GB) | **Qwen3-0.6B (<1GB)** | Gemma tokenizer corrupted; Qwen3 has native thinking, better size |
| Training Approach | Single SFT pass | **Two-stage (Micro-DAPT → SFT)** | Preserves Tamil fluency AND instruction-following |

**Note**: HuggingFace Space is for development/testing only. The MVP will have fully offline on-device inference.

---

## Resource Usage

| Resource | Planned | Actual |
|----------|---------|--------|
| Training Time | 3-4 hours | 84 minutes |
| Training Data | 500-1000 pairs | 3,007 pairs |
| Model Size | ~1.7GB GGUF | LoRA adapter ~100MB |
| GPU | Colab A100 | Colab A100 (free tier) |

---

## Risk Mitigation (Updated)

| Risk | Status | Mitigation |
|------|--------|------------|
| Training fails | ✅ Resolved | Completed successfully |
| Model too slow | 🔄 Active | Using CPU bfloat16, consider Pro for GPU |
| HuggingFace bugs | 🔄 Active | Pinned pydantic <2.11.0 |
| App store rejection | ⏳ Future | Prepare documentation |

---

*Last updated: February 9, 2026*
*Training: Qwen3-0.6B Micro-DAPT + SFT in progress on Kaggle*
*Current milestone: Phase 3 - Data Population & AI Model*
*Architecture: Hybrid Retrieval (Deterministic + Optional AI)*
*Target Model: Qwen3-0.6B (<1GB GGUF) with two-stage training*
