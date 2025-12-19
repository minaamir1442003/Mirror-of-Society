// lib/presentation/screens/auth/forgetpassword/repository/logout_repository.dart
import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/auth/forgetpassword/model/forget_password_model.dart';
import 'package:app_1/presentation/screens/auth/forgetpassword/model/reset_password_model.dart';
import 'package:dio/dio.dart';

class LogoutRepository {
  final Dio _dio;

  LogoutRepository({required Dio dio}) : _dio = dio;

  // إرسال OTP لنسيان كلمة المرور
  Future<ForgetPasswordResponse> forgetPassword(String email) async {
    try {
      final headers = await ApiConstants.headers;
      
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
        options: Options(headers: headers),
      );

      return ForgetPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response!.data['message'] ?? e.message ?? 'فشل إرسال رمز التحقق';
        throw Exception(message);
      }
      throw Exception('فشل الاتصال بالخادم: ${e.message}');
    }
  }

  // إعادة تعيين كلمة المرور
  Future<ResetPasswordResponse> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final headers = await ApiConstants.headers;
      
      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        options: Options(headers: headers),
      );

      return ResetPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          final errors = e.response!.data['errors'] ?? {};
          final errorMessage = _formatValidationErrors(errors);
          throw Exception(errorMessage);
        }
        final message = e.response!.data['message'] ?? e.message ?? 'فشل تغيير كلمة المرور';
        throw Exception(message);
      }
      throw Exception('فشل الاتصال بالخادم: ${e.message}');
    }
  }

  String _formatValidationErrors(Map<String, dynamic> errors) {
    final messages = <String>[];
    errors.forEach((field, errorList) {
      if (errorList is List) {
        for (var error in errorList) {
          messages.add('$field: $error');
        }
      }
    });
    return messages.join('\n');
  }
}