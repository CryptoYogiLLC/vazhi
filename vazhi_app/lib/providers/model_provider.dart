/// Model Provider
///
/// Riverpod providers for model variant selection.
/// Persists the user's choice to SharedPreferences.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/model_variant.dart';

const _prefsKey = 'selected_model_id';

/// All available model variants.
final availableModelsProvider = Provider<List<ModelVariant>>(
  (ref) => ModelRegistry.variants,
);

/// Notifier that loads/saves the selected model to SharedPreferences.
class SelectedModelNotifier extends StateNotifier<ModelVariant> {
  SelectedModelNotifier() : super(ModelRegistry.defaultVariant) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsKey);
    if (id != null) {
      state = ModelRegistry.findById(id);
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
      (ref) => SelectedModelNotifier(),
    );
