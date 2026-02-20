# VAZHI HuggingFace Resources — Full Catalog

> Relocated from CLAUDE.md during optimization (Feb 2026). Kept in sync manually.

## Active Resources (also listed in CLAUDE.md)

- **SFT v7.1 model: `CryptoYogi/vazhi-v7_1`** (DEPLOYMENT CANDIDATE — v7.0 + LoRA r=16, Tamil 96% word, best ever, ready for GGUF)
- **SFT dataset v7.0: `CryptoYogi/vazhi-tamil-sft-v7_0`** (4,172 samples: 3,754 train / 418 eval, rebalanced for Gemma 3 — spiritual 39.2%, domain 51.8%, identity 5.5%, safety 0.8%, 61 mission pairs, avg 47 words)
- **DAPT v2.1 dataset: `CryptoYogi/vazhi-dapt-tamil-v2_1`** (38,580 blocks × 1024 = 39.5M tokens, 5-source, Tamil 97.6%)
- **External — 270M GGUF (bartowski):** `bartowski/google_gemma-3-270m-it-GGUF` (Q6_K_L = 283 MB for 4GB tier, Q4_K_M = 253 MB, IQ4_NL = 242 MB)
- **External — QAT 1B GGUF (bartowski):** `bartowski/google_gemma-3-1b-it-qat-GGUF` (QAT Q2_K = 690 MB for 6GB+ tier, Q4_K_M = 806 MB, Q3_K_M = 722 MB, IQ3_M = 697 MB)
- Space: `CryptoYogi/vazhi` (Gradio test API)

## Gemma 3 Era (v7.x — Current)

### Models
- SFT v7.1 model: `CryptoYogi/vazhi-v7_1` (DEPLOYMENT CANDIDATE — v7.0 + LoRA r=16, Tamil 96% word, best ever)
- SFT v7.1 adapter: `CryptoYogi/vazhi-v7_1-lora`
- SFT v7.2 adapter: `CryptoYogi/vazhi-v7_2-lora` (identity-only, FAILED — merged NOT uploaded)
- SFT v7.0 model: `CryptoYogi/vazhi-v7_0` (Gemma 3 1B-it + LoRA r=8, Tamil 94% word, identity not learned)
- SFT v7.0 adapter: `CryptoYogi/vazhi-v7_0-lora`

### Datasets
- SFT dataset v7.0: `CryptoYogi/vazhi-tamil-sft-v7_0` (4,172 samples: 3,754 train / 418 eval)

## Qwen3 Era (v5.x–v6.x — Superseded)

### Models
- SFT v5.0 model: `CryptoYogi/vazhi-v5_0` (first successful Tamil model)
- SFT v5.1a model: `CryptoYogi/vazhi-v5_1a` (safety-rebalanced, mode collapse fixed)
- SFT v5.3 model: `CryptoYogi/vazhi-v5_3` (semantic gibberish — SFT-only insufficient)
- DAPT v2.1 model: `CryptoYogi/vazhi-dapt-v2_1` (vanilla Qwen3-0.6B + 39.5M tokens DAPT, Tamil word 2%→56%)
- DAPT v2.1 adapter: `CryptoYogi/vazhi-dapt-v2_1-lora`
- SFT v6.0 model (FAILED): `CryptoYogi/vazhi-v6_0` (DAPT v2.1 + SFT, semantic gibberish — 0.6B capacity limit)
- SFT v6.0 adapter: `CryptoYogi/vazhi-v6_0-lora`
- DAPT v2.0 model: `CryptoYogi/vazhi-v5_3-dapt` (v5.3 + 2 epochs DAPT, Tamil +16-20% but still fabricated words)
- DAPT v2.0 adapter: `CryptoYogi/vazhi-v5_3-dapt-lora` (LoRA adapter backup)
- SFT v4.2 model (FAILED): `CryptoYogi/vazhi-v4_2` (transliterated English gibberish — SFT forgot Tamil)
- SFT v4.2 adapter: `CryptoYogi/vazhi-v4_2-lora`
- SFT v4.0 model (FAILED): `CryptoYogi/vazhi-v4_0` (gibberish output — LoRA overfit)
- SFT v4.0 adapter: `CryptoYogi/vazhi-v4_0-lora`

### Datasets
- SFT dataset v5.0: `CryptoYogi/vazhi-tamil-sft-v5_0` (5,921 samples: 5,328 train / 593 eval)
- SFT dataset v5.1: `CryptoYogi/vazhi-tamil-sft-v5_1` (safety rebalanced, ~4,321 samples)
- SFT dataset v5.2: `CryptoYogi/vazhi-tamil-sft-v5_2` (3,579 samples, conversational fundamentals added)
- SFT dataset v5.3: `CryptoYogi/vazhi-tamil-sft-v5_3` (4,264 samples: 3,837 train / 427 eval, Sadhguru Q&A v2 restored)
- DAPT v2.1 dataset: `CryptoYogi/vazhi-dapt-tamil-v2_1` (38,580 blocks × 1024 = 39.5M tokens, 5-source, Tamil 97.6%)
- DAPT v2.0 sources: `CryptoYogi/vazhi-dapt-sources-v2_0` (8 source files: Sadhguru articles, classical lit, chat replay)
- DAPT v2.0 dataset: `CryptoYogi/vazhi-dapt-tamil-v2_0` (4,683 blocks × 1024 = 4.8M tokens, Tamil >=90%)
- Raw Tamil Q&A v1: `CryptoYogi/vazhi-raw-tamil-qa-v1` (37,947 raw pairs from 6 IndicAlign subsets + local)
- Curated Tamil Q&A v1: `CryptoYogi/vazhi-curated-tamil-qa-v1` (35,047 ML-curated with quality scores, PPL, domain labels)
- Curated SFT dataset v4.0 (superseded): `CryptoYogi/vazhi-tamil-sft-v4_0` (1,514 samples: 1,365 train / 149 eval)
- SFT dataset v4.1 (superseded): `CryptoYogi/vazhi-tamil-sft-v4_1` (14,535 samples: 13,083 train / 1,452 eval, 75.8% garbage)

## Legacy (Pre-Qwen3)

- DAPT v1.1 dataset: `CryptoYogi/vazhi-dapt-tamil-v1_1` (55M tokens, NFKC-cleaned, 70% Tamil)
- DAPT v1.1 model: `CryptoYogi/qwen3-0.6b-tamil-v1_1` (Tamil instruct base for SFT — reusable)
- DAPT v1.1 adapter: `CryptoYogi/qwen3-0.6b-tamil-v1_1-lora` (LoRA adapter for recovery)
- DAPT v1.0 dataset: `CryptoYogi/vazhi-dapt-tamil-v1_0` (16M tokens, superseded)
- DAPT v1.0 model: `CryptoYogi/qwen3-0.6b-tamil` (Base model, superseded)
- DAPT v1.0 adapter: `CryptoYogi/qwen3-0.6b-tamil-lora`
- Legacy SFT dataset: `CryptoYogi/vazhi-tamil-sft-v3_6` (3,667 samples)
- Legacy dataset: `CryptoYogi/vazhi-tamil-v05` (11,696 items)
- Forked base model: `CryptoYogi/gemma-2b-tamil-base` (historical, corrupted tokenizer)
