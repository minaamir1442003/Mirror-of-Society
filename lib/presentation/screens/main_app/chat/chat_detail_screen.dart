import 'package:flutter/material.dart';
import 'package:app_1/data/models/message_model.dart';
import 'package:app_1/presentation/widgets/chats/message_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userImage;

  const ChatDetailScreen({
    required this.userId,
    required this.userName,
    required this.userImage,
  });

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // بيانات وهمية للرسائل
    _messages.addAll([
      Message(
        id: '1',
        senderId: 'currentUser',
        receiverId: widget.userId,
        content: 'مرحباً، كيف حالك؟',
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
        isRead: true,
      ),
      Message(
        id: '2',
        senderId: widget.userId,
        receiverId: 'currentUser',
        content: 'أنا بخير، شكراً! وأنت كيف حالك؟',
        timestamp: DateTime.now().subtract(Duration(minutes: 25)),
        isRead: true,
      ),
      Message(
        id: '3',
        senderId: 'currentUser',
        receiverId: widget.userId,
        content: 'أنا أيضاً بخير الحمدلله. هل يمكنك مساعدتي في شيء؟',
        timestamp: DateTime.now().subtract(Duration(minutes: 20)),
        isRead: true,
      ),
      Message(
        id: '4',
        senderId: widget.userId,
        receiverId: 'currentUser',
        content: 'نعم بالطبع، قل لي ماذا تحتاج؟',
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
        isRead: true,
      ),
      Message(
        id: '5',
        senderId: 'currentUser',
        receiverId: widget.userId,
        content: 'أحتاج مساعدة في مشروع Flutter الذي أعمل عليه',
        timestamp: DateTime.now().subtract(Duration(minutes: 10)),
        isRead: true,
      ),
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'currentUser',
      receiverId: widget.userId,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    
    // التمرير لآخر رسالة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // محاكاة رد الطرف الآخر
    _simulateReply();
  }

  void _simulateReply() {
    Future.delayed(Duration(seconds: 2), () {
      final replyMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: widget.userId,
        receiverId: 'currentUser',
        content: 'بالطبع، سأكون سعيداً بمساعدتك!',
        timestamp: DateTime.now(),
        isRead: false,
      );

      setState(() {
        _messages.add(replyMessage);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(widget.userImage),
                radius: 18,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.userName),
                  Text(
                    'متصل الآن',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.phone),
              onPressed: () {
                // اتصال صوتي
              },
            ),
            IconButton(
              icon: Icon(Icons.videocam),
              onPressed: () {
                // اتصال فيديو
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
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message.senderId == 'currentUser';
                  
                  return MessageBubble(
                    message: message,
                    isMe: isMe,
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              // إضافة ملف أو صورة
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالة...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () {
              // إرسال صورة
            },
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.blue,
            ),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}