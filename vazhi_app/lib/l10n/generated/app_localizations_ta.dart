// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'வழி VAZHI';

  @override
  String get appSubtitle => 'தமிழ் AI உதவியாளர்';

  @override
  String get welcomeMessage => 'தமிழர்களுக்கான இலவச AI வழி தோழன்';

  @override
  String get culturePack => 'கலாச்சாரம்';

  @override
  String get cultureDescription => 'திருக்குறள், கோவில்கள், திருவிழாக்கள்';

  @override
  String get educationPack => 'கல்வி';

  @override
  String get educationDescription => 'பள்ளிகள், தேர்வுகள், உதவித்தொகைகள்';

  @override
  String get healthPack => 'சுகாதாரம்';

  @override
  String get healthDescription => 'மருத்துவமனைகள், திட்டங்கள், ஆரோக்கியம்';

  @override
  String get govtPack => 'அரசு';

  @override
  String get govtDescription => 'திட்டங்கள், ஆவணங்கள், சேவைகள்';

  @override
  String get emergencyPack => 'அவசரம்';

  @override
  String get emergencyDescription => 'உதவி எண்கள், முதலுதவி, பாதுகாப்பு';

  @override
  String get legalPack => 'சட்டம்';

  @override
  String get legalDescription => 'உரிமைகள், ஆவணங்கள், நடைமுறைகள்';

  @override
  String get securityPack => 'பாதுகாப்பு';

  @override
  String get securityDescription => 'மோசடி எச்சரிக்கைகள், இணைய பாதுகாப்பு';

  @override
  String get sendMessage => 'செய்தி அனுப்பு';

  @override
  String get voiceInputHint => 'பேச தட்டவும்';

  @override
  String get voiceInputListening => 'கேட்கிறது...';

  @override
  String get stopListening => 'நிறுத்து';

  @override
  String get typeMessage => 'தமிழ் அல்லது ஆங்கிலத்தில் கேளுங்கள்...';

  @override
  String get feedbackPositive => 'உதவியாக இருந்தது';

  @override
  String get feedbackNegative => 'உதவியாக இல்லை';

  @override
  String get feedbackCorrection => 'திருத்தம் பரிந்துரை';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get settingsLanguage => 'மொழி';

  @override
  String get settingsVoice => 'குரல்';

  @override
  String get settingsAbout => 'பற்றி';

  @override
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get error => 'ஏதோ தவறு ஏற்பட்டது';

  @override
  String get retry => 'மீண்டும் முயற்சி';

  @override
  String get cancel => 'ரத்து';

  @override
  String get ok => 'சரி';

  @override
  String get yes => 'ஆம்';

  @override
  String get no => 'இல்லை';

  @override
  String get noResults => 'முடிவுகள் இல்லை';

  @override
  String get searchHint => 'தேடு...';

  @override
  String get offlineMode => 'ஆஃப்லைன் பயன்முறை';

  @override
  String get offlineModeDescription => 'சில அம்சங்கள் வரையறுக்கப்படலாம்';

  @override
  String get downloadModel => 'AI மாடலை பதிவிறக்கு';

  @override
  String get downloadModelDescription =>
      'ஆஃப்லைன் பயன்பாட்டிற்கு தேவை (~1.6 GB)';

  @override
  String downloadProgress(int progress) {
    return 'பதிவிறக்கம்: $progress%';
  }

  @override
  String kuralNumber(int number) {
    return 'குறள் $number';
  }

  @override
  String athikaramNumber(int number) {
    return 'அதிகாரம் $number';
  }
}
