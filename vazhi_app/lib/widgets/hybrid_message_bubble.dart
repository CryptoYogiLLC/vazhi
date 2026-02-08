/// Hybrid Message Bubble
///
/// Displays messages from the hybrid chat system,
/// handling both knowledge-based and AI responses.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/message.dart';
import '../providers/hybrid_chat_provider.dart';
import '../providers/chat_provider.dart';
import 'knowledge_result_card.dart';

class HybridMessageBubble extends ConsumerWidget {
  final HybridMessage message;
  final VoidCallback? onSpeak;
  final VoidCallback? onDownloadAi;
  final Function(HybridMessage)? onEnhanceWithAi;

  const HybridMessageBubble({
    super.key,
    required this.message,
    this.onSpeak,
    this.onDownloadAi,
    this.onEnhanceWithAi,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // User message
    if (message.role == MessageRole.user) {
      return _buildUserMessage(context);
    }

    // Loading state
    if (message.isLoading) {
      return _buildLoadingMessage(context);
    }

    // Error state
    if (message.error != null) {
      return _buildErrorMessage(context, ref);
    }

    // Knowledge-based response
    if (message.isFromKnowledge && message.knowledgeResponse != null) {
      return _buildKnowledgeResponse(context, ref);
    }

    // AI response
    return _buildAiResponse(context);
  }

  Widget _buildUserMessage(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: VazhiTheme.primaryGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          message.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMessage(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(VazhiTheme.primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'சிந்தித்துக் கொண்டிருக்கிறேன்...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, WidgetRef ref) {
    final modelStatus = ref.watch(modelManagerProvider);
    final showDownloadPrompt = modelStatus == ModelStatus.notDownloaded;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showDownloadPrompt) ...[
              const SizedBox(height: 8),
              _buildDownloadButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeResponse(BuildContext context, WidgetRef ref) {
    final modelStatus = ref.watch(modelManagerProvider);
    final isModelReady = modelStatus == ModelStatus.ready;

    return KnowledgeResultCard(
      response: message.knowledgeResponse!,
      modelReady: isModelReady,
      showAiPrompt: message.aiEnhancementAvailable,
      onSpeakTap: onSpeak,
      onDownloadAiTap: onDownloadAi,
      onAskMoreTap: () => onEnhanceWithAi?.call(message),
    );
  }

  Widget _buildAiResponse(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: VazhiTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: VazhiTheme.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AI விளக்கம்',
                    style: TextStyle(
                      fontSize: 11,
                      color: VazhiTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Response content
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SelectableText(
                message.content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onDownloadAi,
        icon: const Icon(Icons.download, size: 18),
        label: const Text('AI Brain பதிவிறக்கம்'),
        style: ElevatedButton.styleFrom(
          backgroundColor: VazhiTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}
