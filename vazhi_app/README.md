# VAZHI Mobile App

**Tamil AI Assistant with Hybrid Retrieval Architecture**

A Flutter-based mobile application that provides immediate value through deterministic lookups while offering optional AI enhancement for deeper conversations.

---

## Quick Start

### Prerequisites

- Flutter SDK 3.10.8+
- Dart 3.0+
- iOS 13+ / Android 8+ for testing
- Xcode (for iOS) / Android Studio (for Android)

### Setup

```bash
# Clone the repository
git clone https://github.com/CryptoYogiLLC/vazhi.git
cd vazhi/vazhi_app

# Install dependencies
flutter pub get

# Run on connected device/simulator
flutter run
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/query_router_test.dart

# Run with coverage
flutter test --coverage
```

---

## Architecture Overview

VAZHI uses a **Hybrid Retrieval Architecture** that routes queries to the appropriate path:

```
User Query → Query Router → [Deterministic | Hybrid | AI] → Response
```

### Query Types

| Type | Description | Model Required |
|------|-------------|----------------|
| **Deterministic** | Exact lookups from SQLite | No |
| **AI Required** | LLM inference for explanations | Yes |
| **Hybrid** | SQLite lookup + AI enhancement | Optional |

### Key Benefits

- **Immediate Value**: App works from first launch (no model download needed)
- **Zero Hallucination**: Factual data (verses, phone numbers) always accurate
- **Progressive Enhancement**: Better experience with optional AI model

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   ├── app_config.dart          # App configuration
│   └── theme.dart               # UI theme and colors
├── database/
│   ├── knowledge_database.dart  # SQLite access layer
│   ├── migrations/              # Database migrations
│   └── data/                    # Seed data files
├── models/
│   ├── message.dart             # Chat message model
│   ├── feedback.dart            # Feedback model
│   ├── kural.dart               # Thirukkural model
│   ├── scheme.dart              # Government scheme model
│   └── ...
├── providers/
│   ├── chat_provider.dart       # Chat state management
│   ├── hybrid_chat_provider.dart # Hybrid retrieval flow
│   ├── voice_provider.dart      # Voice input/output state
│   └── feedback_provider.dart   # Feedback collection
├── screens/
│   └── chat_screen.dart         # Main chat interface
├── services/
│   ├── query_router.dart        # Query classification
│   ├── retrieval/               # Domain-specific retrieval
│   │   ├── retrieval_service.dart
│   │   ├── thirukkural_service.dart
│   │   ├── schemes_service.dart
│   │   ├── emergency_service.dart
│   │   ├── health_service.dart
│   │   └── education_service.dart
│   ├── vazhi_api_service.dart   # Cloud API (HuggingFace)
│   ├── vazhi_local_service.dart # Local LLM (llamadart)
│   ├── model_download_service.dart # Model download management
│   ├── voice_service.dart       # STT/TTS integration
│   └── feedback_service.dart    # Feedback submission
├── utils/
│   └── ...
└── widgets/
    ├── chat_input.dart          # Message input field
    ├── message_bubble.dart      # Standard message bubble
    ├── hybrid_message_bubble.dart # Hybrid response bubble
    ├── knowledge_result_card.dart # Rich data display
    ├── model_status_indicator.dart # Download status
    ├── feedback_buttons.dart    # Thumbs up/down
    ├── pack_selector.dart       # Knowledge pack selector
    ├── settings_drawer.dart     # App settings
    ├── download_dialog.dart     # Model download UI
    └── rotating_suggestions.dart # Query suggestions
```

---

## Key Components

### Query Router (`lib/services/query_router.dart`)

Classifies incoming queries into one of three types:

```dart
enum QueryType {
  deterministic,  // SQLite lookup only
  aiRequired,     // LLM inference only
  hybrid,         // SQLite + optional AI
}

class QueryRouter {
  QueryClassification classify(String query);
}
```

### Retrieval Services (`lib/services/retrieval/`)

Domain-specific services for deterministic lookups:

- **ThirukkuralService**: Verse lookup by number, chapter, keyword
- **SchemesService**: Government scheme details and eligibility
- **EmergencyService**: Emergency contact numbers
- **HealthService**: Hospital and health scheme info
- **EducationService**: Scholarship and institution data

### Hybrid Chat Provider (`lib/providers/hybrid_chat_provider.dart`)

Manages the hybrid response flow:

```dart
class HybridChatNotifier {
  Future<void> sendMessage(String text);
  Future<void> enhanceWithAi(String messageId);
  Future<void> downloadAi();
}
```

### Model Download Service (`lib/services/model_download_service.dart`)

Manages model download with:

- Network detection (WiFi vs cellular warning)
- Storage validation
- Pause/resume support
- Progress tracking (speed, ETA)
- File verification

---

## State Management

The app uses **Riverpod** for state management.

### Key Providers

```dart
// Chat state
final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>();

// Hybrid chat state
final hybridChatProvider = StateNotifierProvider<HybridChatNotifier, HybridChatState>();

// Model status
final modelStatusProvider = StateProvider<ModelStatus>();
final modelManagerProvider = StateNotifierProvider<ModelManagerNotifier, ModelStatus>();

// Inference mode
final inferenceModeProvider = StateProvider<InferenceMode>();

// Voice state
final voiceInputStateProvider = StateNotifierProvider<VoiceInputNotifier, VoiceInputState>();
final voiceOutputStateProvider = StateNotifierProvider<VoiceOutputNotifier, VoiceOutputState>();

// Current pack
final currentPackProvider = StateProvider<String>();
```

---

## Configuration

### App Config (`lib/config/app_config.dart`)

```dart
class AppConfig {
  static const String apiBaseUrl = 'https://huggingface.co/spaces/...';
  static const String modelUrl = 'https://huggingface.co/.../vazhi-v1.gguf';
  static const int expectedModelSize = 1630000000; // ~1.6GB
  static const String defaultPack = 'culture';
  static const List<String> availablePacks = [...];
}
```

### Theme (`lib/config/theme.dart`)

```dart
class VazhiTheme {
  static const Color primaryColor = Color(0xFF00796B);
  static const Color accentColor = Color(0xFF009688);
  static LinearGradient primaryGradient;
  // ...
}
```

---

## Database

### Knowledge Database

SQLite database bundled with the app for deterministic lookups.

**Location**: `assets/data/vazhi_knowledge.db`

**Schema**: See `docs/data_schema.md`

**Tables**:
- `thirukkural` - 1,330 verses
- `siddhars` - 18 siddhar profiles
- `schemes` - Government schemes
- `emergency_contacts` - Emergency numbers
- `hospitals` - Health facility directory
- And more...

### Migrations

Database migrations are stored in `lib/database/migrations/`.

---

## Testing

### Test Structure

```
test/
├── services/
│   ├── query_router_test.dart       # Query classification tests
│   └── retrieval/
│       └── retrieval_test.dart      # Retrieval service tests
├── integration/
│   └── deterministic_flow_test.dart # End-to-end flow tests
└── widget_test.dart                 # Widget tests
```

### Running Tests

```bash
# All tests
flutter test

# With verbose output
flutter test --reporter expanded

# Specific file
flutter test test/services/query_router_test.dart
```

---

## Building

### Debug Build

```bash
flutter run
```

### Release Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Dependencies

Key dependencies from `pubspec.yaml`:

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `dio` | HTTP client |
| `sqflite` | SQLite database |
| `hive` / `hive_flutter` | Local storage |
| `speech_to_text` | Voice input |
| `flutter_tts` | Voice output |
| `llamadart` | Local LLM inference |
| `google_fonts` | Tamil fonts |
| `flutter_markdown` | Markdown rendering |
| `connectivity_plus` | Network detection |
| `path_provider` | File system paths |

---

## Related Documentation

- [Architecture Overview](../docs/architecture/VAZHI_MOBILE_ARCHITECTURE.md)
- [Data Schema](docs/data_schema.md)
- [Hybrid Retrieval ADR](docs/adr/ADR-005-hybrid-retrieval-architecture.md)
- [Project ADRs](../docs/adr/README.md)

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

See [CONTRIBUTING.md](../docs/CONTRIBUTING.md) for detailed guidelines.

---

## License

Apache 2.0 - See LICENSE file in root directory.
