part of 'home_cubit.dart';

abstract class HomeState {
  final String? currentCategoryId;
  final String feedType;
  final List<Category> categories;
  
  const HomeState({
    this.currentCategoryId,
    this.feedType = 'home',
    required this.categories,
  });
}

class HomeInitial extends HomeState {
  const HomeInitial({
    required super.categories,
  }) : super();
}

class HomeLoading extends HomeState {
  const HomeLoading({
    required super.categories,
    String? currentCategoryId,
    String feedType = 'home',
  }) : super(
    currentCategoryId: currentCategoryId,
    feedType: feedType,
  );
}

class HomeLoadingMore extends HomeState {
  final List<FeedItem> feedItems;
  
  const HomeLoadingMore({
    required this.feedItems,
    required super.categories,
    String? currentCategoryId,
    String feedType = 'home',
  }) : super(
    currentCategoryId: currentCategoryId,
    feedType: feedType,
  );
}

class HomeLoaded extends HomeState {
  final List<FeedItem> feedItems;
  final List<OnThisDayEvent> onThisDayEvents;
  final bool hasMore;
  
  const HomeLoaded({
    required this.feedItems,
    required this.onThisDayEvents,
    required this.hasMore,
    required super.categories,
    String? currentCategoryId,
    String feedType = 'home',
  }) : super(
    currentCategoryId: currentCategoryId,
    feedType: feedType,
  );
}

// ✅ أضف هذه الحالة الجديدة
class HomeRefreshingWithOverlay extends HomeState {
  final List<FeedItem> feedItems;
  final List<OnThisDayEvent> onThisDayEvents;
  final bool hasMore;
  
  const HomeRefreshingWithOverlay({
    required this.feedItems,
    required this.onThisDayEvents,
    required this.hasMore,
    required super.categories,
    String? currentCategoryId,
    String feedType = 'home',
  }) : super(
    currentCategoryId: currentCategoryId,
    feedType: feedType,
  );
}

class HomeError extends HomeState {
  final String error;
  final List<FeedItem>? feedItems;
  final List<OnThisDayEvent>? onThisDayEvents;
  final bool? hasMore;
  
  const HomeError({
    required this.error,
    this.feedItems,
    this.onThisDayEvents,
    this.hasMore,
    required super.categories,
    String? currentCategoryId,
    String feedType = 'home',
  }) : super(
    currentCategoryId: currentCategoryId,
    feedType: feedType,
  );
}