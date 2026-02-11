/// Message Model Tests
///
/// Tests for the Message model and its factory constructors.

import 'package:flutter_test/flutter_test.dart';
import 'package:vazhi_app/models/message.dart';

void main() {
  group('MessageRole', () {
    test('has user, assistant, and system roles', () {
      expect(MessageRole.values.length, 3);
      expect(MessageRole.values, contains(MessageRole.user));
      expect(MessageRole.values, contains(MessageRole.assistant));
      expect(MessageRole.values, contains(MessageRole.system));
    });
  });

  group('Message - user factory', () {
    test('creates user message correctly', () {
      final message = Message.user('Hello');

      expect(message.role, MessageRole.user);
      expect(message.content, 'Hello');
      expect(message.isLoading, isFalse);
      expect(message.error, isNull);
      expect(message.pack, isNull);
      expect(message.id, isNotEmpty);
    });

    test('generates non-empty IDs', () {
      final message1 = Message.user('First');
      final message2 = Message.user('Second');

      // IDs are timestamp-based, so they are non-empty
      expect(message1.id, isNotEmpty);
      expect(message2.id, isNotEmpty);
      // Both should be numeric strings (milliseconds since epoch)
      expect(int.tryParse(message1.id), isNotNull);
      expect(int.tryParse(message2.id), isNotNull);
    });

    test('preserves Tamil text', () {
      final message = Message.user('வணக்கம்');
      expect(message.content, 'வணக்கம்');
    });
  });

  group('Message - assistant factory', () {
    test('creates assistant message correctly', () {
      final message = Message.assistant('Response text');

      expect(message.role, MessageRole.assistant);
      expect(message.content, 'Response text');
      expect(message.isLoading, isFalse);
      expect(message.error, isNull);
    });

    test('includes pack when provided', () {
      final message = Message.assistant('Response', pack: 'culture');

      expect(message.pack, 'culture');
    });

    test('preserves Tamil content', () {
      final message = Message.assistant('திருக்குறள் முதல் குறள்');
      expect(message.content, contains('திருக்குறள்'));
    });
  });

  group('Message - loading factory', () {
    test('creates loading message correctly', () {
      final message = Message.loading();

      expect(message.role, MessageRole.assistant);
      expect(message.isLoading, isTrue);
      expect(message.content, isEmpty);
      expect(message.error, isNull);
    });
  });

  group('Message - error factory', () {
    test('creates error message correctly', () {
      final message = Message.error('Something went wrong');

      expect(message.role, MessageRole.assistant);
      expect(message.error, 'Something went wrong');
      expect(message.isLoading, isFalse);
    });

    test('preserves Tamil error messages', () {
      final message = Message.error('பிழை ஏற்பட்டது');
      expect(message.error, 'பிழை ஏற்பட்டது');
    });
  });

  group('Message - MessageRole.system', () {
    test('system role exists in enum', () {
      // System role exists but no factory - messages can be created via constructor
      expect(MessageRole.values, contains(MessageRole.system));
    });
  });

  group('Message - timestamp', () {
    test('sets timestamp on creation', () {
      final before = DateTime.now();
      final message = Message.user('Test');
      final after = DateTime.now();

      expect(message.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(message.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });

  group('Message - immutability', () {
    test('message ID is consistent', () {
      final message = Message.user('Test');
      final id1 = message.id;
      final id2 = message.id;

      expect(id1, equals(id2));
    });
  });

  group('Message - edge cases', () {
    test('handles empty content', () {
      final message = Message.user('');
      expect(message.content, isEmpty);
    });

    test('handles very long content', () {
      final longContent = 'A' * 10000;
      final message = Message.user(longContent);
      expect(message.content.length, 10000);
    });

    test('handles special characters', () {
      final message = Message.user('Special chars: @#\$%^&*()');
      expect(message.content, contains('@#\$%^&*()'));
    });

    test('handles newlines', () {
      final message = Message.user('Line 1\nLine 2');
      expect(message.content, contains('\n'));
    });

    test('handles emojis', () {
      final message = Message.user('Hello 👋 World 🌍');
      expect(message.content, contains('👋'));
      expect(message.content, contains('🌍'));
    });
  });
}
