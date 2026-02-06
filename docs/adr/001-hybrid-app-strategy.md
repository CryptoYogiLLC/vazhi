# ADR-001: Hybrid App Strategy (Lite + Full Variants)

## Status
Accepted

## Date
2026-02-05

---

## Context

VAZHI aims to serve Tamil speakers across a wide spectrum of device capabilities and connectivity:

1. **Urban users**: Good internet, limited phone storage, modern devices
2. **Rural users**: Poor/no internet, basic smartphones, need offline access

A single app variant cannot optimally serve both groups:
- Full offline model (1.7GB+) is too large for storage-constrained urban users
- Cloud-only app fails rural users without reliable internet

### User Research Insights
- Average free storage on budget Indian smartphones: 2-4GB
- Rural Tamil Nadu connectivity: 2G/3G common, frequent outages
- Urban users prefer smaller app installs but have stable WiFi

## Decision

We will build **two app variants** from a single Flutter codebase:

| Variant | Target User | Model Location | App Size |
|---------|-------------|----------------|----------|
| **VAZHI Lite** | Urban, good connectivity | Cloud (HuggingFace Spaces) | ~50MB |
| **VAZHI Full** | Rural, offline needs | Local (llama.cpp) | ~100MB + downloads |

### Shared Components (Single Codebase)
- Chat UI
- Voice input/output
- Feedback system
- Settings
- Expert directory

### Variant-Specific Components
- **Lite**: HTTP client to HuggingFace API
- **Full**: llama.cpp native bindings, pack manager, download manager

### Build Configuration
```dart
// lib/config/app_config.dart
enum AppVariant { lite, full }

const currentVariant = AppVariant.lite; // or .full

// Conditional features based on variant
if (currentVariant == AppVariant.full) {
  // Show pack manager, enable offline mode
}
```

## Consequences

### Positive
- **Maximum reach**: Serves both urban and rural users effectively
- **Single codebase**: 90% code sharing, easier maintenance
- **User choice**: Users pick variant that fits their situation
- **Gradual adoption**: Users can start with Lite, upgrade to Full later

### Negative
- **Two builds to maintain**: Separate APK/IPA for each variant
- **Testing overhead**: Must test both variants on each release
- **User confusion**: May need clear naming (VAZHI Lite vs VAZHI)

### Mitigations
- Use Flutter flavors for variant builds
- Automated testing for both variants
- Clear app store descriptions explaining the difference

## Alternatives Considered

### 1. Single App with Optional Download
- Pros: Single install, user downloads model if needed
- Cons: Complex UX, confusing for non-technical users
- Rejected: Too complicated for target audience

### 2. Cloud-Only App
- Pros: Simple, small install
- Cons: Excludes rural users entirely
- Rejected: Against core mission of serving underserved communities

### 3. Offline-Only App
- Pros: Works everywhere
- Cons: 2GB+ install excludes storage-constrained users
- Rejected: Limits urban adoption

## Related
- [ADR-004: HuggingFace Spaces Backend](004-huggingface-spaces-backend.md)
- [ADR-005: Incremental Pack Downloads](005-incremental-pack-downloads.md)
