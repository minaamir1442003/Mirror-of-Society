import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/common/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      notifications = [
        NotificationItem(
          id: '1',
          type: NotificationType.like,
          userName: 'أحمد محمد',
          userAvatar: '👤',
          boltPreview: 'جلسة برمجة ليلية مع فلاتر...',
          timeAgo: '5 دقائق',
          isRead: false,
        ),
        NotificationItem(
          id: '2',
          type: NotificationType.comment,
          userName: 'سارة خالد',
          userAvatar: '👩',
          boltPreview: 'قراءة كتاب جديد عن فن الكتابة...',
          timeAgo: 'ساعتين',
          isRead: false,
        ),
        NotificationItem(
          id: '3',
          type: NotificationType.share,
          userName: 'محمد علي',
          userAvatar: '👨',
          boltPreview: 'مباراة رائعة اليوم بين الفريقين...',
          timeAgo: '4 ساعات',
          isRead: true,
        ),
        NotificationItem(
          id: '4',
          type: NotificationType.follow,
          userName: 'ريم أحمد',
          userAvatar: '👩‍💼',
          timeAgo: 'يوم',
          isRead: true,
        ),
        NotificationItem(
          id: '5',
          type: NotificationType.system,
          title: 'ترقية الرتبة',
          message: 'تهانينا! تم ترقيتك إلى رتبة "نشط"',
          timeAgo: 'يومين',
          isRead: true,
        ),
      ];
      _isLoading = false;
    });
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    Color? iconColor;
    IconData icon;
    String title;
    String subtitle;

    switch (notification.type) {
      case NotificationType.like:
        icon = Icons.emoji_objects;
        iconColor = Colors.amber;
        title = '${notification.userName} أعجب ببرقيتك';
        subtitle = notification.boltPreview ?? '';
        break;
      case NotificationType.comment:
        icon = Icons.chat_bubble;
        iconColor = AppColors.primary;
        title = '${notification.userName} علق على برقيتك';
        subtitle = notification.boltPreview ?? '';
        break;
      case NotificationType.share:
        icon = Icons.repeat;
        iconColor = AppColors.success;
        title = '${notification.userName} أعاد نشر برقيتك';
        subtitle = notification.boltPreview ?? '';
        break;
      case NotificationType.follow:
        icon = Icons.person_add;
        iconColor = AppColors.warning;
        title = '${notification.userName} يتابعك الآن';
        subtitle = 'بدأ متابعتك';
        break;
      case NotificationType.system:
        icon = Icons.info;
        iconColor = AppColors.darkGray;
        title = notification.title ?? 'إشعار نظام';
        subtitle = notification.message ?? '';
        break;
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: notification.type == NotificationType.system
              ? iconColor?.withOpacity(0.1)
              : AppColors.extraLightGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: notification.type == NotificationType.system
            ? Icon(icon, color: iconColor)
            : Center(
                child: Text(
                  notification.userAvatar ?? '👤',
                  style: TextStyle(fontSize: 20),
                ),
              ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.darkGray,
          fontSize: 14,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            notification.timeAgo,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.lightGray,
            ),
          ),
          if (!notification.isRead)
            Container(
              margin: EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () {
        _markAsRead(notification.id);
      },
    );
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      notifications = notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديد جميع الإشعارات كمقروءة'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف جميع الإشعارات'),
        content: Text('هل أنت متأكد من حذف جميع الإشعارات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف جميع الإشعارات'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
        : notifications.isEmpty
            ? EmptyState(
                icon: Icons.notifications_none,
                message: 'لا توجد إشعارات',
                actionText: 'تحديث',
                onAction: _loadNotifications,
              )
            : Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    color: AppColors.extraLightGray,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: AppColors.darkGray),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'الإشعارات المميزة بعلامة زرقاء لم تقرأ بعد',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.separated(
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          return _buildNotificationItem(notifications[index]);
                        },
                      ),
                    ),
                  ),
                ],
              );
  }
}

enum NotificationType {
  like,
  comment,
  share,
  follow,
  system,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String? userName;
  final String? userAvatar;
  final String? boltPreview;
  final String? title;
  final String? message;
  final String timeAgo;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    this.userName,
    this.userAvatar,
    this.boltPreview,
    this.title,
    this.message,
    required this.timeAgo,
    required this.isRead,
  });

  NotificationItem copyWith({
    bool? isRead,
  }) {
    return NotificationItem(
      id: id,
      type: type,
      userName: userName,
      userAvatar: userAvatar,
      boltPreview: boltPreview,
      title: title,
      message: message,
      timeAgo: timeAgo,
      isRead: isRead ?? this.isRead,
    );
  }
}