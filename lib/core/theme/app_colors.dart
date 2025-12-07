import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1DA1F2);
  static const Color secondary = Color(0xFF14171A);
  static const Color darkGray = Color(0xFF657786);
  static const Color lightGray = Color(0xFFAAB8C2);
  static const Color extraLightGray = Color(0xFFE1E8ED);
  static const Color background = Color(0xFFF5F8FA);
  static const Color success = Color(0xFF17BF63);
  static const Color danger = Color(0xFFE0245E);
  static const Color warning = Color(0xFFF45D22);
  
  static Map<String, Color> categoryColors = {
    'سياسة': danger,
    'رياضة': success,
    'فن': warning,
    'اقتصاد': Color(0xFF794BC4),
    'تكنولوجيا': primary,
    'عامة': darkGray,
  };
  
  static Map<int, Color> rankColors = {
    1: Color(0xFF95A5A6),
    2: Color(0xFF3498DB),
    3: Color(0xFF2ECC71),
    4: Color(0xFFF39C12),
    5: Color(0xFF9B59B6),
  };
}