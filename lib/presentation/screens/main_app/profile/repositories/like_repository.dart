import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/like_model.dart';
import 'package:dio/dio.dart';

class LikeRepository {
  final Dio _dio;

  LikeRepository({required Dio dio}) : _dio = dio;

  // إضافة أو إزالة Like للبرقية
  Future<void> toggleLike(String telegramId) async {
    try {
      print('📡 Toggling like for telegram: $telegramId');
      
      final response = await _dio.post(
        '${ApiConstants.apiBaseUrl}/telegrams/$telegramId/like',
      );
      
      print('✅ Like toggled successfully: ${response.data}');
    } on DioException catch (e) {
      print('❌ Dio Error toggling like: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to toggle like');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Failed to toggle like: $e');
    }
  }

  // الحصول على قائمة الأشخاص الذين أعجبوا بالبرقية
  Future<LikesResponse> getLikes(String telegramId, {int page = 1}) async {
    try {
      print('📡 Fetching likes for telegram: $telegramId, page: $page');
      
      final response = await _dio.get(
        '${ApiConstants.apiBaseUrl}/telegrams/$telegramId/likes',
        queryParameters: {'page': page},
      );
      
      print('✅ Likes fetched successfully');
      
      return LikesResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Dio Error fetching likes: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to fetch likes');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Failed to fetch likes: $e');
    }
  }
}