import 'package:app_1/presentation/screens/auth/forgot_password_screen.dart';
import 'package:app_1/presentation/screens/main_app/explore/categories_screen.dart';
import 'package:app_1/presentation/screens/main_app/onboarding/onboarding_screen.dart';
import 'package:app_1/presentation/screens/main_app/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_app/main_screen.dart';
import '../screens/main_app/create_bolt/create_bolt_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/onboarding':
        return MaterialPageRoute(
          builder: (context) => OnboardingScreen(),
        );
      
      case '/home':
        return MaterialPageRoute(builder: (_) => MainScreen());
      case '/forgot-password':
      return MaterialPageRoute(builder: (_) => ForgotPasswordScreen(),
       settings: settings,);
      
      case '/create-bolt':
        return MaterialPageRoute(builder: (_) => CreateBoltScreen());
      
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
        case '/categories':
        return MaterialPageRoute(builder: (_) => CategoriesScreen());
        case '/profile':
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('الصفحة غير موجودة'),
            ),
          ),
        );
    }
  }
}