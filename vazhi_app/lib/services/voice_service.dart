/// Voice Service
///
/// Handles speech-to-text and text-to-speech functionality.
library;


import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../config/app_config.dart';

/// Speech-to-Text Service
class VoiceInputService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  /// Initialize the speech recognizer
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint('STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
        onError: (error) {
          debugPrint('STT Error: $error');
          _isListening = false;
        },
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('STT Init Error: $e');
      return false;
    }
  }

  /// Start listening for speech
  ///
  /// [onResult] - Called with recognized text (partial and final)
  /// [onDone] - Called when listening completes
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    required VoidCallback onDone,
  }) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) {
        throw VoiceException('Speech recognition not available');
      }
    }

    if (_isListening) return;

    _isListening = true;

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
        if (result.finalResult) {
          _isListening = false;
          onDone();
        }
      },
      localeId: AppConfig.tamilLocale,
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  /// Cancel listening
  Future<void> cancel() async {
    await _speech.cancel();
    _isListening = false;
  }

  /// Get available locales
  Future<List<LocaleName>> getLocales() async {
    if (!_isInitialized) await initialize();
    return await _speech.locales();
  }
}

/// Text-to-Speech Service
class VoiceOutputService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  double _speed = AppConfig.defaultTtsSpeed;

  bool get isSpeaking => _isSpeaking;
  double get speed => _speed;

  /// Initialize TTS
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      await _tts.setLanguage(AppConfig.tamilLocale);
      await _tts.setSpeechRate(_speed);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _isSpeaking = true;
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _tts.setErrorHandler((error) {
        debugPrint('TTS Error: $error');
        _isSpeaking = false;
      });

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('TTS Init Error: $e');
      return false;
    }
  }

  /// Speak text aloud
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isSpeaking) {
      await stop();
    }

    _isSpeaking = true;
    await _tts.speak(text);
  }

  /// Stop speaking
  Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }

  /// Set speech speed (0.0 to 1.0)
  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(0.0, 1.0);
    await _tts.setSpeechRate(_speed);
  }

  /// Get available voices
  Future<List<dynamic>> getVoices() async {
    return await _tts.getVoices;
  }

  /// Check if a Tamil voice is available
  Future<bool> hasTamilVoice() async {
    final voices = await getVoices();
    return voices.any((v) =>
        v['locale'].toString().toLowerCase().contains('ta') ||
        v['name'].toString().toLowerCase().contains('tamil'));
  }
}

/// Custom exception for voice errors
class VoiceException implements Exception {
  final String message;

  VoiceException(this.message);

  @override
  String toString() => message;
}
