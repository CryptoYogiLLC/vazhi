/// Chat Provider
///
/// Manages chat state using Riverpod.
/// Supports both local GGUF inference and cloud API.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../services/vazhi_api_service.dart';
import '../services/vazhi_local_service.dart';

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

/// Local service provider (singleton)
final vazhiLocalServiceProvider = Provider<VazhiLocalService>((ref) {
  final service = VazhiLocalService();
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

/// Model status provider
final modelStatusProvider = StateProvider<ModelStatus>(
  (ref) => ModelStatus.notDownloaded,
);

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

/// Model manager notifier for download and initialization
class ModelManagerNotifier extends StateNotifier<ModelStatus> {
  final VazhiLocalService _localService;
  final Ref _ref;

  ModelManagerNotifier(this._localService, this._ref)
    : super(ModelStatus.notDownloaded) {
    _checkModelStatus();
  }

  Future<void> _checkModelStatus() async {
    if (await _localService.isModelDownloaded()) {
      state = ModelStatus.downloaded;
    } else {
      state = ModelStatus.notDownloaded;
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
      rethrow;
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

    state = ModelStatus.loading;
    try {
      await _localService.initialize();
      state = ModelStatus.ready;
      // Automatically switch to local mode when model is ready
      _ref.read(inferenceModeProvider.notifier).state = InferenceMode.local;
    } catch (e) {
      state = ModelStatus.error;
      rethrow;
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

  /// Check model status
  Future<void> checkStatus() async {
    await _checkModelStatus();
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
