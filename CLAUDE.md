# VAZHI Project Context

## Overview

VAZHI (வழி) is a free, offline Tamil AI assistant for mobile (Android + iOS). It protects people from scams, connects them with government benefits, provides health info, and shares Tamil culture/wisdom — all without internet, without tracking, without fees.

**Target Audience:** Rural Tamil Nadu users with limited connectivity and mid-range smartphones.

**Tech Stack:** Flutter 3.24 + Riverpod 2.6 | SQLite + Hive (encrypted) | Gemma 3 1B-it target (<1GB GGUF Q4_K_M = 0.60GB)

**Architecture:** Hybrid Retrieval — deterministic SQLite lookups for facts (Thirukkural, govt schemes, emergency numbers) + optional on-device AI model for conversational responses. App provides value immediately without model download.

**MVP Strategy:** Ship the hybrid app WITHOUT the AI model first. The deterministic SQLite-only path provides immediate value for lookups and factual queries. AI model will be added as an optional download once training succeeds.

**Monetization:** Purely free, donation-supported (Ko-fi/GitHub Sponsors). No ads, no premium tier.

**Team:** Solo developer (CryptoYogi), open for contributors.

**HuggingFace Space:** Dev/testing only — not a production backend. Production is fully on-device.

## Current Status (Feb 2026)

**Phase:** 3 — On-Device AI Working, App Store Submission Pending

**Completed:**
- Flutter app with chat UI, voice I/O (Tamil STT/TTS), hybrid retrieval, model download manager
- **Smart model selector** (ADR-013): 3 GGUF variants with RAM-based device tier filtering, user-friendly labels, pre-inference RAM checks, MediaStore Downloads persistence
- **Two-tier architecture** (ADR-012): 4GB Android = SQLite retrieval only (all Gemma 3 models OOM), 6GB+ = on-device LLM
- **4GB device crash fixes** (v0.7.0): ARM baseline `armv8.2-a+fp16+dotprod` (Cortex-A55+), GPU offload disabled, n_ctx=256, Vulkan removed (APK 130→100 MB)
- **Model file persistence**: MediaStore Downloads/VAZHI/ via platform channel — survives app uninstall/reinstall
- 6 knowledge packs: Security (468), Government (467), Education (602), Legal (610), Healthcare (460), Culture (400) = 3,007 bilingual training pairs
- Security hardened: encrypted storage, input validation, ReDoS protection, URL allowlist, SHA256 verification
- 293 tests passing, CI/CD via GitHub Actions
- 19 code review issues identified and closed (#22-40)
- **On-device AI fully working on 4GB Android** (app v0.8.0) — vocab-trimmed Q4_K_M (481 MB) loads, streams Tamil responses, handles multi-turn conversations
- **Chat template runtime fix** — Gemma 3 template registered as fallback override in llamadart via `ChatTemplateEngine.registerTemplateOverride()`
- **Streaming LLM responses** — `chatStream()` yields tokens progressively for real-time UI updates
- **Multi-turn context** — disabled llamadart's broken `_enforceContextLimit` (maxContextTokens: 0), llama.cpp context shifting handles overflow naturally
- **Model auto-loads on startup** — fixed false crash detection from stale diagnostic files
- **RAG context truncation** — 150 char limit for SQLite context (n_ctx=256 token budget)
- **Tamil default UI** — language toggle defaults to Tamil, "AI Brain" → "AI சக்தி"
- **Android 12+ splash screen** — peacock logo via `windowSplashScreenAnimatedIcon` (API 31+)
- Google Play: AAB uploaded, awaiting developer account verification

**In progress:**
- **SFT v7.1 is deployment candidate** for 6GB+ devices (96% Tamil word, best SFT'd model)
- **Identity solution**: System prompt at inference time ("You are VAZHI"); factual corrections via hybrid SQLite retrieval

**Pending (not blocked):**
- Apple App Store: TestFlight submission
- Full Thirukkural database (1,330 verses)
- Government schemes database population
- Hospital directory population

## Training History

See `models/TRAINING_LOG.md` for full history (30+ experiments across Qwen2.5, Sarvam, Gemma-2B, Qwen3-0.6B, and Gemma 3 lines).

**Summary:** Qwen3-0.6B exhausted after 20 training attempts (v0.1→v6.0) — DAPT+SFT pipeline built but 0.6B model can't learn Tamil semantics. Pivoted to Gemma 3 1B-it which produces real Tamil with zero fine-tuning (262K vocab, 2T-token multilingual pretraining). SFT v7.1 (LoRA r=16, 96% Tamil word) is the deployment candidate. Identity handled via system prompt (Gemma's Google identity is unhackable via LoRA). Vocabulary trimming (262K→21K) enables 4GB Android deployment.

**Next step:** Prepare for release. If quality insufficient, SFT the trimmed model for VAZHI-specific content.

**Data source for SQLite population:** Open data scraping from Tamil Nadu government websites and Tamil databases.

## Key Rules

> Qwen3/DAPT-era rules relocated to `docs/LESSONS_LEARNED.md` (Feb 2026). Rules below are actively relevant.

### Data Rules
- **NEVER trust data labels** — verify with character-level Tamil % analysis
- **Multi-agent LLM pipelines can silently produce garbage** — always audit output quality at scale
- **Use source text directly when possible** — direct article text as answers produces higher quality than LLM restructuring

### Training Rules
- **Model architecture > training data for low-resource languages** — Gemma 3 1B-it (262K vocab, 2T-token multilingual pretraining) produces real Tamil with zero fine-tuning. When the base model lacks language capacity, no amount of DAPT/SFT can teach it
- **Benchmark before training** — always compare candidate models side-by-side on target language BEFORE committing to training
- **Pretrained identity is unhackable via LoRA SFT** — Gemma 3's "I am Google" identity survives all LoRA fine-tuning. Solution: handle identity via system prompt at inference time. Factual corrections unreliable via SFT — handle via hybrid SQLite retrieval
- **Identity-only training causes domain regression** — even small focused training (90 samples x 10 epochs) can overwrite broader capabilities
- **Test GGUF output EARLY** — after 100 steps, not after 2000. Training success != deployment success
- **Preflight fail-fast** — run tiny training before full run to catch issues early
- **Checkpoint to HF Hub** every epoch (Colab/Kaggle disconnect protection)
- **Eval must check output QUALITY** — automated metrics can false-positive (SFT v4.0: 12/12 "passed" but all gibberish). Test fluency, instruction-following, tone — not just Tamil %
- **Tamil char % is fundamentally broken as eval** — transliterated English in Tamil script scores high but is gibberish. Need Tamil WORD validation
- **NEVER merge LoRA into 4-bit model** — save adapter → reload base in fp16 → merge in fp16
- **Clear `generation_config.suppress_tokens` before generating** — prevents device mismatch in logits processor
- **Disable gradient checkpointing before eval** — conflicts with use_cache

### Quantization Rules
- **Q4_K_M is minimum viable** for Tamil — Q3 and below cause visible degradation
- **Smaller models quantize better** — less absolute precision loss
- **Gemma 3's 262K vocab creates a fixed memory floor** — 30% of params are in the unquantized embedding matrix. Vocab size matters as much as parameter count for memory-constrained devices
- **No untrimmed Gemma 3 model can run on 4GB Android** — tested 1B-it and 270M-it, all OOM. Two-tier: 4GB = SQLite only, 6GB+ = LLM (ADR-012)
- **Google QAT models are robust to aggressive quantization** — QAT Q2_K (690 MB) produces substantive Tamil. Always prefer QAT variants when available
- **Vocabulary trimming is the only path to 4GB LLM support** — 262K→~21K vocab cuts embedding from ~576 MiB to ~46 MiB. Verified working on 4GB Android
- **Always verify `tokenizer.chat_template` in GGUF after conversion** — without it, runtimes fall back to wrong chat format → gibberish. Fix: `gguf-new-metadata --chat-template-config tokenizer_config.json`
- **GGUF conversion preserves model quality** — test in BOTH completion mode and conversation mode when debugging issues
- **Gemma 3 270M-it produces real Tamil at 283 MB** — shallow content but usable as "language glue" with hybrid SQLite for factual accuracy

### Data Pipeline Rules (ADR-010)
- **NEVER mix DAPT and SFT data** — physically separated in `data/sources/dapt/` and `data/sources/sft/`
- **vazhi-packs MUST be in training** — flattened copies in `data/sources/sft/vazhi-packs/`
- **IndicAlign diversity >= 30%** of SFT dataset — prevents memorization
- **Thirukkural hard-capped at <= 15%** — verbatim Q&As rejected, only interpretive allowed
- **Composition targets are hard constraints** — Dataset Factory fails if violated
- **Legacy scripts raise RuntimeError** — `create_diverse_qa_pack.py` and `create_balanced_sft_dataset.py` are superseded
- **Validate tokenized length, not just character length** — Tamil can exceed `max_seq_length` after tokenization
- **Source-aware filtering** — vazhi_packs/handcrafted bypass quality_score, PPL, and tamil_pct filters
- **PPL is fluency, not quality** — use as weak signal for garbage detection (>200), not as a gate

### App/Security Rules
- **Input validation is non-negotiable** — sanitize ALL user input at service boundaries
- **Encrypt sensitive local storage** — Hive alone is not secure, use flutter_secure_storage
- **Use allowlists for external URLs** — never trust user-provided URLs for model downloads
- **Verify downloads with SHA256 checksums**
- **Single source of truth for model metadata** — all GGUF model info lives in `ModelVariant` + `ModelRegistry`. Services accept `ModelVariant` via constructor injection. Adding a new model = one registry entry, zero service changes (ADR-011)
- **Persist user preferences with SharedPreferences** — Riverpod `StateNotifier` + SharedPreferences for reactive persistence
- **Demarcate VAZHI vs community models** — `ModelVariant.isVazhi` field. VAZHI models listed first, community below
- **Persist model files in MediaStore Downloads** — `Downloads/VAZHI/` via Android MediaStore API. Files survive app uninstall/reinstall
- **Explicitly disable GPU offload when no GPU backend** — set `offload_kqv=false`, `op_offload=false`, `flash_attn_typeAsInt=0`. Leaving defaults causes SIGABRT
- **Build native libraries for ARMv8.2-A baseline** — `GGML_CPU_ARM_ARCH=armv8.2-a+fp16+dotprod`. Do NOT use `i8mm` or `sve` — cause SIGILL on Cortex-A55
- **Cap llama.cpp n_ctx for memory-constrained devices** — use n_ctx=256 minimum for Tamil inference
- **Remove unused native backends from APK** — disabling Vulkan saved 30 MB (APK 130→100 MB)
- **Diagnose native crashes by signal type** — SIGABRT = assertion, SIGSEGV = memory, SIGILL = illegal instruction
- **llamadart's `_enforceContextLimit` is broken for n_ctx < 512** — disable it (`maxContextTokens: 0`), rely on llama.cpp's native context shifting
- **Don't clear chat session history as a "fix" for context overflow** — let llama.cpp's sliding window handle overflow
- **Register chat template overrides at runtime** — llamadart may not use GGUF `tokenizer.chat_template` in all code paths. Use `ChatTemplateEngine.registerTemplateOverride()` with architecture matcher
- **Android 12+ (API 31) ignores legacy splash screen** — requires `windowSplashScreenAnimatedIcon` in `values-v31/styles.xml`
- **RAG context must be truncated for small n_ctx** — cap SQLite context at 150 chars for n_ctx=256

## Project Structure

```
vazhi/
├── CLAUDE.md                     # This file — project context for CC agents
├── README.md                     # Public-facing project overview
├── vazhi_app/                    # Flutter mobile app
│   ├── APP_CHANGELOG.md          # App feature history & architecture decisions
│   ├── lib/
│   │   ├── database/migrations/  # Versioned schema changes
│   │   ├── l10n/                 # i18n (English + Tamil ARB files)
│   │   ├── models/model_variant.dart  # ModelVariant + ModelRegistry (single source of truth)
│   │   ├── providers/            # Riverpod state management
│   │   ├── services/             # Query router, APIs, voice, downloads
│   │   └── widgets/              # Accessible UI components
│   └── test/                     # 293 tests
├── data/                         # Training data pipeline (ADR-010)
│   ├── sources/                  # Source data (dapt/ + sft/ + metadata/)
│   ├── curated/                  # Local backups of HF datasets
│   └── LEGACY/                   # Archived pre-pipeline data (read-only)
├── models/
│   └── TRAINING_LOG.md           # Detailed log of all 30+ training attempts
├── notebooks/                    # Kaggle/Colab training notebooks
│   ├── Vazhi_SFT_v7_*.ipynb      # Current: Gemma 3 SFT (v7.0, v7.1, v7.2)
│   ├── Vazhi_Model_Comparison_v1.ipynb  # 7-model Tamil benchmark
│   ├── Vazhi_4GB_Optimization.ipynb     # 4GB device deployment research
│   └── [20+ historical notebooks — Qwen3 DAPT/SFT, Dataset Factory]
├── scripts/                      # Data processing, validation, rebalancing
├── schemas/                      # JSON schemas for training data validation
├── vazhi-packs/                  # 6 domain-specific knowledge packs
├── tools/                        # Developer utilities (GGUF diagnostic, 4GB test harness)
├── huggingface-space/            # Gradio test API (submodule)
└── docs/
    ├── SPRINT_PLAN_REVISED.md    # Roadmap and phase tracking
    ├── LESSONS_LEARNED.md        # 140+ lessons (incl. relocated Qwen3/DAPT rules)
    ├── HUGGINGFACE_RESOURCES.md  # Full catalog of 30+ HF datasets/models
    ├── CODE_REVIEW_CONSENSUS_REPORT.md
    └── adr/                      # 14 Architecture Decision Records
```

## Key Documents (Read Order for New Agents)

1. **This file** — start here
2. **`vazhi_app/APP_CHANGELOG.md`** — app feature history, architecture decisions, and lessons learned
3. **`docs/adr/011-model-selector-architecture.md`** — model selector pattern (ModelVariant + ModelRegistry + SharedPreferences)
4. **`docs/adr/010-data-pipeline-architecture.md`** — data pipeline design, composition targets, anti-memorization rules
5. **`models/TRAINING_LOG.md`** — detailed training history, decisions, and failure analysis
6. **`docs/SPRINT_PLAN_REVISED.md`** — roadmap, phases, what's done vs pending
7. **`docs/LESSONS_LEARNED.md`** — 140+ lessons, including Qwen3/DAPT-era rules relocated from this file
8. **`docs/HUGGINGFACE_RESOURCES.md`** — full catalog of HF datasets, models, and adapters
9. **`docs/CODE_REVIEW_CONSENSUS_REPORT.md`** — security findings (all 19 fixed)

## Development Commands

```bash
# Flutter app
cd vazhi_app
flutter pub get
flutter test                      # Run all 293 tests
flutter run                       # Run on connected device/simulator
flutter analyze                   # Dart static analysis

# Python scripts
python scripts/preflight_validation.py   # Pre-training checks
python scripts/validate_training_data.py # Schema validation
python scripts/rebalance_training_data.py # Fix Thirukkural skew

# CI/CD
gh workflow run ci.yml            # Trigger GitHub Actions
```

## Open GitHub Issues

- **#1-5**: Phase epics (1: Lite MVP, 2: Offline Mode, 3: Pack Manager, 4: Polish, 5: App Store)
- **#12**: Improve Culture pack Thirukkural data (partially addressed by data regen)
- **#13**: Convert model to GGUF for mobile (completed — v7.1 GGUF deployed, vocab-trimmed variants working on 4GB Android)

## HuggingFace Resources (Active)

- **SFT v7.1 model: `CryptoYogi/vazhi-v7_1`** — DEPLOYMENT CANDIDATE (LoRA r=16, 96% Tamil word, best ever)
- **SFT dataset v7.0: `CryptoYogi/vazhi-tamil-sft-v7_0`** — 4,172 samples for Gemma 3 format
- **DAPT v2.1 dataset: `CryptoYogi/vazhi-dapt-tamil-v2_1`** — 39.5M tokens (for future Qwen3 work if needed)
- **External — 270M GGUF:** `bartowski/google_gemma-3-270m-it-GGUF` (Q6_K_L = 283 MB for 4GB tier)
- **External — QAT 1B GGUF:** `bartowski/google_gemma-3-1b-it-qat-GGUF` (QAT Q2_K = 690 MB for 6GB+ tier)
- Space: `CryptoYogi/vazhi` (Gradio test API)

For the full catalog of 30+ HF resources (all datasets, models, adapters, legacy), see `docs/HUGGINGFACE_RESOURCES.md`.
