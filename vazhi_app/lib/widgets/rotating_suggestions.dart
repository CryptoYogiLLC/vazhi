/// Rotating Suggestions Widget
///
/// Displays cycling example questions to inspire users.

import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class RotatingSuggestions extends StatefulWidget {
  final Function(String) onSuggestionTap;

  const RotatingSuggestions({
    super.key,
    required this.onSuggestionTap,
  });

  @override
  State<RotatingSuggestions> createState() => _RotatingSuggestionsState();
}

class _RotatingSuggestionsState extends State<RotatingSuggestions>
    with SingleTickerProviderStateMixin {
  // Suggestions with icon type: 'emoji', 'icon' (Material), or 'image' (asset)
  static const List<Map<String, dynamic>> _suggestions = [
    {
      'iconType': 'emoji',
      'icon': '🛡️',
      'text': 'இது scam message-ஆ?',
      'category': 'Security',
    },
    {
      'iconType': 'emoji',
      'icon': '⚖️',
      'text': 'RTI எப்படி போடுவது?',
      'category': 'Legal',
    },
    {
      'iconType': 'image',
      'imagePath': 'assets/icons/tn_govt.png',
      'text': 'Ration card எப்படி வாங்குவது?',
      'category': 'Government',
    },
    {
      'iconType': 'emoji',
      'icon': '📚',
      'text': 'NEET-க்கு எப்படி prepare பண்றது?',
      'category': 'Education',
    },
    {
      'iconType': 'image',
      'imagePath': 'assets/icons/health_mission.png',
      'text': 'Free treatment எங்கே கிடைக்கும்?',
      'category': 'Healthcare',
    },
    {
      'iconType': 'emoji',
      'icon': '🪷',
      'text': 'திருக்குறள் முதல் குறள் என்ன?',
      'category': 'Culture',
    },
    {
      'iconType': 'emoji',
      'icon': '⚖️',
      'text': 'Consumer complaint எப்படி போடுவது?',
      'category': 'Legal',
    },
    {
      'iconType': 'emoji',
      'icon': '🎓',
      'text': 'Engineering-க்கு என்ன options?',
      'category': 'Education',
    },
  ];

  int _currentIndex = 0;
  late Timer _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _suggestions.length;
        });
        _fadeController.forward();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildIcon(Map<String, dynamic> suggestion) {
    final iconType = suggestion['iconType'] as String;

    if (iconType == 'image') {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          suggestion['imagePath'] as String,
          fit: BoxFit.contain,
        ),
      );
    } else {
      // emoji type
      return Text(
        suggestion['icon'] as String,
        style: const TextStyle(fontSize: 28),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = _suggestions[_currentIndex];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () => widget.onSuggestionTap(suggestion['text'] as String),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: VazhiTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: VazhiTheme.primaryColor.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildIcon(suggestion),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion['text'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: VazhiTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to try',
                      style: TextStyle(
                        fontSize: 12,
                        color: VazhiTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: VazhiTheme.primaryColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static quick suggestion chips
class QuickSuggestionChips extends StatelessWidget {
  final Function(String) onTap;

  const QuickSuggestionChips({super.key, required this.onTap});

  static const List<String> _quickSuggestions = [
    'Scam check',
    'RTI help',
    'Thirukkural',
    'Schemes',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _quickSuggestions.map((text) {
        return ActionChip(
          label: Text(text),
          onPressed: () => onTap(text),
          backgroundColor: VazhiTheme.surfaceColor,
          side: BorderSide(color: VazhiTheme.primaryColor.withOpacity(0.3)),
          labelStyle: TextStyle(
            color: VazhiTheme.primaryColor,
            fontSize: 13,
          ),
        );
      }).toList(),
    );
  }
}
