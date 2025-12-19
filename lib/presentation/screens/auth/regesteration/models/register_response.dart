import 'package:app_1/data/models/user_model.dart';

class RegisterResponse {
  final bool status;
  final String message;
  final String token;
  final UserModel user;
  
  RegisterResponse({
    required this.status,
    required this.message,
    required this.token,
    required this.user,
  });
  
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 Register Response JSON: $json');
    
    // Response comes without 'data' key based on your Postman test
    return RegisterResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',  // مباشرة من الـ JSON
      user: UserModel.fromJson({
        'id': 0, // Backend doesn't return user in response
        'firstname': '', // Will be filled from request
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