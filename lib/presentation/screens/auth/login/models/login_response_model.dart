// lib/data/models/auth_response_model.dart
class LoginResponseModel {
  final bool status;
  final String message;
  final String token;
  final UserData? data;

  LoginResponseModel({
    required this.status,
    required this.message,
    required this.token, // ✅ إضافة token هنا مباشرة
    this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '', // ✅ قراءة token مباشرة من الـ JSON
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }
}

class UserData {
  final String token;
  final User user;

  UserData({
    required this.token,
    required this.user,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? image;
  final String? bio;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.image,
    this.bio,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      image: json['image'],
      bio: json['bio'],
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'bio': bio,
      'is_verified': isVerified,
    };
  }
}