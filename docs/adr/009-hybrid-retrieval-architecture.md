# ADR-009: Hybrid Retrieval Architecture

## Status
**Accepted** - 2026-02-08 | **Last Updated:** 2026-02-11

> **Note (Feb 2026):** Model target is Qwen3-0.6B-Base (<1GB GGUF), not the originally referenced Gemma-2B. See `models/TRAINING_LOG.md` for training status. This ADR supersedes [ADR-001](001-hybrid-app-strategy.md) (two-variant strategy) and [ADR-005](005-incremental-pack-downloads.md) (LoRA pack downloads) — the hybrid retrieval architecture solved both problems with a single app and bundled SQLite data.

## Context

VAZHI is designed as an offline-first Tamil AI assistant. The core challenge is:

1. **Model size**: The target LLM is <1GB GGUF (currently Qwen3-0.6B-Base)
2. **App store limits**: Play Store recommends <150 MB initial download
3. **User acquisition**: Large apps have lower install rates
4. **Inference costs**: Cloud fallback would incur ongoing API costs
5. **Data accuracy**: Factual data (Thirukkural verses, phone numbers) must never be hallucinated

We need an architecture that:
- Provides immediate value without the model download
- Ensures 100% accuracy for factual/reference data
- Reserves AI capabilities for interpretation and conversation
- Encourages (but doesn't force) model download

## Decision

Implement a **Hybrid Retrieval Architecture** with two distinct paths:

### 1. Deterministic Path (No Model Required)
- Exact lookup from structured local database
- Pattern-matched query routing
- Zero hallucination risk for factual data
- Works immediately after app install

### 2. AI-Enhanced Path (Model Required)
- Natural language understanding
- Contextual explanations
- Follow-up conversations
- Complex reasoning and advice

### Query Flow

```
User Query
    │
    ▼
┌─────────────────┐
│  Query Router   │ ◄── Rule-based pattern matching
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐ ┌───────┐
│ SQLite│ │  LLM  │
│Lookup │ │Inference│
└───┬───┘ └───┬───┘
    │         │
    └────┬────┘
         ▼
┌─────────────────┐
│ Response Builder│ ◄── Combines structured data + AI explanation
└─────────────────┘
```

### Query Types

| Type | Route | Description | Example |
|------|-------|-------------|---------|
| **Deterministic** | SQLite only | Exact lookups, keyword-only queries | "குறள் 1", "emergency numbers", "RTI" |
| **Hybrid** | SQLite + LLM | Category keyword + conversational pattern | "how to file RTI?", "why is scholarship important?" |
| **AI Required** | LLM only | No category match, pure conversation | "What should I study?", "tell me about yourself" |

### Routing Logic

The query router uses a two-step classification: (1) detect category keywords, then (2) check for conversational patterns via `_needsExplanation()` (detects "how", "why", "explain", "what is", etc.).

| Query Pattern | Route | Example |
|---------------|-------|---------|
| Category keyword only | Deterministic | "குறள் 1", "RTI", "OTP மோசடி" |
| Category keyword + conversational pattern | Hybrid | "how to file RTI?", "explain குறள் 1" |
| List/browse request | Deterministic | "அதிகாரங்கள் list", "TN schemes" |
| No category match | AI Required | "What should I study?", "Is this message safe?" |

## Consequences

### Positive
1. **Immediate value**: App is useful from first launch
2. **Zero hallucination**: Factual data is always accurate
3. **Reduced inference**: Less battery/CPU usage
4. **Smaller initial download**: Higher install conversion
5. **No cloud costs**: No inference API expenses
6. **Better UX**: Instant responses for lookups

### Negative
1. **More complex architecture**: Two code paths to maintain
2. **Data maintenance**: Need to update structured data periodically
3. **Limited without model**: AI features gated behind download

### Neutral
1. **Storage**: ~2 MB for structured data (acceptable)
2. **Query routing**: Simple pattern matching (no ML needed)

## Data Categories

### Deterministic (Structured SQLite Data)
| Category | Data Type | Records | Service |
|----------|-----------|---------|---------|
| Thirukkural | Verses + athikarams | 1,330 | ThirukkuralService |
| Schemes | Govt schemes + eligibility + documents | 14+ | SchemeService |
| Emergency | National + district contacts | 30+ | EmergencyService |
| Health | Hospitals + facilities | 25+ | HealthcareService |
| Safety | Scam patterns + cyber safety tips | 40 | GenericDataService |
| Education | Scholarships + competitive exams | 35 | GenericDataService |
| Legal | Legal rights + templates | 35 | GenericDataService |
| Siddha Medicine | Traditional remedies | 20 | GenericDataService |
| Festivals | Tamil festivals | 15 | GenericDataService |
| Siddhars | Siddhar biographies | 18 | GenericDataService |
| **Total** | **10 categories** | **~390+** | **~1.5 MB** |

All data is bundled with the app in SQL files and loaded into SQLite with FTS5 indexing at first launch. No downloads required.

### AI-Enhanced (LLM adds explanation to SQLite results)
- Contextual explanations of factual data
- Follow-up conversations about retrieved content
- Comparative analysis across categories

### AI-Required (LLM Only)
- Personalized advice with no category match
- Ambiguous query interpretation
- Creative responses

## Alternatives Considered

### 1. Cloud Inference Fallback
**Rejected**: Incurs ongoing costs, defeats offline-first principle, requires internet.

### 2. Bundle Model in App
**Rejected**: 1.7 GB app size would drastically reduce installs.

### 3. AI-Only (No Structured Data)
**Rejected**: Risk of hallucinating factual data like phone numbers, verses.

### 4. Structured Data Only (No AI)
**Rejected**: Loses the conversational/explanatory value proposition.

## Implementation Notes

1. **Database**: SQLite for complex queries, relationships, and FTS5 full-text search
2. **Query Router**: Dart-based pattern matching, no external dependencies
3. **Response Builder**: Combines SQLite results with optional AI enhancement
4. **UI State**: Show "Download AI" prompts when AI path is triggered without model
5. **Caching**: Cache AI explanations for common queries to reduce re-inference

## Implementation Status

### Completed (all items as of v0.5.1, 2026-02-11)
- Query Router with 10 category matchers + `_needsExplanation()` hybrid check (`lib/services/query_router.dart`)
- Retrieval Services (`lib/services/retrieval/`)
  - ThirukkuralService — verse/athikaram lookup, search, random
  - SchemeService — schemes, eligibility, documents, by level
  - EmergencyService — contacts by type, district, national
  - HealthcareService — hospitals by district, type, CMCHIS, emergency
  - GenericDataService — scams, cyber safety, scholarships, exams, legal rights, legal templates, siddha medicine, festivals, siddhars
- Hybrid Chat Provider (`lib/providers/hybrid_chat_provider.dart`)
- Knowledge Result Cards with expand/collapse and bilingual UI (`lib/widgets/knowledge_result_card.dart`)
- Hybrid Message Bubble with bilingual labels (`lib/widgets/hybrid_message_bubble.dart`)
- Model Status Indicator (`lib/widgets/model_status_indicator.dart`)
- Model Download Service with pause/resume (`lib/services/model_download_service.dart`)
- Full Thirukkural database (1,330 verses)
- Government schemes database (14+ schemes with eligibility and documents)
- FTS5 search with triggers and bulk population
- All 10 knowledge categories populated with ~390 records
- 232 tests passing (unit, integration, widget, security)

## Related ADRs
- [ADR-001: Hybrid App Strategy](001-hybrid-app-strategy.md)
- [ADR-004: HuggingFace Spaces Backend](004-huggingface-spaces-backend.md)
- [ADR-005: Incremental Pack Downloads](005-incremental-pack-downloads.md)

## References
- Architecture Document: `/docs/architecture/VAZHI_MOBILE_ARCHITECTURE.md`
- Data Schema: `/vazhi_app/docs/data_schema.md`
- Training Log: `/models/TRAINING_LOG.md`
