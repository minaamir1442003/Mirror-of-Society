// lib/features/auth/data/repositories/register_repository.dart
import 'package:app_1/core/constants/dio_client.dart';
import 'package:app_1/data/models/user_model.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/register_request.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/register_response.dart';
import 'package:dio/dio.dart';

class RegisterRepository {
  final DioClient _dioClient;

  RegisterRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      print('🚀 Starting registration for: ${request.email}');

      // 1. إنشاء FormData
      final formData = FormData();

      // 2. إضافة الحقول النصية
      formData.fields.addAll([
        MapEntry('firstname', request.firstname),
        MapEntry('lastname', request.lastname),
        MapEntry('email', request.email),
        MapEntry('password', request.password),
        MapEntry('password_confirmation', request.passwordConfirmation),
        MapEntry('phone', request.phone),
        MapEntry('zodiac', request.zodiac), // ✅ هنا
        MapEntry('zodiac_description', request.zodiacDescription), // ✅ وهنا
        MapEntry('share_location', request.shareLocation ? '1' : '0'),
        MapEntry('share_zodiac', request.shareZodiac ? '1' : '0'),
        MapEntry('birthdate', request.birthdate),
        MapEntry('country', request.country),
      ]);
      // 3. إضافة الـ bio إذا كانت موجودة
      if (request.bio != null && request.bio!.isNotEmpty) {
        formData.fields.add(MapEntry('bio', request.bio!));
      }

      // 4. إضافة الـ interests
      for (var interest in request.interests) {
        formData.fields.add(MapEntry('interests[]', interest.toString()));
      }

      // 5. إضافة الصور إذا كانت موجودة
      if (request.imagePath != null && request.imagePath!.isNotEmpty) {
        final imageFile = await MultipartFile.fromFile(
          request.imagePath!,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        formData.files.add(MapEntry('image', imageFile));
      }

      if (request.coverPath != null && request.coverPath!.isNotEmpty) {
        final coverFile = await MultipartFile.fromFile(
          request.coverPath!,
          filename: 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        formData.files.add(MapEntry('cover', coverFile));
      }

      // 6. Send Request - استخدم _dioClient.dio
      print('📤 Sending registration request...');
      final response = await _dioClient.dio.post(
        '/register',
        data: formData,
        options: Options(
          headers: {'Accept': 'application/json', 'Accept-Language': 'en'},
        ),
      );

      print('✅ Response received: ${response.statusCode}');
      print('📝 Response data: ${response.data}');

      // 7. Handle Response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        // Create user data from Request for local storage
        final userData = {
          'id': 0,
          'firstname': request.firstname,
          'lastname': request.lastname,
          'email': request.email,
          'phone': request.phone,
          'bio': request.bio ?? '',
          'zodiac': request.zodiac,
          'zodiac_description': request.zodiacDescription,
          'share_location': request.shareLocation ? 1 : 0,
          'share_zodiac': request.shareZodiac ? 1 : 0,
          'birthdate': request.birthdate,
          'country': request.country,
          'is_verified': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Create Response
        return RegisterResponse(
          status: responseData['status'] ?? false,
          message: responseData['message'] ?? '',
          token: responseData['token'] ?? '',
          user: UserModel.fromJson(userData),
        );
      } else {
        throw Exception('فشل التسجيل: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      print('📊 Response: ${e.response?.data}');

      if (e.response != null) {
        // Handle Validation Errors (422)
        if (e.response!.statusCode == 422) {
          final errors = e.response!.data['errors'];
          final errorMessage = _formatValidationErrors(errors);
          throw Exception(errorMessage);
        }

        // Handle other errors
        final errorMessage =
            e.response!.data['message'] ?? e.message ?? 'حدث خطأ غير معروف';
        throw Exception(errorMessage);
      }

      throw Exception('فشل الاتصال بالخادم: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw Exception('حدث خطأ غير متوقع: $e');
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
