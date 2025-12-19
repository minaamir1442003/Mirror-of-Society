// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'Mirsoc';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String firstLaunchKey = 'first_launch_completed';
  static const String onboardingKey = 'onboarding_completed';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
}