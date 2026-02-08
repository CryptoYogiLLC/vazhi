/// Query Result Models
///
/// Models for query classification and routing in the hybrid architecture.

/// Type of query handling required
enum QueryType {
  /// Can be answered entirely from SQLite database (no model needed)
  deterministic,

  /// Requires AI/LLM for response generation (model required)
  aiRequired,

  /// Combines database lookup with AI enhancement
  hybrid,
}

/// Knowledge category for routing
enum KnowledgeCategory {
  thirukkural,
  schemes,
  emergency,
  health,
  festivals,
  siddhars,
  safety,
  general,
}

extension KnowledgeCategoryExtension on KnowledgeCategory {
  String get id {
    switch (this) {
      case KnowledgeCategory.thirukkural:
        return 'thirukkural';
      case KnowledgeCategory.schemes:
        return 'schemes';
      case KnowledgeCategory.emergency:
        return 'emergency';
      case KnowledgeCategory.health:
        return 'health';
      case KnowledgeCategory.festivals:
        return 'festivals';
      case KnowledgeCategory.siddhars:
        return 'siddhars';
      case KnowledgeCategory.safety:
        return 'safety';
      case KnowledgeCategory.general:
        return 'general';
    }
  }

  String get nameTamil {
    switch (this) {
      case KnowledgeCategory.thirukkural:
        return 'திருக்குறள்';
      case KnowledgeCategory.schemes:
        return 'அரசு திட்டங்கள்';
      case KnowledgeCategory.emergency:
        return 'அவசர தொடர்பு';
      case KnowledgeCategory.health:
        return 'மருத்துவமனைகள்';
      case KnowledgeCategory.festivals:
        return 'திருவிழாக்கள்';
      case KnowledgeCategory.siddhars:
        return 'சித்தர்கள்';
      case KnowledgeCategory.safety:
        return 'பாதுகாப்பு';
      case KnowledgeCategory.general:
        return 'பொது';
    }
  }

  static KnowledgeCategory? fromId(String? id) {
    if (id == null) return null;
    switch (id) {
      case 'thirukkural':
        return KnowledgeCategory.thirukkural;
      case 'schemes':
        return KnowledgeCategory.schemes;
      case 'emergency':
        return KnowledgeCategory.emergency;
      case 'health':
        return KnowledgeCategory.health;
      case 'festivals':
        return KnowledgeCategory.festivals;
      case 'siddhars':
        return KnowledgeCategory.siddhars;
      case 'safety':
        return KnowledgeCategory.safety;
      default:
        return KnowledgeCategory.general;
    }
  }
}

/// Result of query classification
class QueryClassification {
  /// The type of handling required
  final QueryType type;

  /// Detected knowledge category
  final KnowledgeCategory category;

  /// Confidence score (0.0 - 1.0)
  final double confidence;

  /// Extracted entity ID (e.g., kural number, scheme ID)
  final String? entityId;

  /// Extracted entity type (e.g., 'kural_number', 'scheme_id')
  final String? entityType;

  /// Original query text
  final String query;

  /// Matched pattern (for debugging)
  final String? matchedPattern;

  const QueryClassification({
    required this.type,
    required this.category,
    required this.confidence,
    required this.query,
    this.entityId,
    this.entityType,
    this.matchedPattern,
  });

  /// Check if this query can be answered without the model
  bool get canAnswerWithoutModel => type == QueryType.deterministic;

  /// Check if model is required for this query
  bool get requiresModel => type == QueryType.aiRequired;

  /// Check if this is a hybrid query (database + AI)
  bool get isHybrid => type == QueryType.hybrid;

  @override
  String toString() {
    return 'QueryClassification(type: $type, category: $category, '
        'confidence: $confidence, entityId: $entityId)';
  }
}

/// Pattern match result from database
class PatternMatch {
  final String pattern;
  final String categoryId;
  final int priority;
  final String responseType;

  const PatternMatch({
    required this.pattern,
    required this.categoryId,
    required this.priority,
    required this.responseType,
  });

  factory PatternMatch.fromMap(Map<String, dynamic> map) {
    return PatternMatch(
      pattern: map['pattern'] as String,
      categoryId: map['category_id'] as String,
      priority: map['priority'] as int,
      responseType: map['response_type'] as String,
    );
  }

  QueryType get queryType {
    switch (responseType) {
      case 'deterministic':
        return QueryType.deterministic;
      case 'hybrid':
        return QueryType.hybrid;
      case 'ai':
      default:
        return QueryType.aiRequired;
    }
  }
}
