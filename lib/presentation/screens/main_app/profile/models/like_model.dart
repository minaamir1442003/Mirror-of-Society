import 'dart:convert';

class LikeModel {
  final int id;
  final LikeUser user;
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.user,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] ?? 0,
      user: LikeUser.fromJson(json['user'] ?? {}),
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

class LikeUser {
  final int id;
  final String name;
  final String image;
  final String rank;

  LikeUser({
    required this.id,
    required this.name,
    required this.image,
    required this.rank,
  });

  factory LikeUser.fromJson(Map<String, dynamic> json) {
    return LikeUser(
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

class LikesResponse {
  final bool status;
  final String message;
  final LikesData data;

  LikesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LikesResponse.fromJson(Map<String, dynamic> json) {
    return LikesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: LikesData.fromJson(json['data'] ?? {}),
    );
  }
}

class LikesData {
  final List<LikeModel> likes;
  final LikesPagination pagination;

  LikesData({
    required this.likes,
    required this.pagination,
  });

  factory LikesData.fromJson(Map<String, dynamic> json) {
    final likesData = json['data'] as List<dynamic>?;
    
    return LikesData(
      likes: likesData?.map((like) => LikeModel.fromJson(like)).toList() ?? [],
      pagination: LikesPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class LikesPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  LikesPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory LikesPagination.fromJson(Map<String, dynamic> json) {
    return LikesPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;
}