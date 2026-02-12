# ADR-010: Data Pipeline Architecture

## Status
**Accepted** - 2026-02-12

## Context

VAZHI's training data is fragmented across multiple locations with no clear pipeline:

1. **Format mixing** — `data/tamil_foundation/` mixes DAPT corpus files (raw text for continued pretraining) with SFT instruction pairs (ChatML Q&A). This caused the v3.1 failure ("systemsystemsystem..." garbage output).

2. **vazhi-packs excluded** — The 6 curated domain packs (3,007 Q&A pairs) in `vazhi-packs/` are NOT in the training pipeline. The v3.3/v3.6 datasets were constructed from the older `vazhi-tamil-v05` HuggingFace dataset, missing all pack improvements.

3. **IndicAlign never persisted** — The `create_diverse_qa_pack.py` script was designed to fetch IndicAlign diversity samples, but the `diverse_qa_pack/` directory is empty. These samples only exist transiently in HuggingFace datasets.

4. **No local backup** — Curated training datasets exist ONLY on HuggingFace. If HF goes down or the dataset is accidentally overwritten, there is no local copy.

5. **Thirukkural dominance** — Thirukkural is 72.3% of local SFT data, creating massive memorization risk. The model should NOT memorize exact verses (SQLite handles that); it should learn to interpret and explain.

6. **No compute locally** — All training runs on Kaggle/Colab. The pipeline must separate local data curation from remote training execution.

## Decision

Establish a **four-layer data pipeline**: Source Data (local) → Dataset Factory (Kaggle) → Training (Kaggle) → Artifacts (HuggingFace), with local backups.

### Layer 1: Source Data (Local — `data/sources/`)

All raw training inputs, organized by intended use:

```
data/sources/
  dapt/           # Raw Tamil text for continued pretraining (NEVER for SFT)
  sft/
    vazhi-packs/  # Flattened Q&A from 6 domain packs
    handcrafted/  # Refusal, brevity, greeting, guardrail samples
  metadata/       # source_manifest.json with intended_use per file
```

**Key rule:** DAPT and SFT data are physically separated. The `intended_use` field in `source_manifest.json` provides a second layer of protection — the Dataset Factory validates this before loading.

### Layer 2: Dataset Factory (Kaggle — `notebooks/Vazhi_Dataset_Factory_v4_0.ipynb`)

A notebook that runs on Kaggle/Colab and constructs the curated SFT dataset from all sources:

1. Loads vazhi-packs (flattened from `data/sources/sft/vazhi-packs/`)
2. Streams IndicAlign diversity samples from `ai4bharat/indic-align`
3. Loads handcrafted samples (refusal, brevity, greeting, guardrails)
4. Loads general knowledge Q&A from LEGACY files
5. Applies anti-memorization filter for Thirukkural verbatim Q&As
6. **Hard-enforces** composition targets (fails if violated)
7. Creates stratified train/eval split (90/10) by source bucket
8. Uploads to HuggingFace with version tracking

**Composition targets (hard constraints — Factory fails if violated):**

| Bucket | Target | Min | Max | Source |
|--------|--------|-----|-----|--------|
| Domain packs | 45% | 40% | 50% | vazhi-packs (6 packs) |
| IndicAlign | 30% | 25% | 35% | ai4bharat/indic-align |
| Kural interpretive | 15% | 0% | 15% | Thirukkural Q&A (non-verbatim only) |
| Handcrafted | 3% | 2% | 5% | Refusal, brevity, greeting, guardrails |
| General | 7% | 5% | 10% | Dialect, health, emotion Q&A from LEGACY |

**Total target:** ~5,000 samples

### Layer 3: Training (Kaggle — existing `Vazhi_SFT_v3_x` notebooks)

Consumes the curated dataset from HuggingFace. No data construction logic — just loads `CryptoYogi/vazhi-tamil-sft-v4_0` and trains.

### Layer 4: Artifacts (HuggingFace)

- Curated datasets: `CryptoYogi/vazhi-tamil-sft-v4_0` (with `train` and `validation` splits)
- Trained models: `CryptoYogi/vazhi-qwen3-v4_0`
- Local backups: `data/curated/` (downloaded from HF with revision SHA)

### Anti-Memorization Rules

1. **Thirukkural verbatim Q&As are rejected** — Q&As that ask for exact verse text go to SQLite, not the model
2. **Expanded filter** catches: "குறள் N என்ன/சொல்லு/எழுதி", "முதல் குறள் என்ன", raw couplet answers without explanation markers
3. **Only interpretive Q&As pass** — "குறள் 1 பற்றி விளக்கு", "இந்த குறளின் பொருள் என்ன?"
4. **Hard cap at 15%** — even after filtering, Kural content cannot exceed 15% of the dataset

### Stratified Eval Split

The 90/10 train/eval split is stratified by source bucket. Each sample carries a `"bucket"` field (e.g., `"domain_packs"`, `"indicalign"`) so the eval set proportionally represents all data sources. This prevents eval being dominated by any single source.

### Legacy Data Handling

All pre-pipeline data moves to `data/LEGACY/` (read-only archive):
- `data/tamil_foundation/` → `data/LEGACY/` (everything except corpus files)
- `data/archive/` → `data/LEGACY/archive/`
- `data/v04/` → `data/LEGACY/v04/`
- Corpus files (36-40) extracted to `data/sources/dapt/` before the move

Legacy scripts (`create_diverse_qa_pack.py`, `create_balanced_sft_dataset.py`) raise `RuntimeError` if executed directly, pointing to the Dataset Factory notebook.

## Consequences

### Positive
1. **No more format mixing** — DAPT and SFT physically separated, validated by manifest
2. **vazhi-packs in training** — 3,007 curated Q&A pairs finally enter the pipeline
3. **IndicAlign diversity** — 30% minimum prevents memorization and improves generalization
4. **Reproducible** — Dataset Factory notebook produces identical output from same inputs
5. **Local backups** — HuggingFace datasets backed up locally with revision tracking
6. **Hard composition enforcement** — Factory fails loudly if targets are violated, preventing silent regression

### Negative
1. **Two-step process** — must run Factory before training (extra Kaggle session)
2. **IndicAlign dependency** — streaming from HuggingFace requires internet on Kaggle (always available)
3. **More files to maintain** — flattened pack files duplicate information from vazhi-packs

### Neutral
1. **Storage** — flattened packs add ~2MB, well within git limits
2. **Migration** — one-time restructure via `git mv`, fully reversible

## Alternatives Considered

### 1. Single Monolithic Dataset Script
**Rejected**: Mixing all data construction into one local script doesn't work because (a) IndicAlign requires HuggingFace streaming (needs GPU environment), and (b) local scripts can't validate on-device model output quality.

### 2. Keep Current Structure + Add Validation
**Rejected**: The current structure is fundamentally broken — DAPT and SFT files live in the same directory with no metadata distinguishing them. Adding validation on top would be a band-aid; physical separation is the correct fix.

### 3. Move Everything to HuggingFace
**Rejected**: Source data should live in git for version control and local development. HuggingFace is for computed artifacts (curated datasets, trained models), not source inputs.

## Related ADRs
- [ADR-001: Hybrid App Strategy](001-hybrid-app-strategy.md)
- [ADR-009: Hybrid Retrieval Architecture](009-hybrid-retrieval-architecture.md)

## References
- Training Log: `/models/TRAINING_LOG.md`
- Lessons Learned: `/docs/LESSONS_LEARNED.md`
- Dataset Factory: `/notebooks/Vazhi_Dataset_Factory_v4_0.ipynb`
