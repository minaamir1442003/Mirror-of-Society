// lib/core/constants/api_constants.dart
import 'package:app_1/data/services/language_service.dart';

class ApiConstants {
  static const String baseUrl = 'https://mirsoc.com';
  static const String apiBaseUrl = '$baseUrl/api/v1';
  
  // Auth Endpoints
  static const String register = '$apiBaseUrl/register';
  static const String login = '$apiBaseUrl/login';
  static const String forgotPassword = '$apiBaseUrl/forget-password';
  static const String resetPassword = '$apiBaseUrl/reset-password';
  static const String logout = '$apiBaseUrl/logout';
  static const String verifyAccount = '$apiBaseUrl/verify-account';
  static const String requestVerification = '$apiBaseUrl/request-verification';
  
  // Social Auth
  static const String googleAuth = '$apiBaseUrl/auth/google/callback';
  static const String facebookAuth = '$apiBaseUrl/auth/facebook/callback';
  static const String twitterAuth = '$apiBaseUrl/auth/twitter/callback';

  static const String createTelegram = '$apiBaseUrl/telegrams';
static const String updateTelegram = '$apiBaseUrl/telegrams/{id}';
static const String deleteTelegram = '$apiBaseUrl/telegrams/{id}';
static const String likeTelegram = '$apiBaseUrl/telegrams/{id}/like';
static const String repostTelegram = '$apiBaseUrl/telegrams/{id}/repost';
static const String addComment = '$apiBaseUrl/telegrams/{id}/comments';
static const String getCategories = '$apiBaseUrl/categories';
  
  // جلب اللغة الحالية بشكل ديناميكي
  static Future<Map<String, String>> get headers async {
    try {
      final currentLanguage = await LanguageService.getSavedLanguage();
      final languageCode = LanguageService.getLanguageCode(currentLanguage);
      
      print('🌐 ApiConstants: Current language code: $languageCode');
      
      return {
        'Accept': 'application/json',
        'Accept-Language': languageCode,
        'Content-Type': 'application/json',
      };
    } catch (e) {
      print('❌ ApiConstants: Error getting language headers: $e');
      return {
        'Accept': 'application/json',
        'Accept-Language': 'en', // ✅ Fallback إلى الإنجليزية
        'Content-Type': 'application/json',
      };
    }
  }
  
  static Future<Map<String, String>> authHeaders(String token) async {
    try {
      final currentHeaders = await headers;
      return {
        ...currentHeaders,
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('❌ ApiConstants: Error getting auth headers: $e');
      return {
        'Accept': 'application/json',
        'Accept-Language': 'en',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
  }
  static Future<String> translateCategoryName(String englishName) async {
    try {
      final currentLanguage = await LanguageService.getSavedLanguage();
      
      if (currentLanguage == 'العربية') {
        // ترجمة التصنيفات من الإنجليزية إلى العربية
        final translations = {
          'Arts': 'فنون',
          'Sports': 'رياضة',
          'Technology': 'تكنولوجيا',
          'Movies': 'أفلام',
          'Fashion': 'موضة',
          'Business': 'أعمال',
          'Health': 'صحة',
          'Travel': 'سفر',
          'Science': 'علوم',
          'Gaming': 'ألعاب',
          'Literature': 'أدب',
          'Politics': 'سياسة',
          'Food': 'طعام',
          'Music': 'موسيقى',
          'Education': 'تعليم',
          'All': 'الكل',
        };
        return translations[englishName] ?? englishName;
      }
      
      // إذا كانت اللغة غير العربية، نرجع الاسم الإنجليزي
      return englishName;
    } catch (e) {
      print('❌ ApiConstants: Error translating category: $e');
      return englishName;
    }
  }
}