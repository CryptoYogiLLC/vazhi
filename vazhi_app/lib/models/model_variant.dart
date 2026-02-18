/// Model Variant
///
/// Data class representing a GGUF model variant and a registry
/// of available models. Single source of truth for model metadata —
/// eliminates hardcoded constants scattered across services.
///
/// Includes device tier classification and RAM-aware filtering
/// for smart model selection (ADR-013).
library;

/// Quality tier of a model variant
enum ModelQuality { high, medium }

/// Device RAM tier for model compatibility filtering.
/// Thresholds are tolerant of Android's totalMem reporting
/// (e.g., a "4GB" phone reports ~3700-3900 MB).
enum DeviceTier {
  premium, // 8GB+ marketed (totalMem >= 7500)
  standard, // 6GB marketed (totalMem >= 5200)
  compact, // 4GB marketed (totalMem >= 3500)
  sqliteOnly, // <4GB — no LLM, hybrid SQLite only
}

/// A GGUF model variant with all metadata needed for download and inference.
class ModelVariant {
  /// Unique identifier for persistence (e.g., 'q4_k_m')
  final String id;

  /// Quantization label (e.g., 'Q4_K_M')
  final String quantization;

  /// GGUF filename on disk
  final String filename;

  /// Full download URL
  final String url;

  /// Expected file size in bytes
  final int expectedSizeBytes;

  /// Human-readable size (e.g., '~806 MB')
  final String displaySize;

  /// Quality tier
  final ModelQuality quality;

  /// User-friendly English name (e.g., 'High Quality')
  final String displayName;

  /// User-friendly Tamil name (e.g., 'உயர் தரம்')
  final String displayNameTamil;

  /// Minimum total device RAM (in MB) to show this option
  final int minDeviceRamMB;

  /// Minimum available RAM (in MB) needed to load this model safely
  final int minFreeRamMB;

  /// Whether this is a vocabulary-trimmed variant
  final bool isTrimmed;

  /// Optional SHA256 checksum for integrity verification
  final String? sha256;

  /// Whether this model was fine-tuned by the VAZHI project
  final bool isVazhi;

  const ModelVariant({
    required this.id,
    required this.quantization,
    required this.filename,
    required this.url,
    required this.expectedSizeBytes,
    required this.displaySize,
    required this.quality,
    required this.displayName,
    required this.displayNameTamil,
    required this.minDeviceRamMB,
    required this.minFreeRamMB,
    this.isTrimmed = false,
    this.sha256,
    this.isVazhi = true,
  });

  /// Partial download filename (for resume support)
  String get partialFilename => '$filename.partial';

  /// Minimum valid file size (90% of expected — catches truncated downloads)
  int get minimumValidSizeBytes => (expectedSizeBytes * 0.9).toInt();

  /// Required disk space (model + 200MB buffer)
  int get requiredSpaceBytes => expectedSizeBytes + 200 * 1024 * 1024;
}

/// Registry of available model variants.
class ModelRegistry {
  ModelRegistry._();

  /// IDs of removed variants — used for migration from older app versions.
  static const Set<String> _removedVariantIds = {
    'q2_k',
    'qat_q2_k',
    'gemma_270m_q6_k_l',
    'q3_k_m',
  };

  /// All available model variants, ordered by quality (best first).
  static const List<ModelVariant> variants = [
    ModelVariant(
      id: 'q4_k_m',
      quantization: 'Q4_K_M',
      filename: 'vazhi-v7_1-q4_k_m.gguf',
      url:
          'https://huggingface.co/CryptoYogi/vazhi-v7_1-Q4_K_M-GGUF/resolve/main/vazhi-v7_1-q4_k_m.gguf',
      expectedSizeBytes: 806000000,
      displaySize: '~806 MB',
      quality: ModelQuality.high,
      displayName: 'High Quality',
      displayNameTamil: 'உயர் தரம்',
      minDeviceRamMB: 5500,
      minFreeRamMB: 200,
    ),
    ModelVariant(
      id: 'q4_k_m_trimmed',
      quantization: 'Q4_K_M',
      filename: 'vazhi-v7.1-trimmed-q4_k_m.gguf',
      url:
          'https://huggingface.co/CryptoYogi/vazhi-v7_1-trimmed/resolve/main/vazhi-v7.1-trimmed-q4_k_m.gguf',
      expectedSizeBytes: 505000000,
      displaySize: '~505 MB',
      quality: ModelQuality.high,
      displayName: 'Balanced',
      displayNameTamil: 'சமநிலை',
      minDeviceRamMB: 3500,
      minFreeRamMB: 100,
      isTrimmed: true,
    ),
    ModelVariant(
      id: 'q3_k_m_trimmed',
      quantization: 'Q3_K_M',
      filename: 'vazhi-v7.1-trimmed-q3_k_m.gguf',
      url:
          'https://huggingface.co/CryptoYogi/vazhi-v7_1-trimmed/resolve/main/vazhi-v7.1-trimmed-q3_k_m.gguf',
      expectedSizeBytes: 421000000,
      displaySize: '~421 MB',
      quality: ModelQuality.medium,
      displayName: 'Compact',
      displayNameTamil: 'சிறியது',
      minDeviceRamMB: 3500,
      minFreeRamMB: 80,
      isTrimmed: true,
    ),
  ];

  /// Default variant (best quality)
  static ModelVariant get defaultVariant => variants[0];

  /// Look up a variant by its persisted ID.
  /// Migrates removed variant IDs to the recommended model for the device,
  /// or to the default variant if no totalRamMB is provided.
  static ModelVariant findById(String id, {int? totalRamMB}) {
    for (final v in variants) {
      if (v.id == id) return v;
    }
    // Migration: old removed variant → pick best for device
    if (_removedVariantIds.contains(id) && totalRamMB != null) {
      return recommendedForDevice(totalRamMB) ?? variants.last;
    }
    return defaultVariant;
  }

  /// Classify device into a RAM tier using tolerant thresholds.
  /// Android's totalMem doesn't match marketed RAM exactly
  /// (e.g., "4GB" phone reports ~3700-3900 MB).
  static DeviceTier classifyDevice(int totalRamMB) {
    if (totalRamMB >= 7500) return DeviceTier.premium;
    if (totalRamMB >= 5200) return DeviceTier.standard;
    if (totalRamMB >= 3500) return DeviceTier.compact;
    return DeviceTier.sqliteOnly;
  }

  /// Return only variants compatible with the device's total RAM.
  static List<ModelVariant> filterForDevice(int totalRamMB) {
    return variants.where((v) => totalRamMB >= v.minDeviceRamMB).toList();
  }

  /// Recommend the best model for a device tier.
  /// Returns null for sqliteOnly (no model is appropriate).
  static ModelVariant? recommendedForDevice(int totalRamMB) {
    final tier = classifyDevice(totalRamMB);
    switch (tier) {
      case DeviceTier.premium:
      case DeviceTier.standard:
        return variants[0]; // q4_k_m (High Quality)
      case DeviceTier.compact:
        return variants[1]; // q4_k_m_trimmed (Balanced)
      case DeviceTier.sqliteOnly:
        return null;
    }
  }
}
