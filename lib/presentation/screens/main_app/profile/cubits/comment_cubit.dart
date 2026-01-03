// lib/presentation/screens/main_app/profile/cubits/comment_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/comment_model.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/comment_repository.dart';

part 'comment_state.dart';

class CommentCubit extends Cubit<CommentState> {
  final CommentRepository _commentRepository;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  String? _currentTelegramId;
  
  List<CommentModel> _allComments = [];

  CommentCubit({required CommentRepository commentRepository})
      : _commentRepository = commentRepository,
        super(CommentInitial());

  // ========== إضافة خاصية عامة للوصول إلى التعليقات ==========
  List<CommentModel> get comments => List.from(_allComments);

  // الحصول على التعليقات
  Future<void> getComments(String telegramId, {bool loadMore = false, bool forceRefresh = false}) async {
    // منع التحميل إذا كان جارياً بالفعل
    if (_isLoading && !loadMore && !forceRefresh) {
      print('⏸️ CommentCubit: Loading already in progress, skipping...');
      return;
    }
    
    if (forceRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _allComments = [];
      _currentTelegramId = telegramId;
      _isLoading = false;
      emit(CommentLoading()); // إضافة: إرسال حالة التحميل عند forceRefresh
    }
    
    // إذا كانت هذه هي نفس البرقية ولدينا بيانات مخزنة
    if (!loadMore && !forceRefresh && _currentTelegramId == telegramId && _allComments.isNotEmpty) {
      print('📱 CommentCubit: Using cached comments for telegram: $telegramId');
      emit(CommentsLoaded(comments: _allComments, hasMore: _hasMore));
      return;
    }
    
    try {
      _isLoading = true;
      
      if (!loadMore && !forceRefresh) {
        // إذا كانت برقية مختلفة، نبدأ من جديد
        if (_currentTelegramId != telegramId) {
          _currentPage = 1;
          _hasMore = true;
          _allComments = [];
          _currentTelegramId = telegramId;
          emit(CommentLoading());
        } else {
          // نفس البرقية، نستخدم البيانات المخزنة
          emit(CommentsLoaded(comments: _allComments, hasMore: _hasMore));
          _isLoading = false;
          return;
        }
      } else {
        if (!_hasMore && !forceRefresh) {
          print('⚠️ No more comments to load');
          _isLoading = false;
          return;
        }
        
        if (!forceRefresh) {
          emit(CommentLoadingMore(comments: _allComments));
        }
      }
      
      print('📡 CommentCubit: Fetching comments for telegram: $telegramId, page: $_currentPage');
      final response = await _commentRepository.getComments(telegramId, page: _currentPage);
      
      print('✅ CommentCubit: Comments fetched successfully, count: ${response.data.comments.length}');
      
      if (response.data.pagination.hasMore) {
        _hasMore = response.data.pagination.hasMore;
      } else {
        _hasMore = response.data.comments.isNotEmpty;
      }
      
      // إضافة التعليقات الجديدة
      if (forceRefresh || _currentPage == 1) {
        _allComments = response.data.comments;
      } else {
        _allComments.addAll(response.data.comments);
      }
      
      if (_hasMore && !forceRefresh) {
        _currentPage++;
      }
      
      _isLoading = false;
      
      emit(CommentsLoaded(comments: _allComments, hasMore: _hasMore));
      
    } catch (e) {
      print('❌ Error loading comments: $e');
      _isLoading = false;
      
      // محاولة إظهار البيانات المخزنة في حالة الخطأ
      if (_allComments.isNotEmpty) {
        emit(CommentsLoaded(comments: _allComments, hasMore: _hasMore));
      } else {
        emit(CommentError(error: 'فشل في تحميل التعليقات: $e'));
      }
    }
  }

  // إضافة تعليق - الإصدار المصحح
  Future<void> addComment({
    required String telegramId,
    required String content,
    int? parentId,
  }) async {
    try {
      print('➕ CommentCubit: Adding comment to telegram: $telegramId');
      emit(CommentAdding());
      
      await _commentRepository.addComment(
        telegramId: telegramId,
        content: content,
        parentId: parentId,
      );
      
      print('✅ CommentCubit: Comment added successfully, refreshing...');
      
      // إعادة تحميل التعليقات بعد الإضافة
      await getComments(telegramId, forceRefresh: true);
      
      // ⚠️ تمت إزالة emit(CommentAdded) لأن getComments يرسل CommentsLoaded بالفعل
      
    } catch (e) {
      print('❌ CommentCubit: Error adding comment: $e');
      emit(CommentError(error: 'فشل في إضافة التعليق: $e'));
    }
  }

  // حذف تعليق - الإصدار المصحح
  Future<void> deleteComment(int commentId, String telegramId) async {
    try {
      print('🗑️ CommentCubit: Deleting comment: $commentId');
      emit(CommentDeleting());
      
      await _commentRepository.deleteComment(commentId);
      
      print('✅ CommentCubit: Comment deleted successfully, refreshing...');
      
      // إعادة تحميل التعليقات بعد الحذف
      await getComments(telegramId, forceRefresh: true);
      
      // ⚠️ تمت إزالة emit(CommentDeleted) لأن getComments يرسل CommentsLoaded بالفعل
      
    } catch (e) {
      print('❌ CommentCubit: Error deleting comment: $e');
      emit(CommentError(error: 'فشل في حذف التعليق: $e'));
    }
  }

  // تفريغ البيانات
  void clearComments() {
    _currentPage = 1;
    _hasMore = true;
    _allComments = [];
    _currentTelegramId = null;
    _isLoading = false;
    emit(CommentInitial());
  }
  
  // الحصول على عدد التعليقات الحالي
  int get commentsCount => _allComments.length;
  
  // التحقق إذا كان هناك المزيد للتحميل
  bool get hasMore => _hasMore;
}