// lib/presentation/screens/auth/forgetpassword/model/reset_password_model.dart
class ResetPasswordResponse {
  final bool status;
  final String message;

  ResetPasswordResponse({
    required this.status,
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}