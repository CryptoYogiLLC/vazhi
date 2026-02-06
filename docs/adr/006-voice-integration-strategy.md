# ADR-006: Voice Integration Strategy (Input + Output)

## Status
Accepted

## Date
2026-02-05

---

## Context

Many VAZHI target users:
- May have limited literacy in written Tamil
- Prefer speaking over typing
- Are familiar with voice assistants (Google Assistant in Tamil)
- Use smartphones with voice capability but may not know how to use it

Voice support is essential for accessibility and adoption.

### Requirements
1. **Voice Input**: Recognize spoken Tamil and convert to text
2. **Voice Output**: Read responses aloud in Tamil
3. **Offline capable**: Work without internet (especially for Full variant)
4. **Low latency**: Responsive voice interactions

### Options Evaluated

| Component | Platform APIs | Third-party | Custom Model |
|-----------|---------------|-------------|--------------|
| STT (Speech-to-Text) | Native (free) | Google Cloud ($) | Whisper (heavy) |
| TTS (Text-to-Speech) | Native (free) | Google Cloud ($) | Custom (complex) |

## Decision

We will use **native platform APIs** for both speech-to-text and text-to-speech, accessed via Flutter plugins.

### Technical Implementation

#### Speech-to-Text (Input)

```dart
// lib/services/voice_input_service.dart
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  Future<bool> initialize() async {
    return await _speech.initialize(
      onStatus: (status) => print('STT Status: $status'),
      onError: (error) => print('STT Error: $error'),
    );
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function() onDone,
  }) async {
    if (!_speech.isAvailable) {
      throw Exception('Speech recognition not available');
    }

    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          onDone();
        }
      },
      localeId: 'ta-IN',  // Tamil (India)
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }
}
```

#### Text-to-Speech (Output)

```dart
// lib/services/voice_output_service.dart
import 'package:flutter_tts/flutter_tts.dart';

class VoiceOutputService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  Future<void> initialize() async {
    await _tts.setLanguage('ta-IN');  // Tamil (India)
    await _tts.setSpeechRate(0.5);     // Slightly slower for clarity
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // Get available Tamil voices
    final voices = await _tts.getVoices;
    final tamilVoice = voices.firstWhere(
      (v) => v['locale'].toString().startsWith('ta'),
      orElse: () => null,
    );
    if (tamilVoice != null) {
      await _tts.setVoice(tamilVoice);
    }
  }

  Future<void> speak(String text) async {
    if (_isSpeaking) await stop();
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }

  void setSpeed(double rate) {
    _tts.setSpeechRate(rate);  // 0.0 to 1.0
  }
}
```

### User Interface

```
┌─────────────────────────────────────┐
│  வழி - VAZHI                        │
├─────────────────────────────────────┤
│                                     │
│  👤 [Voice waveform animation]      │
│     "கேட்கிறேன்..."                  │
│     (Listening...)                  │
│                                     │
│         🤖 Response text here...    │
│            [🔊 Speaking...]         │
│                                     │
├─────────────────────────────────────┤
│  [🎤 Tap to speak]  [Type here] [➤] │
└─────────────────────────────────────┘
```

### Voice Flow

```
┌─────────┐     ┌─────────────┐     ┌─────────────┐
│ User    │────▶│ Mic Button  │────▶│ STT Active  │
│ Taps 🎤 │     │ Pressed     │     │ (Listening) │
└─────────┘     └─────────────┘     └──────┬──────┘
                                           │
                                           ▼
┌─────────┐     ┌─────────────┐     ┌─────────────┐
│ TTS     │◀────│ Response    │◀────│ Text shown  │
│ Speaks  │     │ Generated   │     │ in chat     │
└─────────┘     └─────────────┘     └─────────────┘
```

### Platform Capabilities

| Feature | iOS | Android | Notes |
|---------|-----|---------|-------|
| Tamil STT | ✅ iOS 13+ | ✅ Android 8+ | Offline on newer devices |
| Tamil TTS | ✅ Native voice | ✅ Native voice | Quality varies by device |
| Offline STT | ✅ iOS 15+ | ⚠️ Varies | Download language pack |
| Offline TTS | ✅ Built-in | ✅ Built-in | Always available |

## Consequences

### Positive
- **Zero cost** - Native APIs are free
- **Offline capable** - Works without internet on modern devices
- **Familiar UX** - Similar to Google Assistant / Siri
- **Low latency** - Native processing is fast
- **Easy integration** - Mature Flutter plugins available

### Negative
- **Quality varies** - Different devices have different voice quality
- **Offline STT limitations** - Older Android may need internet
- **Accent handling** - May struggle with regional Tamil accents
- **No customization** - Cannot train for VAZHI-specific terms

### Mitigations
- Test on range of devices during development
- Fallback to online STT if offline fails
- User settings for TTS speed adjustment
- Clear feedback when voice is not available

## User Settings

| Setting | Options | Default |
|---------|---------|---------|
| Voice output | On / Off | On |
| TTS speed | Slow / Normal / Fast | Normal |
| Auto-speak responses | On / Off | Off |
| Voice language | Tamil / English | Tamil |

## Accessibility Considerations

1. **Visual feedback** - Show waveform/animation during listening
2. **Haptic feedback** - Vibrate on voice activation
3. **Clear states** - Obvious when listening vs processing vs speaking
4. **Manual override** - Always allow typing as alternative
5. **Stop button** - Easy way to interrupt TTS

## Future Enhancements

1. **Wake word** - "Hey VAZHI" activation (Phase 2+)
2. **Continuous conversation** - Multi-turn voice chat
3. **Whisper integration** - Better accuracy for complex queries
4. **Voice personalization** - Remember user's speech patterns

## Related
- [ADR-002: Flutter Framework Selection](002-flutter-framework-selection.md)
- [VAZHI Mobile Architecture](../architecture/VAZHI_MOBILE_ARCHITECTURE.md)
