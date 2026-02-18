/// Model Variant Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:vazhi_app/models/model_variant.dart';

void main() {
  group('ModelVariant - computed properties', () {
    const variant = ModelVariant(
      id: 'test',
      quantization: 'Q4_K_M',
      filename: 'model.gguf',
      url: 'https://example.com/model.gguf',
      expectedSizeBytes: 800000000,
      displaySize: '~800 MB',
      quality: ModelQuality.high,
      qualityLabel: 'Best',
      qualityLabelTamil: 'சிறந்தது',
      recommendedRamMB: 6144,
    );

    test('partialFilename appends .partial', () {
      expect(variant.partialFilename, 'model.gguf.partial');
    });

    test('minimumValidSizeBytes is 90% of expected', () {
      expect(variant.minimumValidSizeBytes, 720000000);
    });

    test('requiredSpaceBytes includes 200MB buffer', () {
      expect(variant.requiredSpaceBytes, 800000000 + 200 * 1024 * 1024);
    });

    test('isVazhi defaults to true', () {
      expect(variant.isVazhi, isTrue);
    });
  });

  group('ModelRegistry', () {
    test('has 5 variants', () {
      expect(ModelRegistry.variants.length, 5);
    });

    test('variants are ordered by quality (best first)', () {
      expect(ModelRegistry.variants[0].quality, ModelQuality.high);
      expect(ModelRegistry.variants[1].quality, ModelQuality.medium);
      expect(ModelRegistry.variants[2].quality, ModelQuality.low);
      expect(ModelRegistry.variants[3].quality, ModelQuality.medium);
      expect(ModelRegistry.variants[4].quality, ModelQuality.lite);
    });

    test('defaultVariant is Q4_K_M', () {
      expect(ModelRegistry.defaultVariant.id, 'q4_k_m');
    });

    test('all variants have unique ids', () {
      final ids = ModelRegistry.variants.map((v) => v.id).toSet();
      expect(ids.length, ModelRegistry.variants.length);
    });

    test('all variants have .gguf filenames', () {
      for (final v in ModelRegistry.variants) {
        expect(v.filename, endsWith('.gguf'));
      }
    });

    test('all variants have huggingface URLs', () {
      for (final v in ModelRegistry.variants) {
        expect(v.url, contains('huggingface.co'));
      }
    });

    test('all variants have reasonable sizes', () {
      for (final v in ModelRegistry.variants) {
        expect(v.expectedSizeBytes, greaterThan(200000000));
        expect(v.expectedSizeBytes, lessThan(1000000000));
      }
    });

    test('VAZHI models come before non-VAZHI models', () {
      final vazhi = ModelRegistry.variants.where((v) => v.isVazhi).toList();
      final other = ModelRegistry.variants.where((v) => !v.isVazhi).toList();
      expect(vazhi.length, 3);
      expect(other.length, 2);
      // VAZHI models are first 3 entries
      for (var i = 0; i < vazhi.length; i++) {
        expect(ModelRegistry.variants[i].isVazhi, isTrue);
      }
      // Non-VAZHI models are last 2 entries
      for (var i = vazhi.length; i < ModelRegistry.variants.length; i++) {
        expect(ModelRegistry.variants[i].isVazhi, isFalse);
      }
    });

    test('defaultVariant is a VAZHI model', () {
      expect(ModelRegistry.defaultVariant.isVazhi, isTrue);
    });
  });

  group('ModelRegistry.findById', () {
    test('finds Q4_K_M by id', () {
      final v = ModelRegistry.findById('q4_k_m');
      expect(v.quantization, 'Q4_K_M');
    });

    test('finds Q3_K_M by id', () {
      final v = ModelRegistry.findById('q3_k_m');
      expect(v.quantization, 'Q3_K_M');
    });

    test('finds Q2_K by id', () {
      final v = ModelRegistry.findById('q2_k');
      expect(v.quantization, 'Q2_K');
    });

    test('finds QAT Q2_K by id', () {
      final v = ModelRegistry.findById('qat_q2_k');
      expect(v.quantization, 'QAT Q2_K');
    });

    test('finds 270M Q6_K_L by id', () {
      final v = ModelRegistry.findById('gemma_270m_q6_k_l');
      expect(v.quantization, '270M Q6_K_L');
    });

    test('returns default for unknown id', () {
      final v = ModelRegistry.findById('nonexistent');
      expect(v.id, ModelRegistry.defaultVariant.id);
    });
  });

  group('ModelQuality', () {
    test('has 4 values', () {
      expect(ModelQuality.values.length, 4);
    });

    test('contains high, medium, low, lite', () {
      expect(ModelQuality.values, contains(ModelQuality.high));
      expect(ModelQuality.values, contains(ModelQuality.medium));
      expect(ModelQuality.values, contains(ModelQuality.low));
      expect(ModelQuality.values, contains(ModelQuality.lite));
    });
  });
}
