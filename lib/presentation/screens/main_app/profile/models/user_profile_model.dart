// lib/presentation/screens/main_app/profile/models/user_profile_model.dart
import 'dart:convert';

class UserProfileModel {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String rank;
  final String phone;
  final String bio;
  final String image;
  final String cover;
  final String zodiac;
  final String zodiacIcon; // ✅ إضافة هذا الحقل الجديد
  final String zodiacDescription;
  final bool shareLocation;
  final bool shareZodiac;
  final DateTime birthdate;
  final String country;
  final List<InterestModel> interests;
  final ProfileStatistics statistics;
  final List<TelegramModel> telegrams;

  UserProfileModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.rank,
    required this.phone,
    required this.bio,
    required this.image,
    required this.cover,
    required this.zodiac,
    required this.zodiacIcon, // ✅ إضافة هذا
    required this.zodiacDescription,
    required this.shareLocation,
    required this.shareZodiac,
    required this.birthdate,
    required this.country,
    required this.interests,
    required this.statistics,
    required this.telegrams,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? {};
    final telegramsData = json['telegrams'] ?? {};

    return UserProfileModel(
      id: userData['id'] ?? 0,
      firstname: userData['firstname'] ?? '',
      lastname: userData['lastname'] ?? '',
      email: userData['email'] ?? '',
      rank: (userData['rank'] ?? '0').toString(),
      phone: userData['phone'] ?? '',
      bio: userData['bio'] ?? '',
      image: userData['image'] ?? '',
      cover: userData['cover'] ?? '',
      zodiac: userData['zodiac'] ?? '',
      zodiacIcon: userData['zodiac_icon'] ?? '', // ✅ إضافة هذا
      zodiacDescription: userData['zodiac_description'] ?? '',
      shareLocation: userData['share_location'] ?? false,
      shareZodiac: userData['share_zodiac'] ?? false,
      birthdate:
          userData['birthdate'] != null
              ? DateTime.parse(userData['birthdate'])
              : DateTime.now(),
      country: userData['country'] ?? '',
      interests:
          (userData['interests'] as List<dynamic>?)
              ?.map((interest) => InterestModel.fromJson(interest))
              .toList() ??
          [],
      statistics: ProfileStatistics.fromJson(json['statistics'] ?? {}),
      telegrams:
          (telegramsData['data'] as List<dynamic>?)
              ?.map((telegram) => TelegramModel.fromJson(telegram))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'rank': rank,
      'phone': phone,
      'bio': bio,
      'image': image,
      'cover': cover,
      'zodiac': zodiac,
      'zodiac_icon': zodiacIcon, // ✅ إضافة هذا
      'zodiac_description': zodiacDescription,
      'share_location': shareLocation,
      'share_zodiac': shareZodiac,
      'birthdate': birthdate.toIso8601String(),
      'country': country,
      'interests': interests.map((interest) => interest.toJson()).toList(),
      'statistics': statistics.toJson(),
      'telegrams': {
        'data': telegrams.map((telegram) => telegram.toJson()).toList(),
      },
    };
  }

  UserProfileModel copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? email,
    String? rank,
    String? phone,
    String? bio,
    String? image,
    String? cover,
    String? zodiac,
    String? zodiacIcon, // ✅ إضافة هذا
    String? zodiacDescription,
    bool? shareLocation,
    bool? shareZodiac,
    DateTime? birthdate,
    String? country,
    List<InterestModel>? interests,
    ProfileStatistics? statistics,
    List<TelegramModel>? telegrams,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      rank: rank ?? this.rank,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      image: image ?? this.image,
      cover: cover ?? this.cover,
      zodiac: zodiac ?? this.zodiac,
      zodiacIcon: zodiacIcon ?? this.zodiacIcon, // ✅ إضافة هذا
      zodiacDescription: zodiacDescription ?? this.zodiacDescription,
      shareLocation: shareLocation ?? this.shareLocation,
      shareZodiac: shareZodiac ?? this.shareZodiac,
      birthdate: birthdate ?? this.birthdate,
      country: country ?? this.country,
      interests: interests ?? this.interests,
      statistics: statistics ?? this.statistics,
      telegrams: telegrams ?? this.telegrams,
    );
  }

  String get fullName => '$firstname $lastname';
  String get username =>
      '@${firstname.toLowerCase()}_${lastname.toLowerCase()}';

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class InterestModel {
  final int id;
  final String name;
  final String color;
  final String? icon;

  InterestModel({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
  });

  factory InterestModel.fromJson(Map<String, dynamic> json) {
    return InterestModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'] ?? '#007bff',
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'color': color, 'icon': icon};
  }
}

class ProfileStatistics {
  final int followersCount;
  final int followingCount;
  final int telegramsCount;

  ProfileStatistics({
    required this.followersCount,
    required this.followingCount,
    required this.telegramsCount,
  });

  factory ProfileStatistics.fromJson(Map<String, dynamic> json) {
    return ProfileStatistics(
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      telegramsCount: json['telegrams_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followers_count': followersCount,
      'following_count': followingCount,
      'telegrams_count': telegramsCount,
    };
  }
}

class TelegramModel {
  final String id;
  final String type;
  final String feedAt;
  final int number;
  final String content;
  final bool isAd; // ✅ هذا الحقل موجود
  final TelegramUser user;
  final CategoryModel category;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final bool isLiked;
  final bool isReposted;

  TelegramModel({
    required this.id,
    required this.type,
    required this.feedAt,
    required this.number,
    required this.content,
    required this.isAd,
    required this.user,
    required this.category,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.repostsCount,
    required this.isLiked,
    required this.isReposted,
  });

  factory TelegramModel.fromJson(Map<String, dynamic> json) {
    return TelegramModel(
      id: json['id'].toString(),
      type: json['type'] ?? 'post',
      feedAt: json['feed_at'] ?? '',
      number: json['number'] ?? 0,
      content: json['content'] ?? '',
      isAd: json['is_ad'] ?? false,
      user: TelegramUser.fromJson(json['user'] ?? {}),
      category: CategoryModel.fromJson(json['category'] ?? {}),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      repostsCount: json['reposts_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isReposted: json['is_reposted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'feed_at': feedAt,
      'number': number,
      'content': content,
      'is_ad': isAd,
      'user': user.toJson(),
      'category': category.toJson(),
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'reposts_count': repostsCount,
      'is_liked': isLiked,
      'is_reposted': isReposted,
    };
  }

  bool get isPost => type == 'post';
  bool get isRepost => type == 'repost';
  bool get isAdPost => isAd;
}

class TelegramUser {
  final int id;
  final String name;
  final String image;
  final String rank;

  TelegramUser({
    required this.id,
    required this.name,
    required this.image,
    required this.rank,
  });

  factory TelegramUser.fromJson(Map<String, dynamic> json) {
    return TelegramUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      rank: (json['rank'] ?? '0').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image': image, 'rank': rank};
  }
}

class CategoryModel {
  final int id;
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'] ?? '#007bff',
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'color': color, 'icon': icon};
  }
}