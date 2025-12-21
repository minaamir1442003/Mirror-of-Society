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
        MapEntry('zodiac', request.zodiac),
        MapEntry('zodiac_description', request.zodiacDescription),
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

      // 6. Send Request
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

      // 7. Handle Response - هنا التعديل المهم
      final responseData = response.data;
      
      // إذا كان الـstatus = false من السيرفر
      if (responseData['status'] == false) {
        return RegisterResponse(
          status: false,
          message: responseData['message'] ?? 'Registration failed',
          token: '',
          user: UserModel.fromJson({
            'id': 0,
            'firstname': '',
            'lastname': '',
            'email': '',
            'phone': '',
            'bio': '',
            'zodiac': '',
            'zodiac_description': '',
            'share_location': 0,
            'share_zodiac': 0,
            'birthdate': '',
            'country': '',
            'is_verified': 0,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }),
        );
      }

      // إذا كان الـstatus = true (نجاح)
      if (responseData['status'] == true) {
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
      }
      
      // في حالة لم يكن هناك status أو true ولا false
      throw Exception('Invalid response format from server');

    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      print('📊 Response: ${e.response?.data}');

      if (e.response != null) {
        // حالة 422 (Validation Errors)
        if (e.response!.statusCode == 422) {
          final errors = e.response!.data['errors'];
          final errorMessage = _formatValidationErrors(errors);
          throw Exception(errorMessage);
        }

        // حالة 400-500 أخرى
        final responseData = e.response!.data;
        if (responseData is Map && responseData.containsKey('status')) {
          // إذا كان الرد منظم بنفس تنسيق API
          final errorMessage = responseData['message'] ?? e.message ?? 'حدث خطأ غير معروف';
          throw Exception(errorMessage);
        } else {
          // إذا كان الرد غير منظم
          final errorMessage = responseData?.toString() ?? e.message ?? 'فشل الاتصال بالخادم';
          throw Exception(errorMessage);
        }
      }

      throw Exception('فشل الاتصال بالخادم: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

String _formatValidationErrors(Map<String, dynamic> errors) {
  print('📝 Formatting validation errors: $errors');
  
  final messages = <String>[];
  
  // التعامل مع أنواع مختلفة من errors
  errors.forEach((field, errorList) {
    print('🔍 Field: $field, ErrorList: $errorList');
    
    if (errorList is List) {
      for (var error in errorList) {
        final fieldName = _getFieldDisplayName(field);
        messages.add('$fieldName: $error');
      }
    } else if (errorList is String) {
      final fieldName = _getFieldDisplayName(field);
      messages.add('$fieldName: $errorList');
    } else {
      // If errorList is not List or String, convert to string
      final fieldName = _getFieldDisplayName(field);
      messages.add('$fieldName: $errorList');
    }
  });
  
  final result = messages.join('\n');
  print('✅ Formatted error message: $result');
  return result;
}

String _getFieldDisplayName(String field) {
  final fieldMap = {
    'firstname': 'First name',
    'lastname': 'Last name',
    'email': 'Email',
    'password': 'Password',
    'password_confirmation': 'Password confirmation',
    'phone': 'Phone number',
    'bio': 'Bio',
    'zodiac': 'Zodiac',
    'zodiac_description': 'Zodiac description',
    'birthdate': 'Birth date',
    'country': 'Country',
    'interests': 'Interests',
    'image': 'Profile image',
    'cover': 'Cover image',
  };
  
  return fieldMap[field] ?? field;
}
}