/// Hybrid Chat Provider
///
/// Manages hybrid chat flow: tries deterministic retrieval first,
/// falls back to AI when needed.
library;

import 'dart:async';
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

  /// Wait for model to become ready if it's currently loading.
  /// Returns true if AI became available, false if timed out or not loading.
  Future<bool> _waitForModelIfLoading() async {
    final status = _ref.read(modelManagerProvider);
    if (status == ModelStatus.ready) return true;
    if (status != ModelStatus.loading && status != ModelStatus.downloaded) {
      return false;
    }

    // Model is loading — poll until ready (max 30s)
    for (var i = 0; i < 60; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      final current = _ref.read(modelManagerProvider);
      if (current == ModelStatus.ready) return true;
      if (current == ModelStatus.error ||
          current == ModelStatus.notDownloaded) {
        return false;
      }
    }
    return false;
  }

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
      // First, try knowledge service for classification and lookup
      final knowledgeResponse = await _knowledgeService.query(text);

      var modelStatus = _ref.read(modelManagerProvider);
      final inferenceMode = _ref.read(inferenceModeProvider);
      var aiReady =
          (modelStatus == ModelStatus.ready &&
              inferenceMode == InferenceMode.local) ||
          inferenceMode == InferenceMode.cloud;

      // If model is still loading, wait for it instead of falling back
      if (!aiReady && inferenceMode == InferenceMode.local) {
        final becameReady = await _waitForModelIfLoading();
        if (becameReady) {
          modelStatus = ModelStatus.ready;
          aiReady = true;
        }
      }

      // Pack switching logic:
      // - No AI or first message: auto-switch freely
      // - Active AI conversation: only switch when user explicitly asks
      //   about a DIFFERENT specific topic (not vague follow-ups)
      final detectedCategory = knowledgeResponse.classification.category;
      final detectedPack = _categoryToPackId(detectedCategory);
      final currentPack = _ref.read(currentPackProvider);
      final hasHistory =
          state.where((m) => m.role == MessageRole.user).length > 1;
      final isSpecificNewTopic =
          detectedCategory != KnowledgeCategory.general &&
          detectedPack != currentPack;

      if (!aiReady || !hasHistory || isSpecificNewTopic) {
        _ref.read(currentPackProvider.notifier).state = detectedPack;
      }
      final matchedPack = _ref.read(currentPackProvider);

      // RAG flow: SQLite provides factual context, AI generates response.
      // Exact lookups (Thirukkural by number, emergency contacts) bypass AI.
      if (aiReady) {
        final isExactLookup =
            knowledgeResponse.answeredDeterministically &&
            knowledgeResponse.hasResponse &&
            !knowledgeResponse.suggestAiEnhancement &&
            (knowledgeResponse.classification.category ==
                    KnowledgeCategory.thirukkural ||
                knowledgeResponse.classification.category ==
                    KnowledgeCategory.emergency);

        if (isExactLookup) {
          state = [
            ...state.where((m) => m.id != loadingMessage.id),
            HybridMessage.knowledge(knowledgeResponse, pack: matchedPack),
          ];
          return;
        }

        // RAG: if SQLite has relevant context, inject it into the AI prompt
        final context = knowledgeResponse.hasResponse
            ? knowledgeResponse.formattedResponse
            : null;
        await _tryAiWithContext(text, matchedPack, loadingMessage, context);
      } else {
        // No AI available — use deterministic answers when possible
        if (knowledgeResponse.answeredDeterministically &&
            knowledgeResponse.hasResponse) {
          state = [
            ...state.where((m) => m.id != loadingMessage.id),
            HybridMessage.knowledge(knowledgeResponse, pack: matchedPack),
          ];
        } else if (knowledgeResponse.hasResponse) {
          state = [
            ...state.where((m) => m.id != loadingMessage.id),
            HybridMessage.knowledge(knowledgeResponse, pack: matchedPack),
          ];
        } else {
          // Show contextual message based on model state
          final isLoading =
              modelStatus == ModelStatus.loading ||
              modelStatus == ModelStatus.downloaded;
          state = [
            ...state.where((m) => m.id != loadingMessage.id),
            HybridMessage.error(
              isLoading
                  ? 'AI மாடல் ஏற்றப்படுகிறது... சில விநாடிகள் காத்திருந்து மீண்டும் முயற்சிக்கவும்.'
                  : 'இந்த கேள்விக்கு AI தேவை. AI Brain பதிவிறக்கம் செய்யுங்கள்.',
            ),
          ];
        }
      }
    } catch (e) {
      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        HybridMessage.error('பிழை: $e'),
      ];
    }
  }

  /// Build a RAG-augmented prompt: inject SQLite context so the AI
  /// generates a grounded response instead of hallucinating.
  static String _buildRagPrompt(String userQuery, String? context) {
    if (context == null || context.isEmpty) return userQuery;

    return 'கீழே கொடுக்கப்பட்ட தகவல்களை அடிப்படையாகக் கொண்டு பதிலளியுங்கள்:\n'
        '---\n'
        '$context\n'
        '---\n\n'
        'பயனர் கேள்வி: $userQuery\n\n'
        'மேலே உள்ள தகவல்களை பயன்படுத்தி தமிழில் விளக்கமாக பதிலளியுங்கள்.';
  }

  /// Send query to AI, optionally augmented with SQLite context (RAG).
  Future<void> _tryAiWithContext(
    String text,
    String pack,
    HybridMessage loadingMessage,
    String? context,
  ) async {
    final modelStatus = _ref.read(modelManagerProvider);
    final inferenceMode = _ref.read(inferenceModeProvider);
    final prompt = _buildRagPrompt(text, context);

    if (modelStatus == ModelStatus.ready &&
        inferenceMode == InferenceMode.local) {
      final aiResponse = await _localService.chat(prompt, pack: pack);
      state = [
        ...state.where((m) => m.id != loadingMessage.id),
        HybridMessage.ai(aiResponse, pack: pack),
      ];
    } else if (inferenceMode == InferenceMode.cloud) {
      final aiResponse = await _apiService.chat(prompt, pack: pack);
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

    // Build RAG prompt with SQLite context
    final context = message.knowledgeResponse!.formattedResponse;
    final userQuery = message.knowledgeResponse!.classification.query;
    final prompt = _buildRagPrompt('விளக்கம் தாருங்கள்: $userQuery', context);

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
