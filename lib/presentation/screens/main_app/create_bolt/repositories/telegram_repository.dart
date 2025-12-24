

import 'package:app_1/core/constants/dio_client.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/models/telegram_m.dart';
import 'package:dio/dio.dart';

class TelegramRepository {
  final Dio _dio;

  TelegramRepository({required DioClient dioClient})
      : _dio = dioClient.dio;

  // إنشاء برقية جديدة
  Future<Telegram> createTelegram({
    required String content,
    required int categoryId,
    bool isAd = false,
  }) async {
    try {
      final response = await _dio.post(
        '/telegrams',
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

  // تحديث برقية
  Future<Telegram> updateTelegram({
    required int telegramId,
    String? content,
    int? categoryId,
    bool? isAd,
  }) async {
    try {
      final response = await _dio.post(
        '/telegrams/$telegramId',
        data: {
          if (content != null) 'content': content,
          if (categoryId != null) 'category_id': categoryId,
          if (isAd != null) 'is_ad': isAd,
        },
      );

      if (response.statusCode == 200) {
        return Telegram.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update telegram: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error in updateTelegram: $e');
      rethrow;
    }
  }

  // حذف برقية
  Future<bool> deleteTelegram(int telegramId) async {
    try {
      final response = await _dio.delete('/telegrams/$telegramId');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete telegram: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error in deleteTelegram: $e');
      rethrow;
    }
  }

  // الإعجاب/إلغاء الإعجاب ببرقية
  Future<void> toggleLike(int telegramId) async {
    try {
      await _dio.post('/telegrams/$telegramId/like');
    } on DioException catch (e) {
      print('Dio error in toggleLike: $e');
      rethrow;
    }
  }

  // إعادة نشر برقية
  Future<void> repostTelegram(int telegramId) async {
    try {
      await _dio.post('/telegrams/$telegramId/repost');
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
        '/telegrams/$telegramId/comments',
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