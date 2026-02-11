/// VAZHI App Configuration
///
/// Defines app variants, API endpoints, and feature flags.

enum AppVariant { lite, full }

class AppConfig {
  // Current app variant
  static const AppVariant variant = AppVariant.lite;

  // API Configuration - Gradio API endpoint
  static const String huggingFaceSpaceUrl =
      'https://CryptoYogi-vazhi.hf.space/api/predict';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Voice Configuration
  static const String tamilLocale = 'ta-IN';
  static const String englishLocale = 'en-IN';
  static const double defaultTtsSpeed = 0.5;

  // Chat Configuration
  static const int maxChatHistory = 50;
  static const int maxResponseTokens = 512;

  // Feature Flags
  static const bool enableVoiceInput = true;
  static const bool enableVoiceOutput = true;
  static const bool enableOfflineMode = false; // Only for Full variant

  // Pack IDs (must match Gradio app's pack_dropdown values)
  static const List<String> availablePacks = [
    'culture',
    'education',
    'security',
    'legal',
    'govt',
    'health',
  ];

  // App Info
  static const String appName = 'VAZHI';
  static const String appNameTamil = 'வழி';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Voluntary AI with Zero-cost Helpful Intelligence';
  static const String appTaglineTamil = 'தமிழ் AI உதவியாளர்';

  // Support
  static const String whatsappSupportNumber = '+91XXXXXXXXXX';
  static const String donationUrl = 'https://ko-fi.com/vazhi';
  static const String githubUrl = 'https://github.com/CryptoYogiLLC/vazhi';
}
