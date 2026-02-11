/// Knowledge Service
///
/// Unified facade for all knowledge retrieval services.
/// Routes queries to appropriate services based on classification.

import '../../models/query_result.dart';
import '../../database/knowledge_database.dart';
import '../query_router.dart';
import 'retrieval_service.dart';
import 'thirukkural_service.dart';
import 'scheme_service.dart';
import 'emergency_service.dart';
import 'healthcare_service.dart';

/// Response from the knowledge service
class KnowledgeResponse {
  /// The query classification
  final QueryClassification classification;

  /// The retrieval result (null if AI-required)
  final RetrievalResult<dynamic>? result;

  /// Whether this query was answered deterministically
  final bool answeredDeterministically;

  /// Formatted response text for display
  final String? formattedResponse;

  /// Suggested follow-up prompt for AI (for hybrid queries)
  final String? aiPromptSuggestion;

  /// Whether additional AI processing is recommended
  final bool suggestAiEnhancement;

  const KnowledgeResponse({
    required this.classification,
    this.result,
    this.answeredDeterministically = false,
    this.formattedResponse,
    this.aiPromptSuggestion,
    this.suggestAiEnhancement = false,
  });

  /// Create response for deterministic answer
  factory KnowledgeResponse.deterministic({
    required QueryClassification classification,
    required RetrievalResult<dynamic> result,
  }) {
    return KnowledgeResponse(
      classification: classification,
      result: result,
      answeredDeterministically: true,
      formattedResponse: result.formattedResponse,
      suggestAiEnhancement: false,
    );
  }

  /// Create response for hybrid answer (data + AI suggestion)
  factory KnowledgeResponse.hybrid({
    required QueryClassification classification,
    required RetrievalResult<dynamic> result,
    String? aiPrompt,
  }) {
    return KnowledgeResponse(
      classification: classification,
      result: result,
      answeredDeterministically: true,
      formattedResponse: result.formattedResponse,
      aiPromptSuggestion: aiPrompt,
      suggestAiEnhancement: true,
    );
  }

  /// Create response requiring AI
  factory KnowledgeResponse.requiresAi({
    required QueryClassification classification,
  }) {
    return KnowledgeResponse(
      classification: classification,
      answeredDeterministically: false,
      suggestAiEnhancement: true,
    );
  }

  /// Check if we have a displayable response
  bool get hasResponse =>
      formattedResponse != null && formattedResponse!.isNotEmpty;

  /// Check if this needs model for complete response
  bool get needsModel => !answeredDeterministically || suggestAiEnhancement;
}

/// Main knowledge service facade
class KnowledgeService {
  final QueryRouter _router;
  final ThirukkuralService _thirukkuralService;
  final SchemeService _schemeService;
  final EmergencyService _emergencyService;
  final HealthcareService _healthcareService;

  KnowledgeService({
    QueryRouter? router,
    ThirukkuralService? thirukkuralService,
    SchemeService? schemeService,
    EmergencyService? emergencyService,
    HealthcareService? healthcareService,
  }) : _router = router ?? QueryRouter(),
       _thirukkuralService = thirukkuralService ?? ThirukkuralService(),
       _schemeService = schemeService ?? SchemeService(),
       _emergencyService = emergencyService ?? EmergencyService(),
       _healthcareService = healthcareService ?? HealthcareService();

  /// Process a query and return the best response
  Future<KnowledgeResponse> query(String userQuery) async {
    // Classify the query
    final classification = await _router.classify(userQuery);

    // Route based on classification
    switch (classification.type) {
      case QueryType.deterministic:
        return _handleDeterministic(classification);
      case QueryType.hybrid:
        return _handleHybrid(classification);
      case QueryType.aiRequired:
        return KnowledgeResponse.requiresAi(classification: classification);
    }
  }

  /// Handle deterministic queries
  Future<KnowledgeResponse> _handleDeterministic(
    QueryClassification classification,
  ) async {
    final result = await _retrieveData(classification);

    if (result == null || !result.success) {
      // If no data found, suggest AI fallback
      return KnowledgeResponse.requiresAi(classification: classification);
    }

    return KnowledgeResponse.deterministic(
      classification: classification,
      result: result,
    );
  }

  /// Handle hybrid queries (data + AI enhancement)
  Future<KnowledgeResponse> _handleHybrid(
    QueryClassification classification,
  ) async {
    final result = await _retrieveData(classification);

    if (result == null || !result.success) {
      // No data, let AI handle completely
      return KnowledgeResponse.requiresAi(classification: classification);
    }

    // Build AI prompt suggestion based on the data
    final aiPrompt = _buildAiPrompt(classification, result);

    return KnowledgeResponse.hybrid(
      classification: classification,
      result: result,
      aiPrompt: aiPrompt,
    );
  }

  /// Retrieve data from appropriate service
  Future<RetrievalResult<dynamic>?> _retrieveData(
    QueryClassification classification,
  ) async {
    switch (classification.category) {
      case KnowledgeCategory.thirukkural:
        return _handleThirukkural(classification);

      case KnowledgeCategory.schemes:
        return _handleSchemes(classification);

      case KnowledgeCategory.emergency:
        return _handleEmergency(classification);

      case KnowledgeCategory.health:
        return _handleHealth(classification);

      case KnowledgeCategory.safety:
        // Safety queries could use emergency service for numbers
        // but primarily need AI for explanations
        return _emergencyService.search(classification.query);

      default:
        // Try full-text search
        return _fullTextSearch(classification.query);
    }
  }

  /// Handle Thirukkural queries
  Future<RetrievalResult<dynamic>> _handleThirukkural(
    QueryClassification classification,
  ) async {
    // If we have an entity ID, get specific kural
    if (classification.entityId != null &&
        classification.entityType == 'kural_number') {
      final kuralNumber = int.tryParse(classification.entityId!);
      if (kuralNumber != null) {
        return _thirukkuralService.getByNumber(kuralNumber);
      }
    }

    // Otherwise search
    return _thirukkuralService.search(classification.query);
  }

  /// Handle scheme queries
  Future<RetrievalResult<dynamic>> _handleSchemes(
    QueryClassification classification,
  ) async {
    // Check for specific scheme ID
    if (classification.entityId != null &&
        classification.entityType == 'scheme_id') {
      return _schemeService.getById(classification.entityId!);
    }

    // Otherwise search
    return _schemeService.search(classification.query);
  }

  /// Handle emergency queries
  Future<RetrievalResult<dynamic>> _handleEmergency(
    QueryClassification classification,
  ) async {
    final query = classification.query.toLowerCase();

    // Check for specific type
    if (query.contains('police') ||
        query.contains('போலீஸ்') ||
        query.contains('காவல்')) {
      return _emergencyService.getByType('police');
    }
    if (query.contains('fire') || query.contains('தீ')) {
      return _emergencyService.getByType('fire');
    }
    if (query.contains('ambulance') ||
        query.contains('ஆம்புலன்ஸ்') ||
        query.contains('108')) {
      return _emergencyService.getByType('medical');
    }

    // Default to quick emergency numbers
    return _emergencyService.getQuickEmergency();
  }

  /// Handle health/hospital queries
  Future<RetrievalResult<dynamic>> _handleHealth(
    QueryClassification classification,
  ) async {
    // Search hospitals
    return _healthcareService.search(classification.query);
  }

  /// Full-text search across all data
  Future<RetrievalResult<Map<String, dynamic>>> _fullTextSearch(
    String query,
  ) async {
    try {
      final results = await KnowledgeDatabase.fullTextSearch(query);
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: KnowledgeCategory.general,
          message: '"$query" க்கான தகவல்கள் கிடைக்கவில்லை',
        );
      }

      return RetrievalResult.list(
        results,
        category: KnowledgeCategory.general,
        displayTitle: 'தேடல் முடிவுகள்',
        formattedResponse: _formatSearchResults(results),
        totalCount: results.length,
      );
    } catch (e) {
      return RetrievalResult.error(
        'தேடல் பிழை: $e',
        category: KnowledgeCategory.general,
      );
    }
  }

  /// Build AI prompt suggestion based on retrieved data
  String _buildAiPrompt(
    QueryClassification classification,
    RetrievalResult<dynamic> result,
  ) {
    final buffer = StringBuffer();

    buffer.writeln(
      'Based on the following data, please provide additional explanation:',
    );
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln(result.formattedResponse ?? '');
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('User query: ${classification.query}');
    buffer.writeln();
    buffer.writeln(
      'Please explain the meaning, context, or provide additional insights in Tamil.',
    );

    return buffer.toString();
  }

  /// Format full-text search results
  String _formatSearchResults(List<Map<String, dynamic>> results) {
    final buffer = StringBuffer();

    buffer.writeln('🔍 **தேடல் முடிவுகள்** (${results.length})');
    buffer.writeln();

    for (final result in results.take(10)) {
      final title = result['title_tamil'] ?? result['title_english'] ?? '';
      final contentType = result['content_type'] ?? '';
      final snippet = result['snippet'] ?? '';

      buffer.writeln('• **$title** [$contentType]');
      if (snippet.isNotEmpty) {
        buffer.writeln('  $snippet');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Get database statistics
  Future<Map<String, int>> getStats() async {
    return KnowledgeDatabase.getStats();
  }

  /// Check if knowledge database is ready
  Future<bool> isReady() async {
    return KnowledgeDatabase.isReady();
  }

  /// Clear router cache (call when patterns are updated)
  void clearCache() {
    _router.clearCache();
  }
}
