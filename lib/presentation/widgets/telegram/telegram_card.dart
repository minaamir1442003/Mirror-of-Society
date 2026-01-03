// // lib/presentation/widgets/telegram/telegram_card.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:app_1/data/services/websocket_service.dart';
// import 'package:app_1/presentation/providers/language_provider.dart';

// class TelegramCard extends StatefulWidget {
//   final Map<String, dynamic> telegramData;
//   final bool isProfileView;
//   final Function(Map<String, dynamic>)? onUpdate;
  
//   const TelegramCard({
//     Key? key,
//     required this.telegramData,
//     this.isProfileView = false,
//     this.onUpdate,
//   }) : super(key: key);

//   @override
//   _TelegramCardState createState() => _TelegramCardState();
// }

// class _TelegramCardState extends State<TelegramCard> {
//   late Map<String, dynamic> _telegramData;
//   late WebSocketService _webSocketService;
//   bool _isSubscribed = false;
//   bool _isLiked = false;
//   int _currentLikes = 0;
//   bool _isReposted = false;
//   int _currentReposts = 0;
//   int _currentComments = 0;
  
//   List<String> _comments = [
//     "ممتاز! 👏",
//     "جميل جداً ❤️",
//     "أحسنت النشر 🌟",
//     "معلومات قيمة 💡",
//     "مشكور على الخبر 🙏",
//   ];

//   final TextEditingController _commentController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _telegramData = Map<String, dynamic>.from(widget.telegramData);
    
//     // استخدام القيم من البيانات
//     _isLiked = _telegramData['is_liked'] ?? false;
//     _currentLikes = _telegramData['likes_count'] ?? 0;
//     _isReposted = _telegramData['is_reposted'] ?? false;
//     _currentReposts = _telegramData['reposts_count'] ?? 0;
//     _currentComments = _telegramData['comments_count'] ?? 0;
    
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeWebSocket();
//     });
//   }
  
//   void _initializeWebSocket() {
//     try {
//       _webSocketService = Provider.of<WebSocketService>(context, listen: false);
      
//       final telegramId = _telegramData['id'] is int 
//           ? _telegramData['id']
//           : int.tryParse(_telegramData['id']?.toString() ?? '');
      
//       if (telegramId != null) {
//         // ✅ الاشتراك في قناة البرقية
//         _webSocketService.subscribeToTelegram(telegramId);
        
//         // ✅ إضافة listener للتحديثات
//         _webSocketService.addTelegramListener(telegramId, _handleTelegramUpdate);
        
//         _isSubscribed = true;
//         print('📡 TelegramCard($telegramId): Subscribed to real-time updates');
//       } else {
//         print('⚠️ TelegramCard: Invalid telegram ID: ${_telegramData['id']}');
//       }
//     } catch (e) {
//       print('❌ TelegramCard: Error initializing WebSocket: $e');
//     }
//   }
  
//   void _handleTelegramUpdate(Map<String, dynamic> updateData) {
//     if (!mounted) return;
    
//     print('🔄 TelegramCard: Received update: $updateData');
    
//     setState(() {
//       // تحديث عدد الإعجابات
//       if (updateData['likes_count'] != null) {
//         _currentLikes = updateData['likes_count'];
//       }
      
//       // تحديث عدد التعليقات
//       if (updateData['comments_count'] != null) {
//         _currentComments = updateData['comments_count'];
//       }
      
//       // تحديث عدد إعادة النشر
//       if (updateData['reposts_count'] != null) {
//         _currentReposts = updateData['reposts_count'];
//       }
      
//       // تحديث حالة الإعجاب
//       if (updateData['data'] != null && updateData['data']['liked'] != null) {
//         _isLiked = updateData['data']['liked'];
//       }
      
//       // تحديث حالة إعادة النشر
//       if (updateData['data'] != null && updateData['data']['reposted'] != null) {
//         _isReposted = updateData['data']['reposted'];
//       }
//     });
    
//     // تحديث البيانات الأصلية
//     _telegramData['likes_count'] = _currentLikes;
//     _telegramData['comments_count'] = _currentComments;
//     _telegramData['reposts_count'] = _currentReposts;
//     _telegramData['is_liked'] = _isLiked;
//     _telegramData['is_reposted'] = _isReposted;
    
//     // إشعار الـ parent بالتحديث
//     if (widget.onUpdate != null) {
//       widget.onUpdate!(_telegramData);
//     }
//   }
  
//   Future<void> _toggleLike() async {
//     try {
//       final telegramId = _telegramData['id'] is int 
//           ? _telegramData['id']
//           : int.tryParse(_telegramData['id']?.toString() ?? '');
      
//       if (telegramId == null) {
//         print('❌ Invalid telegram ID for like action');
//         return;
//       }
      
//       setState(() {
//         _isLiked = !_isLiked;
//         _currentLikes = _isLiked ? _currentLikes + 1 : _currentLikes - 1;
//       });
      
//       // تحديث البيانات
//       _telegramData['is_liked'] = _isLiked;
//       _telegramData['likes_count'] = _currentLikes;
      
//       // إشعار الـ parent بالتحديث
//       if (widget.onUpdate != null) {
//         widget.onUpdate!(_telegramData);
//       }
      
//       // TODO: استدعاء API الحقيقي هنا
//       // final response = await _telegramRepository.likeTelegram(telegramId);
//       // if (response.success) {
//       //   setState(() {
//       //     _isLiked = response.data['liked'];
//       //     _currentLikes = response.data['likes_count'];
//       //   });
//       // }
      
//       print('❤️ Like action for telegram $telegramId, liked: $_isLiked');
      
//     } catch (e) {
//       print('❌ Error handling like: $e');
//     }
//   }
  
//   Future<void> _toggleRepost() async {
//     try {
//       final telegramId = _telegramData['id'] is int 
//           ? _telegramData['id']
//           : int.tryParse(_telegramData['id']?.toString() ?? '');
      
//       if (telegramId == null) {
//         print('❌ Invalid telegram ID for repost action');
//         return;
//       }
      
//       setState(() {
//         _isReposted = !_isReposted;
//         _currentReposts = _isReposted ? _currentReposts + 1 : _currentReposts - 1;
//       });
      
//       // تحديث البيانات
//       _telegramData['is_reposted'] = _isReposted;
//       _telegramData['reposts_count'] = _currentReposts;
      
//       // إشعار الـ parent بالتحديث
//       if (widget.onUpdate != null) {
//         widget.onUpdate!(_telegramData);
//       }
      
//       // TODO: استدعاء API الحقيقي هنا
//       // await _telegramRepository.repostTelegram(telegramId);
      
//       print('🔄 Repost action for telegram $telegramId, reposted: $_isReposted');
      
//     } catch (e) {
//       print('❌ Error handling repost: $e');
//     }
//   }
  
//   void _showCommentsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Directionality(
//           textDirection: TextDirection.rtl,
//           child: AlertDialog(
//             backgroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.r),
//             ),
//             title: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'التعليقات (${_comments.length})',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.close, size: 20.sp),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//             content: Container(
//               width: double.maxFinite,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     height: 200.h,
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: _comments.length,
//                       itemBuilder: (context, index) {
//                         return Card(
//                           margin: EdgeInsets.symmetric(vertical: 4.h),
//                           elevation: 1,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.r),
//                           ),
//                           child: ListTile(
//                             leading: CircleAvatar(
//                               radius: 16.r,
//                               backgroundColor: _getCategoryColor(),
//                               child: Icon(
//                                 Icons.person,
//                                 size: 16.sp,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             title: Text(
//                               _comments[index],
//                               style: TextStyle(
//                                 fontSize: 12.sp,
//                                 color: Colors.grey.shade800,
//                               ),
//                             ),
//                             trailing: Text(
//                               'الآن',
//                               style: TextStyle(
//                                 fontSize: 10.sp,
//                                 color: Colors.grey.shade500,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _commentController,
//                           decoration: InputDecoration(
//                             hintText: 'اكتب تعليقك هنا...',
//                             hintStyle: TextStyle(fontSize: 12.sp),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(25.r),
//                               borderSide: BorderSide(
//                                 color: Colors.grey.shade300,
//                               ),
//                             ),
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 16.w,
//                               vertical: 12.h,
//                             ),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 Icons.send,
//                                 color: _getCategoryColor(),
//                                 size: 20.sp,
//                               ),
//                               onPressed: () {
//                                 _addComment();
//                                 Navigator.pop(context);
//                               },
//                             ),
//                           ),
//                           style: TextStyle(fontSize: 12.sp),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
  
//   void _addComment() {
//     if (_commentController.text.trim().isNotEmpty) {
//       setState(() {
//         _comments.insert(0, _commentController.text.trim());
//         _currentComments++;
//         _telegramData['comments_count'] = _currentComments;
//         _commentController.clear();
//       });
      
//       // إشعار الـ parent بالتحديث
//       if (widget.onUpdate != null) {
//         widget.onUpdate!(_telegramData);
//       }
//     }
//   }
  
//   void _showReportDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Directionality(
//           textDirection: TextDirection.rtl,
//           child: AlertDialog(
//             backgroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.r),
//             ),
//             title: Text(
//               'الإبلاغ عن المحتوى',
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red.shade700,
//               ),
//             ),
//             content: Container(
//               width: double.maxFinite,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'اختر سبب الإبلاغ عن هذه البرقية:',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   _buildReportOption('محتوى غير لائق', Icons.block),
//                   _buildReportOption('معلومات مضللة', Icons.warning),
//                   _buildReportOption('محتوى مسيء', Icons.report_problem),
//                   _buildReportOption('انتحال شخصية', Icons.person_off),
//                   _buildReportOption('محتوى عنيف', Icons.gpp_bad),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   'إلغاء',
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('تم الإبلاغ عن البرقية بنجاح'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 child: Text('إبلاغ'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildReportOption(String title, IconData icon) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.red.shade600, size: 20.sp),
//       title: Text(title, style: TextStyle(fontSize: 12.sp)),
//       onTap: () {},
//     );
//   }
  
//   @override
//   void dispose() {
//     // ✅ مهم: إلغاء الاشتراك عند التخلص من الـ widget
//     if (_isSubscribed) {
//       try {
//         final telegramId = _telegramData['id'] is int 
//             ? _telegramData['id']
//             : int.tryParse(_telegramData['id']?.toString() ?? '');
        
//         if (telegramId != null) {
//           _webSocketService.unsubscribeFromTelegram(telegramId);
//           _webSocketService.removeTelegramListener(telegramId, _handleTelegramUpdate);
//           print('📡 TelegramCard($telegramId): Unsubscribed from real-time');
//         }
//       } catch (e) {
//         print('❌ Error unsubscribing: $e');
//       }
//     }
    
//     _commentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = _telegramData['user'] ?? {};
//     final category = _telegramData['category'] ?? {};
    
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 18.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // المحتوى الرئيسي للبطاقة
//           _buildMainCard(user, category),
//           SizedBox(height: 10),
//           _buildActionsSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainCard(Map<String, dynamic> user, Map<String, dynamic> category) {
//     final isArabic = Provider.of<LanguageProvider>(context, listen: false)
//         .getCurrentLanguageName() == 'العربية';
    
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         // الشريط الجانبي الملون (الجزء الأيسر)
//         Container(
//           margin: EdgeInsets.only(top: 9),
//           width: 30.w,
//           height: (_telegramData['content']?.toString().length ?? 0) > 100 ? 80.h : 70.h,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15.r),
//             color: _getCategoryColor(),
//           ),
//           child: Icon(
//             Icons.lightbulb_outline,
//             color: Colors.white,
//             size: 20.sp,
//           ),
//         ),
//         SizedBox(width: 7.w),

//         // البطاقة الرئيسية (الجزء الأيمن)
//         Expanded(
//           child: Container(
//             constraints: BoxConstraints(minHeight: 90.h),
//             decoration: BoxDecoration(
//               borderRadius: isArabic
//                   ? BorderRadius.only(topRight: Radius.circular(100.r))
//                   : BorderRadius.only(topLeft: Radius.circular(100.r)),
//               boxShadow: [
//                 BoxShadow(
//                   color: _getCategoryColor().withOpacity(0.8),
//                   blurRadius: 8.r,
//                   spreadRadius: 2.r,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Stack(
//               children: [
//                 Positioned.fill(
//                   child: Image.asset(
//                     isArabic
//                       ? "assets/image/9c2b5260-39de-4527-a927-d0590bfdcbeb.jpg"
//                       : "assets/image/df90fd6d-5043-4f3f-af7b-8699f428b253.jpg",
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 5,
//                     vertical: 10.h,
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Padding(
//                             padding: isArabic
//                                 ? EdgeInsets.only(right: 20.0)
//                                 : EdgeInsets.only(left: 20.0),
//                             child: _buildUserInfo(user, isArabic),
//                           ),
//                           Column(
//                             children: [
//                               if (widget.isProfileView && _telegramData['number'] != null)
//                                 Text(
//                                   '#${_telegramData['number']}',
//                                   style: TextStyle(
//                                     fontSize: 13.sp,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black54,
//                                   ),
//                                 ),
//                               _buildSettingsMenu(isArabic),
//                             ],
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 15.h),
//                       Flexible(
//                         child: Container(
//                           alignment: Alignment.center,
//                           child: Text(
//                             _telegramData['content']?.toString() ?? '',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black87,
//                             ),
//                             maxLines: 4,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildUserInfo(Map<String, dynamic> user, bool isArabic) {
//     final createdAt = _telegramData['created_at'] ?? '';
    
//     return GestureDetector(
//       onTap: () {
//         // يمكنك إضافة التنقل لصفحة المستخدم هنا
//       },
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Stack(
//             children: [
//               CircleAvatar(
//                 radius: 18.r,
//                 backgroundImage: NetworkImage(user['image'] ?? ''),
//               ),
//               Positioned(
//                 bottom: isArabic ? -2 : -4,
//                 left: isArabic ? -2 : null,
//                 right: isArabic ? null : -2,
//                 child: Icon(
//                   Icons.bookmark,
//                   color: _getRankColor(user['rank']?.toString() ?? '0'),
//                   size: isArabic ? 22.sp : 20.sp,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(width: 8.w),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 user['name'] ?? '',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//               Text(
//                 _formatTime(createdAt),
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   fontWeight: FontWeight.w400,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatTime(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       final now = DateTime.now();
//       final difference = now.difference(date);

//       if (difference.inMinutes < 60) {
//         return 'قبل ${difference.inMinutes} د';
//       } else if (difference.inHours < 24) {
//         return 'قبل ${difference.inHours} س';
//       } else if (difference.inDays < 7) {
//         return 'قبل ${difference.inDays} ي';
//       } else if (difference.inDays < 30) {
//         final weeks = (difference.inDays / 7).floor();
//         return 'قبل $weeks أ';
//       } else if (difference.inDays < 365) {
//         final months = (difference.inDays / 30).floor();
//         return 'قبل $months ش';
//       } else {
//         final years = (difference.inDays / 365).floor();
//         return 'قبل $years س';
//       }
//     } catch (e) {
//       return dateString;
//     }
//   }

//   Color _getRankColor(String rank) {
//     switch (rank) {
//       case '0':
//         return Colors.grey;
//       case '1':
//         return Colors.red;
//       case '2':
//         return Color(0xFFD4AF37);
//       default:
//         return Colors.blue;
//     }
//   }

//   Widget _buildSettingsMenu(bool isArabic) {
//     return PopupMenuButton<String>(
//       padding: EdgeInsets.zero,
//       icon: Icon(Icons.more_vert, size: 20.sp, color: Colors.grey.shade600),
//       itemBuilder: (context) {
//         final List<PopupMenuItem<String>> items = [
//           PopupMenuItem<String>(
//             value: 'save',
//             child: Row(
//               children: [
//                 Icon(Icons.bookmark_border, size: 18.sp, color: Colors.grey.shade700),
//                 SizedBox(width: 8.w),
//                 Text(
//                   isArabic ? 'حفظ البرقية' : 'Save Telegram',
//                   style: TextStyle(fontSize: 12.sp),
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuItem<String>(
//             value: 'copy',
//             child: Row(
//               children: [
//                 Icon(Icons.copy, size: 18.sp, color: Colors.grey.shade700),
//                 SizedBox(width: 8.w),
//                 Text(
//                   isArabic ? 'نسخ النص' : 'Copy Text',
//                   style: TextStyle(fontSize: 12.sp),
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuItem<String>(
//             value: 'report',
//             child: Row(
//               children: [
//                 Icon(Icons.flag_outlined, size: 18.sp, color: Colors.red.shade600),
//                 SizedBox(width: 8.w),
//                 Text(
//                   isArabic ? 'الإبلاغ' : 'Report',
//                   style: TextStyle(fontSize: 12.sp, color: Colors.red.shade600),
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuItem<String>(
//             value: 'hide',
//             child: Row(
//               children: [
//                 Icon(Icons.visibility_off, size: 18.sp, color: Colors.grey.shade700),
//                 SizedBox(width: 8.w),
//                 Text(
//                   isArabic ? 'إخفاء' : 'Hide',
//                   style: TextStyle(fontSize: 12.sp),
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuItem<String>(
//             value: 'block',
//             child: Row(
//               children: [
//                 Icon(Icons.block, size: 18.sp, color: Colors.red.shade600),
//                 SizedBox(width: 8.w),
//                 Text(
//                   isArabic ? 'حظر المستخدم' : 'Block User',
//                   style: TextStyle(fontSize: 12.sp, color: Colors.red.shade600),
//                 ),
//               ],
//             ),
//           ),
//         ];

//         return items;
//       },
//       onSelected: (value) => _handleMenuSelection(value, context),
//     );
//   }

//   void _handleMenuSelection(String value, BuildContext context) {
//     switch (value) {
//       case 'report':
//         _showReportDialog(context);
//         break;
//       case 'save':
//         _showSnackBar(context, 'تم حفظ البرقية في المفضلة', Colors.green);
//         break;
//       case 'copy':
//         _showSnackBar(context, 'تم نسخ نص البرقية', Colors.blue);
//         break;
//       case 'hide':
//         _showSnackBar(context, 'تم إخفاء البرقية', Colors.orange);
//         break;
//       case 'block':
//         _showSnackBar(context, 'تم حظر المستخدم', Colors.red);
//         break;
//     }
//   }

//   void _showSnackBar(BuildContext context, String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//       ),
//     );
//   }

//   Widget _buildActionsSection() {
//     return Container(
//       width: 350,
//       padding: EdgeInsets.symmetric(horizontal: 10.w),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _buildActionButton(
//             icon: Icons.emoji_objects,
//             label: _currentLikes > 0 ? _currentLikes.toString() : 'ضوء',
//             isActive: _isLiked,
//             activeColor: Colors.amber.shade700,
//             onTap: _toggleLike,
//           ),
//           _buildActionButton(
//             icon: Icons.chat_bubble_outline,
//             label: _currentComments > 0 ? _currentComments.toString() : 'تعليق',
//             onTap: () => _showCommentsDialog(context),
//           ),
//           _buildActionButton(
//             icon: Icons.repeat,
//             label: _currentReposts > 0 ? _currentReposts.toString() : 'شارك',
//             isActive: _isReposted,
//             activeColor: Colors.green,
//             onTap: _toggleRepost,
//           ),
//           _buildActionButton(
//             icon: Icons.send_outlined,
//             label: 'إرسال',
//             onTap: () => print('تم الإرسال'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     bool isActive = false,
//     Color? activeColor,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             color: isActive ? (activeColor ?? Colors.blue) : Colors.grey.shade600,
//             size: 20.sp,
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 10.sp,
//               fontWeight: FontWeight.w500,
//               color: isActive
//                   ? (activeColor ?? Colors.blue)
//                   : Colors.grey.shade700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getCategoryColor() {
//     final categoryColor = _telegramData['category']?['color'] ?? '#007bff';
    
//     String hexColor = categoryColor.replaceAll('#', '');
//     if (hexColor.length == 6) {
//       hexColor = 'FF$hexColor';
//     }
//     return Color(int.parse(hexColor, radix: 16));
//   }
// }