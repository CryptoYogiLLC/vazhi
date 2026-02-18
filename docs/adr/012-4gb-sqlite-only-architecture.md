# ADR-012: 4GB Devices — SQLite-Only Architecture (No On-Device LLM)

## Status
**Accepted** - 2026-02-17

## Date
2026-02-17

---

## Context

VAZHI targets rural Tamil Nadu users with mid-range smartphones. Many budget Android devices ship with 4GB RAM (3.9 GB usable). After extensive testing, **no Gemma 3 model can run on 4GB Android devices** — including the smallest available (270M-it at 264 MiB).

### Models Tested on 4GB Android (3.9 GB total, ~1.3 GB available)

| Model | GGUF Size | Context | Result |
|-------|-----------|---------|--------|
| Gemma 3 1B-it Q4_K_M | 762 MiB | Flutter app | **Crash** (OOM during forward pass) |
| Gemma 3 1B-it Q2_K | 652 MiB | Flutter app | **Crash** (OOM during forward pass) |
| Gemma 3 270M-it Q6_K_L | 264 MiB | Flutter app | **Crash** (OOM during forward pass) |
| Gemma 3 270M-it Q6_K_L | 264 MiB | llama-simple (no Flutter) | **SUCCESS** — 12.3 tok/s, 5.1s for 32 tokens |
| **VAZHI v7.1 Trimmed Q2_K** | **389 MB** | **llama-simple (no Flutter)** | **SUCCESS** — 3.25 tok/s, 10.1s for 32 tokens, only 12 MB RAM consumed |
| **VAZHI v7.1 Trimmed Q3_K_M** | **421 MB** | **llama-simple (no Flutter)** | **SUCCESS** — 4.03 tok/s, 5.7s for 23 tokens, only 16 MB RAM consumed |
| **VAZHI v7.1 Trimmed Q4_K_M** | **505 MB** | **llama-simple (no Flutter)** | **SUCCESS** — 3.42 tok/s, 6.8s for 32 tokens, only 25 MB RAM consumed |

Flutter app tests crash during forward pass. Harness tests (llama-simple without Flutter) prove the 270M-it, **trimmed 1B-it v7.1 Q2_K**, and **trimmed 1B-it v7.1 Q3_K_M** all fit in memory. Flutter's ~640 MB overhead is the bottleneck, but with only 12-16 MB consumed by the trimmed models via mmap, the **combined trimmed model + Flutter may fit**. **Q3_K_M is the recommended 4GB variant** — 32 MB larger than Q2_K but dramatically better Tamil quality (recovers 3 domain answers Q2_K loses).

### Root Cause — UPDATED (Harness Test 2026-02-17)

**Flutter app overhead (~640 MB) is the primary cause, NOT model size alone.**

Harness test (llama-simple via adb, no Flutter) on JK68 (3.9 GB total, 1.3 GB available):
- **Gemma 3 270M-it Q6_K_L (264 MiB) runs successfully** — 12.3 tok/s, no OOM, 5.1s for 32 tokens
- Memory used: ~264 MiB model + ~19 MiB compute = ~283 MiB (well within 1.3 GB available)
- The **same model crashes inside the Flutter app** — Flutter overhead (~640 MB) pushes total to ~923 MB, competing with ~1.3 GB available and triggering Android OOM killer

Contributing factors:
- **Flutter app overhead** (~640 MB for Dart VM, widgets, worker isolate) is the dominant memory consumer
- **262K embedding matrix** stored as f32 tensors — does not shrink with quantization (but is not the OOM cause alone)
- **Forward pass working set ≈ entire model** — mmap pages in lazily but every layer is touched

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
- **Flutter app overhead is CONFIRMED as the bottleneck** — harness test (2026-02-17) proved 270M-it runs fine without Flutter (12.3 tok/s). This means reducing Flutter overhead (lighter native wrapper, memory-optimized Flutter build, or background isolate approach) could enable LLM on 4GB devices
- **SQLite data completeness** — the deterministic path must provide comprehensive, paginated answers (not truncated "and more details" stubs) to be a viable standalone experience

## Future Options for 4GB LLM Support

| Option | Projected Size | Feasibility | Status |
|--------|---------------|-------------|--------|
| Vocabulary trimming (262K→~21K) | Q4_K_M 505 MB, Q3_K_M 421 MB, Q2_K 389 MB | High — weights trimmed, tokenizer rebuilt | **All 3 variants run on 4GB device.** Q4_K_M (505 MB, 3.42 tok/s, 25 MB RAM) = best quality. Q3_K_M (421 MB, 4.03 tok/s, 16 MB RAM) = best speed/quality tradeoff. Q2_K (389 MB, 3.25 tok/s) loses 3 domain answers |
| Reduce Flutter overhead | N/A (app optimization) | Medium — requires profiling Dart VM memory | **Key path** — harness test proved model fits, Flutter overhead is the only remaining blocker |
| imatrix quantization | Same size, no quality gain | Dead end | **Tested** — zero size reduction, -2.4% Tamil quality at Q2_K |
| Embed/output Q8_0 quantization | Same size | Dead end | **Tested** — identical files, 262K tensors already stored optimally |
| Wait for smaller Gemma variant | Unknown | Depends on Google | Speculative |
| Alternative model with smaller vocab | Varies | Quality tradeoff | Researching |

## Related
- [ADR-009](009-hybrid-retrieval-architecture.md) — Hybrid retrieval architecture (the SQLite-only tier leverages this)
- [ADR-011](011-model-selector-architecture.md) — Model selector (shows RAM recommendations per variant)
- `models/TRAINING_LOG.md` — 4GB Device Testing section with full crash analysis
- `docs/LESSONS_LEARNED.md` — Lessons #110-117 on 4GB OOM findings
