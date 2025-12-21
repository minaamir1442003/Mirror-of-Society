import 'package:app_1/core/constants/api_const.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthRepository({required Dio dio}) : _dio = dio;

  Future<bool> logout() async {
    try {
      print('🚀 AuthRepository: Sending logout request to: ${ApiConstants.logout}');
      
      // ✅ إضافة timeout لمنع التوقف
      final response = await _dio.post(
        ApiConstants.logout,
        options: Options(
          receiveTimeout: Duration(seconds: 10), // ✅ وقت استجابة قصير
        ),
      ).timeout(Duration(seconds: 15), onTimeout: () {
        print('⚠️ AuthRepository: Logout request timed out');
        return Response(
          requestOptions: RequestOptions(path: ApiConstants.logout),
          statusCode: 408, // Request Timeout
        );
      });
      
      print('✅ AuthRepository: Logout response status: ${response.statusCode}');
      print('✅ AuthRepository: Logout response data: ${response.data}');
      
      // ✅ مسح جميع بيانات المستخدم بعد تسجيل الخروج
      await _clearAllUserData();
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ AuthRepository: Logout error: $e');
      print('❌ Stack trace: ${e.toString()}');
      
      // ✅ حتى لو فشل الاتصال بالسيرفر، نمسح البيانات المحلية
      try {
        await _clearAllUserData();
      } catch (e2) {
        print('⚠️ AuthRepository: Error in cleanup: $e2');
      }
      
      return false; // نعود بـ false لأن الطلب فشل
    }
  }

  // ✅ دالة جديدة لمسح جميع بيانات المستخدم
  Future<void> _clearAllUserData() async {
    try {
      print('🧹 AuthRepository: Clearing all user data...');
      
      // 1. مسح التوكن من Secure Storage
      await _storage.delete(key: 'auth_token');
      print('✅ Auth token deleted');
      
      // 2. مسح بيانات المستخدم من Secure Storage
      await _storage.delete(key: 'user_data');
      print('✅ User data deleted');
      
      // 3. مسح بيانات المستخدم من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // قائمة بجميع مفاتيح بيانات المستخدم
      final userKeys = [
        'user_id',
        'user_name', 
        'user_email',
        'user_image',
        'user_rank',
        'fcm_token',
        'notifications_enabled'
      ];
      
      for (final key in userKeys) {
        await prefs.remove(key);
      }
      
      // ملاحظة: لا تمسح 'onboarding_completed' هنا!
      print('✅ All user-specific preferences cleared');
      
      print('✅ AuthRepository: All user data cleared successfully');
    } catch (e) {
      print('❌ AuthRepository: Error clearing user data: $e');
      // نستمر حتى لو حدث خطأ
    }
  }
}