# ADR-005: Hybrid Retrieval Architecture

## Status
**Accepted** - 2026-02-08

## Context

VAZHI is designed as an offline-first Tamil AI assistant. The core challenge is:

1. **Model size**: The LLM (Gemma-2B Tamil Q4_K_M) is 1.63 GB
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

### Routing Logic

| Query Pattern | Route | Example |
|---------------|-------|---------|
| Exact reference lookup | Deterministic | "குறள் 1", "CMCHIS phone number" |
| List/browse request | Deterministic | "அதிகாரங்கள் list", "TN schemes" |
| Explanation request | AI | "குறள் 1 meaning", "explain RTI" |
| How-to questions | AI | "How to apply for ration card?" |
| Advice/analysis | AI | "Is this a scam?", "What should I study?" |
| Hybrid (retrieve + explain) | Both | "குறள் 1 அர்த்தம் என்ன?" |

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
1. **Storage**: ~10-15 MB for structured data (acceptable)
2. **Query routing**: Simple pattern matching (no ML needed)

## Data Categories

### Deterministic (Structured Data)
| Pack | Data Type | Records | Storage |
|------|-----------|---------|---------|
| Culture | Thirukkural verses | 1,330 | ~500 KB |
| Culture | Siddhars info | 18 | ~20 KB |
| Culture | Festivals | ~50 | ~30 KB |
| Govt | Schemes | ~100 | ~200 KB |
| Govt | Documents | ~30 | ~50 KB |
| Education | Scholarships | ~50 | ~100 KB |
| Education | Institutions | ~200 | ~150 KB |
| Legal | Templates | ~20 | ~50 KB |
| Legal | Rights info | ~50 | ~80 KB |
| Health | Hospitals | ~500 | ~200 KB |
| Health | Siddha remedies | ~100 | ~80 KB |
| Security | Scam patterns | ~50 | ~50 KB |
| Security | Emergency contacts | ~30 | ~20 KB |
| **Total** | | ~2,500+ | **~1.5 MB** |

### AI-Required (LLM Only)
- Personalized advice
- Complex explanations
- Comparative analysis
- Follow-up conversations
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

## Related ADRs
- ADR-003: SLM Approach (model selection)
- ADR-004: Mixed Training Format (training data)

## References
- Training Log: `/models/TRAINING_LOG.md`
- Data Schema: `/vazhi_app/docs/data_schema.md`
