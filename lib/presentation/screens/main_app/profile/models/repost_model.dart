import 'dart:convert';

class RepostModel {
  final int id;
  final RepostUser user;
  final DateTime createdAt;

  RepostModel({
    required this.id,
    required this.user,
    required this.createdAt,
  });

  factory RepostModel.fromJson(Map<String, dynamic> json) {
    return RepostModel(
      id: json['id'] ?? 0,
      user: RepostUser.fromJson(json['user'] ?? {}),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class RepostUser {
  final int id;
  final String name;
  final String image;
  final String rank;

  RepostUser({
    required this.id,
    required this.name,
    required this.image,
    required this.rank,
  });

  factory RepostUser.fromJson(Map<String, dynamic> json) {
    return RepostUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      rank: (json['rank'] ?? '0').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rank': rank,
    };
  }
}

class RepostsResponse {
  final bool status;
  final String message;
  final RepostsData data;

  RepostsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RepostsResponse.fromJson(Map<String, dynamic> json) {
    return RepostsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: RepostsData.fromJson(json['data'] ?? {}),
    );
  }
}

class RepostsData {
  final List<RepostModel> reposts;
  final RepostsPagination pagination;

  RepostsData({
    required this.reposts,
    required this.pagination,
  });

  factory RepostsData.fromJson(Map<String, dynamic> json) {
    final repostsData = json['data'] as List<dynamic>?;
    
    return RepostsData(
      reposts: repostsData?.map((repost) => RepostModel.fromJson(repost)).toList() ?? [],
      pagination: RepostsPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class RepostsPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  RepostsPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory RepostsPagination.fromJson(Map<String, dynamic> json) {
    return RepostsPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;
}