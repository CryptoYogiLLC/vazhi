/// Model Download Service Tests
///
/// Tests for security features and download functionality.

import 'package:flutter_test/flutter_test.dart';
import 'package:vazhi_app/services/model_download_service.dart';

void main() {
  group('DownloadState', () {
    test('has all expected states', () {
      expect(DownloadState.values.length, 7);
      expect(DownloadState.values, contains(DownloadState.idle));
      expect(DownloadState.values, contains(DownloadState.checking));
      expect(DownloadState.values, contains(DownloadState.downloading));
      expect(DownloadState.values, contains(DownloadState.paused));
      expect(DownloadState.values, contains(DownloadState.verifying));
      expect(DownloadState.values, contains(DownloadState.completed));
      expect(DownloadState.values, contains(DownloadState.error));
    });
  });

  group('NetworkType', () {
    test('has wifi, cellular, and none', () {
      expect(NetworkType.values.length, 3);
      expect(NetworkType.values, contains(NetworkType.wifi));
      expect(NetworkType.values, contains(NetworkType.cellular));
      expect(NetworkType.values, contains(NetworkType.none));
    });
  });

  group('DownloadProgress', () {
    test('creates with default values', () {
      const progress = DownloadProgress();

      expect(progress.state, DownloadState.idle);
      expect(progress.progress, 0.0);
      expect(progress.downloadedBytes, 0);
      expect(progress.totalBytes, 0);
      expect(progress.speedBytesPerSecond, 0);
      expect(progress.estimatedTimeRemaining, isNull);
      expect(progress.errorMessage, isNull);
      expect(progress.networkType, NetworkType.none);
    });

    test('progressPercent formats correctly', () {
      const progress = DownloadProgress(progress: 0.5);
      expect(progress.progressPercent, '50%');
    });

    test('progressPercent handles 0%', () {
      const progress = DownloadProgress(progress: 0.0);
      expect(progress.progressPercent, '0%');
    });

    test('progressPercent handles 100%', () {
      const progress = DownloadProgress(progress: 1.0);
      expect(progress.progressPercent, '100%');
    });

    test('downloadedSize formats bytes correctly', () {
      const progress = DownloadProgress(downloadedBytes: 512);
      expect(progress.downloadedSize, '512 B');
    });

    test('downloadedSize formats KB correctly', () {
      const progress = DownloadProgress(downloadedBytes: 1536);
      expect(progress.downloadedSize, '1.5 KB');
    });

    test('downloadedSize formats MB correctly', () {
      const progress = DownloadProgress(downloadedBytes: 1572864);
      expect(progress.downloadedSize, '1.5 MB');
    });

    test('downloadedSize formats GB correctly', () {
      const progress = DownloadProgress(downloadedBytes: 1610612736);
      expect(progress.downloadedSize, '1.50 GB');
    });

    test('speed formats correctly', () {
      const progress = DownloadProgress(speedBytesPerSecond: 1048576);
      expect(progress.speed, '1.0 MB/s');
    });

    test('eta shows seconds for short times', () {
      const progress = DownloadProgress(
        estimatedTimeRemaining: Duration(seconds: 45),
      );
      expect(progress.eta, '45s');
    });

    test('eta shows minutes and seconds', () {
      const progress = DownloadProgress(
        estimatedTimeRemaining: Duration(minutes: 2, seconds: 30),
      );
      expect(progress.eta, '2m 30s');
    });

    test('eta shows hours and minutes', () {
      const progress = DownloadProgress(
        estimatedTimeRemaining: Duration(hours: 1, minutes: 15),
      );
      expect(progress.eta, '1h 15m');
    });

    test('eta shows -- when null', () {
      const progress = DownloadProgress();
      expect(progress.eta, '--:--');
    });

    test('copyWith updates fields correctly', () {
      const progress = DownloadProgress();
      final updated = progress.copyWith(
        state: DownloadState.downloading,
        progress: 0.5,
        downloadedBytes: 1000000,
      );

      expect(updated.state, DownloadState.downloading);
      expect(updated.progress, 0.5);
      expect(updated.downloadedBytes, 1000000);
      expect(updated.totalBytes, 0); // unchanged
    });

    test('copyWith clears errorMessage when not specified', () {
      const progress = DownloadProgress(errorMessage: 'error');
      final updated = progress.copyWith(state: DownloadState.downloading);

      // errorMessage is nullable and copyWith doesn't preserve it by default
      expect(updated.errorMessage, isNull);
    });
  });

  group('StorageInfo', () {
    test('hasEnoughSpace is true when available > required', () {
      final info = StorageInfo(
        availableBytes: 2000000000,
        requiredBytes: 1000000000,
      );
      expect(info.hasEnoughSpace, isTrue);
    });

    test('hasEnoughSpace is false when available < required', () {
      final info = StorageInfo(
        availableBytes: 500000000,
        requiredBytes: 1000000000,
      );
      expect(info.hasEnoughSpace, isFalse);
    });

    test('isLowSpace is true when buffer is insufficient', () {
      final info = StorageInfo(
        availableBytes: 1100000000, // 10% buffer
        requiredBytes: 1000000000,
      );
      expect(info.isLowSpace, isTrue);
    });

    test('isLowSpace is false with 20%+ buffer', () {
      final info = StorageInfo(
        availableBytes: 1300000000, // 30% buffer
        requiredBytes: 1000000000,
      );
      expect(info.isLowSpace, isFalse);
    });

    test('formats sizes correctly', () {
      final info = StorageInfo(
        availableBytes: 5000000000,
        requiredBytes: 1800000000,
      );
      expect(info.availableSpace, contains('GB'));
      expect(info.requiredSpace, contains('GB'));
    });
  });

  group('ModelDownloadService - Constants', () {
    test('modelUrl is HuggingFace URL', () {
      expect(ModelDownloadService.modelUrl, contains('huggingface.co'));
    });

    test('modelFilename has .gguf extension', () {
      expect(ModelDownloadService.modelFilename, endsWith('.gguf'));
    });

    test('expectedModelSize is approximately 1.6GB', () {
      expect(ModelDownloadService.expectedModelSize, greaterThan(1500000000));
      expect(ModelDownloadService.expectedModelSize, lessThan(2000000000));
    });

    test('requiredSpace includes buffer', () {
      expect(
        ModelDownloadService.requiredSpace,
        greaterThan(ModelDownloadService.expectedModelSize),
      );
    });
  });

  group('ModelDownloadException', () {
    test('stores message', () {
      final exception = ModelDownloadException('Test error');
      expect(exception.message, 'Test error');
    });

    test('toString returns message', () {
      final exception = ModelDownloadException('Test error');
      expect(exception.toString(), 'Test error');
    });

    test('preserves Tamil messages', () {
      final exception = ModelDownloadException('பிழை ஏற்பட்டது');
      expect(exception.message, 'பிழை ஏற்பட்டது');
    });
  });

  group('ModelDownloadService - Instance', () {
    late ModelDownloadService service;

    setUp(() {
      service = ModelDownloadService();
    });

    tearDown(() {
      service.dispose();
    });

    test('progressStream is broadcast stream', () {
      final stream = service.progressStream;
      expect(stream.isBroadcast, isTrue);
    });

    test('can subscribe to progress stream multiple times', () {
      // Broadcast streams allow multiple listeners
      final sub1 = service.progressStream.listen((_) {});
      final sub2 = service.progressStream.listen((_) {});

      expect(sub1, isNotNull);
      expect(sub2, isNotNull);

      sub1.cancel();
      sub2.cancel();
    });
  });
}
