// lib/core/constants/shared%20pref.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _firstLaunchKey = 'first_launch_completed';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  // التحقق مما إذا كان المستخدم جديداً (أول تشغيل)
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) != true;
  }

  // تعيين أن المستخدم انتهى من التشغيل الأول
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
  }

  // التحقق مما إذا كان المستخدم انتهى من الـ onboarding
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // تعيين أن المستخدم انتهى من الـ onboarding
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  // تنظيف جميع البيانات (للتجربة)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstLaunchKey);
    await prefs.remove(_onboardingCompletedKey);
  }
}