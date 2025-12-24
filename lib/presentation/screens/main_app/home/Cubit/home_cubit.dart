import 'dart:convert';
import 'package:app_1/presentation/screens/main_app/home/Models/home_feed_model.dart';
import 'package:app_1/presentation/screens/main_app/home/Repository/home_repository.dart';
import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  final StorageService _storageService;
    bool _isInitialized = false; // ✅ إضافة متغير لتتبع التهيئة
  bool _isInitializing = false; // ✅ لمنع التهيئة المزدوجة
  
  // ⭐ Pagination Variables
  String? _nextCursor;
  bool _hasMore = true;
  bool _isFirstLoad = true;
  bool _isLoadingMore = false;
  
  // ⭐ Data Variables
  List<FeedItem> _allFeedItems = [];
  List<OnThisDayEvent> _onThisDayEvents = [];
  
  // ⭐ Filter Variables
  String? _currentCategoryId;  // null = كل التصنيفات
  String _currentFeedType = 'home'; // 'home' أو 'category'
  List<Category> _categories = [];
  
  // ⭐ Cache Keys
  static const String _cachedFeedKey = 'cached_home_feed';
  static const String _cachedEventsKey = 'cached_events';
  static const String _cachedNextCursorKey = 'cached_next_cursor';
  static const String _cachedHasMoreKey = 'cached_has_more';
  static const String _cachedTimestampKey = 'cached_timestamp';
  static const String _cachedFeedTypeKey = 'cached_feed_type';
  static const String _cachedCategoryIdKey = 'cached_category_id';
  static const String _cachedCategoriesKey = 'cached_categories';
  static const Duration _cacheDuration = Duration(minutes: 10);

  HomeCubit({
    required HomeRepository homeRepository,
    required StorageService storageService,
  }) : _homeRepository = homeRepository,
        _storageService = storageService,
        super(HomeInitial(categories: []));

  // ✅ دالة التهيئة
  Future<void> initialize({bool force = false}) async {
    // إذا تم التهيئة بالفعل ولا نريد إجبار إعادة التهيئة
    if (_isInitialized && !force) {
      print('✅ HomeCubit: Already initialized, skipping...');
      return;
    }
    
    // إذا كان هناك عملية تهيئة جارية
    if (_isInitializing) {
      print('⚠️ HomeCubit: Initialization already in progress');
      return;
    }
    
    _isInitializing = true;
    
    try {
      print('🔄 HomeCubit: Starting initialization...');
      
      // 1. إصدار حالة التحميل إذا كانت المرة الأولى
      if (!_isInitialized || force) {
        emit(HomeInitial(categories: []));
      }
      
      // 2. تحميل التصنيفات إذا لم تكن محملة
      if (_categories.isEmpty) {
        await _loadCategories();
      }
      
      // 3. محاولة تحميل البيانات المخزنة
      final cachedData = await _loadFromCache();
      
      if (cachedData != null) {
        print('📦 HomeCubit: Loaded cached data');
        _allFeedItems = cachedData['feedItems'] ?? [];
        _onThisDayEvents = cachedData['events'] ?? [];
        _nextCursor = cachedData['nextCursor'];
        _hasMore = cachedData['hasMore'] ?? true;
        _currentFeedType = cachedData['feedType'] ?? 'home';
        _currentCategoryId = cachedData['categoryId'];
        
        // إصدار حالة المحملة مع البيانات المخزنة
        if (_allFeedItems.isNotEmpty) {
          emit(HomeLoaded(
            feedItems: _allFeedItems,
            onThisDayEvents: _onThisDayEvents,
            hasMore: _hasMore,
            categories: _categories,
            currentCategoryId: _currentCategoryId,
            feedType: _currentFeedType,
          ));
        }
      }
      
      // 4. تحميل البيانات الجديدة فقط إذا لم يكن لدينا بيانات
      if (_allFeedItems.isEmpty) {
        print('📡 HomeCubit: Loading fresh data...');
        await getFeed(forceRefresh: true);
      } else {
        print('✅ HomeCubit: Using existing data, no need to refresh');
        // تحديث البيانات في الخلفية
        _refreshDataInBackground();
      }

      
      _isInitialized = true;
      print('✅ HomeCubit: Initialization completed successfully');
      
    } catch (e) {
      print('❌ HomeCubit: Initialization error: $e');
      
      // حتى لو حدث خطأ، نعتبر أن التهيئة تمت
      _isInitialized = true;
      
      if (_allFeedItems.isNotEmpty) {
        // نعرض البيانات الموجودة حتى مع وجود خطأ
        emit(HomeLoaded(
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
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
        
        // حفظ في التخزين المؤقت
        await _saveToCache();
        
        print('✅ HomeCubit: Background refresh completed');
      }
    } catch (e) {
      print('⚠️ HomeCubit: Background refresh failed: $e');
    }
  }
  
  // ✅ دالة لإعادة تعيين حالة التهيئة (تستخدم عند تسجيل الخروج)
  void resetInitialization() {
    print('🔄 HomeCubit: Resetting initialization state');
    _isInitialized = false;
    _isInitializing = false;
  }
   bool get isInitialized => _isInitialized;

  // ✅ الدالة الرئيسية للتحميل
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
          _allFeedItems = [];
          _onThisDayEvents = [];
          _nextCursor = null;
          _hasMore = true;
          
          emit(HomeLoading(
            categories: _categories,
            currentCategoryId: _currentCategoryId,
            feedType: _currentFeedType,
          ));
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
        // إضافة البيانات الجديدة للقائمة الحالية
        _allFeedItems.addAll(response.data.feed);
      } else {
        // استبدال البيانات القديمة
        _allFeedItems = response.data.feed;
      }
      
      _onThisDayEvents = response.data.onThisDayEvents;
      _isLoadingMore = false;
      
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
      
      // في حالة الخطأ، نعرض البيانات الحالية إذا كانت موجودة
      if (_allFeedItems.isNotEmpty) {
        emit(HomeLoaded(
          feedItems: _allFeedItems,
          onThisDayEvents: _onThisDayEvents,
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

  // ✅ تحميل المزيد تلقائياً
  Future<void> loadMore() async {
    if (_hasMore && !_isLoadingMore && _nextCursor != null) {
      print('🔄 تحميل المزيد - cursor: $_nextCursor');
      await getFeed(loadMore: true);
    }
  }

  // ✅ تغيير التصنيف
  Future<void> switchCategory(String? categoryId) async {
    print('🔄 تغيير التصنيف إلى: $categoryId');
    
    if (categoryId == _currentCategoryId) return;
    
    // حفظ الإعدادات السابقة
    final previousCategoryId = _currentCategoryId;
    final previousFeedType = _currentFeedType;
    
    // تحديث الإعدادات الجديدة
    if (categoryId == null) {
      _currentCategoryId = null;
      _currentFeedType = 'home';
    } else {
      _currentCategoryId = categoryId;
      _currentFeedType = 'category';
    }
    
    // إعادة تعيين البيانات
    _allFeedItems.clear();
    _onThisDayEvents.clear();
    _nextCursor = null;
    _hasMore = true;
    
    try {
      await getFeed(forceRefresh: true);
    } catch (e) {
      // في حالة الخطأ، نعود للإعدادات السابقة
      _currentCategoryId = previousCategoryId;
      _currentFeedType = previousFeedType;
      rethrow;
    }
  }

  // ✅ إعادة تحميل البيانات
  Future<void> refresh() async {
    print('🔄 إعادة تحميل البيانات');
    _allFeedItems.clear();
    _onThisDayEvents.clear();
    _nextCursor = null;
    _hasMore = true;
    _isFirstLoad = true;
    
    await getFeed(forceRefresh: true);
  }

  // ✅ دوال التخزين المؤقت
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
    
    // ✅ تحسين المقارنة لتشمل الحالات null
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

  Future<void> _loadCategories() async {
    try {
      _categories = await _homeRepository.getCategories();
      
      // حفظ التصنيفات في التخزين
      final categoriesJson = jsonEncode(_categories.map((c) => c.toJson()).toList());
      await _storageService.writeSecureData(_cachedCategoriesKey, categoriesJson);
      
      print('✅ تم تحميل ${_categories.length} تصنيف');
    } catch (e) {
      print('❌ خطأ في تحميل التصنيفات: $e');
      
      // محاولة تحميل من التخزين
      try {
        final cached = await _storageService.readSecureData(_cachedCategoriesKey);
        if (cached != null) {
          final categoriesList = (jsonDecode(cached) as List).cast<Map<String, dynamic>>();
          _categories = categoriesList.map((item) => Category.fromJson(item)).toList();
          print('📦 تم تحميل ${_categories.length} تصنيف من التخزين');
        }
      } catch (cacheError) {
        print('❌ خطأ في تحميل التصنيفات المخزنة: $cacheError');
      }
    }
  }

  // ✅ دوال التفاعل مع تحديث الـ UI فوراً
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
      
      // التراجع عن التحديث في حالة الخطأ
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
      
      // التراجع عن التحديث
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

  // ✅ مسح التخزين المؤقت عند تسجيل الخروج
  Future<void> clearCacheAndData() async {
    print('🧹 HomeCubit: مسح كل البيانات والتخزين...');
    
    try {
      // مسح البيانات المحلية
      _allFeedItems.clear();
      _onThisDayEvents.clear();
      _categories.clear();
      _nextCursor = null;
      _hasMore = true;
      _isFirstLoad = true;
      _isLoadingMore = false;
      _currentCategoryId = null;
      _currentFeedType = 'home';
      
      // مسح التخزين المؤقت
      await _clearCache();
      
      // إعادة الحالة الأولية
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
      await _storageService.deleteSecureData(_cachedCategoriesKey);
      
      print('🗑️ تم مسح التخزين المؤقت للـ HomeCubit');
    } catch (e) {
      print('❌ خطأ في مسح التخزين المؤقت: $e');
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
}