// lib/data/models/user_model.dart
import 'dart:convert';

class UserModel {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String? phone;
  final String? bio;
  final String? image;
  final String? cover;
  final String? zodiac;
  final String? zodiacDescription;
  final bool shareLocation;
  final bool shareZodiac;
  final String? birthdate;
  final String? country;
  final bool isVerified;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // أضف هذه الحقول الجديدة ↓↓↓
  final String? username;
  final int boltCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  
  UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.phone,
    this.bio,
    this.image,
    this.cover,
    this.zodiac,
    this.zodiacDescription,
    required this.shareLocation,
    required this.shareZodiac,
    this.birthdate,
    this.country,
    required this.isVerified,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    
    // قيم افتراضية للحقول الجديدة
    this.username,
    this.boltCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      bio: json['bio'],
      image: json['image'],
      cover: json['cover'],
      zodiac: json['zodiac'],
      zodiacDescription: json['zodiac_description'],
      shareLocation: (json['share_location'] ?? 0) == 1,
      shareZodiac: (json['share_zodiac'] ?? 0) == 1,
      birthdate: json['birthdate'],
      country: json['country'],
      isVerified: (json['is_verified'] ?? 0) == 1,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      
      // الحقول الجديدة
      username: json['username'] ?? json['email']?.split('@').first ?? 'user_${json['id']}',
      boltCount: json['bolt_count'] ?? json['telegrams_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      isFollowing: json['is_following'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'bio': bio,
      'image': image,
      'cover': cover,
      'zodiac': zodiac,
      'zodiac_description': zodiacDescription,
      'share_location': shareLocation ? 1 : 0,
      'share_zodiac': shareZodiac ? 1 : 0,
      'birthdate': birthdate,
      'country': country,
      'is_verified': isVerified ? 1 : 0,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'username': username,
      'bolt_count': boltCount,
      'followers_count': followersCount,
      'following_count': followingCount,
      'is_following': isFollowing,
    };
  }
  
  // getter للاسم الكامل
  String get name => '$firstname $lastname';
  
  // getter لـ imageUrl (اسم مختلف للحفاظ على التوافق)
  String? get imageUrl => image;
}