// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VAZHI வழி';

  @override
  String get appSubtitle => 'Tamil AI Assistant';

  @override
  String get welcomeMessage => 'Free AI companion for Tamil people';

  @override
  String get culturePack => 'Culture';

  @override
  String get cultureDescription => 'Thirukkural, temples, festivals';

  @override
  String get educationPack => 'Education';

  @override
  String get educationDescription => 'Schools, exams, scholarships';

  @override
  String get healthPack => 'Health';

  @override
  String get healthDescription => 'Hospitals, schemes, wellness';

  @override
  String get govtPack => 'Government';

  @override
  String get govtDescription => 'Schemes, documents, services';

  @override
  String get emergencyPack => 'Emergency';

  @override
  String get emergencyDescription => 'Helplines, first aid, safety';

  @override
  String get legalPack => 'Legal';

  @override
  String get legalDescription => 'Rights, documents, procedures';

  @override
  String get securityPack => 'Security';

  @override
  String get securityDescription => 'Scam alerts, cyber safety';

  @override
  String get sendMessage => 'Send message';

  @override
  String get voiceInputHint => 'Tap to speak';

  @override
  String get voiceInputListening => 'Listening...';

  @override
  String get stopListening => 'Stop listening';

  @override
  String get typeMessage => 'Ask anything in Tamil or English...';

  @override
  String get feedbackPositive => 'Helpful';

  @override
  String get feedbackNegative => 'Not helpful';

  @override
  String get feedbackCorrection => 'Suggest correction';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsVoice => 'Voice';

  @override
  String get settingsAbout => 'About';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get noResults => 'No results found';

  @override
  String get searchHint => 'Search...';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get offlineModeDescription => 'Some features may be limited';

  @override
  String get downloadModel => 'Download AI Model';

  @override
  String get downloadModelDescription => 'Required for offline use (~1.6 GB)';

  @override
  String downloadProgress(int progress) {
    return 'Downloading: $progress%';
  }

  @override
  String kuralNumber(int number) {
    return 'Kural $number';
  }

  @override
  String athikaramNumber(int number) {
    return 'Chapter $number';
  }
}
