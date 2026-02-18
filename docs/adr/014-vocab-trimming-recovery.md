# ADR-014: Vocabulary Trimming Diagnostic & Recovery Plan

## Status
Proposed

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

### Phase 1: Fix Conversion

Based on Phase 0 findings:
- If tokenizer parity fails: fix the tokenizer.json rebuild (likely special token ID mapping)
- If metadata is wrong: fix the `convert_hf_to_gguf.py` invocation or use a newer llama.cpp
- If both pass but output still differs: investigate embedding/lm_head weight mapping

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
- Users see "Experimental" badge and know to expect imperfect output from trimmed models
- HARD GATE prevents wasting GPU training hours on a conversion bug
- Progressive trimming will identify the exact break point
- Self-data distillation provides a proven recovery path if needed

### Negative
- Trimmed models are usable but with a warning until diagnostic is complete
- Delays the "trimmed models work perfectly" milestone

### Neutral
- Untrimmed q4_k_m (806 MB) for 6GB+ devices is unaffected
- SQLite-only path for sub-4GB devices is unaffected (ADR-012)

## References

- ADR-012: 4GB SQLite-Only Architecture
- ADR-013: Smart Model Selection
- Notebook: `notebooks/Vazhi_4GB_Optimization.ipynb` (trimming implementation)
- Kaitchup: Gemma 3 270M 262K->64K vocab trimming maintained quality after fine-tuning
- SqueezeBits: Gemma 3 1B-it language-only trim nearly lossless
- COMPACT paper: Joint vocab+channel pruning with self-data distillation
- Estonian NLP: Pruning >> retraining with new embeddings
