# VAZHI Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records for the VAZHI project.

## What is an ADR?

An Architecture Decision Record captures an important architectural decision made along with its context and consequences. ADRs help us:
- Understand why decisions were made
- Onboard new contributors
- Revisit decisions when context changes

## ADR Index

| ADR | Title | Status | Freshness | Summary |
|-----|-------|--------|-----------|---------|
| [001](001-hybrid-app-strategy.md) | Hybrid App Strategy | Accepted | Current | Two app variants: VAZHI Lite (cloud) + VAZHI Full (offline) |
| [002](002-flutter-framework-selection.md) | Flutter Framework Selection | Accepted | Current | Use Flutter for cross-platform development |
| [003](003-community-whatsapp-engagement.md) | Community WhatsApp Engagement | Accepted | Current | WhatsApp for feedback and community content creation |
| [004](004-huggingface-spaces-backend.md) | HuggingFace Spaces Backend | Accepted | **Partially Stale** | Free HuggingFace Spaces — now dev/testing only, not production |
| [005](005-incremental-pack-downloads.md) | Incremental Pack Downloads | Accepted | **Partially Stale** | Base + Pick Packs strategy — model size refs (1.7GB) are outdated |
| [006](006-voice-integration-strategy.md) | Voice Integration Strategy | Accepted | Current | Native platform STT/TTS for voice input/output |
| [007](007-free-donations-monetization.md) | Free + Donations Monetization | Accepted | Current | 100% free app with optional donation support |
| [008](008-app-store-distribution.md) | App Store Distribution | Accepted | Current | Google Play + Apple App Store + F-Droid |
| [009](009-hybrid-retrieval-architecture.md) | Hybrid Retrieval Architecture | Accepted | **Partially Stale** | Deterministic SQLite + AI paths — Gemma-2B ref outdated, now Qwen3-0.6B |

### Staleness Notes

Three ADRs contain outdated model references from earlier in the project. Each has an inline note at the top explaining what changed. The **architectural decisions themselves remain valid** — only specific model names and sizes are outdated.

- **ADR-004**: References Qwen2.5-3B (1.7GB). Current target is Qwen3-0.6B-Base (<1GB). Also, the HF Space is now used for dev/testing only, not as a production backend.
- **ADR-005**: Size calculations reference 1.7GB base model. Need recalculation once final GGUF size is known. The Base + Pick Packs strategy is still the plan.
- **ADR-009**: Originally referenced Gemma-2B Tamil (1.63GB). Now targets Qwen3-0.6B-Base (<1GB). The hybrid retrieval architecture design is fully implemented and current.

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
