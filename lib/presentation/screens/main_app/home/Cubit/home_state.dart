part of 'home_cubit.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoadingMore extends HomeState {
  final List<FeedItem> feedItems;
  const HomeLoadingMore({required this.feedItems});
}

class HomeLoaded extends HomeState {
  final List<FeedItem> feedItems;
  final List<OnThisDayEvent> onThisDayEvents;
  final bool hasMore;
  
  const HomeLoaded({
    required this.feedItems,
    required this.onThisDayEvents,
    required this.hasMore,
  });
}

class HomeError extends HomeState {
  final String error;
  const HomeError({required this.error});
}