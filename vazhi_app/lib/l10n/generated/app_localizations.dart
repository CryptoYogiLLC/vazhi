import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
  ];

  /// The app title shown in the app bar
  ///
  /// In en, this message translates to:
  /// **'VAZHI வழி'**
  String get appTitle;

  /// App subtitle or tagline
  ///
  /// In en, this message translates to:
  /// **'Tamil AI Assistant'**
  String get appSubtitle;

  /// Welcome message on the home screen
  ///
  /// In en, this message translates to:
  /// **'Free AI companion for Tamil people'**
  String get welcomeMessage;

  /// Culture knowledge pack name
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get culturePack;

  /// No description provided for @cultureDescription.
  ///
  /// In en, this message translates to:
  /// **'Thirukkural, temples, festivals'**
  String get cultureDescription;

  /// No description provided for @educationPack.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get educationPack;

  /// No description provided for @educationDescription.
  ///
  /// In en, this message translates to:
  /// **'Schools, exams, scholarships'**
  String get educationDescription;

  /// No description provided for @healthPack.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthPack;

  /// No description provided for @healthDescription.
  ///
  /// In en, this message translates to:
  /// **'Hospitals, schemes, wellness'**
  String get healthDescription;

  /// No description provided for @govtPack.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get govtPack;

  /// No description provided for @govtDescription.
  ///
  /// In en, this message translates to:
  /// **'Schemes, documents, services'**
  String get govtDescription;

  /// No description provided for @emergencyPack.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyPack;

  /// No description provided for @emergencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Helplines, first aid, safety'**
  String get emergencyDescription;

  /// No description provided for @legalPack.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalPack;

  /// No description provided for @legalDescription.
  ///
  /// In en, this message translates to:
  /// **'Rights, documents, procedures'**
  String get legalDescription;

  /// No description provided for @securityPack.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityPack;

  /// No description provided for @securityDescription.
  ///
  /// In en, this message translates to:
  /// **'Scam alerts, cyber safety'**
  String get securityDescription;

  /// Send button accessibility label
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// Voice input button hint
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get voiceInputHint;

  /// Shown when voice input is active
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get voiceInputListening;

  /// Stop voice input accessibility label
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get stopListening;

  /// Placeholder text in the message input
  ///
  /// In en, this message translates to:
  /// **'Ask anything in Tamil or English...'**
  String get typeMessage;

  /// No description provided for @feedbackPositive.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get feedbackPositive;

  /// No description provided for @feedbackNegative.
  ///
  /// In en, this message translates to:
  /// **'Not helpful'**
  String get feedbackNegative;

  /// No description provided for @feedbackCorrection.
  ///
  /// In en, this message translates to:
  /// **'Suggest correction'**
  String get feedbackCorrection;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get settingsVoice;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @offlineModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Some features may be limited'**
  String get offlineModeDescription;

  /// No description provided for @downloadModel.
  ///
  /// In en, this message translates to:
  /// **'Download AI Model'**
  String get downloadModel;

  /// No description provided for @downloadModelDescription.
  ///
  /// In en, this message translates to:
  /// **'Required for offline use (~1.6 GB)'**
  String get downloadModelDescription;

  /// No description provided for @downloadProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading: {progress}%'**
  String downloadProgress(int progress);

  /// No description provided for @kuralNumber.
  ///
  /// In en, this message translates to:
  /// **'Kural {number}'**
  String kuralNumber(int number);

  /// No description provided for @athikaramNumber.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String athikaramNumber(int number);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
