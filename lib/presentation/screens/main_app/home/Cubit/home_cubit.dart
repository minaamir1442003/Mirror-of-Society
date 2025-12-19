import 'package:app_1/presentation/screens/main_app/home/Repository/home_repository.dart';
import 'package:app_1/presentation/screens/main_app/home/models/home_feed_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  
  String? _nextCursor;
  bool _hasMore = true;
  bool _isFirstLoad = true;
  List<FeedItem> _allFeedItems = [];
  List<OnThisDayEvent> _onThisDayEvents = [];

  HomeCubit({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(HomeInitial());

  Future<void> getHomeFeed({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        // أول تحميل
        _nextCursor = null;
        _hasMore = true;
        _isFirstLoad = true;
        _allFeedItems = [];
        _onThisDayEvents = [];
        emit(HomeLoading());
      } else {
        // تحميل إضافي
        if (!_hasMore) {
          print('⚠️ No more data to load');
          return;
        }
        emit(HomeLoadingMore(feedItems: _allFeedItems));
      }

      print('📡 Loading home feed with cursor: $_nextCursor');
      final response = await _homeRepository.getHomeFeed(cursor: _nextCursor);
      
      // تحديث معلومات Pagination
      _nextCursor = response.data.pagination.nextCursor;
      _hasMore = response.data.pagination.hasMore;
      
      print('✅ Received ${response.data.feed.length} feed items');
      print('📊 Next cursor: $_nextCursor, Has more: $_hasMore');
      
      // إضافة العناصر الجديدة
      final newFeedItems = response.data.feed;
      _allFeedItems.addAll(newFeedItems);
      _onThisDayEvents = response.data.onThisDayEvents;
      
      print('📦 Total feed items now: ${_allFeedItems.length}');
      print('📅 On this day events: ${_onThisDayEvents.length}');
      
      _isFirstLoad = false;
      emit(HomeLoaded(
        feedItems: _allFeedItems,
        onThisDayEvents: _onThisDayEvents,
        hasMore: _hasMore,
      ));
    } catch (e) {
      print('❌ Error loading home feed: $e');
      if (_allFeedItems.isNotEmpty) {
        // إذا كان هناك خطأ ولكن لدينا بيانات، نعرضها
        emit(HomeLoaded(
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
      } else {
        emit(HomeError(error: e.toString()));
      }
    }
  }
  
  Future<void> likeTelegram(String telegramId) async {
    try {
      // تحديث حالة الإعجاب محلياً أولاً
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final updatedItem = FeedItem(
          id: _allFeedItems[index].id,
          content: _allFeedItems[index].content,
          type: _allFeedItems[index].type,
          createdAt: _allFeedItems[index].createdAt,
          user: _allFeedItems[index].user,
          category: _allFeedItems[index].category,
          metrics: FeedMetrics(
            likesCount: _allFeedItems[index].metrics.likesCount + 1,
            commentsCount: _allFeedItems[index].metrics.commentsCount,
            repostsCount: _allFeedItems[index].metrics.repostsCount,
          ),
          isLiked: true,
          isReposted: _allFeedItems[index].isReposted,
        );
        
        _allFeedItems[index] = updatedItem;
        emit(HomeLoaded(
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
      }
      
      // إرسال الطلب إلى السيرفر
      await _homeRepository.likeTelegram(telegramId);
    } catch (e) {
      print('❌ Error liking telegram: $e');
      // التراجع عن التغيير في حالة الخطأ
      getHomeFeed();
    }
  }
  
  Future<void> unlikeTelegram(String telegramId) async {
    try {
      // تحديث حالة الإعجاب محلياً أولاً
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final updatedItem = FeedItem(
          id: _allFeedItems[index].id,
          content: _allFeedItems[index].content,
          type: _allFeedItems[index].type,
          createdAt: _allFeedItems[index].createdAt,
          user: _allFeedItems[index].user,
          category: _allFeedItems[index].category,
          metrics: FeedMetrics(
            likesCount: _allFeedItems[index].metrics.likesCount - 1,
            commentsCount: _allFeedItems[index].metrics.commentsCount,
            repostsCount: _allFeedItems[index].metrics.repostsCount,
          ),
          isLiked: false,
          isReposted: _allFeedItems[index].isReposted,
        );
        
        _allFeedItems[index] = updatedItem;
        emit(HomeLoaded(
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
      }
      
      // إرسال الطلب إلى السيرفر
      await _homeRepository.unlikeTelegram(telegramId);
    } catch (e) {
      print('❌ Error unliking telegram: $e');
      // التراجع عن التغيير في حالة الخطأ
      getHomeFeed();
    }
  }
  
  Future<void> repostTelegram(String telegramId) async {
    try {
      // تحديث حالة إعادة النشر محلياً أولاً
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final updatedItem = FeedItem(
          id: _allFeedItems[index].id,
          content: _allFeedItems[index].content,
          type: _allFeedItems[index].type,
          createdAt: _allFeedItems[index].createdAt,
          user: _allFeedItems[index].user,
          category: _allFeedItems[index].category,
          metrics: FeedMetrics(
            likesCount: _allFeedItems[index].metrics.likesCount,
            commentsCount: _allFeedItems[index].metrics.commentsCount,
            repostsCount: _allFeedItems[index].metrics.repostsCount + 1,
          ),
          isLiked: _allFeedItems[index].isLiked,
          isReposted: true,
        );
        
        _allFeedItems[index] = updatedItem;
        emit(HomeLoaded(
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
      }
      
      // إرسال الطلب إلى السيرفر
      await _homeRepository.repostTelegram(telegramId);
    } catch (e) {
      print('❌ Error reposting telegram: $e');
      // التراجع عن التغيير في حالة الخطأ
      getHomeFeed();
    }
  }

  // دالة للتحقق إذا كان هذا أول تحميل
  bool get isFirstLoad => _isFirstLoad;
  
  // دالة للتحقق إذا كان هناك المزيد للتحميل
  bool get hasMore => _hasMore;
  
  // دالة للحصول على عدد العناصر الحالي
  int get feedItemsCount => _allFeedItems.length;
}