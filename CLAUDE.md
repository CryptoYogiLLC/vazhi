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

**Phase:** 3 — Data Population & AI Model Training

**What's done:**
- Flutter app with chat UI, voice I/O (Tamil STT/TTS), hybrid retrieval, model download manager
- **Model selector** (v0.6.0, ADR-011): 3 GGUF variants (Q4_K_M/Q3_K_M/Q2_K) with `ModelVariant` single source of truth, `ModelRegistry`, SharedPreferences persistence, bottom sheet UI
- 6 knowledge packs: Security (468), Government (467), Education (602), Legal (610), Healthcare (460), Culture (400) = 3,007 bilingual training pairs
- Security hardened: encrypted storage, input validation, ReDoS protection, URL allowlist, SHA256 verification
- 247 tests passing, CI/CD via GitHub Actions
- 19 code review issues identified and closed (#22-40)

**What's in progress:**
- AI model training — **Gemma 3 1B-it SFT v7.1 is the deployment candidate** (96% Tamil word score, best ever)
- **SFT v7.0→v7.1→v7.2 completed**: v7.1 (incremental LoRA r=16) achieved best Tamil quality. v7.2 identity-only training failed — Gemma's Google identity is unhackable via LoRA SFT
- **Key insight**: Model architecture > training data. Gemma 3 1B-it with zero fine-tuning outperforms 20 training attempts on Qwen3-0.6B. Google's 2T-token pretraining provides genuine Tamil; identity must be handled via system prompt at inference time, not training
- **Next step**: GGUF conversion of v7.1 (Q4_K_M = 0.60GB) for mobile deployment
- **Identity solution**: System prompt at inference time ("You are VAZHI"); factual corrections via hybrid SQLite retrieval (already built into app architecture)

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
| SFT v4.1 | DAPT v1.1 + LoRA | Failed | Training healthy (loss 0.93→0.79, eval 0.90→0.86) but ALL outputs Tamil gibberish. Root cause: DAPT v1.1 destroyed instruction-following. 16/16 eval "passed" (false positive — metric-only). Model: `CryptoYogi/vazhi-v4_1` |
| SFT v4.2 | Vanilla Qwen3-0.6B + LoRA | Failed | Training healthy (loss 1.29→0.86, eval 0.92, gap -0.003) but ALL outputs transliterated English gibberish in Tamil script. SFT catastrophically forgot Tamil. 16/16 eval false positive (4th consecutive). Model: `CryptoYogi/vazhi-v4_2` |
| Data v5.0 | Dataset rebuild | **Complete** | Two-source Tamil strategy: (1) 848 Sadhguru Tamil Q&A (restructured from 562 scraped articles, 97-98% Tamil), (2) 2,961 vazhi-packs v5 (all 6 domains regenerated in Tamil), (3) 1,800 IndicAlign safety, (4) 168 Thirukkural Q&A (no verbatim), (5) 120 handcrafted, (6) 24 general. Total: 5,921 (85.2% Tamil avg, 41 words avg). Dataset: `CryptoYogi/vazhi-tamil-sft-v5_0` |
| SFT v5.0 | Vanilla Qwen3-0.6B + LoRA | **Success** | First coherent Tamil output. LoRA r=16, 7 modules, LR 1e-5, 1 epoch, 5,328 train. Tamil WORD validation eval. Model: `CryptoYogi/vazhi-v5_0` |
| Data v5.1 | Dataset rebalance | **Complete** | Safety cut from 1,800 (30.6%) to 200 (4.6%) to fix "தீங்கு" mode collapse. Total: ~4,321 samples. Dataset: `CryptoYogi/vazhi-tamil-sft-v5_1` |
| SFT v5.1a | v5.0 + LoRA | **Success** | v5.0 model + v5.1 rebalanced data (1 epoch, ~486 steps). Fixed safety mode collapse. Used as base for v5.3. Model: `CryptoYogi/vazhi-v5_1a` |
| Data v5.2 | Dataset rebuild | **Complete** | Added conversational fundamentals (200) + behavior pack (60). Dropped Sadhguru Q&A v1 (quality audit: 35% duplicates, 41% echo). Safety to ~45 (1%). Total: 3,579. Dataset: `CryptoYogi/vazhi-tamil-sft-v5_2` |
| Data v5.3 | Dataset rebuild | **Complete** | Sadhguru Q&A v2 RESTORED — direct article text as answers (562 pairs, 100% unique, avg 734 words). Total: 4,264 (3,837 train + 427 eval). Dataset: `CryptoYogi/vazhi-tamil-sft-v5_3` |
| SFT v5.3 | v5.1a + LoRA | ⚠️ Partial | 2 epochs (~958 steps), loss 1.09→1.01. 16/16 eval "passed" (94% word) but semantic gibberish with made-up words. English baseline: 13/13 coherent — model reasons in English but can't in Tamil. Proves SFT-only is insufficient. Model: `CryptoYogi/vazhi-v5_3` |
| DAPT v2.0 Data | Dataset prep | **Complete** | Own sources: Sadhguru (562), Thirukkural (1,330), Bharathiar (109), classical lit, chat replay (384). Tamil >=90%. 4,683 blocks × 1024 = 4.8M tokens. Qwen3 tokenizer ~1 token/char (not 3.5). Dataset: `CryptoYogi/vazhi-dapt-tamil-v2_0` |
| DAPT v2.0 | v5.3 + LoRA | ⚠️ Partial | 2 epochs (584 steps), LoRA r=16, LR 1e-5. Loss 1.225→1.004. Tamil char 61%→81% (+20%), word 76%→92% (+16%). Instruction preserved 9/9. **But outputs still fabricated Tamil words** — 4.8M tokens insufficient for language acquisition (v1.1 used 55M). Model: `CryptoYogi/vazhi-v5_3-dapt` |
| DAPT v2.1 Data | Dataset prep | **Complete** | 5-source: Wiki_Chat 70%, Chat replay 11%, Sadhguru 10%, WikiHow 8%, Classical 1%. Tamil >=90%, 38,580 blocks × 1024 = 39.5M tokens (8.2x v2.0). Dataset: `CryptoYogi/vazhi-dapt-tamil-v2_1` |
| DAPT v2.1 | Vanilla Qwen3-0.6B | ✅ Complete | Fresh start, LoRA r=16, LR 1e-5, 2 epochs (2,412 steps), A100-80GB. Loss 1.31→0.83 (37% drop). Tamil word 2%→56% (+54%), instruction 9/9 preserved. Model: `CryptoYogi/vazhi-dapt-v2_1` |
| SFT v6.0 | DAPT v2.1 + LoRA | ❌ Failed | New lineage (DAPT v2.1 base). 1 epoch (479 steps), L4-24GB. Loss 1.37→0.94. 16/16 eval "passed" (78% word) but **semantic gibberish** — same as v5.3. Made-up words, Wikipedia noise, no correct answers. 0.6B model cannot learn Tamil semantics from DAPT+SFT. Model: `CryptoYogi/vazhi-v6_0` |
| Model Comparison v1 | 7 models benchmarked | ✅ Complete | Benchmarked Vanilla Qwen3-0.6B, DAPT v2.1, SFT v6.0, Sarvam-1 (2B), **Gemma 3 1B-it**, Gemma 3n E2B-it (6B raw), Navarasa 2.0 (2B) on 5 Tamil prompts. **Gemma 3 1B-it wins**: real Tamil + relevant answers + structured output + 0.60GB Q4_K_M. Qwen3 models all produce gibberish; Sarvam-1 has Tamil but no instruction-following; Gemma 3n E2B too large (3.6GB GGUF). Notebook: `notebooks/Vazhi_Model_Comparison_v1.ipynb` |
| Data v7.0 | Dataset rebuild | **Complete** | Gemma 3 format (model-agnostic instruction/output). 4,172 samples (3,754 train / 418 eval). Spiritual 39.2%, domain 51.8%, identity 5.5%, safety 0.8%. 61 mission pairs (VAZHI acronym, open source, offline, feedback, sponsorship). Avg 47 words. Dataset: `CryptoYogi/vazhi-tamil-sft-v7_0` |
| SFT v7.0 | Gemma 3 1B-it + LoRA | ⚠️ Partial | 1 epoch (211 steps), LoRA r=8 q_proj+v_proj, LR 1e-5, L4-24GB. Loss 5.35→4.73. Tamil preserved: 93%→92% char, 95%→94% word. 16/16 eval passed. BUT: identity NOT learned (still says Google LLM), factual corrections not taken (capital still Coimbatore). Conservative LoRA too weak to override Gemma's strong pretrained priors. Model: `CryptoYogi/vazhi-v7_0` |
| SFT v7.1 | v7.0 + LoRA r=16 | ✅ **Best model** | Incremental on v7.0 merged. 1 epoch (234 steps), LoRA r=16 q_proj+v_proj, LR 1e-5, A100-80GB. Loss 4.89→4.18 (14.4% drop). Tamil IMPROVED: 89%→95% char, 90%→96% word (best ever). 16/16 eval passed. Identity still says Google, Chennai correct in A/B test. **Deployment candidate** — identity handled via system prompt. Model: `CryptoYogi/vazhi-v7_1` |
| SFT v7.2 | v7.1 + identity-only | ❌ Failed | Identity reinforcement: 90 samples (61 mission + 29 corrections) x 10 epochs (~60 steps), LoRA r=16, LR 1e-5, A100-80GB. Identity NOT learned (0/4 say VAZHI, 2/4 still say Google). Chennai correct (2/2). Tamil preserved (99% word). BUT domain knowledge REGRESSED — model says "சாரி" (sorry) to most domain questions (Thirukkural, ration card, health, legal). Gemma's Google identity is unhackable via LoRA SFT — 2T tokens of pretraining > any fine-tuning. Adapter saved to `CryptoYogi/vazhi-v7_2-lora`, merged NOT uploaded |

**Current strategy — Gemma 3 1B-it pivot (Feb 2026):**
- **Step 1 (DONE):** Qwen3-0.6B exhausted after 20 training attempts (v0.1→v6.0). DAPT+SFT pipeline completed but model can't learn Tamil semantics at 0.6B scale with 151K vocab
- **Step 2 (DONE):** Model Comparison v1 — benchmarked 7 models. Gemma 3 1B-it is the clear winner (real Tamil, relevant answers, fits <1GB)
- **Step 3 (DONE):** SFT v7.0 — 1 epoch, LoRA r=8, Tamil preserved (94% word). Identity/factual corrections NOT learned — conservative LoRA too weak
- **Step 4 (DONE):** SFT v7.1 — incremental r=16 on v7.0, Tamil improved to 96% word (best ever). Identity/factual STILL not overridden — Gemma's 2T-token pretrained priors too deep for LoRA
- **Step 5 (DONE):** SFT v7.2 — identity-only reinforcement (90 samples x 10 epochs). FAILED — identity still Google, domain knowledge regressed. Proves Gemma's identity is unhackable via LoRA SFT
- **Step 6 (NEXT):** GGUF conversion of v7.1 (Q4_K_M = 0.60GB) for mobile deployment — identity handled via system prompt at inference time; factual corrections via hybrid SQLite retrieval
- **Step 7:** Test GGUF output quality (Tamil coherence after quantization)
- **Step 8:** Integrate with Flutter app and test on mobile device

**Why Gemma 3 1B-it instead of continuing Qwen3:**
- Google's 2T-token pretraining on 140+ languages with 262K vocab gives genuine Tamil capability out-of-the-box
- Zero fine-tuning Gemma 3 1B-it produces better Tamil than 20 Qwen3-0.6B training attempts
- Q4_K_M GGUF = 0.60GB (well within <1GB limit)
- Only SFT needed (no DAPT) — dramatically simpler training pipeline

**Data source for SQLite population:** Open data scraping from Tamil Nadu government websites and Tamil databases.

## Key Rules (From 98 Lessons Learned)

### Data Rules
- **NEVER trust data labels** — verify with character-level Tamil % analysis
- **NEVER mix data formats in SFT** — raw text belongs in DAPT, ChatML in SFT. Mixing causes garbage
- **Verify 100% ChatML format** before any SFT run: `is_chatml_formatted()` check on all samples
- **Multi-agent LLM pipelines can silently produce garbage** — always audit output quality at scale (Sadhguru Q&A v1: 35% duplicates, 41% echo, only 38% of source articles used)
- **Use source text directly when possible** — direct article text as answers produces higher quality than LLM restructuring
- **Safety data < 5% for 0.6B models** — 30.6% caused mode collapse, 1% is sufficient for refusal learning

### Training Rules
- **Model architecture > training data for low-resource languages** — Gemma 3 1B-it (262K vocab, 2T-token multilingual pretraining on 140+ langs) produces real Tamil with zero fine-tuning. 20 training attempts on Qwen3-0.6B (151K vocab) never achieved this. When the base model lacks language capacity, no amount of DAPT/SFT can teach it
- **Benchmark before training** — always compare candidate models side-by-side on target language BEFORE committing to training. Model Comparison v1 saved months of wasted effort on Qwen3
- **Pretrained identity is unhackable via LoRA SFT** — Gemma 3's "I am Google" identity survives all LoRA fine-tuning (r=8, r=16, identity-only 90 samples x 10 epochs). 2T tokens of pretraining > any amount of SFT. Solution: handle identity via system prompt at inference time, not training. Similarly, factual corrections are unreliable via SFT — handle via hybrid SQLite retrieval at app level
- **Identity-only training causes domain regression** — v7.2 trained on only 90 identity samples x 10 epochs. While Tamil quality held (99% word), the model started refusing domain questions ("sorry, I don't know") that v7.1 answered well. Even small focused training can overwrite broader capabilities
- **SFT without DAPT is insufficient for low-resource languages on small-vocab models** — SFT teaches task behavior (format, structure) NOT language. Proven on Qwen3-0.6B (v5.0-v5.3). Does NOT apply to models with native multilingual capability (Gemma 3)
- **Don't blame DAPT methodology — blame data quality** — DAPT v1.1 failed because Sangraha corpus was contaminated (English/Tanglish at 70% threshold), not because DAPT is wrong
- **Test GGUF output EARLY** — after 100 steps, not after 2000. Training success != deployment success
- **NEVER modify tokenizer special tokens** — `pad_token = eos_token` causes OrderedVocab holes and corrupts GGUF
- **NEVER ignore tokenizer warnings** — "OrderedVocab contains holes" is FATAL, stop immediately
- **Two-stage training** (Clean DAPT then SFT) is non-negotiable — DAPT teaches Tamil language, SFT teaches Tamil task behavior. Both layers are necessary
- **Preflight fail-fast** — run tiny DAPT+SFT before full training to catch issues early
- **Checkpoint to HF Hub** every epoch (Colab/Kaggle disconnect protection)
- **Suppress conflicting tokens instead of pivoting to base model** — instruct models have language capability; base models with SFT-only produce garbage
- **Iterate on what works** — fix specific issues (token suppression, LR) rather than pivoting to untested approaches
- **Strict ChatML validation** (regex) before training — reject samples missing user/assistant segments
- **Eval must check output QUALITY** — Tamil char %, coherence, not just pattern absence. Automated metrics can false-positive (SFT v4.0: 12/12 "passed" but all gibberish)
- **Eval needs conversational quality checks** — test Tamil fluency, instruction-following, appropriate tone, no hallucinated contacts. NOT factual recall (handled by hybrid SQLite layer). Metric-only eval (Tamil %) misses semantic gibberish
- **Tamil char % is fundamentally broken as eval** — transliterated English in Tamil script ("ஜென்னுஸ் ரெஃப்ஸ்") scores 75-88% Tamil chars but is complete gibberish. Need Tamil WORD validation: dictionary lookup, bigram frequency, or Tamil LM perplexity scoring
- **SFT can catastrophically forget Tamil on small models** — vanilla Qwen3-0.6B produces coherent short Tamil, but LR 5e-5 LoRA SFT (r=8, 2 epochs, 13K samples) destroyed it. Same forgetting pattern as DAPT destroying instruction-following. 0.6B may lack capacity to retain one capability while learning another
- **NEVER merge LoRA into 4-bit model** — save adapter → reload base in fp16 → merge in fp16. 4-bit is for training memory only
- **Clear `generation_config.suppress_tokens` before generating** — models saved with suppress_tokens cause transformers to inject buggy built-in SuppressTokensLogitsProcessor (CPU/CUDA device mismatch). Always clear and use custom logits processor
- **LoRA r=16 on 7 modules is too aggressive for ~1K samples** — overparameterized, overfits to surface patterns. Use r=8 targeting q_proj+v_proj for small datasets
- **Disable gradient checkpointing before eval** — conflicts with use_cache, forces generation without KV cache

### Quantization Rules
- **Q4_K_M is minimum viable** for Tamil — Q3 and below cause visible degradation
- **Smaller models quantize better** — less absolute precision loss
- **Tamil tokenization overhead** (3-4 tokens/char) compounds quantization errors
- **Gemma 3's 262K vocab makes ALL quant levels too large for 4GB Android devices** — Q4_K_M (762 MiB), Q3_K_M (~693 MiB), Q2_K (652 MiB) all OOM-crash during inference. 157 f32 tensors (embeddings, norms) are identical across quant levels. Minimum viable device is 6GB+ RAM
- **Large vocabulary creates a fixed memory floor** — 30% of Gemma 3's 999.89M params are in the 262K embedding matrix (f32, unquantized). Quantization only compresses the other 70%. When choosing deployment models, vocab size matters as much as parameter count for memory-constrained devices
- **mmap is not a silver bullet** — a forward pass touches all 26 layers + embeddings + output head = entire model. Working set ≈ model size. On devices where available RAM barely exceeds model size, Android OOM killer terminates the process during inference

### Data Pipeline Rules (ADR-010)
- **NEVER mix DAPT and SFT data** — physically separated in `data/sources/dapt/` and `data/sources/sft/`
- **vazhi-packs MUST be in training** — flattened copies in `data/sources/sft/vazhi-packs/`
- **IndicAlign diversity >= 30%** of SFT dataset — prevents memorization and improves generalization
- **Thirukkural hard-capped at <= 15%** — verbatim Q&As rejected, only interpretive Q&As allowed
- **Composition targets are hard constraints** — Dataset Factory fails if violated, not aspirational
- **Dataset Factory notebooks** (`notebooks/Vazhi_Dataset_Factory_v4_1*.ipynb`) construct curated datasets on Colab Pro (v4.0 superseded)
- **Legacy scripts raise RuntimeError** — `create_diverse_qa_pack.py` and `create_balanced_sft_dataset.py` are superseded
- **Validate tokenized length, not just character length** — Tamil uses 3-4 tokens/char, so 1500-char samples can exceed `max_seq_length` after tokenization. Dataset Factory must check `len(tokenizer.encode(text))` against training `max_seq_length`
- **3-stage data pipeline** (v4.1+): Retrieve from verified sources (6 IndicAlign subsets + local, 37,947 raw) → Curate with ML (fasttext lang-id, heuristics, exact dedup, perplexity, keyword domain classification → 35,047 curated) → Compose with absolute count targets (14,535 SFT). Each stage uploads to HF for checkpointing
- **Source-aware filtering** — vazhi_packs/handcrafted bypass quality_score, PPL, and tamil_pct filters (hand-curated product voice data)
- **Route safety by subset name** — Toxic_Matrix/HHRLHF_T → safety bucket by subset field, not by narrow toxicity wordlist
- **Checkpoint after expensive GPU steps** — save PPL scores to local JSON before continuing; enables resume on Colab disconnect
- **Qwen3 151K vocab needs VRAM-aware batch sizing** — batch × seq × 151K × dtype = massive logits tensor; use VRAM-based PPL_BATCH_SIZE (8/16/32)
- **max_seq_length=2048 for SFT** — controls training window, not response length. Using 1024 caused 74% domain pack rejection due to system prompt overhead
- **Store raw and curated datasets separately on HF** — enables flexible reuse without re-running expensive retrieval/curation
- **Two-pass curation** — cheap CPU filters first (lang-id, heuristics, dedup), GPU scoring on candidates only
- **PPL is fluency, not quality** — use as weak signal for garbage detection (>200), not as a gate
- **Toxic_Matrix is safety training data** — toxic prompt + safe refusal = route to safety bucket, don't filter

### DAPT Rules
- **DAPT on instruct model needs instruction-preservation** — v1.1 (LR 5e-5, full epoch 55M tokens, LoRA r=16) destroyed instruction-following. Raw text next-token prediction overwrites chat behavior on small models. Fix: lower LR (1-2e-5), smaller token budget (5-15M), and 5-15% chat data replay during DAPT
- **Use Instruct model for DAPT** — v1.0 used Base (per GPT5.2), showed -2% vs vanilla. v1.1 used Instruct, showed +55%. Instruct model has existing multilingual capability; DAPT deepens it
- **NFKC normalize all corpus text** — prevents \ufffd corruption and zero-width char issues
- **Tamil threshold >= 90% for Clean DAPT** — v1.1 used 70% and corpus was still contaminated with English/Tanglish, producing gibberish. 90%+ ensures genuine Tamil prose
- **Separate data prep from training** — data prep (CPU) uploads to HF; training (GPU) loads from HF
- **Token budget, not epochs** — control by target tokens and max_steps, cap at 2 epochs max
- **Verify corpus schema before coding** — inspect actual HF dataset columns and samples (avoid IndicAlign repeat)
- **Pack sequences** — concatenate docs into continuous token stream, split into fixed 1024-token blocks (no padding waste)
- **Filter Sangraha** — Tamil% >= 90% for Clean DAPT v2.0 (was 70% in v1.1 — too low), 200-8000 chars, dedup by MD5, repetition ratio < 0.5
- **5-15% chat data replay during DAPT** — prevents instruction-following catastrophe (DAPT v1.1 used 0% → destroyed chat behavior)
- **30-50M+ tokens needed for language acquisition on 0.6B models** — v2.0 used 4.8M tokens (2 epochs = ~10M exposure) and improved metrics (+16-20%) but model still produces fabricated Tamil words. v1.1 used 55M and showed +55%. There's a critical mass threshold below which the model can't learn real vocabulary
- **Qwen3 tokenizer is ~1 token/char for Tamil** — NOT 3.5 tokens/char as originally estimated. This means the same text corpus produces far fewer tokens than expected. Plan token budgets based on actual tokenizer efficiency, not general estimates
- **Multi-epoch DAPT with interim eval gates** — don't commit to N epochs upfront. Train 1 epoch → eval → decide if another epoch helps. Diminishing returns signal (epoch 1: 14.5% loss drop, epoch 2: 2.0%) indicates when to stop
- **Fresh cosine LR cycle per epoch** — if training multiple epochs via separate Trainer instances, create a new Trainer for each epoch to get a fresh cosine warmup→decay. Resuming with near-zero LR from previous epoch wastes the epoch
- **Host DAPT source files on HuggingFace** — upload source files to an HF dataset repo, download in Colab via `hf_hub_download`. Eliminates manual file uploads and makes reproducible
- **tamil_char_pct denominator must exclude whitespace and digits** — including spaces in denominator artificially deflates Tamil %. Use `sum(1 for c in text if not c.isspace() and not c.isdigit())` as denominator
- **Never run heavy data pipelines locally** — Sangraha filtering, embedding computation, large dataset processing must run on Colab/Kaggle. Local OOM crashes waste time
- **Investigate skipped sources before acquiring new ones** — Wiki_Chat/Wiki_Conv were skipped for OOM, never quality-evaluated. Evaluate existing sources first
- **No device_map for training** — `device_map={"":0}` prevents Trainer's DataParallel wrapping. Use `.to("cuda:0")` instead

### App/Security Rules
- **Input validation is non-negotiable** — sanitize ALL user input at service boundaries
- **Encrypt sensitive local storage** — Hive alone is not secure, use flutter_secure_storage
- **Use allowlists for external URLs** — never trust user-provided URLs for model downloads
- **Verify downloads with SHA256 checksums**
- **Single source of truth for model metadata** — all GGUF model info (URL, filename, size, quality) lives in `ModelVariant` + `ModelRegistry`. Services accept `ModelVariant` via constructor injection. Adding a new model = one registry entry, zero service changes (ADR-011)
- **Persist user preferences with SharedPreferences** — model selection, language preference, etc. Use Riverpod `StateNotifier` + SharedPreferences pattern for reactive persistence

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
│   │   ├── models/model_variant.dart  # ModelVariant + ModelRegistry (single source of truth for GGUF models)
│   │   ├── providers/            # Riverpod state management (incl. model_provider.dart for model selection)
│   │   ├── services/             # Query router, APIs, voice, downloads (accept ModelVariant via constructor)
│   │   └── widgets/              # Accessible UI components (incl. model_selector_sheet.dart)
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
│   ├── Vazhi_SFT_v7_2_Gemma3.ipynb  # SFT v7.2 identity reinforcement — FAILED (Google identity unhackable)
│   ├── Vazhi_SFT_v7_1_Gemma3.ipynb  # SFT v7.1 incremental r=16 — BEST MODEL (96% Tamil word)
│   ├── Vazhi_SFT_v7_0_Gemma3.ipynb  # SFT v7.0 on Gemma 3 1B-it — first Gemma 3 training
│   ├── Vazhi_Model_Comparison_v1.ipynb # 7-model Tamil benchmark — Gemma 3 1B-it wins
│   ├── Vazhi_DAPT_Data_v2_1.ipynb   # DAPT v2.1 data prep (CPU) — 5-source, 39.5M tokens, Tamil>=90%
│   ├── Vazhi_DAPT_v2_1_Tamil.ipynb  # DAPT v2.1 training (GPU) — vanilla Qwen3-0.6B, 2 epochs, Tamil +54%
│   ├── Vazhi_SFT_v6_0_OnDAPT.ipynb # SFT v6.0 on DAPT v2.1 — FAILED (semantic gibberish, 0.6B capacity limit)
│   ├── Vazhi_DAPT_Data_v2_0.ipynb   # DAPT v2.0 data prep (CPU) — own sources, Tamil>=90%, 4.8M tokens
│   ├── Vazhi_DAPT_v2_0_Tamil.ipynb  # DAPT v2.0 training (GPU) — 2 epochs on v5.3, +16-20% Tamil
│   ├── Vazhi_DAPT_Data_v1_1.ipynb   # DAPT v1.1 data prep (CPU) — NFKC, 70% Tamil, 55M tokens
│   ├── Vazhi_DAPT_v1_1_Tamil.ipynb  # DAPT v1.1 training (GPU) — complete, instruct model
│   ├── Vazhi_SFT_v4_2_OnVanilla.ipynb # SFT v4.2 on vanilla Qwen3-0.6B — skip DAPT, baseline test
│   ├── Vazhi_SFT_v4_1_OnDAPT.ipynb # SFT v4.1 on DAPT v1.1 — FAILED (DAPT destroyed instruction-following)
│   ├── Vazhi_SFT_v4_0_OnDAPT.ipynb # SFT v4.0 on DAPT v1.1 — FAILED (gibberish)
│   ├── Vazhi_Eval_v4_0.ipynb        # Standalone eval with think suppression fix
│   ├── Vazhi_DAPT_Data_v1_0.ipynb   # DAPT v1.0 data prep (CPU) — superseded
│   ├── Vazhi_DAPT_v1_0_Tamil.ipynb  # DAPT v1.0 training (GPU) — superseded
│   ├── Vazhi_Dataset_Factory_v4_1.ipynb   # Stage 1: Retrieve (CPU) — 37,947 raw Tamil Q&A
│   ├── Vazhi_Dataset_Factory_v4_1_2.ipynb # Stage 2+3: Curate (GPU) + Compose (CPU) — 35,047 curated → 15,165 SFT
│   ├── Vazhi_Dataset_Factory_v4_1_3.ipynb # Stage 3 re-compose fix (CPU) — safety routing + vazhi_packs bypass
│   ├── Vazhi_Dataset_Factory_v4_0.ipynb # SFT dataset construction (ADR-010) — superseded by v4.1
│   ├── Vazhi_SFT_v3_7_MergeFix.ipynb # Superseded — fp16 merge fix
│   ├── Vazhi_SFT_v3_6_Instruct.ipynb # FAILED — LoRA merge corruption
│   ├── Vazhi_SFT_v3_5_Masked.ipynb # FAILED — Base model SFT-only
│   ├── Vazhi_SFT_v3_3_Clean.ipynb
│   ├── Vazhi_SFT_v3_2_Fixed.ipynb
│   └── [13 more historical notebooks]
├── scripts/                      # Data processing, validation, rebalancing
│   ├── create_sadhguru_qa_v2.py      # Sadhguru direct article-to-QA conversion (replaces broken multi-agent v1)
│   ├── scrape_ilearntamil.py         # Scrape 32 Tamil conversations (668 turns, 64 SFT pairs) for future SFT
│   ├── assemble_dataset_v5_3.py      # v5.3 dataset assembly (Sadhguru Q&A v2 restored)
├── schemas/                      # JSON schemas for training data validation
├── vazhi-packs/                  # 6 domain-specific knowledge packs (app references these)
├── huggingface-space/            # Gradio test API (submodule)
└── docs/
    ├── SPRINT_PLAN_REVISED.md    # Roadmap and phase tracking
    ├── LESSONS_LEARNED.md        # 91 lessons from training journey
    ├── CODE_REVIEW_CONSENSUS_REPORT.md
    ├── DATA_REGENERATION_PLAN.md # Historical — v0.2 data crisis
    └── adr/                      # 10 Architecture Decision Records
```

## Key Documents (Read Order for New Agents)

1. **This file** — start here
2. **`vazhi_app/APP_CHANGELOG.md`** — app feature history, architecture decisions, and lessons learned
3. **`docs/adr/011-model-selector-architecture.md`** — model selector pattern (ModelVariant + ModelRegistry + SharedPreferences)
4. **`docs/adr/010-data-pipeline-architecture.md`** — data pipeline design, composition targets, anti-memorization rules
5. **`models/TRAINING_LOG.md`** — detailed training history, decisions, and failure analysis
6. **`docs/SPRINT_PLAN_REVISED.md`** — roadmap, phases, what's done vs pending
7. **`docs/LESSONS_LEARNED.md`** — 105 hard-won lessons, ideal training pipeline
8. **`docs/CODE_REVIEW_CONSENSUS_REPORT.md`** — security findings (all 19 fixed)

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

- Raw Tamil Q&A v1: `CryptoYogi/vazhi-raw-tamil-qa-v1` (37,947 raw pairs from 6 IndicAlign subsets + local)
- Curated Tamil Q&A v1: `CryptoYogi/vazhi-curated-tamil-qa-v1` (35,047 ML-curated with quality scores, PPL, domain labels)
- **SFT dataset v5.0: `CryptoYogi/vazhi-tamil-sft-v5_0`** (5,921 samples: 5,328 train / 593 eval, two-source Tamil strategy — Sadhguru Q&A + vazhi-packs v5 + safety + thirukkural Q&A + handcrafted + general)
- SFT dataset v5.1: `CryptoYogi/vazhi-tamil-sft-v5_1` (safety rebalanced, ~4,321 samples)
- SFT dataset v5.2: `CryptoYogi/vazhi-tamil-sft-v5_2` (3,579 samples, conversational fundamentals added)
- **SFT dataset v7.0: `CryptoYogi/vazhi-tamil-sft-v7_0`** (4,172 samples: 3,754 train / 418 eval, rebalanced for Gemma 3 — spiritual 39.2%, domain 51.8%, identity 5.5%, safety 0.8%, 61 mission pairs, avg 47 words)
- SFT dataset v5.3: `CryptoYogi/vazhi-tamil-sft-v5_3` (4,264 samples: 3,837 train / 427 eval, Sadhguru Q&A v2 restored)
- **SFT v7.1 model: `CryptoYogi/vazhi-v7_1`** (DEPLOYMENT CANDIDATE — v7.0 + LoRA r=16, Tamil 96% word, best ever, ready for GGUF)
- SFT v7.1 adapter: `CryptoYogi/vazhi-v7_1-lora`
- SFT v7.2 adapter: `CryptoYogi/vazhi-v7_2-lora` (identity-only, FAILED — merged NOT uploaded)
- SFT v7.0 model: `CryptoYogi/vazhi-v7_0` (Gemma 3 1B-it + LoRA r=8, Tamil 94% word, identity not learned)
- SFT v7.0 adapter: `CryptoYogi/vazhi-v7_0-lora`
- SFT v5.0 model: `CryptoYogi/vazhi-v5_0` (first successful Tamil model)
- SFT v5.1a model: `CryptoYogi/vazhi-v5_1a` (safety-rebalanced, mode collapse fixed)
- SFT v5.3 model: `CryptoYogi/vazhi-v5_3` (semantic gibberish — SFT-only insufficient)
- **DAPT v2.1 dataset: `CryptoYogi/vazhi-dapt-tamil-v2_1`** (38,580 blocks × 1024 = 39.5M tokens, 5-source, Tamil 97.6%)
- DAPT v2.1 model: `CryptoYogi/vazhi-dapt-v2_1` (vanilla Qwen3-0.6B + 39.5M tokens DAPT, Tamil word 2%→56%)
- DAPT v2.1 adapter: `CryptoYogi/vazhi-dapt-v2_1-lora`
- SFT v6.0 model (FAILED): `CryptoYogi/vazhi-v6_0` (DAPT v2.1 + SFT, semantic gibberish — 0.6B capacity limit)
- SFT v6.0 adapter: `CryptoYogi/vazhi-v6_0-lora`
- DAPT v2.0 sources: `CryptoYogi/vazhi-dapt-sources-v2_0` (8 source files: Sadhguru articles, classical lit, chat replay)
- DAPT v2.0 dataset: `CryptoYogi/vazhi-dapt-tamil-v2_0` (4,683 blocks × 1024 = 4.8M tokens, Tamil >=90%)
- DAPT v2.0 model: `CryptoYogi/vazhi-v5_3-dapt` (v5.3 + 2 epochs DAPT, Tamil +16-20% but still fabricated words)
- DAPT v2.0 adapter: `CryptoYogi/vazhi-v5_3-dapt-lora` (LoRA adapter backup)
- SFT dataset v4.1 (superseded): `CryptoYogi/vazhi-tamil-sft-v4_1` (14,535 samples: 13,083 train / 1,452 eval, 3-stage pipeline v4.1.3 — 75.8% garbage)
- SFT v4.2 model (FAILED): `CryptoYogi/vazhi-v4_2` (transliterated English gibberish — SFT forgot Tamil)
- SFT v4.2 adapter: `CryptoYogi/vazhi-v4_2-lora`
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
