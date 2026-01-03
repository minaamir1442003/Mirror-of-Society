class Telegram {
  final int id;
  final String content;
  final int categoryId;
  final bool isAd;
  final DateTime? createdAt;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final Map<String, dynamic>? author;
  final Map<String, dynamic>? category;

  Telegram({
    required this.id,
    required this.content,
    required this.categoryId,
    this.isAd = false,
    this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.author,
    this.category,
  });

  factory Telegram.fromJson(Map<String, dynamic> json) {
    return Telegram(
      id: json['id'] as int,
      content: json['content'] as String? ?? '',
      categoryId: json['category_id'] as int? ?? 0,
      isAd: json['is_ad'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      repostsCount: json['reposts_count'] as int? ?? 0,
      author: json['author'] as Map<String, dynamic>?,
      category: json['category'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'category_id': categoryId,
      'is_ad': isAd,
      'created_at': createdAt?.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'reposts_count': repostsCount,
      'author': author,
      'category': category,
    };
  }

  // ✅ إضافة دالة للتحويل إلى Map بسيط للتحديث
  Map<String, dynamic> toUpdateJson() {
    return {
      'id': id,
      'content': content,
      'category_id': categoryId,
      'is_ad': isAd,
    };
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String color;
  final String? icon;
  final int telegramsCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.telegramsCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String?,
      telegramsCount: json['telegrams_count'] as int? ?? 0,
    );
  }
}