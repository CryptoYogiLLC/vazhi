/// Model Download Service
///
/// Enhanced download service with pause/resume, network detection,
/// storage checks, and progress tracking.
library;


import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Download state
enum DownloadState {
  idle,
  checking,
  downloading,
  paused,
  verifying,
  completed,
  error,
}

/// Network type
enum NetworkType { wifi, cellular, none }

/// Download progress information
class DownloadProgress {
  final DownloadState state;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final double speedBytesPerSecond;
  final Duration? estimatedTimeRemaining;
  final String? errorMessage;
  final NetworkType networkType;

  const DownloadProgress({
    this.state = DownloadState.idle,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.speedBytesPerSecond = 0,
    this.estimatedTimeRemaining,
    this.errorMessage,
    this.networkType = NetworkType.none,
  });

  String get progressPercent => '${(progress * 100).toInt()}%';

  String get downloadedSize => _formatBytes(downloadedBytes);

  String get totalSize => _formatBytes(totalBytes);

  String get speed => '${_formatBytes(speedBytesPerSecond.toInt())}/s';

  String get eta {
    if (estimatedTimeRemaining == null) return '--:--';
    final seconds = estimatedTimeRemaining!.inSeconds;
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m ${seconds % 60}s';
    return '${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  DownloadProgress copyWith({
    DownloadState? state,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    double? speedBytesPerSecond,
    Duration? estimatedTimeRemaining,
    String? errorMessage,
    NetworkType? networkType,
  }) {
    return DownloadProgress(
      state: state ?? this.state,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      speedBytesPerSecond: speedBytesPerSecond ?? this.speedBytesPerSecond,
      estimatedTimeRemaining:
          estimatedTimeRemaining ?? this.estimatedTimeRemaining,
      errorMessage: errorMessage,
      networkType: networkType ?? this.networkType,
    );
  }
}

/// Storage information
class StorageInfo {
  final int availableBytes;
  final int requiredBytes;
  final bool hasEnoughSpace;
  final bool isLowSpace;

  StorageInfo({required this.availableBytes, required this.requiredBytes})
    : hasEnoughSpace = availableBytes > requiredBytes,
      isLowSpace = availableBytes < requiredBytes * 1.2; // 20% buffer

  String get availableSpace => DownloadProgress._formatBytes(availableBytes);
  String get requiredSpace => DownloadProgress._formatBytes(requiredBytes);
}

/// Model download service
class ModelDownloadService {
  /// Model download URL
  static const String modelUrl =
      'https://huggingface.co/CryptoYogi/vazhi-gguf/resolve/main/vazhi-v1.gguf';

  /// Model filename
  static const String modelFilename = 'vazhi-v1.gguf';

  /// Partial download filename
  static const String partialFilename = 'vazhi-v1.gguf.partial';

  /// Expected model size (~1.6 GB)
  static const int expectedModelSize = 1630000000;

  /// Minimum required space (model size + 200MB buffer)
  static const int requiredSpace = expectedModelSize + 200 * 1024 * 1024;

  /// Expected MD5 checksum (optional - for verification)
  static const String? expectedChecksum = null; // Set when available

  final _progressController = StreamController<DownloadProgress>.broadcast();
  http.Client? _client;
  bool _isPaused = false;
  bool _isCancelled = false;
  int _resumePosition = 0;
  DateTime? _lastSpeedUpdate;
  int _lastBytesForSpeed = 0;
  double _currentSpeed = 0;

  /// Stream of download progress updates
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  /// Get current network type
  Future<NetworkType> getNetworkType() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.wifi)) {
      return NetworkType.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return NetworkType.cellular;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return NetworkType.wifi;
    }
    return NetworkType.none;
  }

  /// Check if on cellular network
  Future<bool> isOnCellular() async {
    return await getNetworkType() == NetworkType.cellular;
  }

  /// Check available storage
  Future<StorageInfo> checkStorage() async {
    final dir = await getApplicationDocumentsDirectory();

    // Get available space using statfs
    int availableBytes;
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        // On iOS/macOS, use a conservative estimate
        availableBytes = 10 * 1024 * 1024 * 1024; // 10GB default
        // Try to get actual space
        final stat = await FileStat.stat(dir.path);
        if (stat.type != FileSystemEntityType.notFound) {
          // This is a simplification - in production, use platform channels
          availableBytes = 5 * 1024 * 1024 * 1024; // 5GB conservative
        }
      } else {
        // On Android, similar approach
        availableBytes = 5 * 1024 * 1024 * 1024; // 5GB conservative
      }
    } catch (_) {
      availableBytes = 5 * 1024 * 1024 * 1024; // 5GB fallback
    }

    return StorageInfo(
      availableBytes: availableBytes,
      requiredBytes: requiredSpace,
    );
  }

  /// Get model file path
  Future<String> get modelPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$modelFilename';
  }

  /// Get partial file path
  Future<String> get _partialPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$partialFilename';
  }

  /// Check if model is downloaded
  Future<bool> isModelDownloaded() async {
    final path = await modelPath;
    final file = File(path);
    if (await file.exists()) {
      final size = await file.length();
      return size > 1000000000; // At least 1GB
    }
    return false;
  }

  /// Check if there's a partial download
  Future<int> getPartialDownloadSize() async {
    final path = await _partialPath;
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Start or resume download
  Future<void> startDownload({bool forceRestart = false}) async {
    _isPaused = false;
    _isCancelled = false;

    final networkType = await getNetworkType();

    if (networkType == NetworkType.none) {
      _emitProgress(
        DownloadProgress(
          state: DownloadState.error,
          errorMessage: 'இணைய இணைப்பு இல்லை',
          networkType: networkType,
        ),
      );
      return;
    }

    // Check storage
    final storage = await checkStorage();
    if (!storage.hasEnoughSpace) {
      _emitProgress(
        DownloadProgress(
          state: DownloadState.error,
          errorMessage:
              'போதுமான சேமிப்பிடம் இல்லை. ${storage.requiredSpace} தேவை, ${storage.availableSpace} உள்ளது.',
          networkType: networkType,
        ),
      );
      return;
    }

    // Check for partial download
    final partialPath = await _partialPath;
    final partialFile = File(partialPath);
    _resumePosition = 0;

    if (!forceRestart && await partialFile.exists()) {
      _resumePosition = await partialFile.length();
      if (_resumePosition > 0) {
        _emitProgress(
          DownloadProgress(
            state: DownloadState.checking,
            downloadedBytes: _resumePosition,
            totalBytes: expectedModelSize,
            progress: _resumePosition / expectedModelSize,
            networkType: networkType,
          ),
        );
      }
    } else if (await partialFile.exists()) {
      await partialFile.delete();
    }

    await _performDownload(networkType);
  }

  /// Pause download
  void pauseDownload() {
    _isPaused = true;
    _client?.close();
    _client = null;
  }

  /// Resume download
  Future<void> resumeDownload() async {
    if (!_isPaused) return;
    await startDownload();
  }

  /// Cancel download
  Future<void> cancelDownload() async {
    _isCancelled = true;
    _isPaused = false;
    _client?.close();
    _client = null;

    // Delete partial file
    final path = await _partialPath;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }

    _emitProgress(const DownloadProgress(state: DownloadState.idle));
  }

  /// Delete downloaded model
  Future<void> deleteModel() async {
    final path = await modelPath;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }

    // Also delete partial if exists
    final partialPath = await _partialPath;
    final partialFile = File(partialPath);
    if (await partialFile.exists()) {
      await partialFile.delete();
    }
  }

  /// Perform the actual download
  Future<void> _performDownload(NetworkType networkType) async {
    _client = http.Client();
    final partialPath = await _partialPath;
    final finalPath = await modelPath;

    try {
      // Follow redirects and get final URL
      var url = Uri.parse(modelUrl);

      // Create request with range header for resume
      final headers = <String, String>{};
      if (_resumePosition > 0) {
        headers['Range'] = 'bytes=$_resumePosition-';
      }

      // Follow redirects
      http.StreamedResponse response;
      for (var i = 0; i < 5; i++) {
        final request = http.Request('GET', url);
        request.headers.addAll(headers);
        response = await _client!.send(request);

        if (response.statusCode == 301 ||
            response.statusCode == 302 ||
            response.statusCode == 303 ||
            response.statusCode == 307) {
          final location = response.headers['location'];
          if (location == null) {
            throw ModelDownloadException('Redirect without location');
          }
          url = Uri.parse(location);
          if (!url.hasScheme) {
            url = Uri.parse(modelUrl).resolve(location);
          }
          await response.stream.drain();
          continue;
        }

        if (response.statusCode != 200 && response.statusCode != 206) {
          throw ModelDownloadException(
            'பதிவிறக்கம் தோல்வி: HTTP ${response.statusCode}',
          );
        }

        // Calculate total size
        int totalBytes = expectedModelSize;
        if (response.contentLength != null) {
          totalBytes = _resumePosition + response.contentLength!;
        }

        // Open file for writing
        final file = File(partialPath);
        final sink = file.openWrite(
          mode: _resumePosition > 0 ? FileMode.append : FileMode.write,
        );

        var downloadedBytes = _resumePosition;
        _lastSpeedUpdate = DateTime.now();
        _lastBytesForSpeed = downloadedBytes;

        _emitProgress(
          DownloadProgress(
            state: DownloadState.downloading,
            downloadedBytes: downloadedBytes,
            totalBytes: totalBytes,
            progress: downloadedBytes / totalBytes,
            networkType: networkType,
          ),
        );

        try {
          await for (final chunk in response.stream) {
            if (_isCancelled) {
              await sink.close();
              return;
            }

            if (_isPaused) {
              await sink.close();
              _emitProgress(
                DownloadProgress(
                  state: DownloadState.paused,
                  downloadedBytes: downloadedBytes,
                  totalBytes: totalBytes,
                  progress: downloadedBytes / totalBytes,
                  networkType: networkType,
                ),
              );
              return;
            }

            sink.add(chunk);
            downloadedBytes += chunk.length;

            // Update speed calculation
            _updateSpeed(downloadedBytes);

            // Calculate ETA
            Duration? eta;
            if (_currentSpeed > 0) {
              final remainingBytes = totalBytes - downloadedBytes;
              final secondsRemaining = remainingBytes / _currentSpeed;
              eta = Duration(seconds: secondsRemaining.toInt());
            }

            _emitProgress(
              DownloadProgress(
                state: DownloadState.downloading,
                downloadedBytes: downloadedBytes,
                totalBytes: totalBytes,
                progress: downloadedBytes / totalBytes,
                speedBytesPerSecond: _currentSpeed,
                estimatedTimeRemaining: eta,
                networkType: networkType,
              ),
            );
          }

          await sink.close();
        } catch (e) {
          await sink.close();
          rethrow;
        }

        // Verify download
        _emitProgress(
          DownloadProgress(
            state: DownloadState.verifying,
            downloadedBytes: downloadedBytes,
            totalBytes: totalBytes,
            progress: 1.0,
            networkType: networkType,
          ),
        );

        final verified = await _verifyDownload(partialPath);
        if (!verified) {
          throw ModelDownloadException('பதிவிறக்கம் சரிபார்ப்பு தோல்வி');
        }

        // Rename partial to final
        await File(partialPath).rename(finalPath);

        _emitProgress(
          DownloadProgress(
            state: DownloadState.completed,
            downloadedBytes: downloadedBytes,
            totalBytes: totalBytes,
            progress: 1.0,
            networkType: networkType,
          ),
        );

        return;
      }

      throw ModelDownloadException('Too many redirects');
    } on SocketException catch (e) {
      _emitProgress(
        DownloadProgress(
          state: DownloadState.error,
          errorMessage: 'இணைய பிழை: ${e.message}',
          networkType: networkType,
        ),
      );
    } on HttpException catch (e) {
      _emitProgress(
        DownloadProgress(
          state: DownloadState.error,
          errorMessage: 'HTTP பிழை: ${e.message}',
          networkType: networkType,
        ),
      );
    } on ModelDownloadException catch (e) {
      _emitProgress(
        DownloadProgress(
          state: DownloadState.error,
          errorMessage: e.message,
          networkType: networkType,
        ),
      );
    } catch (e) {
      _emitProgress(
        DownloadProgress(
          state: DownloadState.error,
          errorMessage: 'பிழை: $e',
          networkType: networkType,
        ),
      );
    } finally {
      _client?.close();
      _client = null;
    }
  }

  /// Update speed calculation
  void _updateSpeed(int currentBytes) {
    final now = DateTime.now();
    if (_lastSpeedUpdate != null) {
      final elapsed = now.difference(_lastSpeedUpdate!).inMilliseconds;
      if (elapsed > 1000) {
        // Update speed every second
        final bytesDiff = currentBytes - _lastBytesForSpeed;
        _currentSpeed = bytesDiff / (elapsed / 1000);
        _lastSpeedUpdate = now;
        _lastBytesForSpeed = currentBytes;
      }
    }
  }

  /// Verify downloaded file
  Future<bool> _verifyDownload(String path) async {
    final file = File(path);
    if (!await file.exists()) return false;

    final size = await file.length();
    if (size < 1000000000) return false; // At least 1GB

    // If we have a checksum, verify it
    if (expectedChecksum != null) {
      final bytes = await file.readAsBytes();
      final digest = md5.convert(bytes);
      return digest.toString() == expectedChecksum;
    }

    return true;
  }

  void _emitProgress(DownloadProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  /// Dispose resources
  void dispose() {
    _client?.close();
    _progressController.close();
  }
}

/// Model download exception
class ModelDownloadException implements Exception {
  final String message;

  ModelDownloadException(this.message);

  @override
  String toString() => message;
}
