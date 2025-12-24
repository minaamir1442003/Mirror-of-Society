import 'dart:convert';
import 'package:app_1/presentation/screens/main_app/home/models/home_feed_model.dart';

// ========== INTEREST MODEL ==========
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
      color: json['color'] ?? '#000000',
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
    };
  }
}

// ========== USER PROFILE RESPONSE ==========
class UserProfileResponse {
  final bool status;
  final String message;
  final UserProfileData data;

  UserProfileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: UserProfileData.fromJson(json['data'] ?? {}),
    );
  }
}

// ========== USER PROFILE DATA ==========
class UserProfileData {
  final UserData user;
  final ProfileStatistics statistics;
  final UserTelegrams telegrams;

  UserProfileData({
    required this.user,
    required this.statistics,
    required this.telegrams,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      user: UserData.fromJson(json['user'] ?? {}),
      statistics: ProfileStatistics.fromJson(json['statistics'] ?? {}),
      telegrams: UserTelegrams.fromJson(json['telegrams'] ?? {}),
    );
  }
}

// ========== USER DATA ==========
class UserData {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String rank;
  final String? bio;
  final String image;
  final String cover;
  final String? zodiac;
  final String? zodiacDescription;
  final bool shareLocation;
  final bool shareZodiac;
  final DateTime? birthdate;
  final String? country;
  final List<InterestModel> interests; // ✅ صححت النوع هنا
  final bool isFollowing;

  UserData({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.rank,
    this.bio,
    required this.image,
    required this.cover,
    this.zodiac,
    this.zodiacDescription,
    required this.shareLocation,
    required this.shareZodiac,
    this.birthdate,
    this.country,
    required this.interests,
    required this.isFollowing,
  });

  String get fullName => '$firstname $lastname';

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'].toString(),
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      rank: json['rank']?.toString() ?? '0',
      bio: json['bio'],
      image: json['image'] ?? '',
      cover: json['cover'] ?? '',
      zodiac: json['zodiac'],
      zodiacDescription: json['zodiac_description'],
      shareLocation: json['share_location'] ?? false,
      shareZodiac: json['share_zodiac'] ?? false,
      birthdate: json['birthdate'] != null 
          ? DateTime.parse(json['birthdate'])
          : null,
      country: json['country'],
      // ✅ التصحيح هنا: تحويل List<Map> إلى List<InterestModel>
      interests: (json['interests'] as List<dynamic>?)
          ?.map((item) => InterestModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      isFollowing: json['is_following'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'rank': rank,
      'bio': bio,
      'image': image,
      'cover': cover,
      'zodiac': zodiac,
      'zodiac_description': zodiacDescription,
      'share_location': shareLocation,
      'share_zodiac': shareZodiac,
      'birthdate': birthdate?.toIso8601String(),
      'country': country,
      'interests': interests.map((interest) => interest.toJson()).toList(),
      'is_following': isFollowing,
    };
  }

  // ✅ إضافة دالة copyWith
  UserData copyWith({
    String? id,
    String? firstname,
    String? lastname,
    String? email,
    String? rank,
    String? bio,
    String? image,
    String? cover,
    String? zodiac,
    String? zodiacDescription,
    bool? shareLocation,
    bool? shareZodiac,
    DateTime? birthdate,
    String? country,
    List<InterestModel>? interests,
    bool? isFollowing,
  }) {
    return UserData(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      rank: rank ?? this.rank,
      bio: bio ?? this.bio,
      image: image ?? this.image,
      cover: cover ?? this.cover,
      zodiac: zodiac ?? this.zodiac,
      zodiacDescription: zodiacDescription ?? this.zodiacDescription,
      shareLocation: shareLocation ?? this.shareLocation,
      shareZodiac: shareZodiac ?? this.shareZodiac,
      birthdate: birthdate ?? this.birthdate,
      country: country ?? this.country,
      interests: interests ?? this.interests,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

// ========== PROFILE STATISTICS ==========
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
}

// ========== USER TELEGRAMS PAGINATION ==========
class UserTelegramsPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  UserTelegramsPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory UserTelegramsPagination.fromJson(Map<String, dynamic> json) {
    return UserTelegramsPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  bool get hasMore => currentPage < lastPage;
}

// ========== USER TELEGRAMS ==========
class UserTelegrams {
  final List<FeedItem> data;
  final UserTelegramsPagination pagination;

  UserTelegrams({
    required this.data,
    required this.pagination,
  });

  factory UserTelegrams.fromJson(Map<String, dynamic> json) {
    return UserTelegrams(
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => FeedItem.fromJson(item))
          .toList() ?? [],
      pagination: UserTelegramsPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}