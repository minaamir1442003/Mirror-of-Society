// lib/core/services/language_service.dart
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  
  // اللغات المتاحة
  static final Map<String, Map<String, dynamic>> supportedLanguages = {
    'العربية': {
      'code': 'ar',
      'native': 'العربية',
      'font': 'Cairo',
      'direction': 'rtl',
      'locale': 'ar',
    },
    'English': {
      'code': 'en',
      'native': 'English',
      'font': 'Roboto',
      'direction': 'ltr',
      'locale': 'en',
    },
    'Français': {
      'code': 'fr',
      'native': 'Français',
      'font': 'Roboto',
      'direction': 'ltr',
      'locale': 'fr',
    },
    'Español': {
      'code': 'es',
      'native': 'Español',
      'font': 'Roboto',
      'direction': 'ltr',
      'locale': 'es',
    }
  };

  // جلب لغة الجهاز الحالية
  static String getDeviceLanguage() {
    final locale = ui.window.locale;
    final languageCode = locale.languageCode;
    
    // البحث عن تطابق مع اللغات المدعومة
    for (var entry in supportedLanguages.entries) {
      if (entry.value['code'] == languageCode) {
        return entry.key;
      }
    }
    
    // إذا لم توجد تطابق، استخدم الإنجليزية كافتراضي
    return 'English';
  }

  // حفظ اللغة المختارة
  static Future<void> setLanguage(String languageName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageName);
  }

  // جلب اللغة المحفوظة (أو لغة الجهاز)
  static Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    
    if (savedLanguage != null && supportedLanguages.containsKey(savedLanguage)) {
      return savedLanguage;
    }
    
    // إذا لم تكن هناك لغة محفوظة، استخدم لغة الجهاز
    final deviceLanguage = getDeviceLanguage();
    await setLanguage(deviceLanguage);
    return deviceLanguage;
  }

  // جلب كود اللغة
  static String getLanguageCode(String languageName) {
    return supportedLanguages[languageName]?['code'] ?? 'en';
  }

  // جبل اسم الخط المناسب للغة
  static Future<String> getFontFamily() async {
    final languageName = await getSavedLanguage();
    return supportedLanguages[languageName]?['font'] ?? 'Roboto';
  }

  // جلب اتجاه النص
  static Future<ui.TextDirection> getTextDirection() async {
    final languageName = await getSavedLanguage();
    final direction = supportedLanguages[languageName]?['direction'] ?? 'ltr';
    return direction == 'rtl' ? ui.TextDirection.rtl : ui.TextDirection.ltr;
  }

  // جلب قائمة أسماء اللغات
  static List<String> getLanguageNames() {
    return supportedLanguages.keys.toList();
  }

  // هل اللغة عربية؟
  static Future<bool> isArabic() async {
    final language = await getSavedLanguage();
    return language == 'العربية';
  }
}