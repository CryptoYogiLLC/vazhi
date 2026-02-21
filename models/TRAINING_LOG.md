# VAZHI Model Training Log

This log captures all training runs, decisions, and rationale to prevent repeating mistakes.

---

## Version History

| Version | Date | Status | Key Changes |
|---------|------|--------|-------------|
| v0.1 | 2026-02-05 | ❌ Failed | Initial training, Culture pack hallucination |
| v0.2 | 2026-02-06 | ❌ Failed | Added culture_v2 data, still hallucinating |
| v0.3 | 2026-02-06 | ⏸️ Skipped | Heavy augmentation planned but root cause found |
| v0.4 | 2026-02-06 | ❌ Failed | GGUF quantization produced gibberish output |
| v0.5 | 2026-02-07 | ❌ Failed | SLM approach with Qwen2.5-0.5B - LoRA corrupted model |
| v0.6 | 2026-02-07 | ❌ Failed | Sarvam-2B + IndicAlign Anudesh - 4-bit training corrupted model |
| v0.7 | 2026-02-08 | ❌ Failed | Gemma-2B Tamil - Training worked but GGUF conversion failed (tokenizer holes) |
| v0.8 | 2026-02-09 | ⏸️ Superseded | Qwen3-0.6B - Two-stage Micro-DAPT + SFT on Kaggle (superseded by v3.x series) |
| v3.1 | 2026-02-10 | ❌ Failed | Qwen3-0.6B SFT - Mixed data formats caused "systemsystemsystem..." output |
| v3.2 | 2026-02-10 | ❌ Failed | Qwen3-0.6B SFT - ChatML-only fix, fp16 on T4, but fp16 training issues |
| v3.3 | 2026-02-10 | ❌ Failed | Qwen3-0.6B (instruct) - `<think>` tokens conflicted with ChatML, LR too aggressive |
| v3.4 | 2026-02-11 | ⏸️ Superseded | Qwen3-0.6B-**Base** (not instruct) - LR 2e-5, LoRA r=32, 3 epochs. Never run — missing completion-only masking |
| v3.5 | 2026-02-11 | ❌ Failed | Qwen3-0.6B-Base + DataCollatorForCompletionOnlyLM — completion-only masking worked but SFT-only on base model without DAPT produced code/HTML garbage instead of Tamil |
| v3.6 | 2026-02-12 | ❌ Failed | Return to Qwen3-0.6B instruct — dataset + masking + training all correct, but LoRA merge into 4-bit model corrupted weights. Output: random punctuation/operators (0% Tamil) |
| v3.7 | 2026-02-12 | ⏸️ Superseded | Same as v3.6 but fix LoRA merge: save adapter → reload base in fp16 → merge in fp16. Superseded by v3.8 (v4.0 dataset) |
| v3.8 | 2026-02-12 | ❌ Failed | Dataset Factory v4.0 (3,365 samples) + fp16 merge fix — SFT-only on instruct model. 0/12 eval passed, avg Tamil 52%, `<think>` leaking, gibberish content. Root cause: no DAPT stage |
| DAPT v1.0 | 2026-02-12 | ✅ Complete | Two-notebook pipeline: data prep (CPU) + DAPT training (GPU). Qwen3-0.6B-Base + 16M tokens Sangraha Tamil (375 steps). Val loss 1.045→1.016, eval 8/8 passed (66% Tamil, 97% unique). Model: `CryptoYogi/qwen3-0.6b-tamil` |
| DAPT v1.1 | 2026-02-13 | ✅ Complete | Instruct model (not Base), 55M tokens NFKC-cleaned, dual T4 DataParallel. Train loss 1.427→0.964 (-32.5%), PPL 2.6. DAPT wins 7/8 vs vanilla (+55% char, +63% word). Model: `CryptoYogi/qwen3-0.6b-tamil-v1_1` |
| SFT v4.0 | 2026-02-13 | ❌ Failed | DAPT v1.1 + SFT (1,365 train, LoRA r=16, 3 epochs, LR 2e-5). Train loss 1.43→1.03, eval loss 1.33→1.23. `<think>` suppression broken (transformers bug). Content is Tamil gibberish — wrong facts, hallucinated data. DAPT > SFT > Vanilla by Tamil%. Model: `CryptoYogi/vazhi-v4_0` |
| SFT v4.1 | 2026-02-13 | ❌ Failed | DAPT v1.1 + SFT (13,083 train, LoRA r=8 q_proj+v_proj, LR 5e-5, 2 epochs). Train loss 0.93→0.79, eval loss 0.90→0.86. 16/16 eval "passed" but ALL outputs Tamil gibberish (false positive). Root cause: DAPT v1.1 destroyed instruction-following. Vanilla Qwen3-0.6B follows instructions; DAPT model produces gibberish/echoes/loops. Model: `CryptoYogi/vazhi-v4_1` |
| SFT v4.2 | 2026-02-13 | ❌ Failed | Vanilla Qwen3-0.6B + SFT (13,083 train, LoRA r=8 q_proj+v_proj, LR 5e-5, 2 epochs). Train loss 1.29→0.86, eval loss 0.92, gap -0.003. 16/16 eval "passed" — 4th consecutive false positive. ALL outputs transliterated English gibberish in Tamil script (e.g., "ஜென்னுஸ் ரெஃப்ஸ் ஹோர்ட் பிளாஸ்ட்" = "Genus Refs Hort Blast"). SFT catastrophically forgot Tamil. Model: `CryptoYogi/vazhi-v4_2` |
| Data v4.1.3 | 2026-02-13 | ✅ Complete | 3-stage pipeline: Retrieve 37,947 (6 IndicAlign subsets + local) → Curate 35,047 (fasttext, dedup, PPL, keyword domain classifier) → Compose 14,535 SFT (13,083 train / 1,452 eval). v4.1.3 fixed safety routing (subset name, not wordlist: 105→2,000) and vazhi_packs bypass (2,429→2,956). max_seq_length=2048. Colab Pro L4 GPU. Notebooks: `v4_1.ipynb` (Stage 1 CPU), `v4_1_2.ipynb` (Stage 2+3 GPU), `v4_1_3.ipynb` (Stage 3 re-compose fix). Datasets: `vazhi-raw-tamil-qa-v1`, `vazhi-curated-tamil-qa-v1`, `vazhi-tamil-sft-v4_1` |
| Data v5.0 | 2026-02-14 | ✅ Complete | Full dataset rebuild — two-source Tamil data strategy. (1) Scraped 596 Sadhguru Tamil articles from isha.sadhguru.org/ta/, filtered to 562, CC agents restructured into 848 Tamil Q&A pairs (85.2% Tamil avg). (2) Regenerated all 6 vazhi-packs with Tamil responses: healthcare/security/culture via CC agents, legal/education/govt via template-based generator. (3) Extracted safety (1,800), thirukkural Q&A (168, no verbatim), handcrafted (120), general (24) from v4.1 HF dataset. Final: 5,921 samples (5,328 train / 593 eval), 85.2% Tamil avg, 41 words avg. Dataset: `CryptoYogi/vazhi-tamil-sft-v5_0` |
| SFT v5.0 | 2026-02-14 | ✅ Complete | Vanilla Qwen3-0.6B + LoRA (r=16, 7 modules, LR 1e-5, 1 epoch). Dataset v5.0 (5,328 train). Tamil WORD validation eval (not char %). Training healthy. First model with real Tamil output. Model: `CryptoYogi/vazhi-v5_0` |
| Data v5.1 | 2026-02-14 | ✅ Complete | Safety rebalanced — cut from 1,800 (30.6%) to 200 (4.6%) to fix safety mode collapse ("தீங்கு" in every response). Sadhguru Q&A audit found critical quality issues but kept for v5.1. Total: 4,321 samples. Dataset: `CryptoYogi/vazhi-tamil-sft-v5_1` |
| SFT v5.1a | 2026-02-14 | ✅ Complete | v5.0 model + v5.1 dataset (1 epoch, ~486 steps). Fixed safety mode collapse. Used as base for v5.3. Model: `CryptoYogi/vazhi-v5_1a` |
| Data v5.2 | 2026-02-14 | ✅ Complete | Added conversational fundamentals (200 items: greetings, identity, chitchat, colloquial TN Tamil) + VAZHI behavior pack (60 items). Dropped Sadhguru Q&A (quality audit failed). Safety further cut to ~45 (1%). Total: 3,579 samples. Dataset: `CryptoYogi/vazhi-tamil-sft-v5_2` |
| Data v5.3 | 2026-02-14 | ✅ Complete | Sadhguru Q&A v2 RESTORED — direct article text as answers (not LLM-generated). v1 had 35% duplicates, 41% Q-A echo, 20% identical clichés. v2: 562 pairs, 100% unique, avg 734 words. Script: `create_sadhguru_qa_v2.py`. Total: 4,264 samples (3,837 train + 427 eval). Dataset: `CryptoYogi/vazhi-tamil-sft-v5_3` |
| SFT v5.3 | 2026-02-15 | ⚠️ Partial | v5.1a model + v5.3 dataset (2 epochs, ~958 steps). Training healthy (loss 1.09→1.01, eval 1.08→1.03). 16/16 eval "passed" (94% Tamil word) but outputs are **semantic gibberish** with made-up words ("ஏற்றுக்ஷோரம்", "முக்ளிஞ்ணுக்ஸ்"). English baseline: 13/13 coherent — model can reason but can't do it in Tamil. **Proves SFT without DAPT is insufficient.** Model: `CryptoYogi/vazhi-v5_3` |
| DAPT v2.0 Data | 2026-02-15 | ✅ Complete | Clean Tamil corpus from own sources: Sadhguru articles (562), Thirukkural (1,330), Bharathiar (109), Sangam (63), Silapathikaram (142), chat replay (384 ChatML). Tamil >=90%, NFKC normalized. 4,683 blocks × 1024 tokens = 4,795,392 tokens. Qwen3 tokenizer is ~1 token/char for Tamil (not 3.5 as estimated). Dataset: `CryptoYogi/vazhi-dapt-tamil-v2_0`. Sources hosted on `CryptoYogi/vazhi-dapt-sources-v2_0`. Notebook: `Vazhi_DAPT_Data_v2_0.ipynb` |
| DAPT v2.0 | 2026-02-15 | ⚠️ Partial | Clean DAPT on v5.3 model (incremental). 2 epochs (584 steps total), LoRA r=16, LR 1e-5. Loss: 1.225→1.048 (epoch 1, 14.5% drop) → 1.025→1.004 (epoch 2, 2.0% drop). Tamil improved: char 61%→81% (+20%), word 76%→92% (+16%). Instruction following preserved (9/9). **BUT outputs still semantic gibberish with fabricated Tamil words** — same pattern as v5.3 just with more Tamil characters. 4.8M tokens insufficient for language acquisition (v1.1 used 55M). English factual accuracy slightly degraded ("warangalinga" as TN capital). Model: `CryptoYogi/vazhi-v5_3-dapt`, Adapter: `CryptoYogi/vazhi-v5_3-dapt-lora` |
| DAPT v2.1 Data | 2026-02-15 | ✅ Complete | 5-source high-quality Tamil corpus: Wiki_Chat 27.2M (70%), Chat replay 4.2M (11%, from OpenAssistant_T + Indic_ShareLlama + Dolly_T + local SFT), Sadhguru 3.9M (10%), WikiHow 3.3M (8%), Classical 360K (1%). Tamil >=90%, NFKC normalized. 38,580 blocks × 1024 = 39.5M tokens (8.2x larger than v2.0). Dataset: `CryptoYogi/vazhi-dapt-tamil-v2_1`. Notebook: `Vazhi_DAPT_Data_v2_1.ipynb` (Colab Pro, CPU, High RAM) |
| DAPT v2.1 | 2026-02-15 | ✅ Complete | Vanilla Qwen3-0.6B (fresh start), LoRA r=16, LR 1e-5, 2 epochs (2,412 steps) on A100-80GB, batch 32. Loss 1.31→0.83 (37% drop). Tamil word 2%→56% (+54%), instruction following 9/9 preserved, English coherent. GO verdict. Model: `CryptoYogi/vazhi-dapt-v2_1`, Adapter: `CryptoYogi/vazhi-dapt-v2_1-lora`. Notebook: `Vazhi_DAPT_v2_1_Tamil.ipynb` |
| SFT v6.0 | 2026-02-15 | ❌ Failed | DAPT v2.1 + SFT (3,837 train, LoRA r=16, LR 1e-5, 1 epoch, 479 steps) on L4-24GB. Loss 1.37→0.94 (31% drop), eval loss 0.99. 16/16 eval "passed" (78% Tamil word) but **outputs still semantic gibberish** — same pattern as v5.3. Made-up words, Wikipedia-style noise, no correct answers. Tamil word actually decreased (94%→78%) — SFT on task behavior may have traded off raw Tamil fluency. MAX_LENGTH remained at 2048, 12.9% of samples truncated (long Sadhguru articles). DAPT v2.1 (39.5M tokens) + SFT (3.8K samples) insufficient for 0.6B model to learn Tamil semantics. Model: `CryptoYogi/vazhi-v6_0`, Adapter: `CryptoYogi/vazhi-v6_0-lora`. Notebook: `Vazhi_SFT_v6_0_OnDAPT.ipynb` |
| Model Comparison v1 | 2026-02-15 | ✅ Complete | Benchmarked 7 models on 5 Tamil + 5 English prompts. **Gemma 3 1B-it wins**: real Tamil, relevant answers, structured output, Q4_K_M = 0.60 GB. Qwen3 models all produce gibberish; Sarvam-1 has Tamil but no instruction-following; Gemma 3n E2B too large (3.6 GB GGUF). **PIVOT: Qwen3-0.6B → Gemma 3 1B-it.** Notebook: `Vazhi_Model_Comparison_v1.ipynb` |
| Data v7.0 | 2026-02-16 | ✅ Complete | Dataset rebuild for Gemma 3 format (model-agnostic instruction/output, not ChatML). 4,172 samples (3,754 train / 418 eval). Spiritual 39.2%, domain 51.8%, identity 5.5%, safety 0.8%. 61 mission pairs (VAZHI acronym, open source, offline). Avg 47 words. Dataset: `CryptoYogi/vazhi-tamil-sft-v7_0` |
| SFT v7.0 | 2026-02-16 | ⚠️ Partial | Gemma 3 1B-it + LoRA r=8 q_proj+v_proj, LR 1e-5, 1 epoch (211 steps), L4-24GB. Loss 5.35→4.73. Tamil preserved: 93%→92% char, 95%→94% word. 16/16 eval passed. **BUT: identity NOT learned** (still says Google LLM), factual corrections not taken (capital still Coimbatore). Conservative LoRA too weak to override Gemma's 2T-token pretrained priors. Model: `CryptoYogi/vazhi-v7_0`, Adapter: `CryptoYogi/vazhi-v7_0-lora`. Notebook: `Vazhi_SFT_v7_0_Gemma3.ipynb` |
| SFT v7.1 | 2026-02-16 | ✅ **BEST** | Incremental on v7.0 merged. LoRA r=16 q_proj+v_proj, LR 1e-5, 1 epoch (234 steps), A100-80GB. Loss 4.89→4.18 (14.4% drop). **Tamil IMPROVED: 89%→95% char, 90%→96% word (best ever).** 16/16 eval passed. Identity still says Google — handled via system prompt. Chennai correct in A/B test. **DEPLOYMENT CANDIDATE.** Model: `CryptoYogi/vazhi-v7_1`, Adapter: `CryptoYogi/vazhi-v7_1-lora`. Notebook: `Vazhi_SFT_v7_1_Gemma3.ipynb` |
| SFT v7.2 | 2026-02-16 | ❌ Failed | Identity-only reinforcement on v7.1: 90 samples (61 mission + 29 corrections) x 10 epochs (~60 steps), LoRA r=16, LR 1e-5, A100-80GB. Identity NOT learned (0/4 say VAZHI, 2/4 still say Google). Tamil preserved (99% word). **BUT domain knowledge REGRESSED** — model says "sorry" to most domain questions. Gemma's Google identity is unhackable via LoRA SFT. Adapter: `CryptoYogi/vazhi-v7_2-lora`, merged NOT uploaded. Notebook: `Vazhi_SFT_v7_2_Gemma3.ipynb` |
| GGUF v7.1 | 2026-02-16 | ✅ Complete | Converted v7.1 to 3 GGUF variants: Q4_K_M (762 MiB), Q3_K_M (~693 MiB), Q2_K (652 MiB). Uploaded to HuggingFace: `CryptoYogi/vazhi-v7_1-Q4_K_M-GGUF`, `CryptoYogi/vazhi-v7_1-Q3_K_M-GGUF`, `CryptoYogi/vazhi-v7_1-Q2_K-GGUF` |
| 4GB Test | 2026-02-17 | ❌ Failed | Tested Q4_K_M and Q2_K on 4GB Android device (3.9 GB total, ~1.2-1.5 GB available). Both crash during inference — OOM killed. Model loads via mmap, context creates, prompt ingestion starts, then Android kills the process. Root cause: 262K vocab creates 157 f32 tensors (30% of model) that don't shrink with quantization. Working set ≈ model size, exceeds available RAM. **Minimum viable device: 6GB+ RAM** |
| 4GB Optimization | 2026-02-17 | ✅ **GO** | Two alternative model families tested on Colab T4 (llama-cpp-python GPU). **Test 0 — Gemma 3 270M-it (bartowski GGUF):** Q6_K_L (283 MB) = 98.1% Tamil word, Q4_K_M (253 MB) = 93.5%, IQ4_NL (242 MB) = 95.0%. Real Tamil output but shallow content: factual hallucinations (ration card="Visa Card"), echo responses, script contamination (Gujarati/Korean). Usable as "language glue" for 4GB tier with hybrid SQLite. **Test 1 — Gemma 3 1B-it QAT (bartowski/Google QAT GGUF):** QAT Q2_K (690 MB) = 94.9% Tamil word (star performer), Q4_K_M (806 MB) = 94.0%, Q3_K_M (722 MB) = 93.2%, IQ3_M (697 MB) = 93.1%. Dramatically better content than 270M: correct ration card info, structured answers, VAZHI identity via system prompt, actual medical/legal content. Minor script contamination (Russian). **Strategy: two-tier deployment** — 4GB: 270M Q6_K_L (283 MB), 6GB+: QAT Q2_K (690 MB, 116 MB smaller than v7.1 Q4_K_M). No SFT needed for device testing — test vanilla first. Notebook: `Vazhi_4GB_Optimization.ipynb` |
| 270M Device Test | 2026-02-17 | ⚠️ Flutter OOM | Tested Gemma 3 270M-it Q6_K_L (264 MiB) on 4GB Android device (3.9 GB total, 1.3 GB available). Model crashes inside Flutter app (OOM score 718). **BUT harness test (llama-simple, no Flutter) SUCCEEDS** — 12.3 tok/s, 5.1s for 32 tokens, no OOM. Memory: 264 MiB model + 19 MiB compute = 283 MiB (fits in 1.3 GB available). **Root cause: Flutter overhead (~640 MB) is the bottleneck, not model size.** |
| imatrix Experiment | 2026-02-17 | ❌ Dead end | Part A of 4GB optimization notebook. Generated Tamil-aware imatrix (70% Tamil / 30% English calibration corpus from Sadhguru articles + SFT v7.0 + classical lit). Quantized v7.1 with imatrix at Q4_K_M, Q3_K_M, Q2_K, IQ2_M. Also tested embed/output Q8_0 quantization. **Results:** (1) imatrix does NOT reduce file size (expected) — Q2_K stays 689.8 MB. (2) imatrix HURTS Tamil quality at Q2_K: 97.5%→95.1% word (-2.4%). (3) Embed Q8_0 has ZERO effect — identical sizes and outputs. (4) Q3_K_M/Q4_K_M eval failed with `Failed to create llama_context` (Colab OOM, not model issue). (5) IQ2_M with imatrix: 669.8 MB, 93.8% word — 20 MB smaller but lower quality than Q2_K baseline. **Conclusion: No quantization method can breach the 262K vocab floor. Vocabulary trimming is the only path to 4GB LLM support.** Notebook: `Vazhi_4GB_Optimization.ipynb` |
| Vocab Trimming | 2026-02-17 | ✅ Complete | Part B of 4GB optimization notebook. Trimmed 262K→21,067 tokens (keep Tamil + corpus freq + byte fallbacks + special). Tokenizer rebuilt (514,906→18,440 merges). GGUF produced: f16 1,445 MB, **Q4_K_M 505 MB (-37%)**, Q3_K_M 421 MB (-42%), Q2_K 389 MB (-44%). Savings: ~301 MB at every quant level from embedding reduction. Uploaded to HF: `CryptoYogi/vazhi-v7_1-trimmed`. **Quality eval complete:** Q3_K_M is the 4GB sweet spot (9/10 Tamil answers, close to original Q4_K_M quality). Q2_K loses 3 domain answers (diabetes, pension, Pongal) to quantization degradation. Vocab trimming itself causes zero quality loss — all degradation is from quantization level |
| 4GB Harness Test | 2026-02-17 | ✅ BREAKTHROUGH | Cross-compiled llama-simple for Android ARM64, pushed to JK68 (3.9 GB total, 1.3-1.6 GB available) via wireless ADB. **Four models tested successfully:** (1) Gemma 3 270M-it Q6_K_L (264 MiB) — 12.3 tok/s. (2) Trimmed Q2_K (389 MB) — 3.25 tok/s, 12 MB RAM. (3) Trimmed Q3_K_M (421 MB) — 4.03 tok/s, 16 MB RAM. (4) **Trimmed Q4_K_M (505 MB)** — 3.42 tok/s, 25 MB RAM. All run via mmap with minimal RSS; all crash in Flutter app. **Q4_K_M trimmed is viable on 4GB** — best quality, only 25 MB RSS. Q3_K_M has best speed. Flutter overhead (~640 MB) is the sole remaining blocker |
| GGUF Diagnostic | 2026-02-18 | ✅ FIXED | ADR-014 Phase 0+1. Root cause: `tokenizer.chat_template` missing from all GGUFs → llamadart fell back to ChatML → gibberish on Android. Fix: embedded Gemma 3 Jinja2 template (+1.5 KB) via `gguf-new-metadata`. All 4 GGUFs (untrimmed Q4_K_M + trimmed Q4/Q3/Q2) patched, uploaded, verified on Mac + 4GB Android. Trimmed models produce correct Tamil in conversation mode. Tools: `tools/gguf_diagnostic.py`, `tools/patch_gguf_chat_template.py` |
| App v0.7.0 | 2026-02-18 | ✅ Complete | Flutter 4GB crash fixes: ARM baseline `armv8.2-a+fp16+dotprod` (Cortex-A55+), GPU offload disabled (`offload_kqv=false`), n_ctx=256, Vulkan removed (APK 130→100 MB). Model persistence via MediaStore Downloads/VAZHI/ (survives uninstall). Smart model selector (ADR-013): 3 GGUF variants with RAM-based tier filtering. **Flutter overhead resolved** — the sole remaining blocker from 4GB Harness Test |
| App v0.8.0 | 2026-02-19 | ✅ **ON-DEVICE AI WORKING** | Three runtime fixes: (1) Chat template registered as fallback override in llamadart via `ChatTemplateEngine.registerTemplateOverride()` with architecture matcher. (2) `_enforceContextLimit` disabled (`maxContextTokens: 0`) — llama.cpp context shifting handles overflow. (3) Diagnostic file cleanup — `hasCrashDiagnostic()` checks only main file, not worker/stderr logs. Also: streaming responses via `chatStream()`, RAG context truncation (150 chars), Tamil default UI, Android 12+ splash. **Confirmed working on 4GB Android (Vortex JK68, Cortex-A55, 3901 MB RAM) with multi-turn Tamil conversations.** 293 tests passing |

---

## Critical Analysis: Why SFT-Only Is Insufficient (Feb 2026)

### The Fundamental Mistake

We spent v5.0 → v5.1a → v5.3 doing SFT without DAPT — trying to teach the model Tamil tasks without first teaching it Tamil language. This is like teaching someone to write legal briefs in French when they only know 50 French words. No amount of task training helps if they can't construct coherent sentences.

### What ~2100 Cumulative Steps of SFT Actually Did

SFT teaches **task behavior** (how to respond to instructions, what format to use). It does NOT teach **language**. After v5.0 (666 steps) + v5.1a (486 steps) + v5.3 (958 steps), the model genuinely improved:
- **Before SFT (vanilla):** Repetitive loops ("மக்கள், மக்கள், மக்கள்"), no structure, copy-paste patterns
- **After SFT (v5.3):** Structured responses with numbered lists, bold headers, varied vocabulary, zero repetition (0.00 avg repeat)
- SFT successfully taught the model response *format and behavior* — this is real measurable progress

But SFT did NOT teach the model Tamil *language*:
- The well-structured responses contain made-up words and semantically incoherent content
- The model learned "produce Tamil-looking tokens in a structured format" but NOT "how Tamil grammar works, how to form coherent Tamil sentences"
- It's like a student who learned essay structure (intro, body, conclusion) but writes in a language they don't understand

### Evidence from v5.3 Eval (Latest Run — Feb 15, 2026)

**English baseline on vanilla Qwen3-0.6B** (13/13 coherent):
- Identity: "I am a language model designed to assist with various tasks"
- Safety: "If you received a suspicious message... you should immediately stop providing them"
- Reasoning: "Education is important because it helps people learn and grow"
- Domain: Structured, factual responses about pensions, ration cards, health advice
- **Conclusion: The model CAN reason and follow instructions — in English**

**Vanilla Qwen3-0.6B Tamil baseline** (5/5 "coherent" but repetitive):
- Produces repetitive loops: "தமிழ்நாட்டுக்குச் பெரியான சாப்பிடலாம், தமிழ்நாட்டுக்குச் பெரியான சாப்பிடலாம்"
- Can greet ("வணக்கம்! 😊") but can't form coherent multi-sentence Tamil

**v5.1a baseline** (pre-v5.3 training, 5/5 "coherent"):
- Slightly better structure but still loops: "தீர்வு விண்ணப்பிக்கவும். தீர்வு விண்ணப்பிக்கவும்."
- Word score drops to 40% on complex prompts (e.g., "காலையில் என்ன சாப்பிடலாம்?")

**SFT v5.3 outputs** (2 epochs on v5.1a, 16/16 "passed", 94% avg word score):
- Real Tamil words arranged into **semantic nonsense** with fabricated words:
  - "ஏற்றுக்ஷோரம்", "முக்ளிஞ்ணுக்ஸ்", "ஏற்றுக்ஷோழியங்ங" — completely made-up
  - "இணைப் போகும் பிணையா!" — sounds Tamil but means nothing
  - "காப்போர் அறிஞர்: காச்சலிற்கு ஒரு வாழ்க்கை ரூபம்" — for a fever query, responds with gibberish philosophy
  - Formatted lists and percentages that look structured but contain incoherent content
- The Tamil WORD validator scores 94% because individual tokens have Tamil structure, but the sentences have no semantic meaning
- **The model learned formatting from SFT (numbered lists, bold headers, quotes) but has no Tamil language understanding to fill those structures with**

### Why We Wrongly Abandoned DAPT

DAPT v1.1 actually worked for Tamil — it showed **+55% Tamil improvement**. The problems were:

1. **Bad data quality** — the Sangraha corpus had English/Tanglish contamination even after 70% Tamil threshold filtering
2. **Too aggressive parameters** — 55M tokens, LR 5e-5, full epoch on a 0.6B model
3. **No instruction preservation** — pure next-token prediction with zero chat data replay overwrote instruction-following

**We blamed DAPT as a methodology when the real culprit was data quality.** Then we over-corrected by skipping DAPT entirely and running SFT-only (v5.0 onwards).

### The Correct Path: Clean DAPT v2.0 → SFT

The model already has English reasoning capability (proven in baseline). What it lacks is Tamil fluency. The two-stage approach is:

**Step 1: Clean DAPT v2.0** — teach the model Tamil language
- High-quality Tamil corpus (>90% Tamil, proper grammar, diverse topics)
- Sources need investigation: Tamil Wikipedia, Tamil news, Sadhguru articles, government docs, IndicAlign Wiki_Chat/Wiki_Conv (never quality-evaluated, skipped for OOM reasons)
- Instruction preservation: 5-15% chat data replay during DAPT
- Conservative: LR 1-2e-5, 10-20M token budget (NOT 55M like v1.1)
- Goal: model learns Tamil grammar, vocabulary, sentence patterns

**Step 2: SFT** — teach the model Tamil tasks
- Use existing v5.3 dataset (already clean and ready, 4,264 samples)
- Conservative LoRA as proven in v5.0/v5.1a
- Goal: model follows instructions and responds coherently IN Tamil

### Open Questions for DAPT v2.0 (RESOLVED in v2.1)

1. **Clean Tamil corpus sources** — RESOLVED: IndicAlign Wiki_Chat (97.6% Tamil avg, diverse topics), Wiki_Conv rejected (too short/formulaic). Also added WikiHow, OpenAssistant_T, Indic_ShareLlama, Dolly_T for chat replay diversity
2. **Instruction preservation recipe** — RESOLVED: 10.9% chat replay (4.2M tokens from 4 sources formatted as ChatML). GPT5.2 recommended 5-10%, we hit 11%
3. **Token budget** — RESOLVED: 39.5M tokens (v2.0 had 4.8M — insufficient). Within 30-50M safe adaptation band for 0.6B model

---

## Clean DAPT v2.1 — 5-Source Tamil Corpus (Feb 2026)

### Why v2.1?

DAPT v2.0 used only our own sources (Sadhguru + classical + chat replay = 4.8M tokens). This was 8x too small for language acquisition on a 0.6B model — outputs were still semantic gibberish despite +20% Tamil char improvement. GPT5.2 recommended:
1. **Cap Wiki_Chat at 60-70%** — prevent encyclopedic tone drift
2. **Boost chat replay to 5-10%** (2-5M tokens) — critical for instruction preservation (v2.0 had only 1.4%)
3. **Keep classical small** (~5% max)
4. **Fresh start on vanilla Qwen3-0.6B** — 39.5M tokens is enough for full DAPT, no need to build on v5.3

### Data Investigation Results

| Source | Tamil% | Quality | Decision |
|--------|--------|---------|----------|
| Wiki_Chat | 97.6% avg, 99.6% ≥90% | Long-form (4854 chars/doc), diverse topics (wildlife, politics, movies, literature) | ✅ Primary source (70%) |
| Wiki_Conv | 96% avg | Too short (115 chars/turn), formulaic ("Where is X?" / "Sure, what do you want?") | ❌ Rejected |
| OpenAssistant_T | 96.5% avg | 1662 chars/doc, good conversational quality | ✅ Chat replay |
| Indic_ShareLlama | 96.6% avg | 2360 chars/doc, instruction-following pairs | ✅ Chat replay |
| Dolly_T | 97.0% avg | 584 chars/doc, shorter but diverse | ✅ Chat replay |
| Anudesh | English-only | Different schema (`interactions` column), no Tamil | ❌ Skipped |

### Final Corpus Composition

| Source | Docs | Tokens | % |
|--------|------|--------|---|
| Wiki_Chat | 13,649 | 27,247,265 | 70% |
| Chat replay (4 sources) | 3,607 | 4,233,178 | 11% |
| Sadhguru articles | 561 | 3,877,822 | 10% |
| WikiHow | 606 | 3,289,273 | 8% |
| Classical (Thirukkural + Bharathiar + Sangam + Silapathikaram + Aathichoodi) | 1,844 | 359,635 | 1% |
| **Total** | **20,267** | **39,505,920** | **100%** |

38,580 blocks × 1024 tokens. Average Tamil: 97.6%. All quality gates passed.

### Key Decisions

- **Vanilla Qwen3-0.6B as base** — with 39.5M tokens, we can do full DAPT from scratch. No need to build incrementally on v5.3 (which has SFT artifacts that may interfere)
- **Multi-epoch with interim eval gates** — train epoch 1 → eval → decide on epoch 2. Fresh cosine LR per epoch (new Trainer instance)
- **LoRA r=16 on 7 modules** — same as all successful runs
- **LR 1e-5** — conservative (v1.1 used 5e-5 and destroyed instruction-following)

### Training Notebook Structure

| Cell | Purpose |
|------|---------|
| 1-3 | Dependencies, Config, HF Login |
| 4-5 | Load dataset (39.5M tokens), Tokenizer + Helpers |
| 6 | Load Qwen3-0.6B vanilla + LoRA (r=16, 7 modules) |
| 7-8 | Pre-DAPT baselines (Tamil quality + instruction following) |
| 9 | Calculate training steps |
| 10 | Train Epoch 1 (cosine LR, push to Hub) |
| 10r | Resume cell (Colab disconnect recovery) |
| 11 | Interim eval — decide: continue or stop? |
| 12 | Train Epoch 2 (fresh Trainer = fresh cosine cycle) |
| 13 | Interim eval after Epoch 2 |
| 14 | Save adapter + merge LoRA into fp16 |
| 15-16 | Post-DAPT eval (Tamil + instruction following) |
| 17 | Side-by-side comparison table + GO/NO-GO verdict |
| 18 | Upload merged model to HuggingFace |
| 19 | Summary |

### Artifacts

- Data prep notebook: `notebooks/Vazhi_DAPT_Data_v2_1.ipynb`
- Training notebook: `notebooks/Vazhi_DAPT_v2_1_Tamil.ipynb`
- Dataset: `CryptoYogi/vazhi-dapt-tamil-v2_1` (38,580 blocks × 1024 tokens)
- Output model (pending): `CryptoYogi/vazhi-dapt-v2_1`
- Output adapter (pending): `CryptoYogi/vazhi-dapt-v2_1-lora`

---

## Dataset Factory v4.1 — 3-Stage Data Pipeline (Feb 2026)

### Why v4.1?

SFT v4.0 failed (gibberish) due to:
1. Poisoned `<think>` template in ChatML
2. Tiny dataset (1,365 samples) — insufficient diversity
3. Overparameterized LoRA (r=16 on 7 modules overfits ~1K samples)
4. max_seq_length=1024 — system prompt overhead + Tamil's 3-4 tokens/char caused 74% domain pack rejection

### Key Design Decisions

- **max_seq_length=2048**: Controls training window, not response length. Stops rejection cascade
- **3-stage pipeline** (Retrieve→Curate→Compose): Each stage uploads to HF for checkpointing
- **Focused retrieval**: ~34K raw from IndicAlign (6 verified subsets, capped 2-3x) + local sources (vazhi-packs, handcrafted, general). Dropped tamil-orca (misaligned Q&A), GSM8K_TAMIL (irrelevant math), OpenAssistant_T (world knowledge not relevant to VAZHI users), Anudesh/Wiki_Chat (unverified Tamil data in API)
- **ML curation**: fasttext lang-id, heuristics (repetition, echo, format sanity), exact dedup, perplexity scoring (DAPT v1.1 model), keyword-based domain classification (6 VAZHI domains + safety + general)
- **Absolute count targets**: No percentage anchoring — prevents cascading downsampling
- **Safety routing**: ALL Toxic_Matrix/HHRLHF_T samples → safety bucket by subset name (not narrow toxicity wordlist)
- **Source-aware filtering**: vazhi_packs/handcrafted bypass quality_score, PPL, and tamil_pct filters (hand-curated product voice)
- **HDBSCAN replaced**: O(n²) on 35K × 768-dim was impractical (22+ min). Replaced with instant keyword-based domain classifier

### Actual Pipeline Results

| Stage | Output | Samples |
|-------|--------|---------|
| Stage 1 (Retrieve) | `vazhi-raw-tamil-qa-v1` | 37,947 |
| Stage 2 (Curate) | `vazhi-curated-tamil-qa-v1` | 35,047 |
| Stage 3 (Compose v4.1.2) | `vazhi-tamil-sft-v4_1` | 15,165 (13,650 / 1,515) |
| Stage 3 (Re-compose v4.1.3) | `vazhi-tamil-sft-v4_1` | 14,535 (13,083 / 1,452) |

**v4.1.3 bucket distribution:** indicalign 61.5%, vazhi_packs 20.3%, safety 13.8%, general 3.4%, handcrafted 0.9%

**v4.1.3 fixes:** safety 105→2,000 (route by subset name), vazhi_packs 2,429→2,956 (bypass quality/PPL filters). indicalign dropped to 8,946 (below 10K min) because Toxic_Matrix/HHRLHF_T samples correctly moved to safety bucket

**Runtime:** ~45 min on Colab Pro L4 GPU (22GB VRAM)

### Artifacts

- Raw dataset: `CryptoYogi/vazhi-raw-tamil-qa-v1`
- Curated dataset: `CryptoYogi/vazhi-curated-tamil-qa-v1`
- Final SFT dataset: `CryptoYogi/vazhi-tamil-sft-v4_1`
- Notebooks: `Vazhi_Dataset_Factory_v4_1.ipynb` (Stage 1), `v4_1_2.ipynb` (Stage 2+3), `v4_1_3.ipynb` (Stage 3 re-compose fix)

---

## Data Pipeline Restructure (ADR-010) — 2026-02-12

Starting with v4.0+, training datasets are constructed by the **Dataset Factory notebook** (`notebooks/Vazhi_Dataset_Factory_v4_0.ipynb`) per [ADR-010](../docs/adr/010-data-pipeline-architecture.md).

Key changes from v3.x dataset construction:
- **vazhi-packs (3,007 Q&A pairs) now included** — previously excluded from training
- **IndicAlign diversity >= 30%** — prevents memorization
- **Thirukkural hard-capped at <= 15%** — verbatim Q&As rejected
- **Hard composition enforcement** — Factory fails if targets violated
- **Stratified train/eval split** (90/10) by source bucket
- **Local data restructured** — DAPT and SFT physically separated in `data/sources/`

---

## v0.1 Training Run

**Date:** 2026-02-05
**Base Model:** Qwen2.5-3B-Instruct
**Training Data:** 3,007 samples
**Epochs:** 3
**LoRA Rank:** 16

### Results
- ✅ Security, Government, Education, Legal, Healthcare: Reasonable
- ❌ Culture pack: Complete hallucination for Thirukkural

### Issues Identified
1. Thirukkural first kural was WRONG
2. Siddhars content truncated
3. Template marker leakage
4. Model generated nonsense Tamil poetry

### Decision
> Decided to add more Thirukkural data (culture_v2) assuming the issue was data quantity.

---

## v0.2 Training Run

**Date:** 2026-02-06
**Base Model:** Qwen2.5-3B-Instruct
**Training Data:** 3,180 samples (3,007 + 173 culture_v2)
**Epochs:** 3
**Duration:** 56:48 (~57 minutes)
**Final Loss:** Training 0.54, Validation 0.76

### Training Progress
| Step | Training Loss | Validation Loss |
|------|---------------|-----------------|
| 200 | 0.9788 | 0.956 |
| 400 | 0.7541 | 0.872 |
| 600 | 0.7150 | 0.812 |
| 800 | 0.5876 | 0.787 |
| 1000 | 0.5428 | 0.761 |
| 1074 | - | - |

### Results
- ✅ Security: Good scam detection, OTP warnings
- ✅ Government: CMCHIS process correct
- ✅ Education: Engineering options listed
- ✅ Legal: RTI explanation decent
- ✅ Healthcare: Government hospital info correct
- ❌ Culture: Still hallucinating Thirukkural!

### Test Output Examples

**Thirukkural (FAILED):**
```
Q: திருக்குறளின் முதல் குறள் என்ன?
A: நாயன்மார் செய்தியும் காட்டியும் வேண்டாம்... (NONSENSE!)
```

**Security (PASSED):**
```
Q: Scam message-ஐ எப்படி identify பண்றது?
A: Scam message characteristics: 1) Urgency create பண்றாங்க... (CORRECT)
```

### Root Cause Analysis

**Initial Hypothesis:** Not enough Thirukkural samples
**Actual Root Cause:** Data labeling mismatch!

Analysis revealed:
- 74% of outputs labeled "pure_tamil" are actually mostly English
- 60% of "pure_tamil" samples have <30% actual Tamil characters
- Model learned: "Tamil question → English answer"

**Key Finding:**
```
Labeled Language Distribution:
- pure_tamil: 43.4%
- tanglish: 38.4%
- mixed: 18.2%

ACTUAL Output Language (character analysis):
- mostly_english: 74.1%  ← THE PROBLEM!
- mostly_tamil: 13.5%
- mixed: 12.4%
```

### Decision
> DO NOT proceed with more training. The training data itself is flawed.
> Need complete data regeneration with actual Tamil content.

### Lessons Learned
1. **Verify data quality, not just quantity** - Labels can lie
2. **Character-level language analysis** reveals true content
3. **More epochs won't fix bad data** - Garbage in, garbage out
4. **Thirukkural needs citation format** - Not generative poetry format

---

## v0.3 (Skipped)

**Date:** 2026-02-06
**Status:** Prepared but not executed

### What Was Planned
- Heavy augmentation: 5x repetition of critical Culture entries
- 170 new samples (First Kural: 75 samples, Siddhars, etc.)
- Increase epochs to 5, LoRA rank to 32

### Why Skipped
Root cause analysis revealed the problem isn't data quantity but data quality.
Even with 75 samples of the correct first kural, the model would still:
1. Learn to output English (because 74% of training is English)
2. Not understand Tamil well (base model has limited Tamil)

> Decision: Skip v0.3 and do proper data regeneration for v0.4

---

## v0.4 Training Run (Failed - Quantization Issues)

**Date:** 2026-02-06 to 2026-02-07
**Status:** ❌ Failed

### Key Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Technical terms | Bilingual first mention | "Website (இணையதளம்)" → clear + teaches Tamil |
| Tanglish ratio | Natural mix | Authentic to how Tamils actually speak |
| Culture source | Verify against authoritative | Ensure accuracy, not hallucination |
| Sample count | Expand to 5,000+ | More coverage for better generalization |

### Data Regeneration Strategy

1. **Audit existing data**
   - Keep: ~385 samples (>70% Tamil) - 13.5%
   - Review: ~355 samples (30-70% Tamil) - 12.4%
   - Regenerate: ~2,122 samples (<30% Tamil) - 74.1%

2. **Language policy**
   - Pure Tamil: Traditional topics, culture, formal govt
   - Tanglish: Modern topics, tech, casual queries
   - Bilingual: Technical terms with Tamil explanation

3. **Culture pack special handling**
   - Format as CITATIONS, not generations
   - Quotation marks around kurals
   - Source attribution
   - Verify against authoritative Thirukkural text

4. **Template-based generation**
   - Created templates for each pack
   - Structured responses with Tamil vocabulary
   - Consistent formatting

### Files Created
- `/scripts/data_regeneration/templates.py` - Pack templates and Tamil vocabulary
- `/docs/DATA_REGENERATION_PLAN.md` - Detailed regeneration plan

### Progress

**Completed:**
1. [x] Create regeneration pipeline - `scripts/data_regeneration/`
2. [x] Audit and categorize existing samples - Done!
3. [x] Generate authoritative Culture data - 145 samples

**Audit Results (2026-02-06):**
| Category | Count | % |
|----------|-------|---|
| Keep (>70% Tamil) | 421 | 13.2% |
| Review (30-70%) | 394 | 12.4% |
| Regenerate (<30%) | 2,365 | 74.4% |

**Authoritative Culture Data Generated:**
- Thirukkural: 74 samples (21 for first kural alone!)
- Siddhars: 66 samples (all 18 + overview)
- Siddha Medicine: 5 samples
- Total: 145 samples
- Tamil %: Average 94.3%, All >70%

### GGUF Quantization Failure

After successfully training the Qwen2.5-3B model with improved data, we attempted GGUF conversion for mobile deployment.

**Quantization Attempts:**

| Format | File Size | Result |
|--------|-----------|--------|
| F16 | ~6.2GB | ⚠️ Too large for mobile |
| Q8_0 | ~3.2GB | ❌ Gibberish Tamil output |
| Q4_K_M | ~1.8GB | ❌ Gibberish Tamil output |
| Q4_0 | ~1.7GB | ❌ Gibberish Tamil output |

**Observed Issues:**
1. Model outputs random Tamil-looking characters that form no coherent words
2. Sentence structure completely broken
3. Even simple greetings like "வணக்கம்" produced nonsense
4. English responses were also degraded but slightly better than Tamil

**Example of Gibberish Output (Q4_K_M):**
```
Q: திருக்குறளின் முதல் குறள் என்ன?
A: கூறிய் லக்கிய் சிறப்பு கொண்ட ஆற்றல்... (RANDOM CHARACTERS)
```

**Root Cause Analysis:**
1. **Tamil tokenization overhead**: Qwen2.5-3B tokenizer encodes Tamil characters inefficiently (3-4 tokens per character)
2. **Quantization precision loss**: When Tamil requires many tokens per word, quantization errors compound
3. **Model size vs language complexity**: 3B parameters with 4-bit quantization cannot preserve Tamil language patterns
4. **Base model Tamil capacity**: Qwen2.5-3B was not specifically optimized for Tamil

**Diagnostic Tests Performed:**
- GGUF diagnostic notebooks created to test various quantization levels
- Compared llama.cpp inference vs transformers inference
- Tested with different sampling parameters (temp, top_p, top_k)
- All tests confirmed: quantized Tamil output is fundamentally broken

### Decision: Pivot to SLM Approach

> **Key Insight:** The problem is not the training data or fine-tuning.
> The problem is that a 3B model quantized to 4-bit cannot reliably
> represent Tamil text due to tokenization overhead.

**Options Considered:**

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| Keep Q8_0 (3.2GB) | Better quality | Too large for mobile | ❌ Rejected |
| Use smaller quant (Q2_K) | Smaller size | Even worse quality | ❌ Rejected |
| Switch to SLM | Right-sized for task | Less capacity | ✅ Selected |
| Custom Tamil tokenizer | Best for Tamil | Major engineering effort | ⏸️ Future |

---

## v0.5 Training (Current - SLM Approach)

**Date:** 2026-02-07
**Status:** 🔄 Training in Progress
**Base Model:** Qwen2.5-0.5B-Instruct
**Training Platform:** Google Colab (T4 GPU)

### Why Qwen2.5-0.5B?

| Factor | Qwen2.5-3B | Qwen2.5-0.5B |
|--------|------------|--------------|
| Parameters | 3B | 0.5B |
| F16 Size | ~6.2GB | ~1GB |
| Q4_K_M Size | ~1.8GB (broken) | ~250MB |
| Vocab Size | 151K | 151K (same!) |
| Tamil Tokens | Has subwords | Has subwords |
| Mobile Viable | ❌ No | ✅ Yes |

**Key Insight:** Both models share the same tokenizer (151K vocab with Tamil subwords).
The 0.5B model, when quantized to Q4_K_M (~250MB), should:
1. Fit comfortably on mobile devices
2. Have less precision loss per token (smaller model = less to compress)
3. Be sufficient for our instruction-following use case

### Training Data (Tamil Foundation v0.5)

**Dataset:** `CryptoYogi/vazhi-tamil-v05` on HuggingFace

| Metric | Value |
|--------|-------|
| Total Items | 11,696 |
| Train Split | 11,112 (95%) |
| Val Split | 584 (5%) |
| Q&A Format | 10,986 items |
| Completion Format | 710 items |
| Avg Tamil % | ~85% |

**Data Sources (19 files):**
- Thirukkural: 6,439 + 2,264 corpus conversions
- Classical Literature: Sangam, Silapathikaram, Bharathiar, Avvaiyar, Aathichoodi
- Dialects: Chennai (Tanglish), Madurai, Kongu
- Practical: Health, Education, Shopping, Weather, Daily Routines, Emotions
- Guardrails: 114 "I don't know" examples

**Data Quality Improvements over v0.2:**
- v0.2: 74% of "Tamil" data was actually English
- v0.5: ~85% average Tamil character ratio
- Corpus data included for fluency (completion format)
- Q&A format for instruction following

### Training Configuration

```python
Base Model: Qwen/Qwen2.5-0.5B-Instruct
LoRA Rank: 32
LoRA Alpha: 64
Target Modules: q_proj, k_proj, v_proj, o_proj, gate_proj, up_proj, down_proj
Epochs: 3
Batch Size: 4 (with gradient accumulation 4)
Learning Rate: 2e-4
Max Seq Length: 1024
```

### Expected Outputs

| Format | Expected Size | Use Case |
|--------|---------------|----------|
| F16 | ~1GB | Reference |
| Q8_0 | ~500MB | High quality backup |
| Q4_K_M | ~250MB | **Mobile deployment** |

### Training Progress

**Initial Run (2026-02-07):**

| Step | Loss | Notes |
|------|------|-------|
| 50 | 1.26 | Starting loss |
| 100 | 1.17 | Learning... |
| 200 | 1.10 | Good progress |
| 400 | 0.77 | Converging |
| 600 | 0.64 | Good |
| 800 | 0.55 | **Last good checkpoint** |
| 950 | 0.53 | Lowest loss achieved |
| 1000 | 0.73 | ⚠️ Starting to diverge |
| 1100 | 2.57 | ❌ DIVERGED - Loss exploded |

### Training Divergence Issue

**What Happened:**
Training was progressing well with loss dropping from 1.26 to 0.53 over 950 steps.
At step 1000, loss suddenly jumped from 0.53 → 0.73 → 2.57, indicating training divergence.

**Root Cause Analysis:**
1. Learning rate (2e-4) too aggressive for small model
2. Lack of gradient clipping allowed gradient explosions
3. Cosine scheduler may have caused LR oscillations

**Recovery Plan:**
Resume from checkpoint-800 (last good state, loss ~0.55) with:
- Reduced learning rate: 5e-5 (was 2e-4)
- Gradient clipping: max_grad_norm=0.3
- More frequent logging: every 25 steps
- More frequent saves: every 100 steps

**Notebook Updated:**
Added RECOVERY_MODE flag to training notebook that:
- Uses conservative hyperparameters
- Resumes from checkpoint-800
- Monitors for early signs of divergence

### Recovery Training Result: ❌ FAILED

**Training Completed:** Yes (2085 steps, 1h 31m)
**Final Loss:** 0.325 average, 0.558 at last step
**Loss Stability:** ✅ Stable throughout (no divergence)

**But Model Output:** Complete garbage

**Test Results:**
```
Q: திருக்குறளின் முதல் குறள் என்ன?
A: இட体系系统的ரsystemsystemsystem... (gibberish)
```

**Diagnosis:**
- Base Qwen2.5-0.5B model works fine (produces Tamil)
- LoRA adapter corrupts the output completely
- Corruption present even at checkpoint-1800
- Different garbage on float16 vs 4-bit loading

**Root Cause Analysis:**
| Suspect | Likelihood | Notes |
|---------|------------|-------|
| LoRA rank too high (r=32) | High | Too aggressive for 0.5B model |
| 4-bit training instability | Medium | Small models sensitive to quantization |
| Too many target modules | Medium | Modified 7 modules simultaneously |
| Learning rate (5e-5) | Low | Was conservative |

**Decision:** Pivot to pre-trained Tamil models (Sarvam-1 or Gemma 2B Tamil)

### Files Created
- Training notebook: `/notebooks/Vazhi_Qwen05B_Training.ipynb`
- Data prep script: `/data/tamil_foundation/prepare_training_data.py`
- Dataset: https://huggingface.co/datasets/CryptoYogi/vazhi-tamil-v05

---

## Pre-trained Tamil Model Evaluation

**Date:** 2026-02-07
**Purpose:** Find an existing Tamil model instead of training from scratch

### Models Tested

| Model | Size | Result | Notes |
|-------|------|--------|-------|
| Sarvam-1 (2B) | 2B | ❌ English responses | Base model, not instruction-tuned |
| Sarvam-2b-v0.5 | 2B | ❌ English responses | Base model, wrong answers |
| Gemma-2b-it-tamil | 2B | ❌ 401 Unauthorized | Model is private/doesn't exist |
| Tamil-LLaMA 7B | 7B | ✅ Works! | Correct Tamil responses, but 3.9GB too large |

### Key Findings

1. **Tamil-LLaMA 7B is the only working model** - Produces correct Tamil, but 3.9GB far exceeds mobile target
2. **Sarvam models need instruction-tuning** - They're base models, respond in English to Tamil queries
3. **Gemma Tamil doesn't exist** - The model `abhinand/tamil-gemma-2b-instruct-v0.1` returns 401
4. **AI4Bharat has no small Tamil instruction LLM** - Airavata is Hindi-only 7B model

### AI4Bharat IndicAlign Dataset Analysis

**Dataset:** `ai4bharat/indic-align`

| Subset | Total Rows | Purpose | Recommendation |
|--------|------------|---------|----------------|
| **Anudesh** | 36,820 | Native instruction-response pairs | ✅ Best for instruction-tuning |
| Dolly_T | ~15,000 | Translated Dolly dataset | Okay but not native |
| Wiki_Chat | 100,000+ | Wikipedia-based conversations | ❌ Not instruction format |
| Flan_Aligned | Large | Translated Flan | Good for diversity |

**Anudesh Structure:**
```python
{
  "interactions": [["user message", "assistant response"], ...],
  "meta": {...}
}
```

**Tamil Content in Anudesh:**
- Total: 36,820 rows (all Indian languages)
- Tamil after filtering: **1,966 rows** (~5.3%)
- Filtering method: Unicode character detection (0x0B80-0x0BFF)

### Decision

> **Strategy:** Fine-tune Sarvam-2B with IndicAlign Anudesh (Tamil) + VAZHI domain data
>
> **Rationale:** Sarvam-2B already knows Tamil vocabulary (trained on 2T tokens of Indian languages).
> It just needs instruction-tuning to follow commands. Use native Tamil instruction data from Anudesh.

---

## v0.6 Training (Current - Sarvam-2B Fine-tuning)

**Date:** 2026-02-07
**Status:** 🔄 Training in Progress
**Base Model:** sarvamai/sarvam-2b-v0.5
**Training Platform:** Kaggle (T4 GPU)

### Why Sarvam-2B?

| Factor | Value |
|--------|-------|
| Pre-training | 2T tokens of 10 Indian languages |
| Tamil knowledge | Already has vocabulary + grammar |
| What's missing | Instruction-following capability |
| Q4_K_M size | ~1.2GB (mobile viable) |

### Training Data

| Source | Items | Purpose |
|--------|-------|---------|
| VAZHI dataset | 11,112 | Domain-specific (Thirukkural, govt, health) |
| IndicAlign Anudesh (Tamil) | 1,966 | Native Tamil instruction pairs |
| **Total** | **13,078** | Combined training set |

### Training Configuration

```python
Base Model: sarvamai/sarvam-2b-v0.5
Quantization: 4-bit (BitsAndBytes) - required for T4 16GB
Precision: bf16 (not fp16 - caused errors with 4-bit)

LoRA Settings:
  rank: 8           # Conservative
  alpha: 16
  target_modules: [q_proj, v_proj]  # Only 2 modules
  dropout: 0.05

Training Settings:
  learning_rate: 1e-5
  epochs: 2
  batch_size: 2
  gradient_accumulation: 8
  max_grad_norm: 0.3
  max_length: 512
  gradient_checkpointing: True
```

### Training Progress

| Step | Loss | Notes |
|------|------|-------|
| 50 | 3.12 | Starting loss |
| 200 | 3.02 | Started decreasing |
| 350 | 2.78 | Good progress |
| 500 | 2.61 | Converging |
| 800 | 2.53 | Stable |
| 1200 | 2.57 | Stable |
| 1450 | 2.49 | Final loss |
| 1636 | ~2.5 | **Training complete** |

**Duration:** ~1.5 hours on Kaggle T4

### Test Results: ❌ COMPLETE FAILURE

Despite stable loss (~2.5), the model output was complete garbage:

```
Q: வணக்கம், நீங்கள் யார்?
A: H celebrated once (' '" - ((- { like - * - Or / (- What States peace...

Q: திருக்குறளின் முதல் குறள் என்ன?
A: கு ( (- - ('"(- / celebrated ' * {< celebrated November celebrated...

Q: தமிழ்நாட்டின் தலைநகரம் எது?
A: க celebrated ( ' - ('(' ' (- William celebrated - November celebrated...
```

**Observed Issues:**
1. Random English words repeated ("celebrated" appears dozens of times)
2. Mixed scripts from multiple Indian languages (Punjabi ਹਾਂ, Odia ନ୍ତି, Gujarati ઓસ્ટ્રે)
3. Random punctuation and symbols
4. No coherent Tamil whatsoever
5. Pattern similar to v0.5 Qwen failure

### Root Cause Analysis

| Factor | Assessment |
|--------|------------|
| 4-bit training | ❌ **Primary cause** - quantization during training corrupts weights |
| Loss stability | Misleading - low loss ≠ working model |
| LoRA settings | r=8 was conservative but still failed with 4-bit |
| Data quality | Not the issue - same data, different failure mode than v0.1-v0.4 |

**Conclusion:** 4-bit quantized training is fundamentally unstable for instruction-tuning. The model learns to minimize loss but the quantized weights cannot represent coherent language patterns.

### Lessons Learned from v0.6

1. **4-bit training doesn't work** - Both Qwen 0.5B and Sarvam 2B failed with 4-bit
2. **Loss is not a reliable metric** - Can have perfect loss but garbage output
3. **Memory constraints force bad tradeoffs** - T4 16GB insufficient for float16 training of 2B models
4. **Need different approach** - Either use pre-quantized models or train on larger GPU

### Decision: Pivot to Pre-trained Tamil Model Quantization Testing

Since training small models has failed repeatedly, try the opposite approach:
- Find **working** pre-trained Tamil models
- Test various quantization levels
- Find the smallest model that produces coherent Tamil

**Notebook:** `notebooks/Vazhi_TamilLLaMA_Quantization.ipynb`

---

## Pre-trained Model Quantization Testing

**Date:** 2026-02-08
**Status:** ✅ Complete
**Platform:** Kaggle

### Models Tested

| Model | Quant | Size | Chennai Test | Tamil Quality | Viable? |
|-------|-------|------|--------------|---------------|---------|
| Tamil-LLaMA 7B | Q4_K_M | 4.18 GB | ✅ சென்னை | ✅✅ Excellent | Too large |
| **Gemma-2B Tamil** | **Q4_K_M** | **1.63 GB** | **✅ சென்னை** | **✅ Good** | **✅ WINNER** |
| Gemma-2B Tamil | Q3_K_M | 1.38 GB | ❌ சென்பா | ⚠️ Degraded | No |
| Gemma-2B Tamil | Q2_K | 1.16 GB | ❌ Repeats | ❌ Broken | No |
| Qwen3-1.7B Tamil | Q4_K_M | 1.11 GB | ❌ Wrong | ⚠️ Inaccurate | Marginal |
| Llama3.2-Tamil-3B | Q2_K | 1.49 GB | ❌ Garbage | ❌ Broken | No |

### Detailed Test Results

**Tamil-LLaMA 7B Q4_K_M (4.18 GB)** - Baseline
```
Q: வணக்கம், நீங்கள் யார்?
A: இந்தக் கோரிக்கையின்படி, பயனரின் அடையாளத்தை அடையாளம் காண்பதே குறிக்கோள்.

Q: தமிழ்நாட்டின் தலைநகரம் எது?
A: தமிழ்நாட்டின் தலைநகரம் சென்னையில்.
```
✅ Coherent Tamil, correct answers, but 4.18 GB too large for mobile target.

**Gemma-2B Tamil Q4_K_M (1.63 GB)** - SELECTED
```
Q: வணக்கம், நீங்கள் யார்?
A: எனது பெயர் ஸ்பீஸ், எனது கட்டுப்பாடுகள் உங்கள் பார்வையில் தோன்றுகின்றன.

Q: தமிழ்நாட்டின் தலைநகரம் எது?
A: தமிழ்நாட்டின் தலைநகரம் சென்னை.
```
✅ Coherent Tamil, Chennai correct, fits mobile target (1.63 GB).

**Gemma-2B Tamil Q3_K_M (1.38 GB)** - Degraded
```
Q: தமிழ்நாட்டின் தலைநகரம் எது?
A: தமிழ்நாட்டின் தலைநகரம் சென்பா.
```
❌ "சென்பா" instead of "சென்னை" - quantization damage visible.

**Qwen3-1.7B Tamil Q4_K_M (1.11 GB)** - Inaccurate
```
Q: தமிழ்நாட்டின் தலைநகரம் எது?
A: தமிழ்நாட்டின் தலைநகரம் நகராட்சி நகரத்தில் அமைந்துள்ளது...
```
❌ Wrong answer, vague response.

### Key Findings

1. **Working pre-trained models beat failed training** - Gemma-2B Tamil at 1.63 GB outperforms all our training attempts
2. **Q4_K_M is the floor** - Going below Q4 causes visible quality degradation
3. **Model architecture matters** - Gemma handles quantization better than Llama3.2 for Tamil
4. **No training needed** - Just download and use the pre-quantized model

### Selected Model

**Gemma-2B Tamil Q4_K_M**
- Source: `RichardErkhov/abhinand_-_gemma-2b-it-tamil-v0.1-alpha-gguf`
- File: `gemma-2b-it-tamil-v0.1-alpha.Q4_K_M.gguf`
- Size: 1.63 GB
- Quality: Good coherent Tamil, basic facts correct

---

## v0.7 Training Run (Gemma-2B Tamil Fine-tuning)

**Date:** 2026-02-08
**Status:** ❌ Failed (GGUF conversion failed due to tokenizer corruption)
**Base Model:** abhinand/gemma-2b-it-tamil-v0.1-alpha (forked to CryptoYogi/gemma-2b-tamil-base)
**Training Platform:** Kaggle (T4/P100 GPU)

### Why Gemma-2B Tamil?

After v0.6's complete failure with 4-bit training, we pivoted to using a pre-trained Tamil-capable model:

| Factor | Value |
|--------|-------|
| Pre-training | Already instruction-tuned for Tamil |
| Tamil quality | Produces coherent Tamil at Q4_K_M |
| Base size | 2B parameters |
| Q4_K_M size | 1.63 GB |
| Tokenizer | Has proper pad_token (ID 0) |

### Model Forking

To ensure long-term stability and not depend on an "alpha" model, we forked the base model:

**Original:** `abhinand/gemma-2b-it-tamil-v0.1-alpha`
**Fork:** `CryptoYogi/gemma-2b-tamil-base`

This gives us control over the base model and prevents issues if the original author modifies or removes it.

### Critical Bug Discovery: Tokenizer Corruption

**The Problem:**
Previous training attempts (notebook166f14a8b5.ipynb) produced garbage output despite reasonable loss values. The model output became gibberish like:
```
Q: வணக்கம், நீங்கள் யார்?
A: !!!!!!!!!!!!!!!!!!!!!!!!!... (infinite repetition)
```

**Root Cause Identified:**
Setting `tokenizer.pad_token = tokenizer.eos_token` corrupted the tokenizer's internal vocabulary structure, causing "OrderedVocab contains holes" warning.

**The Fix:**
```python
# ❌ WRONG - This corrupts the tokenizer
tokenizer.pad_token = tokenizer.eos_token

# ✅ CORRECT - The tokenizer already has a proper pad_token
# Just align the model config with the tokenizer, don't modify tokenizer
model.config.pad_token_id = tokenizer.pad_token_id  # Already 0
model.config.bos_token_id = tokenizer.bos_token_id
model.config.eos_token_id = tokenizer.eos_token_id
```

### Learning Rate Boundary Testing

Tested two learning rates to find optimal training parameters:

| Learning Rate | Loss Start | Loss End | Result |
|---------------|------------|----------|--------|
| 1e-6 | 3.37 | 3.37 | ❌ No learning (too conservative) |
| 5e-5 | 3.39 | 3.00 | ✅ Learning without catastrophic forgetting |

**Key Finding:** 5e-5 with fixed tokenizer produces stable learning where:
- Loss decreases (3.39 → 3.00)
- Model retains coherent Tamil output
- No repetition loops or garbage output

### Training Configuration (Validated)

```python
Base Model: CryptoYogi/gemma-2b-tamil-base
Quantization: 4-bit (BitsAndBytes)
Precision: bf16

LoRA Settings:
  rank: 4           # Very conservative
  alpha: 8
  target_modules: [q_proj, v_proj]  # Only 2 modules
  dropout: 0.05

Training Settings:
  learning_rate: 5e-5
  epochs: 1         # Single pass through data
  batch_size: 2
  gradient_accumulation: 4
  max_grad_norm: 1.0  # Gradient clipping
  max_length: 512
  gradient_checkpointing: True
  bf16: True
```

### Test Run Results (177 steps)

| Step | Loss | Notes |
|------|------|-------|
| 23 | 3.39 | Starting loss |
| 65 | 3.15 | Learning... |
| 100 | 3.08 | Good progress |
| 150 | 3.00 | Converging |
| 177 | ~3.00 | Training complete |

**Output Quality Test:**
```
Q: வணக்கம், நீங்கள் யார்?
A: (Coherent Tamil response - no repetition, no garbage)
```

### Full Training Plan

Now that the test run validated the approach, full training will use:
- All 11K samples from VAZHI dataset
- Same hyperparameters as test run
- Single epoch to prevent overfitting
- Monitor for loss > 3.2 (early stopping threshold)

### Post-Training Pipeline

1. **Upload LoRA adapter** to HuggingFace
2. **Merge adapter** with base model
3. **Upload merged model** to HuggingFace
4. **Convert to GGUF** (Q4_K_M for mobile deployment)
5. **Test on mobile** before release

### Files Created
- Training notebook: `/notebooks/Vazhi_Training_Fixed.ipynb`
- Base model fork notebook: `/notebooks/Vazhi_Fork_Base_Model.ipynb`
- Forked model: `CryptoYogi/gemma-2b-tamil-base` on HuggingFace

### Memory Issues Encountered

1. **Float16 loading OOM** - Sarvam-2B too large for T4 in float16
2. **Solution:** 4-bit quantization with BitsAndBytes
3. **fp16 training error** - BFloat16 model incompatible with fp16 training
4. **Solution:** Changed to bf16=True in trainer config

### Files Created
- Training notebook: `/notebooks/Vazhi_Sarvam2B_Finetune.ipynb`
- Evaluation notebook: `/notebooks/Vazhi_Pretrained_Tamil_Test.ipynb`

### v0.7 GGUF Conversion Failure

Despite successful training (loss 3.39→3.00), GGUF conversion failed:

**Error:**
```
GGML_ASSERT(id_to_token.size() == token_to_id.size()) failed
```

**Root Cause:**
The source model `abhinand/gemma-2b-it-tamil-v0.1-alpha` had a corrupted tokenizer:
- Warning during training: "OrderedVocab contains holes for indices [1, 2]"
- This warning was ignored during training
- The vocabulary corruption made GGUF conversion impossible

**Attempted Fixes:**
1. Replace tokenizer files with clean `google/gemma-2b` tokenizer → Failed (vocab mismatch)
2. Various GGUF conversion flags → Failed (fundamental corruption)
3. Manual tokenizer surgery → Failed (embedding weights tied to corrupted vocab)

**Conclusion:** The base model itself was corrupted. No post-training fix possible.

---

## v0.8 Training Run (Current - Qwen3-0.6B Two-Stage Training)

**Date:** 2026-02-09
**Status:** 🔄 In Progress
**Base Model:** Qwen/Qwen3-0.6B
**Training Platform:** Kaggle (T4 GPU)

### Why Qwen3-0.6B?

After v0.7's GGUF failure and consultation with GPT5.2, pivoted to Qwen3-0.6B:

| Factor | Gemma-2B | Qwen3-0.6B |
|--------|----------|------------|
| Parameters | 2B | 600M |
| Tokenizer | Corrupted | Clean |
| GGUF target | 1.6GB | <1GB |
| Thinking | None | Native `/think` mode |
| Multilingual | Limited | Strong |

### Two-Stage Training Pipeline

**Key Insight:** Single-pass SFT causes either fluency loss OR instruction-following loss.

**Solution:** Two-stage training:

```
┌─────────────────────────────────────────────────────────┐
│ Stage 1: Micro-DAPT (Continued Pretraining)             │
├─────────────────────────────────────────────────────────┤
│ Data: 80% Vazhi outputs + 20% Sangraha Tamil            │
│ Purpose: Boost Tamil fluency without breaking model     │
│ Format: Plain text completion (no chat template)        │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│ Stage 2: SFT (Instruction Tuning)                       │
├─────────────────────────────────────────────────────────┤
│ Data: Full Vazhi Q&A pairs in chat format               │
│ Purpose: Teach instruction-following                    │
│ Loss: Assistant-only masking (user tokens masked)       │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│ Post-Training: Merge + GGUF                             │
├─────────────────────────────────────────────────────────┤
│ 1. Merge LoRA adapters to base model                    │
│ 2. Upload merged model to HuggingFace                   │
│ 3. Convert to GGUF (Q4_K_M)                             │
│ 4. Upload GGUF to HuggingFace Hub                       │
└─────────────────────────────────────────────────────────┘
```

### Training Data

**Micro-DAPT Data:**
| Source | Proportion | Purpose |
|--------|------------|---------|
| Vazhi outputs (Tamil) | 80% | Domain knowledge |
| Sangraha corpus (AI4Bharat) | 20% | Tamil fluency |

**SFT Data:**
| Source | Items | Format |
|--------|-------|--------|
| Vazhi Q&A pairs | 11,112 | Qwen chat template |

### Training Configuration

```python
# Micro-DAPT Stage
model = "Qwen/Qwen3-0.6B"
lora_rank = 16
lora_alpha = 32
target_modules = ["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"]
learning_rate = 2e-4
epochs = 1
max_seq_length = 2048

# SFT Stage (uses Micro-DAPT output as base)
learning_rate = 1e-4
epochs = 2
loss_type = "assistant_only"  # Mask user tokens
```

### Infrastructure Fixes

| Issue | Fix |
|-------|-----|
| CUDA device selection | `os.environ["CUDA_VISIBLE_DEVICES"] = "0"` |
| Tokenizer parallelism | `os.environ["TOKENIZERS_PARALLELISM"] = "false"` |
| T4 precision | `fp16=True` (not bf16, T4 doesn't support bf16 well) |
| Disconnect protection | HF Hub checkpointing every epoch |

### Preflight Fail-Fast System

Before full training, run preflight check:
```python
# 1. Tiny Micro-DAPT: 50 samples, 10 steps
# 2. Tiny SFT: 50 samples, 10 steps
# 3. Merge LoRA
# 4. Generate test output
# 5. If output quality poor → pivot before wasting hours
```

### Training Progress

| Stage | Status | Notes |
|-------|--------|-------|
| Preflight Check | ✅ | Output quality verified |
| Micro-DAPT | 🔄 In Progress | Training on Kaggle |
| SFT | ⏳ Pending | Waiting for DAPT completion |
| Merge + GGUF | ⏳ Pending | Final conversion |

### Expected Outputs

| Format | Expected Size | Use Case |
|--------|---------------|----------|
| F16 | ~1.2GB | Reference |
| Q4_K_M | **<1GB** | **Mobile deployment** |

### Files Created
- Training notebook: `~/Downloads/Vazhi_Qwen3_MicroDAPT_SFT_GGUF_HFHub_KAGGLE_SAFE.ipynb`
- Sangraha data integration: AI4Bharat CC-BY 4.0 corpus

---

## v3.1 Training Run (Failed - Mixed Data Formats)

**Date:** 2026-02-10
**Status:** ❌ Failed
**Base Model:** Qwen/Qwen3-0.6B
**Training Platform:** Kaggle (T4 GPU)

### What We Tried

Attempted to rebalance the dataset to fix Thirukkural distribution skew (71% → 25%):
1. Extracted ~1,050 diverse Tamil Q&A from IndicAlign
2. Added ~47 manual samples
3. Downsampled Thirukkural from existing dataset
4. Merged all samples and trained

### Training Metrics

| Metric | Value |
|--------|-------|
| Total samples | 4,933 |
| Loss start | 3.39 |
| Loss end | ~0.5 |
| Training time | ~1.5 hours |
| Status | ✅ Completed |

### Test Results: ❌ COMPLETE GARBAGE

Despite good loss, model output was completely broken:

```
Q: வணக்கம்
A: 'systemsystemsystemsystemsystemsystemsystem...

Q: தமிழ்நாட்டின் தலைநகரம் என்ன?
A: தஉsystemsystemsystemsystemsystem...

Q: 2+2 என்ன?
A: 4systemsystemsystemsystem...
```

### Root Cause: MIXED DATA FORMATS

**The Critical Mistake:**
The notebook mixed two incompatible data formats in a single SFT training run:

| Source | Format | Count | Issue |
|--------|--------|-------|-------|
| Existing dataset (`vazhi-tamil-v05`) | RAW TEXT | ~3,836 | No ChatML structure |
| IndicAlign + Manual samples | ChatML formatted | ~1,097 | Properly structured |

**Why This Breaks Training:**

The existing dataset contains samples like:
```
யாதும் ஊரே யாவரும் கேளிர்
தீதும் நன்றும் பிறர்தர வாரா...
```
This is raw Sangam poetry with NO instruction/output structure.

The diverse samples were formatted as:
```
<|im_start|>system
நீங்கள் VAZHI...<|im_end|>
<|im_start|>user
தமிழ்நாட்டின் தலைநகரம்?<|im_end|>
<|im_start|>assistant
சென்னை.<|im_end|>
```

When mixed together, the model saw:
- Raw text samples without "system" tags
- ChatML samples WITH "system" tags
- No consistent pattern to learn

Result: Model learned to output "system" repeatedly as a dominant pattern.

### The Fix

**Option A: SFT with ChatML-only data**
```python
# ONLY include samples that have ChatML formatting
def is_chatml_formatted(text):
    return "<|im_start|>" in text and "<|im_end|>" in text

# Filter for SFT
final_samples = [s for s in all_samples if is_chatml_formatted(s["text"])]
```

**Option B: Proper Two-Stage Training**
- Stage 1 (Micro-DAPT): Use raw Tamil text WITHOUT chat template
- Stage 2 (SFT): Use ONLY ChatML-formatted Q&A pairs

### Lessons Learned

1. **NEVER mix data formats in SFT** - All samples must have consistent chat template
2. **Raw text ≠ SFT data** - Raw text belongs in DAPT (continued pretraining), not SFT
3. **Low loss ≠ working model** - Loss can be excellent (0.5) while output is garbage
4. **Verify format consistency** - Check 100% ChatML before training

### Files Updated

- Notebook fix: `/notebooks/Vazhi_SFT_v3_1_Balanced.ipynb` - Added format filtering
- Lessons learned: `/docs/LESSONS_LEARNED.md` - Added Lesson #28

---

## v3.2 Training Run (Failed - fp16 Issues)

**Date:** 2026-02-10
**Status:** ❌ Failed
**Base Model:** Qwen/Qwen3-0.6B (instruct)
**Training Platform:** Kaggle (T4/P100 GPU)

### What We Fixed from v3.1

1. **ChatML-only data** — filtered out all raw text samples from existing dataset
2. **Thirukkural downsampled** — from 71% to ~25% of dataset
3. **Diverse samples added** — ~1,050 from IndicAlign (Dolly_T, WikiHow, Wiki_Conv, OpenAssistant_T) + ~47 manual samples
4. **100% ChatML verification** — `is_chatml_formatted()` check before training
5. **Single GPU forced** — `CUDA_VISIBLE_DEVICES=0` at top of notebook
6. **fp16 training** — for T4 compatibility

### Training Configuration

```python
Base Model: Qwen/Qwen3-0.6B (instruct)
Quantization: 4-bit QLoRA (NF4)
Compute dtype: float16
LoRA: r=16, alpha=32, all 7 modules
Learning Rate: 1e-4
Epochs: 2
Batch: 2 x 8 = 16 effective
Max Length: 512
```

### Result

Training had fp16-related issues on T4. The Qwen3 model has internal bf16 operations that conflict with fp16 AMP training on non-Ampere GPUs. Led to v3.3 with FP32 training mode.

### Dataset Created

`CryptoYogi/vazhi-tamil-sft-v3_2` on HuggingFace — balanced, ChatML-only SFT dataset.

### Files Created
- Notebook: `/notebooks/Vazhi_SFT_v3_2_Fixed.ipynb`

---

## v3.3 Training Run (Failed - Instruct Model Conflict)

**Date:** 2026-02-10
**Status:** ❌ Failed
**Base Model:** Qwen/Qwen3-0.6B (instruct)
**Training Platform:** Kaggle (P100 GPU)

### What We Fixed from v3.2

1. **FP32 training mode** — disabled both fp16 and bf16 flags to work around Qwen3's internal bf16 ops on P100
2. **Reused v3.2's balanced dataset** — `CryptoYogi/vazhi-tamil-sft-v3_3` (same data, new repo for tracking)
3. **SKIP_DATA_PREP logic** — avoids redundant IndicAlign extraction if dataset already exists on HF

### Training Configuration

```python
Base Model: Qwen/Qwen3-0.6B (instruct)
Quantization: 4-bit QLoRA (NF4)
Compute dtype: float16 (model loading), FP32 (training)
fp16: False, bf16: False  # FP32 mode for P100 compatibility
LoRA: r=16, alpha=32, all 7 modules
Learning Rate: 1e-4
Epochs: 2
Batch: 1 x 16 = 16 effective
Max Length: 512
```

### Result: ❌ Failed

Model output was broken — likely producing `<think>` reasoning tokens or nonsensical output.

### Root Cause Analysis

| Factor | Assessment |
|--------|------------|
| `<think>` token conflict | **Primary cause** — Qwen3-0.6B is instruction-tuned with native `/think` reasoning mode. Our ChatML format (`<\|im_start\|>`) conflicted with its native chat template that expects `<think>` blocks |
| Learning rate (1e-4) | **Contributing** — too aggressive for fine-tuning an already instruction-tuned model, causing catastrophic forgetting of the base model's capabilities |
| FP32 training | Not the issue — this was a correct fix for P100 compatibility |

### Key Insight

**Instruct models have their own chat format.** Qwen3-0.6B (instruct) expects:
```
<think>reasoning here</think>
response here
```

When we force ChatML format (`<|im_start|>system/user/assistant<|im_end|>`), it conflicts with the model's training. The model tries to produce `<think>` tokens within our ChatML structure.

**Solution:** Use the **base** model (`Qwen3-0.6B-Base`) which has no pre-existing chat template, so it can cleanly learn our ChatML format.

### Files Created
- Notebook: `/notebooks/Vazhi_SFT_v3_3_Clean.ipynb`
- Dataset: `CryptoYogi/vazhi-tamil-sft-v3_3` on HuggingFace

---

## v3.4 Training Run (Pending - Base Model Approach)

**Date:** 2026-02-11
**Status:** ⏳ Pending (not yet run on Kaggle)
**Base Model:** Qwen/Qwen3-0.6B-**Base** (NOT instruct)
**Training Platform:** Kaggle (P100 GPU)

### Why Base Model?

After v3.3's failure, the key insight is that instruction-tuned models fight against new chat templates. Using the base model:

| Factor | Qwen3-0.6B (instruct) | Qwen3-0.6B-Base |
|--------|----------------------|-----------------|
| Pre-existing chat format | Yes (`<think>` mode) | None |
| ChatML compatibility | Conflicting | Clean slate |
| SFT risk | Catastrophic forgetting | No existing behavior to forget |
| LoRA rank needed | Lower (preserving existing) | Higher (learning from scratch) |

### Training Configuration

```python
Base Model: Qwen/Qwen3-0.6B-Base  # KEY CHANGE
Quantization: 4-bit QLoRA (NF4)
Compute dtype: float16 (model loading), FP32 (training)
fp16: False, bf16: False  # FP32 mode for P100

LoRA: r=32, alpha=64, all 7 modules  # Increased from r=16 for base model
Learning Rate: 2e-5  # MUCH lower: 5x reduction from v3.3's 1e-4
Epochs: 3  # Increased from 2 (base model needs more training)
Batch: 1 x 16 = 16 effective
Max Length: 512

# ChatML special tokens added to tokenizer since base model doesn't have them
special_tokens: ["<|im_start|>", "<|im_end|>"]
```

### Changes from v3.3

| Setting | v3.3 (failed) | v3.4 |
|---------|--------------|------|
| Base Model | Qwen3-0.6B (instruct) | Qwen3-0.6B-**Base** |
| Learning Rate | 1e-4 | 2e-5 |
| Epochs | 2 | 3 |
| LoRA Rank | 16 | 32 |
| Special Tokens | Already present | Added `<\|im_start\|>`, `<\|im_end\|>` |

### Risk Assessment

| Risk | Mitigation |
|------|------------|
| Base model has zero instruction-following | 3 epochs of SFT + higher LoRA rank |
| Adding special tokens changes vocab size | `model.resize_token_embeddings()` called |
| `pad_token = eos_token` in base model | Carefully handled (lesson from v0.7) |
| May need two-stage (DAPT+SFT) | Can fall back to v0.8's two-stage approach if single SFT fails |

### Existing Models to Test First

Before running v3.4, the `Test_Existing_Models.ipynb` notebook tests whether any previously uploaded HF models still work:
- `CryptoYogi/vazhi-qwen3-lora-best` (v0.8 cycle best)
- `CryptoYogi/vazhi-qwen3-lora-cycle-6` (last cycle checkpoint)
- `CryptoYogi/qwen3-0.6b-vazhi` (v3.3 merged)

If any produce coherent Tamil, we can skip v3.4 and continue from that checkpoint.

### Files Created
- Notebook: `/notebooks/Vazhi_SFT_v3_4_Base.ipynb`
- Test notebook: `/notebooks/Test_Existing_Models.ipynb`

---

## v3.5 Training Run (❌ Failed — SFT-Only on Base Model)

**Date:** 2026-02-11
**Status:** ❌ Failed — model outputs code tokens, HTML attributes, and Chinese instead of Tamil
**Base Model:** Qwen/Qwen3-0.6B-**Base** (NOT instruct)
**Training Platform:** Kaggle (P100 GPU)
**HF Model:** `CryptoYogi/vazhi-qwen3-v3_5`
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v3_3` (reused from v3.3)

### What v3.5 Attempted

v3.5 added `DataCollatorForCompletionOnlyLM` to train only on assistant response tokens (completion-only masking). The masking itself worked correctly — preflight checks confirmed system/user tokens were masked with -100 and only assistant tokens were trained.

### Training Configuration

```python
Base Model: Qwen/Qwen3-0.6B-Base
Quantization: 4-bit QLoRA (NF4)
Compute dtype: float16 (model loading), FP32 (training)
fp16: False, bf16: False  # FP32 mode for P100

LoRA: r=32, alpha=64, all 7 modules
Learning Rate: 2e-5
Epochs: 3
Batch: 1 x 16 = 16 effective
Max Length: 1024 (changed from 512 during training session)
Data Collator: DataCollatorForCompletionOnlyLM
```

### Training Loss Curve

Training completed all 795 steps across 3 epochs. Loss curve looked healthy:
```
Step  25: 1.5557    Step 250: 1.1517
Step  50: 1.4887    Step 300: 1.0899
Step 100: 1.3140    Step 375: 1.0561
Step 150: 1.1793    Step 450: 1.0404
Step 200: 1.1577    Step 475: 1.0749
```

### Evaluation Results — COMPLETE FAILURE

Despite healthy loss curve and 12/12 "passing" eval checks, EVERY response was garbage:

```
[GREETING] Q: வணக்கம்
A: _year_that=True_email="#_verified=True_date_group_url_count_role_order...

[FACTUAL] Q: தமிழ்நாட்டின் தலைநகரம் என்ன?
A: \\' />", // The data is not a valid JSON...

[CULTURE] Q: திருக்குறளின் முதல் குறள் என்ன?
A: ":{"type":"object","description":"A few of the most common...

[SAFETY] Q: ஒரு scam message வந்தால் என்ன செய்வது?
A: 「<br /><br />...
```

The model was regurgitating pre-training data — code tokens, HTML attributes, JSON schemas, variable names, Chinese characters. It had NOT learned Tamil at all.

### Root Cause Analysis

**Primary: SFT-only on base model cannot teach a new language.**

Qwen3-0.6B-Base was pre-trained on predominantly code, web content, English, and Chinese. SFT with ~3K Tamil ChatML samples cannot shift the model's language distribution — the Tamil tokens form a tiny fraction of what it learned during pre-training. The model's "default mode" remains code/web/Chinese generation.

**This was a known risk documented in our own lessons.** Lesson #13 states: "Don't use single-pass SFT for language adaptation — Two-stage (DAPT→SFT) preserves fluency AND instructions." We violated our own rule.

**Secondary issues:**
1. **~20-30% of samples triggered "Could not find response key"** — even at max_seq_length=1024 (changed from 512 mid-session), long Tamil samples exceeded the token limit before the `<|im_start|>assistant\n` marker, causing those samples to contribute zero training signal
2. **Eval criteria was useless** — checks for loops, system leaks, think leaks, and empty responses all "passed" because code garbage doesn't match those patterns. No check for Tamil character content or actual response quality
3. **Loss curve was misleading** — loss only computed on assistant tokens that were found; samples where the response template wasn't found were silently skipped
4. **Response template fragility** — `"<|im_start|>assistant\n"` (with newline) tokenizes differently depending on context; GPT5.2 recommends simpler `"<|im_start|>assistant"` without newline

### Critical Mistake: Pivoting Away From What Worked

**v3.3 (instruct model) was producing Tamil with fixable issues:**
- `<think>` tags appeared in output (fixable with token suppression)
- LR 1e-4 was too aggressive (fixable by reducing to 2e-5)
- Responses sometimes used Thirukkural structure (fixable with dataset rebalancing)
- But the output WAS in Tamil — the model had Tamil capability from instruct training

**v3.5 (base model) threw away all Tamil capability** by pivoting to a base model that had never been trained on Tamil conversations. SFT alone was insufficient to create this capability — DAPT was needed first.

The correct approach should have been: **iterate on v3.3's fixable issues** rather than pivot to an untested architecture (SFT-only on base model).

### GPT5.2 Post-Mortem Feedback

1. **Dataset issues:** Some SFT samples had no assistant segment at all (system+user only), contributing zero training signal
2. **Response template mismatch:** `"\n<|im_start|>assistant\n"` with leading newline is fragile — simpler `"<|im_start|>assistant"` is more robust
3. **No strict ChatML validation:** Need regex-based validator ensuring ALL samples have both user AND assistant with non-empty content
4. **Base model + chat tags = poor signal:** Base model doesn't "expect" ChatML tags, so even correctly masked training provides weak learning signal
5. **Recommended fix:** Two-stage Micro-DAPT (raw Tamil text) → SFT (strict ChatML), OR return to instruct model with `<think>` suppression

### Lessons Added

- **#40**: SFT-only on a base model CANNOT teach a new language — DAPT is required first
- **#41**: Iterate on working approaches — v3.3 produced Tamil with fixable issues; pivoting to base model was a regression
- **#42**: Eval must check output QUALITY, not just pattern absence — add Tamil character % check and coherence scoring
- **#43**: A healthy loss curve does NOT mean the model learned — always test actual output
- **#44**: Strict ChatML validation (regex) before training — reject samples missing user or assistant segments

### Files
- Notebook: `/notebooks/Vazhi_SFT_v3_5_Masked.ipynb`
- HF Model: `CryptoYogi/vazhi-qwen3-v3_5` (garbage output — do not use)

---

## v3.6 Training Run (FAILED — LoRA Merge to 4-bit Corruption)

**Date:** 2026-02-12
**Status:** ❌ Failed
**Base Model:** Qwen/Qwen3-0.6B (INSTRUCT — NOT Base)
**Training Platform:** Kaggle (P100 GPU)
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v3_6` (3,667 samples)
**Output Model:** `CryptoYogi/vazhi-qwen3-v3_6` (garbage — do not use)

### What Went Right

Everything up to and including training was correct:

1. **Dataset construction** — 3,667 samples, 100% strict ChatML validated, 15% Kural, 31.7% short (<400 chars), 10 refusal + 16 brevity + 7 greeting samples
2. **Tokenizer** — ChatML tokens verified, `<think>` token IDs [151667, 151668] found for suppression
3. **Preflight masking** — 20/20 samples passed, 35.5% trainable tokens (system/user properly masked)
4. **Training completed** — all steps finished, model saved, LoRA adapter saved at `/kaggle/working/vazhi-v3_6-final`

### What Went Wrong: LoRA Merge to 4-bit

After training completed, the merge step `model.merge_and_unload()` was called on the **4-bit quantized model**. PEFT issued an explicit warning:

```
UserWarning: Merge lora module to 4-bit linear may get different generations due to rounding errors.
```

This corrupted the model weights. The merge process dequantizes 4-bit weights → adds LoRA delta → but the dequantized 4-bit weights have massive precision loss, making the sum unrecoverable. The result: **completely corrupted weight matrices**.

### Secondary Issue: Gradient Checkpointing During Eval

The eval code set `merged_model.config.use_cache = True`, but gradient checkpointing from training was still active:

```
`use_cache=True` is incompatible with gradient checkpointing. Setting `use_cache=False`.
Caching is incompatible with gradient checkpointing in Qwen3DecoderLayer. Setting past_key_values=None.
```

This forced generation to run **without KV cache** — slow but shouldn't produce garbage by itself. The merge corruption is the primary cause.

### Eval Output (0/12 passed, 0% Tamil)

Every single response was random punctuation, operators, and fragments:

```
Q: வணக்கம்
A: ooks = 1)0]:,. is:.. = *="-1., of,..... to:..... =;.1.2],..:,): +_t =="):

Q: தமிழ்நாட்டின் தலைநகரம் என்ன?
A: ooks...............................................................................

Q: திருக்குறளின் முதல் குறள் என்ன?
A: دي:, =) =="0},.. is], -:)) == * =_ =_t))] = to._->1......

Q: ஒரு scam message வந்தால் என்ன செய்வது?
A: ooks,.:,0 =="-..) is, 0].:.00)、:.1..0 of.0.1.,.1],..)=:..2.}
```

This output pattern differs from both v3.5 (code tokens/HTML) and v3.3 (Tamil with `<think>`). The random punctuation/operators pattern is characteristic of **corrupted weight matrices** — the model can no longer form coherent token sequences.

### Training Configuration (Was Correct)

```python
Base Model: Qwen/Qwen3-0.6B      # INSTRUCT (has Tamil + instruction-following)
Quantization: 4-bit QLoRA (NF4)
Compute dtype: float16 (model loading), FP32 (training)
fp16: False, bf16: False          # FP32 mode for P100

LoRA: r=16, alpha=32, all 7 modules
Learning Rate: 2e-5
Epochs: 3
Batch: 1 x 16 = 16 effective
Max Length: 1024
Save Steps: 50
Data Collator: DataCollatorForCompletionOnlyLM
Response Template: "<|im_start|>assistant\n" [151644, 77091, 198]
```

### Root Cause: Merging LoRA into 4-bit is Destructive

The 4-bit NF4 quantization reduces each weight from float16 (16 bits) to 4 bits, losing 75% of precision. When LoRA delta (trained in float16) is added to the dequantized 4-bit weights, the resulting values cannot be accurately represented. The model effectively becomes random noise.

**The fix:** After training, save the LoRA adapter separately. Then load the base model fresh in **fp16 (NOT 4-bit)**, apply the LoRA adapter, and merge in full precision. Qwen3-0.6B in fp16 is ~1.5GB — easily fits on P100's 16GB alongside the adapter.

### Loss Curve: Unknown

The training progress was rendered as `<IPython.core.display.HTML object>` (widget) and not captured as text in the notebook output. We cannot confirm whether training actually converged or what the final loss was. v3.7 must log loss values as text.

### Files
- Notebook: `/notebooks/Vazhi_SFT_v3_6_Instruct.ipynb`
- Kaggle output: `~/Downloads/vazhi-sft-v3-6-instruct.ipynb`

---

## v3.7 Training Run (Pending — Fix LoRA Merge)

**Date:** 2026-02-12
**Status:** ⏳ Pending
**Base Model:** Qwen/Qwen3-0.6B (INSTRUCT)
**Training Platform:** Kaggle (P100 GPU)
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v3_6` (reuse — the dataset was fine)
**Output Model:** `CryptoYogi/vazhi-qwen3-v3_7`

### Changes from v3.6

v3.6's dataset, training setup, and masking were all correct. Only the post-training merge/eval needs fixing:

1. **LoRA merge in fp16** — after training, save LoRA adapter → delete 4-bit model from GPU → reload base in fp16 → load adapter → merge in fp16 → eval and push
2. **Disable gradient checkpointing before eval** — call `model.gradient_checkpointing_disable()` before generation
3. **Text-based loss logging** — add `TrainerCallback` to print loss values as text (not just HTML widget) so we can verify training convergence from notebook output
4. **Quick sanity check** — eval the PeftModel BEFORE merge to verify it works, then merge and eval again

### Training Configuration (Same as v3.6)

```python
Base Model: Qwen/Qwen3-0.6B      # INSTRUCT
Quantization: 4-bit QLoRA (NF4)   # For training memory only
LoRA: r=16, alpha=32, all 7 modules
Learning Rate: 2e-5
Epochs: 3
Batch: 1 x 16 = 16 effective
Max Length: 1024
Data Collator: DataCollatorForCompletionOnlyLM
```

### Post-Training Fix (Critical)

```python
# 1. Save LoRA adapter (NOT the merged model)
trainer.save_model("/kaggle/working/vazhi-v3_7-lora")

# 2. Free 4-bit training model
del model, trainer
torch.cuda.empty_cache()

# 3. Reload base model in FP16 (NOT 4-bit!)
base_model = AutoModelForCausalLM.from_pretrained(
    BASE_MODEL, torch_dtype=torch.float16, device_map={"":0}
)

# 4. Load LoRA adapter onto fp16 model
from peft import PeftModel
model = PeftModel.from_pretrained(base_model, "/kaggle/working/vazhi-v3_7-lora")

# 5. Merge in full precision — NO rounding errors!
merged_model = model.merge_and_unload()

# 6. Disable gradient checkpointing for eval
merged_model.gradient_checkpointing_disable()
merged_model.config.use_cache = True
```

### Files
- Notebook: `/notebooks/Vazhi_SFT_v3_7_MergeFix.ipynb`
- **Status:** ⏸️ Superseded by v3.8 (which uses Dataset Factory v4.0 output instead of v3.6 dataset)

---

## v3.8 Training Run (Failed — SFT-only, No DAPT)

**Date:** 2026-02-12
**Status:** ❌ Failed
**Base Model:** Qwen/Qwen3-0.6B (INSTRUCT)
**Training Platform:** Kaggle (P100 GPU)
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v4_0` (3,365 samples from Dataset Factory v4.0)
**Output Model:** Not uploaded (failed)

### What Changed from v3.7

1. **New dataset** — Dataset Factory v4.0 output with composition enforcement:
   - 45% domain packs (vazhi-packs), 30% IndicAlign, 15% Kural interpretive, 3% handcrafted, 7% general
   - Anti-memorization filter for verbatim Thirukkural Q&As
   - Strict ChatML validation, dedup, length filter
2. **fp16 LoRA merge** — fixed from v3.6 (merge in fp16, not 4-bit)
3. **Gradient checkpointing disabled before eval**
4. **Text-based loss logging**

### Results: 0/12 Eval Passed

| Metric | Value |
|--------|-------|
| Eval pass rate | 0/12 (0%) |
| Avg Tamil char % | 52% |
| `<think>` token leaking | Yes |
| Content quality | Gibberish — not coherent Tamil |
| Loss curve | Converged (low loss) but misleading |

### Root Cause Analysis

**SFT alone cannot teach Tamil to a model that doesn't know it.** The Qwen3-0.6B instruct model was pre-trained on English/Chinese/code — it has minimal Tamil capability. ~3,365 SFT samples are not enough to teach a new language. The model learned to produce tokens that minimize loss on the response template but never learned Tamil as a language.

This confirms lesson #21: "SFT-only CANNOT teach a new language — you MUST do DAPT first."

### Decision: Pivot to DAPT-First Architecture

After 13 failed training attempts across 5 base models, the pattern is clear:
- **Instruct models** (v3.1-v3.3, v3.6, v3.8): Have instruction-following but no Tamil → SFT produces Tamil-shaped gibberish
- **Base models** (v3.5): Have neither Tamil nor instruction-following → SFT produces code garbage
- **Missing piece:** DAPT stage to teach Tamil fluency BEFORE SFT

**New training architecture (3-step):**
1. **DAPT** — Train Qwen3-0.6B-Base on 30M tokens of raw Tamil text (Sangraha corpus) → produces `CryptoYogi/qwen3-0.6b-tamil`
2. **SFT** — Fine-tune the Tamil-adapted model on curated ChatML dataset (v4.0) → produces `CryptoYogi/vazhi-qwen3-v4_0`
3. **GGUF** — Quantize to Q4_K_M for mobile deployment

### Files
- Dataset Factory notebook: `/notebooks/Vazhi_Dataset_Factory_v4_0.ipynb`
- v3.8 was run using v3.7 notebook with v4.0 dataset

---

## DAPT v1.0 Training Run (Complete — Tamil Base Model)

**Date:** 2026-02-12
**Status:** ✅ Complete
**Base Model:** Qwen/Qwen3-0.6B-Base (NOT instruct — per GPT5.2 review)
**Training Platform:** Kaggle (GPU for training; CPU for data prep)
**Corpus:** AI4Bharat Sangraha `verified/tam` split (~290K+ docs, ~724M+ chars)
**Output Model:** `CryptoYogi/qwen3-0.6b-tamil` (reusable Tamil base for all future SFT)

### Architecture: Separated Data Prep + Training

**Key insight:** If DAPT training fails, we should NOT have to redo data preparation. The pipeline is split into two independent notebooks:

#### Notebook 1: Data Prep (CPU-only)
- **File:** `/notebooks/Vazhi_DAPT_Data_v1_0.ipynb`
- **Runs on:** Local Mac, Kaggle CPU, or Colab CPU — no GPU needed
- **Input:** Streams `ai4bharat/sangraha` verified/tam split
- **Processing:** Filter (Tamil >= 50%, 200-8000 chars, dedup, repetition check) → tokenize → pack into 1024-token blocks → train/val split
- **Output:** `CryptoYogi/vazhi-dapt-tamil-v1_0` on HuggingFace (pre-tokenized, ready for training)
- **Token target:** 30M tokens (sweet spot for 0.6B model)

#### Notebook 2: DAPT Training (GPU)
- **File:** `/notebooks/Vazhi_DAPT_v1_0_Tamil.ipynb`
- **Runs on:** Kaggle P100 GPU
- **Input:** Loads pre-built dataset from HF (`CryptoYogi/vazhi-dapt-tamil-v1_0`)
- **Training:** QLoRA r=16 alpha=32, LR 2e-5, batch 4 × grad_accum 8 = effective 32, max 2 epochs, token budget 30M
- **Output:** Adapter backup (`CryptoYogi/qwen3-0.6b-tamil-lora`) + merged fp16 model (`CryptoYogi/qwen3-0.6b-tamil`)

### GPT5.2 Review: 9 Critical Fixes Incorporated

1. **Use Base model, not Instruct** — cleaner DAPT without washing out chat behavior
2. **Measure actual tokens with tokenizer** — not estimate from chars (Tamil has 3-4x overhead)
3. **Token budget, not epochs** — control training by target tokens and max_steps
4. **r=16 not r=32** — smaller rank sufficient for DAPT, less risk of catastrophic forgetting
5. **Pack sequences** — concatenate docs into continuous token stream, split into 1024 blocks (no padding waste)
6. **Filter Sangraha** — Tamil% >= 50%, dedup, length 200-8000, repetition ratio < 0.5
7. **Real eval harness** — 8 Tamil text continuation prompts testing Tamil%, uniqueness, repetition, code detection
8. **Validate v3.6+v4.0 combined dataset** — ensure SFT dataset is compatible with DAPT-adapted model
9. **Save adapter separately** — backup LoRA adapter before merge

### Sangraha Corpus Verification

Verified all three Sangraha configs to avoid IndicAlign-style schema surprises:
- `verified/tam`: columns `['doc_id', 'type', 'text']` — `text` is plain string
- `unverified/tam`: columns `['doc_id', 'text']` — same structure
- `synthetic/tam_Taml`: columns `['doc_id', 'text']` — same structure

Quality analysis of 500 verified Tamil docs:
- Tamil char % range: 51-94% (median 85%)
- Doc types: web (88.6%), pdf (10.8%), speech (0.6%)
- No HTML, no empty docs, only 4.6% over 8000 chars
- Very clean data — filters are appropriate

### Training Results

**Data prep (CPU — Colab):**
- Corpus: Sangraha `verified/tam` split
- Filtered: 16,450 docs kept (Tamil >= 40%, 200-8000 chars, dedup, repetition < 0.5)
- Packed: 32,244 blocks of 1024 tokens (31,599 train / 645 val)
- Total tokens: ~33M available, ~16M trained on (375 steps × 32,768 tokens/step)

**Training (GPU — Kaggle T4x2, single GPU used):**
- fp16 (no 4-bit quantization — 0.6B model fits in 1.2GB fp16)
- LoRA r=16, alpha=32, 7 target modules, dropout 0.05
- Batch 4, grad accum 8, effective batch 32
- LR 2e-5, cosine decay, 5% warmup
- Gradient checkpointing enabled (required for T4 15GB with Qwen3's 151K vocab)
- 375/500 steps completed (~3.5 hours, stopped early due to Kaggle compute quota)

| Eval Step | Train Loss | Val Loss | Perplexity |
|-----------|-----------|---------|------------|
| 62 | 1.0596 | 1.0449 | 2.8 |
| 124 | 1.0442 | 1.0338 | 2.8 |
| 186 | 1.0428 | 1.0257 | 2.8 |
| 248 | 1.0424 | 1.0197 | 2.8 |
| 310 | 1.0273 | 1.0155 | 2.8 |

**Eval (8 Tamil text continuation prompts):**
- 8/8 passed (no empty, no code, no repetition loops)
- Avg Tamil%: 66%
- Avg unique word ratio: 97%
- Model generates coherent Tamil prose continuations (expected for base model, not instruction-following)

**Key issues resolved during training:**
- 4-bit quantization bypassed Tensor Cores → removed, loaded fp16 directly
- Batch 8 OOM'd due to Qwen3's 151K vocab logits tensor → reduced to batch 4
- `total_mem` AttributeError → fixed to `total_memory`
- `eval_ppl` NameError (cosmetic) — variable was in interrupted training cell

**Artifacts uploaded to HuggingFace:**
- Merged fp16 model: `CryptoYogi/qwen3-0.6b-tamil`
- LoRA adapter backup: `CryptoYogi/qwen3-0.6b-tamil-lora`

### What Happens After DAPT

The DAPT-adapted model (`CryptoYogi/qwen3-0.6b-tamil`) becomes the permanent base for SFT:
- **Reusable:** One DAPT run, unlimited SFT iterations
- **SFT uses v4.0 dataset** from Dataset Factory (1,514 samples: 1,365 train / 149 eval)
- **SFT notebook:** `Vazhi_SFT_v4_0_OnDAPT.ipynb` (loads DAPT v1.1 model, LoRA r=16, completion-only masking)
- **Incremental DAPT (optional):** Can load this model as base and train on remaining ~17M tokens in a future session

---

## DAPT v1.1 Training Run (Complete — Tamil Instruct Model)

**Date:** 2026-02-13
**Status:** ✅ Complete
**Base Model:** Qwen/Qwen3-0.6B (INSTRUCT — reversed v1.0's decision to use Base)
**Training Platform:** Kaggle T4 x2 (dual GPU via DataParallel)
**Corpus:** AI4Bharat Sangraha `verified/tam` — NFKC normalized, Tamil >= 70%, 55M tokens
**Output Model:** `CryptoYogi/qwen3-0.6b-tamil-v1_1` (reusable Tamil instruct base for SFT)

### Why v1.1? (What v1.0 got wrong)

v1.0 used the **Base** model per GPT5.2's recommendation. However, the side-by-side comparison showed DAPT v1.0 produced **-2% Tamil** compared to vanilla Base — DAPT didn't help. Multi-agent review identified the root cause: Base model has zero Tamil knowledge to build on, so 16M tokens of DAPT wasn't enough to bootstrap Tamil from scratch.

v1.1 switches to **Instruct** model because:
- Instruct model already has *some* Tamil capability (from multilingual pretraining)
- DAPT deepens existing fluency rather than building from zero
- Chat behaviors are preserved (important for SFT stage)
- `<think>` tokens from Qwen3 instruct are suppressed during generation only

### Key Changes from v1.0

| Dimension | v1.0 | v1.1 |
|-----------|------|------|
| Model | Qwen3-0.6B-**Base** | Qwen3-0.6B (**Instruct**) |
| Data | 16M tokens, Tamil >= 50% | **55M tokens**, Tamil >= 70%, NFKC |
| Normalization | None | **NFKC** (fixes \ufffd corruption) |
| Docs/Blocks | ~16K / 31,599 | 27,105 / **52,664** |
| LR | 2e-5 | **5e-5** (2.5x higher) |
| GPUs | T4 x1 (single GPU used) | **T4 x2** (DataParallel) |
| Steps | 375/500 (quota limit) | **1,645** (full epoch) |
| Training time | ~3.5h | **~9.7h** |
| Eval | Tamil char% only | Char% + **word%** + perplexity + comparison |
| `<think>` handling | N/A (base model) | Suppressed via `bad_words_ids` |

### Critical Bug Fixed: device_map Prevents DataParallel

v1.0 used `device_map={"":0}` when loading the model. This sets `model.hf_device_map`, which makes HuggingFace Trainer set `is_model_parallel = True` and **skip DataParallel wrapping** — confirmed by v1.0's Trainer output: "The model is already on multiple devices. Skipping..."

v1.1 fix: Load model without `device_map`, manually `.to("cuda:0")`, then Trainer properly wraps with DataParallel across both GPUs. Added runtime check: `hf_device_map present: False`.

### Training Results

**Data prep (CPU — Colab, `Vazhi_DAPT_Data_v1_1.ipynb`):**
- Corpus: Sangraha `verified/tam` only (93% keep rate — highest quality)
- NFKC normalized, \ufffd stripped, zero-width chars removed
- Filtered: 27,105 docs (Tamil >= 70%, 200-8000 chars, dedup, repetition < 0.5)
- Packed: 53,739 blocks → 52,664 train / 1,075 val
- Total tokens: ~55M (110% of 50M budget)
- Quality check: 0/500 \ufffd, 0/500 zero-width chars, Tamil% min=71% median=86%

**Training (GPU — Kaggle T4 x2):**
- fp16 (no 4-bit — 0.6B fits in 1.1GB fp16)
- LoRA r=16, alpha=32, 7 target modules, dropout 0.05
- Batch 4 × 2 GPUs × grad_accum 4 = effective batch 32
- LR 5e-5, cosine decay, 5% warmup
- 1,645 steps (full 1 epoch), ~9.7 hours

| Eval Step | Train Loss | Val Loss | Perplexity |
|-----------|-----------|---------|------------|
| 164 | 1.1001 | 1.0950 | 3.0 |
| 328 | 1.0433 | 1.0465 | 2.8 |
| 492 | 1.0289 | 1.0212 | 2.8 |
| 656 | 1.0067 | 1.0039 | 2.7 |
| 820 | 0.9876 | 0.9920 | 2.7 |
| 984 | 0.9969 | 0.9831 | 2.7 |
| 1148 | 0.9812 | 0.9767 | 2.7 |
| 1312 | 0.9817 | 0.9729 | 2.6 |
| 1476 | 0.9627 | 0.9710 | 2.6 |
| Final | 0.9638 | 0.9707 | 2.6 |

**Summary:** Train loss 1.4268 → 0.9638 (-32.5%), Eval loss 1.0950 → 0.9707 (-11.4%), no overfitting.

**Generation eval (8 Tamil prompts, `<think>` suppressed):**
- 7/8 passed (1 empty response for Pongal prompt)
- Avg Tamil char%: 59%
- Avg Tamil word%: 66%
- Avg unique word ratio: 88%
- No code generation, no repetition loops, no `<think>` leaking

**Side-by-side: DAPT v1.1 vs Vanilla Instruct:**

| Metric | Vanilla Instruct | DAPT v1.1 | Change |
|--------|-----------------|-----------|--------|
| Avg Tamil char% | 4% | 59% | **+55%** |
| Avg Tamil word% | 3% | 66% | **+63%** |
| Wins (word%) | 1/8 | **7/8** | |

Vanilla instruct produced mostly English, math problems, and Telugu/Hindi gibberish for Tamil prompts. DAPT v1.1 produces actual Tamil text. This is the first DAPT run that shows clear improvement over the base model.

**Note:** Tamil output is fluent but not coherent — DAPT teaches language fluency, not instruction-following. Coherence comes from SFT (Step 3).

### Artifacts

- Merged fp16 model: `CryptoYogi/qwen3-0.6b-tamil-v1_1`
- LoRA adapter backup: `CryptoYogi/qwen3-0.6b-tamil-v1_1-lora`
- DAPT dataset: `CryptoYogi/vazhi-dapt-tamil-v1_1`

### Next Step: SFT

```python
BASE_MODEL = "CryptoYogi/qwen3-0.6b-tamil-v1_1"  # DAPT'd instruct model
DATASET = "CryptoYogi/vazhi-tamil-sft-v4_0"       # 1,514 ChatML samples (1,365 train / 149 eval)
```

---

## SFT v4.0 Training Run (Failed — Gibberish Content)

**Date:** 2026-02-13
**Status:** ❌ Failed
**Base Model:** `CryptoYogi/qwen3-0.6b-tamil-v1_1` (DAPT v1.1 Tamil instruct model)
**Training Platform:** Kaggle T4 x2
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v4_0` (1,514 samples: 1,365 train / 149 eval)
**Output Model:** `CryptoYogi/vazhi-v4_0` (merged fp16)
**Adapter:** `CryptoYogi/vazhi-v4_0-lora`

### Training Config

```python
BASE_MODEL = "CryptoYogi/qwen3-0.6b-tamil-v1_1"
DATASET = "CryptoYogi/vazhi-tamil-sft-v4_0"
LORA_R = 16, LORA_ALPHA = 32
TARGET_MODULES = ["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"]
LR = 2e-5, EPOCHS = 3, BATCH = 4 × 2 GPUs × 2 grad_accum = 16 effective
MAX_SEQ_LENGTH = 1024
```

### Training Metrics (Healthy — Not the Problem)

| Epoch | Train Loss | Eval Loss |
|-------|-----------|----------|
| 1 | 1.212 | 1.328 |
| 2 | 1.068 | 1.249 |
| 3 | 1.030 | 1.230 |

Final: train_loss 1.174, eval_loss 1.230. Loss curve looks healthy — steady decline, no overfitting spike.

### Eval Results — 12/12 "Passed" Automated Checks, BUT Content is Gibberish

**Think suppression issue:** `suppress_tokens` kwarg in `generate()` broken in transformers 2.8.0. Custom `SuppressThinkTokens` LogitsProcessor also failed due to model's `generation_config.suppress_tokens` injecting the buggy built-in processor. `strip_think_tags()` fallback worked. Think tokens leaked in all 12/12 raw outputs but were stripped.

**Automated metrics (misleading):** 12/12 passed, avg Tamil 61%, avg repeat 0.00

**Actual content quality (manual review):**

| Prompt | Response | Verdict |
|--------|----------|---------|
| வணக்கம் (Hello) | "objects, price, price application" | Gibberish |
| நீங்கள் யார்? (Who are you?) | Random prices + "Annasappu" | Gibberish |
| TN Capital? | "தமிஞ்சான் திருவிழா" (not a real word) | Wrong |
| Pongal? | "1800 commodity cooperation" | Gibberish |
| 2+2? | "2 + 2 = 4" | **Correct** |
| திருவள்ளுவர் யார்? | "1803 அண்ணாயிரசின் 295" | Gibberish |
| Scam message? | Hallucinated phone number + email | **Dangerous** |
| Fire safety? | Random percentages | Gibberish |
| Stock market? | Random 2024 reference | Gibberish |
| Breakfast? | Random gibberish list | Gibberish |

**Only 1/12 factually correct (2+2=4). Content is fluent-looking Tamil gibberish.**

### Side-by-Side Comparison

| Model | Avg Tamil % | Quality |
|-------|------------|---------|
| Vanilla (Qwen3-0.6B) | 75% | Short/unhelpful but not gibberish |
| DAPT v1.1 | 89% | Fluent Tamil text continuation (no instruction following) |
| SFT v4.0 | 81% | Tamil gibberish with formatting artifacts |

**Diagnosis: DAPT > SFT > Vanilla** = SFT partially degraded DAPT's Tamil fluency without teaching useful instruction-following.

### Root Cause Analysis

1. **1,365 SFT samples insufficient** — Teaching a DAPT'd model both chat format AND task quality requires more data
2. **LoRA r=16 with 7 target modules is overparameterized** — Too many trainable parameters for small dataset = overfitting to surface patterns
3. **3 epochs too many** — Model learned to produce Tamil-looking text but overfit on token patterns, not semantics
4. **`<think>` suppression failure** — Model generates `<think>` tokens first, conditioning the rest of generation on thinking-mode context even after stripping

### Lessons for Next Iteration

See "Mistakes to Avoid" #33-35 (added from this run).

### Notebooks

- SFT training: `notebooks/Vazhi_SFT_v4_0_OnDAPT.ipynb`
- Eval (standalone): `notebooks/Vazhi_Eval_v4_0.ipynb`

---

## SFT v4.1 Training Run (FAILED — DAPT Destroyed Instruction-Following)

**Date:** 2026-02-13
**Status:** ❌ Failed
**Base Model:** `CryptoYogi/qwen3-0.6b-tamil-v1_1` (DAPT v1.1 Tamil instruct model)
**Training Platform:** Colab Pro L4 (22GB VRAM)
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v4_1` (14,535 samples: 13,083 train / 1,452 eval)
**Output Model:** `CryptoYogi/vazhi-v4_1` (merged fp16)
**Adapter:** `CryptoYogi/vazhi-v4_1-lora`
**Notebook:** `notebooks/Vazhi_SFT_v4_1_OnDAPT.ipynb`

### What Changed from v4.0

| Parameter | v4.0 (FAILED) | v4.1 |
|-----------|---------------|------|
| Train samples | 1,365 | **13,083** (10x) |
| LoRA r | 16 | **8** |
| Target modules | 7 (all proj) | **2 (q_proj, v_proj)** |
| Epochs | 3 | **2** |
| LR | 2e-5 | **5e-5** |
| max_seq_length | 1024 | **2048** |
| GPU | Kaggle T4 x2 | **Colab Pro L4** |
| Dtype | fp16 | **bf16 (auto-detected)** |
| Think suppression | suppress_tokens kwarg (broken) | **Custom LogitsProcessor** |
| Eval | Tamil % only (false positives) | **Conversational quality (fluency, intent, no hallucinations)** |
| Hub checkpoint | No | **Yes (every save_steps)** |
| Mid-training checks | No | **Yes (gen check at each eval step)** |

### Training Config

```python
DAPT_MODEL = "CryptoYogi/qwen3-0.6b-tamil-v1_1"
SFT_DATASET = "CryptoYogi/vazhi-tamil-sft-v4_1"
LORA_R = 8, LORA_ALPHA = 16
TARGET_MODULES = ["q_proj", "v_proj"]
LR = 5e-5, EPOCHS = 2, BATCH = 4 × 1 GPU × 2 grad_accum = 8 effective
MAX_SEQ_LENGTH = 2048
```

### Key Improvements Over v4.0

1. **10x more training data** — 13,083 vs 1,365 samples, from 3-stage Dataset Factory v4.1.3
2. **Conservative LoRA** — r=8 on q_proj+v_proj only (was r=16 on 7 modules). Prevents overparameterization
3. **2 epochs** — Reduced from 3 to prevent memorization
4. **max_seq_length=2048** — v4.0's 1024 rejected 74% of domain packs due to system prompt overhead
5. **Mid-training generation checks** — `MidTrainingGenCheck` callback generates actual Tamil responses at each eval step. Tests greeting, factual (capital of TN → must contain சென்னை), and math (2+2 → must contain 4). Catches gibberish during training, not after
6. **Conversational quality eval** — 16 prompts testing Tamil fluency, instruction-following, appropriate tone, safety (no hallucinated contacts), and identity recognition. NOT factual recall (handled by hybrid SQLite layer). Pass: overall >= 60%, avg Tamil > 30%, avg repeat < 0.15, no hallucinated contact info
7. **Hub checkpointing** — `push_to_hub=True, hub_strategy="every_save"` for Colab disconnect protection
8. **Custom LogitsProcessor** — `SuppressThinkTokens` class suppresses `<think>` token IDs (151667, 151668) instead of broken `suppress_tokens` kwarg

### Expected Metrics

| Metric | v4.0 (overfit) | v4.1 (expected) |
|--------|----------------|-----------------|
| Starting loss | 1.43 | ~1.3-1.5 |
| Final loss | 1.03 | ~1.1-1.3 (higher = healthier) |
| Eval loss | 1.23 | ~1.2-1.4 |
| Train/eval gap | 0.20 | <0.15 |
| Steps | ~255 | ~3,270 |
| Runtime | <1 hour | ~30-45 min on L4 |

### Abort Conditions

| Condition | When | Action |
|-----------|------|--------|
| DAPT PPL > vanilla | Pre-SFT | Hard abort — DAPT damaged |
| Loss not decreasing after 200 steps | Training | Stop, check config |
| Loss < 0.5 | Training | Stop, overfitting |
| Eval loss increase > 0.2 | Post-training | Possible overfit |
| VRAM > 90% | Preflight | Reduce batch to 2 |
| Conv quality < 60% | Eval | SFT failed |
| Safety hallucinations | Eval | Needs more safety refusal data |
| Mid-training gen check all garbage | Training | Stop early, investigate |

### Actual Training Results

- **Train loss:** 0.93 → 0.79 (15% drop)
- **Eval loss:** 0.90 → 0.86 (stable, gap < 0.15)
- **Steps completed:** 3068/3272 (94% — session restart lost remaining steps)
- **Hub checkpoint:** Only step 1635 saved (1 epoch). Merged model from 1-epoch checkpoint
- **Mid-training gen checks:** ALL GARBAGE at all checkpoints (steps 817, 1634, 2451)
- **Eval:** 16/16 "passed" — **FALSE POSITIVE**. All responses were Tamil word soup that passed automated metrics (high Tamil %, zero repetition) but had zero semantic meaning

### Root Cause Analysis

**DAPT v1.1 destroyed instruction-following capability.** Diagnostic comparison:

| Prompt | Vanilla Qwen3-0.6B | DAPT v1.1 |
|--------|---------------------|-----------|
| வணக்கம் | Correct Tamil greeting | Gibberish/echo |
| நன்றி | Appropriate acknowledgment | Repetitive loops |
| காலையில் என்ன சாப்பிடலாம்? | "தெரியவில்லை" (per system prompt) | Tamil word soup |

**Why DAPT damaged the model (per GPT5.2 analysis):**
- LR 5e-5 too aggressive for DAPT on instruct model
- Full epoch over 55M tokens too much raw text continuation
- LoRA r=16 amplified the shift
- Raw text next-token prediction overwrote chat/instruction behaviors

**Fix (for future DAPT):** Instruction-preserving DAPT — lower LR (1-2e-5), smaller token budget (5-15M), and 5-15% chat data replay during DAPT.

### Decision

Skip DAPT. Proceed with SFT v4.2 on vanilla Qwen3-0.6B instruct (instruction-following intact).
If v4.2 works but Tamil is weak → instruction-preserving DAPT, then re-SFT.

---

## SFT v4.2 Training Run (FAILED — SFT Catastrophically Forgot Tamil)

**Date:** 2026-02-13
**Status:** ❌ Failed — 4th consecutive false positive eval
**Base Model:** `Qwen/Qwen3-0.6B` (vanilla instruct — DAPT skipped)
**Training Platform:** Colab Pro L4 (22GB VRAM)
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v4_1` (14,535 samples: 13,083 train / 1,452 eval)
**Output Model:** `CryptoYogi/vazhi-v4_2` (merged fp16)
**Adapter:** `CryptoYogi/vazhi-v4_2-lora`
**Notebook:** `notebooks/Vazhi_SFT_v4_2_OnVanilla.ipynb`

### Training Config

```python
BASE_MODEL = "Qwen/Qwen3-0.6B"  # vanilla instruct (not DAPT)
SFT_DATASET = "CryptoYogi/vazhi-tamil-sft-v4_1"
LORA_R = 8, LORA_ALPHA = 16
TARGET_MODULES = ["q_proj", "v_proj"]
LR = 5e-5, EPOCHS = 2, BATCH = 4 × 1 GPU × 2 grad_accum = 8 effective
MAX_SEQ_LENGTH = 2048
```

### Training Results

| Metric | Value |
|--------|-------|
| Train loss | 1.2931 → 0.8552 (33.9% drop) |
| Eval loss | 0.9812 → 0.9151 |
| Final gap | -0.003 (zero overfitting) |
| Steps | 3,270 |
| Runtime | ~45 min on L4 |

Mid-training gen checks:
- Step 817: 1/3 garbage (greeting repetitive loop)
- Step 1634: 3/3 "OK" (but actually meaningless Tamil rambling)
- Step 2451: 1/3 garbage (help prompt echo loop)
- Step 3268: 3/3 "OK" (same meaningless rambling)

### The Failure: Transliterated English Gibberish

**Pre-SFT vanilla model:** Short, coherent Tamil — "வணக்கம் 😊", "நன்றி! 😊"
**After SFT:** Long transliterated English gibberish in Tamil script:

- "ஜென்னுஸ் ரெஃப்ஸ் ஹோர்ட் பிளாஸ்ட்" = "Genus Refs Hort Blast"
- "ஜோர்க்ஸ் ஓப்பூர், ஃபெஸ்ட்ரோனியந் திரோப்ளீஸ்" = "George Opur, Festroniyen Throplees"
- "ஐப்ளேன்ஷாஃப்ட்" = "Iplaneshaft"
- "ஸ்ரஸ்ஷோச் ஃபேஜ்" = "Srasshoch Phase"

Tamil char % scores 75-88% (PASSES eval) because Tamil script characters are used, but the WORDS are nonsensical transliterated English.

### Root Cause Analysis

The third possible outcome from our diagnostic was confirmed: **SFT pipeline itself degrades the model**.

| Observation | Implication |
|-------------|------------|
| Vanilla produces coherent short Tamil | Model HAS Tamil capability |
| SFT destroys it → transliterated English gibberish | SFT is overwriting Tamil with garbage patterns |
| v4.1 (DAPT base) → Tamil word soup gibberish | Different base, different gibberish flavor |
| v4.2 (vanilla base) → transliterated English gibberish | Different base, different gibberish flavor |
| Both have healthy loss curves and zero overfitting | Loss metrics cannot detect semantic quality collapse |
| 4 consecutive 16/16 false positive evals | Tamil char % eval is fundamentally broken |

**This is the SAME catastrophic forgetting pattern in both directions:**
- DAPT: learning Tamil → forgets instruction-following
- SFT: learning instructions → forgets Tamil

The 0.6B model may lack capacity to retain one capability while acquiring another through LoRA fine-tuning.

### Candidate Root Causes (to investigate)

1. **LR 5e-5 too aggressive** — same LR that destroyed instruction-following in DAPT v1.1. May need 1e-5 or 2e-5 for 0.6B
2. **Dataset contamination** — SFT dataset may contain transliterated English that model learned to reproduce
3. **0.6B model too small** — Tamil needs 3-4 tokens/char; effective model capacity for Tamil may be insufficient for conversational SFT
4. **LoRA merge corruption** — mid-training (adapter active) produces different output than merged model. Need to test adapter directly

---

## Architectural Decisions

### ADR-001: Why Not RAG?

**Considered:** Using RAG (Retrieval Augmented Generation) for Culture pack

**Rejected because:**
1. Goes against offline working principle - RAG typically needs vector DB
2. Adds complexity to mobile deployment
3. Fine-tuning should work if data is correct

**Decision:** Fix the training data, not the architecture.

### ADR-002: Why Qwen2.5-3B? (Initial Choice)

**Chosen for:**
- Good instruction following
- Reasonable size for mobile (with quantization)
- Multilingual support (though Tamil is limited)

**Limitations Discovered:**
- Limited Tamil vocabulary efficiency
- Quantization destroys Tamil output quality
- 3B model too large even at Q4 (1.8GB)

**Status:** ❌ Abandoned after v0.4 quantization failures

### ADR-003: Why SLM (Small Language Model) Approach?

**Date:** 2026-02-07
**Status:** ✅ Adopted

**Context:**
After v0.4 training, we discovered that GGUF quantization of Qwen2.5-3B produces
gibberish Tamil output, even at Q8_0 (~3.2GB). The 6.2GB F16 model worked but is
impractical for mobile deployment.

**Problem Statement:**
How do we deploy a Tamil-capable LLM on mobile devices with limited storage and
memory, when large models lose Tamil capability after quantization?

**Decision:**
Use Qwen2.5-0.5B-Instruct as the base model instead of Qwen2.5-3B-Instruct.

**Rationale:**

1. **Same tokenizer, smaller model**
   - Both models use the same 151K vocabulary tokenizer
   - Tamil subword tokens are preserved in both
   - Smaller model means less precision loss during quantization

2. **Right-sized for the task**
   - VAZHI is an instruction-following assistant, not a general-purpose LLM
   - 0.5B parameters sufficient for structured Q&A responses
   - Heavy fine-tuning on domain-specific data compensates for smaller size

3. **Mobile-first design**
   - Q4_K_M of 0.5B ≈ 250MB (vs 1.8GB for 3B)
   - Fits in mobile RAM constraints
   - Faster inference on mobile CPUs

4. **Quantization math**
   - 3B model: 3,000M params × 4 bits = 1.5GB minimum
   - 0.5B model: 500M params × 4 bits = 250MB minimum
   - Smaller absolute error accumulation in smaller model

**Trade-offs Accepted:**
- Less general knowledge capacity
- May struggle with complex multi-turn reasoning
- Relies heavily on training data quality

**Mitigations:**
- Comprehensive Tamil foundation dataset (11,696 items)
- Strong guardrails ("I don't know" responses)
- Focused on specific use cases, not general chat

**Alternatives Considered:**

| Alternative | Why Rejected |
|-------------|--------------|
| Keep 3B at Q8 (3.2GB) | Too large for mobile |
| Custom Tamil tokenizer | Major engineering effort, future consideration |
| Distillation from 3B→0.5B | Complex, may not preserve Tamil |
| Different model family (Phi, Gemma) | Less proven multilingual support |

**Success Criteria:**
1. Q4_K_M produces coherent Tamil responses
2. First Thirukkural correctly cited
3. Guardrails prevent hallucination
4. Model size < 300MB

### ADR-004: Mixed Training Format (Q&A + Completion)

**Date:** 2026-02-07
**Status:** ✅ Adopted

**Context:**
For the Tamil foundation dataset, we have both:
- Structured Q&A data (instruction → response)
- Raw Tamil text (Thirukkural, Sangam poetry, Bharathiar)

**Decision:**
Use a mixed format approach:
- 94% Q&A format for instruction-following
- 6% completion format for Tamil fluency

**Rationale:**
- Q&A format teaches the model to follow instructions
- Completion format exposes the model to authentic Tamil prose/poetry
- Mix prevents the model from only learning to respond to questions
- Raw text helps with Tamil language patterns and fluency

### ADR-005: Hybrid Retrieval Architecture

**Date:** 2026-02-08
**Status:** ✅ Adopted
**Full Document:** `/vazhi_app/docs/adr/ADR-005-hybrid-retrieval-architecture.md`

**Context:**
- App needs to provide value before 1.6GB model download
- Factual data (Thirukkural, phone numbers) must never be hallucinated
- Cloud inference fallback would incur ongoing costs

**Decision:**
Implement a hybrid architecture with two paths:
1. **Deterministic Path** - SQLite lookup for exact data (no model needed)
2. **AI-Enhanced Path** - LLM for explanations and conversations (model required)

**Benefits:**
- App is useful immediately from first launch
- Zero hallucination for factual data
- Encourages model download for AI features
- No cloud costs

**Data Schema:** `/vazhi_app/docs/data_schema.md`

---

## Mistakes to Avoid

1. **Don't trust data labels** - Always verify with character-level analysis
2. **Don't add more data to fix quality issues** - Fix the existing data first
3. **Don't assume English training teaches Tamil** - Language mismatch is real
4. **Don't treat Thirukkural as generative** - It's citation/reference material
5. **Don't skip data quality validation** - Check before training, not after
6. **Don't assume larger models quantize better** - Smaller models may preserve quality better
7. **Don't skip GGUF testing** - Always test quantized output before deployment
8. **Don't ignore tokenization efficiency** - Tamil chars/token ratio matters
9. **NEVER modify the tokenizer's special tokens** - Setting `pad_token = eos_token` causes "OrderedVocab holes" and corrupts the model. Instead, align model config with the existing tokenizer tokens
10. **Don't trust low loss values alone** - Test actual model output after training; loss can be low while output is garbage
11. **Don't use learning rates below 1e-5** - Too conservative, model won't learn. 5e-5 is the sweet spot for LoRA fine-tuning
12. **NEVER ignore tokenizer warnings** - "OrderedVocab contains holes" is a FATAL error that will break GGUF conversion. Stop training immediately if you see this warning
13. **Don't use single-pass SFT for language adaptation** - Two-stage (DAPT→SFT) preserves fluency AND instructions
14. **Don't skip preflight testing** - Run tiny DAPT+SFT before full training to catch issues early
15. **Don't rely on Colab/Kaggle session persistence** - Checkpoint to HF Hub every epoch
16. **Verify base model tokenizer BEFORE training** - A corrupted source model will produce corrupted outputs
17. **NEVER mix data formats in SFT** - Raw text and ChatML-formatted samples CANNOT be trained together. Raw text → DAPT stage. ChatML → SFT stage. Mixing causes "systemsystemsystem..." output.
18. **Verify format consistency before training** - Use `is_chatml_formatted()` check to ensure 100% of SFT samples have proper chat template
19. **Handle instruct model format conflicts with suppression, not pivoting** - If the instruct model has native tokens (e.g., Qwen3's `<think>`), suppress them during generation rather than pivoting to the base model. The instruct model already has language capability (Tamil) and instruction-following — SFT-only on the base model loses both. *(Updated from v3.5 failure: original advice to "use base model" was wrong without DAPT)*
20. **Lower the learning rate for instruct models** - 1e-4 is too aggressive for models that already have instruction-following capability; causes catastrophic forgetting. Use 2e-5 or lower
21. **SFT-only CANNOT teach a new language** - A base model pre-trained on code/web/English/Chinese won't learn Tamil from ~3K SFT samples. You MUST do DAPT (domain-adaptive pretraining on raw Tamil text) first, then SFT
22. **Iterate on what's working, don't pivot to untested approaches** - v3.3 produced Tamil with fixable issues (`<think>` tags, aggressive LR, Thirukkural-biased responses). Fixing those was a 1-hour task. Pivoting to base model SFT-only wasted hours of compute on a worse outcome
23. **Eval must check OUTPUT QUALITY, not just pattern absence** - Check Tamil character %, response coherence, and semantic relevance. A response of code tokens "passes" loop/leak/empty checks but is completely useless
24. **A healthy loss curve does NOT mean the model learned** - Loss was computed only on the subset of samples where the response template was found. The model can minimize loss by predicting common token patterns without learning the target language
25. **Strict ChatML validation (regex) before training** - Every SFT sample MUST have: `<|im_start|>user\n` with non-empty content, `<|im_start|>assistant\n` with non-empty content, and proper `<|im_end|>` closings. Samples missing any part contribute zero or wrong training signal
26. **Use simpler response template for masking** - `"<|im_start|>assistant"` (without trailing newline) is more robust than `"<|im_start|>assistant\n"` — the newline can tokenize differently depending on surrounding context
27. **NEVER merge LoRA into a 4-bit quantized model** — `model.merge_and_unload()` on a 4-bit model causes catastrophic rounding errors, producing garbage output. Instead: save LoRA adapter → reload base model in fp16 → load adapter onto fp16 model → merge in full precision. The 4-bit model is for training memory efficiency only, not for the final merge
28. **Disable gradient checkpointing before eval** — gradient checkpointing conflicts with `use_cache=True` during generation, forcing `past_key_values=None`. Call `model.gradient_checkpointing_disable()` before any `generate()` calls. Also log loss values as text (not just HTML widgets) to verify training convergence from notebook output
29. **Separate data prep from training** — if DAPT/SFT training fails, you shouldn't have to redo corpus filtering, tokenization, and packing. Data prep runs on CPU and uploads to HF; training loads pre-built dataset from HF
30. **Use Instruct model for DAPT when bootstrapping a new language** — v1.0 used Base model per GPT5.2 recommendation, but DAPT showed -2% vs vanilla Base (no improvement). v1.1 used Instruct model and showed +55% Tamil char improvement vs vanilla Instruct. The Instruct model already has some multilingual capability; DAPT deepens it. Base model requires far more tokens to bootstrap from zero. *(Updated: v1.0 proved "Base for DAPT" wrong for low-resource languages on small models)*
31. **Token budget, not epochs** — control DAPT training by target token count and max_steps. Epochs are misleading when corpus size varies. Cap at 2 epochs max to prevent catastrophic forgetting
32. **Verify corpus schema before coding** — always inspect actual HuggingFace dataset columns and sample data before writing processing code. The IndicAlign debacle (assumed schema, broke at runtime) must never repeat
33. **Automated eval metrics can produce false positives** — Tamil %, repeat ratio, code detection, and emptiness checks all passed 12/12 for SFT v4.0, but every response was semantic gibberish. Eval MUST include human-readable content review, not just automated metrics. Consider adding factual accuracy checks (e.g., "Capital of TN" must contain "Chennai/சென்னை")
34. **Clear `generation_config.suppress_tokens` before generating** — When a model is saved with `suppress_tokens` in its generation config, `generate()` auto-injects the built-in `SuppressTokensLogitsProcessor` which has a CPU/CUDA device mismatch bug in transformers 2.8.0. Always set `model.generation_config.suppress_tokens = None` and use a custom logits processor instead
35. **LoRA r=16 on 7 modules is too aggressive for ~1K samples** — With only 1,365 training samples, LoRA r=16 targeting all 7 projection matrices (q/k/v/o/gate/up/down) gives too many trainable parameters. The model overfits to surface patterns (Tamil-looking token sequences) without learning semantics. Try r=8 targeting only q_proj+v_proj for small datasets

---

## Key Learnings

### Quantization & Tamil

1. **Tokenization overhead compounds**: If Tamil needs 3-4 tokens per character, quantization errors multiply
2. **Smaller models can be better**: Less absolute precision loss when fewer parameters to compress
3. **Test early, test quantized**: Never assume training success means deployment success
4. **Same tokenizer ≠ same quality**: Model size affects post-quantization quality significantly

### Data Quality

1. **Character analysis reveals truth**: Labels can lie, character counts don't
2. **Completion data improves fluency**: Not just Q&A, raw text helps language patterns
3. **Corpus vs generated**: Authoritative sources prevent hallucination
4. **Dialect balance matters**: Include regional variations for authentic responses

### Training Configuration (v0.7 Discoveries)

1. **Never modify tokenizer special tokens**: Setting `tokenizer.pad_token = tokenizer.eos_token` creates "OrderedVocab holes" and corrupts vocabulary. Instead, align the model's config with the tokenizer's existing tokens:
   ```python
   model.config.pad_token_id = tokenizer.pad_token_id
   model.config.bos_token_id = tokenizer.bos_token_id
   model.config.eos_token_id = tokenizer.eos_token_id
   ```

2. **Learning rate boundaries for LoRA**:
   - Too low (1e-6): No learning, loss stays flat
   - Sweet spot (5e-5): Stable learning, no catastrophic forgetting
   - Too high (2e-4): Training divergence after ~1000 steps

3. **Conservative LoRA settings work**: r=4, alpha=8, targeting only q_proj and v_proj is sufficient for domain adaptation without corrupting base model capabilities

4. **4-bit training can work**: Unlike v0.5/v0.6 failures, using a pre-trained Tamil model (not English-first model) with proper tokenizer handling allows successful 4-bit training

5. **Fork your base models**: Depending on external "alpha" models is risky. Fork to your own HuggingFace space for stability

6. **Gradient checkpointing + use_cache conflict**: Set `model.config.use_cache = False` before training, re-enable for inference

### Continuous Learning Pipeline (Designed in v0.7)

1. **Weekly feedback collection**: Users provide 👍/👎/✏️ feedback on responses
2. **Corrections become training data**: User corrections in Alpaca format for fine-tuning
3. **Monthly model updates**: Aggregate corrections, retrain, and redeploy
4. **Feedback loop**: App → Corrections → Training → Improved Model → App

---

## SFT v5.0 Training (Feb 2026)

First successful SFT run producing coherent Tamil output. Key changes from v4.x:
- **Dataset v5.0**: Two-source Tamil strategy (5,328 train samples, 85.2% Tamil avg)
- **Conservative LoRA**: r=16 on all 7 modules (expanded from v4.2's r=8 on 2 modules), but LR 1e-5 (5x lower than v4.2's 5e-5)
- **Tamil WORD validation**: Replaced broken Tamil char % eval with bigram-based Tamil word validator
- **Vanilla base**: Skipped DAPT — used vanilla Qwen3-0.6B (instruct) directly
- **1 epoch only**: Prevented catastrophic forgetting seen in v4.2 (2 epochs)

Model: `CryptoYogi/vazhi-v5_0`

---

## Dataset v5.1 — Safety Rebalancing (Feb 2026)

v5.0 model had mode collapse to safety vocabulary — every response included "தீங்கு" (harm) due to safety data being 30.6% of the dataset.

- Safety cut from 1,800 (30.6%) to 200 (4.6%)
- Intelligent downsampling: Toxic_Matrix 50 diverse questions, HHRLHF_T 150 deduplicated responses
- All other sources unchanged from v5.0

Dataset: `CryptoYogi/vazhi-tamil-sft-v5_1` (~4,321 samples)

---

## SFT v5.1a — Safety Fix on v5.0 Model (Feb 2026)

Quick experiment: run v5.1 rebalanced data on the v5.0 SFT model to fix mode collapse without losing Tamil capability.

- Base: `CryptoYogi/vazhi-v5_0` (already has Tamil patterns)
- Dataset: v5.1 (safety 4.6%, down from 30.6%)
- Training: 1 epoch, ~486 steps
- Purpose: Fix "தீங்கு" mode collapse with rebalanced data

Model: `CryptoYogi/vazhi-v5_1a`

---

## Dataset v5.2 — Conversational Fundamentals (Feb 2026)

v5.1 had only 5 conversational items out of 4,321 samples. A 0.6B model can't infer conversational behavior from a system prompt alone.

Key additions:
- **Conversational fundamentals pack** (200 items): greetings, identity, chitchat, wellbeing, farewells, meta-conversation, emotional support, capabilities, language preferences, colloquial TN Tamil
- **VAZHI behavior pack** (60 items): identity responses, capability descriptions, personality traits
- **Sadhguru Q&A DROPPED**: Quality audit found critical issues (see below)
- **Safety further reduced**: ~45 items (1% of dataset)

Dataset: `CryptoYogi/vazhi-tamil-sft-v5_2` (3,579 samples)

---

## Sadhguru Q&A v1 Quality Audit (Feb 2026)

Critical quality issues found in the multi-agent sonnet Q&A generation (v1):
- **35% duplicates**: 4 blocks of 50x identical generic clichés
- **41% Q-A echo**: Agents copy-pasted article opening sentence as both question and answer
- **7% generic motivational content**: Not from Sadhguru articles at all
- **Only 38% of 562 articles used**: Agents skipped most articles
- **Short answers**: ~300 chars avg vs 5,500+ char articles

Root cause: Multi-agent sonnet system broke articles into tiny pieces and generated content rather than using the actual article text. The LLM agents hallucinated rather than extracting.

---

## Dataset v5.3 — Sadhguru Q&A v2 Restored (Feb 2026)

Fix for the v1 quality issues. Created `scripts/create_sadhguru_qa_v2.py`:
- Uses raw article text directly as answers (no LLM generation)
- Extracts questions from article titles or opening "கேள்வி:" markers
- Cleans HTML artifacts: `[pullquote]`, `[SadhguruImage]`, `[separator]`, `[photocredit]`, footnotes, URLs
- One Q&A pair per article (not fragmented into chunks)

**v2 results**: 562 pairs, 100% unique, avg 734 words per answer

**v5.3 composition** (4,264 total, 3,837 train + 427 eval):
| Bucket | Count | Pct |
|--------|-------|-----|
| vazhi_packs | 2,958 | 69.4% |
| sadhguru_qa | 562 | 13.2% |
| conversational | 200 | 6.3% |
| thirukkural | 169 | 3.9% |
| handcrafted | 120 | 2.8% |
| behavior | 60 | 2.7% |
| safety | 45 | 1.1% |
| general | 27 | 0.6% |

Scripts: `scripts/create_sadhguru_qa_v2.py`, `scripts/assemble_dataset_v5_3.py`
Dataset: `CryptoYogi/vazhi-tamil-sft-v5_3`

---

## SFT v5.3 — Sadhguru Q&A v2 Training (Feb 2026, PREPARED)

Training notebook ready, not yet run.

- Base: `CryptoYogi/vazhi-v5_1a` (2 epochs of Tamil SFT)
- Dataset: v5.3 (4,264 samples, Sadhguru Q&A v2 restored)
- Lineage: vanilla → v5.0 (1 epoch) → v5.1a (1 epoch) → v5.3 (this run)
- LoRA: r=16, 7 modules, LR 1e-5, 1 epoch
- Dual baseline eval: vanilla Qwen3-0.6B + v5.1a model
- Output: `CryptoYogi/vazhi-v5_3`
- Notebook: `notebooks/Vazhi_SFT_v5_3.ipynb`

---

## Model Comparison v1 — 7-Model Tamil Benchmark (Feb 2026)

**Date:** 2026-02-15
**Status:** ✅ Complete
**Notebook:** `notebooks/Vazhi_Model_Comparison_v1.ipynb`

### Purpose

After 20 training attempts on Qwen3-0.6B (v0.1→v6.0) all failed to produce coherent Tamil, we ran a systematic side-by-side comparison of 7 models to determine the best path forward.

### Models Tested

| # | Model | Params | fp16 Size | Q4_K_M GGUF | Family |
|---|-------|--------|-----------|-------------|--------|
| 1 | Vanilla Qwen3-0.6B | 0.75B | 1.5 GB | 0.45 GB | qwen3 |
| 2 | DAPT v2.1 (CryptoYogi/vazhi-dapt-v2_1) | 0.75B | 1.5 GB | 0.45 GB | qwen3 |
| 3 | SFT v6.0 (CryptoYogi/vazhi-v6_0) | 0.75B | 1.5 GB | 0.45 GB | qwen3 |
| 4 | Sarvam-1 (sarvamai/sarvam-1) | 2.0B | 4.0 GB | 1.20 GB | sarvam |
| 5 | **Gemma 3 1B-it** (google/gemma-3-1b-it) | ~1.0B | 2.0 GB | 0.60 GB | instruct |
| 6 | Gemma 3n E2B-it (google/gemma-3n-E2B-it) | **6.0B raw** (2B eff.) | 12.0 GB | 3.60 GB | instruct |
| 7 | Navarasa 2.0 (Telugu-LLM-Labs/Indic-gemma-2b-finetuned-sft-Navarasa-2.0) | 2.5B | 5.0 GB | 1.50 GB | instruct |

### Test Prompts (5 Tamil + 5 English)

Tamil: வணக்கம், நீங்கள் யார்? | தமிழ்நாட்டின் தலைநகரம் எது? | திருக்குறளின் முதல் குறள் என்ன? | ஒரு தெரியாத எண்ணில் இருந்து மெசேஜ் வந்தது. என்ன செய்வது? | நீரிழிவு நோய் பற்றி சொல்லுங்கள்

English: Who are you? | What is the capital of Tamil Nadu? | How to file an FIR? | Tell me about Thirukkural | What should I do if I receive a scam call?

### Results

| Model | Real Tamil? | Relevant Answers? | Structured? | Q4_K_M | Rating |
|-------|------------|-------------------|-------------|--------|--------|
| Vanilla Qwen3-0.6B | ❌ Bengali/Hindi confusion | ❌ | ❌ | 0.45 GB | 1/5 |
| DAPT v2.1 | ❌ Fake/made-up words | ❌ | ❌ | 0.45 GB | 1/5 |
| SFT v6.0 | ❌ Fake words + structure | ❌ | ✅ | 0.45 GB | 2/5 |
| Sarvam-1 | ✅ Real Tamil words | ⚠️ Partial | ❌ Base model, no instruction-following | 1.20 GB | 3/5 |
| **Gemma 3 1B-it** | **✅ Real Tamil** | **✅ Relevant** | **✅ Structured** | **0.60 GB** | **4/5** |
| Gemma 3n E2B-it | ✅ Best quality | ✅ Relevant | ✅ Structured | 3.60 GB ❌ | 5/5 (benchmark only) |
| Navarasa 2.0 | ✅ Real Tamil words | ❌ Broken instruction-following | ❌ | 1.50 GB | 1/5 |

### Key Findings

1. **Gemma 3 1B-it is the clear winner for VAZHI:** Real Tamil + relevant answers + structured output + fits <1GB GGUF (0.60GB Q4_K_M)
2. **Model architecture > training data:** Gemma 3 1B-it with zero fine-tuning outperforms 20 Qwen3-0.6B training attempts. Google's 2T-token multilingual pretraining (140+ languages, 262K vocab) provides genuine Tamil that 15-40M token DAPT on 151K vocab never could
3. **Qwen3-0.6B is fundamentally incapable of Tamil:** All 3 Qwen3 variants (vanilla, DAPT, SFT) produce fake Tamil words. The model's 151K vocab and 0.6B params cannot represent Tamil semantics
4. **Sarvam-1 has Tamil but no instruction-following:** Base model produces real Tamil words but doesn't follow prompts. Also exceeds <1GB limit (1.20GB Q4_K_M)
5. **Gemma 3n E2B-it "2B effective" is misleading:** Raw model has 6B params. GGUF must include all params = 3.60GB Q4_K_M. Impossible for mobile deployment
6. **Navarasa 2.0 fine-tuning destroyed instruction-following:** Base Gemma model had Tamil capability but SFT broke it — cautionary tale for our own SFT

### Gemma 3 1B-it Issues to Fix via SFT v7.0

- Response degeneration at end (garbage tokens: 冲突, Netanyahu, "Reply suppress", "EOS")
- Factual hallucinations (Thanjavur as capital instead of Chennai)
- Identity: says "VAZI" not "VAZHI" (close but needs correction)
- English questions get Tamil responses (system prompt bias — may be desired for VAZHI)

### Decision

**PIVOT from Qwen3-0.6B to Gemma 3 1B-it as base model.**

New strategy:
- No DAPT needed (model already knows Tamil from pretraining)
- SFT v7.0: teach VAZHI personality, domain knowledge, Tamil Nadu facts
- Dataset: v5.3 (4,264 samples) converted from ChatML to Gemma format
- GGUF: Q4_K_M = 0.60GB (well within <1GB limit)

---

## Data v7.0 — Dataset Rebuild for Gemma 3 (Feb 2026)

**Date:** 2026-02-16
**Status:** ✅ Complete
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v7_0`

### Purpose

Rebuild the SFT dataset for Gemma 3 format. Gemma 3 uses a different chat template than Qwen3's ChatML — it uses model-agnostic `instruction`/`output` fields rather than `<|im_start|>user` tags. Also rebalanced composition to include 61 VAZHI mission/identity pairs.

### Composition

| Bucket | Count | Pct |
|--------|-------|-----|
| Domain (6 packs) | 2,161 | 51.8% |
| Spiritual (Sadhguru Q&A) | 1,635 | 39.2% |
| Identity/Mission | 230 | 5.5% |
| Conversational | 112 | 2.7% |
| Safety | 34 | 0.8% |

**Total:** 4,172 samples (3,754 train / 418 eval)
**Key additions:** 61 mission pairs covering VAZHI acronym meaning, open source status, offline-first design, feedback channels, sponsorship info
**Avg length:** 47 words per response

---

## SFT v7.0 — Gemma 3 1B-it First Training (Feb 2026)

**Date:** 2026-02-16
**Status:** ⚠️ Partial — Tamil preserved but identity/factual corrections not learned
**Base Model:** `google/gemma-3-1b-it` (~1B params, 262K vocab, native Tamil from 2T-token pretraining)
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v7_0` (3,754 train / 418 eval)
**Output:** `CryptoYogi/vazhi-v7_0`
**Adapter:** `CryptoYogi/vazhi-v7_0-lora`
**Notebook:** `notebooks/Vazhi_SFT_v7_0_Gemma3.ipynb`
**Hardware:** L4-24GB (Colab)

### Training Config

- LoRA r=8, targeting q_proj + v_proj only (conservative — learned from Navarasa catastrophe)
- LR: 1e-5 (cosine)
- Epochs: 1 (211 steps)
- Batch: 16 (gradient accumulation)
- max_seq_length: 2048

### Results

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Train loss | 5.35 | 4.73 | -11.6% |
| Tamil char % | 93% | 92% | -1% (preserved) |
| Tamil word % | 95% | 94% | -1% (preserved) |
| Eval pass | — | 16/16 | — |

### Key Findings

1. **Tamil quality preserved:** Conservative LoRA (r=8, 2 modules) successfully avoided Navarasa-style catastrophic forgetting. Tamil quality barely changed (-1%)
2. **Identity NOT learned:** Model still says it's a "Google LLM" despite 230 identity training pairs. Gemma's 2T-token pretrained identity is deeply embedded
3. **Factual corrections not taken:** Model still says Coimbatore is the capital of Tamil Nadu (a Gemma hallucination). SFT couldn't override pretrained factual associations
4. **Response degeneration fixed:** No more garbage tokens at end of responses (冲突, Netanyahu, etc.) — SFT cleaned up output format
5. **Conservative LoRA too weak:** r=8 on only 2 modules preserved Tamil but was insufficient to override any pretrained priors. Need more capacity

### Decision

Proceed with incremental training — merge v7.0 adapter into base, then train v7.1 with stronger LoRA (r=16) on the merged model.

---

## SFT v7.1 — Incremental LoRA r=16 (Feb 2026) — DEPLOYMENT CANDIDATE

**Date:** 2026-02-16
**Status:** ✅ **BEST MODEL** — 96% Tamil word score (best ever across all 20+ training attempts)
**Base Model:** v7.0 merged (`CryptoYogi/vazhi-v7_0` — Gemma 3 1B-it + v7.0 LoRA merged)
**Dataset:** `CryptoYogi/vazhi-tamil-sft-v7_0` (3,754 train / 418 eval, same as v7.0)
**Output:** `CryptoYogi/vazhi-v7_1`
**Adapter:** `CryptoYogi/vazhi-v7_1-lora`
**Notebook:** `notebooks/Vazhi_SFT_v7_1_Gemma3.ipynb`
**Hardware:** A100-80GB (Colab)

### Training Config

- LoRA r=16, targeting q_proj + v_proj (doubled from v7.0's r=8)
- LR: 1e-5 (cosine)
- Epochs: 1 (234 steps)
- Batch: 16 (gradient accumulation)
- max_seq_length: 2048
- Incremental: trained on v7.0 merged model (not base Gemma 3)

### Results

| Metric | Before (v7.0) | After (v7.1) | Change |
|--------|---------------|--------------|--------|
| Train loss | 4.89 | 4.18 | -14.4% |
| Tamil char % | 89% | 95% | +6% |
| Tamil word % | 90% | 96% | **+6% (best ever)** |
| Eval pass | — | 16/16 | — |

### Key Findings

1. **Tamil IMPROVED to best-ever 96% word:** Incremental training on merged model actually improved Tamil quality, not just preserved it. This suggests the first pass (v7.0) loosened the model's weights enough for the second pass to refine Tamil
2. **Identity still says Google:** Despite doubled LoRA capacity (r=16), the model still identifies as Google. This confirms identity is deeply embedded in Gemma's 2T-token pretraining — not a capacity issue but a depth issue
3. **Chennai correct in A/B test:** Factual correction for Tamil Nadu's capital was learned (2/2 test prompts). Some factual associations can be updated with sufficient LoRA capacity
4. **Two-pass incremental training works:** v7.0 (r=8, conservative) → merge → v7.1 (r=16, stronger) produced better results than either would alone. First pass stabilizes, second pass refines

### Decision

**v7.1 is the deployment candidate.** Identity will be handled via system prompt at inference time ("You are VAZHI, a Tamil AI assistant..."). Factual corrections for edge cases handled via hybrid SQLite retrieval (already built into app architecture). Proceed to GGUF conversion.

---

## SFT v7.2 — Identity-Only Reinforcement (Feb 2026) — FAILED

**Date:** 2026-02-16
**Status:** ❌ Failed — identity NOT learned, domain knowledge REGRESSED
**Base Model:** v7.1 merged (`CryptoYogi/vazhi-v7_1`)
**Dataset:** 90 samples only (61 VAZHI mission pairs + 29 factual corrections), 10 epochs
**Output:** Merged NOT uploaded (regression detected)
**Adapter:** `CryptoYogi/vazhi-v7_2-lora`
**Notebook:** `notebooks/Vazhi_SFT_v7_2_Gemma3.ipynb`
**Hardware:** A100-80GB (Colab)

### Training Config

- LoRA r=16, targeting q_proj + v_proj
- LR: 1e-5 (cosine)
- Epochs: 10 (~60 steps total — tiny dataset)
- Dataset: 90 identity/factual samples repeated 10x
- Hypothesis: focused repetition on identity might override Gemma's pretrained priors

### Results

| Metric | Before (v7.1) | After (v7.2) | Change |
|--------|---------------|--------------|--------|
| Identity correct | 0/4 | 0/4 | **No change** |
| Google identity | 2/4 | 2/4 | No change |
| Tamil word % | 96% | 99% | +3% |
| Domain knowledge | ✅ Full | ❌ **Regressed** | **Critical regression** |

### Key Findings

1. **Gemma's Google identity is unhackable via LoRA SFT:** 90 identity samples x 10 epochs (effectively 900 exposures) couldn't make the model say "VAZHI" even once. 0/4 identity prompts correct. 2T tokens of pretraining > any amount of LoRA fine-tuning
2. **Domain knowledge REGRESSED catastrophically:** Model started saying "சாரி" (sorry, I don't know) to domain questions it previously answered well — Thirukkural, ration cards, health queries, legal questions. Even 90 focused samples can overwrite broader capabilities
3. **Tamil quality technically improved (99% word):** But this is misleading — the model's responses were so short ("sorry" responses) that they trivially scored high Tamil %
4. **Identity-only training is a dead end:** Small focused datasets cause the model to forget broader domain knowledge while still failing to override deeply pretrained identity

### Lesson

**Never attempt to override a model's pretrained identity via LoRA SFT.** For models with strong pretrained identity (Gemma's "I am Google"), handle identity at inference time via system prompt. This is not a training problem — it's a deployment/architecture problem.

---

## GGUF v7.1 — Quantization for Mobile (Feb 2026)

**Date:** 2026-02-16
**Status:** ✅ Complete
**Source Model:** `CryptoYogi/vazhi-v7_1` (Gemma 3 1B-it + SFT v7.1 merged)
**Outputs:** 3 GGUF variants uploaded to HuggingFace

### Variants

| Quantization | File Size | HuggingFace Repo | Device Target |
|---|---|---|---|
| Q4_K_M | 762 MiB | `CryptoYogi/vazhi-v7_1-Q4_K_M-GGUF` | 6GB+ RAM (best quality) |
| Q3_K_M | ~693 MiB | `CryptoYogi/vazhi-v7_1-Q3_K_M-GGUF` | 6GB+ RAM (medium) |
| Q2_K | 652 MiB | `CryptoYogi/vazhi-v7_1-Q2_K-GGUF` | Testing only (low quality) |

### Notable: Gemma 3's 262K Vocab Tax

Unlike Qwen3 (151K vocab), Gemma 3's 262K vocabulary creates 157 f32 tensors (embeddings + layer norms) that are **identical across all quantization levels**. This means:

- Q4_K_M to Q2_K saves only 110 MiB (762→652 MiB, 14% reduction)
- ~30% of Gemma 3's 999.89M params are in the 262K embedding matrix (~302M params)
- The embedding/norm tensors form a fixed ~500 MiB floor that no quantization can reduce
- Quantization only compresses the remaining ~70% of weights (attention + FFN)

This has critical implications for mobile deployment — see 4GB Device Testing below.

---

## 4GB Device Testing — All Variants OOM (Feb 2026)

**Date:** 2026-02-17
**Status:** ❌ Failed — all 3 GGUF variants crash on 4GB Android devices
**Device:** Samsung Galaxy (4GB RAM, 3.9 GB total, ~1.2-1.5 GB available after OS/apps)
**App:** VAZHI v0.1.0-debug (Flutter, llamadart inference)

### Test Results

| Variant | File Size | Load (mmap) | Context Create | Prompt Ingest | Response | Result |
|---------|-----------|-------------|----------------|---------------|----------|--------|
| Q4_K_M | 762 MiB | ✅ | ✅ (n_ctx=256, n_batch=1) | Started (225 tokens) | ❌ | **OOM crash** |
| Q4_K_M (retry) | 762 MiB | ✅ | ✅ (n_ctx=256, n_batch=1) | Started (22 tokens) | ❌ | **OOM crash** |
| Q2_K | 652 MiB | ✅ | ✅ (n_ctx=256, n_batch=1) | Started (22 tokens) | ❌ | **OOM crash** |

Q3_K_M was skipped (similar size to Q2_K, same outcome expected).

### 270M-it Test (Smallest Available Gemma 3)

After confirming all 1B-it variants crash, we tested the smallest Gemma 3 model (270M-it, bartowski's Q6_K_L quant):

| Variant | File Size | Params | Layers | Tensors (f32) | Load | Context | Ingest | Result |
|---------|-----------|--------|--------|---------------|------|---------|--------|--------|
| 270M Q6_K_L | 263.64 MiB | 268.1M | 18 | 109 of 236 | ✅ (mmap) | ✅ (n_ctx=256) | Started (21 tokens) | **OOM crash** |

**Device state at load time:**
- Total RAM: 3,901 MB (3.9 GB)
- Available: 1,444 MB (1.4 GB)
- Free: 242 MB
- OOM score: 718/1000
- App process: ~640 MB overhead (Flutter + Dart VM + worker isolate)

**Crash sequence:** Model loads via mmap → context creates → prompt ingestion starts → forward pass touches all 18 layers + embeddings + output head → Android OOM killer terminates process.

**Key finding:** Even at 264 MiB (vs 652-762 MiB for 1B-it), the 262K vocabulary creates 109 f32 tensors that cannot be compressed. The forward pass working set plus Flutter app overhead (~640 MB) exceeds the ~1.4 GB available.

### Observed Behavior (All Tests)

1. Model file downloads and loads via mmap (kernel handles paging)
2. Context creates successfully with minimal settings (n_ctx=256, n_batch=1)
3. Prompt ingestion begins (llama.cpp `ingest:start` event)
4. During forward pass, model touches all layers + embeddings + output head
5. Working set ≈ entire model size in physical RAM
6. Android OOM killer activates (OOM score 718-772)
7. App process terminated — thinking indicator stops, app crashes

### Root Cause Analysis

**Gemma 3's 262K vocabulary creates a fixed memory floor that quantization cannot reduce.**

| Model | Vocab | Params | Tensor Count (f32) | GGUF Size | Available RAM | Result |
|-------|-------|--------|-------------------|-----------|---------------|--------|
| Gemma 3 1B-it Q4_K_M | 262K | 999.89M | 157 | 762 MiB | ~1.3 GB | **OOM (772)** |
| Gemma 3 1B-it Q2_K | 262K | 999.89M | 157 | 652 MiB | ~1.45 GB | **OOM (757)** |
| Gemma 3 270M-it Q6_K_L | 262K | 268.1M | 109 | 264 MiB | ~1.4 GB | **OOM (718)** |

The f32 tensors (embeddings + layer norms) are identical across all quant levels for a given architecture. The 262K vocabulary creates an uncompressible embedding matrix that dominates memory regardless of model parameter count.

mmap doesn't solve this because the forward pass touches the entire model (all transformer layers + embedding lookup + output head projection). The working set during inference ≈ the full model file size. Combined with Flutter app overhead (~640 MB), total memory demand exceeds the ~1.4 GB available on 4GB devices.

### Implications for VAZHI

1. **No Gemma 3 model can run on 4GB Android devices** — tested 1B-it (3 variants) and 270M-it, all crash
2. **4GB devices = SQLite retrieval only** — architectural decision recorded in ADR-012
3. **6GB+ devices = on-device LLM** — VAZHI v7.1 Q4_K_M (762 MiB) as primary, smaller quants as options
4. **Two-tier deployment confirmed:**
   - 4GB: Hybrid SQLite retrieval (deterministic lookups, offline, no LLM) — still provides immediate value
   - 6GB+: On-device Gemma 3 1B-it with system prompt identity + hybrid SQLite for facts
5. **Future 4GB LLM options:**
   - Vocabulary trimming (262K→~50K) — projected ~300 MiB Q4_K_M, well within 4GB capability
   - imatrix quantization — better Tamil quality at same size, not smaller files
   - Different model architecture with smaller vocabulary
6. **Harness test needed** — to confirm OOM is model size vs device RAM, not Flutter app overhead

---

## References

### Training Notebooks
- SFT v7.2 identity-only (GPU, FAILED): `/notebooks/Vazhi_SFT_v7_2_Gemma3.ipynb`
- SFT v7.1 incremental r=16 (GPU, **BEST MODEL**): `/notebooks/Vazhi_SFT_v7_1_Gemma3.ipynb`
- SFT v7.0 Gemma 3 (GPU, COMPLETE): `/notebooks/Vazhi_SFT_v7_0_Gemma3.ipynb`
- Model Comparison v1 (GPU, COMPLETE): `/notebooks/Vazhi_Model_Comparison_v1.ipynb`
- SFT v6.0 on DAPT v2.1 (GPU, FAILED): `/notebooks/Vazhi_SFT_v6_0_OnDAPT.ipynb`
- SFT v5.3 training (GPU, COMPLETE): `/notebooks/Vazhi_SFT_v5_3.ipynb`
- SFT v5.1a training (GPU, COMPLETE): `/notebooks/Vazhi_SFT_v5_1a.ipynb`
- SFT v5.0 training (GPU, COMPLETE): `/notebooks/Vazhi_SFT_v5_0.ipynb`
- DAPT v2.1 data prep (CPU): `/notebooks/Vazhi_DAPT_Data_v2_1.ipynb`
- DAPT v2.1 training (GPU): `/notebooks/Vazhi_DAPT_v2_1_Tamil.ipynb`
- DAPT v2.0 data prep (CPU): `/notebooks/Vazhi_DAPT_Data_v2_0.ipynb`
- DAPT v2.0 training (GPU): `/notebooks/Vazhi_DAPT_v2_0_Tamil.ipynb`
- Dataset Factory v4.1 Stage 1 Retrieve (CPU, LATEST): `/notebooks/Vazhi_Dataset_Factory_v4_1.ipynb`
- Dataset Factory v4.1 Stage 2+3 Curate+Compose (GPU, LATEST): `/notebooks/Vazhi_Dataset_Factory_v4_1_2.ipynb`
- Dataset Factory v4.1 Stage 3 Re-compose Fix (CPU): `/notebooks/Vazhi_Dataset_Factory_v4_1_3.ipynb`
- SFT v4.2 on vanilla (GPU, FAILED): `/notebooks/Vazhi_SFT_v4_2_OnVanilla.ipynb`
- SFT v4.1 on DAPT (GPU, FAILED): `/notebooks/Vazhi_SFT_v4_1_OnDAPT.ipynb`
- SFT v4.0 training (GPU, FAILED): `/notebooks/Vazhi_SFT_v4_0_OnDAPT.ipynb`
- SFT v4.0 eval (standalone): `/notebooks/Vazhi_Eval_v4_0.ipynb`
- DAPT v1.1 data prep (CPU): `/notebooks/Vazhi_DAPT_Data_v1_1.ipynb`
- DAPT v1.1 training (GPU): `/notebooks/Vazhi_DAPT_v1_1_Tamil.ipynb`
- DAPT v1.0 data prep (CPU): `/notebooks/Vazhi_DAPT_Data_v1_0.ipynb`
- DAPT v1.0 training (GPU): `/notebooks/Vazhi_DAPT_v1_0_Tamil.ipynb`
- Dataset Factory v4.0 (superseded): `/notebooks/Vazhi_Dataset_Factory_v4_0.ipynb`
- v3.7 LoRA merge fix (superseded): `/notebooks/Vazhi_SFT_v3_7_MergeFix.ipynb`
- v3.6 Return to instruct (FAILED — merge corruption): `/notebooks/Vazhi_SFT_v3_6_Instruct.ipynb`
- v3.5 Completion-only masking (FAILED): `/notebooks/Vazhi_SFT_v3_5_Masked.ipynb`
- v3.4 Base model notebook (superseded): `/notebooks/Vazhi_SFT_v3_4_Base.ipynb`
- v3.3 Clean training: `/notebooks/Vazhi_SFT_v3_3_Clean.ipynb`
- v3.2 Fixed training: `/notebooks/Vazhi_SFT_v3_2_Fixed.ipynb`
- v3.1 Balanced SFT: `/notebooks/Vazhi_SFT_v3_1_Balanced.ipynb`
- Test existing models: `/notebooks/Test_Existing_Models.ipynb`
- v0.7 Training notebook: `/notebooks/Vazhi_Training_Fixed.ipynb`
- v0.7 Fork base model: `/notebooks/Vazhi_Fork_Base_Model.ipynb`
- v0.6 Sarvam-2B notebook: `/notebooks/Vazhi_Sarvam2B_Finetune.ipynb`
- v0.5 Qwen-0.5B notebook: `/notebooks/Vazhi_Qwen05B_Training.ipynb`
- v0.4 Training notebook: `/notebooks/Vazhi_Day4_v02_Training.ipynb`
- SmolLM notebook: `/notebooks/Vazhi_SmolLM_135M_Training.ipynb`

### Diagnostics & Quantization
- GGUF Diagnostics: `/notebooks/Vazhi_GGUF_Diagnostic.ipynb`, `Vazhi_GGUF_Diagnostic_v2.ipynb`
- GGUF Quantization: `/notebooks/Vazhi_GGUF_Quantization.ipynb`

### Data & Models (Current)
- **SFT v7.1 (DEPLOYMENT CANDIDATE)**: https://huggingface.co/CryptoYogi/vazhi-v7_1
- **SFT v7.0 (Gemma 3 base)**: https://huggingface.co/CryptoYogi/vazhi-v7_0
- **GGUF Q4_K_M**: https://huggingface.co/CryptoYogi/vazhi-v7_1-Q4_K_M-GGUF
- **GGUF Q3_K_M**: https://huggingface.co/CryptoYogi/vazhi-v7_1-Q3_K_M-GGUF
- **GGUF Q2_K**: https://huggingface.co/CryptoYogi/vazhi-v7_1-Q2_K-GGUF
- **SFT dataset v7.0**: https://huggingface.co/datasets/CryptoYogi/vazhi-tamil-sft-v7_0

### Data & Models (Historical)
- Data prep script: `/data/tamil_foundation/prepare_training_data.py`
- Tamil foundation data: `/data/tamil_foundation/` (19 JSON files)
- HuggingFace dataset: https://huggingface.co/datasets/CryptoYogi/vazhi-tamil-v05
- Forked base model: https://huggingface.co/CryptoYogi/gemma-2b-tamil-base
- Regeneration plan: `/docs/DATA_REGENERATION_PLAN.md`

### App Feedback System
- Feedback model: `/vazhi_app/lib/models/feedback.dart`
- Feedback service: `/vazhi_app/lib/services/feedback_service.dart`
- Feedback buttons widget: `/vazhi_app/lib/widgets/feedback_buttons.dart`

### Architecture Documentation
- ADR-005 Hybrid Retrieval: `/vazhi_app/docs/adr/ADR-005-hybrid-retrieval-architecture.md`
- Knowledge Pack Schema: `/vazhi_app/docs/data_schema.md`
