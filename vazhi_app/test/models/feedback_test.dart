/// Feedback Model Tests
///
/// Tests for the UserFeedback model and its factories.

import 'package:flutter_test/flutter_test.dart';
import 'package:vazhi_app/models/feedback.dart';

void main() {
  group('FeedbackType', () {
    test('has all expected types', () {
      expect(FeedbackType.values.length, 3);
      expect(FeedbackType.values, contains(FeedbackType.positive));
      expect(FeedbackType.values, contains(FeedbackType.negative));
      expect(FeedbackType.values, contains(FeedbackType.correction));
    });
  });

  group('UserFeedback - positive factory', () {
    test('creates positive feedback correctly', () {
      final feedback = UserFeedback.positive(
        messageId: 'msg123',
        question: 'What is Thirukkural?',
        modelResponse: 'Thirukkural is a classic Tamil text.',
        pack: 'culture',
      );

      expect(feedback.type, FeedbackType.positive);
      expect(feedback.messageId, 'msg123');
      expect(feedback.question, 'What is Thirukkural?');
      expect(feedback.modelResponse, contains('Thirukkural'));
      expect(feedback.pack, 'culture');
      expect(feedback.correction, isNull);
      expect(feedback.synced, isFalse);
    });

    test('generates non-empty ID', () {
      final feedback1 = UserFeedback.positive(
        messageId: 'msg1',
        question: 'Q1',
        modelResponse: 'R1',
      );
      final feedback2 = UserFeedback.positive(
        messageId: 'msg2',
        question: 'Q2',
        modelResponse: 'R2',
      );

      // IDs are timestamp-based, so they should be non-empty
      expect(feedback1.id, isNotEmpty);
      expect(feedback2.id, isNotEmpty);
    });
  });

  group('UserFeedback - negative factory', () {
    test('creates negative feedback correctly', () {
      final feedback = UserFeedback.negative(
        messageId: 'msg456',
        question: 'Emergency number?',
        modelResponse: 'Wrong answer',
      );

      expect(feedback.type, FeedbackType.negative);
      expect(feedback.messageId, 'msg456');
      expect(feedback.synced, isFalse);
    });
  });

  group('UserFeedback - correction factory', () {
    test('creates correction feedback correctly', () {
      final feedback = UserFeedback.correction(
        messageId: 'msg789',
        question: 'What is 108?',
        modelResponse: 'Wrong answer',
        correction: '108 is the ambulance emergency number in India.',
        pack: 'emergency',
      );

      expect(feedback.type, FeedbackType.correction);
      expect(feedback.correction, contains('108'));
      expect(feedback.pack, 'emergency');
    });

    test('correction is required', () {
      final feedback = UserFeedback.correction(
        messageId: 'msg',
        question: 'Q',
        modelResponse: 'R',
        correction: 'Correct answer',
      );

      expect(feedback.correction, 'Correct answer');
    });
  });

  group('UserFeedback - toJson/fromJson', () {
    test('roundtrip preserves data', () {
      final original = UserFeedback.correction(
        messageId: 'msg123',
        question: 'திருக்குறள் என்றால் என்ன?',
        modelResponse: 'Original response',
        correction: 'திருக்குறள் ஒரு அறநூல்',
        pack: 'culture',
      );

      final json = original.toJson();
      final restored = UserFeedback.fromJson(json);

      expect(restored.messageId, original.messageId);
      expect(restored.question, original.question);
      expect(restored.modelResponse, original.modelResponse);
      expect(restored.type, original.type);
      expect(restored.correction, original.correction);
      expect(restored.pack, original.pack);
      expect(restored.synced, original.synced);
    });

    test('toJson includes all fields', () {
      final feedback = UserFeedback.positive(
        messageId: 'msg',
        question: 'Q',
        modelResponse: 'R',
        pack: 'test',
      );

      final json = feedback.toJson();

      expect(json, containsPair('id', isNotNull));
      expect(json, containsPair('messageId', 'msg'));
      expect(json, containsPair('question', 'Q'));
      expect(json, containsPair('modelResponse', 'R'));
      expect(json, containsPair('type', 'positive'));
      expect(json, containsPair('pack', 'test'));
      expect(json, containsPair('timestamp', isNotNull));
      expect(json, containsPair('synced', false));
    });

    test('fromJson handles missing correction', () {
      final json = {
        'id': '123',
        'messageId': 'msg',
        'question': 'Q',
        'modelResponse': 'R',
        'type': 'negative',
        'correction': null,
        'pack': null,
        'timestamp': DateTime.now().toIso8601String(),
        'synced': false,
      };

      final feedback = UserFeedback.fromJson(json);
      expect(feedback.correction, isNull);
      expect(feedback.pack, isNull);
    });

    test('fromJson defaults synced to false', () {
      final json = {
        'id': '123',
        'messageId': 'msg',
        'question': 'Q',
        'modelResponse': 'R',
        'type': 'positive',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final feedback = UserFeedback.fromJson(json);
      expect(feedback.synced, isFalse);
    });

    test('fromJson handles unknown type gracefully', () {
      final json = {
        'id': '123',
        'messageId': 'msg',
        'question': 'Q',
        'modelResponse': 'R',
        'type': 'unknown_type',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final feedback = UserFeedback.fromJson(json);
      expect(feedback.type, FeedbackType.negative); // default fallback
    });
  });

  group('UserFeedback - toTrainingFormat', () {
    test('returns empty for non-correction feedback', () {
      final positive = UserFeedback.positive(
        messageId: 'msg',
        question: 'Q',
        modelResponse: 'R',
      );

      expect(positive.toTrainingFormat(), isEmpty);

      final negative = UserFeedback.negative(
        messageId: 'msg',
        question: 'Q',
        modelResponse: 'R',
      );

      expect(negative.toTrainingFormat(), isEmpty);
    });

    test('returns Alpaca format for correction', () {
      final correction = UserFeedback.correction(
        messageId: 'msg',
        question: 'What is 100?',
        modelResponse: 'Wrong',
        correction: '100 is one hundred',
      );

      final format = correction.toTrainingFormat();

      expect(format, contains('### Instruction:'));
      expect(format, contains('What is 100?'));
      expect(format, contains('### Response:'));
      expect(format, contains('100 is one hundred'));
      expect(format, endsWith('</s>'));
    });

    test('preserves Tamil text in training format', () {
      final correction = UserFeedback.correction(
        messageId: 'msg',
        question: 'குறள் 1 என்ன?',
        modelResponse: 'Wrong',
        correction: 'அகர முதல எழுத்தெல்லாம்',
      );

      final format = correction.toTrainingFormat();

      expect(format, contains('குறள் 1 என்ன?'));
      expect(format, contains('அகர முதல எழுத்தெல்லாம்'));
    });
  });

  group('UserFeedback - markSynced', () {
    test('returns new instance with synced=true', () {
      final original = UserFeedback.positive(
        messageId: 'msg',
        question: 'Q',
        modelResponse: 'R',
      );

      expect(original.synced, isFalse);

      final synced = original.markSynced();

      expect(synced.synced, isTrue);
      expect(synced.id, original.id);
      expect(synced.messageId, original.messageId);
    });

    test('preserves all other fields', () {
      final original = UserFeedback.correction(
        messageId: 'msg123',
        question: 'Q',
        modelResponse: 'R',
        correction: 'C',
        pack: 'pack',
      );

      final synced = original.markSynced();

      expect(synced.messageId, original.messageId);
      expect(synced.question, original.question);
      expect(synced.modelResponse, original.modelResponse);
      expect(synced.type, original.type);
      expect(synced.correction, original.correction);
      expect(synced.pack, original.pack);
      expect(synced.timestamp, original.timestamp);
    });
  });

  group('UserFeedback - timestamp', () {
    test('auto-sets timestamp if not provided', () {
      final before = DateTime.now();
      final feedback = UserFeedback.positive(
        messageId: 'msg',
        question: 'Q',
        modelResponse: 'R',
      );
      final after = DateTime.now();

      expect(feedback.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(feedback.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });
}
