

import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/home/Models/home_feed_model.dart';
import 'package:dio/dio.dart';

class HomeRepository {
  final Dio _dio;

  HomeRepository({required Dio dio}) : _dio = dio;

  // ✅ 1. جلب كل البرقيات
  Future<HomeFeedResponse> getHomeFeed({String? cursor}) async {
    try {
      print('📡 جلب كل البرقيات');
      
      final queryParams = cursor != null ? {'cursor': cursor} : null;
      
      final response = await _dio.get(
        '${ApiConstants.apiBaseUrl}/home',
        queryParameters: queryParams,
      );
      
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'فشل تحميل البرقيات');
      }
      
      return HomeFeedResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ خطأ: ${e.message}');
      throw Exception(e.response?.data['message'] ?? 'فشل تحميل البرقيات');
    } catch (e) {
      print('❌ خطأ غير معروف: $e');
      throw Exception('فشل تحميل البرقيات');
    }
  }

  // ✅ 2. جلب برقيات تصنيف معين
  Future<HomeFeedResponse> getCategoryFeed({
    required String categoryId, 
    String? cursor
  }) async {
    try {
      print('📡 جلب برقيات التصنيف $categoryId');
      
      final queryParams = cursor != null ? {'cursor': cursor} : null;
      
      final response = await _dio.get(
        '${ApiConstants.apiBaseUrl}/home/categories/$categoryId',
        queryParameters: queryParams,
      );
      
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'فشل تحميل برقيات التصنيف');
      }
      
      return HomeFeedResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ خطأ (تصنيف): ${e.message}');
      throw Exception(e.response?.data['message'] ?? 'فشل تحميل برقيات التصنيف');
    } catch (e) {
      print('❌ خطأ غير معروف (تصنيف): $e');
      throw Exception('فشل تحميل برقيات التصنيف');
    }
  }
  
  // ✅ 3. جلب كل التصنيفات
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.apiBaseUrl}/categories',
      );
      
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'فشل تحميل التصنيفات');
      }
      
      final categories = (response.data['data'] as List)
          .map((item) => Category.fromJson(item))
          .toList();
      
      return categories;
    } catch (e) {
      print('❌ خطأ في تحميل التصنيفات: $e');
      throw Exception('فشل تحميل التصنيفات');
    }
  }
  
  // ✅ 4. دوال التفاعل
  Future<void> likeTelegram(String telegramId) async {
    try {
      await _dio.post('${ApiConstants.apiBaseUrl}/telegrams/$telegramId/like');
    } catch (e) {
      throw Exception('فشل الإعجاب بالبرقية');
    }
  }
  
  Future<void> unlikeTelegram(String telegramId) async {
    try {
      await _dio.delete('${ApiConstants.apiBaseUrl}/telegrams/$telegramId/like');
    } catch (e) {
      throw Exception('فشل إلغاء الإعجاب');
    }
  }
  
  Future<void> repostTelegram(String telegramId) async {
    try {
      await _dio.post('${ApiConstants.apiBaseUrl}/telegrams/$telegramId/repost');
    } catch (e) {
      throw Exception('فشل إعادة النشر');
    }
  }
}