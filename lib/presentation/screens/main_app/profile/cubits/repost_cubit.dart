import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/repost_model.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/repost_repository.dart';

part 'repost_state.dart';

class RepostCubit extends Cubit<RepostState> {
  final RepostRepository _repostRepository;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  String? _currentTelegramId;
  
  List<RepostModel> _allReposts = [];

  RepostCubit({required RepostRepository repostRepository})
      : _repostRepository = repostRepository,
        super(RepostInitial());

  // تبديل حالة Repost
  Future<void> toggleRepost(String telegramId) async {
    emit(RepostToggling());
    
    try {
      await _repostRepository.toggleRepost(telegramId);
      emit(RepostToggledSuccess());
    } catch (e) {
      emit(RepostError(error: 'فشل في إعادة النشر: $e'));
    }
  }

  // الحصول على قائمة Reposts
  Future<void> getReposts(String telegramId, {bool loadMore = false, bool forceRefresh = false}) async {
    // منع التحميل إذا كان جارياً بالفعل
    if (_isLoading && !loadMore && !forceRefresh) {
      print('⏸️ RepostCubit: Loading already in progress, skipping...');
      return;
    }
    
    if (forceRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _allReposts = [];
      _currentTelegramId = telegramId;
      _isLoading = false;
    }
    
    // إذا كانت هذه هي نفس البرقية ولدينا بيانات مخزنة
    if (!loadMore && !forceRefresh && _currentTelegramId == telegramId && _allReposts.isNotEmpty) {
      print('📱 RepostCubit: Using cached reposts for telegram: $telegramId');
      emit(RepostsLoaded(reposts: _allReposts, hasMore: _hasMore));
      return;
    }
    
    try {
      _isLoading = true;
      
      if (!loadMore && !forceRefresh) {
        // إذا كانت برقية مختلفة، نبدأ من جديد
        if (_currentTelegramId != telegramId) {
          _currentPage = 1;
          _hasMore = true;
          _allReposts = [];
          _currentTelegramId = telegramId;
          emit(RepostLoading());
        } else {
          // نفس البرقية، نستخدم البيانات المخزنة
          emit(RepostsLoaded(reposts: _allReposts, hasMore: _hasMore));
          _isLoading = false;
          return;
        }
      } else {
        if (!_hasMore && !forceRefresh) {
          print('⚠️ No more reposts to load');
          _isLoading = false;
          return;
        }
        
        if (!forceRefresh) {
          emit(RepostLoadingMore(reposts: _allReposts));
        }
      }
      
      final response = await _repostRepository.getReposts(telegramId, page: _currentPage);
      
      if (response.data.pagination.hasMore) {
        _hasMore = response.data.pagination.hasMore;
      } else {
        _hasMore = response.data.reposts.isNotEmpty;
      }
      
      // إضافة الـ Reposts الجديدة
      if (forceRefresh || _currentPage == 1) {
        _allReposts = response.data.reposts;
      } else {
        _allReposts.addAll(response.data.reposts);
      }
      
      if (_hasMore && !forceRefresh) {
        _currentPage++;
      }
      
      _isLoading = false;
      
      emit(RepostsLoaded(reposts: _allReposts, hasMore: _hasMore));
      
    } catch (e) {
      print('❌ Error loading reposts: $e');
      _isLoading = false;
      
      // محاولة إظهار البيانات المخزنة في حالة الخطأ
      if (_allReposts.isNotEmpty) {
        emit(RepostsLoaded(reposts: _allReposts, hasMore: _hasMore));
      } else {
        emit(RepostError(error: 'فشل في تحميل إعادة النشر: $e'));
      }
    }
  }

  // تفريغ البيانات
  void clearReposts() {
    _currentPage = 1;
    _hasMore = true;
    _allReposts = [];
    _currentTelegramId = null;
    _isLoading = false;
    emit(RepostInitial());
  }
  
  // الحصول على عدد الـ Reposts الحالي
  int get repostsCount => _allReposts.length;
  
  // التحقق إذا كان هناك المزيد للتحميل
  bool get hasMore => _hasMore;
}