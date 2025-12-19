import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/profile_response.dart';
import 'package:dio/dio.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository({required Dio dio}) : _dio = dio;

  Future<ProfileResponse> getMyProfile({int page = 1}) async {
    try {
      print('📡 Fetching profile page $page from: ${ApiConstants.apiBaseUrl}/profile?page=$page');
      
      final response = await _dio.get(
        '${ApiConstants.apiBaseUrl}/profile',
        queryParameters: {'page': page},
      );
      
      print('✅ Profile page $page response received');
      
      // طباعة معلومات الـ Pagination إذا كانت موجودة
      final data = response.data['data'] ?? {};
      final telegrams = data['telegrams'] ?? {};
      if (telegrams['pagination'] != null) {
        final pagination = telegrams['pagination'];
        print('📊 Pagination Data:');
        print('   - current_page: ${pagination['current_page']}');
        print('   - last_page: ${pagination['last_page']}');
        print('   - per_page: ${pagination['per_page']}');
        print('   - total: ${pagination['total']}');
        print('   - hasMore: ${(pagination['current_page'] ?? 1) < (pagination['last_page'] ?? 1)}');
      }
      
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Dio Error for page $page: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to load profile');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<ProfileResponse> getUserProfile(int userId, {int page = 1}) async {
    try {
      print('📡 Fetching user $userId profile page $page');
      
      final response = await _dio.get(
        '${ApiConstants.apiBaseUrl}/profile/$userId',
        queryParameters: {'page': page},
      );
      
      print('✅ User profile page $page response received');
      
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to load profile');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<ProfileResponse> updateProfile(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      
      final response = await _dio.post(
        '${ApiConstants.apiBaseUrl}/profile',
        data: formData,
      );
      
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to update profile');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}