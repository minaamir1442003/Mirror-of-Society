part of 'like_cubit.dart';

abstract class LikeState {
  const LikeState();
}

class LikeInitial extends LikeState {}
class LikeLoading extends LikeState {}
class LikeLoadingMore extends LikeState {
  final List<LikeModel> likes;
  const LikeLoadingMore({required this.likes});
}
class LikeToggling extends LikeState {}
class LikeToggledSuccess extends LikeState {}
class LikesLoaded extends LikeState {
  final List<LikeModel> likes;
  final bool hasMore;
  const LikesLoaded({
    required this.likes,
    required this.hasMore,
  });
}
class LikeError extends LikeState {
  final String error;
  const LikeError({required this.error});
}