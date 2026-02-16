/// Chat Provider Tests
///
/// Tests for ChatNotifier, ModelManagerNotifier, and related providers.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vazhi_app/providers/chat_provider.dart';

void main() {
  group('InferenceMode', () {
    test('has local and cloud modes', () {
      expect(InferenceMode.values.length, 2);
      expect(InferenceMode.values, contains(InferenceMode.local));
      expect(InferenceMode.values, contains(InferenceMode.cloud));
    });
  });

  group('ModelStatus', () {
    test('has all expected statuses', () {
      expect(ModelStatus.values.length, 6);
      expect(ModelStatus.values, contains(ModelStatus.notDownloaded));
      expect(ModelStatus.values, contains(ModelStatus.downloading));
      expect(ModelStatus.values, contains(ModelStatus.downloaded));
      expect(ModelStatus.values, contains(ModelStatus.loading));
      expect(ModelStatus.values, contains(ModelStatus.ready));
      expect(ModelStatus.values, contains(ModelStatus.error));
    });
  });

  group('PackInfo', () {
    test('creates PackInfo correctly', () {
      final pack = PackInfo(
        id: 'culture',
        name: 'Culture',
        nameTamil: 'கலாச்சாரம்',
        description: 'Tamil culture description',
        icon: '🪷',
      );

      expect(pack.id, 'culture');
      expect(pack.name, 'Culture');
      expect(pack.nameTamil, 'கலாச்சாரம்');
      expect(pack.icon, '🪷');
    });
  });

  group('availablePacksProvider', () {
    test('returns list of packs', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final packs = container.read(availablePacksProvider);

      expect(packs, isNotEmpty);
      expect(packs.length, 6);

      // Verify culture pack exists
      final culturePack = packs.firstWhere((p) => p.id == 'culture');
      expect(culturePack.nameTamil, 'கலாச்சாரம்');

      // Verify security pack exists
      final securityPack = packs.firstWhere((p) => p.id == 'security');
      expect(securityPack.icon, '🛡️');
    });

    test('all packs have required fields', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final packs = container.read(availablePacksProvider);

      for (final pack in packs) {
        expect(pack.id, isNotEmpty);
        expect(pack.name, isNotEmpty);
        expect(pack.nameTamil, isNotEmpty);
        expect(pack.description, isNotEmpty);
        expect(pack.icon, isNotEmpty);
      }
    });
  });

  group('currentPackProvider', () {
    test('defaults to culture', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final currentPack = container.read(currentPackProvider);
      expect(currentPack, 'culture');
    });

    test('can be changed', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(currentPackProvider.notifier).state = 'security';
      expect(container.read(currentPackProvider), 'security');
    });
  });

  group('inferenceModeProvider', () {
    test('defaults to local', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mode = container.read(inferenceModeProvider);
      expect(mode, InferenceMode.local);
    });

    test('can be changed to cloud', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(inferenceModeProvider.notifier).state =
          InferenceMode.cloud;
      expect(container.read(inferenceModeProvider), InferenceMode.cloud);
    });
  });

  group('downloadProgressProvider', () {
    test('defaults to 0.0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final progress = container.read(downloadProgressProvider);
      expect(progress, 0.0);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(downloadProgressProvider.notifier).state = 0.5;
      expect(container.read(downloadProgressProvider), 0.5);
    });
  });
}
