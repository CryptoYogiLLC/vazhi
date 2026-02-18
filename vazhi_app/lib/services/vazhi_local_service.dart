/// VAZHI Local Inference Service
///
/// Handles local GGUF model inference using llamadart.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:llamadart/llamadart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/model_variant.dart';
import 'device_info_service.dart';

/// Service for running VAZHI model locally on device
class VazhiLocalService {
  final ModelVariant _model;

  LlamaEngine? _engine;
  ChatSession? _session;
  String? _currentPack;
  bool _isModelLoaded = false;

  static const _deviceInfoService = DeviceInfoService();

  VazhiLocalService(this._model);

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
    maxTokens: 256, // Reduced from 1024 to fit in 512-token context window
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

  /// Throw if model is not loaded. Guards all inference methods.
  void _assertReady() {
    if (!_isModelLoaded || _engine == null) {
      throw VazhiLocalException('மாடல் ஏற்றப்படவில்லை');
    }
  }

  /// Internal storage path (used as download staging area).
  Future<String> get _internalPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/${_model.filename}';
  }

  /// Get the model file path, checking Downloads/VAZHI/ first (persists
  /// across reinstalls), then falling back to internal app storage.
  Future<String> get modelPath async {
    // Check Downloads/VAZHI/ first — survives app reinstall
    final downloadsPath = await _deviceInfoService.findModelInDownloads(
      _model.filename,
    );
    if (downloadsPath != null) return downloadsPath;

    // Fallback: internal storage (will be lost on reinstall)
    return _internalPath;
  }

  /// Check if model file exists in Downloads or internal storage.
  Future<bool> isModelDownloaded() async {
    // Check Downloads/VAZHI/ first
    final downloadsPath = await _deviceInfoService.findModelInDownloads(
      _model.filename,
    );
    if (downloadsPath != null) {
      final file = File(downloadsPath);
      if (await file.exists()) {
        final size = await file.length();
        if (size > _model.minimumValidSizeBytes) return true;
      }
    }

    // Fallback: internal storage
    final internalFile = File(await _internalPath);
    if (await internalFile.exists()) {
      final size = await internalFile.length();
      return size > _model.minimumValidSizeBytes;
    }
    return false;
  }

  /// Download the model with progress callback.
  /// Downloads to internal storage first, then copies to Downloads/VAZHI/
  /// for persistence across app reinstalls.
  Future<void> downloadModel({Function(double progress)? onProgress}) async {
    final internalPath = await _internalPath;
    final file = File(internalPath);

    // Create parent directory if needed
    await file.parent.create(recursive: true);

    final client = http.Client();
    try {
      // First, resolve any redirects to get the final URL
      var url = Uri.parse(_model.url);
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
            url = Uri.parse(_model.url).resolve(location);
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

        // Success - download the file to internal storage
        final totalBytes = response.contentLength ?? _model.expectedSizeBytes;
        var receivedBytes = 0;

        final sink = file.openWrite();
        await for (final chunk in response.stream) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          onProgress?.call(receivedBytes / totalBytes);
        }
        await sink.close();

        // Copy to Downloads/VAZHI/ for persistence across reinstalls
        await _persistToDownloads(internalPath);

        return;
      }

      throw VazhiLocalException('Too many redirects');
    } finally {
      client.close();
    }
  }

  /// Copy the model from internal storage to Downloads/VAZHI/.
  /// Non-fatal — if this fails the model still works from internal storage.
  Future<void> _persistToDownloads(String sourcePath) async {
    try {
      final downloadsPath = await _deviceInfoService.saveModelToDownloads(
        _model.filename,
        sourcePath,
      );
      debugPrint('VAZHI: Model persisted to Downloads: $downloadsPath');

      // Delete internal copy — Downloads is now the primary location
      try {
        await File(sourcePath).delete();
        debugPrint('VAZHI: Internal staging copy deleted');
      } catch (_) {
        // Non-fatal — internal copy will be cleaned up on next reinstall anyway
      }
    } catch (e) {
      // Non-fatal — model remains usable from internal storage
      debugPrint('VAZHI: Failed to persist model to Downloads: $e');
    }
  }

  /// GGUF magic bytes: 'GGUF' = [0x47, 0x47, 0x55, 0x46]
  static const _ggufMagic = [0x47, 0x47, 0x55, 0x46];

  /// Validate GGUF file header before passing to native llama.cpp.
  /// Catches corrupt/partial downloads that would cause native SIGSEGV.
  Future<void> _validateGgufHeader(String path) async {
    final file = File(path);
    final raf = await file.open();
    try {
      final header = await raf.read(4);
      if (header.length < 4 ||
          header[0] != _ggufMagic[0] ||
          header[1] != _ggufMagic[1] ||
          header[2] != _ggufMagic[2] ||
          header[3] != _ggufMagic[3]) {
        throw VazhiLocalException(
          'மாடல் கோப்பு சிதைந்துள்ளது. மீண்டும் பதிவிறக்கம் செய்யுங்கள்.',
        );
      }
    } finally {
      await raf.close();
    }
  }

  /// Path to the diagnostic file that tracks model load progress.
  /// Written synchronously before each native call so it survives crashes.
  Future<String> get _diagnosticPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/model_load_diagnostic.txt';
  }

  /// Append a diagnostic step marker. Uses sync I/O to ensure the write
  /// completes before the next (potentially crashing) native FFI call.
  /// Appends (not overwrites) so all steps are visible after a crash.
  Future<void> _writeDiagnostic(String step) async {
    try {
      final path = await _diagnosticPath;
      File(path).writeAsStringSync(
        '${DateTime.now().toIso8601String()}|$step\n',
        mode: FileMode.append,
      );
    } catch (_) {
      // Diagnostic write failure is non-fatal
    }
  }

  /// Read diagnostics. Combines the main diagnostic log with the
  /// worker-isolate load diagnostic (if present). Returns null if none exist.
  Future<String?> readLastDiagnostic() async {
    final parts = <String>[];
    try {
      final path = await _diagnosticPath;
      final file = File(path);
      if (await file.exists()) {
        parts.add(await file.readAsString());
      }
    } catch (_) {}
    // Also read worker-isolate diagnostic
    final workerDiag = await _readWorkerDiagnostic();
    if (workerDiag != null) {
      parts.add('--- worker isolate ---');
      parts.add(workerDiag);
    }
    // Also read captured llama.cpp stderr
    final stderrLog = await _readStderrLog();
    if (stderrLog != null) {
      parts.add('--- llama.cpp stderr ---');
      parts.add(stderrLog);
    }
    return parts.isEmpty ? null : parts.join('\n');
  }

  /// Clear the diagnostic file. Called after successful load,
  /// or by the UI retry handler to allow a fresh load attempt.
  Future<void> clearDiagnostic() async {
    try {
      final path = await _diagnosticPath;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore delete errors
    }
  }

  /// Read the worker-isolate load diagnostic (written by llama_cpp_service
  /// next to the model file as `$modelPath.loaddiag.txt`).
  Future<String?> _readWorkerDiagnostic() async {
    try {
      final path = await modelPath;
      final file = File('$path.loaddiag.txt');
      if (await file.exists()) {
        return file.readAsString();
      }
    } catch (_) {}
    return null;
  }

  /// Read the captured llama.cpp stderr log (written during model load).
  Future<String?> _readStderrLog() async {
    try {
      final path = await modelPath;
      final file = File('$path.stderr.txt');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) return content;
      }
    } catch (_) {}
    return null;
  }

  /// Initialize the engine and load the model.
  /// Writes diagnostic markers before each native call so crashes can
  /// be diagnosed without adb — check readLastDiagnostic() on restart.
  ///
  /// The llamadart service tries mmap first (low RAM), then malloc fallback.
  /// When malloc is used (entire model in physical RAM), context is
  /// aggressively clamped to n_ctx=64/n_batch=1 to avoid OOM.
  /// Step markers written to `$modelPath.loaddiag.txt` survive crashes.
  Future<void> initialize() async {
    if (_isModelLoaded) return;

    final path = await modelPath;
    if (!await isModelDownloaded()) {
      throw VazhiLocalException(
        'மாடல் கோப்பு இல்லை. முதலில் பதிவிறக்கம் செய்யுங்கள்.',
      );
    }

    // Clear previous diagnostic before new attempt
    await clearDiagnostic();

    // Validate GGUF header before native load to prevent SIGSEGV on corrupt files
    await _writeDiagnostic('step:gguf_validate');
    await _validateGgufHeader(path);

    // Check model file size for diagnostic
    final fileSize = await File(path).length();
    final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
    debugPrint('VAZHI: Model file size: ${fileSizeMB}MB');

    await _writeDiagnostic('step:engine_create|size:${fileSizeMB}MB');
    _engine = LlamaEngine(LlamaBackend());

    try {
      await _writeDiagnostic('step:set_log_level');
      await _engine!.setLogLevel(LlamaLogLevel.info);

      await _writeDiagnostic('step:load_start');
      await _engine!.loadModel(
        path,
        modelParams: const ModelParams(
          gpuLayers: 0, // CPU-only — avoids Vulkan issues on phones
          contextSize: 256, // Matches harness-tested context size
          numberOfThreads: 2, // Limit threads to reduce scratch buffer memory
          numberOfThreadsBatch: 2,
        ),
      );
      await _writeDiagnostic('step:load_ok');
    } catch (e) {
      // Merge worker-isolate diagnostic into main diagnostic
      final workerDiag = await _readWorkerDiagnostic();
      if (workerDiag != null) {
        await _writeDiagnostic('worker_diag:\n$workerDiag');
      }
      await _writeDiagnostic('step:error|msg:$e');
      _engine = null;
      throw VazhiLocalException('$e');
    }
    _isModelLoaded = true;
    await _writeDiagnostic('step:complete');
    await clearDiagnostic();
  }

  /// Ensure a session exists with the correct pack's system prompt.
  /// Recreates the session when the pack changes so the system prompt
  /// matches the selected knowledge domain. Preserves session within
  /// the same pack for multi-turn RAG continuity.
  void _ensureSession(String pack) {
    if (_session == null || _currentPack != pack) {
      final systemPrompt =
          packSystemPrompts[pack] ?? packSystemPrompts['culture']!;
      _session = ChatSession(_engine!, systemPrompt: systemPrompt);
      _currentPack = pack;
    }
  }

  /// Send a chat message and get a response
  Future<String> chat(String message, {String pack = 'culture'}) async {
    _assertReady();

    _ensureSession(pack);

    final buffer = StringBuffer();
    await for (final chunk in _session!.create([
      LlamaTextContent(message),
    ], params: _generationParams)) {
      if (chunk.choices.isEmpty) continue;
      final content = chunk.choices.first.delta.content;
      if (content != null) {
        buffer.write(content);
      }
    }

    return _cleanOutput(buffer.toString());
  }

  /// Clear the chat session (start fresh conversation)
  void clearSession() {
    _session = null;
    _currentPack = null;
  }

  /// Dispose of resources
  Future<void> dispose() async {
    _session = null;
    _currentPack = null;
    await _engine?.dispose();
    _engine = null;
    _isModelLoaded = false;
  }

  /// Delete the downloaded model file from all locations.
  Future<void> deleteModel() async {
    await dispose();

    // Delete from Downloads/VAZHI/
    await _deviceInfoService.deleteModelFromDownloads(_model.filename);

    // Delete from internal storage
    final internal = File(await _internalPath);
    if (await internal.exists()) {
      await internal.delete();
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
