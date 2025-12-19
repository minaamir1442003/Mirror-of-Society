// lib/presentation/screens/auth/otp/repository/otp_repository.dart
import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/auth/forgetpassword/model/otp_model.dart';
import 'package:dio/dio.dart';

class OtpRepository {
  final Dio _dio;

  OtpRepository({required Dio dio}) : _dio = dio;

  // التحقق من OTP باستخدام reset-password endpoint
  Future<OtpVerifyResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final headers = await ApiConstants.headers;
      
      // ✅ نحاول التحقق من OTP بدون تغيير كلمة المرور
      // نستخدم password مؤقت للتحقق فقط
      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'password': 'temp123Temp!', // كلمة مرور مؤقتة
          'password_confirmation': 'temp123Temp!',
        },
        options: Options(headers: headers),
      );

      // إذا نجح الطلب، يعني الـ OTP صحيح
      return OtpVerifyResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Verify OTP error: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        // إذا كان الخطأ 422 (Validation Error)، قد يكون الـ OTP خاطئ
        if (e.response!.statusCode == 422) {
          final errors = e.response!.data['errors'] ?? {};
          if (errors.containsKey('otp')) {
            throw Exception('رمز التحقق غير صحيح');
          }
          // قد يكون بسبب أن كلمة المرور ليست قوية بما يكفي
          if (errors.containsKey('password')) {
            // هذا يعني أن الـ OTP صحيح ولكن كلمة المرور ضعيفة
            // نجح التحقق من OTP فقط
            return OtpVerifyResponse(
              status: true,
              message: 'تم التحقق من رمز OTP بنجاح',
            );
          }
        }
        
        final message = e.response!.data['message'] ?? e.message ?? 'فشل التحقق من الرمز';
        throw Exception(message);
      }
      throw Exception('فشل الاتصال بالخادم: ${e.message}');
    } catch (e) {
      print('❌ Unknown error: $e');
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  // إعادة إرسال OTP (استخدام forget-password endpoint)
  Future<OtpResendResponse> resendOtp(String email) async {
    try {
      final headers = await ApiConstants.headers;
      
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
        options: Options(headers: headers),
      );

      print('✅ Resend OTP response: ${response.statusCode}');
      print('📝 Response data: ${response.data}');

      return OtpResendResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Resend OTP error: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        final message = e.response!.data['message'] ?? e.message ?? 'فشل إعادة إرسال الرمز';
        throw Exception(message);
      }
      throw Exception('فشل الاتصال بالخادم: ${e.message}');
    } catch (e) {
      print('❌ Unknown error: $e');
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }
}