import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/models/telegram_m.dart';
import 'package:dio/dio.dart';

class TelegramRepository {
  final Dio _dio;

  TelegramRepository({required Dio dio}) : _dio = dio;

  // إنشاء برقية جديدة
  Future<Telegram> createTelegram({
    required String content,
    required int categoryId,
    bool isAd = false,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.apiBaseUrl}/telegrams',
        data: {
          'content': content,
          'category_id': categoryId,
          'is_ad': isAd,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Telegram.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create telegram: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error in createTelegram: $e');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Response status: ${e.response?.statusCode}');
      }
      rethrow;
    } catch (e) {
      print('Error in createTelegram: $e');
      rethrow;
    }
  }

  // ✅ دالة الحذف المصححة
  Future<void> deleteTelegram(int telegramId) async {
    try {
      print('🗑️ Deleting telegram $telegramId');
      
      final response = await _dio.delete(
        '${ApiConstants.apiBaseUrl}/telegrams/$telegramId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('✅ Delete response: ${response.statusCode}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete telegram: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio error in deleteTelegram: $e');
      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
        print('❌ Response status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  // ✅ دالة حذف إعادة النشر
  Future<void> deleteRepost(int telegramId) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.apiBaseUrl}/telegrams/$telegramId/repost',
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete repost: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ✅ دالة التبليغ المصححة
  Future<void> reportTelegram(int telegramId, String reason) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.apiBaseUrl}/telegrams/$telegramId/report',
        data: {'reason': reason},
      );
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to report telegram: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ✅ تحديث برقية
  Future<Telegram> updateTelegram({
  required int telegramId,
  String? content,
  int? categoryId,
  bool? isAd,
}) async {
  try {
    print('🔄 TelegramRepository: Updating telegram $telegramId');
    
    // ✅ إعداد البيانات بشكل صحيح
    Map<String, dynamic> data = {};
    if (content != null) data['content'] = content;
    if (categoryId != null) data['category_id'] = categoryId;
    if (isAd != null) data['is_ad'] = isAd;
    
    print('📦 Update data: $data');
    print('🔗 Endpoint: ${ApiConstants.apiBaseUrl}/telegrams/$telegramId');
    
    final response = await _dio.post(
      '${ApiConstants.apiBaseUrl}/telegrams/$telegramId',
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    print('✅ Update response status: ${response.statusCode}');
    print('📄 Response data: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ✅ محاولة تحليل البيانات بطرق مختلفة
      Map<String, dynamic> responseData;
      
      if (response.data is Map) {
        responseData = response.data as Map<String, dynamic>;
        
        // ✅ البحث عن البيانات في الهيكل المتوقع
        if (responseData.containsKey('data')) {
          return Telegram.fromJson(responseData['data']);
        } else if (responseData.containsKey('telegram')) {
          return Telegram.fromJson(responseData['telegram']);
        } else {
          // ✅ إذا كانت البيانات مباشرة في الـ response
          return Telegram.fromJson(responseData);
        }
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to update telegram: ${response.statusCode}');
    }
  } on DioException catch (e) {
    print('❌ Dio error in updateTelegram: $e');
    if (e.response != null) {
      print('❌ Response data: ${e.response?.data}');
      print('❌ Response status: ${e.response?.statusCode}');
    }
    rethrow;
  } catch (e) {
    print('❌ Unknown error in updateTelegram: $e');
    rethrow;
  }
}

  // الإعجاب/إلغاء الإعجاب ببرقية
  Future<void> toggleLike(int telegramId) async {
    try {
      await _dio.post('${ApiConstants.apiBaseUrl}/telegrams/$telegramId/like');
    } on DioException catch (e) {
      print('Dio error in toggleLike: $e');
      rethrow;
    }
  }

  // إعادة نشر برقية
  Future<void> repostTelegram(int telegramId) async {
    try {
      await _dio.post('${ApiConstants.apiBaseUrl}/telegrams/$telegramId/repost');
    } on DioException catch (e) {
      print('Dio error in repostTelegram: $e');
      rethrow;
    }
  }

  // إضافة تعليق
  Future<void> addComment({
    required int telegramId,
    required String content,
    int? parentId,
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.apiBaseUrl}/telegrams/$telegramId/comments',
        data: {
          'content': content,
          if (parentId != null) 'parent_id': parentId,
        },
      );
    } on DioException catch (e) {
      print('Dio error in addComment: $e');
      rethrow;
    }
  }
}