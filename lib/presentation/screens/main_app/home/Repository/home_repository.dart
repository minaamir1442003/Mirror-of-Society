import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/home/models/home_feed_model.dart';
import 'package:dio/dio.dart';

class HomeRepository {
  final Dio _dio;

  HomeRepository({required Dio dio}) : _dio = dio;

  Future<HomeFeedResponse> getHomeFeed({String? cursor}) async {
    try {
      print('📡 Fetching home feed from: ${ApiConstants.apiBaseUrl}/home');
      print('🔗 Cursor: $cursor');
      
      final queryParams = cursor != null ? {'cursor': cursor} : null;
      
      final response = await _dio.get(
        '${ApiConstants.apiBaseUrl}/home',
        queryParameters: queryParams,
      );
      
      print('✅ Home feed response received');
      print('📊 Total items: ${response.data['data']['feed']['data']?.length ?? 0}');
      
      return HomeFeedResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to load home feed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Failed to load home feed: $e');
    }
  }
  
  Future<void> likeTelegram(String telegramId) async {
    try {
      await _dio.post('${ApiConstants.apiBaseUrl}/telegrams/$telegramId/like');
    } catch (e) {
      print('❌ Error liking telegram: $e');
      throw Exception('Failed to like telegram');
    }
  }
  
  Future<void> unlikeTelegram(String telegramId) async {
    try {
      await _dio.delete('${ApiConstants.apiBaseUrl}/telegrams/$telegramId/like');
    } catch (e) {
      print('❌ Error unliking telegram: $e');
      throw Exception('Failed to unlike telegram');
    }
  }
  
  Future<void> repostTelegram(String telegramId) async {
    try {
      await _dio.post('${ApiConstants.apiBaseUrl}/telegrams/$telegramId/repost');
    } catch (e) {
      print('❌ Error reposting telegram: $e');
      throw Exception('Failed to repost telegram');
    }
  }
}