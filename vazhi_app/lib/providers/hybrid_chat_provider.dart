/// Hybrid Chat Provider
///
/// Manages hybrid chat flow: tries deterministic retrieval first,
/// falls back to AI when needed. Supports streaming for local inference.
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

  /// Create AI response with explicit ID (for streaming updates)
  factory HybridMessage.aiStreaming(String id, String content, {String? pack}) {
    return HybridMessage._(
      id: id,
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

/// Max RAG context characters to inject into prompt.
/// With n_ctx=256, the budget is tight:
///   ~90 tokens for system prompt + chat template
///   ~30-50 tokens for user query
///   ~60-80 tokens for generation
///   ~30-80 tokens for RAG context
/// At ~1-2 tokens/char for Tamil, 150 chars ≈ 75-150 tokens.
/// Keep conservative to avoid prompt overflow.
const _maxRagContextChars = 150;

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

  /// Replace a message by ID with a new message.
  void _replaceById(String oldId, HybridMessage replacement) {
    state = [...state.where((m) => m.id != oldId), replacement];
  }

  /// Wait for model to become ready if it's currently loading.
  /// Returns true if AI became available, false if timed out or not loading.
  Future<bool> _waitForModelIfLoading() async {
    final status = _ref.read(modelManagerProvider);
    if (status == ModelStatus.ready) return true;
    if (status != ModelStatus.loading && status != ModelStatus.downloaded) {
      return false;
    }

    // Model is loading — poll until ready (max 30s)
    // Check first, then delay — avoids unnecessary 500ms wait if model
    // became ready between the initial read and the loop entry.
    for (var i = 0; i < 60; i++) {
      final current = _ref.read(modelManagerProvider);
      if (current == ModelStatus.ready) return true;
      if (current == ModelStatus.error ||
          current == ModelStatus.notDownloaded) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 500));
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

      final modelStatus = _ref.read(modelManagerProvider);
      final inferenceMode = _ref.read(inferenceModeProvider);
      var aiReady =
          (modelStatus == ModelStatus.ready &&
              inferenceMode == InferenceMode.local) ||
          inferenceMode == InferenceMode.cloud;

      // If model is still loading, wait for it instead of falling back
      if (!aiReady && inferenceMode == InferenceMode.local) {
        aiReady = await _waitForModelIfLoading();
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
          _replaceById(
            loadingMessage.id,
            HybridMessage.knowledge(knowledgeResponse, pack: matchedPack),
          );
          return;
        }

        // RAG: if SQLite has relevant context, inject it into the AI prompt.
        // Truncate context to fit within n_ctx token budget.
        String? context = knowledgeResponse.hasResponse
            ? knowledgeResponse.formattedResponse
            : null;
        if (context != null && context.length > _maxRagContextChars) {
          context = context.substring(0, _maxRagContextChars);
        }
        await _tryAiWithContext(text, matchedPack, loadingMessage, context);
      } else {
        // No AI available — show whatever knowledge we have
        if (knowledgeResponse.hasResponse) {
          _replaceById(
            loadingMessage.id,
            HybridMessage.knowledge(knowledgeResponse, pack: matchedPack),
          );
        } else {
          // Show contextual message based on model state
          final isLoading =
              modelStatus == ModelStatus.loading ||
              modelStatus == ModelStatus.downloaded;
          _replaceById(
            loadingMessage.id,
            HybridMessage.error(
              isLoading
                  ? 'AI மாடல் ஏற்றப்படுகிறது... சில விநாடிகள் காத்திருந்து மீண்டும் முயற்சிக்கவும்.'
                  : 'இந்த கேள்விக்கு AI தேவை. AI சக்தி பதிவிறக்கம் செய்யுங்கள்.',
            ),
          );
        }
      }
    } catch (e) {
      _replaceById(loadingMessage.id, HybridMessage.error('பிழை: $e'));
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

  /// Route a prompt to local or cloud AI. Returns null if AI is unavailable.
  Future<String?> _callAi(String prompt, {required String pack}) async {
    final modelStatus = _ref.read(modelManagerProvider);
    final inferenceMode = _ref.read(inferenceModeProvider);

    if (modelStatus == ModelStatus.ready &&
        inferenceMode == InferenceMode.local) {
      return _localService.chat(prompt, pack: pack);
    }
    if (inferenceMode == InferenceMode.cloud) {
      return _apiService.chat(prompt, pack: pack);
    }
    return null;
  }

  /// Check if local streaming is available.
  bool get _canStreamLocal {
    final modelStatus = _ref.read(modelManagerProvider);
    final inferenceMode = _ref.read(inferenceModeProvider);
    return modelStatus == ModelStatus.ready &&
        inferenceMode == InferenceMode.local;
  }

  /// Send query to AI, optionally augmented with SQLite context (RAG).
  /// Uses streaming for local inference to show tokens as they generate.
  Future<void> _tryAiWithContext(
    String text,
    String pack,
    HybridMessage loadingMessage,
    String? context,
  ) async {
    final prompt = _buildRagPrompt(text, context);

    if (_canStreamLocal) {
      // Stream tokens from local model for real-time display
      await _streamLocalAi(prompt, pack, loadingMessage);
    } else {
      // Cloud mode: wait for complete response
      final aiResponse = await _callAi(prompt, pack: pack);

      if (aiResponse != null) {
        _replaceById(
          loadingMessage.id,
          HybridMessage.ai(aiResponse, pack: pack),
        );
      } else {
        _replaceById(
          loadingMessage.id,
          HybridMessage.error(
            'தகவல் கிடைக்கவில்லை. AI சக்தி பதிவிறக்கம் செய்யுங்கள்.',
          ),
        );
      }
    }
  }

  /// Stream tokens from local LLM, updating UI progressively.
  Future<void> _streamLocalAi(
    String prompt,
    String pack,
    HybridMessage loadingMessage,
  ) async {
    final streamId = 'stream_${DateTime.now().millisecondsSinceEpoch}';
    var currentReplaceId = loadingMessage.id;
    var accumulated = '';

    try {
      await for (final token in _localService.chatStream(prompt, pack: pack)) {
        accumulated += token;

        // Clean output on each update to strip leaked chat tokens
        final cleaned = VazhiLocalService.cleanOutput(accumulated);
        if (cleaned.isNotEmpty) {
          _replaceById(
            currentReplaceId,
            HybridMessage.aiStreaming(streamId, cleaned, pack: pack),
          );
          currentReplaceId = streamId;
        }
      }

      // Final clean and replace with permanent AI message
      final finalContent = VazhiLocalService.cleanOutput(accumulated);
      if (finalContent.isNotEmpty) {
        _replaceById(
          currentReplaceId,
          HybridMessage.ai(finalContent, pack: pack),
        );
      } else {
        _replaceById(
          currentReplaceId,
          HybridMessage.error('AI பதில் காலியாக உள்ளது.'),
        );
      }
    } catch (e) {
      _replaceById(currentReplaceId, HybridMessage.error('AI பிழை: $e'));
    }
  }

  /// Enhance a knowledge response with AI
  Future<void> enhanceWithAi(HybridMessage message) async {
    if (message.knowledgeResponse == null) return;

    // Build RAG prompt with SQLite context
    final context = message.knowledgeResponse!.formattedResponse;
    final userQuery = message.knowledgeResponse!.classification.query;

    // Truncate context for token budget
    String? truncatedContext = context;
    if (truncatedContext != null &&
        truncatedContext.length > _maxRagContextChars) {
      truncatedContext = truncatedContext.substring(0, _maxRagContextChars);
    }

    final prompt = _buildRagPrompt(
      'விளக்கம் தாருங்கள்: $userQuery',
      truncatedContext,
    );

    final loadingMessage = HybridMessage.loading();
    state = [...state, loadingMessage];

    try {
      final pack = _ref.read(currentPackProvider);

      if (_canStreamLocal) {
        await _streamLocalAi(prompt, pack, loadingMessage);
      } else {
        final aiResponse = await _callAi(prompt, pack: pack);

        if (aiResponse != null) {
          _replaceById(
            loadingMessage.id,
            HybridMessage.ai(aiResponse, pack: pack),
          );
        } else {
          _replaceById(
            loadingMessage.id,
            HybridMessage.error('AI கிடைக்கவில்லை'),
          );
        }
      }
    } catch (e) {
      _replaceById(loadingMessage.id, HybridMessage.error('AI பிழை: $e'));
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
