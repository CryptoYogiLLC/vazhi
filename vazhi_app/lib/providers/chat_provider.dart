/// Chat Provider
///
/// Manages chat state using Riverpod.
/// Supports both local GGUF inference and cloud API.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../services/vazhi_api_service.dart';
import '../services/vazhi_local_service.dart';
import 'model_provider.dart';

/// Inference mode enum
enum InferenceMode {
  local, // On-device GGUF model
  cloud, // HuggingFace Space API
}

/// Current inference mode provider
final inferenceModeProvider = StateProvider<InferenceMode>(
  (ref) => InferenceMode.local,
);

/// API service provider
final vazhiApiServiceProvider = Provider<VazhiApiService>((ref) {
  return VazhiApiService();
});

/// Local service provider — rebuilds when the selected model changes.
final vazhiLocalServiceProvider = Provider<VazhiLocalService>((ref) {
  final model = ref.watch(selectedModelProvider);
  final service = VazhiLocalService(model);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Model download status
enum ModelStatus {
  notDownloaded,
  downloading,
  downloaded,
  loading,
  ready,
  error,
}

/// Download progress provider (0.0 to 1.0)
final downloadProgressProvider = StateProvider<double>((ref) => 0.0);

/// Current knowledge pack provider (default to culture)
final currentPackProvider = StateProvider<String>((ref) => 'culture');

/// Chat state notifier
class ChatNotifier extends StateNotifier<List<Message>> {
  final VazhiApiService _apiService;
  final VazhiLocalService _localService;
  final Ref _ref;

  ChatNotifier(this._apiService, this._localService, this._ref) : super([]);

  /// Send a message and get a response
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = Message.user(text);
    state = [...state, userMessage];

    // Add loading placeholder
    final loadingMessage = Message.loading();
    state = [...state, loadingMessage];

    try {
      // Get current pack and mode
      final pack = _ref.read(currentPackProvider);
      final mode = _ref.read(inferenceModeProvider);

      String response;
      if (mode == InferenceMode.local) {
        // Local inference
        if (!_localService.isReady) {
          throw VazhiLocalException(
            'மாடல் ஏற்றப்படவில்லை. முதலில் மாடலை பதிவிறக்கவும்.',
          );
        }

        // Pre-inference RAM check
        final ramError = await _checkRamBeforeInference();
        if (ramError != null) {
          throw VazhiLocalException(ramError);
        }

        response = await _localService.chat(text, pack: pack);
      } else {
        // Cloud API
        response = await _apiService.chat(text, pack: pack);
      }

      // Replace loading with actual response
      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        Message.assistant(response, pack: pack),
      ];
    } on VazhiApiException catch (e) {
      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        Message.error(e.message),
      ];
    } on VazhiLocalException catch (e) {
      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        Message.error(e.message),
      ];
    } catch (e) {
      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        Message.error('எதிர்பாராத பிழை: $e'),
      ];
    }
  }

  /// Check device RAM before inference. Returns error message if blocked, null if OK.
  /// Uses headroom above system threshold (availMem - threshold) instead of
  /// raw availMem, which adapts across devices with different lmkd thresholds.
  Future<String?> _checkRamBeforeInference() async {
    final deviceInfoService = _ref.read(deviceInfoServiceProvider);
    final memInfo = await deviceInfoService.getMemoryInfo();
    if (memInfo.isUnknown) return null; // Can't check — proceed

    // Block on OS low-memory signal (Android's own "we're in trouble" flag)
    if (memInfo.lowMemory) {
      return 'உங்கள் சாதனத்தில் நினைவகம் குறைவாக உள்ளது. '
          'சில ஆப்களை மூடிவிட்டு மீண்டும் முயற்சிக்கவும்.';
    }

    final model = _ref.read(selectedModelProvider);

    // Headroom = available RAM above the system's kill threshold.
    // This is the actual usable memory before lmkd starts killing processes.
    final headroom = memInfo.availableRamMB - memInfo.thresholdMB;

    if (headroom < model.minFreeRamMB) {
      return 'உங்கள் சாதனத்தில் நினைவகம் குறைவாக உள்ளது. '
          'சில ஆப்களை மூடிவிட்டு மீண்டும் முயற்சிக்கவும்.';
    }

    // Tight but not critical — set warning flag
    if (headroom < model.minFreeRamMB * 2) {
      _ref.read(ramWarningProvider.notifier).state = true;
    }

    return null;
  }

  /// Clear chat history
  void clearChat() {
    state = [];
    // Also clear local session if using local mode
    final mode = _ref.read(inferenceModeProvider);
    if (mode == InferenceMode.local) {
      _localService.clearSession();
    }
  }

  /// Retry last failed message
  Future<void> retryLast() async {
    if (state.isEmpty) return;

    final lastError = state.lastWhere(
      (m) => m.error != null,
      orElse: () => Message.user(''),
    );

    if (lastError.error == null) return;

    final errorIndex = state.indexOf(lastError);
    if (errorIndex <= 0) return;

    final userMessage = state[errorIndex - 1];
    if (userMessage.role != MessageRole.user) return;

    state = state.where((m) => m.id != lastError.id).toList();
    await sendMessage(userMessage.content);
  }
}

/// Chat provider
final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) {
  final apiService = ref.watch(vazhiApiServiceProvider);
  final localService = ref.watch(vazhiLocalServiceProvider);
  return ChatNotifier(apiService, localService, ref);
});

/// Last crash diagnostic info (readable from UI)
final lastCrashDiagnosticProvider = StateProvider<String?>((ref) => null);

/// RAM warning flag — set when available RAM is tight but not critical.
final ramWarningProvider = StateProvider<bool>((ref) => false);

/// Model manager notifier for download and initialization
class ModelManagerNotifier extends StateNotifier<ModelStatus> {
  final VazhiLocalService _localService;
  final Ref _ref;

  ModelManagerNotifier(this._localService, this._ref)
    : super(ModelStatus.notDownloaded) {
    _checkModelStatus();
  }

  Future<void> _checkModelStatus({bool forceRetry = false}) async {
    // Wait for model selection + migration to finalize before autoloading.
    // Prevents startup race where the wrong (pre-migration) model is loaded.
    try {
      await _ref.read(modelSelectionReadyProvider.future);
    } catch (_) {
      // Selection failed — proceed with whatever model state exists
    }

    try {
      if (forceRetry) {
        // Retry: clear diagnostic file so we attempt a fresh load
        await _localService.clearDiagnostic();
        _ref.read(lastCrashDiagnosticProvider.notifier).state = null;
      } else {
        // Startup: check for crash diagnostic from previous session
        final diagnostic = await _localService.readLastDiagnostic();
        if (diagnostic != null) {
          _ref.read(lastCrashDiagnosticProvider.notifier).state = diagnostic;
          // Previous load crashed — don't auto-load, show error with diagnostic
          if (await _localService.isModelDownloaded()) {
            state = ModelStatus.error;
            return;
          }
        }
      }

      if (await _localService.isModelDownloaded()) {
        state = ModelStatus.downloaded;
        // Load the model (auto on startup, explicit on retry)
        await loadModel();
      } else {
        state = ModelStatus.notDownloaded;
      }
    } catch (_) {
      // Covers both isModelDownloaded() (filesystem errors) and loadModel()
      // failures. Always set error state so the UI reflects the actual status.
      state = ModelStatus.error;
    }
  }

  /// Download the model (uses legacy service for backward compatibility)
  Future<void> downloadModel() async {
    if (state == ModelStatus.downloading) return;

    state = ModelStatus.downloading;
    _ref.read(downloadProgressProvider.notifier).state = 0.0;

    try {
      await _localService.downloadModel(
        onProgress: (progress) {
          _ref.read(downloadProgressProvider.notifier).state = progress;
        },
      );
      state = ModelStatus.downloaded;
    } catch (e) {
      state = ModelStatus.error;
    }
  }

  /// Set download status (called by DownloadDialog)
  void setDownloading(double progress) {
    state = ModelStatus.downloading;
    _ref.read(downloadProgressProvider.notifier).state = progress;
  }

  /// Set downloaded status
  void setDownloaded() {
    state = ModelStatus.downloaded;
    _ref.read(downloadProgressProvider.notifier).state = 1.0;
  }

  /// Set error status
  void setError() {
    state = ModelStatus.error;
  }

  /// Initialize/load the model
  Future<void> loadModel() async {
    if (state == ModelStatus.loading || state == ModelStatus.ready) return;

    // Pre-load RAM check using headroom above system kill threshold.
    try {
      final deviceInfoService = _ref.read(deviceInfoServiceProvider);
      final memInfo = await deviceInfoService.getMemoryInfo();
      if (!memInfo.isUnknown) {
        final model = _ref.read(selectedModelProvider);
        final headroom = memInfo.availableRamMB - memInfo.thresholdMB;
        if (memInfo.lowMemory || headroom < model.minFreeRamMB) {
          _ref.read(lastCrashDiagnosticProvider.notifier).state =
              'உங்கள் சாதனத்தில் நினைவகம் குறைவாக உள்ளது. '
              'சில ஆப்களை மூடிவிட்டு மீண்டும் முயற்சிக்கவும்.';
          state = ModelStatus.error;
          return;
        }
      }
    } catch (_) {
      // RAM check failed — proceed with load attempt
    }

    state = ModelStatus.loading;
    try {
      await _localService.initialize();
      state = ModelStatus.ready;
      // Automatically switch to local mode when model is ready
      _ref.read(inferenceModeProvider.notifier).state = InferenceMode.local;
    } catch (e) {
      // Store the error in the diagnostic provider for UI display
      final diagnostic = await _localService.readLastDiagnostic();
      _ref.read(lastCrashDiagnosticProvider.notifier).state =
          diagnostic ?? e.toString();
      state = ModelStatus.error;
      // Don't rethrow — state is set, callers check modelManagerProvider.
      // Rethrowing from fire-and-forget _checkModelStatus causes unhandled
      // async exceptions that crash the app (especially on Android).
    }
  }

  /// Delete the model
  Future<void> deleteModel() async {
    await _localService.deleteModel();
    state = ModelStatus.notDownloaded;
    _ref.read(downloadProgressProvider.notifier).state = 0.0;
    // Switch back to cloud mode when model is deleted
    _ref.read(inferenceModeProvider.notifier).state = InferenceMode.cloud;
  }

  /// Check model status. Set [forceRetry] to clear old diagnostic and
  /// attempt a fresh load (used by the Retry button).
  Future<void> checkStatus({bool forceRetry = false}) async {
    await _checkModelStatus(forceRetry: forceRetry);
  }
}

/// Model manager provider
final modelManagerProvider =
    StateNotifierProvider<ModelManagerNotifier, ModelStatus>((ref) {
      final localService = ref.watch(vazhiLocalServiceProvider);
      return ModelManagerNotifier(localService, ref);
    });

/// Available knowledge packs
final availablePacksProvider = Provider<List<PackInfo>>((ref) {
  return [
    PackInfo(
      id: 'culture',
      name: 'Culture',
      nameTamil: 'கலாச்சாரம்',
      description: 'தமிழ் கலாச்சாரம், திருக்குறள், சித்தர்கள், கோவில்கள்',
      icon: '🪷',
    ),
    PackInfo(
      id: 'education',
      name: 'Education',
      nameTamil: 'கல்வி',
      description: 'கல்வி, உதவித்தொகை, தேர்வுகள்',
      icon: '📚',
    ),
    PackInfo(
      id: 'security',
      name: 'Security',
      nameTamil: 'பாதுகாப்பு',
      description: 'இணைய பாதுகாப்பு, மோசடி தடுப்பு',
      icon: '🛡️',
    ),
    PackInfo(
      id: 'legal',
      name: 'Legal',
      nameTamil: 'சட்டம்',
      description: 'சட்ட உரிமைகள், RTI, நுகர்வோர் பாதுகாப்பு',
      icon: '⚖️',
    ),
    PackInfo(
      id: 'govt',
      name: 'Government',
      nameTamil: 'அரசு',
      description: 'அரசு திட்டங்கள், சேவைகள்',
      icon: '🏛️',
    ),
    PackInfo(
      id: 'health',
      name: 'Healthcare',
      nameTamil: 'சுகாதாரம்',
      description: 'சுகாதாரம், சித்த மருத்துவம், அரசு மருத்துவ திட்டங்கள்',
      icon: '🧘',
    ),
  ];
});

/// Pack information model
class PackInfo {
  final String id;
  final String name;
  final String nameTamil;
  final String description;
  final String icon;

  PackInfo({
    required this.id,
    required this.name,
    required this.nameTamil,
    required this.description,
    required this.icon,
  });
}
