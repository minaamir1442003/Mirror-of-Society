// lib/providers/language_provider.dart
import 'package:app_1/data/services/language_service.dart';
import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'العربية'; // استخدم شرطة سفلية للخاصية الخاصة
  bool _isLoading = true;

  // الـ getters للوصول للقيم
  String get currentLanguage => _currentLanguage;
  bool get isLoading => _isLoading;

  LanguageProvider() {
    _initializeLanguage();
  }

  Future<void> _initializeLanguage() async {
    _currentLanguage = await LanguageService.getSavedLanguage();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeLanguage(String language) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // حفظ اللغة في SharedPreferences
      await LanguageService.setLanguage(language);
      
      // تحديث الحالة المحلية
      _currentLanguage = language;
      
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
    return await LanguageService.getTextDirection();
  }

  // جلب قائمة اللغات المتاحة
  List<String> getAvailableLanguages() {
    return LanguageService.getLanguageNames();
  }

  // جلب اسم الخط الحالي
  Future<String> getCurrentFontFamily() async {
    return await LanguageService.getFontFamily();
  }

  // دالة مساعدة لإعادة التحميل (اختياري)
  Future<void> reloadLanguage() async {
    _isLoading = true;
    notifyListeners();
    
    _currentLanguage = await LanguageService.getSavedLanguage();
    
    _isLoading = false;
    notifyListeners();
  }
}