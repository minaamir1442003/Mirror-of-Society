part of 'user_profile_cubit.dart';

abstract class UserProfileState {
  const UserProfileState();
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoadingMore extends UserProfileState {
  final UserData userData;
  final ProfileStatistics statistics;
  final List<FeedItem> telegrams;
  final bool hasMore;

  const UserProfileLoadingMore({
    required this.userData,
    required this.statistics,
    required this.telegrams,
    required this.hasMore,
  });
}

class UserProfileLoaded extends UserProfileState {
  final UserData userData;
  final ProfileStatistics statistics;
  final List<FeedItem> telegrams;
  final bool hasMore;

  const UserProfileLoaded({
    required this.userData,
    required this.statistics,
    required this.telegrams,
    required this.hasMore,
  });
}

// ✅ إضافة حالة جديدة لخطأ أثناء تحميل المزيد
class UserProfileErrorLoadingMore extends UserProfileState {
  final UserData userData;
  final ProfileStatistics statistics;
  final List<FeedItem> telegrams;
  final bool hasMore;
  final String error;

  const UserProfileErrorLoadingMore({
    required this.userData,
    required this.statistics,
    required this.telegrams,
    required this.hasMore,
    required this.error,
  });
}

class UserProfileError extends UserProfileState {
  final String error;

  const UserProfileError({required this.error});
}