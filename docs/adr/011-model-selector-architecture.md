# ADR-011: Model Selector Architecture

## Status
**Accepted** - 2026-02-17

## Date
2026-02-17

---

## Context

The VAZHI app hardcoded a single GGUF model (Q4_K_M, 806MB) in two services — `VazhiLocalService` and `ModelDownloadService` — creating a DRY violation. After 14 debug builds troubleshooting Android crashes on a 4GB device, we confirmed Q4_K_M (806MB) OOMs on that hardware. Users need the ability to choose between model variants based on their device capability.

**Problems with the hardcoded approach:**
1. Model URL, filename, and size duplicated across two services
2. No way for users on low-RAM devices to select a smaller model
3. Adding a new model variant required editing multiple files
4. Hardcoded `'~806 MB'` strings scattered across 4 UI widgets

**Available models (all Gemma 3 1B-it SFT v7.1):**

| Quantization | Size | Quality | Device Target |
|---|---|---|---|
| Q4_K_M | ~806 MB | Best | 6GB+ RAM |
| Q3_K_M | ~722 MB | Medium (degraded Tamil) | 4GB RAM |
| Q2_K | ~690 MB | Low (broken Tamil) | Testing only |

## Decision

Introduce a **single source of truth** pattern: `ModelVariant` data class + `ModelRegistry` static list + Riverpod `SelectedModelNotifier` with SharedPreferences persistence.

### Architecture

```
ModelVariant (data class)
    ├── id, quantization, filename, url, expectedSizeBytes, displaySize
    ├── quality (enum: high/medium/low), qualityLabel, qualityLabelTamil
    ├── recommendedRamMB, sha256 (optional)
    └── Computed: partialFilename, minimumValidSizeBytes (90%), requiredSpaceBytes (+200MB)

ModelRegistry (static const list)
    ├── variants: [Q4_K_M, Q3_K_M, Q2_K] ordered by quality
    ├── defaultVariant: Q4_K_M (getter, not const — Dart limitation)
    └── findById(String id): lookup for persistence with fallback to default

SelectedModelNotifier (Riverpod StateNotifier)
    ├── Loads persisted selection from SharedPreferences on init
    ├── select(ModelVariant): updates state + persists to SharedPreferences
    └── selectedModelProvider: watched by services and UI

Service Integration (constructor injection)
    ├── VazhiLocalService(ModelVariant model) — uses model.filename, model.url, etc.
    ├── ModelDownloadService(ModelVariant model) — uses model.url, model.expectedSizeBytes, etc.
    └── Providers rebuild services when selectedModelProvider changes
```

### Files Created
- `lib/models/model_variant.dart` — ModelVariant, ModelQuality, ModelRegistry
- `lib/providers/model_provider.dart` — SelectedModelNotifier, selectedModelProvider, availableModelsProvider
- `lib/widgets/model_selector_sheet.dart` — Bottom sheet UI with radio-style variant cards

### Files Modified
- `lib/services/vazhi_local_service.dart` — Removed static constants, accepts ModelVariant via constructor
- `lib/services/model_download_service.dart` — Removed static constants, accepts ModelVariant via constructor
- `lib/providers/chat_provider.dart` — vazhiLocalServiceProvider watches selectedModelProvider
- `lib/widgets/download_dialog.dart` — Dynamic sizes, model selector row, downloadServiceProvider watches selectedModelProvider
- `lib/widgets/settings_drawer.dart` — Dynamic sizes, model name display, "Change Model" option
- `lib/widgets/model_status_indicator.dart` — Dynamic sizes from selectedModelProvider

## Consequences

### Positive
- **Single source of truth** — All model metadata in one file (`model_variant.dart`)
- **Adding a model = one registry entry** — No code changes in services or UI needed
- **User choice** — Users on 4GB devices can pick Q3_K_M; power users get Q4_K_M
- **Persisted selection** — SharedPreferences remembers the user's choice across app restarts
- **Reactive updates** — Riverpod dependency chain rebuilds services when model changes
- **Type safety** — Constructor injection ensures services always have a valid ModelVariant

### Negative
- **SharedPreferences dependency** — Added `shared_preferences: ^2.3.4` package
- **Dart const limitation** — `defaultVariant` must be a getter (not `static const`) because list indexing isn't a const expression in Dart
- **No runtime RAM detection** — The app shows recommended RAM but doesn't auto-select based on device capability (future enhancement)

## Alternatives Considered

### 1. Keep hardcoded, add conditional logic
- Simpler but perpetuates DRY violation
- Each new model requires editing multiple files
- Rejected: doesn't scale

### 2. JSON config file for model metadata
- More flexible but adds file I/O complexity
- Overkill for 3 static variants
- Rejected: unnecessary complexity for current needs

### 3. Auto-detect device RAM and select model
- Better UX but platform-specific code needed
- Could be added later on top of the current architecture
- Deferred: can be added as an enhancement to the existing ModelRegistry

## Related
- [ADR-009](009-hybrid-retrieval-architecture.md) — Hybrid retrieval architecture (model is optional)
- [ADR-010](010-data-pipeline-architecture.md) — Data pipeline (produces the models listed in registry)
- `vazhi_app/APP_CHANGELOG.md` — v0.6.0 entry documents this change
