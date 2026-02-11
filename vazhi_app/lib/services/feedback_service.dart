/// Feedback Service
///
/// Handles storing user feedback locally and syncing to backend.
/// Uses encrypted Hive storage to protect user data.
library;


import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../models/feedback.dart';

class FeedbackService {
  static const String _boxName = 'vazhi_feedback';
  static const String _encryptionKeyName = 'vazhi_hive_key';

  Box? _box;
  List<UserFeedback> _feedbackList = [];
  bool _initialized = false;

  /// Get or generate encryption key for Hive
  static Future<List<int>> _getEncryptionKey() async {
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    // Try to get existing key
    final existingKey = await secureStorage.read(key: _encryptionKeyName);

    if (existingKey != null) {
      // Decode existing key
      return base64Decode(existingKey);
    }

    // Generate new key
    final newKey = Hive.generateSecureKey();
    await secureStorage.write(
      key: _encryptionKeyName,
      value: base64Encode(newKey),
    );

    return newKey;
  }

  /// Get all feedback
  List<UserFeedback> get allFeedback => List.unmodifiable(_feedbackList);

  /// Get unsynced feedback count
  int get unsyncedCount => _feedbackList.where((f) => !f.synced).length;

  /// Get feedback stats
  Map<String, int> get stats {
    int positive = 0;
    int negative = 0;
    int corrections = 0;

    for (final f in _feedbackList) {
      switch (f.type) {
        case FeedbackType.positive:
          positive++;
          break;
        case FeedbackType.negative:
          negative++;
          break;
        case FeedbackType.correction:
          corrections++;
          break;
      }
    }

    return {
      'positive': positive,
      'negative': negative,
      'corrections': corrections,
      'total': _feedbackList.length,
      'unsynced': unsyncedCount,
    };
  }

  /// Initialize service and load saved feedback
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get encryption key from secure storage
      final encryptionKey = await _getEncryptionKey();
      final cipher = HiveAesCipher(encryptionKey);

      // Open encrypted box
      _box = await Hive.openBox(
        _boxName,
        encryptionCipher: cipher,
      );
    } catch (e) {
      // Fallback to unencrypted if secure storage fails (e.g., in tests)
      if (kDebugMode) {
        debugPrint('FeedbackService: Falling back to unencrypted storage: $e');
      }
      _box = await Hive.openBox(_boxName);
    }

    final jsonString = _box?.get('feedback_list');

    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString as String);
        _feedbackList = jsonList
            .map((json) => UserFeedback.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _feedbackList = [];
      }
    }

    _initialized = true;
  }

  /// Save feedback to local storage
  Future<void> _save() async {
    if (_box == null) return;
    final jsonString = jsonEncode(_feedbackList.map((f) => f.toJson()).toList());
    await _box!.put('feedback_list', jsonString);
  }

  /// Add positive feedback
  Future<void> addPositive({
    required String messageId,
    required String question,
    required String modelResponse,
    String? pack,
  }) async {
    await initialize();

    // Check if feedback already exists for this message
    final existingIndex = _feedbackList.indexWhere((f) => f.messageId == messageId);
    if (existingIndex >= 0) {
      _feedbackList.removeAt(existingIndex);
    }

    final feedback = UserFeedback.positive(
      messageId: messageId,
      question: question,
      modelResponse: modelResponse,
      pack: pack,
    );

    _feedbackList.add(feedback);
    await _save();
  }

  /// Add negative feedback
  Future<void> addNegative({
    required String messageId,
    required String question,
    required String modelResponse,
    String? pack,
  }) async {
    await initialize();

    // Check if feedback already exists for this message
    final existingIndex = _feedbackList.indexWhere((f) => f.messageId == messageId);
    if (existingIndex >= 0) {
      _feedbackList.removeAt(existingIndex);
    }

    final feedback = UserFeedback.negative(
      messageId: messageId,
      question: question,
      modelResponse: modelResponse,
      pack: pack,
    );

    _feedbackList.add(feedback);
    await _save();
  }

  /// Add correction feedback
  Future<void> addCorrection({
    required String messageId,
    required String question,
    required String modelResponse,
    required String correction,
    String? pack,
  }) async {
    await initialize();

    // Check if feedback already exists for this message
    final existingIndex = _feedbackList.indexWhere((f) => f.messageId == messageId);
    if (existingIndex >= 0) {
      _feedbackList.removeAt(existingIndex);
    }

    final feedback = UserFeedback.correction(
      messageId: messageId,
      question: question,
      modelResponse: modelResponse,
      correction: correction,
      pack: pack,
    );

    _feedbackList.add(feedback);
    await _save();
  }

  /// Get feedback for a specific message
  UserFeedback? getFeedbackForMessage(String messageId) {
    try {
      return _feedbackList.firstWhere((f) => f.messageId == messageId);
    } catch (e) {
      return null;
    }
  }

  /// Export corrections for training (Alpaca format)
  String exportCorrectionsForTraining() {
    final corrections = _feedbackList
        .where((f) => f.type == FeedbackType.correction && f.correction != null)
        .map((f) => f.toTrainingFormat())
        .where((s) => s.isNotEmpty)
        .toList();

    return corrections.join('\n\n');
  }

  /// Export all feedback as JSON (for backend sync)
  String exportAsJson() {
    final unsynced = _feedbackList.where((f) => !f.synced).toList();
    return jsonEncode(unsynced.map((f) => f.toJson()).toList());
  }

  /// Mark feedback as synced
  Future<void> markAsSynced(List<String> feedbackIds) async {
    for (var i = 0; i < _feedbackList.length; i++) {
      if (feedbackIds.contains(_feedbackList[i].id)) {
        _feedbackList[i] = _feedbackList[i].markSynced();
      }
    }
    await _save();
  }

  /// Sync feedback to backend
  /// TODO: Implement actual backend sync when API is ready
  Future<bool> syncToBackend() async {
    // Placeholder for backend sync
    // This would POST to your feedback API endpoint
    /*
    final unsynced = _feedbackList.where((f) => !f.synced).toList();
    if (unsynced.isEmpty) return true;

    try {
      final response = await http.post(
        Uri.parse('https://api.vazhi.app/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(unsynced.map((f) => f.toJson()).toList()),
      );

      if (response.statusCode == 200) {
        await markAsSynced(unsynced.map((f) => f.id).toList());
        return true;
      }
    } catch (e) {
      // Sync failed, will retry later
    }
    */

    return false;
  }

  /// Clear all feedback (for testing)
  Future<void> clear() async {
    _feedbackList.clear();
    await _save();
  }
}
