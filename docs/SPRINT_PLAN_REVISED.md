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

#### App Model Selector ✅ (Feb 17, 2026)
- [x] **Model selector architecture (ADR-011)** — ModelVariant + ModelRegistry single source of truth
- [x] **3 GGUF variants** — Q4_K_M (806MB, best), Q3_K_M (722MB, medium), Q2_K (690MB, low)
- [x] **Persisted selection** — SharedPreferences + Riverpod StateNotifier
- [x] **Bottom sheet UI** — radio-style cards with bilingual quality labels
- [x] **DRY violation eliminated** — services accept ModelVariant via constructor injection
- [x] **247 tests passing** (15 new model variant tests)

#### Database Population (not blocked)
- [ ] Full Thirukkural database (1,330 verses)
- [ ] Complete government schemes database
- [ ] Hospital directory population

#### AI Model Training ✅ PIVOTED TO GEMMA 3
**Final approach: Gemma 3 1B-it + SFT → GGUF (no DAPT needed)**

**Gemma 3 Pivot (Feb 2026):**
After 20 failed Qwen3-0.6B training attempts (v0.1→v6.0), Model Comparison v1 benchmarked 7 models. **Gemma 3 1B-it is the clear winner**: real Tamil output, relevant answers, structured output, Q4_K_M = 0.60GB. Google's 2T-token multilingual pretraining provides native Tamil — no DAPT required.

- [x] **SFT v7.0** — Gemma 3 1B-it + LoRA r=8, Tamil 94% word. Identity/factual not learned (conservative LoRA) ✅
- [x] **SFT v7.1** — incremental r=16 on v7.0, **Tamil 96% word (best ever)** — DEPLOYMENT CANDIDATE ✅
- [x] **SFT v7.2** — identity-only reinforcement — FAILED (Gemma's Google identity unhackable via LoRA) ✅
- [x] **GGUF conversion** — Q4_K_M, Q3_K_M, Q2_K uploaded to HuggingFace ✅
- [x] **App integration** — model selector wired to all 3 variants, download/load working ✅
- [ ] **Step 7: Test GGUF output quality** on mobile device (Tamil coherence after quantization)

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
| AI Model | Gemma-2B Tamil (1.6GB) | **Gemma 3 1B-it (<1GB)** | Google's 2T-token multilingual pretraining provides native Tamil; 20 Qwen3-0.6B attempts all failed |
| Training Approach | Single SFT pass | **SFT-only on Gemma 3 1B-it** | Gemma 3 has native Tamil — no DAPT needed. Identity handled via system prompt, facts via SQLite hybrid retrieval |
| Model Selection | Hardcoded single model | **ModelVariant + ModelRegistry (ADR-011)** | 3 GGUF variants for different device capabilities; single source of truth eliminates DRY violation |

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

*Last updated: February 19, 2026*
*Code Review: 19 issues closed, 293 tests passing*
*Training: SFT v7.1 on Gemma 3 1B-it — DEPLOYMENT CANDIDATE (96% Tamil word)*
*Current milestone: Phase 3 - On-device AI working on 4GB Android, app store submission pending*
*Architecture: Hybrid Retrieval (Deterministic + Optional AI) + Model Selector (ADR-011)*
*Target Model: Gemma 3 1B-it SFT v7.1 — vocab-trimmed Q4_K_M (481 MB) confirmed working on 4GB device*
*Training attempts: 20 Qwen3 failed → Gemma 3 pivot → v7.1 succeeded → on-device verified*
*App: v0.8.0 — Tamil chat working, streaming responses, multi-turn context, auto model load*
