/// Knowledge Result Card
///
/// Displays deterministic results from SQLite knowledge base.
/// Shows formatted content with actions and optional AI enhancement prompt.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../models/query_result.dart';
import '../services/retrieval/knowledge_service.dart';

class KnowledgeResultCard extends StatelessWidget {
  final KnowledgeResponse response;
  final VoidCallback? onDownloadAiTap;
  final VoidCallback? onAskMoreTap;
  final VoidCallback? onSpeakTap;
  final bool showAiPrompt;
  final bool modelReady;

  const KnowledgeResultCard({
    super.key,
    required this.response,
    this.onDownloadAiTap,
    this.onAskMoreTap,
    this.onSpeakTap,
    this.showAiPrompt = true,
    this.modelReady = false,
  });

  @override
  Widget build(BuildContext context) {
    final category = response.classification.category;
    final formattedResponse = response.formattedResponse ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category header
          _buildHeader(context, category),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: MarkdownBody(
              data: formattedResponse,
              styleSheet: _markdownStyleSheet(context),
              selectable: true,
            ),
          ),

          // Action buttons
          _buildActions(context, formattedResponse),

          // AI enhancement prompt (if applicable)
          if (showAiPrompt && response.suggestAiEnhancement)
            _buildAiPrompt(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, KnowledgeCategory category) {
    final icon = _getCategoryIcon(category);
    final name = category.nameTamil;
    final color = _getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (response.result?.displayTitle != null)
                  Text(
                    response.result!.displayTitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          // Source badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'நம்பகமான தரவு',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, String content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Listen
          _ActionButton(
            icon: Icons.volume_up_outlined,
            label: 'கேளுங்கள்',
            onTap: onSpeakTap,
          ),

          // Copy
          _ActionButton(
            icon: Icons.copy_outlined,
            label: 'நகலெடு',
            onTap: () {
              Clipboard.setData(ClipboardData(text: _stripMarkdown(content)));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('நகலெடுக்கப்பட்டது'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),

          // Share
          _ActionButton(
            icon: Icons.share_outlined,
            label: 'பகிர்',
            onTap: () {
              Share.share(_stripMarkdown(content));
            },
          ),

          // Ask more (if model ready)
          if (modelReady)
            _ActionButton(
              icon: Icons.chat_bubble_outline,
              label: 'மேலும்',
              onTap: onAskMoreTap,
            ),
        ],
      ),
    );
  }

  Widget _buildAiPrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            VazhiTheme.primaryColor.withValues(alpha: 0.1),
            VazhiTheme.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: VazhiTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: modelReady
          ? _buildAskMorePrompt(context)
          : _buildDownloadPrompt(context),
    );
  }

  Widget _buildDownloadPrompt(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('🧠', style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ஆழமான விளக்கம் வேண்டுமா?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                'AI Brain பதிவிறக்கம் செய்யுங்கள்',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: onDownloadAiTap,
          icon: const Icon(Icons.download, size: 16),
          label: const Text('பதிவிறக்கம்'),
          style: ElevatedButton.styleFrom(
            backgroundColor: VazhiTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAskMorePrompt(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('💡', style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'இதைப் பற்றி மேலும் கேளுங்கள்!',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onAskMoreTap,
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const Text('AI உடன் கேளுங்கள்'),
          style: OutlinedButton.styleFrom(
            foregroundColor: VazhiTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  String _getCategoryIcon(KnowledgeCategory category) {
    switch (category) {
      case KnowledgeCategory.thirukkural:
        return '📜';
      case KnowledgeCategory.schemes:
        return '🏛️';
      case KnowledgeCategory.emergency:
        return '🚨';
      case KnowledgeCategory.health:
        return '🏥';
      case KnowledgeCategory.festivals:
        return '🎉';
      case KnowledgeCategory.siddhars:
        return '🙏';
      case KnowledgeCategory.safety:
        return '🛡️';
      case KnowledgeCategory.general:
        return '📚';
    }
  }

  Color _getCategoryColor(KnowledgeCategory category) {
    switch (category) {
      case KnowledgeCategory.thirukkural:
        return const Color(0xFFFF6B35);
      case KnowledgeCategory.schemes:
        return const Color(0xFF1E3A5F);
      case KnowledgeCategory.emergency:
        return Colors.red;
      case KnowledgeCategory.health:
        return const Color(0xFF20B2AA);
      case KnowledgeCategory.festivals:
        return Colors.purple;
      case KnowledgeCategory.siddhars:
        return Colors.orange;
      case KnowledgeCategory.safety:
        return const Color(0xFF4682B4);
      case KnowledgeCategory.general:
        return Colors.grey;
    }
  }

  MarkdownStyleSheet _markdownStyleSheet(BuildContext context) {
    return MarkdownStyleSheet(
      p: const TextStyle(fontSize: 15, height: 1.6),
      h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      strong: const TextStyle(fontWeight: FontWeight.bold),
      blockquote: TextStyle(
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
      code: TextStyle(
        backgroundColor: Colors.grey[100],
        fontFamily: 'monospace',
      ),
      listBullet: const TextStyle(fontSize: 14),
    );
  }

  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'\1')
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'\1')
        .replaceAll(RegExp(r'#+\s*'), '')
        .replaceAll(RegExp(r'---+'), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'\1')
        .trim();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
