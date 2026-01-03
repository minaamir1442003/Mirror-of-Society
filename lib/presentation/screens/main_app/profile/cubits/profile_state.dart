// lib/presentation/screens/main_app/profile/cubits/profile_state.dart
part of 'profile_cubit.dart';

abstract class ProfileState {
  final UserProfileModel? lastValidProfile;
  
  const ProfileState({this.lastValidProfile});
}

class ProfileInitial extends ProfileState {
  const ProfileInitial() : super(lastValidProfile: null);
}

class ProfileLoading extends ProfileState {
  const ProfileLoading({UserProfileModel? lastValidProfile}) 
      : super(lastValidProfile: lastValidProfile);
}

class ProfileLoadingMore extends ProfileState {
  final List<TelegramModel> telegrams;
  
  const ProfileLoadingMore({
    required this.telegrams,
    UserProfileModel? lastValidProfile,
  }) : super(lastValidProfile: lastValidProfile);
}

class ProfileLoaded extends ProfileState {
  final UserProfileModel profile;
  final List<TelegramModel> telegrams;
  
  const ProfileLoaded({
    required this.profile,
    required this.telegrams,
    UserProfileModel? lastValidProfile,
  }) : super(lastValidProfile: lastValidProfile);
}

class ProfileRefreshingWithOverlay extends ProfileState {
  final UserProfileModel profile;
  final List<TelegramModel> telegrams;
  
  const ProfileRefreshingWithOverlay({
    required this.profile,
    required this.telegrams,
    UserProfileModel? lastValidProfile,
  }) : super(lastValidProfile: lastValidProfile);
}

class ProfileUpdated extends ProfileState {
  final UserProfileModel profile;
  final List<TelegramModel> telegrams;
  
  const ProfileUpdated({
    required this.profile,
    required this.telegrams,
    UserProfileModel? lastValidProfile,
  }) : super(lastValidProfile: lastValidProfile);
}

class ProfileError extends ProfileState {
  final String error;
  
  const ProfileError({
    required this.error,
    UserProfileModel? lastValidProfile,
  }) : super(lastValidProfile: lastValidProfile);
}

// ✅ حالة جديدة لإظهار الإعلانات
class ProfileAdShown extends ProfileState {
  final UserProfileModel profile;
  final List<TelegramModel> telegrams;
  final TelegramModel adTelegram;
  
  const ProfileAdShown({
    required this.profile,
    required this.telegrams,
    required this.adTelegram,
    UserProfileModel? lastValidProfile,
  }) : super(lastValidProfile: lastValidProfile);
}