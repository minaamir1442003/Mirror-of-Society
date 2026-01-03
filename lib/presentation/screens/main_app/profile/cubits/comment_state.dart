// lib/presentation/screens/main_app/profile/cubits/comment_state.dart
part of 'comment_cubit.dart';

abstract class CommentState {
  const CommentState();
}

class CommentInitial extends CommentState {}
class CommentLoading extends CommentState {}
class CommentLoadingMore extends CommentState {
  final List<CommentModel> comments;
  const CommentLoadingMore({required this.comments});
}
class CommentAdding extends CommentState {}
class CommentDeleting extends CommentState {}
class CommentsLoaded extends CommentState {
  final List<CommentModel> comments;
  final bool hasMore;
  const CommentsLoaded({
    required this.comments,
    required this.hasMore,
  });
}
class CommentError extends CommentState {
  final String error;
  const CommentError({required this.error});
}