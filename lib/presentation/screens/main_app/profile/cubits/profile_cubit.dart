// lib/presentation/screens/main_app/profile/cubits/profile_cubit.dart
import 'package:app_1/presentation/screens/main_app/profile/models/user_profile_model.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isInitialLoadDone = false;
  List<TelegramModel> _allTelegrams = [];
  UserProfileModel? _currentProfile;
  
  // ✅ إضافة هذا المتغير لمنع التحميل المتكرر
  bool _isLoading = false;
  
  int? _cachedUserId;
  bool _isMyProfile = true;

  ProfileCubit({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ProfileInitial());

  Future<void> getMyProfile({bool loadMore = false}) async {
    // ✅ منع التحميل إذا كان جارياً بالفعل
    if (_isLoading && !loadMore) {
      print('⏸️ ProfileCubit: Loading already in progress, skipping...');
      return;
    }
    
    // ✅ إذا كان البروفايل محملاً ولا نحتاج تحميل إضافي
    if (_isInitialLoadDone && _isMyProfile && !loadMore && _currentProfile != null) {
      print('📱 ProfileCubit: Using cached data, no reload needed');
      emit(ProfileLoaded(profile: _currentProfile!));
      return;
    }

    try {
      // ✅ وضع علامة أن التحميل جاري
      _isLoading = true;

      if (!loadMore) {
        // فقط إذا كان هذا ليس تحميل إضافي ولم يكن هناك بيانات
        if (!_isInitialLoadDone || !_isMyProfile || _currentProfile == null) {
          _currentPage = 1;
          _hasMore = true;
          _allTelegrams = [];
          _currentProfile = null;
          _cachedUserId = null;
          _isMyProfile = true;
          emit(ProfileLoading());
        } else {
          // لدينا بيانات مسبقاً، نعرضها
          print('📱 ProfileCubit: Already have data, showing...');
          emit(ProfileLoaded(profile: _currentProfile!));
          _isLoading = false;
          return;
        }
      } else {
        // تحميل إضافي
        if (!_hasMore) {
          print('⚠️ No more data to load');
          _isLoading = false;
          return;
        }
        emit(ProfileLoadingMore(telegrams: _allTelegrams));
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

      final newTelegrams = response.data.telegrams;
      _allTelegrams.addAll(newTelegrams);
      print('📦 Total telegrams now: ${_allTelegrams.length}');

      if (_currentProfile == null) {
        _currentProfile = response.data.copyWith(
          telegrams: _allTelegrams,
        );
      } else {
        _currentProfile = _currentProfile!.copyWith(
          telegrams: _allTelegrams,
        );
      }

      if (_hasMore) {
        _currentPage++;
        print('⬆️ Next page will be: $_currentPage');
      }

      _isInitialLoadDone = true;
      _isLoading = false;
      emit(ProfileLoaded(profile: _currentProfile!));
    } catch (e) {
      print('❌ Error loading profile: $e');
      _isLoading = false;
      
      if (_allTelegrams.isNotEmpty && _currentProfile != null) {
        emit(ProfileLoaded(profile: _currentProfile!));
      } else {
        emit(ProfileError(error: e.toString()));
      }
    }
  }

  Future<void> getUserProfile(int userId, {bool loadMore = false}) async {
    // ✅ منع التحميل إذا كان جارياً بالفعل
    if (_isLoading && !loadMore) {
      print('⏸️ ProfileCubit: Loading already in progress, skipping...');
      return;
    }
    
    // ✅ إذا كان هذا هو نفس البروفايل الموجود في الكاش ولا نحتاج لتحميله من جديد
    if (_isInitialLoadDone && _cachedUserId == userId && !loadMore && _currentProfile != null) {
      print('📱 ProfileCubit: Using cached user profile data for user $userId');
      emit(ProfileLoaded(profile: _currentProfile!));
      return;
    }

    try {
      _isLoading = true;

      if (!loadMore) {
        // فقط إذا كان هذا ليس تحميل إضافي ولم يكن هناك بيانات لهذا المستخدم
        if (_cachedUserId != userId || _currentProfile == null) {
          _currentPage = 1;
          _hasMore = true;
          _allTelegrams = [];
          _currentProfile = null;
          _cachedUserId = userId;
          _isMyProfile = false;
          emit(ProfileLoading());
        } else {
          // لدينا بيانات مسبقاً، نعرضها
          print('📱 ProfileCubit: Already have data for user $userId, showing...');
          emit(ProfileLoaded(profile: _currentProfile!));
          _isLoading = false;
          return;
        }
      } else {
        if (!_hasMore) {
          print('⚠️ No more data to load');
          _isLoading = false;
          return;
        }
        emit(ProfileLoadingMore(telegrams: _allTelegrams));
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

      _allTelegrams.addAll(response.data.telegrams);
      
      if (_currentProfile == null) {
        _currentProfile = response.data.copyWith(
          telegrams: _allTelegrams,
        );
      } else {
        _currentProfile = _currentProfile!.copyWith(
          telegrams: _allTelegrams,
        );
      }

      if (_hasMore) {
        _currentPage++;
      }

      _isInitialLoadDone = true;
      _isLoading = false;
      emit(ProfileLoaded(profile: _currentProfile!));
    } catch (e) {
      print('❌ Error loading user profile: $e');
      _isLoading = false;
      
      if (_allTelegrams.isNotEmpty && _currentProfile != null) {
        emit(ProfileLoaded(profile: _currentProfile!));
      } else {
        emit(ProfileError(error: e.toString()));
      }
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    emit(ProfileUpdating());
    try {
      final response = await _profileRepository.updateProfile(data);
      
      _currentProfile = response.data.copyWith(
        telegrams: _allTelegrams,
      );
      
      _cachedUserId = _currentProfile!.id;
      _isMyProfile = true;
      
      emit(ProfileUpdated(profile: _currentProfile!));
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }

  void clearProfile() {
    _currentPage = 1;
    _hasMore = true;
    _isInitialLoadDone = false;
    _allTelegrams = [];
    _currentProfile = null;
    _cachedUserId = null;
    _isMyProfile = true;
    emit(ProfileInitial());
  }

  // ✅ دالة لتفريغ الكاش فقط (بدون إعادة تحميل)
  void clearCache() {
    _currentPage = 1;
    _hasMore = true;
    _isInitialLoadDone = false;
    _allTelegrams = [];
    _currentProfile = null;
    _cachedUserId = null;
    _isMyProfile = true;
    // ✅ لا نرسل أي state هنا
  }

  void clearAllData() {
    print('🧹 ProfileCubit: Clearing ALL data for logout...');
    
    _currentPage = 1;
    _hasMore = true;
    _isInitialLoadDone = false;
    _allTelegrams = [];
    _currentProfile = null;
    _cachedUserId = null;
    _isMyProfile = true;
    _isLoading = false;
    
    emit(ProfileInitial());
    
    print('✅ ProfileCubit: All data cleared successfully');
  }

  // دالة للتحقق إذا كان البروفايل محملاً
  bool get isProfileLoaded => _isInitialLoadDone && _currentProfile != null;
  
  // دالة للتحقق إذا كان هناك المزيد للتحميل
  bool get hasMore => _hasMore;
  
  // دالة للحصول على عدد البرقيات الحالي
  int get telegramsCount => _allTelegrams.length;
  
  // دالة للحصول على البروفايل الحالي من الكاش
  UserProfileModel? get cachedProfile => _currentProfile;
}