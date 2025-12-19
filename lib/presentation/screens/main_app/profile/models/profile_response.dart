import 'package:app_1/presentation/screens/main_app/profile/models/user_profile_model.dart';

class ProfileResponse {
  final bool status;
  final String message;
  final UserProfileModel data;
  final PaginationInfo? pagination;

  ProfileResponse({
    required this.status,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    
    // استخراج معلومات الـ Pagination من المكان الصحيح
    final telegramsData = data['telegrams'] ?? {};
    PaginationInfo? pagination;
    
    if (telegramsData['pagination'] != null) {
      pagination = PaginationInfo.fromJson(telegramsData['pagination']);
    } else if (data['pagination'] != null) {
      pagination = PaginationInfo.fromJson(data['pagination']);
    }
    
    return ProfileResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: UserProfileModel.fromJson(data),
      pagination: pagination,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
      'pagination': pagination?.toJson(),
    };
  }
}

class PaginationInfo {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;

  PaginationInfo({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 1,
      total: json['total'] ?? 0,
      nextPageUrl: json['next_page_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'next_page_url': nextPageUrl,
    };
  }

  bool get hasMore => currentPage < lastPage;
}