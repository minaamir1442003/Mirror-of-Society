import 'package:app_1/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

AppBar _buildAppBar() {  // ✅ هذا التعريف الصحيح
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Row(
      children: [
        Icon(Icons.bolt, color: AppColors.primary),
        SizedBox(width: 8),
        Text(
          'البرقيات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.secondary,
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.notifications_outlined),
        onPressed: () {},
      ),
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {},
      ),
    ],
  );
}