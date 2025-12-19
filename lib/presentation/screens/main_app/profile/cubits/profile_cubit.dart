import 'package:app_1/presentation/screens/main_app/profile/models/user_profile_model.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFirstLoad = true;
  List<TelegramModel> _allTelegrams = [];
  UserProfileModel? _currentProfile;

  ProfileCubit({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ProfileInitial());

  Future<void> getMyProfile({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        // أول تحميل
        _currentPage = 1;
        _hasMore = true;
        _isFirstLoad = true;
        _allTelegrams = [];
        _currentProfile = null;
        emit(ProfileLoading());
      } else {
        // تحميل إضافي
        if (!_hasMore) {
          print('⚠️ No more data to load');
          return;
        }
        emit(ProfileLoadingMore(telegrams: _allTelegrams));
      }

      print('📡 Loading profile page $_currentPage');
      final response = await _profileRepository.getMyProfile(page: _currentPage);
      
      // تحقق من الرد
      print('✅ Received ${response.data.telegrams.length} telegrams');
      
      // تحديث معلومات Pagination
      if (response.pagination != null) {
        _hasMore = response.pagination!.hasMore;
        print('📊 Pagination: current=${response.pagination!.currentPage}, '
              'last=${response.pagination!.lastPage}, '
              'hasMore=$_hasMore');
      } else {
        // إذا مفيش pagination info
        _hasMore = response.data.telegrams.isNotEmpty;
        print('⚠️ No pagination info, assuming hasMore=$_hasMore');
      }

      // إضافة البرقيات الجديدة
      final newTelegrams = response.data.telegrams;
      _allTelegrams.addAll(newTelegrams);
      print('📦 Total telegrams now: ${_allTelegrams.length}');

      // تحديث الـ Profile
      if (_currentProfile == null) {
        _currentProfile = response.data.copyWith(
          telegrams: _allTelegrams,
        );
      } else {
        _currentProfile = _currentProfile!.copyWith(
          telegrams: _allTelegrams,
        );
      }

      // زيادة رقم الصفحة
      if (_hasMore) {
        _currentPage++;
        print('⬆️ Next page will be: $_currentPage');
      }

      _isFirstLoad = false;
      emit(ProfileLoaded(profile: _currentProfile!));
    } catch (e) {
      print('❌ Error loading profile: $e');
      if (_allTelegrams.isNotEmpty) {
        // إذا كان هناك خطأ ولكن لدينا بيانات، نعرضها
        emit(ProfileLoaded(profile: _currentProfile!));
      } else {
        emit(ProfileError(error: e.toString()));
      }
    }
  }

  Future<void> getUserProfile(int userId, {bool loadMore = false}) async {
    try {
      if (!loadMore) {
        _currentPage = 1;
        _hasMore = true;
        _isFirstLoad = true;
        _allTelegrams = [];
        _currentProfile = null;
        emit(ProfileLoading());
      } else {
        if (!_hasMore) {
          print('⚠️ No more data to load');
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

      _isFirstLoad = false;
      emit(ProfileLoaded(profile: _currentProfile!));
    } catch (e) {
      print('❌ Error loading user profile: $e');
      if (_allTelegrams.isNotEmpty) {
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
      
      emit(ProfileUpdated(profile: _currentProfile!));
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }

  void clearProfile() {
    _currentPage = 1;
    _hasMore = true;
    _isFirstLoad = true;
    _allTelegrams = [];
    _currentProfile = null;
    emit(ProfileInitial());
  }

  // دالة للتحقق إذا كان هذا أول تحميل
  bool get isFirstLoad => _isFirstLoad;
  
  // دالة للتحقق إذا كان هناك المزيد للتحميل
  bool get hasMore => _hasMore;
  
  // دالة للحصول على عدد البرقيات الحالي
  int get telegramsCount => _allTelegrams.length;
}