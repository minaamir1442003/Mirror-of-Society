import 'dart:convert';

import 'package:app_1/presentation/screens/main_app/home/Repository/home_repository.dart';
import 'package:app_1/presentation/screens/main_app/home/models/home_feed_model.dart';
import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  final StorageService _storageService;
  
  String? _nextCursor;
  bool _hasMore = true;
  bool _isFirstLoad = true;
  bool _isLoadingMore = false;
  List<FeedItem> _allFeedItems = [];
  List<OnThisDayEvent> _onThisDayEvents = [];
  
  static const String _cachedFeedKey = 'cached_home_feed';
  static const String _cachedNextCursorKey = 'cached_next_cursor';
  static const String _cachedHasMoreKey = 'cached_has_more';
  static const String _cachedTimestampKey = 'cached_timestamp';
  static const Duration _cacheDuration = Duration(minutes: 10); // التخزين لمدة 10 دقائق

  HomeCubit({
    required HomeRepository homeRepository,
    required StorageService storageService,
  }) : _homeRepository = homeRepository,
        _storageService = storageService,
        super(HomeInitial());

  Future<void> getHomeFeed({bool loadMore = false, bool forceRefresh = false}) async {
    try {
      // ✅ التحقق من وجود بيانات مخزنة وعدم انتهاء صلاحيتها
      if (!forceRefresh && !loadMore && await _hasValidCache()) {
        await _loadFromCache();
        return;
      }

      // ✅ منع التحميل المزدوج
      if (_isLoadingMore && loadMore) return;
      
      if (!loadMore) {
        // أول تحميل
        print('🔄 First load ${forceRefresh ? '(Force refresh)' : ''}');
        _nextCursor = null;
        _hasMore = true;
        _isFirstLoad = true;
        _allFeedItems = [];
        _onThisDayEvents = [];
        emit(HomeLoading());
      } else {
        // تحميل إضافي
        if (!_hasMore || _isLoadingMore) {
          print('⚠️ No more data to load or already loading');
          return;
        }
        print('🔄 Loading more with cursor: $_nextCursor');
        _isLoadingMore = true;
        emit(HomeLoadingMore(feedItems: _allFeedItems));
      }

      final response = await _homeRepository.getHomeFeed(
        cursor: loadMore ? _nextCursor : null
      );
      
      // ✅ تحديث معلومات Pagination
      _nextCursor = response.data.pagination.nextCursor;
      _hasMore = response.data.pagination.hasMore;
      
      print('✅ Received ${response.data.feed.length} feed items');
      print('📊 Next cursor: $_nextCursor, Has more: $_hasMore');
      
      if (loadMore) {
        // إضافة العناصر الجديدة
        _allFeedItems.addAll(response.data.feed);
      } else {
        // استبدال العناصر القديمة
        _allFeedItems = response.data.feed;
      }
      
      _onThisDayEvents = response.data.onThisDayEvents;
      
      print('📦 Total feed items now: ${_allFeedItems.length}');
      print('📅 On this day events: ${_onThisDayEvents.length}');
      
      _isFirstLoad = false;
      _isLoadingMore = false;
      
      // ✅ حفظ البيانات في التخزين المؤقت
      if (!loadMore) {
        await _saveToCache();
      }
      
      emit(HomeLoaded(
        feedItems: _allFeedItems,
        onThisDayEvents: _onThisDayEvents,
        hasMore: _hasMore,
      ));
      
    } catch (e) {
      _isLoadingMore = false;
      print('❌ Error loading home feed: $e');
      
      // ✅ إذا فشل التحميل من الشبكة، حاول تحميل من التخزين
      if (!loadMore && _allFeedItems.isEmpty && await _hasValidCache()) {
        print('🔄 Falling back to cached data');
        await _loadFromCache();
      } else if (_allFeedItems.isNotEmpty) {
        // إذا كان هناك خطأ ولكن لدينا بيانات، نعرضها
        emit(HomeLoaded(
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
      } else {
        emit(HomeError(
          error: e.toString(),
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
      }
    }
  }

  // ✅ دالة للتحقق من وجود بيانات مخزنة صالحة
  Future<bool> _hasValidCache() async {
    try {
      await _storageService.ensureInitialized();
      final cachedTimestamp = await _storageService.readSecureData(_cachedTimestampKey);
      
      if (cachedTimestamp == null) return false;
      
      final timestamp = DateTime.tryParse(cachedTimestamp);
      if (timestamp == null) return false;
      
      final now = DateTime.now();
      final difference = now.difference(timestamp);
      
      return difference < _cacheDuration;
    } catch (e) {
      print('❌ Error checking cache validity: $e');
      return false;
    }
  }
  Future<void> clearCacheAndData() async {
  print('🧹 HomeCubit: Clearing all cache and data...');
  
  // مسح البيانات المحلية
  _allFeedItems.clear();
  _onThisDayEvents.clear();
  _nextCursor = null;
  _hasMore = true;
  _isFirstLoad = true;
  _isLoadingMore = false;
  
  // مسح التخزين المؤقت
  await _clearCache();
  
  // إعادة الحالة الأولية
  emit(HomeInitial());
  
  print('✅ HomeCubit: All data cleared successfully');
}

  // ✅ دالة لتحميل البيانات من التخزين
  Future<void> _loadFromCache() async {
    try {
      await _storageService.ensureInitialized();
      
      // قراءة البيانات المخزنة
      final cachedData = {
        _cachedFeedKey: await _storageService.readSecureData(_cachedFeedKey),
        'cached_events': await _storageService.readSecureData('cached_events'),
        _cachedNextCursorKey: await _storageService.readSecureData(_cachedNextCursorKey),
        _cachedHasMoreKey: await _storageService.readSecureData(_cachedHasMoreKey),
      };
      
      final feedJson = cachedData[_cachedFeedKey];
      final eventsJson = cachedData['cached_events'];
      
      if (feedJson != null) {
        try {
          final feedList = (jsonDecode(feedJson) as List).cast<Map<String, dynamic>>();
          _allFeedItems = feedList.map((item) => FeedItem.fromJson(item)).toList();
          
          if (eventsJson != null) {
            final eventsList = (jsonDecode(eventsJson) as List).cast<Map<String, dynamic>>();
            _onThisDayEvents = eventsList.map((event) => OnThisDayEvent.fromJson(event)).toList();
          }
          
          _nextCursor = cachedData[_cachedNextCursorKey];
          _hasMore = cachedData[_cachedHasMoreKey] == 'true';
          _isFirstLoad = false;
          
          print('📦 Loaded ${_allFeedItems.length} items from cache');
          
          emit(HomeLoaded(
            feedItems: _allFeedItems,
            onThisDayEvents: _onThisDayEvents,
            hasMore: _hasMore,
          ));
          
          // ✅ تحميل بيانات جديدة في الخلفية لتحديث التخزين
          _refreshCacheInBackground();
        } catch (e) {
          print('❌ Error parsing cached data: $e');
          // إذا فشل التحليل، احذف البيانات المخزنة
          await _clearCache();
        }
      }
    } catch (e) {
      print('❌ Error loading from cache: $e');
      emit(HomeError(
        error: 'Failed to load cached data',
        feedItems: _allFeedItems,
        onThisDayEvents: _onThisDayEvents,
        hasMore: _hasMore,
      ));
    }
  }

  // ✅ دالة لحفظ البيانات في التخزين
  Future<void> _saveToCache() async {
    try {
      await _storageService.ensureInitialized();
      
      final feedJson = jsonEncode(_allFeedItems.map((item) => item.toJson()).toList());
      final eventsJson = jsonEncode(_onThisDayEvents.map((event) => event.toJson()).toList());
      
      await _storageService.writeSecureData(_cachedFeedKey, feedJson);
      await _storageService.writeSecureData('cached_events', eventsJson);
      await _storageService.writeSecureData(_cachedNextCursorKey, _nextCursor ?? '');
      await _storageService.writeSecureData(_cachedHasMoreKey, _hasMore.toString());
      await _storageService.writeSecureData(_cachedTimestampKey, DateTime.now().toIso8601String());
      
      print('💾 Home feed cached successfully');
    } catch (e) {
      print('❌ Error saving to cache: $e');
    }
  }

  // ✅ دالة لتحديث التخزين في الخلفية
  Future<void> _refreshCacheInBackground() async {
    try {
      final response = await _homeRepository.getHomeFeed(cursor: null);
      
      _allFeedItems = response.data.feed;
      _onThisDayEvents = response.data.onThisDayEvents;
      _nextCursor = response.data.pagination.nextCursor;
      _hasMore = response.data.pagination.hasMore;
      
      await _saveToCache();
      print('🔄 Cache refreshed in background');
    } catch (e) {
      print('❌ Error refreshing cache in background: $e');
    }
  }

  // ✅ دالة لمسح التخزين
  Future<void> _clearCache() async {
    try {
      await _storageService.deleteSecureData(_cachedFeedKey);
      await _storageService.deleteSecureData('cached_events');
      await _storageService.deleteSecureData(_cachedNextCursorKey);
      await _storageService.deleteSecureData(_cachedHasMoreKey);
      await _storageService.deleteSecureData(_cachedTimestampKey);
      print('🗑️ Cache cleared');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  Future<void> refreshFeed() async {
    await getHomeFeed(forceRefresh: true);
  }
  
  Future<void> loadMore() async {
    if (_hasMore && !_isLoadingMore && _nextCursor != null) {
      await getHomeFeed(loadMore: true);
    }
  }
  
  Future<void> likeTelegram(String telegramId) async {
    try {
      // تحديث حالة الإعجاب محلياً أولاً
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final updatedItem = _allFeedItems[index].copyWith(
          metrics: FeedMetrics(
            likesCount: _allFeedItems[index].metrics.likesCount + 1,
            commentsCount: _allFeedItems[index].metrics.commentsCount,
            repostsCount: _allFeedItems[index].metrics.repostsCount,
          ),
          isLiked: true,
        );
        
        _allFeedItems[index] = updatedItem;
        
        // ✅ إرسال حالة جديدة فقط للبرقية المحددة
        emit(HomeLoaded(
          feedItems: List.from(_allFeedItems),
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
        
        // ✅ تحديث التخزين بعد التغيير
        await _saveToCache();
      }
      
      // إرسال الطلب إلى السيرفر
      await _homeRepository.likeTelegram(telegramId);
      
    } catch (e) {
      print('❌ Error liking telegram: $e');
      
      // ✅ التراجع عن التغيير المحلي فقط
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final revertedItem = _allFeedItems[index].copyWith(
          metrics: FeedMetrics(
            likesCount: _allFeedItems[index].metrics.likesCount - 1,
            commentsCount: _allFeedItems[index].metrics.commentsCount,
            repostsCount: _allFeedItems[index].metrics.repostsCount,
          ),
          isLiked: false,
        );
        
        _allFeedItems[index] = revertedItem;
        
        emit(HomeLoaded(
          feedItems: List.from(_allFeedItems),
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
      }
    }
  }
  
  Future<void> unlikeTelegram(String telegramId) async {
    try {
      // تحديث حالة الإعجاب محلياً أولاً
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final updatedItem = _allFeedItems[index].copyWith(
          metrics: FeedMetrics(
            likesCount: _allFeedItems[index].metrics.likesCount - 1,
            commentsCount: _allFeedItems[index].metrics.commentsCount,
            repostsCount: _allFeedItems[index].metrics.repostsCount,
          ),
          isLiked: false,
        );
        
        _allFeedItems[index] = updatedItem;
        
        emit(HomeLoaded(
          feedItems: List.from(_allFeedItems),
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
        
        // ✅ تحديث التخزين بعد التغيير
        await _saveToCache();
      }
      
      // إرسال الطلب إلى السيرفر
      await _homeRepository.unlikeTelegram(telegramId);
      
    } catch (e) {
      print('❌ Error unliking telegram: $e');
      
      // ✅ التراجع عن التغيير المحلي فقط
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final revertedItem = _allFeedItems[index].copyWith(
          metrics: FeedMetrics(
            likesCount: _allFeedItems[index].metrics.likesCount + 1,
            commentsCount: _allFeedItems[index].metrics.commentsCount,
            repostsCount: _allFeedItems[index].metrics.repostsCount,
          ),
          isLiked: true,
        );
        
        _allFeedItems[index] = revertedItem;
        
        emit(HomeLoaded(
          feedItems: List.from(_allFeedItems),
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
      }
    }
  }
  
  Future<void> repostTelegram(String telegramId) async {
    try {
      // تحديث حالة إعادة النشر محلياً أولاً
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final updatedItem = _allFeedItems[index].copyWith(
          metrics: FeedMetrics(
            likesCount: _allFeedItems[index].metrics.likesCount,
            commentsCount: _allFeedItems[index].metrics.commentsCount,
            repostsCount: _allFeedItems[index].metrics.repostsCount + 1,
          ),
          isReposted: true,
        );
        
        _allFeedItems[index] = updatedItem;
        
        emit(HomeLoaded(
          feedItems: List.from(_allFeedItems),
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
        
        // ✅ تحديث التخزين بعد التغيير
        await _saveToCache();
      }
      
      // إرسال الطلب إلى السيرفر
      await _homeRepository.repostTelegram(telegramId);
      
    } catch (e) {
      print('❌ Error reposting telegram: $e');
      
      // ✅ التراجع عن التغيير المحلي فقط
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final revertedItem = _allFeedItems[index].copyWith(
          metrics: FeedMetrics(
            likesCount: _allFeedItems[index].metrics.likesCount,
            commentsCount: _allFeedItems[index].metrics.commentsCount,
            repostsCount: _allFeedItems[index].metrics.repostsCount - 1,
          ),
          isReposted: false,
        );
        
        _allFeedItems[index] = revertedItem;
        
        emit(HomeLoaded(
          feedItems: List.from(_allFeedItems),
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
        ));
      }
    }
  }

  // ✅ جتتر للتحقق إذا كان هذا أول تحميل
  bool get isFirstLoad => _isFirstLoad;
  
  // ✅ جتتر للتحقق إذا كان هناك المزيد للتحميل
  bool get hasMore => _hasMore;
  
  // ✅ جتتر للحصول على عدد العناصر الحالي
  int get feedItemsCount => _allFeedItems.length;
  
  // ✅ جتتر للتحقق من حالة التحميل الإضافي
  bool get isLoadingMore => _isLoadingMore;
  
  // ✅ جتتر للحصول على البيانات الحالية
  List<FeedItem> get feedItems => _allFeedItems;
  
  // ✅ جتتر للحصول على أحداث اليوم
  List<OnThisDayEvent> get onThisDayEvents => _onThisDayEvents;
  
  // ✅ دالة لمسح البيانات
  void clearData() {
    _allFeedItems.clear();
    _onThisDayEvents.clear();
    _nextCursor = null;
    _hasMore = true;
    _isFirstLoad = true;
    _isLoadingMore = false;
    _clearCache();
    emit(HomeInitial());
  }
  
  // ✅ دالة لفحص حالة الـ Pagination
  void debugPagination() {
    print('🔍 === PAGINATION DEBUG ===');
    print('🔍 nextCursor: $_nextCursor');
    print('🔍 hasMore: $_hasMore');
    print('🔍 isLoadingMore: $_isLoadingMore');
    print('🔍 isFirstLoad: $_isFirstLoad');
    print('🔍 totalItems: ${_allFeedItems.length}');
    print('🔍 =========================');
  }
  
  // ✅ دالة للتحقق مما إذا كان هناك cursor
  bool get hasNextCursor => _nextCursor != null && _nextCursor!.isNotEmpty;
}