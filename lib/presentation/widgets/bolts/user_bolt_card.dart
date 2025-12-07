import 'package:flutter/material.dart';
import 'package:app_1/core/theme/app_colors.dart';
import 'package:app_1/data/models/bolt_model.dart';

class UserBoltCard extends StatelessWidget {
  final BoltModel bolt;
  final bool isMyProfile;

  const UserBoltCard({
    Key? key,
    required this.bolt,
    this.isMyProfile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildContent(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bolt.categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  bolt.categoryIcon,
                  size: 16,
                  color: bolt.categoryColor,
                ),
                SizedBox(width: 6),
                Text(
                  bolt.category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: bolt.categoryColor,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                _formatTime(bolt.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 8),
              if (isMyProfile)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 18, color: Colors.grey),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      // TODO: تعديل البرقية
                    } else if (value == 'delete') {
                      // TODO: حذف البرقية
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        bolt.content,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey[800],
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.emoji_objects, bolt.likes, 'ضوء', Colors.amber),
          _buildStatItem(Icons.chat_bubble_outline, bolt.comments, 'تعليق', Colors.blue),
          _buildStatItem(Icons.repeat, bolt.shares, 'شارك', Colors.green),
          _buildStatItem(Icons.bookmark_border, 0, 'حفظ', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          count > 0 ? _formatNumber(count) : label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'قبل ${difference.inMinutes} د';
    } else if (difference.inHours < 24) {
      return 'قبل ${difference.inHours} س';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} ي';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}