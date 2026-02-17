/// Model Status Indicator
///
/// Shows the current status of the AI model (download progress, ready state).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/chat_provider.dart';
import '../providers/model_provider.dart';

class ModelStatusIndicator extends ConsumerWidget {
  final bool compact;
  final VoidCallback? onTap;

  const ModelStatusIndicator({super.key, this.compact = false, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(modelManagerProvider);
    final progress = ref.watch(downloadProgressProvider);
    final model = ref.watch(selectedModelProvider);

    return GestureDetector(
      onTap: onTap,
      child: compact
          ? _buildCompactIndicator(status, progress)
          : _buildFullIndicator(status, progress, model.displaySize),
    );
  }

  Widget _buildCompactIndicator(ModelStatus status, double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBackgroundColor(status).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(status, progress, size: 14),
          const SizedBox(width: 4),
          Text(
            _getCompactLabel(status),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _getBackgroundColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullIndicator(
    ModelStatus status,
    double progress,
    String displaySize,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatusIcon(status, progress, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLabel(status),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                if (status == ModelStatus.downloading)
                  _buildProgressBar(progress)
                else
                  Text(
                    _getDescription(status, displaySize),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          if (status == ModelStatus.notDownloaded ||
              status == ModelStatus.downloaded)
            _buildActionButton(status),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(
    ModelStatus status,
    double progress, {
    double size = 20,
  }) {
    switch (status) {
      case ModelStatus.notDownloaded:
        return Icon(
          Icons.cloud_download_outlined,
          size: size,
          color: Colors.grey,
        );
      case ModelStatus.downloading:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(VazhiTheme.primaryColor),
          ),
        );
      case ModelStatus.downloaded:
        return Icon(Icons.cloud_done_outlined, size: size, color: Colors.blue);
      case ModelStatus.loading:
        return SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      case ModelStatus.ready:
        return Icon(Icons.check_circle, size: size, color: Colors.green);
      case ModelStatus.error:
        return Icon(Icons.error_outline, size: size, color: Colors.red);
    }
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(VazhiTheme.primaryColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}% பதிவிறக்கம்',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildActionButton(ModelStatus status) {
    if (status == ModelStatus.notDownloaded) {
      return ElevatedButton.icon(
        onPressed: null, // Will be handled by parent
        icon: const Icon(Icons.download, size: 16),
        label: const Text('பதிவிறக்கம்'),
        style: ElevatedButton.styleFrom(
          backgroundColor: VazhiTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 12),
        ),
      );
    } else if (status == ModelStatus.downloaded) {
      return OutlinedButton.icon(
        onPressed: null, // Will be handled by parent
        icon: const Icon(Icons.play_arrow, size: 16),
        label: const Text('ஏற்று'),
        style: OutlinedButton.styleFrom(
          foregroundColor: VazhiTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 12),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _getCompactLabel(ModelStatus status) {
    switch (status) {
      case ModelStatus.notDownloaded:
        return 'AI இல்லை';
      case ModelStatus.downloading:
        return 'பதிவிறக்கம்...';
      case ModelStatus.downloaded:
        return 'AI தயார்';
      case ModelStatus.loading:
        return 'ஏற்றுகிறது...';
      case ModelStatus.ready:
        return 'AI ஆன்';
      case ModelStatus.error:
        return 'பிழை';
    }
  }

  String _getLabel(ModelStatus status) {
    switch (status) {
      case ModelStatus.notDownloaded:
        return 'AI Brain பதிவிறக்கவில்லை';
      case ModelStatus.downloading:
        return 'AI Brain பதிவிறக்குகிறது...';
      case ModelStatus.downloaded:
        return 'AI Brain தயாராக உள்ளது';
      case ModelStatus.loading:
        return 'AI Brain ஏற்றுகிறது...';
      case ModelStatus.ready:
        return 'AI Brain செயலில் உள்ளது';
      case ModelStatus.error:
        return 'பிழை ஏற்பட்டது';
    }
  }

  String _getDescription(ModelStatus status, String displaySize) {
    switch (status) {
      case ModelStatus.notDownloaded:
        return 'ஆழமான AI விளக்கங்களுக்கு பதிவிறக்கவும் ($displaySize)';
      case ModelStatus.downloading:
        return 'சிறிது நேரம் ஆகும்...';
      case ModelStatus.downloaded:
        return 'AI செயல்படுத்த ஏற்றவும்';
      case ModelStatus.loading:
        return 'சிறிது நேரம் காத்திருங்கள்...';
      case ModelStatus.ready:
        return 'ஆஃப்லைன் AI உரையாடல் தயார்!';
      case ModelStatus.error:
        return 'மீண்டும் முயற்சிக்கவும்';
    }
  }

  Color _getBackgroundColor(ModelStatus status) {
    switch (status) {
      case ModelStatus.notDownloaded:
        return Colors.grey;
      case ModelStatus.downloading:
        return VazhiTheme.primaryColor;
      case ModelStatus.downloaded:
        return Colors.blue;
      case ModelStatus.loading:
        return VazhiTheme.primaryColor;
      case ModelStatus.ready:
        return Colors.green;
      case ModelStatus.error:
        return Colors.red;
    }
  }
}

/// Download prompt banner
class DownloadPromptBanner extends ConsumerWidget {
  final VoidCallback onDownloadTap;
  final VoidCallback? onDismiss;

  const DownloadPromptBanner({
    super.key,
    required this.onDownloadTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(modelManagerProvider);
    final model = ref.watch(selectedModelProvider);

    // Only show for not downloaded state
    if (status != ModelStatus.notDownloaded) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            VazhiTheme.primaryColor.withValues(alpha: 0.1),
            VazhiTheme.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: VazhiTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🧠', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Brain பதிவிறக்கவும்',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'ஆஃப்லைன் AI உரையாடல் மற்றும் ஆழமான விளக்கங்கள்',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  color: Colors.grey,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '📦 ${model.displaySize}  •  📱 ஆஃப்லைன் வேலை செய்யும்',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onDownloadTap,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('இப்போது பதிவிறக்கம்'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VazhiTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
