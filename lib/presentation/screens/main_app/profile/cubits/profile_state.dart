// lib/presentation/cubits/profile/profile_state.dart
part of 'profile_cubit.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoadingMore extends ProfileState {
  final List<TelegramModel> telegrams;
  const ProfileLoadingMore({required this.telegrams});
}
class ProfileLoaded extends ProfileState {
  final UserProfileModel profile;
  const ProfileLoaded({required this.profile});
}
class ProfileUpdating extends ProfileState {}
class ProfileUpdated extends ProfileState {
  final UserProfileModel profile;
  const ProfileUpdated({required this.profile});
}
class ProfileError extends ProfileState {
  final String error;
  const ProfileError({required this.error});
}