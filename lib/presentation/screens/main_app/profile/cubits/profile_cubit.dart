// lib/presentation/screens/main_app/profile/cubits/profile_cubit.dart
import 'dart:convert';
import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/user_profile_model.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final StorageService? _storageService;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isInitialLoadDone = false;
  List<TelegramModel> _allTelegrams = [];
  UserProfileModel? _currentProfile;
  
  // ✅ متغيرات Overlay Loading
  bool _isLoading = false;
  bool _isRefreshingWithOverlay = false;
  
  // ✅ بيانات مؤقتة للعرض أثناء التحميل
  UserProfileModel? _lastValidProfile;
  List<TelegramModel> _lastValidTelegrams = [];
  
  int? _cachedUserId;
  bool _isMyProfile = true;
  
  // ✅ متغيرات التهيئة
  bool _isInitializing = false;
  bool _isInitialized = false;
  
  // ✅ Cache Keys
  static const String _cachedProfileKey = 'cached_profile';
  static const String _cachedTelegramsKey = 'cached_telegrams';
  static const String _cachedUserIdKey = 'cached_user_id';
  static const String _cachedIsMyProfileKey = 'cached_is_my_profile';
  static const String _cachedTimestampKey = 'cached_profile_timestamp';
  static const Duration _cacheDuration = Duration(minutes: 10);

  ProfileCubit({
    required ProfileRepository profileRepository,
    StorageService? storageService,
  }) : _profileRepository = profileRepository,
        _storageService = storageService,
        super(ProfileInitial());

  // ✅ دالة التهيئة المعدلة مع Overlay الصحيح
  Future<void> initialize({bool force = false, int? userId}) async {
    if (_isInitialized && !force) {
      print('✅ ProfileCubit: Already initialized, skipping...');
      return;
    }
    
    if (_isInitializing) {
      print('⚠️ ProfileCubit: Initialization already in progress');
      return;
    }
    
    _isInitializing = true;
    
    try {
      print('🔄 ProfileCubit: Starting initialization...');
      
      // 1. تحميل البيانات المخزنة أولاً
      final cachedData = await _loadFromCache();
      
      if (cachedData != null) {
        print('📦 ProfileCubit: Loaded cached data');
        _currentProfile = cachedData['profile'];
        _allTelegrams = cachedData['telegrams'] ?? [];
        _cachedUserId = cachedData['userId'];
        _isMyProfile = cachedData['isMyProfile'] ?? true;
        
        // حفظ كآخر بيانات صالحة
        _lastValidProfile = _currentProfile;
        _lastValidTelegrams = List.from(_allTelegrams);
        
        // ✅ عرض البيانات المخزنة مع Overlay للتحميل
        if (_currentProfile != null) {
          emit(ProfileRefreshingWithOverlay(
            profile: _currentProfile!,
            telegrams: _allTelegrams,
            lastValidProfile: _lastValidProfile,
          ));
        } else {
          emit(ProfileLoading(lastValidProfile: _lastValidProfile));
        }
      } else {
        // إذا مفيش بيانات مخزنة، نعرض حالة Loading بدون بيانات
        emit(ProfileLoading(lastValidProfile: _lastValidProfile));
      }
      
      // 2. جلب البيانات الجديدة مع الحفاظ على العرض القديم
      try {
        if (userId == null) {
          await getMyProfile(forceRefresh: true, showOverlay: false);
        } else {
          await getUserProfile(userId, forceRefresh: true, showOverlay: false);
        }
        
        print('✅ ProfileCubit: Initialization completed successfully');
        
      } catch (e) {
        print('❌ ProfileCubit: Error loading fresh data: $e');
        
        // إذا فشل تحميل البيانات الجديدة، نظهر البيانات القديمة بدون Overlay
        if (_lastValidProfile != null) {
          emit(ProfileLoaded(
            profile: _lastValidProfile!,
            telegrams: _lastValidTelegrams,
            lastValidProfile: _lastValidProfile,
          ));
        } else {
          // إذا مفيش بيانات خالص، نظهر Error State
          emit(ProfileError(
            error: 'فشل تحميل البيانات',
            lastValidProfile: _lastValidProfile,
          ));
        }
      }

      _isInitialized = true;
      
    } catch (e) {
      print('❌ ProfileCubit: Initialization error: $e');
      
      _isInitialized = true;
      
      if (_lastValidProfile != null) {
        emit(ProfileLoaded(
          profile: _lastValidProfile!,
          telegrams: _lastValidTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
      }
    } finally {
      _isInitializing = false;
    }
  }

  // ✅ تعديل دالة getMyProfile لدعم Overlay الصحيح
  Future<void> getMyProfile({
    bool loadMore = false, 
    bool forceRefresh = false,
    bool showOverlay = true
  }) async {
    // ✅ منع التحميل إذا كان جارياً بالفعل
    if (_isLoading && !loadMore && !forceRefresh) {
      print('⏸️ ProfileCubit: Loading already in progress, skipping...');
      return;
    }
    
    // ✅ حفظ البيانات الحالية قبل التحديث
    final previousProfile = _currentProfile;
    final previousTelegrams = List<TelegramModel>.from(_allTelegrams);
    
    // ✅ إذا كان forceRefresh = true، نطلب البيانات من السيرفر
    if (forceRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _cachedUserId = null;
      _isMyProfile = true;
      print('🔄 ProfileCubit: Force refresh requested');
      
      // ✅ إرسال حالة الـ Overlay Loading مع البيانات القديمة
      if (!loadMore && showOverlay && _lastValidProfile != null) {
        emit(ProfileRefreshingWithOverlay(
          profile: _lastValidProfile!,
          telegrams: _lastValidTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
      } else if (!loadMore && _lastValidProfile != null) {
        emit(ProfileRefreshingWithOverlay(
          profile: _lastValidProfile!,
          telegrams: _lastValidTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
      } else if (!loadMore) {
        emit(ProfileLoading(lastValidProfile: _lastValidProfile));
      }
    }
    
    // ✅ إذا كان البروفايل محملاً ولا نحتاج تحميل إضافي ولا force refresh
    if (_isInitialLoadDone && _isMyProfile && !loadMore && !forceRefresh && _currentProfile != null) {
      print('📱 ProfileCubit: Using cached data, no reload needed');
      emit(ProfileLoaded(
        profile: _currentProfile!,
        telegrams: _allTelegrams,
        lastValidProfile: _lastValidProfile,
      ));
      return;
    }

    try {
      // ✅ وضع علامة أن التحميل جاري
      _isLoading = true;

      if (!loadMore && !forceRefresh) {
        // فقط إذا كان هذا ليس تحميل إضافي ولم يكن هناك بيانات
        if (!_isInitialLoadDone || !_isMyProfile || _currentProfile == null) {
          _currentPage = 1;
          _hasMore = true;
          _cachedUserId = null;
          _isMyProfile = true;
          
          // ✅ عرض البيانات القديمة مع Overlay للتحميل
          if (_lastValidProfile != null) {
            emit(ProfileRefreshingWithOverlay(
              profile: _lastValidProfile!,
              telegrams: _lastValidTelegrams,
              lastValidProfile: _lastValidProfile,
            ));
          } else {
            emit(ProfileLoading(lastValidProfile: _lastValidProfile));
          }
        } else {
          // لدينا بيانات مسبقاً، نعرضها
          print('📱 ProfileCubit: Already have data, showing...');
          emit(ProfileLoaded(
            profile: _currentProfile!,
            telegrams: _allTelegrams,
            lastValidProfile: _lastValidProfile,
          ));
          _isLoading = false;
          return;
        }
      } else {
        // تحميل إضافي
        if (!_hasMore && !forceRefresh) {
          print('⚠️ No more data to load');
          _isLoading = false;
          return;
        }
        
        // ✅ إذا كان forceRefresh مع overlay، لا نرسل ProfileLoadingMore
        if (!forceRefresh || !showOverlay) {
          emit(ProfileLoadingMore(
            telegrams: _allTelegrams,
            lastValidProfile: _lastValidProfile,
          ));
        }
      }

      print('📡 Loading profile page $_currentPage');
      final response = await _profileRepository.getMyProfile(page: _currentPage);
      
      _cachedUserId = response.data.id;
      _isMyProfile = true;
      
      if (response.pagination != null) {
        _hasMore = response.pagination!.hasMore;
        print('📊 Pagination: current=${response.pagination!.currentPage}, '
              'last=${response.pagination!.lastPage}, '
              'hasMore=$_hasMore');
      } else {
        _hasMore = response.data.telegrams.isNotEmpty;
        print('⚠️ No pagination info, assuming hasMore=$_hasMore');
      }

      // ✅ تحديث البيانات
      List<TelegramModel> newTelegrams;
      
      if (forceRefresh || _currentPage == 1) {
        newTelegrams = response.data.telegrams;
        _allTelegrams = newTelegrams;
      } else {
        newTelegrams = response.data.telegrams;
        _allTelegrams.addAll(newTelegrams);
      }
      
      print('📦 Total telegrams now: ${_allTelegrams.length}');

      // تحديث الـ profile
      _currentProfile = response.data.copyWith(
        telegrams: _allTelegrams,
      );
      
      // ✅ حفظ كآخر بيانات صالحة
      _lastValidProfile = _currentProfile;
      _lastValidTelegrams = List.from(_allTelegrams);
      
      // ✅ حفظ في التخزين المؤقت
      await _saveToCache();

      if (_hasMore && !forceRefresh) {
        _currentPage++;
        print('⬆️ Next page will be: $_currentPage');
      }

      _isInitialLoadDone = true;
      _isLoading = false;
      
      // ✅ إصدار الحالة الجديدة بدون Overlay
      emit(ProfileLoaded(
        profile: _currentProfile!,
        telegrams: _allTelegrams,
        lastValidProfile: _lastValidProfile,
      ));
      
      print('✅ Profile loaded successfully');
      
    } catch (e) {
      print('❌ Error loading profile: $e');
      _isLoading = false;
      
      // ✅ في حالة الخطأ، استعادة البيانات القديمة
      if (forceRefresh || _currentPage == 1) {
        _currentProfile = previousProfile;
        _allTelegrams = previousTelegrams;
      }
      
      // ✅ محاولة إظهار البيانات المخزنة في حالة الخطأ بدون Overlay
      if (_lastValidProfile != null) {
        emit(ProfileLoaded(
          profile: _lastValidProfile!,
          telegrams: _lastValidTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
      } else {
        emit(ProfileError(
          error: e.toString(),
          lastValidProfile: _lastValidProfile,
        ));
      }
    }
  }

  // ✅ تعديل دالة getUserProfile لدعم Overlay الصحيح
  Future<void> getUserProfile(int userId, {
    bool loadMore = false, 
    bool forceRefresh = false,
    bool showOverlay = true
  }) async {
    // ✅ منع التحميل إذا كان جارياً بالفعل
    if (_isLoading && !loadMore && !forceRefresh) {
      print('⏸️ ProfileCubit: Loading already in progress, skipping...');
      return;
    }
    
    // ✅ حفظ البيانات الحالية قبل التحديث
    final previousProfile = _currentProfile;
    final previousTelegrams = List<TelegramModel>.from(_allTelegrams);
    
    // ✅ إذا كان forceRefresh = true، نطلب البيانات من السيرفر
    if (forceRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _cachedUserId = userId;
      _isMyProfile = false;
      print('🔄 ProfileCubit: Force refresh requested for user $userId');
      
      // ✅ إرسال حالة الـ Overlay Loading مع البيانات القديمة
      if (!loadMore && showOverlay && _lastValidProfile != null) {
        emit(ProfileRefreshingWithOverlay(
          profile: _lastValidProfile!,
          telegrams: _lastValidTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
      } else if (!loadMore && _lastValidProfile != null) {
        emit(ProfileRefreshingWithOverlay(
          profile: _lastValidProfile!,
          telegrams: _lastValidTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
      } else if (!loadMore) {
        emit(ProfileLoading(lastValidProfile: _lastValidProfile));
      }
    }
    
    // ✅ إذا كان هذا هو نفس البروفايل الموجود في الكاش ولا نحتاج لتحميله من جديد
    if (_isInitialLoadDone && _cachedUserId == userId && !loadMore && !forceRefresh && _currentProfile != null) {
      print('📱 ProfileCubit: Using cached user profile data for user $userId');
      emit(ProfileLoaded(
        profile: _currentProfile!,
        telegrams: _allTelegrams,
        lastValidProfile: _lastValidProfile,
      ));
      return;
    }

    try {
      _isLoading = true;

      if (!loadMore && !forceRefresh) {
        // فقط إذا كان هذا ليس تحميل إضافي ولم يكن هناك بيانات لهذا المستخدم
        if (_cachedUserId != userId || _currentProfile == null) {
          _currentPage = 1;
          _hasMore = true;
          _cachedUserId = userId;
          _isMyProfile = false;
          
          // ✅ عرض البيانات القديمة مع Overlay للتحميل
          if (_lastValidProfile != null) {
            emit(ProfileRefreshingWithOverlay(
              profile: _lastValidProfile!,
              telegrams: _lastValidTelegrams,
              lastValidProfile: _lastValidProfile,
            ));
          } else {
            emit(ProfileLoading(lastValidProfile: _lastValidProfile));
          }
        } else {
          // لدينا بيانات مسبقاً، نعرضها
          print('📱 ProfileCubit: Already have data for user $userId, showing...');
          emit(ProfileLoaded(
            profile: _currentProfile!,
            telegrams: _allTelegrams,
            lastValidProfile: _lastValidProfile,
          ));
          _isLoading = false;
          return;
        }
      } else {
        if (!_hasMore && !forceRefresh) {
          print('⚠️ No more data to load');
          _isLoading = false;
          return;
        }
        
        if (!forceRefresh || !showOverlay) {
          emit(ProfileLoadingMore(
            telegrams: _allTelegrams,
            lastValidProfile: _lastValidProfile,
          ));
        }
      }

      final response = await _profileRepository.getUserProfile(
        userId, 
        page: _currentPage
      );
      
      if (response.pagination != null) {
        _hasMore = response.pagination!.hasMore;
      } else {
        _hasMore = response.data.telegrams.isNotEmpty;
      }

      // ✅ تحديث البيانات
      List<TelegramModel> newTelegrams;
      
      if (forceRefresh || _currentPage == 1) {
        newTelegrams = response.data.telegrams;
        _allTelegrams = newTelegrams;
      } else {
        newTelegrams = response.data.telegrams;
        _allTelegrams.addAll(newTelegrams);
      }
      
      // تحديث الـ profile
      _currentProfile = response.data.copyWith(
        telegrams: _allTelegrams,
      );
      
      // ✅ حفظ كآخر بيانات صالحة
      _lastValidProfile = _currentProfile;
      _lastValidTelegrams = List.from(_allTelegrams);
      
      // ✅ حفظ في التخزين المؤقت
      await _saveToCache();

      if (_hasMore && !forceRefresh) {
        _currentPage++;
      }

      _isInitialLoadDone = true;
      _isLoading = false;
      
      // ✅ إصدار الحالة الجديدة بدون Overlay
      emit(ProfileLoaded(
        profile: _currentProfile!,
        telegrams: _allTelegrams,
        lastValidProfile: _lastValidProfile,
      ));
      
      print('✅ User profile loaded successfully');
      
    } catch (e) {
      print('❌ Error loading user profile: $e');
      _isLoading = false;
      
      // ✅ في حالة الخطأ، استعادة البيانات القديمة
      if (forceRefresh || _currentPage == 1) {
        _currentProfile = previousProfile;
        _allTelegrams = previousTelegrams;
      }
      
      // ✅ إظهار البيانات القديمة بدون Overlay في حالة الخطأ
      if (_lastValidProfile != null) {
        emit(ProfileLoaded(
          profile: _lastValidProfile!,
          telegrams: _lastValidTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
      } else {
        emit(ProfileError(
          error: e.toString(),
          lastValidProfile: _lastValidProfile,
        ));
      }
    }
  }

  // ✅ دالة Refresh المعدلة مع Overlay الصحيح
  Future<void> refresh({int? userId}) async {
    print('🔄 ProfileCubit: Refreshing with overlay...');
    
    if (_isRefreshingWithOverlay) return;
    
    try {
      _isRefreshingWithOverlay = true;
      
      // ✅ حفظ البيانات الحالية مؤقتاً
      final UserProfileModel? oldProfile = _currentProfile;
      final List<TelegramModel> oldTelegrams = List.from(_allTelegrams);
      
      // ✅ إصدار حالة الـ Overlay Loading مع البيانات الحالية
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(ProfileRefreshingWithOverlay(
          profile: currentState.profile,
          telegrams: currentState.telegrams,
          lastValidProfile: currentState.lastValidProfile,
        ));
      } else if (state is ProfileRefreshingWithOverlay) {
        final currentState = state as ProfileRefreshingWithOverlay;
        emit(ProfileRefreshingWithOverlay(
          profile: currentState.profile,
          telegrams: currentState.telegrams,
          lastValidProfile: currentState.lastValidProfile,
        ));
      } else if (state is ProfileUpdated) {
        final currentState = state as ProfileUpdated;
        emit(ProfileRefreshingWithOverlay(
          profile: currentState.profile,
          telegrams: currentState.telegrams,
          lastValidProfile: currentState.lastValidProfile,
        ));
      } else if (_lastValidProfile != null) {
        emit(ProfileRefreshingWithOverlay(
          profile: _lastValidProfile!,
          telegrams: _lastValidTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
      } else {
        emit(ProfileLoading(lastValidProfile: _lastValidProfile));
      }
      
      try {
        // جلب البيانات الجديدة
        if (userId == null) {
          await getMyProfile(forceRefresh: true, showOverlay: false);
        } else {
          await getUserProfile(userId, forceRefresh: true, showOverlay: false);
        }
        
        print('✅ ProfileCubit: Refresh completed successfully');
        
      } catch (e) {
        print('❌ Error refreshing profile: $e');
        
        // ✅ استعادة البيانات القديمة في حالة الخطأ
        _currentProfile = oldProfile;
        _allTelegrams = oldTelegrams;
        _lastValidProfile = oldProfile;
        _lastValidTelegrams = oldTelegrams;
        
        if (oldProfile != null) {
          emit(ProfileLoaded(
            profile: oldProfile,
            telegrams: oldTelegrams,
            lastValidProfile: _lastValidProfile,
          ));
        } else {
          emit(ProfileError(
            error: e.toString(),
            lastValidProfile: _lastValidProfile,
          ));
        }
        
        throw e;
      }
    } finally {
      _isRefreshingWithOverlay = false;
    }
  }

  // ✅ دالة clearCacheAndRefresh
  Future<void> clearCacheAndRefresh({int? userId}) async {
    print('🧹 ProfileCubit: Clearing cache and refreshing');
    
    _allTelegrams.clear();
    _lastValidProfile = null;
    _lastValidTelegrams.clear();
    _hasMore = true;
    _currentPage = 1;
    
    await _clearCache();
    
    emit(ProfileLoading(lastValidProfile: _lastValidProfile));
    
    if (userId == null) {
      await getMyProfile(forceRefresh: true);
    } else {
      await getUserProfile(userId, forceRefresh: true);
    }
  }

  // ✅ دوال Cache
  Future<Map<String, dynamic>?> _loadFromCache() async {
    try {
      if (_storageService == null) return null;
      
      final cachedTimestamp = await _storageService!.readSecureData(_cachedTimestampKey);
      if (cachedTimestamp == null) return null;
      
      final cachedTime = DateTime.parse(cachedTimestamp);
      final now = DateTime.now();
      
      if (now.difference(cachedTime) > _cacheDuration) {
        print('🗑️ ProfileCubit: Cache expired');
        return null;
      }
      
      final profileJson = await _storageService!.readSecureData(_cachedProfileKey);
      final telegramsJson = await _storageService!.readSecureData(_cachedTelegramsKey);
      final cachedUserId = await _storageService!.readSecureData(_cachedUserIdKey);
      final cachedIsMyProfile = await _storageService!.readSecureData(_cachedIsMyProfileKey);
      
      if (profileJson == null) return null;
      
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      final profile = UserProfileModel.fromJson(profileMap);
      
      List<TelegramModel> telegrams = [];
      if (telegramsJson != null) {
        final telegramsList = (jsonDecode(telegramsJson) as List).cast<Map<String, dynamic>>();
        telegrams = telegramsList.map((item) => TelegramModel.fromJson(item)).toList();
      }
      
      final isMyProfile = cachedIsMyProfile == 'true';
      final userId = cachedUserId != null ? int.tryParse(cachedUserId) : null;
      
      print('📦 ProfileCubit: Loaded profile from cache');
      return {
        'profile': profile,
        'telegrams': telegrams,
        'userId': userId,
        'isMyProfile': isMyProfile,
      };
    } catch (e) {
      print('❌ ProfileCubit: Error loading from cache: $e');
      return null;
    }
  }

  Future<void> _saveToCache() async {
    try {
      if (_storageService == null || _currentProfile == null) return;
      
      final profileJson = jsonEncode(_currentProfile!.toJson());
      final telegramsJson = jsonEncode(_allTelegrams.map((item) => item.toJson()).toList());
      
      await _storageService!.writeSecureData(_cachedProfileKey, profileJson);
      await _storageService!.writeSecureData(_cachedTelegramsKey, telegramsJson);
      await _storageService!.writeSecureData(_cachedUserIdKey, _cachedUserId?.toString() ?? '');
      await _storageService!.writeSecureData(_cachedIsMyProfileKey, _isMyProfile.toString());
      await _storageService!.writeSecureData(_cachedTimestampKey, DateTime.now().toIso8601String());
      
      print('💾 ProfileCubit: Saved to cache');
    } catch (e) {
      print('❌ ProfileCubit: Error saving to cache: $e');
    }
  }

  Future<void> _clearCache() async {
    try {
      if (_storageService == null) return;
      
      await _storageService!.deleteSecureData(_cachedProfileKey);
      await _storageService!.deleteSecureData(_cachedTelegramsKey);
      await _storageService!.deleteSecureData(_cachedUserIdKey);
      await _storageService!.deleteSecureData(_cachedIsMyProfileKey);
      await _storageService!.deleteSecureData(_cachedTimestampKey);
      
      print('🗑️ ProfileCubit: Cache cleared');
    } catch (e) {
      print('❌ ProfileCubit: Error clearing cache: $e');
    }
  }

  // ✅ باقي الدوال الموجودة في الكود الأصلي
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _profileRepository.updateProfile(data);
      
      _currentProfile = response.data.copyWith(
        telegrams: _allTelegrams,
      );
      
      _cachedUserId = _currentProfile!.id;
      _isMyProfile = true;
      _lastValidProfile = _currentProfile;
      _lastValidTelegrams = List.from(_allTelegrams);
      
      await _saveToCache();
      
      emit(ProfileUpdated(
        profile: _currentProfile!,
        telegrams: _allTelegrams,
        lastValidProfile: _lastValidProfile,
      ));
      
      print('✅ Profile updated successfully');
    } catch (e) {
      print('❌ Error updating profile: $e');
      
      if (_lastValidProfile != null) {
        emit(ProfileLoaded(
          profile: _lastValidProfile!,
          telegrams: _lastValidTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
      } else {
        emit(ProfileError(
          error: e.toString(),
          lastValidProfile: _lastValidProfile,
        ));
      }
    }
  }

  // في profile_cubit.dart
Future<void> updateTelegramInList(Map<String, dynamic> updatedData) async {
  try {
    final telegramId = updatedData['id']?.toString();
    if (telegramId == null) {
      print('❌ ProfileCubit: No telegram ID in update data');
      return;
    }
    
    print('🔄 ProfileCubit: Updating telegram in list: $telegramId');
    print('📦 Update data: $updatedData');
    
    final index = _allTelegrams.indexWhere((t) => t.id == telegramId);
    if (index != -1) {
      final oldTelegram = _allTelegrams[index];
      
      // ✅ تحديث البيانات
      _allTelegrams[index] = TelegramModel(
        id: telegramId,
        type: oldTelegram.type,
        feedAt: oldTelegram.feedAt,
        number: oldTelegram.number,
        content: updatedData['content'] ?? oldTelegram.content,
        isAd: updatedData['is_ad'] ?? oldTelegram.isAd,
        user: oldTelegram.user,
        category: CategoryModel(
          id: updatedData['category_id'] ?? oldTelegram.category.id,
          name: oldTelegram.category.name, // تحتفظ بالاسم القديم
          color: oldTelegram.category.color,
          icon: oldTelegram.category.icon,
        ),
        createdAt: oldTelegram.createdAt,
        likesCount: oldTelegram.likesCount,
        commentsCount: oldTelegram.commentsCount,
        repostsCount: oldTelegram.repostsCount,
        isLiked: oldTelegram.isLiked,
        isReposted: oldTelegram.isReposted,
      );
      
      print('✅ ProfileCubit: Telegram updated at index $index');
      
      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(
          telegrams: List.from(_allTelegrams),
        );
        
        _lastValidProfile = _currentProfile;
        _lastValidTelegrams = List.from(_allTelegrams);
        
        await _saveToCache();
        
        emit(ProfileUpdated(
          profile: _currentProfile!,
          telegrams: _allTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
        
        print('✅ ProfileCubit: Profile state updated');
      }
    } else {
      print('⚠️ ProfileCubit: Telegram not found in list, forcing refresh');
      
      // إذا لم تجد البرقية، قم بتحميل جديد
      if (_isMyProfile) {
        await getMyProfile(forceRefresh: true);
      } else if (_cachedUserId != null) {
        await getUserProfile(_cachedUserId!, forceRefresh: true);
      }
    }
  } catch (e) {
    print('❌ ProfileCubit: Error updating telegram in list: $e');
  }
}

  Future<void> removeTelegramFromList(int telegramId) async {
    try {
      print('🗑️ ProfileCubit: Removing telegram $telegramId from list');
      
      _allTelegrams.removeWhere((telegram) => telegram.id == telegramId.toString());
      _lastValidTelegrams = List.from(_allTelegrams);
      
      print('📊 Total telegrams after removal: ${_allTelegrams.length}');
      
      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(
          telegrams: List.from(_allTelegrams),
        );
        
        final updatedStats = ProfileStatistics(
          followersCount: _currentProfile!.statistics.followersCount,
          followingCount: _currentProfile!.statistics.followingCount,
          telegramsCount: _allTelegrams.length,
        );
        
        _currentProfile = _currentProfile!.copyWith(
          statistics: updatedStats,
        );
        
        _lastValidProfile = _currentProfile;
        _lastValidTelegrams = List.from(_allTelegrams);
        
        await _saveToCache();
        
        emit(ProfileUpdated(
          profile: _currentProfile!,
          telegrams: _allTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
        print('✅ Telegram removed from list and profile updated');
      }
    } catch (e) {
      print('❌ Error removing telegram from list: $e');
    }
  }

  Future<void> updateTelegramLikeStatus(String telegramId, Map<String, dynamic> updatedData) async {
    try {
      print('🔄 ProfileCubit: Updating like status for telegram: $telegramId');
      
      final index = _allTelegrams.indexWhere((t) => t.id == telegramId);
      if (index != -1) {
        _allTelegrams[index] = TelegramModel(
          id: telegramId,
          type: _allTelegrams[index].type,
          feedAt: _allTelegrams[index].feedAt,
          number: _allTelegrams[index].number,
          content: _allTelegrams[index].content,
          isAd: _allTelegrams[index].isAd,
          user: _allTelegrams[index].user,
          category: _allTelegrams[index].category,
          createdAt: _allTelegrams[index].createdAt,
          likesCount: updatedData['likes_count'] ?? _allTelegrams[index].likesCount,
          commentsCount: _allTelegrams[index].commentsCount,
          repostsCount: _allTelegrams[index].repostsCount,
          isLiked: updatedData['is_liked'] ?? _allTelegrams[index].isLiked,
          isReposted: _allTelegrams[index].isReposted,
        );
        
        if (_currentProfile != null) {
          _currentProfile = _currentProfile!.copyWith(
            telegrams: List.from(_allTelegrams),
          );
          
          _lastValidProfile = _currentProfile;
          _lastValidTelegrams = List.from(_allTelegrams);
          
          await _saveToCache();
          
          emit(ProfileUpdated(
            profile: _currentProfile!,
            telegrams: _allTelegrams,
            lastValidProfile: _lastValidProfile,
          ));
          print('✅ Telegram like status updated in list');
        }
      } else {
        print('⚠️ Telegram not found in list for like update');
      }
    } catch (e) {
      print('❌ Error updating telegram like status: $e');
    }
  }

  Future<void> updateTelegramRepostStatus(String telegramId, Map<String, dynamic> updatedData) async {
    try {
      print('🔄 ProfileCubit: Updating repost status for telegram: $telegramId');
      
      final index = _allTelegrams.indexWhere((t) => t.id == telegramId);
      if (index != -1) {
        _allTelegrams[index] = TelegramModel(
          id: telegramId,
          type: _allTelegrams[index].type,
          feedAt: _allTelegrams[index].feedAt,
          number: _allTelegrams[index].number,
          content: _allTelegrams[index].content,
          isAd: _allTelegrams[index].isAd,
          user: _allTelegrams[index].user,
          category: _allTelegrams[index].category,
          createdAt: _allTelegrams[index].createdAt,
          likesCount: _allTelegrams[index].likesCount,
          commentsCount: _allTelegrams[index].commentsCount,
          repostsCount: updatedData['reposts_count'] ?? _allTelegrams[index].repostsCount,
          isLiked: _allTelegrams[index].isLiked,
          isReposted: updatedData['is_reposted'] ?? _allTelegrams[index].isReposted,
        );
        
        if (_currentProfile != null) {
          _currentProfile = _currentProfile!.copyWith(
            telegrams: List.from(_allTelegrams),
          );
          
          _lastValidProfile = _currentProfile;
          _lastValidTelegrams = List.from(_allTelegrams);
          
          await _saveToCache();
          
          emit(ProfileUpdated(
            profile: _currentProfile!,
            telegrams: _allTelegrams,
            lastValidProfile: _lastValidProfile,
          ));
          print('✅ Telegram repost status updated in list');
        }
      } else {
        print('⚠️ Telegram not found in list for repost update');
      }
    } catch (e) {
      print('❌ Error updating telegram repost status: $e');
    }
  }

  // ✅ Getters
  bool get isRefreshingWithOverlay => _isRefreshingWithOverlay;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get hasMore => _hasMore;
  int get telegramsCount => _allTelegrams.length;
  UserProfileModel? get cachedProfile => _currentProfile;
  UserProfileModel? get lastValidProfile => _lastValidProfile;
  List<TelegramModel> get lastValidTelegrams => _lastValidTelegrams;
  bool get isProfileLoaded => _currentProfile != null && _isInitialLoadDone;
  
  // ✅ دالة resetInitialization
  void resetInitialization() {
    print('🔄 ProfileCubit: Resetting initialization state');
    _isInitialized = false;
    _isInitializing = false;
  }
  
  // ✅ دالة clearAllData للخروج
  void clearAllData() {
    print('🧹 ProfileCubit: Clearing ALL data for logout...');
    
    _currentPage = 1;
    _hasMore = true;
    _isInitialLoadDone = false;
    _allTelegrams.clear();
    _currentProfile = null;
    _lastValidProfile = null;
    _lastValidTelegrams.clear();
    _cachedUserId = null;
    _isMyProfile = true;
    _isLoading = false;
    _isInitialized = false;
    _isInitializing = false;
    _isRefreshingWithOverlay = false;
    
    emit(ProfileInitial());
    
    print('✅ ProfileCubit: All data cleared successfully');
  }
  
  void clearProfile() {
    _currentPage = 1;
    _hasMore = true;
    _isInitialLoadDone = false;
    _allTelegrams.clear();
    _currentProfile = null;
    _lastValidProfile = null;
    _lastValidTelegrams.clear();
    _cachedUserId = null;
    _isMyProfile = true;
    _isInitialized = false;
    _isInitializing = false;
    emit(ProfileInitial());
  }
  
  void clearCache() {
    _currentPage = 1;
    _hasMore = true;
    _isInitialLoadDone = false;
    _allTelegrams.clear();
    _currentProfile = null;
    _lastValidProfile = null;
    _lastValidTelegrams.clear();
    _cachedUserId = null;
    _isMyProfile = true;
  }
  
  Future<void> navigateToUserProfile(int userId) async {
    print('📍 ProfileCubit: Navigating to user profile: $userId');
    
    if (userId == _currentProfile?.id) {
      print('⚠️ Same user, no navigation needed');
      return;
    }
    
    final previousProfile = _currentProfile;
    final previousTelegrams = List<TelegramModel>.from(_allTelegrams);
    
    try {
      await getUserProfile(userId);
    } catch (e) {
      print('❌ Error loading user profile for navigation: $e');
      
      _currentProfile = previousProfile;
      _allTelegrams = previousTelegrams;
      _lastValidProfile = previousProfile;
      _lastValidTelegrams = previousTelegrams;
      
      if (previousProfile != null) {
        emit(ProfileLoaded(
          profile: previousProfile,
          telegrams: previousTelegrams,
          lastValidProfile: _lastValidProfile,
        ));
      }
      
      throw e;
    }
  }
}