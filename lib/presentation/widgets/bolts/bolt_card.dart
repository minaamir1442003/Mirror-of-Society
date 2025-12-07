import 'package:app_1/data/models/user_model.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/main_app/home/user_screen.dart';
import 'package:app_1/presentation/widgets/bolts/CornerPageCurlPainter.dart';
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
    _currentLikes = widget.bolt.likes;
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
  }

  void _showCommentsDialog(BuildContext context) {
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

          SizedBox(width: 7),

          // البطاقة الرئيسية
          _buildMainCard(),
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
      height: 110.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        color: widget.bolt.categoryColor,
      ),
      child: Icon(widget.bolt.categoryIcon, color: Colors.white, size: 20.sp),
    );
  }

  Widget _buildMainCard() {
    return IntrinsicHeight(
      child: Container(
        width: 320.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: widget.bolt.categoryColor.withOpacity(0.8),
              blurRadius: 8.r,
              spreadRadius: 2.r,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [_buildContentSection(), _buildActionsSection()],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // صورة المستخدم واسمه
        _buildUserInfo(),

        // المحتوى النصي
        _buildContentText(),

        // قائمة الإعدادات
        _buildSettingsMenu(),
      ],
    );
  }

  Widget _buildUserInfo() {
    return GestureDetector(
      onTap: () {
        _navigateToUserProfile(context);
      },
      child: Stack(
        children: [
          Container(
            width: 80.w,
            padding: EdgeInsets.only(top: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: AssetImage("assets/image/images.jpg"),
                ),
                SizedBox(height: 7.h),
                Text(
                  widget.bolt.userName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Text(
                  "منذ 30د",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          context.watch<LanguageProvider>().currentLanguage == 'العربية'
              ? Positioned(
                bottom: 40,
                left: 15,
                child: Icon(Icons.bookmark, color: Colors.grey, size: 30),
              )
              : Positioned(
                bottom: 35,
                right: 15,
                child: Icon(Icons.bookmark, color: Colors.grey, size: 30),
              ),
        ],
      ),
    );
  }

  Widget _buildContentText() {
    return Container(
      width: 210.w,
      padding: EdgeInsets.only(top: 15),
      child: Text(
        widget.bolt.content,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_vert,
                size: 18.sp,
                color: Colors.grey.shade600,
              ),
              itemBuilder: (context) => _buildMenuItems(),
              onSelected: (value) => _handleMenuSelection(value, context),
            ),
          ),
        ],
      ),
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
    return Column(
      children: [
        // الخط الفاصل
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5),
          child: Divider(
            color: widget.bolt.categoryColor.withOpacity(0.8),
            height: 1.h,
          ),
        ),

        // الأزرار
        Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    _comments.length > 0
                        ? _comments.length.toString()
                        : 'تعليق',
                onTap: () => _showCommentsDialog(context),
              ),
              _buildActionButton(
                icon: Icons.repeat,
                label:
                    widget.bolt.shares > 0
                        ? widget.bolt.shares.toString()
                        : 'شارك',
                onTap: () => print('تم المشاركة'),
              ),
              _buildActionButton(
                icon: Icons.send_outlined,
                label: 'إرسال',
                onTap: () => print('تم الإرسال'),
              ),
            ],
          ),
        ),
      ],
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _navigateToUserProfile(BuildContext context) {
    // إنشاء بيانات وهمية للمستخدم من بيانات البرقية
    final user = UserModel(
      id: widget.bolt.id, // استخدام ID البرقية مؤقتاً
      name: widget.bolt.userName,
      username: widget.bolt.userName.replaceAll(' ', '_').toLowerCase(),
      bio: 'مستخدم نشط في تطبيق البرقيات',
      imageUrl: null, // أو يمكنك استخدام image path
      boltCount: 42, // عدد وهمي
      followersCount: 1200,
      followingCount: 856,
      isFollowing: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VisitProfileScreen(user: user)),
    );
  }
}
