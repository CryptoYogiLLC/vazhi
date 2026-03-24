/// Knowledge Result Card
///
/// Displays deterministic results from SQLite knowledge base.
/// Shows formatted content with actions and optional AI enhancement prompt.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../models/query_result.dart';
import '../services/retrieval/knowledge_service.dart';
import 'settings_drawer.dart';

class KnowledgeResultCard extends ConsumerStatefulWidget {
  final KnowledgeResponse response;
  final VoidCallback? onDownloadAiTap;
  final VoidCallback? onAskMoreTap;
  final VoidCallback? onSpeakTap;
  final void Function(String query)? onInternalLink;
  final bool showAiPrompt;
  final bool modelReady;

  const KnowledgeResultCard({
    super.key,
    required this.response,
    this.onDownloadAiTap,
    this.onAskMoreTap,
    this.onSpeakTap,
    this.onInternalLink,
    this.showAiPrompt = true,
    this.modelReady = false,
  });

  @override
  ConsumerState<KnowledgeResultCard> createState() =>
      _KnowledgeResultCardState();
}

class _KnowledgeResultCardState extends ConsumerState<KnowledgeResultCard> {
  @override
  Widget build(BuildContext context) {
    final isTamil = ref.watch(languageProvider);
    String t(String en, String ta) => isTamil ? ta : en;
    final category = widget.response.classification.category;
    final formattedResponse = widget.response.formattedResponse ?? '';

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
          _buildHeader(context, category, t),

          // Content — collapsible
          _buildContent(context, formattedResponse, t),

          // Action buttons
          _buildActions(context, formattedResponse, t),

          // AI enhancement prompt (if applicable)
          if (widget.showAiPrompt && widget.response.suggestAiEnhancement)
            _buildAiPrompt(context, t),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String formattedResponse,
    String Function(String, String) t,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MarkdownBody(
        data: formattedResponse,
        styleSheet: _markdownStyleSheet(context),
        selectable: false,
        onTapLink: (text, href, title) => _handleLinkTap(context, href),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    KnowledgeCategory category,
    String Function(String, String) t,
  ) {
    final icon = _getCategoryIcon(category);
    final name = t(_getCategoryNameEnglish(category), category.nameTamil);
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
                if (widget.response.result?.displayTitle != null)
                  Text(
                    widget.response.result!.displayTitle!,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  t('Trusted data', 'நம்பகமான தரவு'),
                  style: const TextStyle(
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

  Widget _buildActions(
    BuildContext context,
    String content,
    String Function(String, String) t,
  ) {
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
            label: t('Listen', 'கேளுங்கள்'),
            onTap: widget.onSpeakTap,
          ),

          // Copy
          _ActionButton(
            icon: Icons.copy_outlined,
            label: t('Copy', 'நகலெடு'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: _stripMarkdown(content)));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t('Copied', 'நகலெடுக்கப்பட்டது')),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          // Share
          _ActionButton(
            icon: Icons.share_outlined,
            label: t('Share', 'பகிர்'),
            onTap: () {
              Share.share(_stripMarkdown(content));
            },
          ),

          // Ask more (if model ready)
          if (widget.modelReady)
            _ActionButton(
              icon: Icons.chat_bubble_outline,
              label: t('More', 'மேலும்'),
              onTap: widget.onAskMoreTap,
            ),
        ],
      ),
    );
  }

  Widget _buildAiPrompt(
    BuildContext context,
    String Function(String, String) t,
  ) {
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
      child: widget.modelReady
          ? _buildAskMorePrompt(context, t)
          : _buildDownloadPrompt(context, t),
    );
  }

  Widget _buildDownloadPrompt(
    BuildContext context,
    String Function(String, String) t,
  ) {
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
              Text(
                t('Want deeper explanation?', 'ஆழமான விளக்கம் வேண்டுமா?'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                t('Download AI Shakthi', 'AI சக்தி பதிவிறக்கம் செய்யுங்கள்'),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: widget.onDownloadAiTap,
          icon: const Icon(Icons.download, size: 16),
          label: Text(t('Download', 'பதிவிறக்கம்')),
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

  Widget _buildAskMorePrompt(
    BuildContext context,
    String Function(String, String) t,
  ) {
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
        Expanded(
          child: Text(
            t('Ask more about this!', 'இதைப் பற்றி மேலும் கேளுங்கள்!'),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
        OutlinedButton.icon(
          onPressed: widget.onAskMoreTap,
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: Text(t('Ask AI', 'AI உடன் கேளுங்கள்')),
          style: OutlinedButton.styleFrom(
            foregroundColor: VazhiTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _handleLinkTap(BuildContext context, String? href) {
    if (href == null || href.isEmpty) return;

    // Internal navigation links — "vazhi:type/id"
    if (href.startsWith('vazhi:')) {
      final path = href.substring(6); // Strip "vazhi:" prefix
      // Convert URL paths to queries: "athikaram/5" → "அதிகாரம் 5"
      //                                "kural/42" → "குறள் 42"
      //                                "thirukkural" → "Thirukkural"
      String query;
      if (path.startsWith('athikaram/')) {
        query = 'அதிகாரம் ${path.substring(10)}';
      } else if (path.startsWith('kural/')) {
        query = 'குறள் ${path.substring(6)}';
      } else if (path == 'thirukkural') {
        query = 'Thirukkural';
      } else {
        query = path;
      }
      if (query.isNotEmpty) {
        widget.onInternalLink?.call(query);
      }
      return;
    }

    final uri = Uri.tryParse(href);
    if (uri == null) return;
    if (uri.scheme != 'https' && uri.scheme != 'http') return;
    launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('இணைப்பைத் திறக்க முடியவில்லை')),
        );
      }
      return false;
    });
  }

  String _getCategoryNameEnglish(KnowledgeCategory category) {
    switch (category) {
      case KnowledgeCategory.thirukkural:
        return 'Thirukkural';
      case KnowledgeCategory.schemes:
        return 'Government';
      case KnowledgeCategory.emergency:
        return 'Emergency';
      case KnowledgeCategory.health:
        return 'Healthcare';
      case KnowledgeCategory.festivals:
        return 'Festivals';
      case KnowledgeCategory.siddhars:
        return 'Siddhars';
      case KnowledgeCategory.safety:
        return 'Security';
      case KnowledgeCategory.education:
        return 'Education';
      case KnowledgeCategory.legal:
        return 'Legal';
      case KnowledgeCategory.siddhaMedicine:
        return 'Siddha Medicine';
      case KnowledgeCategory.general:
        return 'General';
    }
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
      case KnowledgeCategory.education:
        return '🎓';
      case KnowledgeCategory.legal:
        return '⚖️';
      case KnowledgeCategory.siddhaMedicine:
        return '🌿';
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
      case KnowledgeCategory.education:
        return const Color(0xFF2E8B57);
      case KnowledgeCategory.legal:
        return const Color(0xFF8B4513);
      case KnowledgeCategory.siddhaMedicine:
        return const Color(0xFF228B22);
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
      a: const TextStyle(
        color: Color(0xFF1565C0),
        fontSize: 15,
        decoration: TextDecoration.underline,
      ),
      blockquote: TextStyle(
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
      code: TextStyle(
        backgroundColor: Colors.grey[100],
        fontFamily: 'monospace',
      ),
      listBullet: const TextStyle(fontSize: 14),
      listBulletPadding: const EdgeInsets.only(top: 4),
      listIndent: 16,
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
