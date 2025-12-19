// lib/presentation/screens/main_app/profile/repositories/update_profile_repository.dart
import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/profile_response.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/update_profile_request.dart';
import 'package:dio/dio.dart';

class UpdateProfileRepository {
  final Dio _dio;

  UpdateProfileRepository({required Dio dio}) : _dio = dio;

  Future<ProfileResponse> updateProfile(UpdateProfileRequest request) async {
    try {
      print('📡 Updating profile...');
      
      // إنشاء FormData مع الملفات
      final formData = await request.toFormDataWithFiles();
      
      print('📦 Sending update request with data: ${request.toFormData()}');
      
      final response = await _dio.post(
        '${ApiConstants.apiBaseUrl}/profile',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      print('✅ Profile updated successfully');
      print('📊 Response: ${response.data}');
      
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Dio Error updating profile: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to update profile');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // دالة للحصول على قائمة الاهتمامات المتاحة
  Future<List<Map<String, dynamic>>> getAvailableInterests() async {
    try {
      print('📡 Fetching available interests...');
      
      final response = await _dio.get('${ApiConstants.apiBaseUrl}/categories');
      
      print('✅ Interests fetched successfully');
      
      final List<dynamic> categories = response.data['data'] ?? [];
      return categories.map((category) {
        return {
          'id': category['id'] ?? 0,
          'name': category['name'] ?? '',
          'color': category['color'] ?? '#007bff',
        };
      }).toList();
    } catch (e) {
      print('❌ Error fetching interests: $e');
      return [];
    }
  }

  // دالة للحصول على قائمة الأبراج
  Future<List<Map<String, dynamic>>> getAvailableZodiacs() async {
  try {
    print('📡 Fetching available zodiacs...');
    
    final response = await _dio.get('${ApiConstants.apiBaseUrl}/zodiacs');
    
    print('✅ Zodiacs fetched successfully');
    
    final List<dynamic> zodiacs = response.data['data'] ?? [];
    
    // إزالة التكرارات باستخدام Map و Set
    final Map<String, Map<String, dynamic>> uniqueZodiacs = {};
    
    for (var zodiac in zodiacs) {
      final name = zodiac['name']?.toString() ?? '';
      if (name.isNotEmpty && !uniqueZodiacs.containsKey(name)) {
        uniqueZodiacs[name] = {
          'id': zodiac['id'] ?? 0,
          'name': name,
          'description': zodiac['description'] ?? '',
          'icon': zodiac['icon'] ?? '',
        };
      }
    }
    
    return uniqueZodiacs.values.toList();
  } catch (e) {
    print('❌ Error fetching zodiacs: $e');
    return [];
  }
}
}