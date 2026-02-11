/// Hybrid Chat Provider
///
/// Manages hybrid chat flow: tries deterministic retrieval first,
/// falls back to AI when needed.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/query_result.dart';
import '../services/retrieval/knowledge_service.dart';
import '../services/vazhi_api_service.dart';
import '../services/vazhi_local_service.dart';
import 'chat_provider.dart';
import 'knowledge_service_provider.dart';

/// Extended message with knowledge response
class HybridMessage extends Message {
  final KnowledgeResponse? knowledgeResponse;
  final bool isFromKnowledge;
  final bool aiEnhancementAvailable;

  HybridMessage._({
    required super.id,
    required super.role,
    required super.content,
    required super.timestamp,
    super.pack,
    super.error,
    super.isLoading,
    this.knowledgeResponse,
    this.isFromKnowledge = false,
    this.aiEnhancementAvailable = false,
  });

  /// Create from regular message
  factory HybridMessage.fromMessage(Message message) {
    return HybridMessage._(
      id: message.id,
      role: message.role,
      content: message.content,
      timestamp: message.timestamp,
      pack: message.pack,
      error: message.error,
      isLoading: message.isLoading,
    );
  }

  /// Create user message
  factory HybridMessage.user(String content) {
    final base = Message.user(content);
    return HybridMessage.fromMessage(base);
  }

  /// Create loading message
  factory HybridMessage.loading() {
    final base = Message.loading();
    return HybridMessage.fromMessage(base);
  }

  /// Create knowledge-based response
  factory HybridMessage.knowledge(KnowledgeResponse response, {String? pack}) {
    return HybridMessage._(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: response.formattedResponse ?? '',
      timestamp: DateTime.now(),
      pack: pack,
      knowledgeResponse: response,
      isFromKnowledge: true,
      aiEnhancementAvailable: response.suggestAiEnhancement,
    );
  }

  /// Create AI response
  factory HybridMessage.ai(String content, {String? pack}) {
    return HybridMessage._(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      pack: pack,
      isFromKnowledge: false,
    );
  }

  /// Create error message
  factory HybridMessage.error(String errorMessage) {
    return HybridMessage._(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      error: errorMessage,
    );
  }
}

/// Hybrid chat state notifier
class HybridChatNotifier extends StateNotifier<List<HybridMessage>> {
  final KnowledgeService _knowledgeService;
  final VazhiApiService _apiService;
  final VazhiLocalService _localService;
  final Ref _ref;

  HybridChatNotifier(
    this._knowledgeService,
    this._apiService,
    this._localService,
    this._ref,
  ) : super([]);

  /// Map KnowledgeCategory to pack ID for auto-switching the pack selector
  static String _categoryToPackId(KnowledgeCategory category) {
    switch (category) {
      case KnowledgeCategory.thirukkural:
      case KnowledgeCategory.siddhars:
      case KnowledgeCategory.festivals:
        return 'culture';
      case KnowledgeCategory.schemes:
        return 'govt';
      case KnowledgeCategory.emergency:
      case KnowledgeCategory.health:
      case KnowledgeCategory.siddhaMedicine:
        return 'health';
      case KnowledgeCategory.safety:
        return 'security';
      case KnowledgeCategory.education:
        return 'education';
      case KnowledgeCategory.legal:
        return 'legal';
      case KnowledgeCategory.general:
        return 'culture'; // Default fallback
    }
  }

  /// Send a message with hybrid handling
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = HybridMessage.user(text);
    state = [...state, userMessage];

    // Add loading placeholder
    final loadingMessage = HybridMessage.loading();
    state = [...state, loadingMessage];

    try {
      // First, try knowledge service
      final knowledgeResponse = await _knowledgeService.query(text);

      // Auto-switch pack selector to match the response category
      final matchedPack = _categoryToPackId(
        knowledgeResponse.classification.category,
      );
      _ref.read(currentPackProvider.notifier).state = matchedPack;

      if (knowledgeResponse.answeredDeterministically &&
          knowledgeResponse.hasResponse) {
        // We have a deterministic answer
        state = [
          ...state.where((m) => m.id != loadingMessage.id),
          HybridMessage.knowledge(knowledgeResponse, pack: matchedPack),
        ];
        return;
      }

      // Check if AI is needed and available
      final modelStatus = _ref.read(modelManagerProvider);
      final inferenceMode = _ref.read(inferenceModeProvider);

      if (knowledgeResponse.classification.type == QueryType.aiRequired ||
          (knowledgeResponse.classification.type == QueryType.hybrid &&
              !knowledgeResponse.hasResponse)) {
        // AI is needed
        if (modelStatus == ModelStatus.ready &&
            inferenceMode == InferenceMode.local) {
          // Use local AI
          final aiResponse = await _localService.chat(text, pack: matchedPack);
          state = [
            ...state.where((m) => m.id != loadingMessage.id),
            HybridMessage.ai(aiResponse, pack: matchedPack),
          ];
        } else if (inferenceMode == InferenceMode.cloud) {
          // Use cloud API
          final aiResponse = await _apiService.chat(text, pack: matchedPack);
          state = [
            ...state.where((m) => m.id != loadingMessage.id),
            HybridMessage.ai(aiResponse, pack: matchedPack),
          ];
        } else {
          // No AI available, show knowledge result with download prompt
          // or show "AI required" message
          if (knowledgeResponse.hasResponse) {
            state = [
              ...state.where((m) => m.id != loadingMessage.id),
              HybridMessage.knowledge(knowledgeResponse, pack: matchedPack),
            ];
          } else {
            state = [
              ...state.where((m) => m.id != loadingMessage.id),
              HybridMessage.error(
                'இந்த கேள்விக்கு AI தேவை. AI Brain பதிவிறக்கம் செய்யுங்கள்.',
              ),
            ];
          }
        }
      } else {
        // Hybrid or fallback - show what we have
        if (knowledgeResponse.hasResponse) {
          state = [
            ...state.where((m) => m.id != loadingMessage.id),
            HybridMessage.knowledge(knowledgeResponse, pack: matchedPack),
          ];
        } else {
          // Try AI as fallback
          await _tryAiFallback(text, matchedPack, loadingMessage);
        }
      }
    } catch (e) {
      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        HybridMessage.error('பிழை: $e'),
      ];
    }
  }

  /// Try AI as fallback when knowledge service fails
  Future<void> _tryAiFallback(
    String text,
    String pack,
    HybridMessage loadingMessage,
  ) async {
    final modelStatus = _ref.read(modelManagerProvider);
    final inferenceMode = _ref.read(inferenceModeProvider);

    if (modelStatus == ModelStatus.ready &&
        inferenceMode == InferenceMode.local) {
      final aiResponse = await _localService.chat(text, pack: pack);
      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        HybridMessage.ai(aiResponse, pack: pack),
      ];
    } else if (inferenceMode == InferenceMode.cloud) {
      final aiResponse = await _apiService.chat(text, pack: pack);
      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        HybridMessage.ai(aiResponse, pack: pack),
      ];
    } else {
      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        HybridMessage.error(
          'தகவல் கிடைக்கவில்லை. AI Brain பதிவிறக்கம் செய்யுங்கள்.',
        ),
      ];
    }
  }

  /// Enhance a knowledge response with AI
  Future<void> enhanceWithAi(HybridMessage message) async {
    if (message.knowledgeResponse == null) return;

    // Get the AI prompt
    final prompt =
        message.knowledgeResponse!.aiPromptSuggestion ??
        'விளக்கம் தாருங்கள்: ${message.content}';

    // Add loading
    final loadingMessage = HybridMessage.loading();
    state = [...state, loadingMessage];

    try {
      final modelStatus = _ref.read(modelManagerProvider);
      final inferenceMode = _ref.read(inferenceModeProvider);
      final pack = _ref.read(currentPackProvider);

      String aiResponse;
      if (modelStatus == ModelStatus.ready &&
          inferenceMode == InferenceMode.local) {
        aiResponse = await _localService.chat(prompt, pack: pack);
      } else if (inferenceMode == InferenceMode.cloud) {
        aiResponse = await _apiService.chat(prompt, pack: pack);
      } else {
        state = [
          ...state.where((m) => m.id != loadingMessage.id),
          HybridMessage.error('AI கிடைக்கவில்லை'),
        ];
        return;
      }

      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        HybridMessage.ai(aiResponse, pack: pack),
      ];
    } catch (e) {
      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        HybridMessage.error('AI பிழை: $e'),
      ];
    }
  }

  /// Clear chat
  void clearChat() {
    state = [];
    final mode = _ref.read(inferenceModeProvider);
    if (mode == InferenceMode.local) {
      _localService.clearSession();
    }
  }
}

/// Hybrid chat provider
final hybridChatProvider =
    StateNotifierProvider<HybridChatNotifier, List<HybridMessage>>((ref) {
      final knowledgeService = ref.watch(knowledgeServiceProvider);
      final apiService = ref.watch(vazhiApiServiceProvider);
      final localService = ref.watch(vazhiLocalServiceProvider);
      return HybridChatNotifier(
        knowledgeService,
        apiService,
        localService,
        ref,
      );
    });

/// Check if model is ready for AI queries
final isModelReadyProvider = Provider<bool>((ref) {
  final status = ref.watch(modelManagerProvider);
  return status == ModelStatus.ready;
});

/// Check if any AI is available (local or cloud)
final isAiAvailableProvider = Provider<bool>((ref) {
  final status = ref.watch(modelManagerProvider);
  final mode = ref.watch(inferenceModeProvider);
  return status == ModelStatus.ready || mode == InferenceMode.cloud;
});
