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
    this.userRank,
    this.onLikePressed,
    this.onCommentPressed,
    this.onSharePressed,
  });
}