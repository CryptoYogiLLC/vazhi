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
| [001](001-hybrid-app-strategy.md) | Hybrid App Strategy | Accepted | Two app variants: VAZHI Lite (cloud) + VAZHI Full (offline) |
| [002](002-flutter-framework-selection.md) | Flutter Framework Selection | Accepted | Use Flutter for cross-platform development |
| [003](003-community-whatsapp-engagement.md) | Community WhatsApp Engagement | Accepted | WhatsApp for feedback and community content creation |
| [004](004-huggingface-spaces-backend.md) | HuggingFace Spaces Backend | Accepted | Free HuggingFace Spaces for VAZHI Lite cloud inference |
| [005](005-incremental-pack-downloads.md) | Incremental Pack Downloads | Accepted | Base model + selective pack downloads |
| [006](006-voice-integration-strategy.md) | Voice Integration Strategy | Accepted | Native platform STT/TTS for voice input/output |
| [007](007-free-donations-monetization.md) | Free + Donations Monetization | Accepted | 100% free app with optional donation support |
| [008](008-app-store-distribution.md) | App Store Distribution | Accepted | Google Play + Apple App Store + F-Droid |

## Key Decisions Summary

### Target Audience
- **Primary**: Tamil speakers in Tamil Nadu
- **Device**: Mid-range smartphones (4GB+ RAM for Full version)
- **Connectivity**: Both online (urban) and offline (rural) users

### Technology Choices
- **Framework**: Flutter (Dart)
- **LLM Inference**: llama.cpp (GGUF format) for offline, HuggingFace for cloud
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
