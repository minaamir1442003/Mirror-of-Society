import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/models/user_profile_model.dart';
import 'package:dio/dio.dart';

class UserProfileRepository {
  final Dio _dio;

  UserProfileRepository({required Dio dio}) : _dio = dio;

  Future<UserProfileResponse> getUserProfile(String userId, {int page = 1}) async {
    try {
      print('📡 Fetching user profile for ID: $userId, page: $page');
      
      final response = await _dio.get(
        '${ApiConstants.apiBaseUrl}/profile/$userId',
        queryParameters: {'page': page},
      );
      
      print('✅ User profile response received');
      print('📄 Response data keys: ${response.data['data']?.keys}');
      
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load user profile');
      }
      
      return UserProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      print('❌ Status code: ${e.response?.statusCode}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to load user profile');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Failed to load user profile: $e');
    }
  }

  // ✅ دالة جديدة لجلب البرقيات فقط (بدون بيانات المستخدم)
  Future<UserTelegrams> getUserTelegramsOnly(String userId, {int page = 1}) async {
    try {
      print('📡 Fetching telegrams for user ID: $userId, page: $page');
      
      final response = await _dio.get(
        '${ApiConstants.apiBaseUrl}/profile/$userId',
        queryParameters: {'page': page},
      );
      
      print('✅ Telegrams response received');
      
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load telegrams');
      }
      
      // ✅ استخراج بيانات البرقيات فقط
      final telegramsData = response.data['data']['telegrams'];
      return UserTelegrams.fromJson(telegramsData);
    } on DioException catch (e) {
      print('❌ Dio Error loading telegrams: ${e.message}');
      throw Exception('Failed to load telegrams: ${e.message}');
    } catch (e) {
      print('❌ Unknown Error loading telegrams: $e');
      throw Exception('Failed to load telegrams');
    }
  }

  Future<void> followUser(String userId) async {
    try {
      await _dio.post('${ApiConstants.apiBaseUrl}/follow/$userId');
    } catch (e) {
      print('❌ Error following user: $e');
      throw Exception('Failed to follow user');
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      await _dio.post('${ApiConstants.apiBaseUrl}/unfollow/$userId');
    } catch (e) {
      print('❌ Error unfollowing user: $e');
      throw Exception('Failed to unfollow user');
    }
  }
}