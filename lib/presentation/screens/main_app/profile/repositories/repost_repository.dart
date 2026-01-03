import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/repost_model.dart';
import 'package:dio/dio.dart';

class RepostRepository {
  final Dio _dio;

  RepostRepository({required Dio dio}) : _dio = dio;

  // إجراء Repost (إعادة نشر)
  Future<void> toggleRepost(String telegramId) async {
    try {
      print('📡 Toggling repost for telegram: $telegramId');
      
      final response = await _dio.post(
        '${ApiConstants.apiBaseUrl}/telegrams/$telegramId/repost',
      );
      
      print('✅ Repost toggled successfully: ${response.data}');
    } on DioException catch (e) {
      print('❌ Dio Error toggling repost: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to toggle repost');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Failed to toggle repost: $e');
    }
  }

  // الحصول على قائمة الأشخاص الذين أعادوا نشر البرقية
  Future<RepostsResponse> getReposts(String telegramId, {int page = 1}) async {
    try {
      print('📡 Fetching reposts for telegram: $telegramId, page: $page');
      
      final response = await _dio.get(
        '${ApiConstants.apiBaseUrl}/telegrams/$telegramId/reposts',
        queryParameters: {'page': page},
      );
      
      print('✅ Reposts fetched successfully');
      
      return RepostsResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Dio Error fetching reposts: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to fetch reposts');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Failed to fetch reposts: $e');
    }
  }
}