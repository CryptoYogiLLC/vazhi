/// Query Router Service
///
/// Routes user queries to deterministic (SQLite) or AI (LLM) paths
/// based on pattern matching and query classification.
library;

import '../database/knowledge_database.dart';
import '../models/query_result.dart';

/// Exception for invalid regex patterns
class InvalidPatternException implements Exception {
  final String message;
  InvalidPatternException(this.message);
  @override
  String toString() => 'InvalidPatternException: $message';
}

class QueryRouter {
  // Cached patterns from database
  List<PatternMatch>? _cachedPatterns;

  // Compiled regex patterns
  final Map<String, RegExp> _compiledPatterns = {};

  // Input limits
  static const int _maxQueryLength = 500;
  static const int _maxPatternLength = 200;

  /// Classify a query and determine routing
  Future<QueryClassification> classify(String query) async {
    // Validate and sanitize input
    final sanitizedQuery = _sanitizeQuery(query);
    if (sanitizedQuery.isEmpty) {
      return QueryClassification(
        type: QueryType.aiRequired,
        category: KnowledgeCategory.general,
        confidence: 0.0,
        query: query,
      );
    }

    final normalizedQuery = _normalizeQuery(sanitizedQuery);

    // Try to match against database patterns first
    final dbMatch = await _matchDatabasePatterns(normalizedQuery);
    if (dbMatch != null) {
      return _buildClassification(
        query: sanitizedQuery,
        normalizedQuery: normalizedQuery,
        match: dbMatch,
      );
    }

    // Fall back to built-in pattern matching
    return _classifyWithBuiltInPatterns(sanitizedQuery, normalizedQuery);
  }

  /// Sanitize user query to prevent injection and DoS
  String _sanitizeQuery(String query) {
    // Truncate if too long
    if (query.length > _maxQueryLength) {
      query = query.substring(0, _maxQueryLength);
    }
    // Remove null bytes and control characters
    return query.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '').trim();
  }

  /// Normalize query for matching
  String _normalizeQuery(String query) {
    return query.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
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

  /// Get or compile a regex pattern with validation
  RegExp _getCompiledPattern(String pattern) {
    return _compiledPatterns.putIfAbsent(pattern, () {
      // Validate pattern length
      if (pattern.length > _maxPatternLength) {
        throw InvalidPatternException(
          'Pattern too long: ${pattern.length} chars',
        );
      }

      // Check for ReDoS patterns (nested quantifiers, catastrophic backtracking)
      if (_isPotentialReDoS(pattern)) {
        throw InvalidPatternException('Potential ReDoS pattern detected');
      }

      return RegExp(pattern, caseSensitive: false);
    });
  }

  /// Check for patterns that could cause ReDoS (Regular expression Denial of Service)
  bool _isPotentialReDoS(String pattern) {
    // Detect nested quantifiers like (a+)+ or (a*)*
    if (RegExp(r'\([^)]*[+*]\)[+*]').hasMatch(pattern)) {
      return true;
    }
    // Detect alternation with overlapping patterns like (a|a)+
    if (RegExp(r'\([^)]*\|[^)]*\)[+*]').hasMatch(pattern)) {
      return true;
    }
    // Detect deeply nested groups
    final openParens = pattern.split('(').length - 1;
    if (openParens > 5) {
      return true;
    }
    return false;
  }

  /// Build classification from pattern match
  QueryClassification _buildClassification({
    required String query,
    required String normalizedQuery,
    required PatternMatch match,
  }) {
    final category =
        KnowledgeCategoryExtension.fromId(match.categoryId) ??
        KnowledgeCategory.general;

    // Extract entity ID based on category
    String? entityId;
    String? entityType;

    if (category == KnowledgeCategory.thirukkural) {
      // Check athikaram number first (more specific), then kural number
      final athikaramNum = _extractAthikaramNumber(normalizedQuery);
      if (athikaramNum != null) {
        entityId = athikaramNum.toString();
        entityType = 'athikaram_number';
      } else {
        final kuralNum = _extractKuralNumber(normalizedQuery);
        if (kuralNum != null) {
          entityId = kuralNum.toString();
          entityType = 'kural_number';
        }
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
    // Check for athikaram (chapter) number first — "அதிகாரம் 5", "athikaram 5"
    final athikaramNum = _extractAthikaramNumber(normalizedQuery);
    if (athikaramNum != null) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.thirukkural,
        confidence: 0.95,
        query: query,
        entityId: athikaramNum.toString(),
        entityType: 'athikaram_number',
      );
    }

    // Check for kural number — "குறள் 42", "kural 42"
    final kuralNum = _extractKuralNumber(normalizedQuery);
    if (kuralNum != null) {
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
    if (_isThirukkuralQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.thirukkural,
        confidence: 0.85,
        query: query,
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

    // All knowledge category matches route to deterministic (SQLite-first).
    // Order matters: more specific categories first to avoid misclassification
    // (e.g., "IIT eligibility" should match education, not schemes).

    // Education before schemes — "eligibility" is in both, but IIT/NEET/etc.
    // are specific to education and should take priority.
    if (_isEducationQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.education,
        confidence: 0.85,
        query: query,
      );
    }

    if (_isSafetyQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.safety,
        confidence: 0.85,
        query: query,
      );
    }

    if (_isHealthQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.health,
        confidence: 0.8,
        query: query,
      );
    }

    if (_isSchemeQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.schemes,
        confidence: 0.8,
        query: query,
      );
    }

    if (_isLegalQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.legal,
        confidence: 0.85,
        query: query,
      );
    }

    if (_isSiddhaMedicineQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.siddhaMedicine,
        confidence: 0.85,
        query: query,
      );
    }

    if (_isFestivalQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.festivals,
        confidence: 0.85,
        query: query,
      );
    }

    if (_isSiddharQuery(normalizedQuery)) {
      return QueryClassification(
        type: QueryType.deterministic,
        category: KnowledgeCategory.siddhars,
        confidence: 0.85,
        query: query,
      );
    }

    // Default: try hybrid approach — SQLite FTS5 may still find results.
    // Don't classify as aiRequired just because the query contains "how"/"why"
    // — the hybrid_chat_provider will show SQLite results if found,
    // and only fall back to AI if SQLite has nothing.
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

  /// Extract athikaram (chapter) number from query
  int? _extractAthikaramNumber(String query) {
    final patterns = [
      RegExp(r'அதிகாரம்\s*(\d+)'),
      RegExp(r'athikaram\s*(\d+)', caseSensitive: false),
      RegExp(r'chapter\s*(\d+)', caseSensitive: false),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(query);
      if (match != null) {
        final num = int.tryParse(match.group(1)!);
        if (num != null && num >= 1 && num <= 133) {
          return num;
        }
      }
    }
    return null;
  }

  /// Check if this is a general Thirukkural query (without a specific number)
  bool _isThirukkuralQuery(String query) {
    final patterns = [
      'thirukkural',
      'thirukural',
      'tirukkural',
      'திருக்குறள்',
      'குறள்',
      'kural',
      'valluvar',
      'வள்ளுவர்',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if query needs explanation (AI enhancement)
  bool _needsExplanation(String query) {
    final explanationPatterns = [
      'விளக்கம்',
      'விளக்கு',
      'அர்த்தம்',
      'பொருள்',
      'explain',
      'meaning',
      'what does',
      'why',
      'எப்படி',
      'ஏன்',
      'how',
      'tell me more',
      'elaborate',
      'detail',
      'விரிவாக',
    ];
    return explanationPatterns.any((p) => query.contains(p));
  }

  /// Check if this is an emergency-related query
  bool _isEmergencyQuery(String query) {
    final patterns = [
      'அவசர',
      'emergency',
      'ஆம்புலன்ஸ்',
      'ambulance',
      'போலீஸ்',
      'police',
      'தீ',
      'fire',
      '108',
      '100',
      '101',
      'helpline',
      'உதவி எண்',
      'accident',
      'விபத்து',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if this is a scheme-related query
  bool _isSchemeQuery(String query) {
    final patterns = [
      'திட்டம்',
      'scheme',
      'cmchis',
      'ஆயுஷ்மான்',
      'ayushman',
      'முத்ரா',
      'mudra',
      'கிசான்',
      'kisan',
      'ஓய்வூதியம்',
      'pension',
      'மகளிர் உரிமை',
      'சலுகை',
      'subsidy',
      'அரசு உதவி',
      'welfare',
      'documents',
      'ஆவணங்கள்',
      'ration card',
      'ரேஷன்',
      'free treatment',
      'இலவச',
      'pm kisan',
      'government',
      'அரசு',
      'benefit',
      'பயன்',
      'apply',
      'விண்ணப்பம்',
      'birth certificate',
      'பிறப்பு சான்றிதழ்',
      'death certificate',
      'community certificate',
      'சாதி சான்றிதழ்',
      'income certificate',
      'வருமான சான்றிதழ்',
      'certificate',
      'சான்றிதழ்',
      'aadhar',
      'aadhaar',
      'ஆதார்',
      'voter id',
      'வாக்காளர்',
      'pan card',
      'passport',
      'பாஸ்போர்ட்',
      'driving license',
      'ration',
      'ரேஷன்',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if this is a health/hospital query
  bool _isHealthQuery(String query) {
    final patterns = [
      'மருத்துவமனை',
      'hospital',
      'doctor',
      'மருத்துவர்',
      'clinic',
      'phc',
      'ஆரம்ப சுகாதார',
      'அரசு மருத்துவமனை',
      'health center',
      'medical',
      'health',
      'சுகாதாரம்',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if this is a safety/scam query
  bool _isSafetyQuery(String query) {
    final patterns = [
      'மோசடி',
      'scam',
      'fraud',
      'ஏமாற்று',
      'otp',
      'வங்கி மோசடி',
      'bank fraud',
      'பாதுகாப்பு',
      'safety',
      'fake',
      'போலி',
      'cheating',
      'phishing',
      'ஃபிஷிங்',
      'hacking',
      'cyber',
      'சைபர்',
      'password',
      'கடவுச்சொல்',
      'spam',
      'virus',
      'malware',
      'identity theft',
      'online safety',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if this is an education query (scholarships, exams)
  bool _isEducationQuery(String query) {
    final patterns = [
      'scholarship',
      'உதவித்தொகை',
      'exam',
      'தேர்வு',
      'neet',
      'jee',
      'tnpsc',
      'upsc',
      'competitive',
      'போட்டி',
      'entrance',
      'நுழைவு',
      'bank exam',
      'ssc',
      'gate',
      'cat',
      'engineering',
      'பொறியியல்',
      'medical',
      'mbbs',
      'college',
      'கல்லூரி',
      'education',
      'கல்வி',
      'study',
      'படிப்பு',
      'course',
      'career',
      'options',
      'iit',
      'nit',
      'anna university',
      'அண்ணா பல்கலை',
      'eligibility',
      'தகுதி',
      'plus two',
      'plus-2',
      'plus 2',
      '+2',
      '12th',
      'பன்னிரண்டாம்',
      '10th',
      'பத்தாம்',
      'sslc',
      'hsc',
      'degree',
      'பட்டம்',
      'diploma',
      'polytechnic',
      'university',
      'பல்கலை',
      'school',
      'பள்ளி',
      'coaching',
      'tuition',
      'after',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if this is a legal query
  bool _isLegalQuery(String query) {
    final patterns = [
      'legal',
      'சட்ட',
      'right',
      'உரிமை',
      'rti',
      'fir',
      'consumer',
      'நுகர்வோர்',
      'template',
      'மாதிரி',
      'complaint',
      'புகார்',
      'law',
      'fundamental',
      'அடிப்படை உரிமை',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if this is a siddha medicine query
  bool _isSiddhaMedicineQuery(String query) {
    final patterns = [
      'siddha',
      'சித்த மருத்துவ',
      'remedy',
      'மருந்து',
      'herbal',
      'மூலிகை',
      'ayurvedic',
      'home remedy',
      'இயற்கை மருத்துவம்',
      'nattu maruthuvam',
      'நாட்டு மருத்துவம்',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if this is a festival query
  bool _isFestivalQuery(String query) {
    final patterns = [
      'festival',
      'திருவிழா',
      'பண்டிகை',
      'pongal',
      'பொங்கல்',
      'deepavali',
      'தீபாவளி',
      'நவராத்திரி',
      'navaratri',
      'vinayagar',
      'விநாயகர்',
      'celebration',
      'கொண்டாட்டம்',
      'new year',
      'புத்தாண்டு',
      'puthandu',
      'thai pongal',
      'தைப்பொங்கல்',
      'கார்த்திகை',
      'karthigai',
      'thai pusam',
      'தைப்பூசம்',
      'chithirai',
      'சித்திரை',
      'aadi',
      'ஆடி',
      'panguni',
      'பங்குனி',
    ];
    return patterns.any((p) => query.contains(p));
  }

  /// Check if this is a siddhar query
  bool _isSiddharQuery(String query) {
    final patterns = [
      'siddhar',
      'சித்தர்',
      'agathiyar',
      'அகத்தியர்',
      'thirumoolar',
      'திருமூலர்',
      'bogar',
      'போகர்',
      'korakkar',
      'கொரக்கர்',
      '18 siddhar',
      'பதினெண் சித்தர்',
      'yoga',
      'யோகா',
      'யோகம்',
      'patanjali',
      'பதஞ்சலி',
      'pranayama',
      'பிராணாயாமம்',
      'meditation',
      'தியானம்',
      'kundalini',
      'குண்டலினி',
    ];
    return patterns.any((p) => query.contains(p));
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
      byType[pattern.responseType] = (byType[pattern.responseType] ?? 0) + 1;
    }

    return {
      'totalPatterns': _cachedPatterns!.length,
      'byCategory': byCategory,
      'byType': byType,
    };
  }
}
