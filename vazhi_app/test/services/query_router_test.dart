import 'package:flutter_test/flutter_test.dart';
import 'package:vazhi_app/services/query_router.dart';
import 'package:vazhi_app/models/query_result.dart';

void main() {
  late QueryRouter router;

  setUp(() {
    router = QueryRouter();
  });

  group('QueryRouter - Thirukkural patterns', () {
    test('classifies "குறள் 1" as deterministic thirukkural', () async {
      final result = await router.classify('குறள் 1');

      expect(result.type, QueryType.deterministic);
      expect(result.category, KnowledgeCategory.thirukkural);
      expect(result.entityId, '1');
      expect(result.entityType, 'kural_number');
    });

    test('classifies "kural 42" as deterministic thirukkural', () async {
      final result = await router.classify('kural 42');

      expect(result.type, QueryType.deterministic);
      expect(result.category, KnowledgeCategory.thirukkural);
      expect(result.entityId, '42');
    });

    test('classifies "thirukkural 100" as deterministic', () async {
      final result = await router.classify('thirukkural 100');

      expect(result.type, QueryType.deterministic);
      expect(result.entityId, '100');
    });

    test('classifies kural with explanation request as hybrid', () async {
      final result = await router.classify('குறள் 1 விளக்கம்');

      expect(result.type, QueryType.hybrid);
      expect(result.category, KnowledgeCategory.thirukkural);
      expect(result.entityId, '1');
    });

    test('classifies kural with meaning request as hybrid', () async {
      final result = await router.classify('kural 5 meaning');

      expect(result.type, QueryType.hybrid);
      expect(result.category, KnowledgeCategory.thirukkural);
    });

    test('rejects invalid kural numbers', () async {
      final result = await router.classify('குறள் 9999');

      // Should not extract invalid kural number
      expect(result.entityId, isNull);
    });
  });

  group('QueryRouter - Emergency patterns', () {
    test('classifies "அவசர எண்" as deterministic emergency', () async {
      final result = await router.classify('அவசர எண்');

      expect(result.type, QueryType.deterministic);
      expect(result.category, KnowledgeCategory.emergency);
    });

    test('classifies "ambulance number" as deterministic', () async {
      final result = await router.classify('ambulance number');

      expect(result.type, QueryType.deterministic);
      expect(result.category, KnowledgeCategory.emergency);
    });

    test('classifies "police helpline" as deterministic', () async {
      final result = await router.classify('police helpline');

      expect(result.type, QueryType.deterministic);
      expect(result.category, KnowledgeCategory.emergency);
    });

    test('classifies "108 ambulance" as deterministic emergency', () async {
      // Note: Just "108" could be confused with kural number 108
      // Using explicit context to ensure emergency classification
      final result = await router.classify('108 ambulance');

      expect(result.type, QueryType.deterministic);
      expect(result.category, KnowledgeCategory.emergency);
    });
  });

  group('QueryRouter - Scheme patterns', () {
    test('classifies "CMCHIS திட்டம்" as deterministic', () async {
      final result = await router.classify('CMCHIS திட்டம்');

      expect(result.type, QueryType.deterministic);
      expect(result.category, KnowledgeCategory.schemes);
    });

    test('classifies scheme with eligibility question as hybrid', () async {
      final result = await router.classify('CMCHIS எப்படி apply பண்றது?');

      expect(result.type, QueryType.hybrid);
      expect(result.category, KnowledgeCategory.schemes);
    });

    test('classifies "ayushman bharat" as scheme', () async {
      final result = await router.classify('ayushman bharat eligibility');

      expect(result.category, KnowledgeCategory.schemes);
    });
  });

  group('QueryRouter - Health patterns', () {
    test('classifies "அரசு மருத்துவமனை" as deterministic health', () async {
      final result = await router.classify('அரசு மருத்துவமனை சென்னை');

      expect(result.type, QueryType.deterministic);
      expect(result.category, KnowledgeCategory.health);
    });

    test('classifies "hospital near me" as deterministic', () async {
      final result = await router.classify('government hospital');

      expect(result.type, QueryType.deterministic);
      expect(result.category, KnowledgeCategory.health);
    });
  });

  group('QueryRouter - Safety patterns', () {
    test('classifies "OTP மோசடி" as deterministic safety', () async {
      final result = await router.classify('OTP மோசடி');

      expect(result.type, QueryType.deterministic);
      expect(result.category, KnowledgeCategory.safety);
    });

    test('classifies "bank fraud" as safety', () async {
      final result = await router.classify('bank fraud complaint');

      expect(result.category, KnowledgeCategory.safety);
    });
  });

  group('QueryRouter - Conversational queries route as hybrid', () {
    test('classifies "how to file RTI" as hybrid legal', () async {
      final result = await router.classify('how to file RTI?');

      expect(result.type, QueryType.hybrid);
      expect(result.category, KnowledgeCategory.legal);
    });

    test('classifies "how to report scam" as hybrid safety', () async {
      final result = await router.classify('how to report a scam?');

      expect(result.type, QueryType.hybrid);
      expect(result.category, KnowledgeCategory.safety);
    });

    test(
      'classifies "why scholarship important" as hybrid education',
      () async {
        final result = await router.classify('why is scholarship important?');

        expect(result.type, QueryType.hybrid);
        expect(result.category, KnowledgeCategory.education);
      },
    );

    test('classifies plain keyword as deterministic', () async {
      final result = await router.classify('rti');

      expect(result.type, QueryType.deterministic);
      expect(result.category, KnowledgeCategory.legal);
    });
  });

  group('QueryRouter - AI-required patterns', () {
    test('classifies "how to" questions as AI-required', () async {
      // Query with no deterministic keywords falls through to AI-required
      final result = await router.classify('how to improve my skills?');

      expect(result.type, QueryType.aiRequired);
    });

    test('classifies "why" questions as AI-required', () async {
      final result = await router.classify('why is this important?');

      expect(result.type, QueryType.aiRequired);
    });

    test('classifies opinion requests as AI-required', () async {
      final result = await router.classify('what do you think about this?');

      expect(result.type, QueryType.aiRequired);
    });
  });

  group('QueryRouter - Edge cases', () {
    test('handles empty query', () async {
      final result = await router.classify('');

      // Empty queries return low-confidence AI required (after input validation)
      expect(result.type, QueryType.aiRequired);
      expect(result.category, KnowledgeCategory.general);
      expect(result.confidence, 0.0);
    });

    test('handles query with only spaces', () async {
      final result = await router.classify('   ');

      // Whitespace-only queries return low-confidence AI required (after sanitization)
      expect(result.type, QueryType.aiRequired);
      expect(result.confidence, 0.0);
    });

    test('handles mixed Tamil and English', () async {
      // "குறள் 10" pattern should be detected even with mixed text
      final result = await router.classify('குறள் 10 explain பண்ணு');

      expect(result.category, KnowledgeCategory.thirukkural);
      expect(result.type, QueryType.hybrid);
    });

    test('is case insensitive', () async {
      final result1 = await router.classify('KURAL 5');
      final result2 = await router.classify('kural 5');

      expect(result1.entityId, result2.entityId);
    });
  });

  group('QueryRouter - Classification properties', () {
    test('canAnswerWithoutModel returns true for deterministic', () async {
      final result = await router.classify('குறள் 1');

      expect(result.canAnswerWithoutModel, isTrue);
      expect(result.requiresModel, isFalse);
    });

    test('requiresModel returns true for AI queries', () async {
      // Pure AI query with no deterministic patterns
      final result = await router.classify('why should I be kind to others?');

      expect(result.requiresModel, isTrue);
      expect(result.canAnswerWithoutModel, isFalse);
    });

    test('isHybrid returns true for hybrid queries', () async {
      final result = await router.classify('குறள் 1 விளக்கம்');

      expect(result.isHybrid, isTrue);
    });
  });
}
