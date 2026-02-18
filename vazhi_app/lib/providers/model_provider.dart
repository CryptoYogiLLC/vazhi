/// Model Provider
///
/// Riverpod providers for model variant selection with device-aware filtering.
/// Persists the user's choice to SharedPreferences and auto-migrates
/// removed variant IDs from older app versions.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/model_variant.dart';
import '../services/device_info_service.dart';

const _prefsKey = 'selected_model_id';

/// Device info service provider.
final deviceInfoServiceProvider = Provider<DeviceInfoService>(
  (ref) => const DeviceInfoService(),
);

/// Device memory info — queried once at startup.
final deviceMemoryInfoProvider = FutureProvider<DeviceMemoryInfo>((ref) async {
  final service = ref.read(deviceInfoServiceProvider);
  return service.getMemoryInfo();
});

/// Device tier derived from total RAM.
/// Defaults to compact (safe) when RAM is unknown.
final deviceTierProvider = Provider<DeviceTier>((ref) {
  final memInfo = ref.watch(deviceMemoryInfoProvider).valueOrNull;
  if (memInfo == null || memInfo.isUnknown) {
    return DeviceTier.compact;
  }
  return ModelRegistry.classifyDevice(memInfo.totalRamMB);
});

/// Models compatible with this device's RAM.
/// When RAM is unknown, shows only trimmed (smallest) models as a safe default.
final compatibleModelsProvider = Provider<List<ModelVariant>>((ref) {
  final memInfo = ref.watch(deviceMemoryInfoProvider).valueOrNull;
  if (memInfo == null || memInfo.isUnknown) {
    return ModelRegistry.variants.where((v) => v.isTrimmed).toList();
  }
  return ModelRegistry.filterForDevice(memInfo.totalRamMB);
});

/// Whether RAM detection has completed.
final ramDetectionCompleteProvider = Provider<bool>((ref) {
  return ref.watch(deviceMemoryInfoProvider).hasValue;
});

/// Whether RAM detection failed (unknown).
final ramUnknownProvider = Provider<bool>((ref) {
  final memInfo = ref.watch(deviceMemoryInfoProvider).valueOrNull;
  return memInfo != null && memInfo.isUnknown;
});

/// All available model variants (delegates to compatible models).
final availableModelsProvider = Provider<List<ModelVariant>>(
  (ref) => ref.watch(compatibleModelsProvider),
);

/// Notifier that loads/saves the selected model to SharedPreferences.
/// Auto-migrates removed variant IDs from older app versions.
///
/// Exposes [ready] to let downstream consumers (e.g. ModelManagerNotifier)
/// wait until model selection + migration is finalized before autoloading.
class SelectedModelNotifier extends StateNotifier<ModelVariant> {
  final Ref _ref;
  final Completer<void> _readyCompleter = Completer<void>();

  /// Completes when initial load + migration is done.
  /// Downstream consumers should await this before acting on [state].
  Future<void> get ready => _readyCompleter.future;

  SelectedModelNotifier(this._ref) : super(ModelRegistry.defaultVariant) {
    _load();
  }

  Future<void> _load() async {
    try {
      // Run SharedPreferences and RAM detection in parallel
      final results = await Future.wait([
        SharedPreferences.getInstance(),
        _ref.read(deviceMemoryInfoProvider.future),
      ]);
      final prefs = results[0] as SharedPreferences;
      final memInfo = results[1] as DeviceMemoryInfo;
      final id = prefs.getString(_prefsKey);
      final totalRamMB = memInfo.totalRamMB;

      if (id != null) {
        final variant = ModelRegistry.findById(id, totalRamMB: totalRamMB);
        // If the ID was migrated (different from what was stored), persist the new ID
        if (variant.id != id) {
          await prefs.setString(_prefsKey, variant.id);
        }
        state = variant;
      } else {
        // First launch: auto-select best model for device
        final recommended = totalRamMB > 0
            ? ModelRegistry.recommendedForDevice(totalRamMB)
            : null;
        if (recommended != null) {
          state = recommended;
          await prefs.setString(_prefsKey, recommended.id);
        } else {
          // sqliteOnly or unknown — use smallest trimmed variant
          final fallback = ModelRegistry.variants
              .where((v) => v.isTrimmed)
              .last;
          state = fallback;
          await prefs.setString(_prefsKey, fallback.id);
        }
      }
    } finally {
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
    }
  }

  Future<void> select(ModelVariant variant) async {
    state = variant;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, variant.id);
  }
}

/// The currently selected model variant.
final selectedModelProvider =
    StateNotifierProvider<SelectedModelNotifier, ModelVariant>(
      (ref) => SelectedModelNotifier(ref),
    );

/// Completes when model selection + migration is finalized.
/// ModelManagerNotifier awaits this before autoloading to prevent
/// the startup race where the wrong (pre-migration) model gets loaded.
final modelSelectionReadyProvider = FutureProvider<void>((ref) async {
  final notifier = ref.read(selectedModelProvider.notifier);
  await notifier.ready;
});
