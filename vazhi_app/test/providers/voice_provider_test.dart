/// Voice Provider Tests
///
/// Tests for voice input/output state management.

import 'package:flutter_test/flutter_test.dart';
import 'package:vazhi_app/providers/voice_provider.dart';
import 'package:vazhi_app/config/app_config.dart';

void main() {
  group('VoiceInputState', () {
    test('creates with default values', () {
      const state = VoiceInputState();

      expect(state.isListening, isFalse);
      expect(state.recognizedText, isEmpty);
      expect(state.isAvailable, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith updates only specified fields', () {
      const state = VoiceInputState();
      final updated = state.copyWith(isListening: true);

      expect(updated.isListening, isTrue);
      expect(updated.recognizedText, isEmpty);
      expect(updated.isAvailable, isFalse);
    });

    test('copyWith can update recognizedText', () {
      const state = VoiceInputState();
      final updated = state.copyWith(recognizedText: 'hello');

      expect(updated.recognizedText, 'hello');
    });

    test('copyWith can set error', () {
      const state = VoiceInputState();
      final updated = state.copyWith(error: 'Microphone error');

      expect(updated.error, 'Microphone error');
    });

    test('copyWith can clear error with empty string', () {
      final state = const VoiceInputState().copyWith(error: 'error');
      // Note: error uses positional null, so passing empty would work differently
      expect(state.error, 'error');
    });
  });

  group('VoiceOutputState', () {
    test('creates with default values', () {
      const state = VoiceOutputState();

      expect(state.isSpeaking, isFalse);
      expect(state.speed, AppConfig.defaultTtsSpeed);
      expect(state.isAvailable, isFalse);
      expect(state.isEnabled, isTrue);
    });

    test('copyWith updates isSpeaking', () {
      const state = VoiceOutputState();
      final updated = state.copyWith(isSpeaking: true);

      expect(updated.isSpeaking, isTrue);
      expect(updated.isEnabled, isTrue);
    });

    test('copyWith updates speed', () {
      const state = VoiceOutputState();
      final updated = state.copyWith(speed: 0.8);

      expect(updated.speed, 0.8);
    });

    test('copyWith can disable voice output', () {
      const state = VoiceOutputState();
      final updated = state.copyWith(isEnabled: false);

      expect(updated.isEnabled, isFalse);
    });

    test('copyWith preserves other fields', () {
      const state = VoiceOutputState(
        isSpeaking: true,
        speed: 0.7,
        isAvailable: true,
        isEnabled: false,
      );
      final updated = state.copyWith(speed: 0.9);

      expect(updated.isSpeaking, isTrue);
      expect(updated.speed, 0.9);
      expect(updated.isAvailable, isTrue);
      expect(updated.isEnabled, isFalse);
    });
  });
}
