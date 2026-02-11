/// Thirukkural Model
///
/// Represents a single Thirukkural verse with metadata.

class Thirukkural {
  final int kuralNumber;
  final String verseLine1;
  final String verseLine2;
  final String verseFull;
  final String paal;
  final String paalEnglish;
  final String iyal;
  final String athikaram;
  final String athikaramEnglish;
  final int athikaramNumber;
  final String? meaningTamil;
  final String? meaningEnglish;
  final String? keywordsTamil;
  final String? keywordsEnglish;

  const Thirukkural({
    required this.kuralNumber,
    required this.verseLine1,
    required this.verseLine2,
    required this.verseFull,
    required this.paal,
    required this.paalEnglish,
    required this.iyal,
    required this.athikaram,
    required this.athikaramEnglish,
    required this.athikaramNumber,
    this.meaningTamil,
    this.meaningEnglish,
    this.keywordsTamil,
    this.keywordsEnglish,
  });

  /// Create from database map
  factory Thirukkural.fromMap(Map<String, dynamic> map) {
    return Thirukkural(
      kuralNumber: map['kural_number'] as int,
      verseLine1: map['verse_line1'] as String,
      verseLine2: map['verse_line2'] as String,
      verseFull: map['verse_full'] as String,
      paal: map['paal'] as String,
      paalEnglish: map['paal_english'] as String,
      iyal: map['iyal'] as String? ?? '',
      athikaram: map['athikaram'] as String,
      athikaramEnglish: map['athikaram_english'] as String,
      athikaramNumber: map['athikaram_number'] as int,
      meaningTamil: map['meaning_tamil'] as String?,
      meaningEnglish: map['meaning_english'] as String?,
      keywordsTamil: map['keywords_tamil'] as String?,
      keywordsEnglish: map['keywords_english'] as String?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'kural_number': kuralNumber,
      'verse_line1': verseLine1,
      'verse_line2': verseLine2,
      'verse_full': verseFull,
      'paal': paal,
      'paal_english': paalEnglish,
      'iyal': iyal,
      'athikaram': athikaram,
      'athikaram_english': athikaramEnglish,
      'athikaram_number': athikaramNumber,
      'meaning_tamil': meaningTamil,
      'meaning_english': meaningEnglish,
      'keywords_tamil': keywordsTamil,
      'keywords_english': keywordsEnglish,
    };
  }

  /// Get formatted verse for display
  String get formattedVerse => '$verseLine1\n$verseLine2';

  /// Get chapter info
  String get chapterInfo => '$athikaram ($athikaramEnglish)';

  /// Get section info
  String get sectionInfo => iyal.isNotEmpty ? '$paal - $iyal' : paal;

  @override
  String toString() => 'Thirukkural #$kuralNumber: $verseLine1...';
}

/// Athikaram (Chapter) summary
class Athikaram {
  final int number;
  final String nameTamil;
  final String nameEnglish;
  final String paal;
  final String paalEnglish;

  const Athikaram({
    required this.number,
    required this.nameTamil,
    required this.nameEnglish,
    required this.paal,
    required this.paalEnglish,
  });

  factory Athikaram.fromMap(Map<String, dynamic> map) {
    return Athikaram(
      number: map['athikaram_number'] as int,
      nameTamil: map['athikaram'] as String,
      nameEnglish: map['athikaram_english'] as String,
      paal: map['paal'] as String,
      paalEnglish: map['paal_english'] as String,
    );
  }

  /// Get kural number range for this chapter
  int get startKural => (number - 1) * 10 + 1;
  int get endKural => number * 10;
}
