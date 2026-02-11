/// Voice Provider
///
/// Manages voice input/output state using Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/voice_service.dart';
import '../config/app_config.dart';

/// Voice input service provider
final voiceInputProvider = Provider<VoiceInputService>((ref) {
  return VoiceInputService();
});

/// Voice output service provider
final voiceOutputProvider = Provider<VoiceOutputService>((ref) {
  return VoiceOutputService();
});

/// Voice input state
class VoiceInputState {
  final bool isListening;
  final String recognizedText;
  final bool isAvailable;
  final String? error;

  const VoiceInputState({
    this.isListening = false,
    this.recognizedText = '',
    this.isAvailable = false,
    this.error,
  });

  VoiceInputState copyWith({
    bool? isListening,
    String? recognizedText,
    bool? isAvailable,
    String? error,
  }) {
    return VoiceInputState(
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText,
      isAvailable: isAvailable ?? this.isAvailable,
      error: error,
    );
  }
}

/// Voice input state notifier
class VoiceInputNotifier extends StateNotifier<VoiceInputState> {
  final VoiceInputService _service;

  VoiceInputNotifier(this._service) : super(const VoiceInputState());

  /// Initialize voice input
  Future<void> initialize() async {
    if (!AppConfig.enableVoiceInput) return;

    final available = await _service.initialize();
    state = state.copyWith(isAvailable: available);
  }

  /// Start listening
  Future<void> startListening() async {
    if (!state.isAvailable || state.isListening) return;

    state = state.copyWith(isListening: true, recognizedText: '', error: null);

    try {
      await _service.startListening(
        onResult: (text, isFinal) {
          state = state.copyWith(recognizedText: text);
        },
        onDone: () {
          state = state.copyWith(isListening: false);
        },
      );
    } on VoiceException catch (e) {
      state = state.copyWith(isListening: false, error: e.message);
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    await _service.stopListening();
    state = state.copyWith(isListening: false);
  }

  /// Cancel listening
  Future<void> cancel() async {
    await _service.cancel();
    state = state.copyWith(isListening: false, recognizedText: '');
  }

  /// Clear recognized text
  void clearText() {
    state = state.copyWith(recognizedText: '');
  }
}

/// Voice input state provider
final voiceInputStateProvider =
    StateNotifierProvider<VoiceInputNotifier, VoiceInputState>((ref) {
  final service = ref.watch(voiceInputProvider);
  return VoiceInputNotifier(service);
});

/// Voice output state
class VoiceOutputState {
  final bool isSpeaking;
  final double speed;
  final bool isAvailable;
  final bool isEnabled;

  const VoiceOutputState({
    this.isSpeaking = false,
    this.speed = AppConfig.defaultTtsSpeed,
    this.isAvailable = false,
    this.isEnabled = true,
  });

  VoiceOutputState copyWith({
    bool? isSpeaking,
    double? speed,
    bool? isAvailable,
    bool? isEnabled,
  }) {
    return VoiceOutputState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      speed: speed ?? this.speed,
      isAvailable: isAvailable ?? this.isAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// Voice output state notifier
class VoiceOutputNotifier extends StateNotifier<VoiceOutputState> {
  final VoiceOutputService _service;

  VoiceOutputNotifier(this._service) : super(const VoiceOutputState());

  /// Initialize voice output
  Future<void> initialize() async {
    if (!AppConfig.enableVoiceOutput) return;

    final available = await _service.initialize();
    state = state.copyWith(isAvailable: available);
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (!state.isAvailable) return;

    state = state.copyWith(isSpeaking: true);
    await _service.speak(text);
    state = state.copyWith(isSpeaking: false);
  }

  /// Stop speaking
  Future<void> stop() async {
    await _service.stop();
    state = state.copyWith(isSpeaking: false);
  }

  /// Set speech speed
  Future<void> setSpeed(double speed) async {
    await _service.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  /// Toggle voice output enabled
  void toggleEnabled() {
    state = state.copyWith(isEnabled: !state.isEnabled);
  }

  /// Set voice output enabled
  void setEnabled(bool enabled) {
    state = state.copyWith(isEnabled: enabled);
  }
}

/// Voice output state provider
final voiceOutputStateProvider =
    StateNotifierProvider<VoiceOutputNotifier, VoiceOutputState>((ref) {
  final service = ref.watch(voiceOutputProvider);
  return VoiceOutputNotifier(service);
});
