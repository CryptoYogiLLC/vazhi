/// Model Provider
///
/// Riverpod providers for model variant selection with device-aware filtering.
/// Persists the user's choice to SharedPreferences and auto-migrates
/// removed variant IDs from older app versions.
library;

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
class SelectedModelNotifier extends StateNotifier<ModelVariant> {
  final Ref _ref;

  SelectedModelNotifier(this._ref) : super(ModelRegistry.defaultVariant) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsKey);

    // Get device RAM for migration decisions
    final memInfo = await _ref.read(deviceInfoServiceProvider).getMemoryInfo();
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
        final fallback = ModelRegistry.variants.where((v) => v.isTrimmed).last;
        state = fallback;
        await prefs.setString(_prefsKey, fallback.id);
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
