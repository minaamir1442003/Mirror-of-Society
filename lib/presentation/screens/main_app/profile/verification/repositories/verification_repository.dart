

import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/core/constants/dio_client.dart';
import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:dio/dio.dart';

class VerificationRepository {
  final DioClient _dioClient;

  VerificationRepository({required DioClient dioClient})
      : _dioClient = dioClient;

  // طلب رمز التحقق
  Future<Map<String, dynamic>> requestVerification() async {
    try {
      final token = await _getToken();
      final headers = await ApiConstants.authHeaders(token);

      final response = await _dioClient.dio.post(
        ApiConstants.requestVerification,
        options: Options(headers: headers),
      );

      return {
        'status': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      print('❌ Error requesting verification: ${e.response?.data}');
      return {
        'status': false,
        'error': e.response?.data?['message'] ?? 'حدث خطأ في طلب رمز التحقق',
      };
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {
        'status': false,
        'error': 'حدث خطأ غير متوقع',
      };
    }
  }

  // التحقق من الرمز
  Future<Map<String, dynamic>> verifyAccount(String code) async {
    try {
      final token = await _getToken();
      final headers = await ApiConstants.authHeaders(token);

      final response = await _dioClient.dio.post(
        ApiConstants.verifyAccount,
        data: {'code': code},
        options: Options(headers: headers),
      );

      return {
        'status': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      print('❌ Error verifying account: ${e.response?.data}');
      return {
        'status': false,
        'error': e.response?.data?['message'] ?? 'حدث خطأ في التحقق من الرمز',
      };
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {
        'status': false,
        'error': 'حدث خطأ غير متوقع',
      };
    }
  }

  // الحصول على التوكن من التخزين
  Future<String> _getToken() async {
    // يمكنك تعديل هذا ليتناسب مع نظام التخزين لديك
    final storageService = StorageService();
    final token = await storageService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return token;
  }
}