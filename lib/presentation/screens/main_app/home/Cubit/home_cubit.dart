import 'dart:convert';
import 'package:app_1/presentation/screens/main_app/home/Models/categories_constants.dart';
import 'package:app_1/presentation/screens/main_app/home/Models/home_feed_model.dart';
import 'package:app_1/presentation/screens/main_app/home/Repository/home_repository.dart';
import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  final StorageService _storageService;
  bool _isInitialized = false;
  bool _isInitializing = false;
  
  // ⭐ Pagination Variables
  String? _nextCursor;
  bool _hasMore = true;
  bool _isFirstLoad = true;
  bool _isLoadingMore = false;
  
  // ⭐ Data Variables
  List<FeedItem> _allFeedItems = [];
  List<OnThisDayEvent> _onThisDayEvents = [];
  
  // ⭐ Filter Variables
  String? _currentCategoryId;
  String _currentFeedType = 'home';
  List<Category> _categories = [];
  
  // ⭐ Overlay Refresh Variable
  bool _isRefreshingWithOverlay = false;
  
  // ⭐ آخر بيانات متاحة (للعرض أثناء التحميل)
  List<FeedItem> _lastValidFeedItems = [];
  List<OnThisDayEvent> _lastValidEvents = [];
  
  // ⭐ Cache Keys
  static const String _cachedFeedKey = 'cached_home_feed';
  static const String _cachedEventsKey = 'cached_events';
  static const String _cachedNextCursorKey = 'cached_next_cursor';
  static const String _cachedHasMoreKey = 'cached_has_more';
  static const String _cachedTimestampKey = 'cached_timestamp';
  static const String _cachedFeedTypeKey = 'cached_feed_type';
  static const String _cachedCategoryIdKey = 'cached_category_id';
  static const Duration _cacheDuration = Duration(minutes: 10);

  HomeCubit({
    required HomeRepository homeRepository,
    required StorageService storageService,
  }) : _homeRepository = homeRepository,
        _storageService = storageService,
        super(HomeInitial(categories: []));

  // ✅ دالة التهيئة المعدلة بدون شاشة بيضاء
  Future<void> initialize({bool force = false, bool isArabic = false}) async {
    if (_isInitialized && !force) {
      print('✅ HomeCubit: Already initialized, skipping...');
      return;
    }
    
    if (_isInitializing) {
      print('⚠️ HomeCubit: Initialization already in progress');
      return;
    }
    
    _isInitializing = true;
    
    try {
      print('🔄 HomeCubit: Starting initialization...');
      
      // 1. تحميل التصنيفات من الثوابت
      _loadCategoriesFromConstants(isArabic);
      
      // 2. إصدار حالة التحميل مع البيانات المخزنة
      final cachedData = await _loadFromCache();
      
      if (cachedData != null) {
        print('📦 HomeCubit: Loaded cached data');
        _allFeedItems = cachedData['feedItems'] ?? [];
        _onThisDayEvents = cachedData['events'] ?? [];
        _nextCursor = cachedData['nextCursor'];
        _hasMore = cachedData['hasMore'] ?? true;
        _currentFeedType = cachedData['feedType'] ?? 'home';
        _currentCategoryId = cachedData['categoryId'];
        
        // حفظ كآخر بيانات صالحة
        _lastValidFeedItems = List.from(_allFeedItems);
        _lastValidEvents = List.from(_onThisDayEvents);
        
        // إصدار حالة الـ Overlay Loading مع البيانات المخزنة
        emit(HomeRefreshingWithOverlay(
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
      } else {
        // إذا مفيش بيانات مخزنة، نعرض حالة Loading بدون بيانات
        emit(HomeLoading(
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
      }
      
      // 3. جلب البيانات الجديدة مباشرة مع الحفاظ على البيانات القديمة
      try {
        HomeFeedResponse response;
        
        if (_currentFeedType == 'category' && _currentCategoryId != null) {
          response = await _homeRepository.getCategoryFeed(
            categoryId: _currentCategoryId!,
            cursor: null,
          );
        } else {
          response = await _homeRepository.getHomeFeed(cursor: null);
        }
        
        // تحديث البيانات
        _allFeedItems = response.data.feed;
        _onThisDayEvents = response.data.onThisDayEvents;
        _nextCursor = response.data.pagination.nextCursor;
        _hasMore = response.data.pagination.hasMore;
        _isFirstLoad = false;
        
        // حفظ كآخر بيانات صالحة
        _lastValidFeedItems = List.from(_allFeedItems);
        _lastValidEvents = List.from(_onThisDayEvents);
        
        // حفظ في التخزين المؤقت
        await _saveToCache();
        
        // إصدار الحالة الجديدة
        emit(HomeLoaded(
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
        
        print('✅ HomeCubit: Initialization completed successfully');
        
      } catch (e) {
        print('❌ HomeCubit: Error loading fresh data: $e');
        
        // إذا فشل تحميل البيانات الجديدة، نظهر البيانات القديمة إذا كانت موجودة
        if (_lastValidFeedItems.isNotEmpty) {
          emit(HomeLoaded(
            feedItems: _lastValidFeedItems,
            onThisDayEvents: _lastValidEvents,
            hasMore: _hasMore,
            categories: _categories,
            currentCategoryId: _currentCategoryId,
            feedType: _currentFeedType,
          ));
        } else {
          // إذا مفيش بيانات خالص، نظهر Empty State
          emit(HomeError(
            error: 'فشل تحميل البيانات',
            feedItems: [],
            onThisDayEvents: [],
            hasMore: false,
            categories: _categories,
            currentCategoryId: _currentCategoryId,
            feedType: _currentFeedType,
          ));
        }
      }

      _isInitialized = true;
      
    } catch (e) {
      print('❌ HomeCubit: Initialization error: $e');
      
      _isInitialized = true;
      
      if (_lastValidFeedItems.isNotEmpty) {
        emit(HomeLoaded(
          feedItems: _lastValidFeedItems,
          onThisDayEvents: _lastValidEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
      }
    } finally {
      _isInitializing = false;
    }
  }

  // ✅ دالة تحميل التصنيفات من الثوابت
  void _loadCategoriesFromConstants(bool isArabic) {
    try {
      final categoriesData = CategoriesConstants.getCategories(isArabic);
      
      _categories = categoriesData.map((item) => Category(
        id: item['id'].toString(),
        name: item['name'].toString(),
        color: item['color'].toString(),
        icon: item['icon'],
        telegramsCount: item['telegrams_count'] ?? 0,
      )).toList();
      
      print('✅ HomeCubit: Loaded ${_categories.length} categories from constants');
    } catch (e) {
      print('❌ HomeCubit: Error loading categories from constants: $e');
      _categories = [];
    }
  }

  // ✅ تحديث التصنيفات عند تغيير اللغة
  void updateCategoriesLanguage(bool isArabic) {
    print('🔄 HomeCubit: Updating categories language to ${isArabic ? 'Arabic' : 'English'}');
    
    // حفظ التصنيف الحالي
    final currentCategoryId = _currentCategoryId;
    
    // تحميل التصنيفات باللغة الجديدة
    _loadCategoriesFromConstants(isArabic);
    
    // تحديث حالة الـ UI مع الحفاظ على البيانات الحالية
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(HomeLoaded(
        feedItems: currentState.feedItems,
        onThisDayEvents: currentState.onThisDayEvents,
        hasMore: currentState.hasMore,
        categories: _categories,
        currentCategoryId: currentCategoryId,
        feedType: _currentFeedType,
      ));
    } else if (state is HomeLoading) {
      emit(HomeLoading(
        categories: _categories,
        currentCategoryId: currentCategoryId,
        feedType: _currentFeedType,
      ));
    } else if (state is HomeInitial) {
      emit(HomeInitial(categories: _categories));
    } else if (state is HomeRefreshingWithOverlay) {
      final currentState = state as HomeRefreshingWithOverlay;
      emit(HomeRefreshingWithOverlay(
        feedItems: currentState.feedItems,
        onThisDayEvents: currentState.onThisDayEvents,
        hasMore: currentState.hasMore,
        categories: _categories,
        currentCategoryId: currentCategoryId,
        feedType: _currentFeedType,
      ));
    }
  }

  // ✅ تحديث البيانات في الخلفية
  Future<void> _refreshDataInBackground() async {
    try {
      print('🔄 HomeCubit: Refreshing data in background...');
      
      HomeFeedResponse response;
      
      if (_currentFeedType == 'category' && _currentCategoryId != null) {
        response = await _homeRepository.getCategoryFeed(
          categoryId: _currentCategoryId!,
          cursor: null,
        );
      } else {
        response = await _homeRepository.getHomeFeed(cursor: null);
      }
      
      // تحديث البيانات فقط إذا اختلفت
      if (response.data.feed.isNotEmpty) {
        _allFeedItems = response.data.feed;
        _onThisDayEvents = response.data.onThisDayEvents;
        _nextCursor = response.data.pagination.nextCursor;
        _hasMore = response.data.pagination.hasMore;
        
        // حفظ كآخر بيانات صالحة
        _lastValidFeedItems = List.from(_allFeedItems);
        _lastValidEvents = List.from(_onThisDayEvents);
        
        // حفظ في التخزين المؤقت
        await _saveToCache();
        
        print('✅ HomeCubit: Background refresh completed');
      }
    } catch (e) {
      print('⚠️ HomeCubit: Background refresh failed: $e');
    }
  }
  
  void resetInitialization() {
    print('🔄 HomeCubit: Resetting initialization state');
    _isInitialized = false;
    _isInitializing = false;
  }
  
  bool get isInitialized => _isInitialized;
  bool get isRefreshingWithOverlay => _isRefreshingWithOverlay;

  Future<void> getFeed({
    bool loadMore = false,
    bool forceRefresh = false
  }) async {
    try {
      // 1️⃣ التحقق من حالة التحميل
      if (_isLoadingMore && loadMore) return;
      
      if (loadMore) {
        if (!_hasMore || _nextCursor == null || _isLoadingMore) {
          print('⚠️ لا توجد بيانات أكثر للتحميل');
          return;
        }
        _isLoadingMore = true;
        emit(HomeLoadingMore(
          feedItems: _allFeedItems,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
      } else {
        if (!forceRefresh && !_isFirstLoad && _allFeedItems.isNotEmpty) {
          print('📊 البيانات موجودة بالفعل، لا حاجة لإعادة التحميل');
          return;
        }
        
        print('🔄 تحميل البيانات ${forceRefresh ? '(إعادة تحميل)' : ''}');
        _isFirstLoad = false;
        
        if (!loadMore) {
          // إصدار حالة الـ Overlay Loading مع البيانات القديمة إذا كانت موجودة
          if (_lastValidFeedItems.isNotEmpty) {
            emit(HomeRefreshingWithOverlay(
              feedItems: _lastValidFeedItems,
              onThisDayEvents: _lastValidEvents,
              hasMore: _hasMore,
              categories: _categories,
              currentCategoryId: _currentCategoryId,
              feedType: _currentFeedType,
            ));
          } else {
            emit(HomeLoading(
              categories: _categories,
              currentCategoryId: _currentCategoryId,
              feedType: _currentFeedType,
            ));
          }
        }
      }

      // 2️⃣ جلب البيانات من السيرفر
      HomeFeedResponse response;
      
      if (_currentFeedType == 'category' && _currentCategoryId != null) {
        response = await _homeRepository.getCategoryFeed(
          categoryId: _currentCategoryId!,
          cursor: loadMore ? _nextCursor : null,
        );
      } else {
        response = await _homeRepository.getHomeFeed(
          cursor: loadMore ? _nextCursor : null,
        );
      }
      
      // 3️⃣ تحديث البيانات
      _nextCursor = response.data.pagination.nextCursor;
      _hasMore = response.data.pagination.hasMore;
      
      if (loadMore) {
        _allFeedItems.addAll(response.data.feed);
      } else {
        _allFeedItems = response.data.feed;
      }
      
      _onThisDayEvents = response.data.onThisDayEvents;
      _isLoadingMore = false;
      
      // حفظ كآخر بيانات صالحة
      _lastValidFeedItems = List.from(_allFeedItems);
      _lastValidEvents = List.from(_onThisDayEvents);
      
      // 4️⃣ حفظ في التخزين المؤقت إذا كان أول تحميل
      if (!loadMore) {
        await _saveToCache();
      }
      
      // 5️⃣ إصدار الحالة الجديدة
      emit(HomeLoaded(
        feedItems: _allFeedItems,
        onThisDayEvents: _onThisDayEvents,
        hasMore: _hasMore,
        categories: _categories,
        currentCategoryId: _currentCategoryId,
        feedType: _currentFeedType,
      ));
      
      print('✅ تم تحميل ${_allFeedItems.length} برقية');
      print('📊 hasMore: $_hasMore, nextCursor: $_nextCursor');
      
    } catch (e) {
      _isLoadingMore = false;
      print('❌ خطأ في تحميل البيانات: $e');
      
      // في حالة الخطأ، نعرض البيانات القديمة إذا كانت موجودة
      if (_lastValidFeedItems.isNotEmpty) {
        emit(HomeLoaded(
          feedItems: _lastValidFeedItems,
          onThisDayEvents: _lastValidEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
      } else {
        emit(HomeError(
          error: 'فشل تحميل البيانات: ${e.toString()}',
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
      }
    }
  }

  Future<void> loadMore() async {
    if (_hasMore && !_isLoadingMore && _nextCursor != null) {
      print('🔄 تحميل المزيد - cursor: $_nextCursor');
      await getFeed(loadMore: true);
    }
  }

  // ✅ تعديل دالة switchCategory عشان تعمل overlay
  Future<void> switchCategory(String? categoryId) async {
    print('🔄 تغيير التصنيف إلى: $categoryId');
    
    if (categoryId == _currentCategoryId) return;
    
    final previousCategoryId = _currentCategoryId;
    final previousFeedType = _currentFeedType;
    
    if (categoryId == null) {
      _currentCategoryId = null;
      _currentFeedType = 'home';
    } else {
      _currentCategoryId = categoryId;
      _currentFeedType = 'category';
    }
    
    // إصدار حالة الـ Overlay Loading مع البيانات الحالية
    if (_lastValidFeedItems.isNotEmpty) {
      emit(HomeRefreshingWithOverlay(
        feedItems: _lastValidFeedItems,
        onThisDayEvents: _lastValidEvents,
        hasMore: _hasMore,
        categories: _categories,
        currentCategoryId: previousCategoryId,
        feedType: previousFeedType,
      ));
    } else {
      emit(HomeLoading(
        categories: _categories,
        currentCategoryId: previousCategoryId,
        feedType: previousFeedType,
      ));
    }
    
    _allFeedItems.clear();
    _onThisDayEvents.clear();
    _nextCursor = null;
    _hasMore = true;
    
    try {
      await getFeed(forceRefresh: true);
    } catch (e) {
      _currentCategoryId = previousCategoryId;
      _currentFeedType = previousFeedType;
      
      // استعادة البيانات القديمة في حالة الخطأ
      if (_lastValidFeedItems.isNotEmpty) {
        emit(HomeLoaded(
          feedItems: _lastValidFeedItems,
          onThisDayEvents: _lastValidEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: previousCategoryId,
          feedType: previousFeedType,
        ));
      }
      rethrow;
    }
  }

  // ✅ دالة refresh الجديدة مع Overlay
  Future<void> refresh() async {
    print('🔄 إعادة تحميل البيانات مع الحفاظ على البيانات القديمة');
    
    if (_isRefreshingWithOverlay) return;
    
    try {
      _isRefreshingWithOverlay = true;
      
      // ✅ إصدار حالة الـ Overlay Loading مع البيانات الحالية
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(HomeRefreshingWithOverlay(
          feedItems: currentState.feedItems,
          onThisDayEvents: currentState.onThisDayEvents,
          hasMore: currentState.hasMore,
          categories: currentState.categories,
          currentCategoryId: currentState.currentCategoryId,
          feedType: currentState.feedType,
        ));
      } else if (state is HomeRefreshingWithOverlay) {
        // إذا كان بالفعل في حالة overlay، نظهر البيانات القديمة
        final currentState = state as HomeRefreshingWithOverlay;
        emit(HomeRefreshingWithOverlay(
          feedItems: currentState.feedItems,
          onThisDayEvents: currentState.onThisDayEvents,
          hasMore: currentState.hasMore,
          categories: currentState.categories,
          currentCategoryId: currentState.currentCategoryId,
          feedType: currentState.feedType,
        ));
      }
      
      // ✅ حفظ البيانات القديمة مؤقتاً
      final oldFeedItems = List<FeedItem>.from(_allFeedItems);
      final oldEvents = List<OnThisDayEvent>.from(_onThisDayEvents);
      final oldCursor = _nextCursor;
      final oldHasMore = _hasMore;
      
      try {
        // جلب البيانات الجديدة
        HomeFeedResponse response;
        
        if (_currentFeedType == 'category' && _currentCategoryId != null) {
          response = await _homeRepository.getCategoryFeed(
            categoryId: _currentCategoryId!,
            cursor: null,
          );
        } else {
          response = await _homeRepository.getHomeFeed(cursor: null);
        }
        
        // تحديث البيانات
        _allFeedItems = response.data.feed;
        _onThisDayEvents = response.data.onThisDayEvents;
        _nextCursor = response.data.pagination.nextCursor;
        _hasMore = response.data.pagination.hasMore;
        _isFirstLoad = false;
        
        // حفظ كآخر بيانات صالحة
        _lastValidFeedItems = List.from(_allFeedItems);
        _lastValidEvents = List.from(_onThisDayEvents);
        
        // حفظ في التخزين المؤقت
        await _saveToCache();
        
        // إصدار الحالة الجديدة
        emit(HomeLoaded(
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
        
        print('✅ تم تحديث البيانات بنجاح');
        
      } catch (e) {
        print('❌ خطأ في تحديث البيانات: $e');
        
        // ✅ استعادة البيانات القديمة في حالة الخطأ
        _allFeedItems = oldFeedItems;
        _onThisDayEvents = oldEvents;
        _nextCursor = oldCursor;
        _hasMore = oldHasMore;
        
        // حفظ كآخر بيانات صالحة
        _lastValidFeedItems = List.from(_allFeedItems);
        _lastValidEvents = List.from(_onThisDayEvents);
        
        emit(HomeLoaded(
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
        
        throw e;
      }
    } finally {
      _isRefreshingWithOverlay = false;
    }
  }

  // ✅ أضف دالة clearCacheAndRefresh للاستخدام عندما لا يوجد بيانات في الكاش
  Future<void> clearCacheAndRefresh() async {
    print('🧹 مسح الكاش وتحويل للتحميل العادي');
    
    _allFeedItems.clear();
    _onThisDayEvents.clear();
    _lastValidFeedItems.clear();
    _lastValidEvents.clear();
    _nextCursor = null;
    _hasMore = true;
    _isFirstLoad = true;
    
    await _clearCache();
    
    emit(HomeLoading(
      categories: _categories,
      currentCategoryId: _currentCategoryId,
      feedType: _currentFeedType,
    ));
    
    await getFeed(forceRefresh: true);
  }

  Future<Map<String, dynamic>?> _loadFromCache() async {
    try {
      final cachedTimestamp = await _storageService.readSecureData(_cachedTimestampKey);
      if (cachedTimestamp == null) return null;
      
      final cachedTime = DateTime.parse(cachedTimestamp);
      final now = DateTime.now();
      
      if (now.difference(cachedTime) > _cacheDuration) {
        print('🗑️ البيانات المخزنة منتهية الصلاحية');
        return null;
      }
      
      final cachedFeedType = await _storageService.readSecureData(_cachedFeedTypeKey);
      final cachedCategoryId = await _storageService.readSecureData(_cachedCategoryIdKey);
      
      final String currentFeedTypeValue = _currentFeedType ?? 'home';
      final String currentCategoryIdValue = _currentCategoryId ?? '';
      final String cachedFeedTypeValue = cachedFeedType ?? 'home';
      final String cachedCategoryIdValue = cachedCategoryId ?? '';
      
      if (currentFeedTypeValue != cachedFeedTypeValue || 
          currentCategoryIdValue != cachedCategoryIdValue) {
        print('🗑️ البيانات المخزنة لا تطابق التصفية الحالية');
        print('   - Current: feedType=$currentFeedTypeValue, categoryId=$currentCategoryIdValue');
        print('   - Cached: feedType=$cachedFeedTypeValue, categoryId=$cachedCategoryIdValue');
        return null;
      }
      
      final feedJson = await _storageService.readSecureData(_cachedFeedKey);
      final eventsJson = await _storageService.readSecureData(_cachedEventsKey);
      final nextCursor = await _storageService.readSecureData(_cachedNextCursorKey);
      final hasMoreStr = await _storageService.readSecureData(_cachedHasMoreKey);
      
      if (feedJson == null) return null;
      
      final feedList = (jsonDecode(feedJson) as List).cast<Map<String, dynamic>>();
      final feedItems = feedList.map((item) => FeedItem.fromJson(item)).toList();
      
      List<OnThisDayEvent> events = [];
      if (eventsJson != null) {
        final eventsList = (jsonDecode(eventsJson) as List).cast<Map<String, dynamic>>();
        events = eventsList.map((item) => OnThisDayEvent.fromJson(item)).toList();
      }
      
      final hasMore = hasMoreStr == 'true';
      
      print('📦 تم تحميل ${feedItems.length} برقية من التخزين المؤقت');
      return {
        'feedItems': feedItems,
        'events': events,
        'nextCursor': nextCursor,
        'hasMore': hasMore,
        'feedType': cachedFeedTypeValue,
        'categoryId': cachedCategoryIdValue,
      };
    } catch (e) {
      print('❌ خطأ في تحميل البيانات المخزنة: $e');
      return null;
    }
  }

  Future<void> _saveToCache() async {
    try {
      final feedJson = jsonEncode(_allFeedItems.map((item) => item.toJson()).toList());
      final eventsJson = jsonEncode(_onThisDayEvents.map((event) => event.toJson()).toList());
      
      await _storageService.writeSecureData(_cachedFeedKey, feedJson);
      await _storageService.writeSecureData(_cachedEventsKey, eventsJson);
      await _storageService.writeSecureData(_cachedNextCursorKey, _nextCursor ?? '');
      await _storageService.writeSecureData(_cachedHasMoreKey, _hasMore.toString());
      await _storageService.writeSecureData(_cachedFeedTypeKey, _currentFeedType);
      await _storageService.writeSecureData(_cachedCategoryIdKey, _currentCategoryId ?? '');
      await _storageService.writeSecureData(_cachedTimestampKey, DateTime.now().toIso8601String());
      
      print('💾 تم حفظ ${_allFeedItems.length} برقية في التخزين المؤقت');
    } catch (e) {
      print('❌ خطأ في حفظ البيانات للتخزين: $e');
    }
  }

  Future<void> likeTelegram(String telegramId) async {
    try {
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final item = _allFeedItems[index];
        final updatedItem = item.copyWith(
          isLiked: true,
          metrics: FeedMetrics(
            likesCount: item.metrics.likesCount + 1,
            commentsCount: item.metrics.commentsCount,
            repostsCount: item.metrics.repostsCount,
          ),
        );
        
        _allFeedItems[index] = updatedItem;
        
        // تحديث آخر بيانات صالحة
        _lastValidFeedItems = List.from(_allFeedItems);
        
        emit(HomeLoaded(
          feedItems: List.from(_allFeedItems),
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
        
        await _homeRepository.likeTelegram(telegramId);
        print('✅ تم الإعجاب بالبرقية $telegramId');
      }
    } catch (e) {
      print('❌ خطأ في الإعجاب: $e');
      
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final item = _allFeedItems[index];
        final updatedItem = item.copyWith(
          isLiked: false,
          metrics: FeedMetrics(
            likesCount: item.metrics.likesCount - 1,
            commentsCount: item.metrics.commentsCount,
            repostsCount: item.metrics.repostsCount,
          ),
        );
        
        _allFeedItems[index] = updatedItem;
        
        // تحديث آخر بيانات صالحة
        _lastValidFeedItems = List.from(_allFeedItems);
        
        emit(HomeLoaded(
          feedItems: List.from(_allFeedItems),
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
      }
    }
  }

  Future<void> unlikeTelegram(String telegramId) async {
    try {
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final item = _allFeedItems[index];
        final updatedItem = item.copyWith(
          isLiked: false,
          metrics: FeedMetrics(
            likesCount: item.metrics.likesCount - 1,
            commentsCount: item.metrics.commentsCount,
            repostsCount: item.metrics.repostsCount,
          ),
        );
        
        _allFeedItems[index] = updatedItem;
        
        // تحديث آخر بيانات صالحة
        _lastValidFeedItems = List.from(_allFeedItems);
        
        emit(HomeLoaded(
          feedItems: List.from(_allFeedItems),
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
        
        await _homeRepository.unlikeTelegram(telegramId);
        print('✅ تم إلغاء الإعجاب بالبرقية $telegramId');
      }
    } catch (e) {
      print('❌ خطأ في إلغاء الإعجاب: $e');
      
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final item = _allFeedItems[index];
        final updatedItem = item.copyWith(
          isLiked: true,
          metrics: FeedMetrics(
            likesCount: item.metrics.likesCount + 1,
            commentsCount: item.metrics.commentsCount,
            repostsCount: item.metrics.repostsCount,
          ),
        );
        
        _allFeedItems[index] = updatedItem;
        
        // تحديث آخر بيانات صالحة
        _lastValidFeedItems = List.from(_allFeedItems);
        
        emit(HomeLoaded(
          feedItems: List.from(_allFeedItems),
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
      }
    }
  }

  Future<void> repostTelegram(String telegramId) async {
    try {
      final index = _allFeedItems.indexWhere((item) => item.id == telegramId);
      if (index != -1) {
        final item = _allFeedItems[index];
        final updatedItem = item.copyWith(
          isReposted: true,
          metrics: FeedMetrics(
            likesCount: item.metrics.likesCount,
            commentsCount: item.metrics.commentsCount,
            repostsCount: item.metrics.repostsCount + 1,
          ),
        );
        
        _allFeedItems[index] = updatedItem;
        
        // تحديث آخر بيانات صالحة
        _lastValidFeedItems = List.from(_allFeedItems);
        
        emit(HomeLoaded(
          feedItems: List.from(_allFeedItems),
          onThisDayEvents: _onThisDayEvents,
          hasMore: _hasMore,
          categories: _categories,
          currentCategoryId: _currentCategoryId,
          feedType: _currentFeedType,
        ));
        
        await _homeRepository.repostTelegram(telegramId);
        print('✅ تم إعادة نشر البرقية $telegramId');
      }
    } catch (e) {
      print('❌ خطأ في إعادة النشر: $e');
    }
  }

  Future<void> clearCacheAndData() async {
    print('🧹 HomeCubit: مسح كل البيانات والتخزين...');
    
    try {
      _allFeedItems.clear();
      _onThisDayEvents.clear();
      _lastValidFeedItems.clear();
      _lastValidEvents.clear();
      _categories.clear();
      _nextCursor = null;
      _hasMore = true;
      _isFirstLoad = true;
      _isLoadingMore = false;
      _currentCategoryId = null;
      _currentFeedType = 'home';
      
      await _clearCache();
      
      emit(HomeInitial(categories: []));
      
      print('✅ HomeCubit: تم مسح كل البيانات بنجاح');
    } catch (e) {
      print('❌ خطأ في مسح البيانات: $e');
    }
  }

  Future<void> _clearCache() async {
    try {
      await _storageService.deleteSecureData(_cachedFeedKey);
      await _storageService.deleteSecureData(_cachedEventsKey);
      await _storageService.deleteSecureData(_cachedNextCursorKey);
      await _storageService.deleteSecureData(_cachedHasMoreKey);
      await _storageService.deleteSecureData(_cachedTimestampKey);
      await _storageService.deleteSecureData(_cachedFeedTypeKey);
      await _storageService.deleteSecureData(_cachedCategoryIdKey);
      
      print('🗑️ تم مسح التخزين المؤقت للـ HomeCubit');
    } catch (e) {
      print('❌ خطأ في مسح التخزين المؤقت: $e');
    }
  }
  
  Future<void> resetCubit() async {
    print('🔄 HomeCubit: Resetting cubit completely...');
    
    try {
      _allFeedItems.clear();
      _onThisDayEvents.clear();
      _lastValidFeedItems.clear();
      _lastValidEvents.clear();
      _categories.clear();
      _nextCursor = null;
      _hasMore = true;
      _isFirstLoad = true;
      _isLoadingMore = false;
      _currentCategoryId = null;
      _currentFeedType = 'home';
      
      _isInitialized = false;
      _isInitializing = false;
      
      await _clearCache();
      
      emit(HomeInitial(categories: []));
      
      print('✅ HomeCubit: Reset completed successfully');
    } catch (e) {
      print('❌ HomeCubit: Error during reset: $e');
      emit(HomeError(
        error: 'فشل إعادة التعيين',
        feedItems: [],
        onThisDayEvents: [],
        hasMore: false,
        categories: [],
      ));
    }
  }

  Future<void> forceClear() async {
    print('🧹 HomeCubit: Force clearing all data...');
    
    _allFeedItems.clear();
    _onThisDayEvents.clear();
    _lastValidFeedItems.clear();
    _lastValidEvents.clear();
    _categories.clear();
    _nextCursor = null;
    _hasMore = true;
    _isFirstLoad = true;
    _isLoadingMore = false;
    _currentCategoryId = null;
    _currentFeedType = 'home';
    _isInitialized = false;
    _isInitializing = false;
  }
  
  Future<void> clearDataOnNewLogin() async {
    print('🔄 HomeCubit: Clearing data for new login...');
    
    try {
      _allFeedItems.clear();
      _onThisDayEvents.clear();
      _lastValidFeedItems.clear();
      _lastValidEvents.clear();
      _nextCursor = null;
      _hasMore = true;
      _isFirstLoad = true;
      _isLoadingMore = false;
      _currentCategoryId = null;
      _currentFeedType = 'home';
      
      await _clearCache();
      
      _isInitialized = false;
      _isInitializing = false;
      
      emit(HomeInitial(categories: _categories));
      
      print('✅ HomeCubit: Data cleared for new login');
    } catch (e) {
      print('❌ HomeCubit: Error clearing data for new login: $e');
    }
  }
  
  Future<void> forceRefreshOnLogin() async {
    print('🔄 HomeCubit: Force refresh on login...');
    
    try {
      await clearDataOnNewLogin();
      
      await getFeed(forceRefresh: true);
      
      print('✅ HomeCubit: Force refresh completed');
    } catch (e) {
      print('❌ HomeCubit: Error in force refresh: $e');
    }
  }

  // ✅ Getters
  String? get currentCategoryId => _currentCategoryId;
  String get currentFeedType => _currentFeedType;
  bool get isFirstLoad => _isFirstLoad;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  List<FeedItem> get feedItems => _allFeedItems;
  List<OnThisDayEvent> get onThisDayEvents => _onThisDayEvents;
  List<Category> get categories => _categories;
  bool get hasNextCursor => _nextCursor != null && _nextCursor!.isNotEmpty;
  
  // ✅ Getter للبيانات القديمة
  List<FeedItem> get lastValidFeedItems => _lastValidFeedItems;
  List<OnThisDayEvent> get lastValidEvents => _lastValidEvents;
}