/// VAZHI Local Inference Service
///
/// Handles local GGUF model inference using llamadart.
library;

import 'dart:async';
import 'dart:io';
import 'package:llamadart/llamadart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// Service for running VAZHI model locally on device
class VazhiLocalService {
  LlamaEngine? _engine;
  ChatSession? _session;
  bool _isModelLoaded = false;

  /// Model download URL from HuggingFace
  /// Gemma 3 1B-it SFT v7.1, Q4_K_M quantization (~806MB)
  static const String modelUrl =
      'https://huggingface.co/CryptoYogi/vazhi-v7_1-Q4_K_M-GGUF/resolve/main/vazhi-v7_1-q4_k_m.gguf';

  /// Model filename
  static const String modelFilename = 'vazhi-v7_1-q4_k_m.gguf';

  /// Expected model size in bytes (~806MB)
  static const int expectedModelSize = 806000000;

  /// System prompts for each pack
  static const Map<String, String> packSystemPrompts = {
    'culture': '''நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர்.
தமிழ் கலாச்சாரம், திருக்குறள், சித்தர்கள், கோவில்கள் பற்றி உதவுங்கள்.
தமிழில் தெளிவாகவும் உதவியாகவும் பதிலளியுங்கள்.''',
    'education': '''நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர்.
கல்வி, உதவித்தொகை, தேர்வுகள் பற்றி உதவுங்கள்.
தமிழில் தெளிவாகவும் உதவியாகவும் பதிலளியுங்கள்.''',
    'security': '''நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர்.
இணைய பாதுகாப்பு, மோசடி தடுப்பு பற்றி உதவுங்கள்.
தமிழில் தெளிவாகவும் உதவியாகவும் பதிலளியுங்கள்.''',
    'legal': '''நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர்.
சட்ட உரிமைகள், RTI, நுகர்வோர் பாதுகாப்பு பற்றி உதவுங்கள்.
தமிழில் தெளிவாகவும் உதவியாகவும் பதிலளியுங்கள்.''',
    'govt': '''நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர்.
அரசு திட்டங்கள், சேவைகள் பற்றி உதவுங்கள்.
தமிழில் தெளிவாகவும் உதவியாகவும் பதிலளியுங்கள்.''',
    'health': '''நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர்.
சுகாதாரம், சித்த மருத்துவம், அரசு மருத்துவ திட்டங்கள் பற்றி உதவுங்கள்.
தமிழில் தெளிவாகவும் உதவியாகவும் பதிலளியுங்கள்.''',
  };

  /// Generation params with stop sequences to prevent hallucinated multi-turn chat.
  /// NOTE: Do NOT include `<start_of_turn>` or `<end_of_turn>` here — those are
  /// Gemma 3's native EOG tokens (token 106) and llama.cpp handles them
  /// automatically. Adding them as explicit text-based stop sequences conflicts
  /// with native EOG detection and causes empty responses.
  static const _generationParams = GenerationParams(
    maxTokens: 1024,
    temp: 0.7,
    stopSequences: ['<|im_start|>', '<|im_end|>', '\nuser\n', '\nUser:'],
  );

  /// Regex to strip any leaked chat format tokens from output
  /// Only strip the token markers themselves (with optional role label),
  /// NOT everything after them — greedy .* with dotAll was wiping responses.
  static final _chatTokenPattern = RegExp(
    r'<\|im_start\|>(system|user|assistant)?\n?'
    r'|<\|im_end\|>'
    r'|<start_of_turn>(user|model)?\n?'
    r'|<end_of_turn>',
  );

  /// Clean model output by stripping leaked chat tokens
  static String _cleanOutput(String text) {
    return text.replaceAll(_chatTokenPattern, '').trim();
  }

  /// Check if model is loaded and ready
  bool get isReady => _isModelLoaded;

  /// Get the local model file path
  Future<String> get modelPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$modelFilename';
  }

  /// Check if model file exists locally
  Future<bool> isModelDownloaded() async {
    final path = await modelPath;
    final file = File(path);
    if (await file.exists()) {
      final size = await file.length();
      // Check if file size is reasonable (at least 500MB for Q4_K_M GGUF)
      return size > 500000000;
    }
    return false;
  }

  /// Download the model with progress callback
  Future<void> downloadModel({Function(double progress)? onProgress}) async {
    final path = await modelPath;
    final file = File(path);

    // Create parent directory if needed
    await file.parent.create(recursive: true);

    final client = http.Client();
    try {
      // First, resolve any redirects to get the final URL
      var url = Uri.parse(modelUrl);
      http.StreamedResponse response;

      // Follow redirects manually (up to 5 redirects)
      for (var i = 0; i < 5; i++) {
        final request = http.Request('GET', url);
        response = await client.send(request);

        if (response.statusCode == 301 ||
            response.statusCode == 302 ||
            response.statusCode == 303 ||
            response.statusCode == 307) {
          final location = response.headers['location'];
          if (location == null) {
            throw VazhiLocalException('Redirect without location header');
          }
          // Handle relative and absolute URLs
          url = Uri.parse(location);
          if (!url.hasScheme) {
            url = Uri.parse(modelUrl).resolve(location);
          }
          // Drain the response body before following redirect
          await response.stream.drain();
          continue;
        }

        if (response.statusCode != 200) {
          throw VazhiLocalException(
            'மாடல் பதிவிறக்கம் தோல்வி: ${response.statusCode}',
          );
        }

        // Success - download the file
        final totalBytes = response.contentLength ?? expectedModelSize;
        var receivedBytes = 0;

        final sink = file.openWrite();
        await for (final chunk in response.stream) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          onProgress?.call(receivedBytes / totalBytes);
        }
        await sink.close();
        return;
      }

      throw VazhiLocalException('Too many redirects');
    } finally {
      client.close();
    }
  }

  /// Initialize the engine and load the model
  Future<void> initialize() async {
    if (_isModelLoaded) return;

    final path = await modelPath;
    if (!await isModelDownloaded()) {
      throw VazhiLocalException(
        'மாடல் கோப்பு இல்லை. முதலில் பதிவிறக்கம் செய்யுங்கள்.',
      );
    }

    _engine = LlamaEngine(LlamaBackend());
    try {
      await _engine!.setLogLevel(LlamaLogLevel.info);
      await _engine!.loadModel(
        path,
        modelParams: const ModelParams(
          gpuLayers: 0, // CPU-only — avoids Vulkan issues on phones
          contextSize: 2048,
        ),
      );
    } catch (e) {
      _engine = null;
      throw VazhiLocalException('Model load failed: $e');
    }
    _isModelLoaded = true;
  }

  /// Ensure a session exists. Reuses the current session to preserve
  /// conversation history (critical for multi-turn RAG). Only creates
  /// a new session on first use or after explicit `clearSession()`.
  void _ensureSession(String pack) {
    if (_session == null) {
      final systemPrompt =
          packSystemPrompts[pack] ?? packSystemPrompts['culture']!;
      _session = ChatSession(_engine!, systemPrompt: systemPrompt);
    }
  }

  /// Send a chat message and get a response
  Future<String> chat(String message, {String pack = 'culture'}) async {
    if (!_isModelLoaded || _engine == null) {
      throw VazhiLocalException('மாடல் ஏற்றப்படவில்லை');
    }

    _ensureSession(pack);

    final buffer = StringBuffer();
    await for (final chunk in _session!.create([
      LlamaTextContent(message),
    ], params: _generationParams)) {
      final content = chunk.choices.first.delta.content;
      if (content != null) {
        buffer.write(content);
      }
    }

    return _cleanOutput(buffer.toString());
  }

  /// Stream chat response token by token
  Stream<String> chatStream(String message, {String pack = 'culture'}) async* {
    if (!_isModelLoaded || _engine == null) {
      throw VazhiLocalException('மாடல் ஏற்றப்படவில்லை');
    }

    _ensureSession(pack);

    await for (final chunk in _session!.create([
      LlamaTextContent(message),
    ], params: _generationParams)) {
      final content = chunk.choices.first.delta.content;
      if (content != null && content.isNotEmpty) {
        // Strip any partial chat tokens from streamed chunks
        final cleaned = _cleanOutput(content);
        if (cleaned.isNotEmpty) {
          yield cleaned;
        }
      }
    }
  }

  /// Stream chat response with metrics tracking
  Stream<(String token, InferenceMetrics metrics)> chatStreamWithMetrics(
    String message, {
    String pack = 'culture',
  }) async* {
    if (!_isModelLoaded || _engine == null) {
      throw VazhiLocalException('மாடல் ஏற்றப்படவில்லை');
    }

    _ensureSession(pack);

    final metrics = InferenceMetrics()..startInference();

    await for (final chunk in _session!.create([
      LlamaTextContent(message),
    ], params: _generationParams)) {
      final content = chunk.choices.first.delta.content;
      if (content != null && content.isNotEmpty) {
        metrics.onToken();
        yield (content, metrics);
      }
    }

    metrics.endInference();
    _lastMetrics = metrics;
  }

  /// Last recorded inference metrics
  InferenceMetrics? _lastMetrics;

  /// Get the last recorded inference metrics
  InferenceMetrics? get lastMetrics => _lastMetrics;

  /// Send a chat message with metrics and get response + metrics
  Future<(String response, InferenceMetrics metrics)> chatWithMetrics(
    String message, {
    String pack = 'culture',
  }) async {
    if (!_isModelLoaded || _engine == null) {
      throw VazhiLocalException('மாடல் ஏற்றப்படவில்லை');
    }

    _ensureSession(pack);

    final metrics = InferenceMetrics()..startInference();
    final buffer = StringBuffer();

    await for (final chunk in _session!.create([
      LlamaTextContent(message),
    ], params: _generationParams)) {
      final content = chunk.choices.first.delta.content;
      if (content != null && content.isNotEmpty) {
        metrics.onToken();
        buffer.write(content);
      }
    }

    metrics.endInference();
    _lastMetrics = metrics;

    return (_cleanOutput(buffer.toString()), metrics);
  }

  /// Clear the chat session (start fresh conversation)
  void clearSession() {
    _session = null;
  }

  /// Dispose of resources
  Future<void> dispose() async {
    _session = null;
    await _engine?.dispose();
    _engine = null;
    _isModelLoaded = false;
  }

  /// Delete the downloaded model file
  Future<void> deleteModel() async {
    await dispose();
    final path = await modelPath;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

/// Custom exception for VAZHI local inference errors
class VazhiLocalException implements Exception {
  final String message;

  VazhiLocalException(this.message);

  @override
  String toString() => message;
}

/// Metrics collected during inference
class InferenceMetrics {
  final Stopwatch _stopwatch = Stopwatch();
  int _tokenCount = 0;
  int _firstTokenMs = 0;
  bool _firstTokenRecorded = false;

  /// Start tracking inference
  void startInference() {
    _stopwatch.reset();
    _stopwatch.start();
    _tokenCount = 0;
    _firstTokenMs = 0;
    _firstTokenRecorded = false;
  }

  /// Record first token arrival
  void onFirstToken() {
    if (!_firstTokenRecorded) {
      _firstTokenMs = _stopwatch.elapsedMilliseconds;
      _firstTokenRecorded = true;
    }
  }

  /// Record a token
  void onToken() {
    _tokenCount++;
    if (!_firstTokenRecorded) {
      onFirstToken();
    }
  }

  /// End tracking inference
  void endInference() {
    _stopwatch.stop();
  }

  /// Total inference time in milliseconds
  int get totalMs => _stopwatch.elapsedMilliseconds;

  /// Time to first token in milliseconds
  int get firstTokenMs => _firstTokenMs;

  /// Number of tokens generated
  int get tokenCount => _tokenCount;

  /// Tokens per second throughput
  double get tokensPerSecond {
    if (totalMs == 0) return 0;
    return _tokenCount / (totalMs / 1000);
  }

  /// Convert to JSON-serializable map
  Map<String, dynamic> toJson() => {
    'total_ms': totalMs,
    'first_token_ms': _firstTokenMs,
    'token_count': _tokenCount,
    'tokens_per_second': tokensPerSecond.toStringAsFixed(2),
    'timestamp': DateTime.now().toIso8601String(),
  };

  @override
  String toString() =>
      'InferenceMetrics(total: ${totalMs}ms, firstToken: ${_firstTokenMs}ms, '
      'tokens: $_tokenCount, tps: ${tokensPerSecond.toStringAsFixed(1)})';
}

/// Callback for streaming responses with metrics
typedef StreamCallback = void Function(String token, InferenceMetrics metrics);
