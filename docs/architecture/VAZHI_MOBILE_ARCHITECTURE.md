# VAZHI Mobile App Architecture

**Version**: 1.0
**Date**: February 2026
**Status**: Approved

---

## Executive Summary

VAZHI (வழி) is an open-source Tamil language LLM designed to run on mobile phones. This document defines the architecture for the VAZHI mobile application ecosystem, which includes two variants: VAZHI Lite (cloud-based) and VAZHI Full (offline-capable).

### Core Principles

| Principle | Implementation |
|-----------|----------------|
| **Tamil-first** | Native Tamil support, not translated |
| **Zero-cost** | Free app, donation-supported |
| **Accessible** | Works on mid-range phones (4GB RAM) |
| **Dual-mode** | Online (Lite) and Offline (Full) variants |
| **Community-driven** | WhatsApp-based feedback and content creation |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            VAZHI ECOSYSTEM                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────┐       ┌────────────────────────────┐        │
│  │       VAZHI LITE           │       │       VAZHI FULL           │        │
│  │       (~50MB app)          │       │       (~100MB app)         │        │
│  │                            │       │                            │        │
│  │  • Internet required       │       │  • Works fully offline     │        │
│  │  • All 6 packs via cloud   │       │  • Base model: 1.7GB       │        │
│  │  • 5-10 sec response       │       │  • Packs: ~60MB each       │        │
│  │  • Voice Input/Output      │       │  • 4-6 sec response        │        │
│  │  • Any smartphone          │       │  • Voice Input/Output      │        │
│  │                            │       │  • Requires 4GB+ RAM       │        │
│  └─────────────┬──────────────┘       └─────────────┬──────────────┘        │
│                │                                    │                        │
│                ▼                                    ▼                        │
│  ┌────────────────────────────┐       ┌────────────────────────────┐        │
│  │   HuggingFace Spaces       │       │   Local llama.cpp          │        │
│  │   (Free GPU inference)     │       │   (On-device inference)    │        │
│  │   Gradio API endpoint      │       │   GGUF quantized model     │        │
│  └────────────────────────────┘       └────────────────────────────┘        │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                           SHARED COMPONENTS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐        │
│  │   Chat UI    │ │    Voice     │ │   Feedback   │ │   Settings   │        │
│  │  Tamil + EN  │ │  Input/Out   │ │  + WhatsApp  │ │  + History   │        │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘        │
│                                                                              │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐        │
│  │   6 Packs    │ │   Expert     │ │   Donate     │ │    Pack      │        │
│  │  Selectable  │ │  Directory   │ │   Button     │ │   Manager    │        │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘        │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                          COMMUNITY LAYER                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────┐      │
│  │                      WhatsApp Group                                │      │
│  │   • VAZHI Contributors - Q&A content creation                     │      │
│  │   • Feedback collection from users                                │      │
│  │   • Community support and discussions                             │      │
│  └───────────────────────────────────────────────────────────────────┘      │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                           DISTRIBUTION                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   Android: Google Play Store ($25 one-time) + F-Droid (free)                │
│   iOS: Apple App Store ($99/year)                                           │
│   Models: HuggingFace Hub (free hosting)                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## App Variants Comparison

| Feature | VAZHI Lite | VAZHI Full |
|---------|------------|------------|
| **App size** | ~50MB | ~100MB + downloads |
| **Internet required** | Yes (always) | No (after initial download) |
| **Base model location** | Cloud (HuggingFace) | Local (1.7GB GGUF) |
| **All 6 packs** | Yes (cloud) | Yes (download individually) |
| **Response time** | 5-10 seconds | 4-6 seconds |
| **Voice input** | Yes | Yes |
| **Voice output** | Yes | Yes |
| **UI languages** | Tamil + English | Tamil + English |
| **Chat history** | User configurable | User configurable |
| **Feedback system** | In-App + WhatsApp | In-App + WhatsApp |
| **Expert directory** | Yes | Yes |
| **Donation button** | Yes | Yes |
| **Minimum device** | Any Android/iOS | 4GB RAM required |
| **Target user** | Urban, good connectivity | Rural, limited connectivity |

---

## Technology Stack

### Mobile Application

| Component | Technology | Rationale |
|-----------|------------|-----------|
| **Framework** | Flutter (Dart) | Cross-platform, excellent Tamil rendering, smaller app size |
| **State Management** | Riverpod | Modern, testable, good for async |
| **Local Storage** | Hive / SQLite | Chat history, settings |
| **HTTP Client** | Dio | Robust API calls to HF Spaces |
| **Voice STT** | speech_to_text plugin | Native iOS/Android speech recognition |
| **Voice TTS** | flutter_tts plugin | Native text-to-speech with Tamil |
| **LLM Inference** | flutter_llama_cpp | Local GGUF model inference |

### Backend (VAZHI Lite)

| Component | Technology | Rationale |
|-----------|------------|-----------|
| **Hosting** | HuggingFace Spaces | Free GPU inference |
| **Framework** | Gradio | Simple API, built-in UI for testing |
| **Model** | VAZHI LoRA + Qwen 2.5 3B | Fine-tuned Tamil model |
| **Quantization** | 4-bit (bitsandbytes) | Fits in free tier GPU memory |

### Model Distribution

| Component | Technology | Rationale |
|-----------|------------|-----------|
| **Model hosting** | HuggingFace Hub | Free, reliable, CDN-backed |
| **Model format** | GGUF (Q4_K_M) | Optimized for mobile inference |
| **Pack format** | LoRA adapters (GGUF) | Small incremental downloads |

---

## Feature Specifications

### 1. Chat Interface

```
┌─────────────────────────────────────┐
│  வழி - VAZHI                    ≡   │
├─────────────────────────────────────┤
│                                     │
│  👤 Scam message-ஐ எப்படி           │
│     identify பண்றது?               │
│                                     │
│         🤖 Scam messages-ல்          │
│            இந்த signs இருக்கும்:    │
│            • Urgent-ஆ கேட்பாங்க     │
│            • OTP கேட்பாங்க          │
│            • Unknown links...       │
│                                     │
├─────────────────────────────────────┤
│  [🎤]  Type your message...   [➤]  │
└─────────────────────────────────────┘
```

**Features:**
- Tamil + English input support
- Markdown rendering for responses
- Typing indicator during generation
- Copy/share response buttons
- Voice input button (mic icon)
- Auto-scroll to latest message

### 2. Voice Input/Output

**Flow:**
```
User taps mic → Speech recognized (Tamil) → Text shown →
VAZHI processes → Response generated → TTS speaks response
```

**Technical:**
- Uses native platform STT (offline-capable on modern devices)
- Tamil language code: `ta-IN`
- TTS with adjustable speed
- Visual feedback during listening

### 3. Pack Manager (Full version only)

```
┌─────────────────────────────────────┐
│  ◀ Packs                            │
├─────────────────────────────────────┤
│                                     │
│  🛡️ Vazhi Kaval (Security)          │
│  ━━━━━━━━━━━━━━━━━━━━━ ✅ Enabled    │
│  Scam detection, cyber safety       │
│                                     │
│  🏛️ Vazhi Arasu (Government)        │
│  ━━━━━━━━━━━━━━━━━━━━━ ✅ Enabled    │
│  Schemes, services, documents       │
│                                     │
│  📚 Vazhi Kalvi (Education)         │
│  ━━━━━━━━━━━━━━━━━ [Download 58MB]  │
│  Scholarships, exams, guidance      │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Base model required first (1.7GB)
- Individual pack downloads (~60MB each)
- Enable/disable packs
- Storage usage display
- Download progress with pause/resume

### 4. Feedback System

**In-App Form:**
- Category: Bug / Incorrect Answer / Suggestion / Other
- Description (text)
- Optional: Include conversation context
- Submit: Queues locally, sends when online

**WhatsApp Integration:**
- "Send via WhatsApp" button
- Pre-fills message with context
- Opens WhatsApp to VAZHI support number

### 5. Expert Directory

**Purpose:** When VAZHI cannot help, show relevant contacts.

**Categories:**
- Government offices (Collector, Taluk)
- Legal aid (District Legal Services)
- Healthcare (PHC, Government hospitals)
- Education (DEO, Scholarship offices)
- Consumer forum contacts
- Cyber crime helpline

**Display:** Searchable list with phone numbers, addresses, website links.

### 6. Settings

| Setting | Options |
|---------|---------|
| App language | Tamil / English |
| Voice output | On / Off |
| TTS speed | Slow / Normal / Fast |
| Chat history | Keep all / Last 50 / None |
| Storage management | Clear cache / Delete packs |
| About | Version, licenses, donate link |

---

## Data Flow

### VAZHI Lite (Online)

```
┌─────────┐    ┌─────────────┐    ┌──────────────────┐    ┌─────────┐
│  User   │───▶│ Flutter App │───▶│ HuggingFace API  │───▶│ Response│
│  Query  │    │ (HTTP POST) │    │ (Gradio endpoint)│    │  JSON   │
└─────────┘    └─────────────┘    └──────────────────┘    └─────────┘
```

### VAZHI Full (Offline)

```
┌─────────┐    ┌─────────────┐    ┌──────────────────┐    ┌─────────┐
│  User   │───▶│ Flutter App │───▶│ llama.cpp local  │───▶│ Response│
│  Query  │    │ (native)    │    │ (GGUF model)     │    │  String │
└─────────┘    └─────────────┘    └──────────────────┘    └─────────┘
```

---

## File Structure

### App Storage (On Device)

```
VAZHI App Data/
├── models/
│   └── vazhi-base-q4.gguf           # 1.7GB - Base Tamil model (Full only)
├── packs/
│   ├── vazhi-kaval.gguf             # ~60MB - Security pack
│   ├── vazhi-arasu.gguf             # ~60MB - Government pack
│   ├── vazhi-kalvi.gguf             # ~60MB - Education pack
│   ├── vazhi-sattam.gguf            # ~60MB - Legal pack
│   ├── vazhi-maruthuvam.gguf        # ~60MB - Healthcare pack
│   └── vazhi-panpaadu.gguf          # ~60MB - Culture pack
├── database/
│   └── conversations.db             # Chat history (SQLite)
├── cache/
│   └── tts_cache/                   # Cached TTS audio
└── config.json                      # User preferences
```

### CDN Structure (HuggingFace Hub)

```
CryptoYogiLLC/vazhi-models/
├── vazhi-base-q4.gguf               # Base model
├── packs/
│   └── v1/
│       ├── vazhi-kaval.gguf
│       ├── vazhi-arasu.gguf
│       └── ...
└── manifest.json                    # Version info, checksums
```

---

## Device Requirements

### Minimum (VAZHI Lite)

| Requirement | Specification |
|-------------|---------------|
| OS | Android 8+ / iOS 13+ |
| RAM | 2GB |
| Storage | 100MB free |
| Network | 3G or better |

### Minimum (VAZHI Full)

| Requirement | Specification |
|-------------|---------------|
| OS | Android 10+ / iOS 15+ |
| RAM | 4GB |
| Storage | 3GB free (base + 2 packs) |
| Network | WiFi for initial download |

### Recommended (VAZHI Full)

| Requirement | Specification |
|-------------|---------------|
| OS | Android 12+ / iOS 16+ |
| RAM | 6GB+ |
| Storage | 5GB+ free |
| Processor | Snapdragon 7 Gen 1+ / A14+ |

---

## Development Phases

| Phase | Scope | Deliverables |
|-------|-------|--------------|
| **Phase 1** | VAZHI Lite MVP | Flutter app + HuggingFace backend, chat + voice |
| **Phase 2** | VAZHI Full | Offline inference with llama.cpp |
| **Phase 3** | Pack Manager | Incremental downloads, storage management |
| **Phase 4** | Polish | Feedback system, expert directory, settings |
| **Phase 5** | Launch | Play Store + App Store submission |

---

## Security Considerations

1. **No user data collection** - All processing local or via HuggingFace (no custom backend)
2. **No accounts required** - Anonymous usage
3. **Model integrity** - SHA256 checksums for downloads
4. **WhatsApp integration** - Uses official deep links, no API access
5. **Donation** - External link to trusted platform (Ko-fi, Buy Me a Coffee)

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

---

## Appendix: Pack Details

| Pack | Tamil Name | Focus Areas | Training Pairs |
|------|------------|-------------|----------------|
| Security | காவல் (Kaval) | Scams, fraud, cyber safety, OTP | 468 |
| Government | அரசு (Arasu) | Schemes, ration card, CMCHIS | 467 |
| Education | கல்வி (Kalvi) | Scholarships, exams, colleges | 602 |
| Legal | சட்டம் (Sattam) | RTI, FIR, consumer rights | 610 |
| Healthcare | மருத்துவம் (Maruthuvam) | Hospitals, schemes, Siddha | 460 |
| Culture | பண்பாடு (Panpaadu) | Thirukkural, temples, festivals | 400 |

**Total: 3,007 training pairs**
