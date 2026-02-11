/// Download Dialog
///
/// Dialog for AI model download with progress, pause/resume,
/// and network information.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../services/model_download_service.dart';
import '../providers/chat_provider.dart';

/// Download dialog provider
final downloadServiceProvider = Provider<ModelDownloadService>((ref) {
  final service = ModelDownloadService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Current download progress provider
final downloadProgressStreamProvider = StreamProvider<DownloadProgress>((ref) {
  final service = ref.watch(downloadServiceProvider);
  return service.progressStream;
});

class DownloadDialog extends ConsumerStatefulWidget {
  const DownloadDialog({super.key});

  /// Show the download dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DownloadDialog(),
    );
  }

  @override
  ConsumerState<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends ConsumerState<DownloadDialog> {
  bool _showCellularWarning = false;
  bool _acceptedCellular = false;
  bool _hasStarted = false;
  StorageInfo? _storageInfo;
  String? _storageError;

  @override
  void initState() {
    super.initState();
    _checkPrerequisites();
  }

  Future<void> _checkPrerequisites() async {
    final service = ref.read(downloadServiceProvider);

    // Check storage
    try {
      final storage = await service.checkStorage();
      setState(() {
        _storageInfo = storage;
        if (!storage.hasEnoughSpace) {
          _storageError =
              'போதுமான சேமிப்பிடம் இல்லை.\n${storage.requiredSpace} தேவை, ${storage.availableSpace} மட்டுமே உள்ளது.';
        }
      });
    } catch (e) {
      setState(() {
        _storageError = 'சேமிப்பிடம் சரிபார்க்க முடியவில்லை';
      });
    }

    // Check for partial download
    final partialSize = await service.getPartialDownloadSize();
    if (partialSize > 0) {
      // We have a partial download, offer to resume
      setState(() {
        _hasStarted = true;
      });
    }

    // Check network
    if (await service.isOnCellular()) {
      setState(() {
        _showCellularWarning = true;
      });
    }
  }

  Future<void> _startDownload({bool forceRestart = false}) async {
    final service = ref.read(downloadServiceProvider);

    if (_showCellularWarning && !_acceptedCellular) {
      // Show cellular warning first
      final proceed = await _showCellularWarningDialog();
      if (!proceed) return;
      _acceptedCellular = true;
    }

    setState(() {
      _hasStarted = true;
    });

    await service.startDownload(forceRestart: forceRestart);
  }

  Future<bool> _showCellularWarningDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.signal_cellular_alt, color: Colors.orange),
                SizedBox(width: 12),
                Text('மொபைல் டேட்டா'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'நீங்கள் மொபைல் டேட்டாவில் உள்ளீர்கள்.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'AI Brain பதிவிறக்கம் ~1.6 GB. WiFi பயன்படுத்த பரிந்துரைக்கப்படுகிறது.',
                ),
                SizedBox(height: 8),
                Text(
                  'தொடர வேண்டுமா?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('WiFi காத்திரு'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('தொடர்க'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(downloadProgressStreamProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: progressAsync.when(
          data: (progress) => _buildContent(progress),
          loading: () => _buildInitialContent(),
          error: (error, _) => _buildErrorContent(error.toString()),
        ),
      ),
    );
  }

  Widget _buildInitialContent() {
    if (_storageError != null) {
      return _buildStorageError();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildInfoCard(),
        const SizedBox(height: 24),
        _buildActions(null),
      ],
    );
  }

  Widget _buildStorageError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.storage, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        const Text(
          'சேமிப்பிடம் பற்றாக்குறை',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          _storageError!,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('மூடு'),
        ),
      ],
    );
  }

  Widget _buildContent(DownloadProgress progress) {
    if (!_hasStarted || progress.state == DownloadState.idle) {
      return _buildInitialContent();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildProgressSection(progress),
        const SizedBox(height: 24),
        _buildActions(progress),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: VazhiTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('🧠', style: TextStyle(fontSize: 28)),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Brain பதிவிறக்கம்',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'ஆஃப்லைன் AI உரையாடல்',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VazhiTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.storage, 'கோப்பு அளவு', '~1.6 GB'),
          const Divider(height: 16),
          _buildInfoRow(Icons.offline_bolt, 'ஆஃப்லைன் பயன்', 'ஆம்'),
          const Divider(height: 16),
          _buildInfoRow(
            Icons.signal_wifi_4_bar,
            'பரிந்துரை',
            'WiFi பயன்படுத்தவும்',
          ),
          if (_storageInfo != null && _storageInfo!.isLowSpace) ...[
            const Divider(height: 16),
            _buildInfoRow(
              Icons.warning_amber,
              'சேமிப்பிடம்',
              _storageInfo!.availableSpace,
              iconColor: Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? VazhiTheme.primaryColor),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildProgressSection(DownloadProgress progress) {
    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(progress),
        const SizedBox(height: 16),

        // Status and stats
        _buildStatusRow(progress),
        const SizedBox(height: 12),

        // Details
        _buildDetailsRow(progress),
      ],
    );
  }

  Widget _buildProgressIndicator(DownloadProgress progress) {
    final isPaused = progress.state == DownloadState.paused;
    final isVerifying = progress.state == DownloadState.verifying;
    final isCompleted = progress.state == DownloadState.completed;
    final isError = progress.state == DownloadState.error;

    Color progressColor = VazhiTheme.primaryColor;
    if (isPaused) progressColor = Colors.orange;
    if (isCompleted) progressColor = Colors.green;
    if (isError) progressColor = Colors.red;

    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  value: isVerifying ? null : progress.progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(progressColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCompleted)
                    const Icon(Icons.check, size: 32, color: Colors.green)
                  else if (isError)
                    const Icon(Icons.error, size: 32, color: Colors.red)
                  else if (isVerifying)
                    const Icon(Icons.security, size: 28, color: Colors.blue)
                  else ...[
                    Text(
                      progress.progressPercent,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isPaused)
                      const Icon(Icons.pause, size: 16, color: Colors.orange),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getStatusText(progress),
          style: TextStyle(fontWeight: FontWeight.w500, color: progressColor),
        ),
      ],
    );
  }

  String _getStatusText(DownloadProgress progress) {
    switch (progress.state) {
      case DownloadState.idle:
        return 'தயாராக உள்ளது';
      case DownloadState.checking:
        return 'சரிபார்க்கிறது...';
      case DownloadState.downloading:
        return 'பதிவிறக்கம்...';
      case DownloadState.paused:
        return 'இடைநிறுத்தப்பட்டது';
      case DownloadState.verifying:
        return 'சரிபார்க்கிறது...';
      case DownloadState.completed:
        return 'வெற்றிகரமாக பதிவிறக்கப்பட்டது!';
      case DownloadState.error:
        return progress.errorMessage ?? 'பிழை ஏற்பட்டது';
    }
  }

  Widget _buildStatusRow(DownloadProgress progress) {
    if (progress.state == DownloadState.error) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                progress.errorMessage ?? 'பிழை ஏற்பட்டது',
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    if (progress.state == DownloadState.completed) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(
              'AI Brain தயாராக உள்ளது!',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDetailsRow(DownloadProgress progress) {
    if (progress.state != DownloadState.downloading &&
        progress.state != DownloadState.paused) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            Icons.download,
            '${progress.downloadedSize} / ${progress.totalSize}',
          ),
          _buildDetailItem(Icons.speed, progress.speed),
          _buildDetailItem(Icons.timer, progress.eta),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(DownloadProgress? progress) {
    final state = progress?.state ?? DownloadState.idle;

    if (state == DownloadState.completed) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Load the model
                ref.read(modelManagerProvider.notifier).loadModel();
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('AI ஏற்று'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      );
    }

    if (state == DownloadState.downloading) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(downloadServiceProvider).pauseDownload();
              },
              icon: const Icon(Icons.pause),
              label: const Text('இடைநிறுத்து'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                ref.read(downloadServiceProvider).cancelDownload();
                Navigator.pop(context, false);
              },
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('ரத்து', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      );
    }

    if (state == DownloadState.paused) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(downloadServiceProvider).resumeDownload();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('தொடர்க'),
              style: ElevatedButton.styleFrom(
                backgroundColor: VazhiTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                ref.read(downloadServiceProvider).cancelDownload();
                Navigator.pop(context, false);
              },
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('ரத்து', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      );
    }

    if (state == DownloadState.error) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _startDownload(forceRestart: true),
              icon: const Icon(Icons.refresh),
              label: const Text('மீண்டும் முயற்சி'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('மூடு'),
            ),
          ),
        ],
      );
    }

    // Initial state - show download button
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _storageError != null ? null : _startDownload,
            icon: const Icon(Icons.download),
            label: const Text('பதிவிறக்கம் தொடங்கு'),
            style: ElevatedButton.styleFrom(
              backgroundColor: VazhiTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('பின்னர்'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(String error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(error),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('மூடு'),
        ),
      ],
    );
  }
}
