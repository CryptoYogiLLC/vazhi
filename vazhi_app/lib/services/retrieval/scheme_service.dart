/// Scheme Retrieval Service
///
/// Handles deterministic retrieval of government schemes, eligibility, and documents.
library;

import '../../database/knowledge_database.dart';
import '../../models/scheme.dart';
import '../../models/query_result.dart';
import 'retrieval_service.dart';

class SchemeService extends RetrievalService {
  @override
  KnowledgeCategory get category => KnowledgeCategory.schemes;

  /// Get a specific scheme by ID
  Future<RetrievalResult<Scheme>> getById(String schemeId) async {
    try {
      final map = await KnowledgeDatabase.getSchemeById(schemeId);
      if (map == null) {
        return RetrievalResult.notFound(
          category: category,
          message: 'திட்டம் கிடைக்கவில்லை (Scheme not found)',
        );
      }

      final scheme = Scheme.fromMap(map);

      // Load eligibility and documents
      final eligibility = await KnowledgeDatabase.getSchemeEligibility(
        schemeId,
      );
      scheme.eligibility = eligibility
          .map((m) => SchemeEligibility.fromMap(m))
          .toList();

      final documents = await KnowledgeDatabase.getSchemeDocuments(schemeId);
      scheme.documents = documents
          .map((m) => SchemeDocument.fromMap(m))
          .toList();

      return RetrievalResult.found(
        scheme,
        category: category,
        displayTitle: scheme.nameEnglish,
        formattedResponse: formatForDisplay(scheme),
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  /// Get all schemes
  Future<RetrievalResult<Scheme>> getAllSchemes({
    bool activeOnly = true,
  }) async {
    try {
      final results = await KnowledgeDatabase.getAllSchemes(
        activeOnly: activeOnly,
      );
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: 'திட்டங்கள் கிடைக்கவில்லை',
        );
      }

      final schemes = results.map((m) => Scheme.fromMap(m)).toList();
      return RetrievalResult.list(
        schemes,
        category: category,
        displayTitle: 'அரசு திட்டங்கள் (${schemes.length})',
        formattedResponse: _formatSchemeListResponse(schemes),
        totalCount: schemes.length,
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  /// Get schemes by level (state/central)
  Future<RetrievalResult<Scheme>> getByLevel(String level) async {
    try {
      final results = await KnowledgeDatabase.getAllSchemes(level: level);
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: '$level திட்டங்கள் கிடைக்கவில்லை',
        );
      }

      final schemes = results.map((m) => Scheme.fromMap(m)).toList();
      final levelName = level == 'state' ? 'மாநில' : 'மத்திய';

      return RetrievalResult.list(
        schemes,
        category: category,
        displayTitle: '$levelName அரசு திட்டங்கள் (${schemes.length})',
        formattedResponse: _formatSchemeListResponse(schemes),
        totalCount: schemes.length,
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  /// Search schemes
  @override
  Future<RetrievalResult<Scheme>> search(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) {
      return getAllSchemes();
    }

    try {
      // Get all schemes and filter locally (since we don't have a specific search method)
      final results = await KnowledgeDatabase.getAllSchemes();
      final queryLower = query.toLowerCase();

      final filtered = results.where((m) {
        final nameTamil = (m['name_tamil'] as String?)?.toLowerCase() ?? '';
        final nameEnglish = (m['name_english'] as String?)?.toLowerCase() ?? '';
        final descTamil =
            (m['description_tamil'] as String?)?.toLowerCase() ?? '';
        final descEnglish =
            (m['description_english'] as String?)?.toLowerCase() ?? '';

        return nameTamil.contains(queryLower) ||
            nameEnglish.contains(queryLower) ||
            descTamil.contains(queryLower) ||
            descEnglish.contains(queryLower);
      }).toList();

      if (filtered.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message:
              '"$query" க்கான திட்டங்கள் கிடைக்கவில்லை\n'
              '(No schemes found for "$query")',
        );
      }

      final schemes = filtered.map((m) => Scheme.fromMap(m)).toList();
      return RetrievalResult.list(
        schemes,
        category: category,
        displayTitle: '"$query" - ${schemes.length} திட்டங்கள்',
        formattedResponse: _formatSchemeListResponse(schemes),
        totalCount: schemes.length,
      );
    } catch (e) {
      return RetrievalResult.error('தேடல் பிழை: $e', category: category);
    }
  }

  /// Get scheme eligibility
  Future<RetrievalResult<SchemeEligibility>> getEligibility(
    String schemeId,
  ) async {
    try {
      final results = await KnowledgeDatabase.getSchemeEligibility(schemeId);
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: 'தகுதி விவரங்கள் கிடைக்கவில்லை',
        );
      }

      final eligibility = results
          .map((m) => SchemeEligibility.fromMap(m))
          .toList();
      return RetrievalResult.list(
        eligibility,
        category: category,
        displayTitle: 'தகுதி அளவுகோல்',
        formattedResponse: _formatEligibilityResponse(eligibility),
        totalCount: eligibility.length,
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  /// Get required documents for a scheme
  Future<RetrievalResult<SchemeDocument>> getDocuments(String schemeId) async {
    try {
      final results = await KnowledgeDatabase.getSchemeDocuments(schemeId);
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: 'ஆவண விவரங்கள் கிடைக்கவில்லை',
        );
      }

      final documents = results.map((m) => SchemeDocument.fromMap(m)).toList();
      return RetrievalResult.list(
        documents,
        category: category,
        displayTitle: 'தேவையான ஆவணங்கள்',
        formattedResponse: _formatDocumentsResponse(documents),
        totalCount: documents.length,
      );
    } catch (e) {
      return RetrievalResult.error('தரவுத்தளப் பிழை: $e', category: category);
    }
  }

  @override
  String formatForDisplay(dynamic item) {
    if (item is! Scheme) return item.toString();
    return _formatSchemeResponse(item);
  }

  /// Format a single scheme for display
  String _formatSchemeResponse(Scheme scheme) {
    final buffer = StringBuffer();

    buffer.writeln('🏛️ **${scheme.nameTamil}**');
    buffer.writeln(scheme.nameEnglish);
    buffer.writeln();
    buffer.writeln(scheme.descriptionTamil);
    buffer.writeln();

    // Level badge
    final levelBadge = scheme.level == 'state'
        ? '🏢 மாநில அரசு'
        : '🏛️ மத்திய அரசு';
    buffer.writeln('$levelBadge | ${scheme.department ?? ""}');
    buffer.writeln();

    // Eligibility
    if (scheme.eligibility != null && scheme.eligibility!.isNotEmpty) {
      buffer.writeln('---');
      buffer.writeln('### 📋 தகுதி அளவுகோல்');
      buffer.writeln();
      for (final e in scheme.eligibility!) {
        buffer.writeln('• ${e.criteriaTamil}');
      }
      buffer.writeln();
    }

    // Documents
    if (scheme.documents != null && scheme.documents!.isNotEmpty) {
      buffer.writeln('---');
      buffer.writeln('### 📄 தேவையான ஆவணங்கள்');
      buffer.writeln();
      for (final d in scheme.documents!) {
        final mandatory = d.isMandatory ? '(அவசியம்)' : '(விருப்பம்)';
        buffer.writeln('• ${d.documentTamil} $mandatory');
      }
      buffer.writeln();
    }

    // Application URL
    if (scheme.applicationUrl != null) {
      buffer.writeln('---');
      buffer.writeln('🔗 [மேலும் விவரங்கள்](${scheme.applicationUrl})');
    }

    return buffer.toString();
  }

  /// Format list of schemes
  String _formatSchemeListResponse(List<Scheme> schemes) {
    final buffer = StringBuffer();

    buffer.writeln('🏛️ **அரசு திட்டங்கள் (${schemes.length})**');
    buffer.writeln();

    // Group by level
    final stateSchemes = schemes.where((s) => s.level == 'state').toList();
    final centralSchemes = schemes.where((s) => s.level == 'central').toList();

    if (stateSchemes.isNotEmpty) {
      buffer.writeln('### 🏢 மாநில அரசு திட்டங்கள்');
      buffer.writeln();
      for (final scheme in stateSchemes) {
        buffer.writeln('• **${scheme.nameTamil}**');
        final desc = scheme.descriptionTamil;
        buffer.writeln(
          '  ${desc.length > 80 ? desc.substring(0, 80) : desc}...',
        );
        buffer.writeln();
      }
    }

    if (centralSchemes.isNotEmpty) {
      buffer.writeln('### 🏛️ மத்திய அரசு திட்டங்கள்');
      buffer.writeln();
      for (final scheme in centralSchemes) {
        buffer.writeln('• **${scheme.nameTamil}**');
        final desc = scheme.descriptionTamil;
        buffer.writeln(
          '  ${desc.length > 80 ? desc.substring(0, 80) : desc}...',
        );
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// Format eligibility criteria
  String _formatEligibilityResponse(List<SchemeEligibility> eligibility) {
    final buffer = StringBuffer();

    buffer.writeln('📋 **தகுதி அளவுகோல்**');
    buffer.writeln();

    for (final e in eligibility) {
      buffer.writeln('• ${e.criteriaTamil}');
      buffer.writeln('  (${e.criteriaEnglish})');
    }

    return buffer.toString();
  }

  /// Format required documents
  String _formatDocumentsResponse(List<SchemeDocument> documents) {
    final buffer = StringBuffer();

    buffer.writeln('📄 **தேவையான ஆவணங்கள்**');
    buffer.writeln();

    final mandatory = documents.where((d) => d.isMandatory).toList();
    final optional = documents.where((d) => !d.isMandatory).toList();

    if (mandatory.isNotEmpty) {
      buffer.writeln('**அவசியம்:**');
      for (final d in mandatory) {
        buffer.writeln('• ${d.documentTamil}');
      }
      buffer.writeln();
    }

    if (optional.isNotEmpty) {
      buffer.writeln('**விருப்பம்:**');
      for (final d in optional) {
        buffer.writeln('• ${d.documentTamil}');
      }
    }

    return buffer.toString();
  }
}
