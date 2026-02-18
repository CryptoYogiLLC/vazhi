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
      displayName: 'Test Model',
      displayNameTamil: 'சோதனை',
      minDeviceRamMB: 5500,
      minFreeRamMB: 200,
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

    test('isTrimmed defaults to false', () {
      expect(variant.isTrimmed, isFalse);
    });
  });

  group('ModelVariant - new fields', () {
    test('all registry variants have displayName', () {
      for (final v in ModelRegistry.variants) {
        expect(v.displayName.isNotEmpty, isTrue);
      }
    });

    test('all registry variants have displayNameTamil', () {
      for (final v in ModelRegistry.variants) {
        expect(v.displayNameTamil.isNotEmpty, isTrue);
      }
    });

    test('all registry variants have minDeviceRamMB > 0', () {
      for (final v in ModelRegistry.variants) {
        expect(v.minDeviceRamMB, greaterThan(0));
      }
    });

    test('all registry variants have minFreeRamMB > 0', () {
      for (final v in ModelRegistry.variants) {
        expect(v.minFreeRamMB, greaterThan(0));
      }
    });

    test('trimmed variants are marked isTrimmed', () {
      final trimmed = ModelRegistry.variants.where((v) => v.isTrimmed);
      expect(trimmed.length, 2);
      expect(trimmed.every((v) => v.id.contains('trimmed')), isTrue);
    });
  });

  group('ModelRegistry', () {
    test('has 3 variants', () {
      expect(ModelRegistry.variants.length, 3);
    });

    test('variants are ordered by quality (best first)', () {
      expect(ModelRegistry.variants[0].quality, ModelQuality.high);
      expect(ModelRegistry.variants[1].quality, ModelQuality.high);
      expect(ModelRegistry.variants[2].quality, ModelQuality.medium);
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

    test('all variants are VAZHI-trained', () {
      for (final v in ModelRegistry.variants) {
        expect(v.isVazhi, isTrue);
      }
    });

    test('defaultVariant is a VAZHI model', () {
      expect(ModelRegistry.defaultVariant.isVazhi, isTrue);
    });
  });

  group('ModelRegistry.findById', () {
    test('finds q4_k_m by id', () {
      final v = ModelRegistry.findById('q4_k_m');
      expect(v.id, 'q4_k_m');
      expect(v.displayName, 'High Quality');
    });

    test('finds q4_k_m_trimmed by id', () {
      final v = ModelRegistry.findById('q4_k_m_trimmed');
      expect(v.id, 'q4_k_m_trimmed');
      expect(v.displayName, 'Balanced');
    });

    test('finds q3_k_m_trimmed by id', () {
      final v = ModelRegistry.findById('q3_k_m_trimmed');
      expect(v.id, 'q3_k_m_trimmed');
      expect(v.displayName, 'Compact');
    });

    test('returns default for unknown id', () {
      final v = ModelRegistry.findById('nonexistent');
      expect(v.id, ModelRegistry.defaultVariant.id);
    });

    test('migrates removed q2_k to recommended for 6GB device', () {
      final v = ModelRegistry.findById('q2_k', totalRamMB: 5600);
      expect(v.id, 'q4_k_m'); // standard tier → High Quality
    });

    test('migrates removed qat_q2_k to recommended for 4GB device', () {
      final v = ModelRegistry.findById('qat_q2_k', totalRamMB: 3700);
      expect(v.id, 'q4_k_m_trimmed'); // compact tier → Balanced
    });

    test('migrates removed gemma_270m_q6_k_l to recommended', () {
      final v = ModelRegistry.findById('gemma_270m_q6_k_l', totalRamMB: 7800);
      expect(v.id, 'q4_k_m'); // premium tier → High Quality
    });

    test('migrates removed q3_k_m to fallback for sqliteOnly device', () {
      final v = ModelRegistry.findById('q3_k_m', totalRamMB: 3000);
      // sqliteOnly → recommendedForDevice returns null → falls back to last variant
      expect(v.id, 'q3_k_m_trimmed');
    });

    test('removed variant without totalRamMB returns default', () {
      final v = ModelRegistry.findById('q2_k');
      expect(v.id, ModelRegistry.defaultVariant.id);
    });
  });

  group('DeviceTier', () {
    test('has 4 values', () {
      expect(DeviceTier.values.length, 4);
    });

    test('contains premium, standard, compact, sqliteOnly', () {
      expect(DeviceTier.values, contains(DeviceTier.premium));
      expect(DeviceTier.values, contains(DeviceTier.standard));
      expect(DeviceTier.values, contains(DeviceTier.compact));
      expect(DeviceTier.values, contains(DeviceTier.sqliteOnly));
    });
  });

  group('ModelRegistry.classifyDevice', () {
    test('3000 MB → sqliteOnly', () {
      expect(ModelRegistry.classifyDevice(3000), DeviceTier.sqliteOnly);
    });

    test('3499 MB → sqliteOnly (just under threshold)', () {
      expect(ModelRegistry.classifyDevice(3499), DeviceTier.sqliteOnly);
    });

    test('3500 MB → compact (threshold)', () {
      expect(ModelRegistry.classifyDevice(3500), DeviceTier.compact);
    });

    test('3700 MB → compact (real "4GB" phone)', () {
      expect(ModelRegistry.classifyDevice(3700), DeviceTier.compact);
    });

    test('5199 MB → compact (just under standard)', () {
      expect(ModelRegistry.classifyDevice(5199), DeviceTier.compact);
    });

    test('5200 MB → standard (threshold)', () {
      expect(ModelRegistry.classifyDevice(5200), DeviceTier.standard);
    });

    test('5600 MB → standard (real "6GB" phone)', () {
      expect(ModelRegistry.classifyDevice(5600), DeviceTier.standard);
    });

    test('7499 MB → standard (just under premium)', () {
      expect(ModelRegistry.classifyDevice(7499), DeviceTier.standard);
    });

    test('7500 MB → premium (threshold)', () {
      expect(ModelRegistry.classifyDevice(7500), DeviceTier.premium);
    });

    test('7800 MB → premium (real "8GB" phone)', () {
      expect(ModelRegistry.classifyDevice(7800), DeviceTier.premium);
    });

    test('16000 MB → premium (high-end phone)', () {
      expect(ModelRegistry.classifyDevice(16000), DeviceTier.premium);
    });
  });

  group('ModelRegistry.filterForDevice', () {
    test('3700 MB returns only trimmed variants', () {
      final models = ModelRegistry.filterForDevice(3700);
      expect(models.length, 2);
      expect(models.every((v) => v.isTrimmed), isTrue);
    });

    test('5600 MB returns all 3 variants', () {
      final models = ModelRegistry.filterForDevice(5600);
      expect(models.length, 3);
    });

    test('3000 MB returns empty list', () {
      final models = ModelRegistry.filterForDevice(3000);
      expect(models, isEmpty);
    });

    test('7800 MB returns all 3 variants', () {
      final models = ModelRegistry.filterForDevice(7800);
      expect(models.length, 3);
    });
  });

  group('ModelRegistry.recommendedForDevice', () {
    test('3700 MB → q4_k_m_trimmed (Balanced)', () {
      final model = ModelRegistry.recommendedForDevice(3700);
      expect(model, isNotNull);
      expect(model!.id, 'q4_k_m_trimmed');
    });

    test('5600 MB → q4_k_m (High Quality)', () {
      final model = ModelRegistry.recommendedForDevice(5600);
      expect(model, isNotNull);
      expect(model!.id, 'q4_k_m');
    });

    test('7800 MB → q4_k_m (High Quality)', () {
      final model = ModelRegistry.recommendedForDevice(7800);
      expect(model, isNotNull);
      expect(model!.id, 'q4_k_m');
    });

    test('3000 MB → null (sqliteOnly)', () {
      final model = ModelRegistry.recommendedForDevice(3000);
      expect(model, isNull);
    });
  });

  group('ModelQuality', () {
    test('has 2 values', () {
      expect(ModelQuality.values.length, 2);
    });

    test('contains high, medium', () {
      expect(ModelQuality.values, contains(ModelQuality.high));
      expect(ModelQuality.values, contains(ModelQuality.medium));
    });
  });
}
