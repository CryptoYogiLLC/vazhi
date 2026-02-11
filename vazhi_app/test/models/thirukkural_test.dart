/// Thirukkural Model Tests
///
/// Tests for the Thirukkural and Athikaram models.

import 'package:flutter_test/flutter_test.dart';
import 'package:vazhi_app/models/thirukkural.dart';

void main() {
  group('Thirukkural', () {
    late Map<String, dynamic> sampleMap;

    setUp(() {
      sampleMap = {
        'kural_number': 1,
        'verse_line1': 'அகர முதல எழுத்தெல்லாம்',
        'verse_line2': 'ஆதி பகவன் முதற்றே உலகு',
        'verse_full': 'அகர முதல எழுத்தெல்லாம் ஆதி பகவன் முதற்றே உலகு',
        'paal': 'அறத்துப்பால்',
        'paal_english': 'Virtue',
        'iyal': 'பாயிரம்',
        'athikaram': 'கடவுள் வாழ்த்து',
        'athikaram_english': 'The Praise of God',
        'athikaram_number': 1,
        'meaning_tamil': 'எழுத்துக்களுக்கு அகரம் முதல் ஆனது போல',
        'meaning_english': 'As the letter A is the first of all letters',
        'keywords_tamil': 'அகரம், கடவுள்',
        'keywords_english': 'god, beginning',
      };
    });

    test('creates from map correctly', () {
      final kural = Thirukkural.fromMap(sampleMap);

      expect(kural.kuralNumber, 1);
      expect(kural.verseLine1, 'அகர முதல எழுத்தெல்லாம்');
      expect(kural.verseLine2, 'ஆதி பகவன் முதற்றே உலகு');
      expect(kural.paal, 'அறத்துப்பால்');
      expect(kural.athikaramNumber, 1);
    });

    test('handles null iyal field', () {
      sampleMap['iyal'] = null;
      final kural = Thirukkural.fromMap(sampleMap);

      expect(kural.iyal, isEmpty);
    });

    test('handles null meaning fields', () {
      sampleMap['meaning_tamil'] = null;
      sampleMap['meaning_english'] = null;
      final kural = Thirukkural.fromMap(sampleMap);

      expect(kural.meaningTamil, isNull);
      expect(kural.meaningEnglish, isNull);
    });

    test('toMap returns correct structure', () {
      final kural = Thirukkural.fromMap(sampleMap);
      final map = kural.toMap();

      expect(map['kural_number'], 1);
      expect(map['verse_line1'], 'அகர முதல எழுத்தெல்லாம்');
      expect(map['athikaram'], 'கடவுள் வாழ்த்து');
    });

    test('formattedVerse joins lines', () {
      final kural = Thirukkural.fromMap(sampleMap);

      expect(kural.formattedVerse, contains('\n'));
      expect(kural.formattedVerse, startsWith('அகர முதல'));
    });

    test('chapterInfo formats correctly', () {
      final kural = Thirukkural.fromMap(sampleMap);

      expect(kural.chapterInfo, 'கடவுள் வாழ்த்து (The Praise of God)');
    });

    test('sectionInfo includes iyal when present', () {
      final kural = Thirukkural.fromMap(sampleMap);

      expect(kural.sectionInfo, 'அறத்துப்பால் - பாயிரம்');
    });

    test('sectionInfo shows only paal when iyal is empty', () {
      sampleMap['iyal'] = null;
      final kural = Thirukkural.fromMap(sampleMap);

      expect(kural.sectionInfo, 'அறத்துப்பால்');
    });

    test('toString includes kural number', () {
      final kural = Thirukkural.fromMap(sampleMap);

      expect(kural.toString(), contains('#1'));
    });

    test('roundtrip fromMap -> toMap preserves data', () {
      final original = Thirukkural.fromMap(sampleMap);
      final map = original.toMap();
      final restored = Thirukkural.fromMap(map);

      expect(restored.kuralNumber, original.kuralNumber);
      expect(restored.verseFull, original.verseFull);
      expect(restored.athikaram, original.athikaram);
    });
  });

  group('Athikaram', () {
    late Map<String, dynamic> sampleMap;

    setUp(() {
      sampleMap = {
        'athikaram_number': 1,
        'athikaram': 'கடவுள் வாழ்த்து',
        'athikaram_english': 'The Praise of God',
        'paal': 'அறத்துப்பால்',
        'paal_english': 'Virtue',
      };
    });

    test('creates from map correctly', () {
      final athikaram = Athikaram.fromMap(sampleMap);

      expect(athikaram.number, 1);
      expect(athikaram.nameTamil, 'கடவுள் வாழ்த்து');
      expect(athikaram.nameEnglish, 'The Praise of God');
      expect(athikaram.paal, 'அறத்துப்பால்');
    });

    test('startKural calculates correctly for first athikaram', () {
      final athikaram = Athikaram.fromMap(sampleMap);

      expect(athikaram.startKural, 1);
      expect(athikaram.endKural, 10);
    });

    test('startKural calculates correctly for middle athikaram', () {
      sampleMap['athikaram_number'] = 50;
      final athikaram = Athikaram.fromMap(sampleMap);

      expect(athikaram.startKural, 491);
      expect(athikaram.endKural, 500);
    });

    test('startKural calculates correctly for last athikaram', () {
      sampleMap['athikaram_number'] = 133;
      final athikaram = Athikaram.fromMap(sampleMap);

      expect(athikaram.startKural, 1321);
      expect(athikaram.endKural, 1330);
    });
  });

  group('Thirukkural - Edge Cases', () {
    test('handles empty strings', () {
      final map = {
        'kural_number': 1,
        'verse_line1': '',
        'verse_line2': '',
        'verse_full': '',
        'paal': '',
        'paal_english': '',
        'iyal': '',
        'athikaram': '',
        'athikaram_english': '',
        'athikaram_number': 1,
      };

      final kural = Thirukkural.fromMap(map);
      expect(kural.verseLine1, isEmpty);
      expect(kural.formattedVerse, equals('\n'));
    });

    test('handles special characters in text', () {
      final map = {
        'kural_number': 1,
        'verse_line1': 'Test "quoted" text',
        'verse_line2': "Test 'single' quotes",
        'verse_full': 'Test & ampersand',
        'paal': 'Test',
        'paal_english': 'Test',
        'iyal': 'Test',
        'athikaram': 'Test',
        'athikaram_english': 'Test',
        'athikaram_number': 1,
      };

      final kural = Thirukkural.fromMap(map);
      expect(kural.verseLine1, contains('"'));
      expect(kural.verseLine2, contains("'"));
    });

    test('handles maximum kural number', () {
      final map = {
        'kural_number': 1330,
        'verse_line1': 'Last verse',
        'verse_line2': 'Line 2',
        'verse_full': 'Full verse',
        'paal': 'காமத்துப்பால்',
        'paal_english': 'Love',
        'iyal': 'கற்பியல்',
        'athikaram': 'ஊடலுவகை',
        'athikaram_english': 'The Pleasures of Temporary Variance',
        'athikaram_number': 133,
      };

      final kural = Thirukkural.fromMap(map);
      expect(kural.kuralNumber, 1330);
    });
  });
}
