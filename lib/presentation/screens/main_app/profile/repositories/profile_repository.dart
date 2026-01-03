import 'dart:convert';

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
      
      // ✅ التحقق من هيكل البيانات
      print('🔍 Response data structure:');
      print(jsonEncode(response.data));
      
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