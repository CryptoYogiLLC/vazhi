/// Message Bubble Widget
///
/// Displays a single chat message with appropriate styling.
library;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../config/theme.dart';
import '../models/message.dart';
import '../models/feedback.dart';
import 'feedback_buttons.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String? userQuestion; // The question this response answers
  final VoidCallback? onSpeak;
  final VoidCallback? onRetry;
  final FeedbackType? currentFeedback;
  final VoidCallback? onPositiveFeedback;
  final VoidCallback? onNegativeFeedback;
  final Function(String)? onCorrection;

  const MessageBubble({
    super.key,
    required this.message,
    this.userQuestion,
    this.onSpeak,
    this.onRetry,
    this.currentFeedback,
    this.onPositiveFeedback,
    this.onNegativeFeedback,
    this.onCorrection,
  });

  /// Check if any feedback callbacks are provided
  bool get _hasFeedbackCallbacks =>
      onPositiveFeedback != null ||
      onNegativeFeedback != null ||
      onCorrection != null;

  /// Show the correction dialog
  void _showCorrectionDialog(BuildContext context) {
    if (onCorrection == null) return;

    showDialog(
      context: context,
      builder: (context) => CorrectionDialog(
        question: userQuestion ?? '',
        modelResponse: message.content,
        onSubmit: onCorrection!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) {
      return _buildLoadingBubble();
    }

    if (message.error != null) {
      return _buildErrorBubble(context);
    }

    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[_buildAvatar(isUser), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? VazhiTheme.userBubbleColor
                        : VazhiTheme.assistantBubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: isUser
                      ? Text(
                          message.content,
                          style: const TextStyle(
                            color: VazhiTheme.userBubbleText,
                            fontSize: 16,
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: VazhiTheme.assistantBubbleText,
                              fontSize: 16,
                            ),
                            strong: const TextStyle(
                              color: VazhiTheme.assistantBubbleText,
                              fontWeight: FontWeight.bold,
                            ),
                            listBullet: const TextStyle(
                              color: VazhiTheme.assistantBubbleText,
                            ),
                          ),
                        ),
                ),
                if (!isUser)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.pack != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: VazhiTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              message.pack!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: VazhiTheme.primaryColor,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (onSpeak != null)
                          GestureDetector(
                            onTap: onSpeak,
                            child: const Icon(
                              Icons.volume_up,
                              size: 18,
                              color: VazhiTheme.textLight,
                            ),
                          ),
                        if (_hasFeedbackCallbacks) ...[
                          const SizedBox(width: 12),
                          FeedbackButtons(
                            messageId: message.id,
                            currentFeedback: currentFeedback,
                            onPositive: onPositiveFeedback ?? () {},
                            onNegative: onNegativeFeedback ?? () {},
                            onCorrect: () => _showCorrectionDialog(context),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isUser) ...[const SizedBox(width: 8), _buildAvatar(isUser)],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? VazhiTheme.primaryColor : VazhiTheme.secondaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: isUser
            ? const Icon(Icons.person, size: 18, color: Colors.white)
            : const Text(
                'வ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: VazhiTheme.assistantBubbleColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: VazhiTheme.textLight.withValues(
              alpha: 0.3 + (0.7 * (1 - (value - value.floor()))),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildErrorBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(false),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: VazhiTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: VazhiTheme.errorColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 18,
                        color: VazhiTheme.errorColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message.error!,
                          style: TextStyle(
                            color: VazhiTheme.errorColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onRetry,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 16,
                            color: VazhiTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Retry',
                            style: TextStyle(
                              color: VazhiTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
