# ADR-014: Vocabulary Trimming Diagnostic & Recovery Plan

## Status
In Progress — Phase 1 fix applied and verified on Mac, pending Android device test

## Context

VAZHI's Gemma 3 1B-it model (v7.1) has a 262K SentencePiece vocabulary that creates an uncompressible f32 embedding floor. Even Q2_K quantization produces 690 MB GGUFs that OOM-crash on 4GB Android devices (ADR-012). The only path to 4GB LLM support is vocabulary trimming: reducing 262K tokens to ~21K Tamil-relevant tokens.

An initial trimming experiment (Vazhi_4GB_Optimization.ipynb) successfully:
- Trimmed embed_tokens [262144, 1152] to [21067, 1152]
- Rebuilt tokenizer.json with remapped IDs
- Passed HuggingFace quality checks on 13 Tamil prompts
- Produced GGUF files (Q4_K_M ~505 MB, Q3_K_M ~421 MB)
- Passed harness tests (load + run on 4GB device)

**However, on-device output is English gibberish ("Aki") instead of Tamil.** The HuggingFace model works correctly but the GGUF conversion breaks something.

## Decision

### Labeling: Experimental Status

All vocabulary-trimmed models are labeled `isExperimental: true` in `ModelRegistry` until the GGUF conversion gap is resolved. The UI shows:
- Amber "Experimental" badge in model selector sheet
- Warning text in settings drawer: "Experimental -- output may not work correctly"
- "Experimental" status row in download dialog info card

This sets user expectations while we investigate and fix the root cause.

### Diagnostic Approach: HARD GATE

**No new training runs until the trimmed GGUF matches HuggingFace behavior.**

The diagnostic gap must be resolved first because:
1. The HF model passes quality checks -- this is NOT a model quality problem
2. Training on top of a broken GGUF pipeline wastes GPU hours
3. The root cause is likely in tokenizer conversion, not model weights

### Phase 0: Forensic GGUF Diagnostic (HARD GATE)

Three concrete diagnostic steps:

**Step 1: Tokenization Parity Test**
- Load the trimmed HF tokenizer and the GGUF tokenizer (via llama.cpp's `main --tokenize` mode)
- Feed identical Tamil prompts to both
- Compare token ID sequences
- If IDs differ: the tokenizer conversion is broken (most likely cause)

**Step 2: Deterministic Decode Comparison**
- Run the trimmed HF model with `temperature=0, do_sample=False` on 5 prompts
- Run the trimmed GGUF with `--temp 0 --top-k 1` on the same 5 prompts
- Compare outputs character-by-character
- If HF outputs Tamil but GGUF outputs English: confirms tokenizer/embedding mapping issue

**Step 3: GGUF Metadata Diff**
- Compare `gguf-dump` output of trimmed vs untrimmed GGUF
- Check: vocab size, token count, special token IDs, BOS/EOS values
- Verify chat template tokens (`<start_of_turn>`, `<end_of_turn>`, `<bos>`, `<eos>`) have correct IDs

**Key risks identified:**

1. **Chat template special token remapping**: The notebook filters `added_tokens` by `id < NEW_VOCAB` during tokenizer rebuild. If `<start_of_turn>` or `<end_of_turn>` tokens were reindexed and the GGUF conversion doesn't map them correctly, the model sees garbled prompts at inference time.

2. **llama.cpp version skew**: The llama.cpp version used for GGUF conversion may not handle Gemma 3's trimmed 21K vocab correctly. Gemma 3 SentencePiece has specific merge rules and byte-fallback tokens that older llama.cpp versions may misparse.

### Phase 0 Results (2026-02-18)

Diagnostic script: `tools/gguf_diagnostic.py` (GGUFReader-based metadata + token comparison)

**Test 0 (Versions):** llama-cli b7970 (eb449cdfa), Python 3.14.0, gguf library

**Test 1 (Metadata Diff): PASS**
- `general.architecture: gemma3` — matches
- `tokenizer.ggml.model: llama`, `tokenizer.ggml.pre: default` — matches
- `bos_token_id: 2`, `eos_token_id: 1` — matches
- `tokenizer.chat_template` — MISSING in BOTH models (expected for Gemma 3, but see root cause below)
- Token count: 262,144 (untrimmed) vs 21,067 (trimmed)

**Test 2 (Special Tokens): PASS**
- `<start_of_turn>` (id=105, type=control) — present and correct in BOTH
- `<end_of_turn>` (id=106, type=control) — present and correct in BOTH
- All 7 critical tokens preserved with identical IDs and types
- All 256 byte-fallback tokens present with correct type=6
- 6,251 control tokens identical, only normal tokens trimmed (262K→21K)
- BOS/EOS point to correct tokens in both models

**Test 3 (Deterministic Decode): PASS in completion mode, FAIL in conversation mode**
- `llama-completion --special` (raw Gemma 3 template): **IDENTICAL Tamil output** from both models on all 5 prompts. This proves the GGUF conversion is correct — embeddings, weights, tokenizer all work.
- `llama-cli -cnv -st` (conversation mode): Untrimmed produces Tamil, trimmed produces **0 tokens** (immediate `<end_of_turn>`) for 9/10 prompts. Verbose log confirms: `slot process_toke: stopped by EOS, next token: 106 ''`
- Prompt token count differs: untrimmed=26 tokens, trimmed=33 tokens for the same input. Conversation mode tokenizes the template as literal text (33 tokens for trimmed) instead of as special tokens (11 tokens).

**Test 4 (Token-ID Parity): PASS**
- `<start_of_turn>` → token 105 in BOTH models (same ID preserved)
- `<end_of_turn>` → token 106 in BOTH models (same ID preserved)
- Tamil words tokenize as 2-3 subword tokens (NOT byte-fallback) in both
- All Tamil content tokens correctly remapped to new IDs

### Root Cause: Missing `tokenizer.chat_template` in GGUF

**Two separate failures, one root cause:**

**1. llama-cli conversation mode (Mac/desktop):** Without an explicit `tokenizer.chat_template`, llama-cli uses its built-in Gemma 3 handler. This handler constructs the template and tokenizes it — but for the trimmed vocabulary, the literal character tokens for `<start_of_turn>` map to different IDs that the model doesn't associate with conversation boundaries, causing immediate `<end_of_turn>` generation.

**2. Flutter app / llamadart (Android — the actual production issue):** Without `tokenizer.chat_template` in the GGUF, llamadart's `ChatTemplateEngine.render()` detects `ChatFormat.contentOnly` → falls back to `ChatFormat.generic` → uses **ChatML format** (`<|im_start|>role\nmessage<|im_end|>`). The Gemma 3 model was never trained on ChatML tokens, so it produces gibberish ("Aki"). This is the root cause of the Android gibberish.

Key code path in llamadart (`chat_template_engine.dart:281-305`):
```
templateSource = metadata['tokenizer.chat_template']  // → null
detectChatFormat(null)  // → ChatFormat.contentOnly
// Engine switches to ChatFormat.generic → ChatML template
```

The llamadart `tokenize()` does call `llama_tokenize(parse_special=true)`, so special tokens in the prompt ARE correctly tokenized. The problem is the WRONG template (ChatML instead of Gemma 3) being rendered.

**Fix: Embed the Gemma 3 chat template in the GGUF metadata.** This will:
1. Make llamadart detect Gemma format → use GemmaHandler → correct `<start_of_turn>/<end_of_turn>` prompt
2. Make llama-cli use the explicit template instead of the built-in handler
3. Apply to BOTH trimmed AND untrimmed GGUFs (both are missing the template)

### Phase 1: Fix — Embed Chat Template in GGUF

Based on Phase 0 findings, the fix is to add `tokenizer.chat_template` to the GGUF metadata during conversion. Two approaches:

**Option A (preferred): Add template during GGUF conversion**
- In the trimming notebook, after `convert_hf_to_gguf.py`, use `gguf-py` to write the chat template key
- Template string (Gemma 3 official Jinja2):
  ```
  {% for message in messages %}{% if message['role'] == 'user' %}<start_of_turn>user
  {{ message['content'] }}<end_of_turn>
  <start_of_turn>model
  {% elif message['role'] == 'model' %}{{ message['content'] }}<end_of_turn>
  {% endif %}{% endfor %}
  ```

**Option B (quick fix): Patch existing GGUFs with gguf-new-metadata**
- Use `gguf-new-metadata --chat-template-config tokenizer_config.json` to create patched copies
- No need to re-convert from HuggingFace

### Phase 1 Results (2026-02-18)

Patcher script: `tools/patch_gguf_chat_template.py`

**Method:** Used `gguf-new-metadata --chat-template-config` with the official Gemma 3 `tokenizer_config.json` (from `google/gemma-3-1b-it` on HuggingFace). Creates a copy of each GGUF with the 1,532-char Jinja2 chat template embedded as `tokenizer.chat_template`.

**Files patched (all +1.5 KB):**
- `vazhi-v7_1-q4_k_m.gguf` (806 MB, untrimmed) — SUCCESS
- `vazhi-v7.1-trimmed-q4_k_m.gguf` (505 MB) — SUCCESS
- `vazhi-v7.1-trimmed-q3_k_m.gguf` (421 MB) — SUCCESS
- `vazhi-v7.1-trimmed-q2_k.gguf` (389 MB) — SUCCESS

**Verification — llama-cli conversation mode (`-cnv -st`, `--temp 0 --top-k 1`):**

All 5 prompts on patched trimmed Q4_K_M now produce coherent Tamil:

| Prompt | Before Patch | After Patch |
|--------|-------------|-------------|
| வணக்கம், நீங்கள் யார்? | 0 tokens (immediate EOS) | நான் கூகிளால் பயிற்சி அளிக்கப்பட்ட ஒரு பெரிய மொழி மாதிரி |
| திருக்குறள் பற்றி சொல்லுங்கள் | 0 tokens | Multi-paragraph Tamil explanation of Thirukkural |
| தமிழ்நாட்டின் தலைநகரம் என்ன? | 0 tokens | தமிழ்நாட்டின் தலைநகரம் சென்னை |
| ஒரு குட்டி கதை சொல்லுங்கள் | 0 tokens | Full Tamil short story (boy named கவின் in a village) |
| நன்றி | 0 tokens | உங்களுக்கு நன்றி சொல்லும் போது, நான் மகிழ்ச்சியடைகிறேன் |

All 3 trimmed quant levels (Q4_K_M, Q3_K_M, Q2_K) and the untrimmed Q4_K_M verified working.

**HARD GATE STATUS: CLEARED** — Trimmed GGUF now matches HuggingFace behavior in conversation mode. Phase 2 (progressive trimming) and Phase 3 (recovery SFT) are NOT needed.

**Remaining:** Upload patched GGUFs to HuggingFace, test on 4GB Android device via Flutter app, remove `isExperimental` flag from ModelRegistry if on-device test passes.

### Phase 2: Progressive Trimming (if Phase 1 alone is insufficient)

Instead of jumping from 262K to 21K (92% reduction), test intermediate sizes:
- 262K -> 80K (keep all SentencePiece merge parents)
- 80K -> 50K
- 50K -> 30K
- 30K -> 21K

Each step: convert to GGUF, test on device, verify Tamil output. This identifies the exact trim level where quality breaks, and whether leaf-based pruning (avoiding broken merge rules) helps.

### Phase 3: Recovery SFT (only if needed)

If Phases 0-2 produce a working GGUF but Tamil quality has degraded:
- Generate reference outputs from the untrimmed v7.1 model (self-data distillation)
- LoRA r=8, LR 1e-4, 3-5 epochs on the trimmed model
- Use the v7.0 SFT dataset (4,172 samples) as training data
- Self-data distillation recovers ~91% quality vs ~82% with standard SFT (per COMPACT paper findings)

Recovery SFT is NOT mandatory for mild trims -- the Estonian NLP research shows pruning (keeping existing embeddings) is nearly lossless when the removed tokens are truly unused. It becomes necessary only for aggressive trims where the model shows quality degradation after GGUF conversion is fixed.

## Consequences

### Positive
- Root cause identified: missing `tokenizer.chat_template` in GGUF, NOT model weights or tokenizer mapping
- GGUF conversion is verified correct — embeddings, weights, and tokenizer all function properly
- Fix applied and verified: one metadata key (+1.5 KB), no retraining needed
- Phase 2 (progressive trimming) and Phase 3 (recovery SFT) confirmed unnecessary
- HARD GATE cleared — trimmed GGUF produces identical Tamil to untrimmed in conversation mode
- All 4 GGUFs (1 untrimmed + 3 trimmed quant levels) patched and verified on Mac

### Negative
- Trimmed models remain Experimental until verified on Android device via Flutter app
- Patched GGUFs need to be re-uploaded to HuggingFace for deployment

### Neutral
- SQLite-only path for sub-4GB devices is unaffected (ADR-012)
- Once the template fix is applied, trimmed models should produce identical Tamil output to untrimmed

## References

- ADR-012: 4GB SQLite-Only Architecture
- ADR-013: Smart Model Selection
- Notebook: `notebooks/Vazhi_4GB_Optimization.ipynb` (trimming implementation)
- Diagnostic: `tools/gguf_diagnostic.py` (Phase 0 automated metadata + token comparison)
- Patcher: `tools/patch_gguf_chat_template.py` (Phase 1 chat template injection via gguf-new-metadata)
- llamadart template engine: `vazhi_app/packages/llamadart/lib/src/core/template/chat_template_engine.dart`
- llamadart tokenization: `vazhi_app/packages/llamadart/lib/src/backends/llama_cpp/llama_cpp_service.dart:1194-1222`
- Kaitchup: Gemma 3 270M 262K->64K vocab trimming maintained quality after fine-tuning
- SqueezeBits: Gemma 3 1B-it language-only trim nearly lossless
- COMPACT paper: Joint vocab+channel pruning with self-data distillation
- Estonian NLP: Pruning >> retraining with new embeddings
