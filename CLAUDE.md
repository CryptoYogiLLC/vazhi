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
- AI model training — 9 failed attempts across 4 base models (see Training History below)
- Latest approach: v3.4 using Qwen3-0.6B-**Base** (not instruct) — not yet validated on Kaggle

**What's pending (not blocked):**
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
| v3.4 | Qwen3-0.6B-**Base** | Pending | New hypothesis: use base model to avoid `<think>` conflict, LR 2e-5 |

**Fallback if v3.4 fails:**
- Primary: Try two-stage DAPT+SFT (domain-adaptive pretraining first, then SFT)
- Secondary: Sarvam-1 IQ3_M (1.17GB, proven Tamil, exceeds <1GB hard limit)
- Last resort: Gemma-2B Tamil Q4_K_M (1.63GB, works but far exceeds size target)

**Data source for SQLite population:** Open data scraping from Tamil Nadu government websites and Tamil databases.

## Key Rules (From 39 Lessons Learned)

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
- **Use base models for SFT** when the instruct model's native format conflicts with your chat template

### Quantization Rules
- **Q4_K_M is minimum viable** for Tamil — Q3 and below cause visible degradation
- **Smaller models quantize better** — less absolute precision loss
- **Tamil tokenization overhead** (3-4 tokens/char) compounds quantization errors

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
│   └── test/                     # 228 tests
├── data/                         # Training datasets
│   ├── tamil_foundation/         # 19 JSON files, 11K+ samples
│   └── v04/                      # Regenerated training data
├── models/
│   └── TRAINING_LOG.md           # Detailed log of all 9+ training attempts
├── notebooks/                    # Kaggle/Colab training notebooks
│   ├── Vazhi_SFT_v3_4_Base.ipynb # LATEST — Qwen3-0.6B-Base approach
│   ├── Vazhi_SFT_v3_3_Clean.ipynb
│   ├── Vazhi_SFT_v3_2_Fixed.ipynb
│   └── [13 more historical notebooks]
├── scripts/                      # Data processing, validation, rebalancing
├── schemas/                      # JSON schemas for training data validation
├── vazhi-packs/                  # 6 domain-specific knowledge packs
├── huggingface-space/            # Gradio test API (submodule)
└── docs/
    ├── SPRINT_PLAN_REVISED.md    # Roadmap and phase tracking
    ├── LESSONS_LEARNED.md        # 35+ lessons from training journey
    ├── CODE_REVIEW_CONSENSUS_REPORT.md
    ├── DATA_REGENERATION_PLAN.md # Historical — v0.2 data crisis
    └── adr/                      # 9 Architecture Decision Records
```

## Key Documents (Read Order for New Agents)

1. **This file** — start here
2. **`vazhi_app/APP_CHANGELOG.md`** — app feature history, architecture decisions, and lessons learned
3. **`models/TRAINING_LOG.md`** — detailed training history, decisions, and failure analysis
4. **`docs/SPRINT_PLAN_REVISED.md`** — roadmap, phases, what's done vs pending
5. **`docs/LESSONS_LEARNED.md`** — 39 hard-won lessons, ideal training pipeline
6. **`docs/CODE_REVIEW_CONSENSUS_REPORT.md`** — security findings (all 19 fixed)

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

- Dataset: `CryptoYogi/vazhi-tamil-v05` (11,696 items)
- Balanced SFT dataset: `CryptoYogi/vazhi-tamil-sft-v3_3`
- Forked base model: `CryptoYogi/gemma-2b-tamil-base` (historical, corrupted tokenizer)
- Space: `CryptoYogi/vazhi` (Gradio test API)
