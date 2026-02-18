# ADR-012: 4GB Devices — SQLite-Only Architecture (No On-Device LLM)

## Status
**Accepted** - 2026-02-17

## Date
2026-02-17

---

## Context

VAZHI targets rural Tamil Nadu users with mid-range smartphones. Many budget Android devices ship with 4GB RAM (3.9 GB usable). After extensive testing, **no Gemma 3 model can run on 4GB Android devices** — including the smallest available (270M-it at 264 MiB).

### Models Tested on 4GB Android (3.9 GB total, ~1.4 GB available)

| Model | GGUF Size | Params | OOM Score | Result |
|-------|-----------|--------|-----------|--------|
| Gemma 3 1B-it Q4_K_M | 762 MiB | 999.89M | 772 | **Crash** |
| Gemma 3 1B-it Q2_K | 652 MiB | 999.89M | 757 | **Crash** |
| Gemma 3 270M-it Q6_K_L | 264 MiB | 268.1M | 718 | **Crash** |

All tests follow the same pattern: model loads via mmap, context creates, prompt ingestion starts, then Android OOM killer terminates the process during the forward pass.

### Root Cause

Gemma 3's 262K vocabulary creates an uncompressible memory floor:
- **262K embedding matrix** stored as f32 tensors — does not shrink with quantization
- **Forward pass working set ≈ entire model** — mmap pages in lazily but every layer is touched
- **Flutter app overhead** (~640 MB for Dart VM, widgets, worker isolate) competes for the same ~1.4 GB available
- **Even 264 MiB (270M-it) + 640 MB Flutter = ~900 MB**, leaving only ~500 MB for compute buffers, OS, and other processes — insufficient for inference

### Why Not a Different Model?

The 262K vocabulary is what gives Gemma 3 its excellent Tamil capability (96% Tamil word score). Models with smaller vocabularies (e.g., Qwen3-0.6B with 151K) have significantly worse Tamil quality (proven in 20 failed training attempts). The vocabulary size is inseparable from the Tamil quality.

## Decision

Adopt a **two-tier deployment architecture**:

### Tier 1: 4GB Devices — SQLite Retrieval Only
- **No on-device LLM** — the app does not offer model download on 4GB devices
- **Hybrid SQLite retrieval** handles all queries via deterministic lookups
- 6 knowledge packs (3,007 bilingual entries) provide offline value
- Query router classifies queries and routes to appropriate SQLite lookups
- Knowledge result cards display structured data with full details (paginated)

### Tier 2: 6GB+ Devices — On-Device LLM + SQLite
- **Gemma 3 1B-it v7.1 Q4_K_M** (762 MiB) as default model
- Additional quant variants (Q3_K_M, Q2_K) for user choice
- Non-VAZHI models (QAT Q2_K, 270M Q6_K_L) available for testing/experimentation
- System prompt handles VAZHI identity at inference time
- Hybrid SQLite retrieval provides factual accuracy alongside LLM responses

### Architecture

```
User Query → Query Router
    │
    ├── [4GB Device]
    │   └── SQLite Lookup → Knowledge Result Cards (paginated, full info)
    │
    └── [6GB+ Device]
        ├── Deterministic queries → SQLite Lookup → Knowledge Result Cards
        ├── Hybrid queries → SQLite + LLM → Combined Response
        └── Conversational queries → LLM → AI Response
```

### Detection Strategy (Future Enhancement)

Currently, the app shows all model variants with RAM recommendations. A future enhancement could auto-detect device RAM and:
- Hide the model download option on <4GB devices
- Auto-select the appropriate model variant on 6GB+ devices
- Show a banner explaining why LLM is unavailable on low-RAM devices

## Consequences

### Positive
- **4GB users still get value** — offline SQLite lookups for Thirukkural, government schemes, emergency numbers, etc.
- **No misleading download prompts** — users on 4GB devices won't download a model that crashes
- **Clear architectural boundary** — SQLite retrieval path is well-tested and reliable
- **Progressive enhancement preserved** — same app codebase, different capability tiers
- **Honest UX** — no "AI mode" that crashes; users get what works

### Negative
- **Reduced capability on 4GB** — no conversational AI, no open-ended questions
- **Two tiers to maintain** — must ensure SQLite-only path provides complete, useful responses
- **User expectations** — "AI assistant" marketing may disappoint 4GB users who can't access AI features

### Risks
- **Flutter app overhead unverified** — a harness test (llama.cpp CLI via adb) should confirm whether the crash is purely model vs RAM, or if Flutter's ~640 MB overhead is a significant factor. If Flutter overhead is the dominant factor, a lighter native wrapper could enable 270M on 4GB
- **SQLite data completeness** — the deterministic path must provide comprehensive, paginated answers (not truncated "and more details" stubs) to be a viable standalone experience

## Future Options for 4GB LLM Support

| Option | Projected Size | Feasibility | Status |
|--------|---------------|-------------|--------|
| Vocabulary trimming (262K→~50K) | ~300 MiB Q4_K_M | High — SqueezeBits (2025) tested on Gemma 3 1B-it | Planned experiment |
| imatrix quantization | Same size, better quality | Medium — helps quality not size | In progress |
| Wait for smaller Gemma variant | Unknown | Depends on Google | Speculative |
| Alternative model with smaller vocab | Varies | Quality tradeoff | Researching |

## Related
- [ADR-009](009-hybrid-retrieval-architecture.md) — Hybrid retrieval architecture (the SQLite-only tier leverages this)
- [ADR-011](011-model-selector-architecture.md) — Model selector (shows RAM recommendations per variant)
- `models/TRAINING_LOG.md` — 4GB Device Testing section with full crash analysis
- `docs/LESSONS_LEARNED.md` — Lessons #110-117 on 4GB OOM findings
