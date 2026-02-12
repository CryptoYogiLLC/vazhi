# ADR-005: Incremental Pack Downloads (Base + Pick Strategy)

## Status
**Superseded** by [ADR-009: Hybrid Retrieval Architecture](009-hybrid-retrieval-architecture.md)

> **Superseded (Feb 2026):** The "Base + Pick Packs" strategy described here — downloading a base GGUF model plus separate LoRA adapter packs (~60MB each) per domain — was never implemented. The hybrid retrieval architecture (ADR-009) took a fundamentally different approach: all domain knowledge is bundled as SQLite data within the app (~1.5MB total), and the AI model is a single optional GGUF download for conversational capabilities. There are no separate LoRA packs, no per-domain model downloads, and no pack manifest from HuggingFace Hub. The app provides full knowledge coverage (10 categories, ~390 records) immediately at install from SQLite alone.

## Date
2026-02-05

---

## Context

VAZHI Full requires users to download models for offline use. The complete system includes:
- Base model: 1.7GB (quantized Qwen 2.5 3B with VAZHI LoRA merged)
- 6 specialized packs: ~60MB each (LoRA adapters)

Total if bundled: ~2.1GB

### User Constraints
- Many users have limited storage (2-4GB free)
- Not all users need all packs
- Large single downloads often fail on mobile networks
- Users want to start using the app quickly

### Download Strategies Considered

| Strategy | Download Size | User Control | Complexity |
|----------|---------------|--------------|------------|
| All-in-One | 2.1GB | None | Low |
| Base + All Packs | 1.7GB + 360MB | None | Low |
| Base + Pick Packs | 1.7GB + (60MB × N) | High | Medium |
| Regional Bundles | 1.9-2.0GB | Limited | Medium |

## Decision

We will implement **Base + Pick Packs** strategy: users download the base model first, then selectively download packs they need.

### Download Flow

```
1. App Install (~100MB)
   └── Can use VAZHI Lite immediately (cloud)

2. Base Model Download (1.7GB)
   └── Required for offline mode
   └── General Tamil chat works

3. Pack Downloads (~60MB each)
   └── Optional per user choice
   └── Specialized domain knowledge
```

### User Journey

```
┌────────────────────────────────────────────────────────────┐
│  Welcome to VAZHI!                                          │
│                                                             │
│  Choose your mode:                                          │
│                                                             │
│  ┌─────────────────────┐  ┌─────────────────────┐          │
│  │  ☁️ VAZHI Lite       │  │  📱 VAZHI Full       │          │
│  │  Use online now     │  │  Download for        │          │
│  │  No downloads       │  │  offline use         │          │
│  └─────────────────────┘  └─────────────────────┘          │
│                                                             │
└────────────────────────────────────────────────────────────┘

        ↓ (User chooses Full)

┌────────────────────────────────────────────────────────────┐
│  Download Base Model                                        │
│                                                             │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 45%                    │
│  850 MB / 1.7 GB                                           │
│                                                             │
│  💡 Tip: Connect to WiFi for faster download               │
│                                                             │
│  [Pause]  [Cancel]                                         │
└────────────────────────────────────────────────────────────┘

        ↓ (Base downloaded)

┌────────────────────────────────────────────────────────────┐
│  Choose Your Packs                                          │
│  Download packs for topics you care about                   │
│                                                             │
│  🛡️ Security (Kaval)                          [Download]   │
│     Scam alerts, cyber safety              58 MB           │
│                                                             │
│  🏛️ Government (Arasu)                        [Download]   │
│     Schemes, ration card, CMCHIS           62 MB           │
│                                                             │
│  📚 Education (Kalvi)                         [Download]   │
│     Scholarships, exams, colleges          55 MB           │
│                                                             │
│  ⚖️ Legal (Sattam)                            [Download]   │
│     RTI, consumer rights, FIR              61 MB           │
│                                                             │
│  🏥 Healthcare (Maruthuvam)                   [Download]   │
│     Hospitals, Siddha, schemes             57 MB           │
│                                                             │
│  🏛️ Culture (Panpaadu)                        [Download]   │
│     Thirukkural, temples, festivals        52 MB           │
│                                                             │
│                              [Skip - Use Base Model Only]   │
└────────────────────────────────────────────────────────────┘
```

### Technical Implementation

#### Pack Manifest (from HuggingFace Hub)

```json
{
  "version": "1.0",
  "base_model": {
    "name": "vazhi-base-q4",
    "file": "vazhi-base-q4.gguf",
    "size_bytes": 1825361920,
    "sha256": "abc123...",
    "url": "https://huggingface.co/CryptoYogiLLC/vazhi/resolve/main/vazhi-base-q4.gguf"
  },
  "packs": [
    {
      "id": "security",
      "name": "Vazhi Kaval",
      "name_tamil": "வழி காவல்",
      "description": "Scam detection, cyber safety, fraud alerts",
      "file": "vazhi-kaval.gguf",
      "size_bytes": 60817408,
      "sha256": "def456...",
      "url": "https://huggingface.co/CryptoYogiLLC/vazhi/resolve/main/packs/vazhi-kaval.gguf"
    }
    // ... other packs
  ]
}
```

#### Download Manager

```dart
class PackDownloadManager {
  Future<void> downloadBaseModel({
    required Function(double) onProgress,
    required Function() onComplete,
  }) async {
    final manifest = await fetchManifest();
    await downloadWithResume(
      url: manifest.baseModel.url,
      destPath: "${appDir}/models/vazhi-base-q4.gguf",
      expectedHash: manifest.baseModel.sha256,
      onProgress: onProgress,
    );
    onComplete();
  }

  Future<void> downloadPack(String packId, {
    required Function(double) onProgress,
  }) async {
    final manifest = await fetchManifest();
    final pack = manifest.packs.firstWhere((p) => p.id == packId);
    await downloadWithResume(
      url: pack.url,
      destPath: "${appDir}/packs/${pack.file}",
      expectedHash: pack.sha256,
      onProgress: onProgress,
    );
    await enablePack(packId);
  }
}
```

## Consequences

### Positive
- **Faster start** - Users can use Lite mode immediately
- **Storage efficient** - Download only needed packs
- **Resumable** - Large downloads can pause/resume
- **User control** - Clear visibility of storage usage
- **Flexible** - Add/remove packs anytime

### Negative
- **More UI complexity** - Pack manager screen needed
- **Multiple downloads** - User makes several decisions
- **Potential confusion** - "Why do I need to download more?"

### Mitigations
- Clear onboarding explaining the pack system
- Recommended packs based on first query
- "Download All" option for users with space
- Show storage impact before each download

## Storage Scenarios

| User Type | Downloads | Total Size |
|-----------|-----------|------------|
| Light user | Base only | 1.7GB |
| Typical user | Base + 2 packs | 1.82GB |
| Power user | Base + all packs | 2.06GB |
| Lite only | None | 0GB (cloud) |

## Related
- [ADR-001: Hybrid App Strategy](001-hybrid-app-strategy.md)
- [VAZHI Mobile Architecture](../architecture/VAZHI_MOBILE_ARCHITECTURE.md)
