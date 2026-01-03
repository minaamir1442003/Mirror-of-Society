part of 'repost_cubit.dart';

abstract class RepostState {
  const RepostState();
}

class RepostInitial extends RepostState {}
class RepostLoading extends RepostState {}
class RepostLoadingMore extends RepostState {
  final List<RepostModel> reposts;
  const RepostLoadingMore({required this.reposts});
}
class RepostToggling extends RepostState {}
class RepostToggledSuccess extends RepostState {}
class RepostsLoaded extends RepostState {
  final List<RepostModel> reposts;
  final bool hasMore;
  const RepostsLoaded({
    required this.reposts,
    required this.hasMore,
  });
}
class RepostError extends RepostState {
  final String error;
  const RepostError({required this.error});
}