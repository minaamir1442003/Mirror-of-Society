// lib/presentation/screens/main_app/profile/cubits/update_profile_state.dart
part of 'update_profile_cubit.dart';

abstract class UpdateProfileState {
  const UpdateProfileState();
}

class UpdateProfileInitial extends UpdateProfileState {}

class UpdateProfileLoading extends UpdateProfileState {}

class UpdateProfileDataLoaded extends UpdateProfileState {
  final List<Map<String, dynamic>> availableInterests;
  final List<Map<String, dynamic>> availableZodiacs;
  
  const UpdateProfileDataLoaded({
    required this.availableInterests,
    required this.availableZodiacs,
  });
}

class UpdateProfileUpdating extends UpdateProfileState {}

class UpdateProfileSuccess extends UpdateProfileState {
  final String message;
  final UserProfileModel? updatedProfile;
  
  const UpdateProfileSuccess({
    required this.message,
    this.updatedProfile,
  });
}

class UpdateProfileError extends UpdateProfileState {
  final String error;
  
  const UpdateProfileError({required this.error});
}