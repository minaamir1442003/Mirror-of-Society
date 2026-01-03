import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CountryService {
  // دالة لجلب البلد من إعدادات الجهاز
  static Future<String> getDeviceCountry() async {
    try {
      // جلب إعدادات الجهاز
      final locale = await _getDeviceLocale();
      final countryCode = locale.countryCode;
      
      // تحويل كود البلد إلى اسم البلد
      if (countryCode != null) {
        return _getCountryNameFromCode(countryCode);
      }
      
      return 'Egypt'; // القيمة الافتراضية
    } catch (e) {
      print('❌ Error getting device country: $e');
      return 'Egypt';
    }
  }
  
  static Future<Locale> _getDeviceLocale() async {
    try {
      // جلب locale من النظام
      final locale = WidgetsBinding.instance.window.locale;
      return locale;
    } catch (e) {
      print('❌ Error getting device locale: $e');
      return const Locale('en', 'US');
    }
  }
  
  static String _getCountryNameFromCode(String countryCode) {
    final countryNames = {
      'EG': 'Egypt',
      'SA': 'Saudi Arabia',
      'AE': 'UAE',
      'KW': 'Kuwait',
      'QA': 'Qatar',
      'OM': 'Oman',
      'BH': 'Bahrain',
      'JO': 'Jordan',
      'LB': 'Lebanon',
      'SY': 'Syria',
      'IQ': 'Iraq',
      'YE': 'Yemen',
      'LY': 'Libya',
      'TN': 'Tunisia',
      'DZ': 'Algeria',
      'MA': 'Morocco',
      'SD': 'Sudan',
      'SO': 'Somalia',
      'PS': 'Palestine',
      'DJ': 'Djibouti',
      'MR': 'Mauritania',
      'KM': 'Comoros',
      'TR': 'Turkey',
      'IR': 'Iran',
      'PK': 'Pakistan',
      'AF': 'Afghanistan',
    };
    
    return countryNames[countryCode] ?? 'Egypt';
  }
  
  // دالة لجلب اسم البلد بالعربية
  static String getCountryNameInArabic(String englishName) {
    final arabicNames = {
      'Egypt': 'مصر',
      'Saudi Arabia': 'السعودية',
      'UAE': 'الإمارات',
      'Kuwait': 'الكويت',
      'Qatar': 'قطر',
      'Oman': 'عمان',
      'Bahrain': 'البحرين',
      'Jordan': 'الأردن',
      'Lebanon': 'لبنان',
      'Syria': 'سوريا',
      'Iraq': 'العراق',
      'Yemen': 'اليمن',
      'Libya': 'ليبيا',
      'Tunisia': 'تونس',
      'Algeria': 'الجزائر',
      'Morocco': 'المغرب',
      'Sudan': 'السودان',
      'Somalia': 'الصومال',
      'Palestine': 'فلسطين',
      'Djibouti': 'جيبوتي',
      'Mauritania': 'موريتانيا',
      'Comoros': 'جزر القمر',
      'Turkey': 'تركيا',
      'Iran': 'إيران',
      'Pakistan': 'باكستان',
      'Afghanistan': 'أفغانستان',
    };
    
    return arabicNames[englishName] ?? englishName;
  }
}