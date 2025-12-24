class VerificationRequest {
  final String message;

  VerificationRequest({required this.message});

  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      message: json['message'] ?? '',
    );
  }
}

class VerificationResponse {
  final bool status;
  final String message;
  final Map<String, dynamic>? data;

  VerificationResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}