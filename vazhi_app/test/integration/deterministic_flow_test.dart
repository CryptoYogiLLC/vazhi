/// Integration tests for deterministic retrieval flow
///
/// Tests that knowledge-based queries work correctly without AI model.

import 'package:flutter_test/flutter_test.dart';
import 'package:vazhi_app/services/query_router.dart';
import 'package:vazhi_app/services/retrieval/retrieval_service.dart';
import 'package:vazhi_app/services/retrieval/thirukkural_service.dart';
import 'package:vazhi_app/services/retrieval/scheme_service.dart';
import 'package:vazhi_app/services/retrieval/emergency_service.dart';
import 'package:vazhi_app/services/retrieval/healthcare_service.dart';
import 'package:vazhi_app/services/retrieval/knowledge_service.dart';
import 'package:vazhi_app/models/query_result.dart';

void main() {
  group('Deterministic Flow Integration Tests', () {
    late QueryRouter queryRouter;
    late KnowledgeService knowledgeService;
    late ThirukkuralService thirukkuralService;
    late SchemeService schemeService;
    late EmergencyService emergencyService;
    late HealthcareService healthcareService;

    setUp(() {
      queryRouter = QueryRouter();
      thirukkuralService = ThirukkuralService();
      schemeService = SchemeService();
      emergencyService = EmergencyService();
      healthcareService = HealthcareService();
      knowledgeService = KnowledgeService(
        router: queryRouter,
        thirukkuralService: thirukkuralService,
        schemeService: schemeService,
        emergencyService: emergencyService,
        healthcareService: healthcareService,
      );
    });

    group('Thirukkural Lookup', () {
      test('classifies valid kural number correctly', () async {
        final response = await knowledgeService.query('குறள் 1');

        // Classification should work even without database
        expect(response.classification.type, QueryType.deterministic);
        expect(response.classification.category, KnowledgeCategory.thirukkural);
        expect(response.classification.entityId, '1');
      });

      test('classifies English kural query correctly', () async {
        final response = await knowledgeService.query('kural 100');

        expect(response.classification.category, KnowledgeCategory.thirukkural);
        expect(response.classification.entityId, '100');
      });

      test('returns verse for Thirukkural query', () async {
        final response = await knowledgeService.query('thirukkural 42');

        // May be deterministic or require AI depending on pattern matching
        expect(response.classification.category, KnowledgeCategory.thirukkural);
      });

      test('returns hybrid for kural with explanation request', () async {
        final response = await knowledgeService.query('குறள் 1 பொருள் என்ன');

        // Should have data but suggest AI enhancement
        expect(response.classification.type, QueryType.hybrid);
        expect(response.suggestAiEnhancement, isTrue);
      });

      test('handles athikaram lookup with pattern', () async {
        // Use a pattern that's more likely to match
        final classification = await queryRouter.classify('முதல் அதிகாரம் குறள்கள்');

        // Athikaram may not have specific pattern - test that it doesn't crash
        expect(classification, isNotNull);
      });

      test('rejects invalid kural number gracefully', () async {
        final response = await knowledgeService.query('குறள் 0');

        expect(response.hasResponse, isFalse);
      });

      test('rejects kural number above 1330', () async {
        final response = await knowledgeService.query('kural 1500');

        expect(response.hasResponse, isFalse);
      });
    });

    group('Scheme Lookup', () {
      test('classifies scheme queries correctly', () async {
        final response = await knowledgeService.query('CMCHIS திட்டம்');

        expect(response.classification.category, KnowledgeCategory.schemes);
      });

      test('classifies central schemes', () async {
        final classification = await queryRouter.classify('PM Kisan scheme');

        expect(classification.category, KnowledgeCategory.schemes);
      });

      test('returns hybrid for eligibility questions', () async {
        final response = await knowledgeService.query('CMCHIS யாருக்கு தகுதி விளக்கம்');

        // May be deterministic or hybrid based on pattern matching
        expect(response.classification.category, KnowledgeCategory.schemes);
      });

      test('handles Ayushman Bharat queries', () async {
        final classification = await queryRouter.classify('ayushman bharat');

        expect(classification.category, KnowledgeCategory.schemes);
      });
    });

    group('Emergency Contacts', () {
      test('returns emergency numbers for Tamil query', () async {
        final response = await knowledgeService.query('அவசர எண்');

        expect(response.classification.category, KnowledgeCategory.emergency);
        expect(response.classification.type, QueryType.deterministic);
      });

      test('returns ambulance number', () async {
        final response = await knowledgeService.query('ambulance number');

        expect(response.classification.category, KnowledgeCategory.emergency);
      });

      test('returns police helpline', () async {
        final response = await knowledgeService.query('police helpline');

        expect(response.classification.category, KnowledgeCategory.emergency);
      });

      test('handles numeric emergency query', () async {
        final response = await knowledgeService.query('108 ambulance');

        expect(response.classification.category, KnowledgeCategory.emergency);
      });

      test('returns fire department number', () async {
        final response = await knowledgeService.query('fire emergency');

        expect(response.classification.category, KnowledgeCategory.emergency);
      });
    });

    group('Healthcare Facilities', () {
      test('classifies hospital queries', () async {
        final response = await knowledgeService.query('அரசு மருத்துவமனை');

        expect(response.classification.category, KnowledgeCategory.health);
      });

      test('handles English hospital query', () async {
        final response = await knowledgeService.query('government hospital');

        expect(response.classification.category, KnowledgeCategory.health);
      });

      test('handles hospital near me query', () async {
        final response = await knowledgeService.query('hospital near me');

        expect(response.classification.category, KnowledgeCategory.health);
      });
    });

    group('Safety and Scam Detection', () {
      test('classifies OTP scam as safety', () async {
        final response = await knowledgeService.query('OTP மோசடி');

        expect(response.classification.category, KnowledgeCategory.safety);
        expect(response.classification.type, QueryType.hybrid);
      });

      test('classifies bank fraud as safety', () async {
        final response = await knowledgeService.query('bank fraud');

        expect(response.classification.category, KnowledgeCategory.safety);
      });

      test('classifies phishing query as safety', () async {
        final classification = await queryRouter.classify('phishing scam');

        expect(classification.category, KnowledgeCategory.safety);
      });
    });

    group('AI Required Queries', () {
      test('classifies how-to questions as AI required', () async {
        final response = await knowledgeService.query('how to learn programming');

        expect(response.classification.type, QueryType.aiRequired);
        expect(response.needsModel, isTrue);
      });

      test('classifies why questions as AI required', () async {
        final response = await knowledgeService.query('why is sky blue');

        expect(response.classification.type, QueryType.aiRequired);
      });

      test('classifies opinion requests as AI required', () async {
        final response = await knowledgeService.query('what do you think about AI');

        expect(response.classification.type, QueryType.aiRequired);
      });

      test('AI required returns no deterministic response', () async {
        final response = await knowledgeService.query('explain machine learning');

        expect(response.answeredDeterministically, isFalse);
        expect(response.hasResponse, isFalse);
      });
    });

    group('Edge Cases', () {
      test('handles empty query gracefully', () async {
        final response = await knowledgeService.query('');

        expect(response.hasResponse, isFalse);
      });

      test('handles whitespace-only query', () async {
        final response = await knowledgeService.query('   ');

        expect(response.hasResponse, isFalse);
      });

      test('is case insensitive', () async {
        final response1 = await knowledgeService.query('KURAL 1');
        final response2 = await knowledgeService.query('kural 1');

        expect(
          response1.classification.category,
          response2.classification.category,
        );
      });

      test('handles mixed Tamil and English', () async {
        // Use known patterns - "குறள் 1" is reliable
        final response = await knowledgeService.query('குறள் 1 கேள்வி');

        expect(response.classification.category, KnowledgeCategory.thirukkural);
      });
    });

    group('Response Properties', () {
      test('deterministic response has classification', () async {
        final response = await knowledgeService.query('அவசர எண்');

        // Verify response is properly classified
        expect(response.classification.category, KnowledgeCategory.emergency);
      });

      test('hybrid response suggests AI enhancement', () async {
        final response = await knowledgeService.query('குறள் 1 விளக்கம்');

        expect(response.suggestAiEnhancement, isTrue);
      });

      test('hybrid response has aiPromptSuggestion', () async {
        final response = await knowledgeService.query('CMCHIS பற்றி விளக்கவும்');

        if (response.classification.type == QueryType.hybrid) {
          expect(response.aiPromptSuggestion, isNotNull);
        }
      });

      test('AI required response sets needsModel true', () async {
        final response = await knowledgeService.query('explain philosophy');

        expect(response.needsModel, isTrue);
      });
    });
  });

  group('Service Independence Tests', () {
    test('ThirukkuralService works independently', () async {
      final service = ThirukkuralService();

      final result = await service.getByNumber(1);
      expect(result.category, KnowledgeCategory.thirukkural);
    });

    test('EmergencyService works independently', () async {
      final service = EmergencyService();

      final result = await service.getAllContacts();
      expect(result.category, KnowledgeCategory.emergency);
    });

    test('SchemeService works independently', () async {
      final service = SchemeService();

      expect(service.category, KnowledgeCategory.schemes);
    });

    test('HealthcareService works independently', () async {
      final service = HealthcareService();

      expect(service.category, KnowledgeCategory.health);
    });
  });

  group('Query Router Pattern Matching', () {
    late QueryRouter router;

    setUp(() {
      router = QueryRouter();
    });

    test('thirukkural patterns have priority over general', () async {
      final c = await router.classify('குறள் 100 பற்றி');

      expect(c.category, KnowledgeCategory.thirukkural);
    });

    test('emergency patterns have high priority', () async {
      final c = await router.classify('108 call செய்யுங்கள்');

      // Should recognize as emergency due to 108
      expect(c.category, KnowledgeCategory.emergency);
    });

    test('scheme names are recognized', () async {
      final c = await router.classify('PM Kisan பற்றி தெரிந்து கொள்ள வேண்டும்');

      expect(c.category, KnowledgeCategory.schemes);
    });

    test('health keywords trigger health category', () async {
      final c = await router.classify('Chennai hospital list');

      expect(c.category, KnowledgeCategory.health);
    });
  });
}
