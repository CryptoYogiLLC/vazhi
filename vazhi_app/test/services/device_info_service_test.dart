/// Device Info Service Tests

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vazhi_app/services/device_info_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceMemoryInfo', () {
    test('unknown factory returns zeros', () {
      const info = DeviceMemoryInfo.unknown();
      expect(info.totalRamMB, 0);
      expect(info.availableRamMB, 0);
      expect(info.lowMemory, isFalse);
      expect(info.thresholdMB, 0);
      expect(info.isUnknown, isTrue);
    });

    test('normal info is not unknown', () {
      const info = DeviceMemoryInfo(
        totalRamMB: 3700,
        availableRamMB: 1200,
        lowMemory: false,
        thresholdMB: 150,
      );
      expect(info.isUnknown, isFalse);
    });

    test('low memory flag is preserved', () {
      const info = DeviceMemoryInfo(
        totalRamMB: 3700,
        availableRamMB: 100,
        lowMemory: true,
        thresholdMB: 150,
      );
      expect(info.lowMemory, isTrue);
    });
  });

  group('DeviceInfoService', () {
    const channel = MethodChannel('com.cryptoyogillc.vazhi/device_info');

    test('channel name matches Dart constant', () {
      const service = DeviceInfoService();
      expect(service, isNotNull);
    });

    test('returns parsed DeviceMemoryInfo on success', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'getMemoryInfo') {
              return {
                'totalRam': 3700,
                'availableRam': 1200,
                'lowMemory': false,
                'threshold': 150,
              };
            }
            return null;
          });

      const service = DeviceInfoService();
      final info = await service.getMemoryInfo();

      expect(info.totalRamMB, 3700);
      expect(info.availableRamMB, 1200);
      expect(info.lowMemory, isFalse);
      expect(info.thresholdMB, 150);
      expect(info.isUnknown, isFalse);

      // Clean up
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('returns unknown on null result', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            return null;
          });

      const service = DeviceInfoService();
      final info = await service.getMemoryInfo();
      expect(info.isUnknown, isTrue);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('returns unknown on PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            throw PlatformException(code: 'ERROR', message: 'test error');
          });

      const service = DeviceInfoService();
      final info = await service.getMemoryInfo();
      expect(info.isUnknown, isTrue);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
  });
}
