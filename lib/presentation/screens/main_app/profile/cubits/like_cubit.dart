import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/like_model.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/like_repository.dart';

part 'like_state.dart';

class LikeCubit extends Cubit<LikeState> {
  final LikeRepository _likeRepository;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  String? _currentTelegramId;
  
  List<LikeModel> _allLikes = [];

  LikeCubit({required LikeRepository likeRepository})
      : _likeRepository = likeRepository,
        super(LikeInitial());

  // تبديل حالة الإعجاب
  Future<void> toggleLike(String telegramId) async {
    emit(LikeToggling());
    
    try {
      await _likeRepository.toggleLike(telegramId);
      emit(LikeToggledSuccess());
    } catch (e) {
      emit(LikeError(error: 'فشل في الإعجاب: $e'));
    }
  }

  // الحصول على قائمة الإعجابات
  Future<void> getLikes(String telegramId, {bool loadMore = false, bool forceRefresh = false}) async {
    // منع التحميل إذا كان جارياً بالفعل
    if (_isLoading && !loadMore && !forceRefresh) {
      print('⏸️ LikeCubit: Loading already in progress, skipping...');
      return;
    }
    
    if (forceRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _allLikes = [];
      _currentTelegramId = telegramId;
      _isLoading = false;
    }
    
    // إذا كانت هذه هي نفس البرقية ولدينا بيانات مخزنة
    if (!loadMore && !forceRefresh && _currentTelegramId == telegramId && _allLikes.isNotEmpty) {
      print('📱 LikeCubit: Using cached likes for telegram: $telegramId');
      emit(LikesLoaded(likes: _allLikes, hasMore: _hasMore));
      return;
    }
    
    try {
      _isLoading = true;
      
      if (!loadMore && !forceRefresh) {
        // إذا كانت برقية مختلفة، نبدأ من جديد
        if (_currentTelegramId != telegramId) {
          _currentPage = 1;
          _hasMore = true;
          _allLikes = [];
          _currentTelegramId = telegramId;
          emit(LikeLoading());
        } else {
          // نفس البرقية، نستخدم البيانات المخزنة
          emit(LikesLoaded(likes: _allLikes, hasMore: _hasMore));
          _isLoading = false;
          return;
        }
      } else {
        if (!_hasMore && !forceRefresh) {
          print('⚠️ No more likes to load');
          _isLoading = false;
          return;
        }
        
        if (!forceRefresh) {
          emit(LikeLoadingMore(likes: _allLikes));
        }
      }
      
      final response = await _likeRepository.getLikes(telegramId, page: _currentPage);
      
      if (response.data.pagination.hasMore) {
        _hasMore = response.data.pagination.hasMore;
      } else {
        _hasMore = response.data.likes.isNotEmpty;
      }
      
      // إضافة الـ Likes الجديدة
      if (forceRefresh || _currentPage == 1) {
        _allLikes = response.data.likes;
      } else {
        _allLikes.addAll(response.data.likes);
      }
      
      if (_hasMore && !forceRefresh) {
        _currentPage++;
      }
      
      _isLoading = false;
      
      emit(LikesLoaded(likes: _allLikes, hasMore: _hasMore));
      
    } catch (e) {
      print('❌ Error loading likes: $e');
      _isLoading = false;
      
      // محاولة إظهار البيانات المخزنة في حالة الخطأ
      if (_allLikes.isNotEmpty) {
        emit(LikesLoaded(likes: _allLikes, hasMore: _hasMore));
      } else {
        emit(LikeError(error: 'فشل في تحميل الإعجابات: $e'));
      }
    }
  }

  // تفريغ البيانات
  void clearLikes() {
    _currentPage = 1;
    _hasMore = true;
    _allLikes = [];
    _currentTelegramId = null;
    _isLoading = false;
    emit(LikeInitial());
  }
  
  // الحصول على عدد الـ Likes الحالي
  int get likesCount => _allLikes.length;
  
  // التحقق إذا كان هناك المزيد للتحميل
  bool get hasMore => _hasMore;
}