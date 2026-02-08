# VAZHI Mobile App Architecture

**Version**: 2.0
**Date**: February 2026
**Status**: Approved
**Last Updated**: 2026-02-08

---

## Executive Summary

VAZHI (வழி) is an open-source Tamil AI assistant designed to run on mobile phones. The app uses a **Hybrid Retrieval Architecture** that provides immediate value through deterministic lookups while offering optional AI enhancement for deeper conversations.

### Key Innovation: Hybrid Retrieval

Unlike traditional AI apps that require large model downloads before use, VAZHI works immediately after installation:

- **Deterministic Path**: Instant, accurate answers from local SQLite database (no AI needed)
- **AI-Enhanced Path**: Natural language understanding via optional LLM download

This architecture solves critical problems:
- **Zero hallucination** for factual data (Thirukkural verses, phone numbers, scheme details)
- **Immediate value** without 1.6GB model download
- **Higher install rates** due to small initial app size (~50MB)
- **Works offline** for both deterministic and AI paths

### Core Principles

| Principle | Implementation |
|-----------|----------------|
| **Tamil-first** | Native Tamil support, not translated |
| **Zero-cost** | Free app, donation-supported |
| **Offline-first** | Works without internet after install |
| **Hybrid intelligence** | Deterministic accuracy + AI flexibility |
| **Progressive enhancement** | Useful immediately, better with AI model |
| **Community-driven** | WhatsApp-based feedback and content creation |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VAZHI HYBRID ARCHITECTURE                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                           ┌─────────────────┐                                │
│                           │   User Query    │                                │
│                           │   (Tamil/EN)    │                                │
│                           └────────┬────────┘                                │
│                                    │                                         │
│                                    ▼                                         │
│                           ┌─────────────────┐                                │
│                           │  Query Router   │◄── Pattern matching            │
│                           │  (Dart rules)   │    No ML required              │
│                           └────────┬────────┘                                │
│                                    │                                         │
│              ┌─────────────────────┼─────────────────────┐                   │
│              │                     │                     │                   │
│              ▼                     ▼                     ▼                   │
│   ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐          │
│   │   DETERMINISTIC  │  │      HYBRID      │  │    AI-REQUIRED   │          │
│   │      PATH        │  │       PATH       │  │       PATH       │          │
│   │                  │  │                  │  │                  │          │
│   │  • Exact lookups │  │  • Retrieve data │  │  • Explanations  │          │
│   │  • Lists/browse  │  │  • Enhance w/ AI │  │  • Advice        │          │
│   │  • Phone numbers │  │  • Best of both  │  │  • Conversations │          │
│   │  • Kural verses  │  │                  │  │  • Complex Q&A   │          │
│   └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘          │
│            │                     │                     │                     │
│            ▼                     ▼                     ▼                     │
│   ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐          │
│   │     SQLite       │  │  SQLite + LLM    │  │   LLM Inference  │          │
│   │   (Bundled)      │  │   (if available) │  │   (if downloaded)│          │
│   │     ~2MB         │  │                  │  │     ~1.6GB       │          │
│   └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘          │
│            │                     │                     │                     │
│            └─────────────────────┴─────────────────────┘                     │
│                                  │                                           │
│                                  ▼                                           │
│                        ┌─────────────────┐                                   │
│                        │Response Builder │                                   │
│                        │ + UI Rendering  │                                   │
│                        └─────────────────┘                                   │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                           SHARED COMPONENTS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐        │
│  │   Chat UI    │ │    Voice     │ │   Feedback   │ │   Settings   │        │
│  │  Tamil + EN  │ │  STT / TTS   │ │  👍 👎 ✏️    │ │  + History   │        │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘        │
│                                                                              │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐        │
│  │   6 Packs    │ │    Model     │ │   Donate     │ │   Knowledge  │        │
│  │  Selectable  │ │  Download    │ │   Button     │ │   Cards UI   │        │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘        │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                          INFERENCE OPTIONS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────┐       ┌────────────────────────────┐        │
│  │      LOCAL INFERENCE       │       │      CLOUD FALLBACK        │        │
│  │                            │       │                            │        │
│  │  • llamadart (GGUF)       │       │  • HuggingFace Spaces      │        │
│  │  • 1.6GB model download   │       │  • Gradio API              │        │
│  │  • 4-6 sec response       │       │  • Internet required       │        │
│  │  • Works offline          │       │  • 5-10 sec response       │        │
│  │  • Requires 4GB+ RAM      │       │  • Any device              │        │
│  └────────────────────────────┘       └────────────────────────────┘        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Query Router Logic

The Query Router is the heart of the hybrid architecture. It analyzes user queries and routes them to the appropriate path.

### Query Classification

| Query Type | Route | Example Queries |
|------------|-------|-----------------|
| **Deterministic** | SQLite only | "குறள் 1", "CMCHIS phone number", "emergency contacts" |
| **AI Required** | LLM only | "Is this a scam?", "Explain RTI process", "What should I study?" |
| **Hybrid** | SQLite + LLM | "குறள் 1 அர்த்தம் என்ன?" (retrieve verse, explain meaning) |

### Routing Patterns

```dart
enum QueryType {
  deterministic,  // SQLite lookup only
  aiRequired,     // LLM inference only
  hybrid,         // SQLite + optional AI enhancement
}

// Pattern matching rules
class QueryRouter {
  QueryType classify(String query) {
    // Exact reference lookups → Deterministic
    if (isKuralReference(query)) return QueryType.deterministic;
    if (isPhoneNumberRequest(query)) return QueryType.deterministic;
    if (isSchemeListRequest(query)) return QueryType.deterministic;

    // Explanation/advice requests → AI Required
    if (containsExplanationKeywords(query)) return QueryType.aiRequired;
    if (isAdviceRequest(query)) return QueryType.aiRequired;
    if (isComplexQuestion(query)) return QueryType.aiRequired;

    // Retrieve + explain → Hybrid
    if (isReferenceWithMeaning(query)) return QueryType.hybrid;

    return QueryType.aiRequired; // Default to AI
  }
}
```

### Response Behavior by State

| Query Type | Model Downloaded | Model Not Downloaded |
|------------|------------------|----------------------|
| **Deterministic** | Instant SQLite response | Instant SQLite response |
| **AI Required** | Full AI response | Show "Download AI" prompt with preview |
| **Hybrid** | SQLite + AI explanation | SQLite data + "Enhance with AI" button |

---

## Data Architecture

### Deterministic Data (SQLite)

Bundled with the app (~2MB compressed). Zero hallucination risk.

| Pack | Data Type | Records | Use Case |
|------|-----------|---------|----------|
| **Culture** | Thirukkural verses | 1,330 | Exact verse lookup |
| **Culture** | Siddhars info | 18 | Biography lookup |
| **Culture** | Festivals | ~50 | Date/significance lookup |
| **Government** | Schemes | ~100 | Eligibility, benefits |
| **Government** | Documents | ~30 | Required documents list |
| **Education** | Scholarships | ~50 | Amount, eligibility |
| **Education** | Institutions | ~200 | Contact info |
| **Legal** | Templates | ~20 | RTI, FIR formats |
| **Legal** | Rights info | ~50 | Citizen rights |
| **Health** | Hospitals | ~500 | Location, contact |
| **Health** | Emergency contacts | ~30 | Phone numbers |
| **Security** | Scam patterns | ~50 | Warning signs |
| **Security** | Emergency contacts | ~30 | Helpline numbers |
| **Total** | | **~2,500+** | **~1.8 MB** |

### AI-Enhanced Data (LLM)

Requires model download (~1.6GB). Provides conversational intelligence.

- Personalized advice and recommendations
- Complex explanations in natural language
- Comparative analysis ("Which scheme is better for me?")
- Follow-up conversations with context
- Ambiguous query interpretation
- Creative and nuanced responses

---

## User Experience Flow

### Without Model (First Install)

```
┌─────────────────────────────────────────────────────────────────┐
│  வழி - VAZHI                                              ≡    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  👤 குறள் 1 என்ன?                                              │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  📜 திருக்குறள் #1                                        │ │
│  │                                                           │ │
│  │  அகர முதல எழுத்தெல்லாம் ஆதி                               │ │
│  │  பகவன் முதற்றே உலகு                                       │ │
│  │                                                           │ │
│  │  அதிகாரம்: கடவுள் வாழ்த்து                                │ │
│  │  பால்: அறத்துப்பால்                                       │ │
│  │                                                           │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │  🤖 Want AI explanation?  [Download AI Model]       │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  [🎤]  Type your message...                            [➤]    │
└─────────────────────────────────────────────────────────────────┘
```

### With Model (After Download)

```
┌─────────────────────────────────────────────────────────────────┐
│  வழி - VAZHI                                        🤖 ≡       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  👤 குறள் 1 அர்த்தம் என்ன?                                     │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  📜 திருக்குறள் #1                                        │ │
│  │                                                           │ │
│  │  அகர முதல எழுத்தெல்லாம் ஆதி                               │ │
│  │  பகவன் முதற்றே உலகு                                       │ │
│  │                                                           │ │
│  │  ───────────────────────────────────────────────────────  │ │
│  │                                                           │ │
│  │  🤖 AI விளக்கம்:                                          │ │
│  │                                                           │ │
│  │  இந்த குறளின் ஆழமான பொருள்: எல்லா எழுத்துக்களும்         │ │
│  │  'அ' என்ற எழுத்தில் தொடங்குவது போல், இந்த உலகமும்        │ │
│  │  இறைவனிடம் தொடங்குகிறது. வள்ளுவர் இங்கு கல்வியின்        │ │
│  │  அடிப்படையான எழுத்தறிவை, ஆன்மீகத்துடன் இணைக்கிறார்...    │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  👤 இன்னும் விளக்கமாக சொல்லுங்கள்                              │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  [🎤]  Type your message...                            [➤]    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Mobile Application

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Framework** | Flutter (Dart) | Cross-platform, excellent Tamil rendering |
| **State Management** | Riverpod | Modern, testable, async-friendly |
| **Deterministic DB** | SQLite + sqflite | Structured data, FTS5 search |
| **Chat History** | Hive | Fast local storage |
| **HTTP Client** | Dio | Cloud API calls |
| **Voice STT** | speech_to_text | Tamil speech recognition |
| **Voice TTS** | flutter_tts | Tamil text-to-speech |
| **LLM Inference** | llamadart | Local GGUF model inference |

### Query Processing

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Query Router** | Dart (rule-based) | Classify query type |
| **Retrieval Services** | Modular Dart classes | Domain-specific lookups |
| **Response Builder** | Dart + Flutter Widgets | Combine data + UI |
| **Knowledge Cards** | Custom Flutter widgets | Rich data display |

### Backend (Cloud Fallback)

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Hosting** | HuggingFace Spaces | Free GPU inference |
| **Framework** | Gradio | Simple API endpoint |
| **Model** | VAZHI LoRA + Qwen 2.5 3B | Fine-tuned Tamil model |
| **Quantization** | 4-bit (bitsandbytes) | Memory efficiency |

---

## Modular Service Architecture

The app uses a modular service architecture for clean separation of concerns.

```
lib/
├── services/
│   ├── query_router.dart           # Query classification
│   ├── retrieval/
│   │   ├── retrieval_service.dart  # Base interface
│   │   ├── thirukkural_service.dart
│   │   ├── schemes_service.dart
│   │   ├── emergency_service.dart
│   │   ├── health_service.dart
│   │   └── education_service.dart
│   ├── vazhi_api_service.dart      # Cloud API
│   ├── vazhi_local_service.dart    # Local LLM
│   ├── model_download_service.dart # Download management
│   ├── voice_service.dart          # STT/TTS
│   └── feedback_service.dart       # User feedback
├── providers/
│   ├── chat_provider.dart          # Chat state
│   ├── hybrid_chat_provider.dart   # Hybrid flow
│   ├── voice_provider.dart         # Voice state
│   └── feedback_provider.dart      # Feedback state
├── database/
│   ├── knowledge_database.dart     # SQLite access
│   └── migrations/                 # Schema versions
├── widgets/
│   ├── knowledge_result_card.dart  # Rich data display
│   ├── model_status_indicator.dart # Download status
│   ├── hybrid_message_bubble.dart  # Hybrid responses
│   └── ...
└── screens/
    └── chat_screen.dart            # Main UI
```

---

## Data Flow Diagrams

### Deterministic Query Flow

```
┌─────────┐    ┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│  User   │───▶│Query Router │───▶│   SQLite     │───▶│  Knowledge  │
│  Query  │    │(deterministic)   │   Lookup     │    │    Card     │
└─────────┘    └─────────────┘    └──────────────┘    └─────────────┘
                                         │
                                         ▼
                                  Instant response
                                  No AI needed
```

### AI Query Flow (Model Downloaded)

```
┌─────────┐    ┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│  User   │───▶│Query Router │───▶│   llamadart  │───▶│  Message    │
│  Query  │    │(aiRequired) │    │   Inference  │    │   Bubble    │
└─────────┘    └─────────────┘    └──────────────┘    └─────────────┘
                                         │
                                         ▼
                                  4-6 sec response
                                  Full AI capability
```

### AI Query Flow (Model NOT Downloaded)

```
┌─────────┐    ┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│  User   │───▶│Query Router │───▶│   Check      │───▶│  Download   │
│  Query  │    │(aiRequired) │    │   Model      │    │   Prompt    │
└─────────┘    └─────────────┘    └──────────────┘    └─────────────┘
                                         │
                                         ▼
                                  "Download AI Model
                                   for full answers"
```

### Hybrid Query Flow

```
┌─────────┐    ┌─────────────┐    ┌──────────────┐
│  User   │───▶│Query Router │───▶│   SQLite     │
│  Query  │    │  (hybrid)   │    │   Lookup     │
└─────────┘    └─────────────┘    └──────┬───────┘
                                         │
                              ┌──────────┴──────────┐
                              │                     │
                              ▼                     ▼
                     ┌──────────────┐      ┌──────────────┐
                     │ Model Ready  │      │ Model Not    │
                     │              │      │ Downloaded   │
                     └──────┬───────┘      └──────┬───────┘
                            │                     │
                            ▼                     ▼
                     ┌──────────────┐      ┌──────────────┐
                     │ SQLite Data  │      │ SQLite Data  │
                     │ + AI Explain │      │ + "Enhance   │
                     │              │      │   with AI"   │
                     └──────────────┘      └──────────────┘
```

---

## Model Download Flow

The model download is an optional enhancement with a polished UX.

### Download Dialog Features

- **Network detection**: Warns on cellular, recommends WiFi
- **Storage check**: Validates available space before download
- **Progress tracking**: Speed, ETA, percentage
- **Pause/Resume**: Survives app restarts
- **Verification**: Checks file integrity after download

### Model Specifications

| Property | Value |
|----------|-------|
| **Format** | GGUF (Q4_K_M quantization) |
| **Size** | ~1.6 GB |
| **Base Model** | Gemma-2B Tamil |
| **Min RAM** | 4GB |
| **Inference** | llamadart (llama.cpp binding) |
| **Response Time** | 4-6 seconds |

---

## File Structure (On Device)

```
VAZHI App Data/
├── databases/
│   ├── vazhi_knowledge.db          # Deterministic data (~2MB)
│   └── conversations.db            # Chat history
├── models/
│   └── vazhi-v1.gguf               # AI model (~1.6GB, optional)
├── cache/
│   └── tts_cache/                  # Cached TTS audio
└── preferences/
    └── config.json                 # User settings
```

---

## Device Requirements

### All Users (Deterministic Features)

| Requirement | Specification |
|-------------|---------------|
| **OS** | Android 8+ / iOS 13+ |
| **RAM** | 2GB |
| **Storage** | 100MB free |
| **Network** | Not required (after install) |

### AI Features (Optional)

| Requirement | Specification |
|-------------|---------------|
| **OS** | Android 10+ / iOS 15+ |
| **RAM** | 4GB+ |
| **Storage** | 2GB+ free |
| **Network** | WiFi recommended for download |

---

## Development Phases (Updated)

| Phase | Status | Scope |
|-------|--------|-------|
| **Phase 1** | ✅ Complete | Flutter app + HuggingFace backend, chat + voice |
| **Phase 2** | ⚠️ Partial | Hybrid architecture, deterministic retrieval, model download UI |
| **Phase 3** | 🔲 Planned | Pack Manager with incremental downloads |
| **Phase 4** | ⚠️ Partial | Feedback system (done), expert directory (pending) |
| **Phase 5** | 🔲 Planned | Play Store + App Store submission |

### Current Implementation Status

- ✅ Query Router with pattern matching
- ✅ SQLite retrieval services (Thirukkural, Schemes, Emergency, Health)
- ✅ Hybrid chat provider
- ✅ Knowledge result cards UI
- ✅ Model download with pause/resume
- ✅ Network and storage validation
- ⚠️ AI model training (in progress)
- 🔲 Full Thirukkural database (1,330 verses)
- 🔲 Complete schemes database

---

## Security Considerations

1. **No user data collection** - All processing local
2. **No accounts required** - Anonymous usage
3. **Model integrity** - SHA256 checksums for downloads
4. **SQLite bundled** - No external data fetching for deterministic
5. **WhatsApp integration** - Uses official deep links only
6. **Donation** - External link to trusted platform

---

## Related ADRs

- [ADR-001: Hybrid App Strategy](../adr/001-hybrid-app-strategy.md)
- [ADR-002: Flutter Framework Selection](../adr/002-flutter-framework-selection.md)
- [ADR-003: Community Engagement via WhatsApp](../adr/003-community-whatsapp-engagement.md)
- [ADR-004: HuggingFace Spaces Backend](../adr/004-huggingface-spaces-backend.md)
- [ADR-005: Incremental Pack Downloads](../adr/005-incremental-pack-downloads.md)
- [ADR-006: Voice Integration Strategy](../adr/006-voice-integration-strategy.md)
- [ADR-007: Free Plus Donations Monetization](../adr/007-free-donations-monetization.md)
- [ADR-008: App Store Distribution](../adr/008-app-store-distribution.md)
- [ADR-009: Hybrid Retrieval Architecture](../adr/009-hybrid-retrieval-architecture.md)

---

## Appendix: Knowledge Pack Details

| Pack | Tamil Name | Deterministic Data | AI Training Pairs |
|------|------------|-------------------|-------------------|
| Culture | பண்பாடு | Thirukkural (1,330), Siddhars (18), Festivals (~50) | 400 |
| Government | அரசு | Schemes (~100), Documents (~30), Offices (~200) | 467 |
| Education | கல்வி | Scholarships (~50), Institutions (~200), Exams (~30) | 602 |
| Legal | சட்டம் | Templates (~20), Rights (~50), Procedures | 610 |
| Healthcare | மருத்துவம் | Hospitals (~500), Emergency (~30), Siddha (~100) | 460 |
| Security | காவல் | Scam patterns (~50), Safety tips (~30), Contacts | 468 |

**Deterministic Records**: ~2,500+
**AI Training Pairs**: 3,007
**SQLite Database Size**: ~1.8 MB (compressed: ~600 KB)

---

## Appendix: Query Pattern Examples

### Deterministic Patterns

```dart
// Thirukkural lookup
"குறள் 1"
"kural 42"
"திருக்குறள் 100"

// Emergency contacts
"emergency number"
"அவசர எண்"
"police phone"

// Scheme lookup
"CMCHIS phone number"
"PM-KISAN details"
"ration card documents"
```

### AI-Required Patterns

```dart
// Explanation requests
"explain RTI"
"குறள் meaning"
"what is CMCHIS"

// Advice requests
"Is this a scam?"
"What should I study?"
"Which scheme is better for me?"

// Complex questions
"How to apply for ration card?"
"தை பொங்கல் எப்படி கொண்டாடுவது?"
```

### Hybrid Patterns

```dart
// Retrieve + explain
"குறள் 1 அர்த்தம் என்ன?"
"Tell me about Thirumoolar"
"CMCHIS scheme details and how to apply"
```
