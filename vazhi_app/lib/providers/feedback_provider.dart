/// Feedback Provider
///
/// Manages user feedback state and service for Riverpod.
library;


import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feedback.dart';
import '../services/feedback_service.dart';

/// Singleton feedback service
final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  final service = FeedbackService();
  // Initialize asynchronously
  service.initialize();
  return service;
});

/// State for tracking feedback per message
class FeedbackState {
  final Map<String, FeedbackType> messageFeedback;
  final bool isLoading;

  const FeedbackState({
    this.messageFeedback = const {},
    this.isLoading = false,
  });

  FeedbackState copyWith({
    Map<String, FeedbackType>? messageFeedback,
    bool? isLoading,
  }) {
    return FeedbackState(
      messageFeedback: messageFeedback ?? this.messageFeedback,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Get feedback type for a specific message
  FeedbackType? getFeedbackForMessage(String messageId) {
    return messageFeedback[messageId];
  }
}

/// Notifier for managing feedback state
class FeedbackNotifier extends StateNotifier<FeedbackState> {
  final FeedbackService _service;

  FeedbackNotifier(this._service) : super(const FeedbackState()) {
    _loadExistingFeedback();
  }

  Future<void> _loadExistingFeedback() async {
    state = state.copyWith(isLoading: true);
    await _service.initialize();

    // Build map from existing feedback
    final feedbackMap = <String, FeedbackType>{};
    for (final feedback in _service.allFeedback) {
      feedbackMap[feedback.messageId] = feedback.type;
    }

    state = state.copyWith(
      messageFeedback: feedbackMap,
      isLoading: false,
    );
  }

  /// Add positive feedback for a message
  Future<void> addPositive({
    required String messageId,
    required String question,
    required String modelResponse,
    String? pack,
  }) async {
    await _service.addPositive(
      messageId: messageId,
      question: question,
      modelResponse: modelResponse,
      pack: pack,
    );

    state = state.copyWith(
      messageFeedback: {
        ...state.messageFeedback,
        messageId: FeedbackType.positive,
      },
    );
  }

  /// Add negative feedback for a message
  Future<void> addNegative({
    required String messageId,
    required String question,
    required String modelResponse,
    String? pack,
  }) async {
    await _service.addNegative(
      messageId: messageId,
      question: question,
      modelResponse: modelResponse,
      pack: pack,
    );

    state = state.copyWith(
      messageFeedback: {
        ...state.messageFeedback,
        messageId: FeedbackType.negative,
      },
    );
  }

  /// Add correction feedback for a message
  Future<void> addCorrection({
    required String messageId,
    required String question,
    required String modelResponse,
    required String correction,
    String? pack,
  }) async {
    await _service.addCorrection(
      messageId: messageId,
      question: question,
      modelResponse: modelResponse,
      correction: correction,
      pack: pack,
    );

    state = state.copyWith(
      messageFeedback: {
        ...state.messageFeedback,
        messageId: FeedbackType.correction,
      },
    );
  }

  /// Get feedback stats
  Map<String, int> get stats => _service.stats;

  /// Export corrections for training
  String exportCorrections() => _service.exportCorrectionsForTraining();
}

/// Provider for feedback state
final feedbackProvider =
    StateNotifierProvider<FeedbackNotifier, FeedbackState>((ref) {
  final service = ref.watch(feedbackServiceProvider);
  return FeedbackNotifier(service);
});
