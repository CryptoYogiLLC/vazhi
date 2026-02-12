# VAZHI Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records for the VAZHI project.

## What is an ADR?

An Architecture Decision Record captures an important architectural decision made along with its context and consequences. ADRs help us:
- Understand why decisions were made
- Onboard new contributors
- Revisit decisions when context changes

## ADR Index

| ADR | Title | Status | Summary |
|-----|-------|--------|---------|
| [001](001-hybrid-app-strategy.md) | Hybrid App Strategy | **Superseded** by 009 | Two-variant strategy replaced by single-app hybrid retrieval |
| [002](002-flutter-framework-selection.md) | Flutter Framework Selection | Accepted | Use Flutter for cross-platform development |
| [003](003-community-whatsapp-engagement.md) | Community WhatsApp Engagement | Accepted | WhatsApp for feedback and community content creation |
| [004](004-huggingface-spaces-backend.md) | HuggingFace Spaces Backend | Partially Stale | Free HuggingFace Spaces — now dev/testing only, not production |
| [005](005-incremental-pack-downloads.md) | Incremental Pack Downloads | **Superseded** by 009 | LoRA pack downloads replaced by bundled SQLite data |
| [006](006-voice-integration-strategy.md) | Voice Integration Strategy | Accepted | Native platform STT/TTS for voice input/output |
| [007](007-free-donations-monetization.md) | Free + Donations Monetization | Accepted | 100% free app with optional donation support |
| [008](008-app-store-distribution.md) | App Store Distribution | Accepted | Google Play + Apple App Store + F-Droid |
| [009](009-hybrid-retrieval-architecture.md) | Hybrid Retrieval Architecture | **Accepted (Current)** | Deterministic SQLite + optional AI — 10 categories, 232 tests |

### Superseded & Stale ADRs

**ADR-001 (Superseded):** Originally proposed two app variants (VAZHI Lite + VAZHI Full) as separate APKs. The hybrid retrieval architecture (ADR-009) eliminated this need — a single app works offline from install via SQLite, with the AI model as an optional download. No separate Lite variant is needed.

**ADR-005 (Superseded):** Originally proposed downloading a base GGUF model plus separate LoRA adapter packs (~60MB each) per domain. In practice, all domain knowledge is bundled as SQLite data (~1.5MB) within the app. The AI model is a single optional GGUF download, not per-domain LoRA adapters.

**ADR-004 (Partially Stale):** The HF Space was designed as the VAZHI Lite production backend. With ADR-001 superseded, it's now used for dev/testing only. The Gradio setup and deployment approach remain valid for that purpose. Model refs are outdated (now Qwen3-0.6B-Base, not Qwen2.5-3B).

## Key Decisions Summary

### Target Audience
- **Primary**: Tamil speakers in Tamil Nadu
- **Device**: Mid-range smartphones (4GB+ RAM for Full version)
- **Connectivity**: Both online (urban) and offline (rural) users

### Technology Choices
- **Framework**: Flutter (Dart)
- **Architecture**: Hybrid Retrieval (Deterministic SQLite + Optional AI)
- **LLM Inference**: llamadart (GGUF format) for offline, HuggingFace for cloud
- **Voice**: Native platform APIs (speech_to_text, flutter_tts)
- **Backend**: HuggingFace Spaces with Gradio

### Business Model
- **Price**: Free forever
- **Revenue**: Voluntary donations
- **Distribution**: Official app stores ($124 year 1, $99/year after)

## Creating New ADRs

When making significant architectural decisions:

1. Copy the template below
2. Number sequentially (e.g., `009-new-decision.md`)
3. Fill in all sections
4. Get team consensus before marking "Accepted"

### ADR Template

```markdown
# ADR-XXX: [Title]

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Date
YYYY-MM-DD

---

## Context
[What is the issue we're seeing that motivates this decision?]

## Decision
[What is the decision we're making?]

## Consequences
### Positive
[What are the benefits?]

### Negative
[What are the drawbacks?]

## Alternatives Considered
[What other options were evaluated?]

## Related
[Links to related ADRs or documents]
```

## Related Documentation

- [VAZHI Mobile Architecture](../architecture/VAZHI_MOBILE_ARCHITECTURE.md)
- [Project README](../../README.md)
