// lib/presentation/screens/main_app/profile/models/comment_model.dart
import 'dart:convert';

class CommentModel {
  final int id;
  final String content;
  final DateTime createdAt;
  final int? parentId;
  final CommentUser user;
  final List<CommentModel> children;

  CommentModel({
    required this.id,
    required this.content,
    required this.createdAt,
    this.parentId,
    required this.user,
    required this.children,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final childrenData = json['children'] as List<dynamic>?;
    
    return CommentModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      parentId: json['parent_id'],
      user: CommentUser.fromJson(json['user'] ?? {}),
      children: childrenData?.map((child) => CommentModel.fromJson(child)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'parent_id': parentId,
      'user': user.toJson(),
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class CommentUser {
  final int id;
  final String name;
  final String image;
  final String rank;

  CommentUser({
    required this.id,
    required this.name,
    required this.image,
    required this.rank,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
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

class CommentsResponse {
  final bool status;
  final String message;
  final CommentsData data;

  CommentsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    return CommentsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: CommentsData.fromJson(json['data'] ?? {}),
    );
  }
}

class CommentsData {
  final List<CommentModel> comments;
  final CommentsPagination pagination;

  CommentsData({
    required this.comments,
    required this.pagination,
  });

  factory CommentsData.fromJson(Map<String, dynamic> json) {
    final commentsData = json['data'] as List<dynamic>?;
    
    return CommentsData(
      comments: commentsData?.map((comment) => CommentModel.fromJson(comment)).toList() ?? [],
      pagination: CommentsPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class CommentsPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  CommentsPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory CommentsPagination.fromJson(Map<String, dynamic> json) {
    return CommentsPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;
}