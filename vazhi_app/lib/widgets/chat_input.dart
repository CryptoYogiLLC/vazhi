/// Chat Input Widget
///
/// Text input with send and microphone buttons.

import 'package:flutter/material.dart';
import '../config/theme.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool isListening;
  final VoidCallback onMicPressed;
  final bool voiceAvailable;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isListening,
    required this.onMicPressed,
    required this.voiceAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Microphone button
            if (voiceAvailable)
              _MicButton(
                isListening: isListening,
                onPressed: onMicPressed,
              ),

            const SizedBox(width: 8),

            // Text input
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: isListening ? 'Listening...' : 'Type a message...',
                  hintStyle: TextStyle(
                    color: isListening
                        ? VazhiTheme.primaryColor
                        : VazhiTheme.textLight,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    onSend(text);
                  }
                },
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            _SendButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onSend(controller.text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const _MicButton({
    required this.isListening,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isListening
              ? VazhiTheme.primaryColor
              : VazhiTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: isListening ? Colors.white : VazhiTheme.primaryColor,
              size: 24,
            ),
            if (isListening)
              _PulsingCircle(),
          ],
        ),
      ),
    );
  }
}

class _PulsingCircle extends StatefulWidget {
  @override
  State<_PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<_PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 48 + (16 * _controller.value),
          height: 48 + (16 * _controller.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: VazhiTheme.primaryColor.withOpacity(1 - _controller.value),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SendButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: VazhiTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.send,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
