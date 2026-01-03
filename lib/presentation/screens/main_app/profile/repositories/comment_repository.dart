// lib/presentation/screens/main_app/profile/repositories/comment_repository.dart
import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/comment_model.dart';
import 'package:dio/dio.dart';

class CommentRepository {
  final Dio _dio;

  CommentRepository({required Dio dio}) : _dio = dio;

  // الحصول على التعليقات
  Future<CommentsResponse> getComments(String telegramId, {int page = 1}) async {
    try {
      print('📡 Fetching comments for telegram: $telegramId, page: $page');
      
      final response = await _dio.get(
        '${ApiConstants.apiBaseUrl}/telegrams/$telegramId/comments',
        queryParameters: {'page': page},
      );
      
      print('✅ Comments fetched successfully');
      
      return CommentsResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Dio Error fetching comments: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to fetch comments');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Failed to fetch comments: $e');
    }
  }

  // إضافة تعليق
  Future<void> addComment({
    required String telegramId,
    required String content,
    int? parentId,
  }) async {
    try {
      print('📡 Adding comment to telegram: $telegramId');
      print('📝 Content: $content, Parent ID: $parentId');
      
      final data = {
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      };
      
      final response = await _dio.post(
        '${ApiConstants.apiBaseUrl}/telegrams/$telegramId/comments',
        data: data,
      );
      
      print('✅ Comment added successfully: ${response.data}');
    } on DioException catch (e) {
      print('❌ Dio Error adding comment: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to add comment');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  // حذف تعليق
  Future<void> deleteComment(int commentId) async {
    try {
      print('📡 Deleting comment: $commentId');
      
      await _dio.delete(
        '${ApiConstants.apiBaseUrl}/comments/$commentId',
      );
      
      print('✅ Comment deleted successfully');
    } on DioException catch (e) {
      print('❌ Dio Error deleting comment: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to delete comment');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Failed to delete comment: $e');
    }
  }
}