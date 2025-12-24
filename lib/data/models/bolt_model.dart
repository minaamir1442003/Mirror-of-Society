import 'package:flutter/material.dart';

class BoltModel {
  final String id;
  final String content;
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;
  final DateTime createdAt;
  final String userName;
  final String userImage;
  final int likes;
  final int comments;
  final String? userId;
  final int shares;
  final bool isAd;
  final bool isLiked;
  final bool isReposted;
  final String? userRank;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onSharePressed;
  

  BoltModel({
    this.id = '',
    required this.content,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
    required this.createdAt,
    this.userName = 'مستخدم',
    this.userImage = 'assets/image/images.jpg',
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isAd = false,
    this.isLiked = false,
    this.isReposted = false,
    this.userId,
    this.userRank,
    this.onLikePressed,
    this.onCommentPressed,
    this.onSharePressed,
  });
  BoltModel copyWith({
    String? id,
    String? content,
    String? category,
    Color? categoryColor,
    IconData? categoryIcon,
    DateTime? createdAt,
    String? userName,
    String? userImage,
    String? userId,
    int? likes,
    int? comments,
    int? shares,
    bool? isAd,
    bool? isLiked,
    bool? isReposted,
    String? userRank,
    VoidCallback? onLikePressed,
    VoidCallback? onCommentPressed,
    VoidCallback? onSharePressed,
  }) {
    return BoltModel(
      id: id ?? this.id,
      content: content ?? this.content,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      userId: userId ?? this.userId,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isAd: isAd ?? this.isAd,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      userRank: userRank ?? this.userRank,
      onLikePressed: onLikePressed ?? this.onLikePressed,
      onCommentPressed: onCommentPressed ?? this.onCommentPressed,
      onSharePressed: onSharePressed ?? this.onSharePressed,
    );
  }
}