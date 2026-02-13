# VAZHI Project Context

## Overview

VAZHI (வழி) is a free, offline Tamil AI assistant for mobile (Android + iOS). It protects people from scams, connects them with government benefits, provides health info, and shares Tamil culture/wisdom — all without internet, without tracking, without fees.

**Target Audience:** Rural Tamil Nadu users with limited connectivity and mid-range smartphones.

**Tech Stack:** Flutter 3.24 + Riverpod 2.6 | SQLite + Hive (encrypted) | Qwen3-0.6B target (<1GB GGUF, hard limit)

**Architecture:** Hybrid Retrieval — deterministic SQLite lookups for facts (Thirukkural, govt schemes, emergency numbers) + optional on-device AI model for conversational responses. App provides value immediately without model download.

**MVP Strategy:** Ship the hybrid app WITHOUT the AI model first. The deterministic SQLite-only path provides immediate value for lookups and factual queries. AI model will be added as an optional download once training succeeds.

**Monetization:** Purely free, donation-supported (Ko-fi/GitHub Sponsors). No ads, no premium tier.

**Team:** Solo developer (CryptoYogi), open for contributors.

**HuggingFace Space:** Dev/testing only — not a production backend. Production is fully on-device.

## Current Status (Feb 2026)

**Phase:** 3 — Data Population & AI Model Training

**What's done:**
- Flutter app with chat UI, voice I/O (Tamil STT/TTS), hybrid retrieval, model download manager
- 6 knowledge packs: Security (468), Government (467), Education (602), Legal (610), Healthcare (460), Culture (400) = 3,007 bilingual training pairs
- Security hardened: encrypted storage, input validation, ReDoS protection, URL allowlist, SHA256 verification
- 232 tests passing, CI/CD via GitHub Actions
- 19 code review issues identified and closed (#22-40)

**What's blocking:**
- AI model training — 13 failed SFT attempts across 5 base models, but **DAPT v1.0 succeeded**
- DAPT complete: `CryptoYogi/qwen3-0.6b-tamil` — Tamil base model (375 steps, val loss 1.016, 8/8 eval passed)
- Next step: SFT on DAPT'd model with v4.0 ChatML dataset (notebook to be created)

**What's done (app distribution):**
- Google Play: App icon (peacock logo), display name ("VAZHI - வழி"), application ID (`com.cryptoyogillc.vazhi`), AAB uploaded — awaiting developer account verification (needs Android phone) before internal testing can go live

**What's pending (not blocked):**
- Apple App Store: TestFlight submission
- Full Thirukkural database (1,330 verses)
- Government schemes database population
- Hospital directory population

## Training History (Critical Context)

| Version | Model | Result | Root Cause |
|---------|-------|--------|------------|
| v0.1-v0.2 | Qwen2.5-3B | Failed | 74% of "Tamil" data was actually English |
| v0.4 | Qwen2.5-3B | Failed | GGUF quantization destroyed Tamil output |
| v0.5 | Qwen2.5-0.5B | Failed | LoRA corrupted model (r=32 too aggressive for 0.5B) |
| v0.6 | Sarvam-2B | Failed | 4-bit training instability |
| v0.7 | Gemma-2B Tamil | Failed | Tokenizer corruption (OrderedVocab holes) broke GGUF |
| v3.1 | Qwen3-0.6B | Failed | Mixed raw text + ChatML in SFT = "systemsystem..." garbage |
| v3.2 | Qwen3-0.6B | Failed | fp16 training issue on T4; dataset reused in v3.3 |
| v3.3 | Qwen3-0.6B (instruct) | Failed | Native `<think>` tokens conflicted with ChatML; LR 1e-4 too aggressive |
| v3.4 | Qwen3-0.6B-Base | Superseded | Never run — missing completion-only masking |
| v3.5 | Qwen3-0.6B-Base | Failed | SFT-only on base model produced code garbage — base model has no Tamil without DAPT |
| v3.6 | Qwen3-0.6B (instruct) | Failed | Dataset + masking + training correct, but LoRA merge into 4-bit model corrupted weights → 0% Tamil |
| v3.7 | Qwen3-0.6B (instruct) | Superseded | Same as v3.6 but merge fix — superseded by v3.8 (v4.0 dataset) |
| v3.8 | Qwen3-0.6B (instruct) | Failed | SFT-only with Dataset Factory v4.0 (3,365 samples), 0/12 eval, avg Tamil 52%, gibberish — no DAPT |
| DAPT v1.0 | Qwen3-0.6B-Base | **Success** | DAPT 16M tokens Sangraha, 375 steps, val loss 1.016, 8/8 eval passed. Model: `CryptoYogi/qwen3-0.6b-tamil` |

**Current strategy (DAPT-first):**
- **Step 1:** Data prep — filter Sangraha Tamil corpus, pack into 33M tokens (`Vazhi_DAPT_Data_v1_0.ipynb`, CPU) ✅ DONE
- **Step 2:** DAPT — train Qwen3-0.6B-Base on 16M tokens → `CryptoYogi/qwen3-0.6b-tamil` (`Vazhi_DAPT_v1_0_Tamil.ipynb`, GPU) ✅ DONE
- **Step 3:** SFT — fine-tune Tamil base on v4.0 ChatML dataset (`Vazhi_SFT_v3_9_OnDAPT.ipynb`, to be created)
- **Optional:** Incremental DAPT — load DAPT'd model, train on remaining ~17M tokens
- **Fallback:** Sarvam-1 IQ3_M (1.17GB, proven Tamil, exceeds <1GB hard limit)

**Data source for SQLite population:** Open data scraping from Tamil Nadu government websites and Tamil databases.

## Key Rules (From 46 Lessons Learned)

### Data Rules
- **NEVER trust data labels** — verify with character-level Tamil % analysis
- **NEVER mix data formats in SFT** — raw text belongs in DAPT, ChatML in SFT. Mixing causes garbage
- **Verify 100% ChatML format** before any SFT run: `is_chatml_formatted()` check on all samples

### Training Rules
- **Test GGUF output EARLY** — after 100 steps, not after 2000. Training success != deployment success
- **NEVER modify tokenizer special tokens** — `pad_token = eos_token` causes OrderedVocab holes and corrupts GGUF
- **NEVER ignore tokenizer warnings** — "OrderedVocab contains holes" is FATAL, stop immediately
- **Two-stage training** (DAPT then SFT) preserves both Tamil fluency AND instruction-following
- **Preflight fail-fast** — run tiny DAPT+SFT before full training to catch issues early
- **Checkpoint to HF Hub** every epoch (Colab/Kaggle disconnect protection)
- **Suppress conflicting tokens instead of pivoting to base model** — instruct models have language capability; base models with SFT-only produce garbage
- **Iterate on what works** — fix specific issues (token suppression, LR) rather than pivoting to untested approaches
- **Strict ChatML validation** (regex) before training — reject samples missing user/assistant segments
- **Eval must check output QUALITY** — Tamil char %, coherence, not just pattern absence
- **NEVER merge LoRA into 4-bit model** — save adapter → reload base in fp16 → merge in fp16. 4-bit is for training memory only
- **Disable gradient checkpointing before eval** — conflicts with use_cache, forces generation without KV cache

### Quantization Rules
- **Q4_K_M is minimum viable** for Tamil — Q3 and below cause visible degradation
- **Smaller models quantize better** — less absolute precision loss
- **Tamil tokenization overhead** (3-4 tokens/char) compounds quantization errors

### Data Pipeline Rules (ADR-010)
- **NEVER mix DAPT and SFT data** — physically separated in `data/sources/dapt/` and `data/sources/sft/`
- **vazhi-packs MUST be in training** — flattened copies in `data/sources/sft/vazhi-packs/`
- **IndicAlign diversity >= 30%** of SFT dataset — prevents memorization and improves generalization
- **Thirukkural hard-capped at <= 15%** — verbatim Q&As rejected, only interpretive Q&As allowed
- **Composition targets are hard constraints** — Dataset Factory fails if violated, not aspirational
- **Dataset Factory notebook** (`notebooks/Vazhi_Dataset_Factory_v4_0.ipynb`) constructs curated datasets on Kaggle
- **Legacy scripts raise RuntimeError** — `create_diverse_qa_pack.py` and `create_balanced_sft_dataset.py` are superseded

### DAPT Rules
- **Use Base model for DAPT, not Instruct** — DAPT washes out chat behaviors; base model is a clean slate
- **Separate data prep from training** — data prep (CPU) uploads to HF; training (GPU) loads from HF
- **Token budget, not epochs** — control by target tokens (30M) and max_steps, cap at 2 epochs max
- **Verify corpus schema before coding** — inspect actual HF dataset columns and samples (avoid IndicAlign repeat)
- **Pack sequences** — concatenate docs into continuous token stream, split into fixed 1024-token blocks (no padding waste)
- **Filter Sangraha** — Tamil% >= 50%, 200-8000 chars, dedup by MD5, repetition ratio < 0.5

### App/Security Rules
- **Input validation is non-negotiable** — sanitize ALL user input at service boundaries
- **Encrypt sensitive local storage** — Hive alone is not secure, use flutter_secure_storage
- **Use allowlists for external URLs** — never trust user-provided URLs for model downloads
- **Verify downloads with SHA256 checksums**

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
│   │   ├── services/             # Query router, APIs, voice, downloads
│   │   ├── widgets/              # Accessible UI components
│   │   └── providers/            # Riverpod state management
│   └── test/                     # 232 tests
├── data/                         # Training data pipeline (ADR-010)
│   ├── sources/                  # Source data, organized by intended use
│   │   ├── dapt/                 # Raw Tamil text for DAPT (NEVER for SFT)
│   │   ├── sft/
│   │   │   ├── vazhi-packs/      # Flattened Q&A from 6 domain packs
│   │   │   └── handcrafted/      # Refusal, brevity, greeting, guardrails
│   │   └── metadata/             # source_manifest.json (intended_use per file)
│   ├── curated/                  # Local backups of HF datasets
│   └── LEGACY/                   # Archived pre-pipeline data (read-only)
├── models/
│   └── TRAINING_LOG.md           # Detailed log of all 13 training attempts + DAPT strategy
├── notebooks/                    # Kaggle/Colab training notebooks
│   ├── Vazhi_DAPT_Data_v1_0.ipynb   # DAPT data prep (CPU) — filter/pack Sangraha
│   ├── Vazhi_DAPT_v1_0_Tamil.ipynb  # DAPT training (GPU) — LATEST
│   ├── Vazhi_Dataset_Factory_v4_0.ipynb # SFT dataset construction (ADR-010)
│   ├── Vazhi_SFT_v3_7_MergeFix.ipynb # Superseded — fp16 merge fix
│   ├── Vazhi_SFT_v3_6_Instruct.ipynb # FAILED — LoRA merge corruption
│   ├── Vazhi_SFT_v3_5_Masked.ipynb # FAILED — Base model SFT-only
│   ├── Vazhi_SFT_v3_3_Clean.ipynb
│   ├── Vazhi_SFT_v3_2_Fixed.ipynb
│   └── [13 more historical notebooks]
├── scripts/                      # Data processing, validation, rebalancing
├── schemas/                      # JSON schemas for training data validation
├── vazhi-packs/                  # 6 domain-specific knowledge packs (app references these)
├── huggingface-space/            # Gradio test API (submodule)
└── docs/
    ├── SPRINT_PLAN_REVISED.md    # Roadmap and phase tracking
    ├── LESSONS_LEARNED.md        # 46 lessons from training journey
    ├── CODE_REVIEW_CONSENSUS_REPORT.md
    ├── DATA_REGENERATION_PLAN.md # Historical — v0.2 data crisis
    └── adr/                      # 10 Architecture Decision Records
```

## Key Documents (Read Order for New Agents)

1. **This file** — start here
2. **`vazhi_app/APP_CHANGELOG.md`** — app feature history, architecture decisions, and lessons learned
3. **`docs/adr/010-data-pipeline-architecture.md`** — data pipeline design, composition targets, anti-memorization rules
4. **`models/TRAINING_LOG.md`** — detailed training history, decisions, and failure analysis
5. **`docs/SPRINT_PLAN_REVISED.md`** — roadmap, phases, what's done vs pending
6. **`docs/LESSONS_LEARNED.md`** — 46 hard-won lessons, ideal training pipeline
7. **`docs/CODE_REVIEW_CONSENSUS_REPORT.md`** — security findings (all 19 fixed)

## Development Commands

```bash
# Flutter app
cd vazhi_app
flutter pub get
flutter test                      # Run all 232 tests
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
- **#13**: Convert model to GGUF for mobile (blocked on successful training)

## HuggingFace Resources

- Curated SFT dataset v4.0: `CryptoYogi/vazhi-tamil-sft-v4_0` (3,365 samples, Dataset Factory output)
- DAPT dataset: `CryptoYogi/vazhi-dapt-tamil-v1_0` (32,244 packed 1024-token blocks from Sangraha Tamil)
- DAPT model: `CryptoYogi/qwen3-0.6b-tamil` (reusable Tamil base for SFT — DAPT v1.0 complete)
- DAPT adapter backup: `CryptoYogi/qwen3-0.6b-tamil-lora` (LoRA adapter for recovery)
- Legacy SFT dataset: `CryptoYogi/vazhi-tamil-sft-v3_6` (3,667 samples)
- Legacy dataset: `CryptoYogi/vazhi-tamil-v05` (11,696 items)
- Forked base model: `CryptoYogi/gemma-2b-tamil-base` (historical, corrupted tokenizer)
- Space: `CryptoYogi/vazhi` (Gradio test API)
