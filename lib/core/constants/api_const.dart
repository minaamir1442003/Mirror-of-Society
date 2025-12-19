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
  
  // جلب اللغة الحالية بشكل ديناميكي
  static Future<Map<String, String>> get headers async {
    final currentLanguage = await LanguageService.getSavedLanguage();
    final languageCode = LanguageService.getLanguageCode(currentLanguage);
    
    return {
      'Accept': 'application/json',
      'Accept-Language': languageCode,
    };
  }
  
  static Future<Map<String, String>> authHeaders(String token) async {
    final currentHeaders = await headers;
    return {
      ...currentHeaders,
      'Authorization': 'Bearer $token',
    };
  }
}