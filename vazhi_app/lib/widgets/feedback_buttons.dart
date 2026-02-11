/// Feedback Buttons Widget
///
/// Shows 👍/👎/✏️ feedback buttons for AI responses.
library;

import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/feedback.dart';

class FeedbackButtons extends StatefulWidget {
  final String messageId;
  final FeedbackType? currentFeedback;
  final VoidCallback onPositive;
  final VoidCallback onNegative;
  final VoidCallback onCorrect;

  const FeedbackButtons({
    super.key,
    required this.messageId,
    this.currentFeedback,
    required this.onPositive,
    required this.onNegative,
    required this.onCorrect,
  });

  @override
  State<FeedbackButtons> createState() => _FeedbackButtonsState();
}

class _FeedbackButtonsState extends State<FeedbackButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Thumbs up
        _FeedbackButton(
          icon: Icons.thumb_up_outlined,
          activeIcon: Icons.thumb_up,
          isActive: widget.currentFeedback == FeedbackType.positive,
          activeColor: Colors.green,
          tooltip: 'நல்ல பதில்',
          onTap: widget.onPositive,
        ),
        const SizedBox(width: 8),
        // Thumbs down
        _FeedbackButton(
          icon: Icons.thumb_down_outlined,
          activeIcon: Icons.thumb_down,
          isActive: widget.currentFeedback == FeedbackType.negative,
          activeColor: Colors.red,
          tooltip: 'தவறான பதில்',
          onTap: widget.onNegative,
        ),
        const SizedBox(width: 8),
        // Correct/Edit
        _FeedbackButton(
          icon: Icons.edit_outlined,
          activeIcon: Icons.edit,
          isActive: widget.currentFeedback == FeedbackType.correction,
          activeColor: VazhiTheme.primaryColor,
          tooltip: 'திருத்தம்',
          onTap: widget.onCorrect,
        ),
      ],
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final Color activeColor;
  final String tooltip;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.activeColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      selected: isActive,
      onTap: onTap,
      label: tooltip,
      hint: isActive ? 'Already selected' : 'Double tap to select',
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              size: 18,
              color: isActive ? activeColor : VazhiTheme.textLight,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for entering a correction
class CorrectionDialog extends StatefulWidget {
  final String question;
  final String modelResponse;
  final Function(String) onSubmit;

  const CorrectionDialog({
    super.key,
    required this.question,
    required this.modelResponse,
    required this.onSubmit,
  });

  @override
  State<CorrectionDialog> createState() => _CorrectionDialogState();
}

class _CorrectionDialogState extends State<CorrectionDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Pre-fill with model response for easy editing
    _controller.text = widget.modelResponse;
    // Select all text for easy replacement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(Icons.edit, color: VazhiTheme.primaryColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'பதிலைத் திருத்துங்கள்',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Original question
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'கேள்வி:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.question, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Correction input
            const Text(
              'சரியான பதில்:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'சரியான பதிலை இங்கே எழுதுங்கள்...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: VazhiTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Helper text
            Text(
              'உங்கள் திருத்தம் மாடலை மேம்படுத்த பயன்படுத்தப்படும்.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ரத்து'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final correction = _controller.text.trim();
                    if (correction.isNotEmpty &&
                        correction != widget.modelResponse) {
                      widget.onSubmit(correction);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VazhiTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('சமர்ப்பி'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
