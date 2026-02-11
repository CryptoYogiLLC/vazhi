/// Query Router Service
///
/// Routes user queries to deterministic (SQLite) or AI (LLM) paths
/// based on pattern matching and query classification.

import '../database/knowledge_database.dart';
import '../models/query_result.dart';

class QueryRouter {
  // Cached patterns from database
  List<PatternMatch>? _cachedPatterns;

  // Compiled regex patterns
  final Map<String, RegExp> _compiledPatterns = {};

  /// Classify a query and determine routing
  Future<QueryClassification> classify(String query) async {
    final normalizedQuery = _normalizeQuery(query);

    // Try to match against database patterns first
    final dbMatch = await _matchDatabasePatterns(normalizedQuery);
    if (dbMatch != null) {
      return _buildClassification(
        query: query,
        normalizedQuery: normalizedQuery,
        match: dbMatch,
      );
    }

    // Fall back to built-in pattern matching
    return _classifyWithBuiltInPatterns(query, normalizedQuery);
  }

  /// Normalize query for matching
  String _normalizeQuery(String query) {
    return query
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Match against patterns stored in database
  Future<PatternMatch?> _matchDatabasePatterns(String normalizedQuery) async {
    // Load patterns if not cached
    _cachedPatterns ??= await _loadPatterns();

    PatternMatch? bestMatch;
    int highestPriority = -1;

    for (final pattern in _cachedPatterns!) {
      try {
        final regex = _getCompiledPattern(pattern.pattern);
        if (regex.hasMatch(normalizedQuery)) {
          if (pattern.priority > highestPriority) {
            highestPriority = pattern.priority;
            bestMatch = pattern;
          }
        }
      } catch (e) {
        // Skip invalid patterns
      }
    }

    return bestMatch;
  }

  /// Load patterns from database
  Future<List<PatternMatch>> _loadPatterns() async {
    try {
      final rows = await KnowledgeDatabase.getQueryPatterns();
      return rows.map((r) => PatternMatch.fromMap(r)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get or compile a regex pattern
  RegExp _getCompiledPattern(String pattern) {
    return _compiledPatterns.putIfAbsent(
      pattern,
      () => RegExp(pattern, caseSensitive: false),
    );
  }

  /// Build classification from pattern match
  QueryClassification _buildClassification({
    required String query,
    required String normalizedQuery,
    required PatternMatch match,
  }) {
    final category = KnowledgeCategoryExtension.fromId(match.categoryId)
        ?? KnowledgeCategory.general;

    // Extract entity ID based on category
    String? entityId;
    String? entityType;

    if (category == KnowledgeCategory.thirukkural) {
      final extracted = _extractKuralNumber(normalizedQuery);
      if (extracted != null) {
        entityId = extracted.toString();
        entityType = 'kural_number';
      }
    }

    return QueryClassification(
      type: match.queryType,
      category: category,
      confidence: match.priority / 100.0,
      query: query,
      entityId: entityId,
      entityType: entityType,
      matchedPattern: match.pattern,
    );
  }

  /// Classify using built-in patterns (fallback)
  QueryClassification _classifyWithBuiltInPatterns(
    String query,
    String normalizedQuery,
  ) {
    // Check for Thirukkural patterns
    final kuralNum = _extractKuralNumber(normalizedQuery);
    if (kuralNum != null) {
      // Check if asking for explanation (hybrid) or just the kural (deterministic)
      final needsExplanation = _needsExplanation(normalizedQuery);
      return QueryClassification(
        type: needsExplanation ? QueryType.hybrid : QueryType.deterministic,
        category: KnowledgeCategory.thirukkural,
        confidence: 0.9,
        query: query,
        entityId: kuralNum.toString(),
        entityType: 'kural_number',
      );
    }

    // Check for emergency patterns
    if (_isEmergencyQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.emergency,
        confidence: 0.85,
        query: query,
      );
    }

    // Check for scheme patterns
    if (_isSchemeQuery(normalizedQuery)) {
      final needsExplanation = _needsExplanation(normalizedQuery);
      return QueryClassification(
        type: needsExplanation ? QueryType.hybrid : QueryType.deterministic,
        category: KnowledgeCategory.schemes,
        confidence: 0.8,
        query: query,
      );
    }

    // Check for hospital/health patterns
    if (_isHealthQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.health,
        confidence: 0.8,
        query: query,
      );
    }

    // Check for scam/safety patterns
    if (_isSafetyQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.hybrid,
        category: KnowledgeCategory.safety,
        confidence: 0.75,
        query: query,
      );
    }

    // Check for general AI-required patterns
    if (_requiresAiResponse(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.aiRequired,
        category: KnowledgeCategory.general,
        confidence: 0.6,
        query: query,
      );
    }

    // Default: try hybrid approach
    return QueryClassification(
      type: QueryType.hybrid,
      category: KnowledgeCategory.general,
      confidence: 0.5,
      query: query,
    );
  }

  /// Tamil ordinal to number mapping
  static const Map<String, int> _tamilOrdinals = {
    'முதல்': 1,
    'முதலாம்': 1,
    'first': 1,
    'இரண்டாம்': 2,
    'இரண்டாவது': 2,
    'second': 2,
    'மூன்றாம்': 3,
    'மூன்றாவது': 3,
    'third': 3,
    'நான்காம்': 4,
    'நான்காவது': 4,
    'ஐந்தாம்': 5,
    'ஆறாம்': 6,
    'ஏழாம்': 7,
    'எட்டாம்': 8,
    'ஒன்பதாம்': 9,
    'பத்தாம்': 10,
    'கடைசி': 1330,
    'last': 1330,
  };

  /// Extract Thirukkural number from query
  int? _extractKuralNumber(String query) {
    // First check for Tamil ordinals like "முதல் குறள்", "கடைசி குறள்"
    for (final entry in _tamilOrdinals.entries) {
      if (query.contains(entry.key)) {
        return entry.value;
      }
    }

    // Match patterns like "குறள் 42", "kural 42", "thirukkural 42", "#42"
    final patterns = [
      RegExp(r'குறள்\s*(\d+)'),
      RegExp(r'kural\s*(\d+)', caseSensitive: false),
      RegExp(r'thirukkural\s*(\d+)', caseSensitive: false),
      RegExp(r'#(\d+)'),
      RegExp(r'^(\d+)$'), // Just a number
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(query);
      if (match != null) {
        final num = int.tryParse(match.group(1)!);
        if (num != null && num >= 1 && num <= 1330) {
          return num;
        }
      }
    }
    return null;
  }

  /// Check if query needs explanation (AI enhancement)
  bool _needsExplanation(String query) {
    final explanationPatterns = [
      'விளக்கம்', 'விளக்கு', 'அர்த்தம்', 'பொருள்',
      'explain', 'meaning', 'what does', 'why',
      'எப்படி', 'ஏன்', 'how', 'tell me more',
      'elaborate', 'detail', 'விரிவாக',
    ];
    return explanationPatterns.any((p) => query.contains(p));
  }

  /// Check if this is an emergency-related query
  bool _isEmergencyQuery(String query) {
    final patterns = [
      'அவசர', 'emergency', 'ஆம்புலன்ஸ்', 'ambulance',
      'போலீஸ்', 'police', 'தீ', 'fire', '108', '100', '101',
      'helpline', 'உதவி எண்', 'accident', 'விபத்து',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if this is a scheme-related query
  bool _isSchemeQuery(String query) {
    final patterns = [
      'திட்டம்', 'scheme', 'cmchis', 'ஆயுஷ்மான்', 'ayushman',
      'முத்ரா', 'mudra', 'கிசான்', 'kisan', 'ஓய்வூதியம்', 'pension',
      'மகளிர் உரிமை', 'சலுகை', 'subsidy', 'அரசு உதவி', 'welfare',
      'eligibility', 'தகுதி', 'documents', 'ஆவணங்கள்',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if this is a health/hospital query
  bool _isHealthQuery(String query) {
    final patterns = [
      'மருத்துவமனை', 'hospital', 'doctor', 'மருத்துவர்',
      'clinic', 'phc', 'ஆரம்ப சுகாதார', 'அரசு மருத்துவமனை',
      'health center', 'medical',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if this is a safety/scam query
  bool _isSafetyQuery(String query) {
    final patterns = [
      'மோசடி', 'scam', 'fraud', 'ஏமாற்று', 'otp',
      'வங்கி மோசடி', 'bank fraud', 'பாதுகாப்பு', 'safety',
      'fake', 'போலி', 'cheating',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if query requires AI response
  bool _requiresAiResponse(String query) {
    final aiPatterns = [
      'எப்படி', 'how to', 'how do', 'ஏன்', 'why',
      'what if', 'என்றால்', 'suggest', 'பரிந்துரை',
      'recommend', 'compare', 'ஒப்பிடு', 'difference',
      'வேறுபாடு', 'best', 'சிறந்த', 'should i',
      'help me', 'உதவி', 'advice', 'ஆலோசனை',
      'opinion', 'கருத்து', 'think', 'நினை',
    ];
    return aiPatterns.any((p) => query.contains(p));
  }

  /// Clear cached patterns (call when patterns are updated)
  void clearCache() {
    _cachedPatterns = null;
    _compiledPatterns.clear();
  }

  /// Get routing statistics for debugging
  Future<Map<String, dynamic>> getRoutingStats() async {
    _cachedPatterns ??= await _loadPatterns();

    final byCategory = <String, int>{};
    final byType = <String, int>{};

    for (final pattern in _cachedPatterns!) {
      byCategory[pattern.categoryId] =
          (byCategory[pattern.categoryId] ?? 0) + 1;
      byType[pattern.responseType] =
          (byType[pattern.responseType] ?? 0) + 1;
    }

    return {
      'totalPatterns': _cachedPatterns!.length,
      'byCategory': byCategory,
      'byType': byType,
    };
  }
}
