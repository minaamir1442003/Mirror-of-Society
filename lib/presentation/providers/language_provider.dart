// lib/presentation/providers/language_provider.dart
import 'package:flutter/material.dart';
import 'package:app_1/data/services/language_service.dart';

class LanguageProvider with ChangeNotifier {
  late Locale _currentLocale;
  bool _isLoading = true;
  
  // قائمة اللغات المتاحة
  final Map<String, Locale> _availableLanguages = {
    'العربية': Locale('ar', ''),
    'English': Locale('en', ''),
    'Français': Locale('fr', ''),
    'Español': Locale('es', ''),
  };

  LanguageProvider({required Locale initialLocale}) {
    _currentLocale = initialLocale;
    _isLoading = false;
  }

  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;

  Future<void> changeLanguage(String languageName) async {
    if (!_availableLanguages.containsKey(languageName)) {
      throw Exception('Language not supported');
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // 1. حفظ اللغة في SharedPreferences
      await LanguageService.setLanguage(languageName);
      
      // 2. تحديث الحالة المحلية
      _currentLocale = _availableLanguages[languageName]!;
      
      // 3. تحديث واجهة المستخدم
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // جلب اتجاه النص الحالي
  Future<TextDirection> getCurrentTextDirection() async {
    final languageName = _availableLanguages.entries
        .firstWhere((entry) => entry.value == _currentLocale)
        .key;
    final direction = LanguageService.supportedLanguages[languageName]?['direction'] ?? 'ltr';
    return direction == 'rtl' ? TextDirection.rtl : TextDirection.ltr;
  }

  // جلب قائمة أسماء اللغات المتاحة
  List<String> getAvailableLanguages() {
    return _availableLanguages.keys.toList();
  }

  // الحصول على اسم اللغة الحالية
  String getCurrentLanguageName() {
    return _availableLanguages.entries
        .firstWhere((entry) => entry.value == _currentLocale)
        .key;
  }

  // تحقق إذا كانت اللغة عربية
  bool get isArabic => _currentLocale.languageCode == 'ar';
}