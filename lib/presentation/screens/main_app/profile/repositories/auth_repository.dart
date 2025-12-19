// lib/data/repositories/auth_repository.dart - الإصلاح الكامل
import 'package:app_1/core/constants/api_const.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository({required Dio dio}) : _dio = dio;

  Future<bool> logout() async {
    try {
      print('🚀 Sending logout request to: ${ApiConstants.logout}');
      
      final response = await _dio.post(
        ApiConstants.logout,
      );
      
      print('✅ Logout response status: ${response.statusCode}');
      print('✅ Logout response data: ${response.data}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Logout error: $e');
      return false;
    }
  }
}