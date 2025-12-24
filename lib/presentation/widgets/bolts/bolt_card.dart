import 'package:app_1/data/models/user_model.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/main_app/home/user_screen.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/bolt_model.dart';

class BoltCard extends StatefulWidget {
  final BoltModel bolt;

  const BoltCard({Key? key, required this.bolt}) : super(key: key);

  @override
  State<BoltCard> createState() => _BoltCardState();
}

class _BoltCardState extends State<BoltCard> {
  bool _isLiked = false;
  int _currentLikes = 0;
  bool _isReposted = false;
  int _currentShares = 0;
  List<String> _comments = [
    "ممتاز! 👏",
    "جميل جداً ❤️",
    "أحسنت النشر 🌟",
    "معلومات قيمة 💡",
    "مشكور على الخبر 🙏",
  ];

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // استخدام القيم من نموذج البرقية
    _isLiked = widget.bolt.isLiked;
    _currentLikes = widget.bolt.likes;
    _isReposted = widget.bolt.isReposted;
    _currentShares = widget.bolt.shares;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _currentLikes++;
      } else {
        _currentLikes--;
      }
    });

    // استدعاء دالة الإعجاب إذا كانت موجودة
    if (widget.bolt.onLikePressed != null) {
      widget.bolt.onLikePressed!();
    }
  }

  void _toggleRepost() {
    setState(() {
      _isReposted = !_isReposted;
      if (_isReposted) {
        _currentShares++;
      } else {
        _currentShares--;
      }
    });

    // استدعاء دالة المشاركة إذا كانت موجودة
    if (widget.bolt.onSharePressed != null) {
      widget.bolt.onSharePressed!();
    }
  }

  void _showCommentsDialog(BuildContext context) {
    // استدعاء دالة التعليقات إذا كانت موجودة
    if (widget.bolt.onCommentPressed != null) {
      widget.bolt.onCommentPressed!();
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التعليقات (${_comments.length})',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 200.h,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4.h),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 16.r,
                              backgroundColor: widget.bolt.categoryColor
                                  .withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 16.sp,
                                color: widget.bolt.categoryColor,
                              ),
                            ),
                            title: Text(
                              _comments[index],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            trailing: Text(
                              'الآن',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'اكتب تعليقك هنا...',
                            hintStyle: TextStyle(fontSize: 12.sp),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.send,
                                color: widget.bolt.categoryColor,
                                size: 20.sp,
                              ),
                              onPressed: () {
                                _addComment();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        _comments.insert(0, _commentController.text.trim());
        _commentController.clear();
      });
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Text(
              'الإبلاغ عن المحتوى',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'اختر سبب الإبلاغ عن هذه البرقية:',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildReportOption('محتوى غير لائق', Icons.block),
                  _buildReportOption('معلومات مضللة', Icons.warning),
                  _buildReportOption('محتوى مسيء', Icons.report_problem),
                  _buildReportOption('انتحال شخصية', Icons.person_off),
                  _buildReportOption('محتوى عنيف', Icons.gpp_bad),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم الإبلاغ عن البرقية بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('إبلاغ'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.red.shade600, size: 20.sp),
      title: Text(title, style: TextStyle(fontSize: 12.sp)),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // الشريط الجانبي الملون
          _buildCategorySideBar(),

          SizedBox(width: 7.w),

          // البطاقة الرئيسية
          Expanded(
            child: Column(
              children: [
                _buildMainCard(),
                SizedBox(height: 10),
                _buildActionsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // WIDGET BUILDING METHODS
  // ========================

  Widget _buildCategorySideBar() {
    return Container(
      width: 30.w,
      height: 90.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        color: widget.bolt.categoryColor,
      ),
      child: Icon(widget.bolt.categoryIcon, color: Colors.white, size: 20.sp),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 90.h),
      decoration: BoxDecoration(
        borderRadius:
            context.watch<LanguageProvider>().getCurrentLanguageName() ==
                    'العربية'
                ? BorderRadius.only(topRight: Radius.circular(100.r))
                : BorderRadius.only(topLeft: Radius.circular(100.r)),
        boxShadow: [
          BoxShadow(
            color: widget.bolt.categoryColor.withOpacity(0.8),
            blurRadius: 8.r,
            spreadRadius: 2.r,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child:
                context.watch<LanguageProvider>().getCurrentLanguageName() ==
                        'العربية'
                    ? Image.asset(
                      "assets/image/9c2b5260-39de-4527-a927-d0590bfdcbeb.jpg",
                      fit: BoxFit.fill,
                    )
                    : Image.asset(
                      "assets/image/df90fd6d-5043-4f3f-af7b-8699f428b253.jpg",
                      fit: BoxFit.fill,
                    ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding:
                          context
                                      .watch<LanguageProvider>()
                                      .getCurrentLanguageName() ==
                                  'العربية'
                              ? EdgeInsets.only(right: 20.0)
                              : EdgeInsets.only(left: 20.0),
                      child: _buildUserInfo(),
                    ),
                    _buildSettingsMenu(),
                  ],
                ),
                SizedBox(height: 15.h),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.bolt.content,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return GestureDetector(
      onTap: () {
        _navigateToUserProfile(context);
      },
      child: Row(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  print(widget.bolt.userId);
                  //                 Navigator.push(
                  //   context,
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UserProfileScreen(
                            userId: widget.bolt.userId!, // ✅ تمرير الـ userId
                            initialName: widget.bolt.userName,
                            initialImage: widget.bolt.userImage,
                          ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 23.r,
                  backgroundImage:
                      widget.bolt.userImage.startsWith('http')
                          ? NetworkImage(widget.bolt.userImage)
                          : AssetImage(widget.bolt.userImage) as ImageProvider,
                ),
              ),
              context.watch<LanguageProvider>().getCurrentLanguageName() ==
                      'العربية'
                  ? Positioned(
                    bottom: -4,
                    left: -2,
                    child: Icon(
                      Icons.bookmark,
                      color: _getRankColor(widget.bolt.userRank.toString()),
                      size: 22.sp,
                    ),
                  )
                  : Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(
                      Icons.bookmark,
                      color: _getRankColor(widget.bolt.userRank.toString()),
                      size: 20.sp,
                    ),
                  ),
            ],
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.bolt.userName,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                _getTimeAgo(widget.bolt.createdAt),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return 'قبل ${(difference.inDays / 365).floor()} سنة';
    } else if (difference.inDays > 30) {
      return 'قبل ${(difference.inDays / 30).floor()} شهر';
    } else if (difference.inDays > 0) {
      return 'قبل ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'قبل ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'قبل ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case '0':
        return Colors.grey;
      case '1':
        return Colors.red;
      case '2':
        return Color(0xFFD4AF37);
      default:
        return Colors.blue;
    }
  }

  Widget _buildSettingsMenu() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_vert, size: 20.sp, color: Colors.grey.shade600),
      itemBuilder: (context) => _buildMenuItems(),
      onSelected: (value) => _handleMenuSelection(value, context),
    );
  }

  List<PopupMenuItem<String>> _buildMenuItems() {
    return [
      PopupMenuItem<String>(
        value: 'save',
        child: Row(
          children: [
            Icon(
              Icons.bookmark_border,
              size: 18.sp,
              color: Colors.grey.shade700,
            ),
            SizedBox(width: 8.w),
            Text('حفظ البرقية', style: TextStyle(fontSize: 12.sp)),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'copy',
        child: Row(
          children: [
            Icon(Icons.copy, size: 18.sp, color: Colors.grey.shade700),
            SizedBox(width: 8.w),
            Text('نسخ النص', style: TextStyle(fontSize: 12.sp)),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'report',
        child: Row(
          children: [
            Icon(Icons.flag_outlined, size: 18.sp, color: Colors.red.shade600),
            SizedBox(width: 8.w),
            Text(
              'الإبلاغ',
              style: TextStyle(fontSize: 12.sp, color: Colors.red.shade600),
            ),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'hide',
        child: Row(
          children: [
            Icon(
              Icons.visibility_off,
              size: 18.sp,
              color: Colors.grey.shade700,
            ),
            SizedBox(width: 8.w),
            Text('إخفاء', style: TextStyle(fontSize: 12.sp)),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'block',
        child: Row(
          children: [
            Icon(Icons.block, size: 18.sp, color: Colors.red.shade600),
            SizedBox(width: 8.w),
            Text(
              'حظر المستخدم',
              style: TextStyle(fontSize: 12.sp, color: Colors.red.shade600),
            ),
          ],
        ),
      ),
    ];
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'report':
        _showReportDialog(context);
        break;
      case 'save':
        _showSnackBar(context, 'تم حفظ البرقية في المفضلة', Colors.green);
        break;
      case 'copy':
        _showSnackBar(context, 'تم نسخ نص البرقية', Colors.blue);
        break;
      case 'hide':
        _showSnackBar(context, 'تم إخفاء البرقية', Colors.orange);
        break;
      case 'block':
        _showSnackBar(context, 'تم حظر المستخدم', Colors.red);
        break;
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Widget _buildActionsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.emoji_objects,
            label: _currentLikes > 0 ? _currentLikes.toString() : 'ضوء',
            isActive: _isLiked,
            activeColor: Colors.amber.shade700,
            onTap: _toggleLike,
          ),
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            label:
                widget.bolt.comments > 0
                    ? widget.bolt.comments.toString()
                    : 'تعليق',
            onTap: () => _showCommentsDialog(context),
          ),
          _buildActionButton(
            icon: Icons.repeat,
            label: _currentShares > 0 ? _currentShares.toString() : 'شارك',
            isActive: _isReposted,
            activeColor: Colors.green,
            onTap: _toggleRepost,
          ),
          _buildActionButton(
            icon: Icons.send_outlined,
            label: 'إرسال',
            onTap: () => print('تم الإرسال'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                isActive ? (activeColor ?? Colors.blue) : Colors.grey.shade600,
            size: 20.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color:
                  isActive
                      ? (activeColor ?? Colors.blue)
                      : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUserProfile(BuildContext context) {
    final user = UserModel(
      id: int.tryParse(widget.bolt.id) ?? 0,
      firstname: widget.bolt.userName.split(' ').first,
      lastname:
          widget.bolt.userName.split(' ').length > 1
              ? widget.bolt.userName.split(' ').last
              : 'User',
      email:
          '${widget.bolt.userName.replaceAll(' ', '_').toLowerCase()}@example.com',
      phone: null,
      bio: 'مستخدم نشط في تطبيق البرقيات 💻 | مهتم بالتكنولوجيا والبرمجة',
      image: widget.bolt.userImage,
      cover: null,
      zodiac: 'الجوزاء',
      zodiacDescription: 'اجتماعي، مبدع، مرح',
      shareLocation: true,
      shareZodiac: true,
      birthdate: '1995-05-15',
      country: 'مصر',
      isVerified: true,
      emailVerifiedAt: DateTime.now().subtract(Duration(days: 30)),
      createdAt: DateTime.now().subtract(Duration(days: 365)),
      updatedAt: DateTime.now(),

      username: widget.bolt.userName.replaceAll(' ', '_').toLowerCase(),
      boltCount: 42,
      followersCount: 1200,
      followingCount: 856,
      isFollowing: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VisitProfileScreen(user: user)),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
