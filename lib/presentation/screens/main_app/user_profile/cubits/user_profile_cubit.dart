import 'dart:convert';
import 'package:app_1/presentation/screens/main_app/home/models/home_feed_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/models/user_profile_model.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/repositories/user_profile_repository.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserProfileRepository _repository;
  final StorageService _storageService;
  
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  
  UserData? _userData;
  ProfileStatistics? _statistics;
  List<FeedItem> _telegrams = [];
  
  static const String _cachedProfileKey = 'cached_user_profile_';
  static const String _cachedTelegramsKey = 'cached_user_telegrams_';
  static const Duration _cacheDuration = Duration(minutes: 5);

  UserProfileCubit({
    required UserProfileRepository repository,
    required StorageService storageService,
  }) : _repository = repository,
        _storageService = storageService,
        super(UserProfileInitial());

  Future<void> loadUserProfile(String userId, {bool forceRefresh = false}) async {
    try {
      print('🚀 Loading user profile for ID: $userId');
      
      // ✅ إعادة تعيين حالة التحميل
      _currentPage = 1;
      _telegrams.clear();
      _hasMore = true;
      _isLoadingMore = false;
      
      // ✅ التحقق من وجود بيانات مخزنة
      if (!forceRefresh && await _hasValidCache(userId)) {
        await _loadFromCache(userId);
        return;
      }

      emit(UserProfileLoading());
      
      final response = await _repository.getUserProfile(userId, page: _currentPage);
      
      print('✅ Profile loaded successfully');
      print('👤 User: ${response.data.user.fullName}');
      print('📊 Statistics: ${response.data.statistics.followersCount} followers');
      print('📦 Telegrams count: ${response.data.telegrams.data.length}');
      print('📄 Total pages: ${response.data.telegrams.pagination.lastPage}');
      print('📄 Current page: ${response.data.telegrams.pagination.currentPage}');
      
      _userData = response.data.user;
      _statistics = response.data.statistics;
      _telegrams = response.data.telegrams.data;
      _totalPages = response.data.telegrams.pagination.lastPage;
      _hasMore = _currentPage < _totalPages;
      
      print('🔍 Has more pages: $_hasMore');
      
      // ✅ حفظ البيانات في التخزين
      await _saveToCache(userId);
      
      emit(UserProfileLoaded(
        userData: _userData!,
        statistics: _statistics!,
        telegrams: _telegrams,
        hasMore: _hasMore,
      ));
      
    } catch (e) {
      print('❌ Error loading user profile: $e');
      
      // ✅ محاولة تحميل من التخزين المؤقت
      if (await _hasValidCache(userId)) {
        await _loadFromCache(userId);
      } else {
        emit(UserProfileError(error: e.toString()));
      }
    }
  }

  Future<void> loadMoreTelegrams() async {
    try {
      if (_userData == null || !_hasMore || _isLoadingMore) {
        print('⚠️ Cannot load more: hasMore=$_hasMore, isLoadingMore=$_isLoadingMore');
        return;
      }
      
      _isLoadingMore = true;
      
      // ✅ إرسال حالة التحميل مع البيانات الحالية
      if (_userData != null && _statistics != null) {
        emit(UserProfileLoadingMore(
          userData: _userData!,
          statistics: _statistics!,
          telegrams: _telegrams,
          hasMore: _hasMore,
        ));
      }
      
      _currentPage++;
      
      print('📥 Loading more telegrams, page: $_currentPage');
      print('📊 Current telegrams count: ${_telegrams.length}');
      
      // ✅ استخدام الدالة الجديدة لجلب البرقيات فقط
      final telegramsResponse = await _repository.getUserTelegramsOnly(
        _userData!.id, 
        page: _currentPage
      );
      
      final newTelegrams = telegramsResponse.data;
      print('✅ Loaded ${newTelegrams.length} new telegrams');
      
      // ✅ إضافة البرقيات الجديدة إلى القائمة الحالية
      _telegrams.addAll(newTelegrams);
      
      // ✅ تحديث معلومات الصفحات
      _totalPages = telegramsResponse.pagination.lastPage;
      _hasMore = _currentPage < _totalPages;
      _isLoadingMore = false;
      
      print('📊 Total telegrams now: ${_telegrams.length}');
      print('📄 Has more: $_hasMore');
      
      // ✅ إرسال الحالة النهائية
      if (_userData != null && _statistics != null) {
        emit(UserProfileLoaded(
          userData: _userData!,
          statistics: _statistics!,
          telegrams: _telegrams,
          hasMore: _hasMore,
        ));
      }
      
    } catch (e) {
      _isLoadingMore = false;
      _currentPage--;
      print('❌ Error loading more telegrams: $e');
      
      // ✅ الرجوع للحالة السابقة مع الخطأ
      if (_userData != null && _statistics != null) {
        emit(UserProfileErrorLoadingMore(
          userData: _userData!,
          statistics: _statistics!,
          telegrams: _telegrams,
          hasMore: _hasMore,
          error: e.toString(),
        ));
      }
    }
  }

  Future<void> toggleFollow() async {
    try {
      if (_userData == null) return;
      
      final oldFollowingState = _userData!.isFollowing;
      
      print('🔄 Toggling follow: ${oldFollowingState ? 'Unfollow' : 'Follow'} user ${_userData!.id}');
      
      // ✅ تحديث محلي أولاً
      _userData = _userData!.copyWith(isFollowing: !oldFollowingState);
      
      if (oldFollowingState) {
        _statistics = ProfileStatistics(
          followersCount: _statistics!.followersCount - 1,
          followingCount: _statistics!.followingCount,
          telegramsCount: _statistics!.telegramsCount,
        );
        await _repository.unfollowUser(_userData!.id);
        print('✅ Unfollowed user ${_userData!.id}');
      } else {
        _statistics = ProfileStatistics(
          followersCount: _statistics!.followersCount + 1,
          followingCount: _statistics!.followingCount,
          telegramsCount: _statistics!.telegramsCount,
        );
        await _repository.followUser(_userData!.id);
        print('✅ Followed user ${_userData!.id}');
      }
      
      if (state is UserProfileLoaded) {
        emit(UserProfileLoaded(
          userData: _userData!,
          statistics: _statistics!,
          telegrams: _telegrams,
          hasMore: _hasMore,
        ));
      }
      
      // ✅ تحديث التخزين المؤقت
      await _saveToCache(_userData!.id);
      
    } catch (e) {
      print('❌ Error toggling follow: $e');
      
      // ✅ التراجع عن التغيير
      if (_userData != null) {
        _userData = _userData!.copyWith(isFollowing: !_userData!.isFollowing);
        
        if (state is UserProfileLoaded) {
          emit(UserProfileLoaded(
            userData: _userData!,
            statistics: _statistics!,
            telegrams: _telegrams,
            hasMore: _hasMore,
          ));
        }
      }
    }
  }

  // ✅ دالة للتحقق من وجود بيانات مخزنة
  Future<bool> _hasValidCache(String userId) async {
    try {
      await _storageService.ensureInitialized();
      final cachedTimestamp = await _storageService.readSecureData('${_cachedProfileKey}timestamp_$userId');
      
      if (cachedTimestamp == null) return false;
      
      final timestamp = DateTime.tryParse(cachedTimestamp);
      if (timestamp == null) return false;
      
      final now = DateTime.now();
      final isValid = now.difference(timestamp) < _cacheDuration;
      
      print('🔍 Cache for user $userId is ${isValid ? 'valid' : 'expired'}');
      return isValid;
    } catch (e) {
      print('❌ Error checking cache validity: $e');
      return false;
    }
  }

  // ✅ دالة لتحميل البيانات من التخزين
  Future<void> _loadFromCache(String userId) async {
    try {
      await _storageService.ensureInitialized();
      
      print('📂 Loading cached profile for user $userId');
      
      final profileJson = await _storageService.readSecureData('${_cachedProfileKey}profile_$userId');
      final telegramsJson = await _storageService.readSecureData('${_cachedTelegramsKey}telegrams_$userId');
      final statsJson = await _storageService.readSecureData('${_cachedProfileKey}stats_$userId');
      
      if (profileJson != null && statsJson != null) {
        final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
        final statsData = jsonDecode(statsJson) as Map<String, dynamic>;
        
        _userData = UserData.fromJson(profileData);
        _statistics = ProfileStatistics.fromJson(statsData);
        
        if (telegramsJson != null) {
          final telegramsList = (jsonDecode(telegramsJson) as List).cast<Map<String, dynamic>>();
          _telegrams = telegramsList.map((item) => FeedItem.fromJson(item)).toList();
          print('📦 Loaded ${_telegrams.length} telegrams from cache');
        }
        
        // ✅ تحديث معلومات الصفحات بناءً على البيانات المخزنة
        _hasMore = _telegrams.length >= 10; // إذا كان لدينا 10 برقيات أو أكثر، فمن المحتمل أن يكون هناك المزيد
        
        print('✅ Cached profile loaded successfully for user $userId');
        
        emit(UserProfileLoaded(
          userData: _userData!,
          statistics: _statistics!,
          telegrams: _telegrams,
          hasMore: _hasMore,
        ));
      } else {
        print('⚠️ No cached data found for user $userId');
      }
    } catch (e) {
      print('❌ Error loading from cache: $e');
      emit(UserProfileError(error: 'Failed to load cached data'));
    }
  }

  // ✅ دالة لحفظ البيانات في التخزين
  Future<void> _saveToCache(String userId) async {
    try {
      await _storageService.ensureInitialized();
      
      if (_userData != null && _statistics != null) {
        final profileJson = jsonEncode(_userData!.toJson());
        final statsJson = jsonEncode({
          'followers_count': _statistics!.followersCount,
          'following_count': _statistics!.followingCount,
          'telegrams_count': _statistics!.telegramsCount,
        });
        
        await _storageService.writeSecureData('${_cachedProfileKey}profile_$userId', profileJson);
        await _storageService.writeSecureData('${_cachedProfileKey}stats_$userId', statsJson);
        await _storageService.writeSecureData('${_cachedProfileKey}timestamp_$userId', DateTime.now().toIso8601String());
        
        if (_telegrams.isNotEmpty) {
          final telegramsJson = jsonEncode(_telegrams.map((item) => item.toJson()).toList());
          await _storageService.writeSecureData('${_cachedTelegramsKey}telegrams_$userId', telegramsJson);
        }
        
        print('💾 User profile cached for user $userId');
      }
    } catch (e) {
      print('❌ Error saving to cache: $e');
    }
  }

  // ✅ دالة لمسح التخزين المؤقت
  Future<void> _clearCache(String userId) async {
    try {
      await _storageService.deleteSecureData('${_cachedProfileKey}profile_$userId');
      await _storageService.deleteSecureData('${_cachedProfileKey}stats_$userId');
      await _storageService.deleteSecureData('${_cachedProfileKey}timestamp_$userId');
      await _storageService.deleteSecureData('${_cachedTelegramsKey}telegrams_$userId');
      print('🗑️ Cache cleared for user $userId');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  // ✅ دالة لإعادة تعيين الحالة
  void reset() {
    _currentPage = 1;
    _totalPages = 1;
    _isLoadingMore = false;
    _hasMore = true;
    _userData = null;
    _statistics = null;
    _telegrams.clear();
    emit(UserProfileInitial());
  }

  // ✅ جتتر للتحقق من حالة التحميل
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  UserData? get userData => _userData;
  List<FeedItem> get telegrams => _telegrams;
}