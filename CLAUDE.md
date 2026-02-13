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
- AI model training — 13 failed SFT attempts across 5 base models, **DAPT v1.0 + v1.1 both succeeded**
- DAPT v1.1 complete: `CryptoYogi/qwen3-0.6b-tamil-v1_1` — Tamil instruct model (55M tokens, PPL 2.6, +55% Tamil vs vanilla)
- Next step: SFT v4.1 on DAPT'd instruct model — 3-stage pipeline (retrieve ~520K, curate with ML, compose ~10K) with max_seq_length=2048

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
| DAPT v1.0 | Qwen3-0.6B-Base | Superseded | DAPT 16M tokens Sangraha, 375 steps. Comparison showed -2% vs vanilla Base — DAPT didn't help |
| DAPT v1.1 | Qwen3-0.6B (instruct) | **Success** | DAPT 55M tokens NFKC Sangraha, 1645 steps, PPL 2.6, 7/8 eval, +55% Tamil vs vanilla. Model: `CryptoYogi/qwen3-0.6b-tamil-v1_1` |
| SFT v4.0 | DAPT v1.1 + LoRA | Failed | Training healthy (loss 1.43→1.03) but content is Tamil gibberish. LoRA r=16 on 7 modules overfit 1,365 samples. DAPT > SFT > Vanilla. Model: `CryptoYogi/vazhi-v4_0` |

**Current strategy (DAPT-first):**
- **Step 1:** Data prep — filter Sangraha Tamil corpus, NFKC normalize, pack into 55M tokens (`Vazhi_DAPT_Data_v1_1.ipynb`, CPU) ✅ DONE
- **Step 2:** DAPT — train Qwen3-0.6B (instruct) on 55M tokens → `CryptoYogi/qwen3-0.6b-tamil-v1_1` (`Vazhi_DAPT_v1_1_Tamil.ipynb`, GPU) ✅ DONE
- **Step 2.5:** Dataset Factory v4.1 — 3-stage pipeline (Retrieve→Curate→Compose), ~10K SFT samples from ~520K raw (`Vazhi_Dataset_Factory_v4_1.ipynb`, GPU)
- **Step 3:** SFT — fine-tune DAPT'd instruct model on v4.1 dataset with max_seq_length=2048, conservative LoRA (r=8, q_proj+v_proj, 2 epochs)
- **Fallback:** Sarvam-1 IQ3_M (1.17GB, proven Tamil, exceeds <1GB hard limit)

**Data source for SQLite population:** Open data scraping from Tamil Nadu government websites and Tamil databases.

## Key Rules (From 56 Lessons Learned)

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
- **Eval must check output QUALITY** — Tamil char %, coherence, not just pattern absence. Automated metrics can false-positive (SFT v4.0: 12/12 "passed" but all gibberish)
- **Eval needs factual accuracy checks** — e.g., "Capital of TN" must contain "Chennai/சென்னை". Metric-only eval misses semantic gibberish
- **NEVER merge LoRA into 4-bit model** — save adapter → reload base in fp16 → merge in fp16. 4-bit is for training memory only
- **Clear `generation_config.suppress_tokens` before generating** — models saved with suppress_tokens cause transformers to inject buggy built-in SuppressTokensLogitsProcessor (CPU/CUDA device mismatch). Always clear and use custom logits processor
- **LoRA r=16 on 7 modules is too aggressive for ~1K samples** — overparameterized, overfits to surface patterns. Use r=8 targeting q_proj+v_proj for small datasets
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
- **Dataset Factory notebook** (`notebooks/Vazhi_Dataset_Factory_v4_1.ipynb`) constructs curated datasets on Kaggle (v4.0 superseded)
- **Legacy scripts raise RuntimeError** — `create_diverse_qa_pack.py` and `create_balanced_sft_dataset.py` are superseded
- **Validate tokenized length, not just character length** — Tamil uses 3-4 tokens/char, so 1500-char samples can exceed `max_seq_length` after tokenization. Dataset Factory must check `len(tokenizer.encode(text))` against training `max_seq_length`
- **3-stage data pipeline** (v4.1+): Retrieve broadly (all sources, no caps) → Curate with ML (fasttext lang-id, heuristics, dedup, perplexity, semantic clustering) → Compose with absolute count targets. Each stage uploads to HF for checkpointing
- **max_seq_length=2048 for SFT** — controls training window, not response length. Using 1024 caused 74% domain pack rejection due to system prompt overhead
- **Store raw and curated datasets separately on HF** — enables flexible reuse without re-running expensive retrieval/curation
- **Two-pass curation** — cheap CPU filters first (lang-id, heuristics, dedup), GPU scoring on candidates only
- **PPL is fluency, not quality** — use as weak signal for garbage detection (>200), not as a gate
- **Toxic_Matrix is safety training data** — toxic prompt + safe refusal = route to safety bucket, don't filter

### DAPT Rules
- **Use Instruct model for DAPT** — v1.0 used Base (per GPT5.2), showed -2% vs vanilla. v1.1 used Instruct, showed +55%. Instruct model has existing multilingual capability; DAPT deepens it
- **NFKC normalize all corpus text** — prevents \ufffd corruption and zero-width char issues
- **Tamil threshold >= 70%** — v1.0 used 50% and got noisy mixed-language docs; 70% is cleaner
- **Separate data prep from training** — data prep (CPU) uploads to HF; training (GPU) loads from HF
- **Token budget, not epochs** — control by target tokens and max_steps, cap at 2 epochs max
- **Verify corpus schema before coding** — inspect actual HF dataset columns and samples (avoid IndicAlign repeat)
- **Pack sequences** — concatenate docs into continuous token stream, split into fixed 1024-token blocks (no padding waste)
- **Filter Sangraha** — Tamil% >= 70%, 200-8000 chars, dedup by MD5, repetition ratio < 0.5
- **No device_map for training** — `device_map={"":0}` prevents Trainer's DataParallel wrapping. Use `.to("cuda:0")` instead

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
│   ├── Vazhi_DAPT_Data_v1_1.ipynb   # DAPT v1.1 data prep (CPU) — NFKC, 70% Tamil, 55M tokens
│   ├── Vazhi_DAPT_v1_1_Tamil.ipynb  # DAPT v1.1 training (GPU) — complete, instruct model
│   ├── Vazhi_SFT_v4_0_OnDAPT.ipynb # SFT v4.0 on DAPT v1.1 — FAILED (gibberish)
│   ├── Vazhi_Eval_v4_0.ipynb        # Standalone eval with think suppression fix
│   ├── Vazhi_DAPT_Data_v1_0.ipynb   # DAPT v1.0 data prep (CPU) — superseded
│   ├── Vazhi_DAPT_v1_0_Tamil.ipynb  # DAPT v1.0 training (GPU) — superseded
│   ├── Vazhi_Dataset_Factory_v4_1.ipynb # 3-stage SFT dataset pipeline (Retrieve→Curate→Compose)
│   ├── Vazhi_Dataset_Factory_v4_0.ipynb # SFT dataset construction (ADR-010) — superseded by v4.1
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
    ├── LESSONS_LEARNED.md        # 56 lessons from training journey
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
6. **`docs/LESSONS_LEARNED.md`** — 56 hard-won lessons, ideal training pipeline
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

- Raw Tamil Q&A v1: `CryptoYogi/vazhi-raw-tamil-qa-v1` (~520K+ raw pairs from all sources)
- Curated Tamil Q&A v1: `CryptoYogi/vazhi-curated-tamil-qa-v1` (ML-curated with quality scores)
- SFT dataset v4.1: `CryptoYogi/vazhi-tamil-sft-v4_1` (~10K samples, 3-stage pipeline)
- SFT v4.0 model (FAILED): `CryptoYogi/vazhi-v4_0` (gibberish output — LoRA overfit)
- SFT v4.0 adapter: `CryptoYogi/vazhi-v4_0-lora`
- Curated SFT dataset v4.0 (superseded): `CryptoYogi/vazhi-tamil-sft-v4_0` (1,514 samples: 1,365 train / 149 eval)
- DAPT v1.1 dataset: `CryptoYogi/vazhi-dapt-tamil-v1_1` (55M tokens, NFKC-cleaned, 70% Tamil)
- DAPT v1.1 model: `CryptoYogi/qwen3-0.6b-tamil-v1_1` (Tamil instruct base for SFT — reusable)
- DAPT v1.1 adapter: `CryptoYogi/qwen3-0.6b-tamil-v1_1-lora` (LoRA adapter for recovery)
- DAPT v1.0 dataset: `CryptoYogi/vazhi-dapt-tamil-v1_0` (16M tokens, superseded)
- DAPT v1.0 model: `CryptoYogi/qwen3-0.6b-tamil` (Base model, superseded)
- DAPT v1.0 adapter: `CryptoYogi/qwen3-0.6b-tamil-lora`
- Legacy SFT dataset: `CryptoYogi/vazhi-tamil-sft-v3_6` (3,667 samples)
- Legacy dataset: `CryptoYogi/vazhi-tamil-v05` (11,696 items)
- Forked base model: `CryptoYogi/gemma-2b-tamil-base` (historical, corrupted tokenizer)
- Space: `CryptoYogi/vazhi` (Gradio test API)
