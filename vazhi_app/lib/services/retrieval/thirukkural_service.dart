/// Thirukkural Retrieval Service
///
/// Handles deterministic retrieval of Thirukkural verses, athikarams, and search.

import '../../database/knowledge_database.dart';
import '../../models/thirukkural.dart';
import '../../models/query_result.dart';
import 'retrieval_service.dart';

class ThirukkuralService extends RetrievalService {
  @override
  KnowledgeCategory get category => KnowledgeCategory.thirukkural;

  /// Get a specific kural by number
  Future<RetrievalResult<Thirukkural>> getByNumber(int number) async {
    if (number < 1 || number > 1330) {
      return RetrievalResult.notFound(
        category: category,
        message: 'குறள் எண் 1 முதல் 1330 வரை இருக்க வேண்டும்\n'
            '(Kural number must be between 1 and 1330)',
      );
    }

    try {
      final map = await KnowledgeDatabase.getKuralByNumber(number);
      if (map == null) {
        return RetrievalResult.notFound(
          category: category,
          message: 'குறள் $number கிடைக்கவில்லை',
        );
      }

      final kural = Thirukkural.fromMap(map);
      return RetrievalResult.found(
        kural,
        category: category,
        displayTitle: 'குறள் $number - ${kural.athikaram}',
        formattedResponse: formatForDisplay(kural),
      );
    } catch (e) {
      return RetrievalResult.error(
        'தரவுத்தளப் பிழை: $e',
        category: category,
      );
    }
  }

  /// Get all kurals in an athikaram (chapter)
  Future<RetrievalResult<Thirukkural>> getByAthikaram(int athikaramNumber) async {
    if (athikaramNumber < 1 || athikaramNumber > 133) {
      return RetrievalResult.notFound(
        category: category,
        message: 'அதிகார எண் 1 முதல் 133 வரை இருக்க வேண்டும்\n'
            '(Athikaram number must be between 1 and 133)',
      );
    }

    try {
      final results = await KnowledgeDatabase.getKuralsByAthikaram(athikaramNumber);
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: 'அதிகாரம் $athikaramNumber கிடைக்கவில்லை',
        );
      }

      final kurals = results.map((m) => Thirukkural.fromMap(m)).toList();
      final athikaramName = kurals.first.athikaram;

      return RetrievalResult.list(
        kurals,
        category: category,
        displayTitle: 'அதிகாரம் $athikaramNumber: $athikaramName',
        formattedResponse: _formatAthikaramResponse(kurals),
        totalCount: kurals.length,
      );
    } catch (e) {
      return RetrievalResult.error(
        'தரவுத்தளப் பிழை: $e',
        category: category,
      );
    }
  }

  /// Get all athikarams (chapters)
  Future<RetrievalResult<Athikaram>> getAllAthikarams() async {
    try {
      final results = await KnowledgeDatabase.getAllAthikarams();
      final athikarams = results.map((m) => Athikaram.fromMap(m)).toList();

      return RetrievalResult.list(
        athikarams,
        category: category,
        displayTitle: 'திருக்குறள் அதிகாரங்கள் (133)',
        formattedResponse: _formatAthikaramsListResponse(athikarams),
        totalCount: athikarams.length,
      );
    } catch (e) {
      return RetrievalResult.error(
        'தரவுத்தளப் பிழை: $e',
        category: category,
      );
    }
  }

  /// Search kurals by text
  @override
  Future<RetrievalResult<Thirukkural>> search(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) {
      return RetrievalResult.notFound(
        category: category,
        message: 'தேடல் சொல்லை உள்ளிடவும்',
      );
    }

    try {
      final results = await KnowledgeDatabase.searchKurals(query);
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: '"$query" க்கான குறள்கள் கிடைக்கவில்லை\n'
              '(No kurals found for "$query")',
        );
      }

      final kurals = results.map((m) => Thirukkural.fromMap(m)).toList();
      return RetrievalResult.list(
        kurals,
        category: category,
        displayTitle: '"$query" - ${kurals.length} குறள்கள்',
        formattedResponse: _formatSearchResponse(kurals, query),
        totalCount: kurals.length,
        hasMore: kurals.length >= limit,
      );
    } catch (e) {
      return RetrievalResult.error(
        'தேடல் பிழை: $e',
        category: category,
      );
    }
  }

  /// Get random kural (for daily inspiration)
  Future<RetrievalResult<Thirukkural>> getRandomKural() async {
    final randomNumber = DateTime.now().millisecondsSinceEpoch % 1330 + 1;
    return getByNumber(randomNumber);
  }

  /// Get kurals by paal (section)
  Future<RetrievalResult<Thirukkural>> getByPaal(String paal) async {
    try {
      // Search for kurals in this paal
      final results = await KnowledgeDatabase.searchKurals(paal);
      if (results.isEmpty) {
        return RetrievalResult.notFound(
          category: category,
          message: '"$paal" பாலில் குறள்கள் கிடைக்கவில்லை',
        );
      }

      final kurals = results.map((m) => Thirukkural.fromMap(m)).toList();
      return RetrievalResult.list(
        kurals,
        category: category,
        displayTitle: '$paal',
        formattedResponse: _formatSearchResponse(kurals, paal),
        totalCount: kurals.length,
      );
    } catch (e) {
      return RetrievalResult.error(
        'தரவுத்தளப் பிழை: $e',
        category: category,
      );
    }
  }

  @override
  String formatForDisplay(dynamic item) {
    if (item is! Thirukkural) return item.toString();
    return _formatKuralResponse(item);
  }

  /// Format a single kural for display
  String _formatKuralResponse(Thirukkural kural) {
    final buffer = StringBuffer();

    buffer.writeln('📜 **குறள் ${kural.kuralNumber}**');
    buffer.writeln();
    buffer.writeln('${kural.verseLine1}');
    buffer.writeln('${kural.verseLine2}');
    buffer.writeln();
    buffer.writeln('**பொருள்:** ${kural.meaningTamil}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('📚 **அதிகாரம்:** ${kural.athikaram} (${kural.athikaramNumber})');
    buffer.writeln('📖 **பால்:** ${kural.paal}');

    return buffer.toString();
  }

  /// Format athikaram response (list of kurals in a chapter)
  String _formatAthikaramResponse(List<Thirukkural> kurals) {
    if (kurals.isEmpty) return 'குறள்கள் இல்லை';

    final first = kurals.first;
    final buffer = StringBuffer();

    buffer.writeln('📚 **அதிகாரம் ${first.athikaramNumber}: ${first.athikaram}**');
    buffer.writeln('📖 ${first.paal} | ${first.paalEnglish}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    for (final kural in kurals) {
      buffer.writeln('**குறள் ${kural.kuralNumber}:**');
      buffer.writeln('${kural.verseLine1}');
      buffer.writeln('${kural.verseLine2}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Format list of athikarams
  String _formatAthikaramsListResponse(List<Athikaram> athikarams) {
    final buffer = StringBuffer();

    buffer.writeln('📜 **திருக்குறள் - 133 அதிகாரங்கள்**');
    buffer.writeln();

    String? currentPaal;
    for (final ath in athikarams) {
      if (currentPaal != ath.paal) {
        currentPaal = ath.paal;
        buffer.writeln();
        buffer.writeln('### ${ath.paal} (${ath.paalEnglish})');
        buffer.writeln();
      }
      buffer.writeln('${ath.number}. ${ath.nameTamil}');
    }

    return buffer.toString();
  }

  /// Format search results
  String _formatSearchResponse(List<Thirukkural> kurals, String query) {
    final buffer = StringBuffer();

    buffer.writeln('🔍 **"$query" - ${kurals.length} குறள்கள்**');
    buffer.writeln();

    for (final kural in kurals.take(5)) {
      buffer.writeln('**குறள் ${kural.kuralNumber}** (${kural.athikaram}):');
      buffer.writeln('${kural.verseLine1}');
      buffer.writeln('${kural.verseLine2}');
      buffer.writeln();
    }

    if (kurals.length > 5) {
      buffer.writeln('_...மேலும் ${kurals.length - 5} குறள்கள்_');
    }

    return buffer.toString();
  }
}
