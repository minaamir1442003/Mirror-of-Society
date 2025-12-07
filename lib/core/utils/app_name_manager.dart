// lib/core/utils/app_name_manager.dart
import 'dart:ui' as ui;

class AppNameManager {
  // قائمة أسماء التطبيق للغات المختلفة
  static final Map<String, String> _appNames = {
    'ar': 'مرآة المجتمع',
    'en': 'Mirror of Society',
    'fr': 'Miroir de la Société',
    'es': 'Espejo de la Sociedad',
  };

  // جلب اسم التطبيق بناءً على لغة الجهاز
  static String getAppName() {
    // الحصول على لغة الجهاز الحالية
    final locale = ui.window.locale;
    final languageCode = locale.languageCode;
    
    // إذا كانت اللغة عربية، استخدم العربية
    if (languageCode == 'ar') {
      return _appNames['ar']!;
    }
    // إذا كانت أي لغة أخرى، استخدم الإنجليزية
    else {
      return _appNames['en']!;
    }
  }

  // جلب اسم التطبيق للغة معينة
  static String getAppNameForLanguage(String languageCode) {
    return _appNames[languageCode] ?? _appNames['en']!;
  }

  // معرفة إذا كانت اللغة عربية
  static bool isArabic() {
    final locale = ui.window.locale;
    return locale.languageCode == 'ar';
  }
}