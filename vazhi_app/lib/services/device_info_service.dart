/// Device Info Service
///
/// Queries device memory information and manages model file persistence
/// in Downloads/VAZHI/ via platform channels.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Device memory information from the OS.
class DeviceMemoryInfo {
  /// Total device RAM in MB
  final int totalRamMB;

  /// Currently available RAM in MB
  final int availableRamMB;

  /// Whether the OS reports low memory pressure (Android only)
  final bool lowMemory;

  /// System low-memory threshold in MB (Android only)
  final int thresholdMB;

  const DeviceMemoryInfo({
    required this.totalRamMB,
    required this.availableRamMB,
    required this.lowMemory,
    required this.thresholdMB,
  });

  /// Unknown/fallback when platform channel fails.
  /// Callers treat totalRamMB == 0 as "safe mode".
  const DeviceMemoryInfo.unknown()
    : totalRamMB = 0,
      availableRamMB = 0,
      lowMemory = false,
      thresholdMB = 0;

  bool get isUnknown => totalRamMB == 0;
}

/// Service to query device info and manage model file persistence.
class DeviceInfoService {
  static const _channel = MethodChannel('com.cryptoyogillc.vazhi/device_info');

  const DeviceInfoService();

  /// Query the OS for current memory information.
  /// Returns [DeviceMemoryInfo.unknown] on error.
  Future<DeviceMemoryInfo> getMemoryInfo() async {
    try {
      final result = await _channel.invokeMethod<Map>('getMemoryInfo');
      if (result == null) return const DeviceMemoryInfo.unknown();

      return DeviceMemoryInfo(
        totalRamMB: (result['totalRam'] as num?)?.toInt() ?? 0,
        availableRamMB: (result['availableRam'] as num?)?.toInt() ?? 0,
        lowMemory: (result['lowMemory'] as bool?) ?? false,
        thresholdMB: (result['threshold'] as num?)?.toInt() ?? 0,
      );
    } on MissingPluginException {
      return const DeviceMemoryInfo.unknown();
    } on PlatformException {
      return const DeviceMemoryInfo.unknown();
    }
  }

  /// Check if a model file exists in Downloads/VAZHI/ and return its path.
  /// Returns null if not found or on non-Android platforms.
  Future<String?> findModelInDownloads(String filename) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'findModelInDownloads',
        {'filename': filename},
      );
      return result;
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('VAZHI: findModelInDownloads failed: $e');
      return null;
    }
  }

  /// Copy a model file from sourcePath to Downloads/VAZHI/.
  /// Returns the real file path in Downloads.
  /// Throws on failure. Non-fatal — caller should catch.
  Future<String> saveModelToDownloads(
    String filename,
    String sourcePath,
  ) async {
    final result = await _channel.invokeMethod<String>('saveModelToDownloads', {
      'filename': filename,
      'sourcePath': sourcePath,
    });
    return result!;
  }

  /// Delete a model file from Downloads/VAZHI/.
  Future<bool> deleteModelFromDownloads(String filename) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'deleteModelFromDownloads',
        {'filename': filename},
      );
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
