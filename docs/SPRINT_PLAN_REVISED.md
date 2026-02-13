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
- [x] Integration tests (232 passing) ✅

### Phase 2.5: Code Quality & Security ✅ COMPLETE (Feb 10, 2026)

Multi-agent code review completed with 19 GitHub issues closed.

#### Security Enhancements ✅
- [x] Encrypted Hive storage (AES cipher + flutter_secure_storage)
- [x] Input validation & sanitization (SQL/FTS5 injection prevention)
- [x] ReDoS (regex denial-of-service) detection
- [x] URL validation for model downloads (allowlist enforcement)
- [x] SHA256 checksum verification for downloads
- [x] Secure timeout handling (10-second limits)

#### Infrastructure ✅
- [x] Database migration framework with version tracking
- [x] i18n/l10n infrastructure (ARB files for English/Tamil)
- [x] Accessibility (Semantics widgets for screen readers)
- [x] Inference metrics (first token latency, tokens/second)
- [x] JSON Schema validation for training data
- [x] Preflight validation script for training runs

#### Code Quality ✅
- [x] Test coverage: 232 tests passing
- [x] Training data rebalancer (Thirukkural 71%→25% target)
- [x] Comprehensive error handling throughout
- [x] Deprecated API cleanup (provider namespacing)

**Issues Closed**: #22-32, #27, #29, #33-40 (19 total from code review)

### Phase 3: Data Population & AI 🔄 IN PROGRESS

#### Data Pipeline ✅
- [x] **Data pipeline restructure (ADR-010)** — four-layer pipeline, composition enforcement, anti-memorization
- [x] **Dataset Factory v4.0** (`Vazhi_Dataset_Factory_v4_0.ipynb`) — ran on Kaggle, produced 3,365 curated SFT samples
- [x] **DAPT data prep notebook** (`Vazhi_DAPT_Data_v1_0.ipynb`) — CPU-only, streams Sangraha, filters, packs 30M tokens
- [x] **DAPT training notebook** (`Vazhi_DAPT_v1_0_Tamil.ipynb`) — GPU, QLoRA on Qwen3-0.6B-Base, produces reusable Tamil base

#### Database Population (not blocked)
- [ ] Full Thirukkural database (1,330 verses)
- [ ] Complete government schemes database
- [ ] Hospital directory population

#### AI Model Training 🔄
**Current approach: 3-step pipeline (DAPT → SFT → GGUF)**
- [x] **Step 1: Run DAPT data prep** on Colab CPU — filter Sangraha, pack 33M tokens, upload to HF ✅
- [x] **Step 2: Run DAPT training** on Kaggle T4 GPU — produced `CryptoYogi/qwen3-0.6b-tamil` (375 steps, val loss 1.016, 8/8 eval passed) ✅
- [ ] **Step 3: Run SFT** on DAPT-adapted model with v4.0 dataset (3,365 samples)
- [ ] **Step 4: GGUF conversion** and Tamil output quality validation

**DAPT v1.0 Results (Feb 12, 2026):**
- Data: 16,450 Sangraha docs → 32,244 packed 1024-token blocks
- Training: 375/500 steps on Kaggle T4, fp16, LoRA r=16, ~3.5 hours
- Val loss: 1.045 → 1.016 (steady improvement)
- Eval: 8/8 Tamil continuations passed, avg 66% Tamil, 97% unique words
- Artifacts: `CryptoYogi/qwen3-0.6b-tamil` (merged fp16) + `CryptoYogi/qwen3-0.6b-tamil-lora` (adapter backup)

**Model Training History (13 failed attempts, 1 DAPT success):**
- v0.1-v0.4: Qwen2.5-3B — data quality issues then GGUF broke Tamil
- v0.5: Qwen2.5-0.5B — LoRA corrupted model
- v0.6: Sarvam-2B — 4-bit training instability
- v0.7: Gemma-2B Tamil — tokenizer corruption broke GGUF
- v3.1: Qwen3-0.6B — mixed data formats (raw + ChatML)
- v3.2: Qwen3-0.6B — fp16 issues on T4
- v3.3: Qwen3-0.6B (instruct) — native `<think>` tokens conflicted with ChatML
- v3.4: Qwen3-0.6B-Base — base model approach, not validated
- v3.5: Qwen3-0.6B — SFT-only on base model produced code garbage (no DAPT)
- v3.6: Qwen3-0.6B — training succeeded but LoRA merge into 4-bit model corrupted output
- v3.7: Qwen3-0.6B — superseded by v3.8 (v4.0 dataset)
- v3.8 (FAILED): Qwen3-0.6B (instruct) — SFT-only with v4.0 dataset, 0/12 eval, no DAPT = gibberish Tamil
- **DAPT v1.0 (SUCCESS):** Qwen3-0.6B-Base + 16M tokens Sangraha → Tamil base model, 8/8 eval passed

See `models/TRAINING_LOG.md` for full details and lessons learned.

### Phase 3.5: App Store Prep 🔄 PARTIAL
- [x] App icon updated (VAZHI peacock logo, replaces Flutter default)
- [x] Display name set to "VAZHI - வழி"
- [x] Application ID changed to `com.cryptoyogillc.vazhi`
- [x] Release AAB built and uploaded to Google Play
- [ ] Google Play developer account verification (requires Android phone)
- [ ] Publish internal testing link for testers
- [ ] Apple App Store: TestFlight submission (icon/name/bundle ID already set)

### Phase 4: Polish & Launch
- [ ] Expert directory feature
- [ ] FTS5 Tamil search optimization
- [ ] Demo video recording
- [ ] TestFlight submission (Apple)

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
| AI Model | Gemma-2B Tamil (1.6GB) | **Qwen3-0.6B (<1GB)** | Gemma tokenizer corrupted; Qwen3-0.6B is instruct-capable with clean ChatML support |
| Training Approach | Single SFT pass | **DAPT (Base) → SFT (instruct-style)** | SFT-only cannot teach Tamil; DAPT on Sangraha corpus first, then SFT with ChatML dataset |

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
| Training fails | 🟡 Partial | DAPT v1.0 succeeded (Tamil base model); SFT pending as final step |
| Model too slow | 🔄 Active | Using CPU bfloat16, consider Pro for GPU |
| HuggingFace bugs | 🔄 Active | Pinned pydantic <2.11.0 |
| App store rejection | ⏳ Future | Prepare documentation |

---

*Last updated: February 12, 2026*
*Code Review: 19 issues closed, 232 tests passing*
*Training: DAPT v1.0 complete (Tamil base model on HF), SFT pending*
*Current milestone: Phase 3 - Data Population & AI Model*
*Architecture: Hybrid Retrieval (Deterministic + Optional AI)*
*Target Model: Qwen3-0.6B (<1GB GGUF) with DAPT (Base) → SFT → GGUF*
*Training attempts: 13 failed, DAPT v1.0 succeeded*
