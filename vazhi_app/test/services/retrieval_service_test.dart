import 'package:flutter_test/flutter_test.dart';
import 'package:vazhi_app/services/retrieval/retrieval_service.dart';
import 'package:vazhi_app/services/retrieval/thirukkural_service.dart';
import 'package:vazhi_app/services/retrieval/scheme_service.dart';
import 'package:vazhi_app/services/retrieval/emergency_service.dart';
import 'package:vazhi_app/services/retrieval/healthcare_service.dart';
import 'package:vazhi_app/services/retrieval/knowledge_service.dart';
import 'package:vazhi_app/models/query_result.dart';

void main() {
  group('RetrievalResult', () {
    test('creates found result correctly', () {
      final result = RetrievalResult.found(
        'test data',
        category: KnowledgeCategory.thirukkural,
        displayTitle: 'Test Title',
      );

      expect(result.success, isTrue);
      expect(result.hasData, isTrue);
      expect(result.data, 'test data');
      expect(result.displayTitle, 'Test Title');
      expect(result.category, KnowledgeCategory.thirukkural);
    });

    test('creates list result correctly', () {
      final result = RetrievalResult.list(
        ['item1', 'item2', 'item3'],
        category: KnowledgeCategory.schemes,
        totalCount: 3,
      );

      expect(result.success, isTrue);
      expect(result.hasData, isTrue);
      expect(result.results.length, 3);
      expect(result.isListResult, isTrue);
      expect(result.isSingleResult, isFalse);
    });

    test('creates not found result correctly', () {
      final result = RetrievalResult.notFound(
        category: KnowledgeCategory.emergency,
        message: 'Not found',
      );

      expect(result.success, isFalse);
      expect(result.hasData, isFalse);
      expect(result.errorMessage, 'Not found');
    });

    test('creates error result correctly', () {
      final result = RetrievalResult.error(
        'Database error',
        category: KnowledgeCategory.health,
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, 'Database error');
    });
  });

  group('KnowledgeCategory', () {
    test('fromId returns correct category', () {
      expect(KnowledgeCategoryExtension.fromId('thirukkural'), KnowledgeCategory.thirukkural);
      expect(KnowledgeCategoryExtension.fromId('schemes'), KnowledgeCategory.schemes);
      expect(KnowledgeCategoryExtension.fromId('emergency'), KnowledgeCategory.emergency);
      expect(KnowledgeCategoryExtension.fromId('health'), KnowledgeCategory.health);
      expect(KnowledgeCategoryExtension.fromId('unknown'), KnowledgeCategory.general);
    });

    test('id getter returns correct string', () {
      expect(KnowledgeCategory.thirukkural.id, 'thirukkural');
      expect(KnowledgeCategory.schemes.id, 'schemes');
      expect(KnowledgeCategory.emergency.id, 'emergency');
    });

    test('nameTamil returns Tamil name', () {
      expect(KnowledgeCategory.thirukkural.nameTamil, 'திருக்குறள்');
      expect(KnowledgeCategory.schemes.nameTamil, 'அரசு திட்டங்கள்');
      expect(KnowledgeCategory.emergency.nameTamil, 'அவசர தொடர்பு');
    });
  });

  group('ThirukkuralService', () {
    late ThirukkuralService service;

    setUp(() {
      service = ThirukkuralService();
    });

    test('category is thirukkural', () {
      expect(service.category, KnowledgeCategory.thirukkural);
    });

    test('rejects invalid kural numbers', () async {
      final result1 = await service.getByNumber(0);
      expect(result1.success, isFalse);

      final result2 = await service.getByNumber(1331);
      expect(result2.success, isFalse);

      final result3 = await service.getByNumber(-5);
      expect(result3.success, isFalse);
    });

    test('rejects invalid athikaram numbers', () async {
      final result1 = await service.getByAthikaram(0);
      expect(result1.success, isFalse);

      final result2 = await service.getByAthikaram(134);
      expect(result2.success, isFalse);
    });
  });

  group('SchemeService', () {
    late SchemeService service;

    setUp(() {
      service = SchemeService();
    });

    test('category is schemes', () {
      expect(service.category, KnowledgeCategory.schemes);
    });
  });

  group('EmergencyService', () {
    late EmergencyService service;

    setUp(() {
      service = EmergencyService();
    });

    test('category is emergency', () {
      expect(service.category, KnowledgeCategory.emergency);
    });
  });

  group('HealthcareService', () {
    late HealthcareService service;

    setUp(() {
      service = HealthcareService();
    });

    test('category is health', () {
      expect(service.category, KnowledgeCategory.health);
    });
  });

  group('KnowledgeResponse', () {
    test('creates deterministic response', () {
      final classification = QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.thirukkural,
        confidence: 0.9,
        query: 'குறள் 1',
      );

      final result = RetrievalResult.found(
        'test',
        category: KnowledgeCategory.thirukkural,
        formattedResponse: 'Test response',
      );

      final response = KnowledgeResponse.deterministic(
        classification: classification,
        result: result,
      );

      expect(response.answeredDeterministically, isTrue);
      expect(response.suggestAiEnhancement, isFalse);
      expect(response.hasResponse, isTrue);
    });

    test('creates hybrid response', () {
      final classification = QueryClassification(
        type: QueryType.hybrid,
        category: KnowledgeCategory.thirukkural,
        confidence: 0.8,
        query: 'குறள் 1 விளக்கம்',
      );

      final result = RetrievalResult.found(
        'test',
        category: KnowledgeCategory.thirukkural,
        formattedResponse: 'Test response',
      );

      final response = KnowledgeResponse.hybrid(
        classification: classification,
        result: result,
        aiPrompt: 'Explain this',
      );

      expect(response.answeredDeterministically, isTrue);
      expect(response.suggestAiEnhancement, isTrue);
      expect(response.aiPromptSuggestion, 'Explain this');
    });

    test('creates AI-required response', () {
      final classification = QueryClassification(
        type: QueryType.aiRequired,
        category: KnowledgeCategory.general,
        confidence: 0.5,
        query: 'explain philosophy',
      );

      final response = KnowledgeResponse.requiresAi(
        classification: classification,
      );

      expect(response.answeredDeterministically, isFalse);
      expect(response.needsModel, isTrue);
      expect(response.hasResponse, isFalse);
    });
  });
}
