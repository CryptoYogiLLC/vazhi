/// Generic Data Service
///
/// Handles retrieval for all data categories that use direct database queries.
/// Covers: scam patterns, scholarships, exams, legal rights, legal templates,
/// siddha medicine, festivals, siddhars, cyber safety tips.
library;

import '../../database/knowledge_database.dart';
import '../../models/query_result.dart';
import 'retrieval_service.dart';

class GenericDataService {
  /// Search scam patterns
  Future<RetrievalResult<Map<String, dynamic>>> searchScams(String query) async {
    try {
      final results = await KnowledgeDatabase.searchScamPatterns(query);
      if (results.isEmpty) {
        // Fall back to getting all scam patterns
        final all = await KnowledgeDatabase.getAllScamPatterns();
        if (all.isEmpty) {
          return RetrievalResult.notFound(category: KnowledgeCategory.safety);
        }
        return RetrievalResult.list(
          all,
          category: KnowledgeCategory.safety,
          displayTitle: 'மோசடி எச்சரிக்கைகள் / Scam Alerts',
          formattedResponse: _formatScamPatterns(all),
          totalCount: all.length,
        );
      }
      return RetrievalResult.list(
        results,
        category: KnowledgeCategory.safety,
        displayTitle: 'மோசடி எச்சரிக்கைகள் / Scam Alerts',
        formattedResponse: _formatScamPatterns(results),
        totalCount: results.length,
      );
    } catch (e) {
      return RetrievalResult.error('$e', category: KnowledgeCategory.safety);
    }
  }

  /// Get cyber safety tips
  Future<RetrievalResult<Map<String, dynamic>>> getCyberSafetyTips() async {
    try {
      final results = await KnowledgeDatabase.getCyberSafetyTips();
      if (results.isEmpty) {
        return RetrievalResult.notFound(category: KnowledgeCategory.safety);
      }
      return RetrievalResult.list(
        results,
        category: KnowledgeCategory.safety,
        displayTitle: 'இணைய பாதுகாப்பு / Cyber Safety Tips',
        formattedResponse: _formatCyberSafetyTips(results),
        totalCount: results.length,
      );
    } catch (e) {
      return RetrievalResult.error('$e', category: KnowledgeCategory.safety);
    }
  }

  /// Search scholarships
  Future<RetrievalResult<Map<String, dynamic>>> searchScholarships(String query) async {
    try {
      final results = await KnowledgeDatabase.searchScholarships(query);
      if (results.isEmpty) {
        final all = await KnowledgeDatabase.getAllScholarships();
        if (all.isEmpty) {
          return RetrievalResult.notFound(category: KnowledgeCategory.education);
        }
        return RetrievalResult.list(
          all,
          category: KnowledgeCategory.education,
          displayTitle: 'உதவித்தொகைகள் / Scholarships',
          formattedResponse: _formatScholarships(all),
          totalCount: all.length,
        );
      }
      return RetrievalResult.list(
        results,
        category: KnowledgeCategory.education,
        displayTitle: 'உதவித்தொகைகள் / Scholarships',
        formattedResponse: _formatScholarships(results),
        totalCount: results.length,
      );
    } catch (e) {
      return RetrievalResult.error('$e', category: KnowledgeCategory.education);
    }
  }

  /// Search exams
  Future<RetrievalResult<Map<String, dynamic>>> searchExams(String query) async {
    try {
      final results = await KnowledgeDatabase.getAllExams();
      if (results.isEmpty) {
        return RetrievalResult.notFound(category: KnowledgeCategory.education);
      }
      return RetrievalResult.list(
        results,
        category: KnowledgeCategory.education,
        displayTitle: 'போட்டித் தேர்வுகள் / Competitive Exams',
        formattedResponse: _formatExams(results),
        totalCount: results.length,
      );
    } catch (e) {
      return RetrievalResult.error('$e', category: KnowledgeCategory.education);
    }
  }

  /// Search legal rights
  Future<RetrievalResult<Map<String, dynamic>>> searchLegalRights(String query) async {
    try {
      final results = await KnowledgeDatabase.searchLegalRights(query);
      if (results.isEmpty) {
        final all = await KnowledgeDatabase.getLegalRights();
        if (all.isEmpty) {
          return RetrievalResult.notFound(category: KnowledgeCategory.legal);
        }
        return RetrievalResult.list(
          all,
          category: KnowledgeCategory.legal,
          displayTitle: 'சட்ட உரிமைகள் / Legal Rights',
          formattedResponse: _formatLegalRights(all),
          totalCount: all.length,
        );
      }
      return RetrievalResult.list(
        results,
        category: KnowledgeCategory.legal,
        displayTitle: 'சட்ட உரிமைகள் / Legal Rights',
        formattedResponse: _formatLegalRights(results),
        totalCount: results.length,
      );
    } catch (e) {
      return RetrievalResult.error('$e', category: KnowledgeCategory.legal);
    }
  }

  /// Search legal templates
  Future<RetrievalResult<Map<String, dynamic>>> searchLegalTemplates(String query) async {
    try {
      final results = await KnowledgeDatabase.getLegalTemplates();
      if (results.isEmpty) {
        return RetrievalResult.notFound(category: KnowledgeCategory.legal);
      }
      return RetrievalResult.list(
        results,
        category: KnowledgeCategory.legal,
        displayTitle: 'சட்ட மாதிரிகள் / Legal Templates',
        formattedResponse: _formatLegalTemplates(results),
        totalCount: results.length,
      );
    } catch (e) {
      return RetrievalResult.error('$e', category: KnowledgeCategory.legal);
    }
  }

  /// Search siddha medicine
  Future<RetrievalResult<Map<String, dynamic>>> searchSiddhaMedicine(String query) async {
    try {
      final results = await KnowledgeDatabase.searchSiddhaMedicine(query);
      if (results.isEmpty) {
        final all = await KnowledgeDatabase.getSiddhaMedicine();
        if (all.isEmpty) {
          return RetrievalResult.notFound(category: KnowledgeCategory.siddhaMedicine);
        }
        return RetrievalResult.list(
          all,
          category: KnowledgeCategory.siddhaMedicine,
          displayTitle: 'சித்த மருத்துவம் / Siddha Medicine',
          formattedResponse: _formatSiddhaMedicine(all),
          totalCount: all.length,
        );
      }
      return RetrievalResult.list(
        results,
        category: KnowledgeCategory.siddhaMedicine,
        displayTitle: 'சித்த மருத்துவம் / Siddha Medicine',
        formattedResponse: _formatSiddhaMedicine(results),
        totalCount: results.length,
      );
    } catch (e) {
      return RetrievalResult.error('$e', category: KnowledgeCategory.siddhaMedicine);
    }
  }

  /// Search festivals
  Future<RetrievalResult<Map<String, dynamic>>> searchFestivals(String query) async {
    try {
      final results = await KnowledgeDatabase.searchFestivals(query);
      if (results.isEmpty) {
        final all = await KnowledgeDatabase.getAllFestivals();
        if (all.isEmpty) {
          return RetrievalResult.notFound(category: KnowledgeCategory.festivals);
        }
        return RetrievalResult.list(
          all,
          category: KnowledgeCategory.festivals,
          displayTitle: 'திருவிழாக்கள் / Festivals',
          formattedResponse: _formatFestivals(all),
          totalCount: all.length,
        );
      }
      return RetrievalResult.list(
        results,
        category: KnowledgeCategory.festivals,
        displayTitle: 'திருவிழாக்கள் / Festivals',
        formattedResponse: _formatFestivals(results),
        totalCount: results.length,
      );
    } catch (e) {
      return RetrievalResult.error('$e', category: KnowledgeCategory.festivals);
    }
  }

  /// Search siddhars
  Future<RetrievalResult<Map<String, dynamic>>> searchSiddhars(String query) async {
    try {
      final results = await KnowledgeDatabase.searchSiddhars(query);
      if (results.isEmpty) {
        final all = await KnowledgeDatabase.getAllSiddhars();
        if (all.isEmpty) {
          return RetrievalResult.notFound(category: KnowledgeCategory.siddhars);
        }
        return RetrievalResult.list(
          all,
          category: KnowledgeCategory.siddhars,
          displayTitle: 'சித்தர்கள் / Siddhars',
          formattedResponse: _formatSiddhars(all),
          totalCount: all.length,
        );
      }
      return RetrievalResult.list(
        results,
        category: KnowledgeCategory.siddhars,
        displayTitle: 'சித்தர்கள் / Siddhars',
        formattedResponse: _formatSiddhars(results),
        totalCount: results.length,
      );
    } catch (e) {
      return RetrievalResult.error('$e', category: KnowledgeCategory.siddhars);
    }
  }

  // --- Formatters ---

  String _formatScamPatterns(List<Map<String, dynamic>> items) {
    final buffer = StringBuffer();
    buffer.writeln('🛡️ **மோசடி எச்சரிக்கைகள் / Scam Alerts** (${items.length})');
    buffer.writeln();
    for (final item in items.take(5)) {
      final name = item['name_tamil'] ?? item['name_english'] ?? '';
      final type = item['type'] ?? '';
      buffer.writeln('⚠️ **$name**  ');
      if (type.isNotEmpty) buffer.writeln('வகை: $type  ');
      final desc = item['description_tamil'] ?? item['description_english'] ?? '';
      if (desc.isNotEmpty) buffer.writeln('$desc');
      buffer.writeln();
    }
    if (items.length > 5) buffer.writeln('...மேலும் ${items.length - 5} முடிவுகள்');
    return buffer.toString();
  }

  String _formatCyberSafetyTips(List<Map<String, dynamic>> items) {
    final buffer = StringBuffer();
    buffer.writeln('🔒 **இணைய பாதுகாப்பு குறிப்புகள்** (${items.length})');
    buffer.writeln();
    for (final item in items.take(5)) {
      final title = item['title_tamil'] ?? item['title_english'] ?? '';
      final desc = item['tip_tamil'] ?? item['tip_english'] ?? '';
      buffer.writeln('• **$title**  ');
      if (desc.isNotEmpty) buffer.writeln('$desc');
      buffer.writeln();
    }
    if (items.length > 5) buffer.writeln('...மேலும் ${items.length - 5} குறிப்புகள்');
    return buffer.toString();
  }

  String _formatScholarships(List<Map<String, dynamic>> items) {
    final buffer = StringBuffer();
    buffer.writeln('🎓 **உதவித்தொகைகள் / Scholarships** (${items.length})');
    buffer.writeln();
    for (final item in items.take(5)) {
      final name = item['name_tamil'] ?? item['name_english'] ?? '';
      final provider = item['provider'] ?? '';
      final amount = item['amount'] ?? '';
      buffer.writeln('📚 **$name**  ');
      if (provider.isNotEmpty) buffer.writeln('வழங்குபவர்: $provider  ');
      if (amount.isNotEmpty) buffer.writeln('தொகை: $amount');
      buffer.writeln();
    }
    if (items.length > 5) buffer.writeln('...மேலும் ${items.length - 5} உதவித்தொகைகள்');
    return buffer.toString();
  }

  String _formatExams(List<Map<String, dynamic>> items) {
    final buffer = StringBuffer();
    buffer.writeln('📝 **போட்டித் தேர்வுகள் / Competitive Exams** (${items.length})');
    buffer.writeln();
    for (final item in items.take(5)) {
      final name = item['name_tamil'] ?? item['name_english'] ?? '';
      final conductor = item['conducting_body'] ?? '';
      buffer.writeln('📋 **$name**  ');
      if (conductor.isNotEmpty) buffer.writeln('நடத்துபவர்: $conductor');
      buffer.writeln();
    }
    if (items.length > 5) buffer.writeln('...மேலும் ${items.length - 5} தேர்வுகள்');
    return buffer.toString();
  }

  String _formatLegalRights(List<Map<String, dynamic>> items) {
    final buffer = StringBuffer();
    buffer.writeln('⚖️ **சட்ட உரிமைகள் / Legal Rights** (${items.length})');
    buffer.writeln();
    for (final item in items.take(5)) {
      final name = item['title_tamil'] ?? item['title_english'] ?? '';
      final category = item['category'] ?? '';
      buffer.writeln('📜 **$name**  ');
      if (category.isNotEmpty) buffer.writeln('பிரிவு: $category');
      buffer.writeln();
    }
    if (items.length > 5) buffer.writeln('...மேலும் ${items.length - 5} உரிமைகள்');
    return buffer.toString();
  }

  String _formatLegalTemplates(List<Map<String, dynamic>> items) {
    final buffer = StringBuffer();
    buffer.writeln('📄 **சட்ட மாதிரிகள் / Legal Templates** (${items.length})');
    buffer.writeln();
    for (final item in items.take(5)) {
      final name = item['name_tamil'] ?? item['name_english'] ?? '';
      final type = item['category'] ?? '';
      buffer.writeln('📋 **$name**  ');
      if (type.isNotEmpty) buffer.writeln('வகை: $type');
      buffer.writeln();
    }
    if (items.length > 5) buffer.writeln('...மேலும் ${items.length - 5} மாதிரிகள்');
    return buffer.toString();
  }

  String _formatSiddhaMedicine(List<Map<String, dynamic>> items) {
    final buffer = StringBuffer();
    buffer.writeln('🌿 **சித்த மருத்துவம் / Siddha Medicine** (${items.length})');
    buffer.writeln();
    for (final item in items.take(5)) {
      final name = item['name_tamil'] ?? item['name_english'] ?? '';
      final use = item['traditional_use'] ?? '';
      buffer.writeln('🍃 **$name**  ');
      if (use.isNotEmpty) buffer.writeln('பயன்: $use');
      buffer.writeln();
    }
    if (items.length > 5) buffer.writeln('...மேலும் ${items.length - 5} மருந்துகள்');
    return buffer.toString();
  }

  String _formatFestivals(List<Map<String, dynamic>> items) {
    final buffer = StringBuffer();
    buffer.writeln('🎉 **திருவிழாக்கள் / Tamil Festivals** (${items.length})');
    buffer.writeln();
    for (final item in items.take(5)) {
      final name = item['name_tamil'] ?? item['name_english'] ?? '';
      final month = item['tamil_month'] ?? '';
      buffer.writeln('🪔 **$name**  ');
      if (month.isNotEmpty) buffer.writeln('மாதம்: $month');
      buffer.writeln();
    }
    if (items.length > 5) buffer.writeln('...மேலும் ${items.length - 5} திருவிழாக்கள்');
    return buffer.toString();
  }

  String _formatSiddhars(List<Map<String, dynamic>> items) {
    final buffer = StringBuffer();
    buffer.writeln('🙏 **சித்தர்கள் / Siddhars** (${items.length})');
    buffer.writeln();
    for (final item in items.take(5)) {
      final name = item['name_tamil'] ?? item['name_english'] ?? '';
      final period = item['period'] ?? '';
      buffer.writeln('🔱 **$name**  ');
      if (period.isNotEmpty) buffer.writeln('காலம்: $period');
      buffer.writeln();
    }
    if (items.length > 5) buffer.writeln('...மேலும் ${items.length - 5} சித்தர்கள்');
    return buffer.toString();
  }
}
