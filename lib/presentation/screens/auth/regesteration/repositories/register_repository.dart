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

      // 7. Handle Response
      final responseData = response.data;

      // إذا كان الـstatus = false من السيرفر
      if (responseData['status'] == false) {
        print('❌ Registration failed with data: $responseData');
        
        // **استخراج رسالة الخطأ المباشرة من الـ errors**
        String errorMessage = 'Registration failed';
        
        if (responseData.containsKey('errors') && responseData['errors'] is Map) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          print('🔍 Full errors from server: $errors');
          
          // استخراج أول رسالة خطأ (الأولوية للـ email)
          if (errors.containsKey('email') && errors['email'] is List && (errors['email'] as List).isNotEmpty) {
            errorMessage = (errors['email'] as List)[0].toString();
            print('✅ Extracted email error: $errorMessage');
          } 
          // إذا لم يكن هناك email error، أخذ أول خطأ موجود
          else if (errors.isNotEmpty) {
            final firstErrorKey = errors.keys.first;
            final firstErrorValue = errors[firstErrorKey];
            
            if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
              errorMessage = firstErrorValue[0].toString();
            } else if (firstErrorValue is String) {
              errorMessage = firstErrorValue;
            }
            print('✅ Extracted first error ($firstErrorKey): $errorMessage');
          }
        } else {
          // إذا لم يكن هناك errors، استخدم message العامة
          errorMessage = responseData['message'] ?? 'Registration failed';
          print('⚠️ No errors key, using message: $errorMessage');
        }
        
        print('✅ Final error message to send: $errorMessage');
        
        // **استخدام الـ factory الجديدة**
        return RegisterResponse.failure(
          message: errorMessage,
          errorData: responseData['errors'] ?? {},
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
        return RegisterResponse.success(
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
          final responseData = e.response!.data;
          print('🔍 422 Validation Error Response: $responseData');
          
          if (responseData is Map && responseData.containsKey('errors')) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            
            // استخراج رسالة الـ email مباشرة
            String errorMessage = 'validation error';
            
            if (errors.containsKey('email') && errors['email'] is List && (errors['email'] as List).isNotEmpty) {
              errorMessage = (errors['email'] as List)[0].toString();
              print('✅ Extracted email error from 422: $errorMessage');
            } 
            // إذا لم يكن هناك email error
            else if (errors.isNotEmpty) {
              final firstErrorKey = errors.keys.first;
              final firstErrorValue = errors[firstErrorKey];
              
              if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
                errorMessage = firstErrorValue[0].toString();
              } else if (firstErrorValue is String) {
                errorMessage = firstErrorValue;
              }
              print('✅ Extracted first error from 422 ($firstErrorKey): $errorMessage');
            }
            
            print('✅ Final error message from 422: $errorMessage');
            
            return RegisterResponse.failure(
              message: errorMessage,
              errorData: errors,
            );
          }
        }

        // حالة 400-500 أخرى
        final responseData = e.response!.data;
        String errorMessage = 'Connection failed';
        
        if (responseData is Map && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
        
        return RegisterResponse.failure(
          message: errorMessage,
          errorData: {},
        );
      }

      throw Exception('Connection failed: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}