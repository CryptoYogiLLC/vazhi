/// Model Variant
///
/// Data class representing a GGUF model variant and a registry
/// of available models. Single source of truth for model metadata —
/// eliminates hardcoded constants scattered across services.
library;

/// Quality tier of a model variant
enum ModelQuality { high, medium, low, lite }

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

  /// English quality label
  final String qualityLabel;

  /// Tamil quality label
  final String qualityLabelTamil;

  /// Recommended device RAM in MB
  final int recommendedRamMB;

  /// Optional SHA256 checksum for integrity verification
  final String? sha256;

  const ModelVariant({
    required this.id,
    required this.quantization,
    required this.filename,
    required this.url,
    required this.expectedSizeBytes,
    required this.displaySize,
    required this.quality,
    required this.qualityLabel,
    required this.qualityLabelTamil,
    required this.recommendedRamMB,
    this.sha256,
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
      qualityLabel: 'Best',
      qualityLabelTamil: 'சிறந்தது',
      recommendedRamMB: 6144,
    ),
    ModelVariant(
      id: 'q3_k_m',
      quantization: 'Q3_K_M',
      filename: 'vazhi-v7_1-q3_k_m.gguf',
      url:
          'https://huggingface.co/CryptoYogi/vazhi-v7_1-Q3_K_M-GGUF/resolve/main/vazhi-v7_1-q3_k_m.gguf',
      expectedSizeBytes: 722000000,
      displaySize: '~722 MB',
      quality: ModelQuality.medium,
      qualityLabel: 'Medium',
      qualityLabelTamil: 'நடுத்தரம்',
      recommendedRamMB: 4096,
    ),
    ModelVariant(
      id: 'q2_k',
      quantization: 'Q2_K',
      filename: 'vazhi-v7_1-q2_k.gguf',
      url:
          'https://huggingface.co/CryptoYogi/vazhi-v7_1-Q2_K-GGUF/resolve/main/vazhi-v7_1-q2_k.gguf',
      expectedSizeBytes: 690000000,
      displaySize: '~690 MB',
      quality: ModelQuality.low,
      qualityLabel: 'Low',
      qualityLabelTamil: 'குறைவு',
      recommendedRamMB: 3072,
    ),
    ModelVariant(
      id: 'qat_q2_k',
      quantization: 'QAT Q2_K',
      filename: 'google_gemma-3-1b-it-qat-Q2_K.gguf',
      url:
          'https://huggingface.co/bartowski/google_gemma-3-1b-it-qat-GGUF/resolve/main/google_gemma-3-1b-it-qat-Q2_K.gguf',
      expectedSizeBytes: 690000000,
      displaySize: '~690 MB',
      quality: ModelQuality.medium,
      qualityLabel: 'Good',
      qualityLabelTamil: 'நல்லது',
      recommendedRamMB: 4096,
    ),
    ModelVariant(
      id: 'gemma_270m_q6_k_l',
      quantization: '270M Q6_K_L',
      filename: 'google_gemma-3-270m-it-Q6_K_L.gguf',
      url:
          'https://huggingface.co/bartowski/google_gemma-3-270m-it-GGUF/resolve/main/google_gemma-3-270m-it-Q6_K_L.gguf',
      expectedSizeBytes: 283000000,
      displaySize: '~283 MB',
      quality: ModelQuality.lite,
      qualityLabel: 'Lite',
      qualityLabelTamil: 'லைட்',
      recommendedRamMB: 2048,
    ),
  ];

  /// Default variant (best quality)
  static ModelVariant get defaultVariant => variants[0];

  /// Look up a variant by its persisted ID. Returns default if not found.
  static ModelVariant findById(String id) {
    for (final v in variants) {
      if (v.id == id) return v;
    }
    return defaultVariant;
  }
}
