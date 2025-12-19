import 'package:flutter/material.dart';
import 'package:app_1/data/models/bolt_model.dart';

class HomeFeedResponse {
  final bool status;
  final String message;
  final HomeFeedData data;

  HomeFeedResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory HomeFeedResponse.fromJson(Map<String, dynamic> json) {
    return HomeFeedResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: HomeFeedData.fromJson(json['data'] ?? {}),
    );
  }
}

class HomeFeedData {
  final List<FeedItem> feed;
  final List<OnThisDayEvent> onThisDayEvents;
  final PaginationInfo pagination;

  HomeFeedData({
    required this.feed,
    required this.onThisDayEvents,
    required this.pagination,
  });

  factory HomeFeedData.fromJson(Map<String, dynamic> json) {
    final feedData = json['feed'] ?? {};
    final paginationData = feedData['pagination'] ?? {};
    
    return HomeFeedData(
      feed: (feedData['data'] as List<dynamic>?)
          ?.map((item) => FeedItem.fromJson(item))
          .toList() ?? [],
      onThisDayEvents: (json['on_this_day_events'] as List<dynamic>?)
          ?.map((item) => OnThisDayEvent.fromJson(item))
          .toList() ?? [],
      pagination: PaginationInfo.fromJson(paginationData),
    );
  }
}

class FeedItem {
  final String id;
  final String content;
  final String type;
  final DateTime createdAt;
  final TelegramUser user;
  final CategoryModel category;
  final FeedMetrics metrics;
  bool isLiked;
  bool isReposted;

  FeedItem({
    required this.id,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.user,
    required this.category,
    required this.metrics,
    required this.isLiked,
    required this.isReposted,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'].toString(),
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      user: TelegramUser.fromJson(json['user'] ?? {}),
      category: CategoryModel.fromJson(json['category'] ?? {}),
      metrics: FeedMetrics.fromJson(json['metrics'] ?? {}),
      isLiked: json['is_liked'] ?? false,
      isReposted: json['is_reposted'] ?? false,
    );
  }

  FeedItem copyWith({
    String? id,
    String? content,
    String? type,
    DateTime? createdAt,
    TelegramUser? user,
    CategoryModel? category,
    FeedMetrics? metrics,
    bool? isLiked,
    bool? isReposted,
  }) {
    return FeedItem(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      category: category ?? this.category,
      metrics: metrics ?? this.metrics,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
    );
  }

  // ✅ دالة التحويل إلى BoltModel
  BoltModel toBoltModel({
    VoidCallback? onLikePressed,
    VoidCallback? onCommentPressed,
    VoidCallback? onSharePressed,
  }) {
    return BoltModel(
      id: id,
      content: content,
      category: category.name,
      categoryColor: _parseColor(category.color),
      categoryIcon: _getCategoryIcon(category.name),
      createdAt: createdAt,
      userName: user.name,
      userImage: user.image.isNotEmpty ? user.image : "assets/image/images.jpg",
      likes: metrics.likesCount,
      comments: metrics.commentsCount,
      shares: metrics.repostsCount,
      isAd: false,
      isLiked: isLiked,
      isReposted: isReposted,
      userRank: user.rank,
      onLikePressed: onLikePressed,
      onCommentPressed: onCommentPressed,
      onSharePressed: onSharePressed,
    );
  }

  // ✅ دالة مساعدة لتحويل اللون
  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  // ✅ دالة للحصول على الأيقونة المناسبة
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'arts':
        return Icons.palette;
      case 'sports':
        return Icons.sports_soccer;
      case 'technology':
        return Icons.computer;
      case 'movies':
        return Icons.movie;
      case 'fashion':
        return Icons.shopping_bag;
      case 'business':
        return Icons.business;
      case 'health':
        return Icons.health_and_safety;
      case 'travel':
        return Icons.flight;
      case 'science':
        return Icons.science;
      case 'gaming':
        return Icons.games;
      case 'literature':
        return Icons.menu_book;
      default:
        return Icons.category;
    }
  }
}

class TelegramUser {
  final String id;
  final String name;
  final String email;
  final String image;
  final String rank;

  TelegramUser({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.rank,
  });

  factory TelegramUser.fromJson(Map<String, dynamic> json) {
    return TelegramUser(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      rank: json['rank']?.toString() ?? '0',
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String color;
  final String? icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      color: json['color'] ?? '#000000',
      icon: json['icon'],
    );
  }
}

class FeedMetrics {
  final int likesCount;
  final int commentsCount;
  final int repostsCount;

  FeedMetrics({
    required this.likesCount,
    required this.commentsCount,
    required this.repostsCount,
  });

  factory FeedMetrics.fromJson(Map<String, dynamic> json) {
    return FeedMetrics(
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      repostsCount: json['reposts_count'] ?? 0,
    );
  }
}

class OnThisDayEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? imageUrl;

  OnThisDayEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
  });

  factory OnThisDayEvent.fromJson(Map<String, dynamic> json) {
    return OnThisDayEvent(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      imageUrl: json['image_url'],
    );
  }
}

class PaginationInfo {
  final String? nextCursor;
  final String? prevCursor;
  final bool hasMore;

  PaginationInfo({
    this.nextCursor,
    this.prevCursor,
    required this.hasMore,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      nextCursor: json['next_cursor'],
      prevCursor: json['prev_cursor'],
      hasMore: json['has_more'] ?? false,
    );
  }
}