import 'package:app_1/core/constants/dio_client.dart';

import 'package:app_1/presentation/screens/auth/regesteration/models/category_model.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/zodiac_model.dart';
import 'package:dio/dio.dart';

class GeneralRepository {
  final DioClient _dioClient;

  GeneralRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<CategoryModel>> getCategories(String language) async {
    try {
      final response = await _dioClient.dio.get(
        '/categories',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Accept-Language': language == 'العربية' ? 'ar' : 'en',
          },
        ),
      );

      if (response.statusCode == 200) {
        // تحويل الـ JSON مباشرة
        final data = response.data['data'] as List;
        return data.map((item) => CategoryModel.fromJson(item)).toList();
      } else {
        throw Exception('فشل في جلب التصنيفات: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error (Categories): ${e.message}');
      print('📊 Response: ${e.response?.data}');
      throw Exception('فشل الاتصال بالخادم: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Error (Categories): $e');
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  Future<List<ZodiacModel>> getZodiacs(String language) async {
    try {
      final response = await _dioClient.dio.get(
        '/zodiacs',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Accept-Language': language == 'العربية' ? 'ar' : 'en',
          },
        ),
      );

      if (response.statusCode == 200) {
        // تحويل الـ JSON مباشرة
        final data = response.data['data'] as List;
        return data.map((item) => ZodiacModel.fromJson(item)).toList();
      } else {
        throw Exception('فشل في جلب الأبراج: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error (Zodiacs): ${e.message}');
      print('📊 Response: ${e.response?.data}');
      throw Exception('فشل الاتصال بالخادم: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Error (Zodiacs): $e');
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  // دالة مساعدة للترجمة من العربي للإنجليزي
  static String translateZodiacName(String arabicName) {
    final zodiacMap = {
      'الحمل': 'Aries',
      'الثور': 'Taurus',
      'الجوزاء': 'Gemini',
      'السرطان': 'Cancer',
      'الأسد': 'Leo',
      'العذراء': 'Virgo',
      'الميزان': 'Libra',
      'العقرب': 'Scorpio',
      'القوس': 'Sagittarius',
      'الجدي': 'Capricorn',
      'الدلو': 'Aquarius',
      'الحوت': 'Pisces',
    };
    
    return zodiacMap[arabicName] ?? arabicName;
  }
}