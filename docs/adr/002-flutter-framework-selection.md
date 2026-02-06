# ADR-002: Flutter Framework Selection

## Status
Accepted

## Date
2026-02-05

---

## Context

VAZHI requires a cross-platform mobile framework to build both iOS and Android apps from a single codebase. The key requirements are:

1. **Excellent Tamil text rendering** - Complex script support
2. **Small app size** - Target users have limited storage
3. **Native performance** - Local LLM inference via llama.cpp
4. **Voice integration** - Speech-to-text and text-to-speech
5. **Single codebase** - Cannot afford to maintain two native apps

### Candidates Evaluated

| Framework | Language | Native Perf | Community | llama.cpp Support |
|-----------|----------|-------------|-----------|-------------------|
| React Native | JavaScript | Good | Large | react-native-llama (mature) |
| Flutter | Dart | Excellent | Growing | flutter_llama_cpp (newer) |
| Capacitor | Web | Fair | Medium | Limited |

## Decision

We will use **Flutter** as the mobile app framework.

### Rationale

| Factor | Flutter Advantage |
|--------|-------------------|
| **Tamil rendering** | Skia engine handles complex scripts beautifully |
| **App size** | Base app ~10-15MB vs React Native ~20-25MB |
| **UI consistency** | Pixel-perfect identical UI on iOS/Android |
| **Animation** | Built-in 60fps animations, important for voice feedback |
| **Hot reload** | Faster development iteration |
| **Performance** | Compiles to native ARM, no JavaScript bridge |

### llama.cpp Integration Risk

The `flutter_llama_cpp` package is newer than `react-native-llama`. Mitigation:
- Validate llama.cpp integration in Phase 1 before heavy development
- Fallback: Write native platform channels if needed (Kotlin/Swift)
- The package is actively maintained and improving

### Tech Stack

```yaml
# pubspec.yaml dependencies
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0

  # Storage
  hive: ^2.2.3
  sqflite: ^2.3.0

  # HTTP
  dio: ^5.3.0

  # Voice
  speech_to_text: ^6.3.0
  flutter_tts: ^3.8.0

  # LLM (Full variant only)
  flutter_llama_cpp: ^0.1.0  # Or latest

  # UI
  google_fonts: ^6.1.0
  flutter_markdown: ^0.6.18
```

## Consequences

### Positive
- **Beautiful Tamil UI** - Native Skia rendering for complex scripts
- **Smaller install** - Important for storage-constrained users
- **Smooth animations** - Better UX for voice interactions
- **True cross-platform** - Identical behavior on iOS and Android
- **Strong typing** - Dart catches errors at compile time

### Negative
- **Learning curve** - Team needs to learn Dart (if unfamiliar)
- **Newer llama.cpp package** - Less battle-tested than React Native equivalent
- **Smaller ecosystem** - Fewer packages than React Native (but growing)

### Mitigations
- Dart is easy to learn for developers with JS/Java/Swift experience
- Early llama.cpp validation in Phase 1
- Core packages (voice, HTTP, storage) are mature and well-maintained

## Alternatives Considered

### React Native
- Pros: Larger community, more mature llama.cpp support
- Cons: Larger app size, JavaScript bridge overhead, less consistent cross-platform UI
- Rejected: App size and Tamil rendering quality are priorities

### Native (Kotlin + Swift)
- Pros: Best performance, direct llama.cpp access
- Cons: Two codebases to maintain, 2x development effort
- Rejected: Resource constraints, single developer building both platforms

### Capacitor/Ionic
- Pros: Web-based, familiar to web developers
- Cons: Performance concerns for ML workloads, less native feel
- Rejected: Not suitable for on-device LLM inference

## Related
- [VAZHI Mobile Architecture](../architecture/VAZHI_MOBILE_ARCHITECTURE.md)
- [ADR-006: Voice Integration Strategy](006-voice-integration-strategy.md)
