import 'package:app_1/presentation/screens/main_app/chat/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_1/data/models/chat_model.dart';
import 'package:app_1/presentation/widgets/chats/chat_item.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Chat> chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    // بيانات وهمية للمحادثات
    chats = [
      Chat(
        id: '1',
        userId: 'user1',
        userName: 'أحمد محمد',
        userImage: 'assets/image/download.jpg',
        lastMessage: 'مرحباً، كيف حالك؟',
        lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
        unreadCount: 3,
        isOnline: true,
        lastSeen: DateTime.now(),
      ),
      Chat(
        id: '2',
        userId: 'user2',
        userName: 'سارة علي',
        userImage: 'assets/image/download.jpg',
        lastMessage: 'هل يمكنك مساعدتي في المشروع؟',
        lastMessageTime: DateTime.now().subtract(Duration(hours: 2)),
        unreadCount: 0,
        isOnline: false,
        lastSeen: DateTime.now().subtract(Duration(hours: 1)),
      ),
      Chat(
        id: '3',
        userId: 'user3',
        userName: 'محمد خالد',
        userImage: 'assets/image/images.jpg',
        lastMessage: 'شكراً على المساعدة!',
        lastMessageTime: DateTime.now().subtract(Duration(days: 1)),
        unreadCount: 1,
        isOnline: false,
        lastSeen: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('المحادثات'),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // بحث في المحادثات
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                // قائمة إضافية
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            return ChatItem(
              chat: chats[index],
              onTap: () {
                // الانتقال لصفحة المحادثة
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      userId: chats[index].userId,
                      userName: chats[index].userName,
                      userImage: chats[index].userImage,
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.message),
          onPressed: () {
            // بدء محادثة جديدة
          },
        ),
      ),
    );
  }
}