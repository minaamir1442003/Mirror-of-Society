// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1DA1F2); // أزرق تويتر-like
  static const Color secondaryColor = Color(0xFF14171A);
  static const Color darkGray = Color(0xFF657786);
  static const Color lightGray = Color(0xFFAAB8C2);
  static const Color extraLightGray = Color(0xFFE1E8ED);
  static const Color extraExtraLightGray = Color(0xFFF5F8FA);
  static const Color successColor = Color(0xFF17BF63);
  static const Color dangerColor = Color(0xFFE0245E);
  
  // ألوان التصنيفات
  static Map<String, Color> categoryColors = {
    'سياسة': Color(0xFFE0245E),
    'رياضة': Color(0xFF17BF63),
    'فن': Color(0xFFF45D22),
    'اقتصاد': Color(0xFF794BC4),
    'تكنولوجيا': Color(0xFF1DA1F2),
    'عامة': Color(0xFF657786),
  };
  
  // ألوان الرتب
  static Map<int, Color> rankColors = {
    1: Color(0xFF95A5A6),  // رمادي
    2: Color(0xFF3498DB),  // أزرق
    3: Color(0xFF2ECC71),  // أخضر
    4: Color(0xFFF39C12),  // ذهبي
    5: Color(0xFF9B59B6),  // بنفسجي
  };
  
  static ThemeData get lightTheme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: secondaryColor),
      titleTextStyle: TextStyle(
        color: secondaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    fontFamily: 'Cairo', // خط عربي
  );
}