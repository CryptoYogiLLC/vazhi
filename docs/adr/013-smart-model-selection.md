# ADR-013: Smart Model Selection with RAM Detection

## Status

Accepted

## Context

VAZHI's vocabulary-trimmed GGUF models work on 4GB Android devices (harness tests confirmed Q4_K_M at 505 MB, Q3_K_M at 421 MB, Q2_K at 389 MB). However, the previous model selector (ADR-011) showed 5 variants with quantization jargon (Q4_K_M, Q3_K_M, Q2_K, QAT Q2_K, 270M Q6_K_L) and static RAM recommendations that ignored the user's actual device capabilities.

Problems:
- Users could download a model that crashes their phone
- Quantization labels are meaningless to target users in rural Tamil Nadu
- Real-world phones with WhatsApp/FB/YouTube running have far less available RAM than marketed specs
- Android's `totalMem` doesn't match marketed RAM (e.g., "4GB" phone reports ~3700-3900 MB)
- No runtime check prevented loading a model on a memory-constrained device

## Decision

### Device Tier System

Detect device RAM at runtime via platform channels and classify into tiers with tolerant thresholds:

| Tier | Marketed RAM | Threshold (totalMem) | Available Models |
|------|-------------|---------------------|-----------------|
| premium | 8GB+ | >= 7500 MB | All 3 variants |
| standard | 6-7GB | >= 5200 MB | All 3 variants |
| compact | 4-5GB | >= 3500 MB | Trimmed only (2) |
| sqliteOnly | <4GB | < 3500 MB | None (SQLite retrieval only) |

### Variant Reduction (5 to 3)

Removed variants:
- `q2_k` — loses 4/10 Tamil answers, quality too low
- `qat_q2_k` — not VAZHI-trained (community model)
- `gemma_270m_q6_k_l` — not VAZHI-trained (community model)
- `q3_k_m` — untrimmed, too large for 4GB devices

Remaining variants:

| ID | Display Name | Tamil | Size | Min Device RAM | Quality |
|----|-------------|-------|------|---------------|---------|
| q4_k_m | High Quality | உயர் தரம் | ~806 MB | 5500 MB | high |
| q4_k_m_trimmed | Balanced | சமநிலை | ~505 MB | 3500 MB | high |
| q3_k_m_trimmed | Compact | சிறியது | ~421 MB | 3500 MB | medium |

All 3 are VAZHI-trained. User-friendly names replace quantization labels ("High Quality" instead of "Q4_K_M"). Quantization shown in small grey text for advanced users.

### RAM Detection

Platform channels (`com.cryptoyogillc.vazhi/device_info`):
- **Android:** `ActivityManager.getMemoryInfo()` returns totalMem, availMem, lowMemory, threshold
- **iOS:** `ProcessInfo.processInfo.physicalMemory` + `os_proc_available_memory()`

Safe fallback when detection fails: show only trimmed models + warning banner.

### Pre-Inference RAM Check

Two-level check using Android's own memory pressure signals:
1. **Before model load** (`loadModel()`): Block if `lowMemory == true` or `availableRam < minFreeRamMB`
2. **Before each inference** (`sendMessage()`): Quick RAM check, return Tamil error message instead of crash

Per-model `minFreeRamMB` values derived from harness test measurements with safety margin.

### Migration Strategy

Old persisted variant IDs are auto-migrated on app launch:
- Removed IDs (`q2_k`, `qat_q2_k`, `gemma_270m_q6_k_l`, `q3_k_m`) map to `recommendedForDevice(totalRam)`
- First launch with no persisted ID: auto-select recommended model for device

## Consequences

### Positive
- Users cannot download models that will crash their device
- User-friendly labels eliminate quantization confusion
- Pre-inference RAM checks prevent mid-conversation crashes
- Safe fallback behavior when RAM detection fails
- Automatic migration from older app versions

### Negative
- Reduces user choice (5 to 3 variants) — mitigated by all removed variants being either low-quality or not VAZHI-trained
- Platform channel adds native code (first in the app) — minimal maintenance burden
- Users on sqliteOnly devices see no model options — but these devices genuinely cannot run any Gemma 3 model (ADR-012)

## References

- ADR-011: Model Selector Architecture
- ADR-012: 4GB SQLite-Only Architecture
- Harness test results: trimmed Q4_K_M uses 25 MB RSS, trimmed Q3_K_M uses 16 MB RSS on 4GB device
