/// VAZHI API Service
///
/// Handles communication with the HuggingFace Spaces backend.

import 'package:dio/dio.dart';
import '../config/app_config.dart';

class VazhiApiService {
  late final Dio _dio;

  VazhiApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.huggingFaceSpaceUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  /// Send a chat message and get a response
  ///
  /// [message] - The user's question in Tamil or Tanglish
  /// [pack] - Optional knowledge pack (culture, education, security, legal, govt, health)
  ///
  /// Returns the assistant's response string
  Future<String> chat(String message, {String pack = 'culture'}) async {
    try {
      // Gradio API format - using the /api/predict endpoint
      // The app.py has pack_dropdown with values: culture, education, security, legal, govt, health
      final response = await _dio.post(
        '',
        data: {
          'data': [message, pack],
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Gradio returns {data: [response_dict]} where response_dict has 'response' key
        if (data != null && data['data'] != null && data['data'].isNotEmpty) {
          final result = data['data'][0];
          // Handle both string response and dict response formats
          if (result is String) {
            return result;
          } else if (result is Map && result['response'] != null) {
            return result['response'] as String;
          }
          return result.toString();
        }
        throw VazhiApiException('Invalid response format');
      } else {
        throw VazhiApiException('API error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw VazhiApiException(
          'இணைப்பு நேரம் முடிந்தது. இணைய இணைப்பை சரிபார்க்கவும்.',
          isColdStart: true,
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw VazhiApiException(
          'சர்வர் சூடேறுகிறது, மீண்டும் முயற்சிக்கவும்.',
          isColdStart: true,
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw VazhiApiException(
          'இணைய இணைப்பு இல்லை. நெட்வொர்க் சரிபார்க்கவும்.',
        );
      } else {
        throw VazhiApiException(
          'பிணைய பிழை: ${e.message}',
        );
      }
    } catch (e) {
      if (e is VazhiApiException) rethrow;
      throw VazhiApiException('எதிர்பாராத பிழை: $e');
    }
  }

  /// Check if the API is available
  Future<bool> isAvailable() async {
    try {
      final response = await _dio.get(
        '',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Custom exception for VAZHI API errors
class VazhiApiException implements Exception {
  final String message;
  final bool isColdStart;

  VazhiApiException(this.message, {this.isColdStart = false});

  @override
  String toString() => message;
}
