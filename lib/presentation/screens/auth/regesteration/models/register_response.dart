import 'package:app_1/data/models/user_model.dart';

class RegisterResponse {
  final bool status;
  final String message;
  final String token;
  final UserModel user;
  final Map<String, dynamic>? errorData;
  
  RegisterResponse({
    required this.status,
    required this.message,
    required this.token,
    required this.user,
    this.errorData,
  });
  
  // Factory method للنجاح
  factory RegisterResponse.success({
    required bool status,
    required String message,
    required String token,
    required UserModel user,
  }) {
    return RegisterResponse(
      status: status,
      message: message,
      token: token,
      user: user,
      errorData: null,
    );
  }
  
  // Factory method للفشل
  factory RegisterResponse.failure({
    required String message,
    Map<String, dynamic>? errorData,
  }) {
    return RegisterResponse(
      status: false,
      message: message,
      token: '',
      errorData: errorData,
      user: UserModel.fromJson({
        'id': 0,
        'firstname': '',
        'lastname': '',
        'email': '',
        'phone': '',
        'bio': '',
        'zodiac': '',
        'zodiac_description': '',
        'share_location': 0,
        'share_zodiac': 0,
        'birthdate': '',
        'country': '',
        'is_verified': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );
  }
  
  // Factory method من JSON
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      errorData: json['errors'] as Map<String, dynamic>?,
      user: UserModel.fromJson({
        'id': 0,
        'firstname': '',
        'lastname': '',
        'email': json['email'] ?? '',
        'phone': '',
        'bio': '',
        'zodiac': '',
        'zodiac_description': '',
        'share_location': 0,
        'share_zodiac': 0,
        'birthdate': '',
        'country': '',
        'is_verified': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );
  }
}