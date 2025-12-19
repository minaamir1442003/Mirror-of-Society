// lib/presentation/screens/auth/otp/model/otp_model.dart
class OtpVerifyResponse {
  final bool status;
  final String message;

  OtpVerifyResponse({
    required this.status,
    required this.message,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class OtpResendResponse {
  final bool status;
  final String message;

  OtpResendResponse({
    required this.status,
    required this.message,
  });

  factory OtpResendResponse.fromJson(Map<String, dynamic> json) {
    return OtpResendResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}