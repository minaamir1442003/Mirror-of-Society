import 'package:flutter/material.dart';

class BoltModel {
  final String id;
  final String content;
  final String category;
  final Color categoryColor;
  final IconData categoryIcon; // أضف هذا
  final DateTime createdAt;
  final String userName;
  final String userImage;
  final int likes;
  final int comments;
  final int shares;
  final bool isAd;
  
  BoltModel({
    this.id = '',
    required this.content,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon, // أضف هذا
    required this.createdAt,
    this.userName = 'مستخدم',
    this.userImage = 'assets/images/user_placeholder.jpg',
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isAd = false,
  });
}