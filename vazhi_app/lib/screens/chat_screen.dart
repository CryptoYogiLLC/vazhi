/// Chat Screen - Redesigned
///
/// Clean, simple, elegant chat interface for VAZHI.
/// Now supports hybrid retrieval architecture with knowledge base.
library;


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import '../providers/hybrid_chat_provider.dart';
import '../providers/voice_provider.dart';
import '../providers/feedback_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/hybrid_message_bubble.dart';
import '../widgets/model_status_indicator.dart';
import '../widgets/chat_input.dart';
import '../widgets/rotating_suggestions.dart';
import '../widgets/settings_drawer.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showCategoryView = false;
  bool _useHybridChat = true; // Feature flag for hybrid chat
  late List<String> _shuffledCategoryIds;

  // Category card display info - using local assets for offline support
  static const List<Map<String, dynamic>> _categoryCardInfo = [
    {
      'id': 'culture',
      'icon': '🪷',
      'title': 'கலாச்சாரம்',
      'subtitle': 'Culture',
      'description': 'Thirukkural, temples, festivals',
      'color': Color(0xFFFF6B35),
      'imageAsset': 'assets/images/culture.jpg',
    },
    {
      'id': 'education',
      'icon': '📚',
      'title': 'கல்வி',
      'subtitle': 'Education',
      'description': 'Scholarships, exams, admissions',
      'color': Color(0xFF4A90D9),
      'imageAsset': 'assets/images/education.jpg',
    },
    {
      'id': 'security',
      'icon': '🛡️',
      'title': 'பாதுகாப்பு',
      'subtitle': 'Security',
      'description': 'Identify scams, cyber safety',
      'color': Color(0xFF4682B4),
      'imageAsset': 'assets/images/security.jpg',
    },
    {
      'id': 'legal',
      'icon': '⚖️',
      'title': 'சட்டம்',
      'subtitle': 'Legal',
      'description': 'RTI, consumer rights, laws',
      'color': Color(0xFF6B3FA0),
      'imageAsset': 'assets/images/legal.jpg',
    },
    {
      'id': 'govt',
      'icon': '🏛️',
      'title': 'அரசு',
      'subtitle': 'Government',
      'description': 'Schemes, services, documents',
      'color': Color(0xFF1E3A5F),
      'imageAsset': 'assets/images/govt.jpg',
    },
    {
      'id': 'health',
      'icon': '🧘',
      'title': 'சுகாதாரம்',
      'subtitle': 'Healthcare',
      'description': 'Health tips, Siddha, wellness',
      'color': Color(0xFF20B2AA),
      'imageAsset': 'assets/images/health.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Shuffle category cards on each app launch
    _shuffledCategoryIds =
        _categoryCardInfo.map((c) => c['id'] as String).toList()..shuffle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceInputStateProvider.notifier).initialize();
      ref.read(voiceOutputStateProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    if (_useHybridChat) {
      ref.read(hybridChatProvider.notifier).sendMessage(text);
    } else {
      ref.read(chatProvider.notifier).sendMessage(text);
    }
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _handleDownloadAi() {
    ref.read(modelManagerProvider.notifier).downloadModel();
  }

  void _handleEnhanceWithAi(HybridMessage message) {
    ref.read(hybridChatProvider.notifier).enhanceWithAi(message);
  }

  void _speakMessage(String text) {
    ref.read(voiceOutputStateProvider.notifier).speak(text);
  }

  void _handleSuggestionTap(String suggestion) {
    _textController.text = suggestion;
    _sendMessage(suggestion);
  }

  void _handleCategoryTap(String packId) {
    // Set the pack - this triggers the category view without sending a message
    ref.read(currentPackProvider.notifier).state = packId;
    // Navigate to category view (set a flag to show category view instead of welcome)
    setState(() {
      _showCategoryView = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use hybrid or regular chat based on feature flag
    final hybridMessages = _useHybridChat
        ? ref.watch(hybridChatProvider)
        : <HybridMessage>[];
    final regularMessages = !_useHybridChat
        ? ref.watch(chatProvider)
        : <Message>[];
    final messages = _useHybridChat ? hybridMessages : regularMessages;
    final voiceInputState = ref.watch(voiceInputStateProvider);

    if (_useHybridChat) {
      ref.listen(hybridChatProvider, (_, __) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      });
    } else {
      ref.listen(chatProvider, (_, __) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      });
    }

    ref.listen(voiceInputStateProvider, (previous, current) {
      if (current.recognizedText.isNotEmpty &&
          current.recognizedText != previous?.recognizedText) {
        _textController.text = current.recognizedText;
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: VazhiTheme.backgroundColor,
      drawer: const SettingsDrawer(),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages, Category View, or Welcome View
          Expanded(
            child: messages.isNotEmpty
                ? _useHybridChat
                      ? _buildHybridChatView(hybridMessages)
                      : _buildChatView(regularMessages)
                : _showCategoryView
                ? _buildCategoryOnlyView()
                : _buildWelcomeView(),
          ),

          // Input area
          _buildInputArea(voiceInputState),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final hasMessages = _useHybridChat
        ? ref.watch(hybridChatProvider).isNotEmpty
        : ref.watch(chatProvider).isNotEmpty;
    final showBack = hasMessages || _showCategoryView;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: VazhiTheme.textPrimary),
              onPressed: () {
                // Clear chat and go back to homepage
                if (_useHybridChat) {
                  ref.read(hybridChatProvider.notifier).clearChat();
                } else {
                  ref.read(chatProvider.notifier).clearChat();
                }
                setState(() {
                  _showCategoryView = false;
                });
              },
            )
          : IconButton(
              icon: const Icon(Icons.menu, color: VazhiTheme.textPrimary),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/vazhi_logo_white.jpg',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: VazhiTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'வ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'VAZHI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: VazhiTheme.textPrimary,
                  letterSpacing: 1.5,
                ),
              ),
              // VAZHI acronym with bold first letters
              _buildAcronymText(),
            ],
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (hasMessages)
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: VazhiTheme.textSecondary,
            ),
            onPressed: () => _showClearChatDialog(),
          ),
        if (!showBack)
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: VazhiTheme.textSecondary,
            ),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
      ],
    );
  }

  Widget _buildAcronymText() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 8,
          color: VazhiTheme.textSecondary,
          letterSpacing: 0.2,
        ),
        children: [
          TextSpan(
            text: 'V',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: VazhiTheme.primaryColor,
            ),
          ),
          const TextSpan(text: 'oluntary '),
          TextSpan(
            text: 'A',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: VazhiTheme.primaryColor,
            ),
          ),
          const TextSpan(text: 'I with '),
          TextSpan(
            text: 'Z',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: VazhiTheme.primaryColor,
            ),
          ),
          const TextSpan(text: 'ero-cost '),
          TextSpan(
            text: 'H',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: VazhiTheme.primaryColor,
            ),
          ),
          const TextSpan(text: 'elpful '),
          TextSpan(
            text: 'I',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: VazhiTheme.primaryColor,
            ),
          ),
          const TextSpan(text: 'ntelligence'),
        ],
      ),
    );
  }

  Widget _buildWelcomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Large centered logo
          Center(
            child: Column(
              children: [
                // Big logo image - logo already contains VAZHI வழி text
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/vazhi_logo_white.jpg',
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: VazhiTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Center(
                        child: Text(
                          'வழி',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Acronym with bold letters
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: VazhiTheme.textSecondary,
                      letterSpacing: 0.3,
                    ),
                    children: [
                      TextSpan(
                        text: 'V',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: VazhiTheme.primaryColor,
                        ),
                      ),
                      const TextSpan(text: 'oluntary '),
                      TextSpan(
                        text: 'A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: VazhiTheme.primaryColor,
                        ),
                      ),
                      const TextSpan(text: 'I with '),
                      TextSpan(
                        text: 'Z',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: VazhiTheme.primaryColor,
                        ),
                      ),
                      const TextSpan(text: 'ero-cost '),
                      TextSpan(
                        text: 'H',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: VazhiTheme.primaryColor,
                        ),
                      ),
                      const TextSpan(text: 'elpful '),
                      TextSpan(
                        text: 'I',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: VazhiTheme.primaryColor,
                        ),
                      ),
                      const TextSpan(text: 'ntelligence'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // About VAZHI Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [VazhiTheme.secondaryColor, VazhiTheme.secondaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: VazhiTheme.goldAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '100% FREE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '📴 Works Offline',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'VAZHI வழி',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A free Tamil AI assistant for Tamilians worldwide. Ask questions about government schemes, legal rights, health, education, culture & identify scams - all in Tamil or Tanglish.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'தமிழர்களுக்கான இலவச AI வழி தோழன்',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section title
          const Text(
            'How can I help you?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VazhiTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'நான் எப்படி உதவ முடியும்?',
            style: TextStyle(fontSize: 13, color: VazhiTheme.textSecondary),
          ),

          const SizedBox(height: 12),

          // Category Cards Grid - randomized order
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: _buildShuffledCategoryCards(),
          ),

          const SizedBox(height: 20),

          // Quick suggestions
          QuickSuggestionChips(onTap: _handleSuggestionTap),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildShuffledCategoryCards() {
    return _shuffledCategoryIds.map((id) {
      final info = _categoryCardInfo.firstWhere((c) => c['id'] == id);
      return _buildCategoryCard(
        icon: info['icon'] as String,
        title: info['title'] as String,
        subtitle: info['subtitle'] as String,
        description: info['description'] as String,
        color: info['color'] as Color,
        imageAsset: info['imageAsset'] as String,
        onTap: () => _handleCategoryTap(id),
      );
    }).toList();
  }

  Widget _buildCategoryCard({
    required String icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
    String? imageAsset,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Base gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Background image with fade from top-right - more prominent
            if (imageAsset != null)
              Positioned(
                top: -15,
                right: -15,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.white.withValues(alpha: 0.7),
                        Colors.white.withValues(alpha: 0.45),
                        Colors.white.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.35, 0.65, 0.95],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    imageAsset,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 24)),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView(List<dynamic> messages) {
    final currentPack = ref.watch(currentPackProvider);
    final packs = ref.watch(availablePacksProvider);
    final packInfo = packs.firstWhere(
      (p) => p.id == currentPack,
      orElse: () => packs.first,
    );
    final feedbackState = ref.watch(feedbackProvider);

    return Column(
      children: [
        // Category banner at top
        _buildCategoryBanner(packInfo),
        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index] as Message;
              final isAssistant = message.role == MessageRole.assistant;

              // Find the user question that this response answers
              String? userQuestion;
              if (isAssistant && index > 0) {
                final prevMessage = messages[index - 1] as Message;
                if (prevMessage.role == MessageRole.user) {
                  userQuestion = prevMessage.content;
                }
              }

              return MessageBubble(
                message: message,
                userQuestion: userQuestion,
                onSpeak:
                    isAssistant && !message.isLoading && message.error == null
                    ? () => _speakMessage(message.content)
                    : null,
                onRetry: message.error != null
                    ? () => ref.read(chatProvider.notifier).retryLast()
                    : null,
                currentFeedback: feedbackState.getFeedbackForMessage(
                  message.id,
                ),
                onPositiveFeedback:
                    isAssistant && !message.isLoading && message.error == null
                    ? () => _handlePositiveFeedback(message, userQuestion)
                    : null,
                onNegativeFeedback:
                    isAssistant && !message.isLoading && message.error == null
                    ? () => _handleNegativeFeedback(message, userQuestion)
                    : null,
                onCorrection:
                    isAssistant && !message.isLoading && message.error == null
                    ? (correction) =>
                          _handleCorrection(message, userQuestion, correction)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Hybrid chat view that uses knowledge base + AI
  Widget _buildHybridChatView(List<HybridMessage> messages) {
    final currentPack = ref.watch(currentPackProvider);
    final packs = ref.watch(availablePacksProvider);
    final packInfo = packs.firstWhere(
      (p) => p.id == currentPack,
      orElse: () => packs.first,
    );
    final modelStatus = ref.watch(modelManagerProvider);

    return Column(
      children: [
        // Category banner at top
        _buildCategoryBanner(packInfo),

        // Model status indicator (compact, shown only if not ready)
        if (modelStatus != ModelStatus.ready)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ModelStatusIndicator(
              compact: true,
              onTap: modelStatus == ModelStatus.notDownloaded
                  ? _handleDownloadAi
                  : null,
            ),
          ),

        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];

              return HybridMessageBubble(
                message: message,
                onSpeak:
                    message.role == MessageRole.assistant &&
                        !message.isLoading &&
                        message.error == null
                    ? () => _speakMessage(message.content)
                    : null,
                onDownloadAi: _handleDownloadAi,
                onEnhanceWithAi: _handleEnhanceWithAi,
              );
            },
          ),
        ),
      ],
    );
  }

  void _handlePositiveFeedback(Message message, String? userQuestion) {
    ref
        .read(feedbackProvider.notifier)
        .addPositive(
          messageId: message.id,
          question: userQuestion ?? '',
          modelResponse: message.content,
          pack: message.pack,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('நன்றி! 👍'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleNegativeFeedback(Message message, String? userQuestion) {
    ref
        .read(feedbackProvider.notifier)
        .addNegative(
          messageId: message.id,
          question: userQuestion ?? '',
          modelResponse: message.content,
          pack: message.pack,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thanks for the feedback 👎'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleCorrection(
    Message message,
    String? userQuestion,
    String correction,
  ) {
    ref
        .read(feedbackProvider.notifier)
        .addCorrection(
          messageId: message.id,
          question: userQuestion ?? '',
          modelResponse: message.content,
          correction: correction,
          pack: message.pack,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('திருத்தம் சமர்ப்பிக்கப்பட்டது! 🙏'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Category data map for consistent use across the app - using local assets
  static final Map<String, Map<String, dynamic>> _categoryData = {
    'culture': {
      'color': const Color(0xFFFF6B35),
      'imageAsset': 'assets/images/culture.jpg',
      'subtitle': 'Tamil Culture & Heritage',
      'icon': '🪷',
      'suggestions': [
        'திருக்குறளின் முதல் குறள் என்ன?',
        'தமிழ் புத்தாண்டு எப்போது?',
        'சித்தர்கள் யார்?',
        'பொங்கல் பண்டிகை பற்றி சொல்லுங்கள்',
      ],
    },
    'education': {
      'color': const Color(0xFF4A90D9),
      'imageAsset': 'assets/images/education.jpg',
      'subtitle': 'Education & Learning',
      'icon': '📚',
      'suggestions': [
        'NEET exam-க்கு எப்படி prepare பண்றது?',
        'TN அரசு உதவித்தொகை எப்படி விண்ணப்பிப்பது?',
        'IIT-க்கு தகுதி என்ன?',
        'Plus 2 முடித்தபின் என்ன படிக்கலாம்?',
      ],
    },
    'security': {
      'color': const Color(0xFF4682B4),
      'imageAsset': 'assets/images/security.jpg',
      'subtitle': 'Cyber Safety & Scam Prevention',
      'icon': '🛡️',
      'suggestions': [
        'OTP scam-ஐ எப்படி கண்டறிவது?',
        'Online fraud-ஐ எப்படி தடுப்பது?',
        'UPI மோசடி பற்றி சொல்லுங்கள்',
        'Phishing email-ஐ எப்படி அடையாளம் காண்பது?',
      ],
    },
    'legal': {
      'color': const Color(0xFF6B3FA0),
      'imageAsset': 'assets/images/legal.jpg',
      'subtitle': 'Legal Rights & RTI',
      'icon': '⚖️',
      'suggestions': [
        'RTI எப்படி file பண்றது?',
        'Consumer complaint எப்படி கொடுப்பது?',
        'FIR எப்படி போடுவது?',
        'வாடகை உரிமைகள் என்ன?',
      ],
    },
    'govt': {
      'color': const Color(0xFF1E3A5F),
      'imageAsset': 'assets/images/govt.jpg',
      'subtitle': 'Government Schemes & Services',
      'icon': '🏛️',
      'suggestions': [
        'PM Kisan scheme பற்றி சொல்லுங்கள்',
        'Aadhaar card-ஐ எப்படி update பண்றது?',
        'Ration card எப்படி பெறுவது?',
        'பிறப்பு சான்றிதழ் எப்படி பெறுவது?',
      ],
    },
    'health': {
      'color': const Color(0xFF20B2AA),
      'imageAsset': 'assets/images/health.jpg',
      'subtitle': 'Healthcare & Wellness',
      'icon': '🧘',
      'suggestions': [
        'சித்த மருத்துவம் என்றால் என்ன?',
        'நீரிழிவு நோய்க்கு இயற்கை மருத்துவம்',
        'Ayushman Bharat-ல் சேர்வது எப்படி?',
        'யோகா பயிற்சிகள் என்ன?',
      ],
    },
  };

  Widget _buildCategoryBanner(PackInfo packInfo) {
    final data = _categoryData[packInfo.id] ?? _categoryData['culture']!;
    final color = data['color'] as Color;
    final imageAsset = data['imageAsset'] as String;
    final subtitle = data['subtitle'] as String;
    final icon = data['icon'] as String;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      height: 70,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image - local asset for offline support
          Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: color),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.75)],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      packInfo.nameTamil,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOnlyView() {
    final currentPack = ref.watch(currentPackProvider);
    final packs = ref.watch(availablePacksProvider);
    final packInfo = packs.firstWhere(
      (p) => p.id == currentPack,
      orElse: () => packs.first,
    );
    final data = _categoryData[packInfo.id] ?? _categoryData['culture']!;
    final suggestions = data['suggestions'] as List<String>;
    final color = data['color'] as Color;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category banner
          _buildCategoryBanner(packInfo),

          const SizedBox(height: 16),

          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Try asking...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: VazhiTheme.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Horizontal scrolling suggestion cards
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 220,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 4 : 8,
                    right: index == suggestions.length - 1 ? 4 : 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleSuggestionTap(suggestions[index]),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                suggestions[index],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: VazhiTheme.textPrimary,
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: color,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Prompt text
          Center(
            child: Text(
              'Or type your own question below',
              style: TextStyle(
                fontSize: 13,
                color: VazhiTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(dynamic voiceInputState) {
    return ChatInput(
      controller: _textController,
      onSend: _sendMessage,
      isListening: voiceInputState.isListening,
      onMicPressed: () {
        if (voiceInputState.isListening) {
          ref.read(voiceInputStateProvider.notifier).stopListening();
        } else {
          ref.read(voiceInputStateProvider.notifier).startListening();
        }
      },
      voiceAvailable: voiceInputState.isAvailable,
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Chat?'),
        content: const Text(
          'This will delete all messages in this conversation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_useHybridChat) {
                ref.read(hybridChatProvider.notifier).clearChat();
              } else {
                ref.read(chatProvider.notifier).clearChat();
              }
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
