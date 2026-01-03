import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/comment_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/like_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/repost_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/screen/comments_bottom_sheet.dart';
import 'package:app_1/presentation/screens/main_app/profile/screen/likes_bottom_sheet.dart';
import 'package:app_1/presentation/screens/main_app/profile/screen/reposts_bottom_sheet.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
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

  void _handleLikeAction(BuildContext context) {
    _toggleLike();
  }

  void _showLikesBottomSheet(BuildContext context) {
    final likeCubit = BlocProvider.of<LikeCubit>(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (context) {
        return LikesBottomSheet(
          telegramId: widget.bolt.id,
          likeCubit: likeCubit,
        );
      },
    );
  }

  void _showCommentsBottomSheet(BuildContext context) {
    final commentCubit = BlocProvider.of<CommentCubit>(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (context) {
        return CommentsBottomSheet(
          telegramId: widget.bolt.id,
          commentCubit: commentCubit,
        );
      },
    );
  }

  void _handleRepostAction(BuildContext context) {
    _toggleRepost();
  }

  void _showRepostsBottomSheet(BuildContext context) {
    final repostCubit = BlocProvider.of<RepostCubit>(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (context) {
        return RepostsBottomSheet(
          telegramId: widget.bolt.id,
          repostCubit: repostCubit,
        );
      },
    );
  }

  Widget _buildUserInfo() {
    return GestureDetector(
      onTap: () {
        _navigateToUserProfile(context);
      },
      child: Stack(
        children: [
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UserProfileScreen(
                            userId: widget.bolt.userId!,
                            initialName: widget.bolt.userName,
                            initialImage: widget.bolt.userImage,
                          ),
                    ),
                  );
                },

                child: Container(
              
                
                  height: 60,
                  child: Center(
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundImage:
                          widget.bolt.userImage.startsWith('http')
                              ? NetworkImage(widget.bolt.userImage)
                              : AssetImage(widget.bolt.userImage) as ImageProvider,
                    ),
                  ),
                ),
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
          ),  context.watch<LanguageProvider>().getCurrentLanguageName() ==
                      'العربية'
                  ? Positioned(
                    bottom: -2,
                    right: 23.w,
                    child: Icon(
                      Icons.bookmark,
                      color: _getRankColor(widget.bolt.userRank.toString()),
                      size: 22.sp,
                    ),
                  )
                  : Positioned(
                    bottom: -2,
                    left: 22.w,
                    child: Icon(
                      Icons.bookmark,
                      color: _getRankColor(widget.bolt.userRank.toString()),
                      size: 21.sp,
                    ),
                  ),
          
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
    
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الإعجاب - اللمبة للإعجاب، الرقم لقائمة المعجبين
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // اللمبة - للإعجاب
              GestureDetector(
                onTap: () => _handleLikeAction(context),
                child: Icon(
                  _isLiked ? Icons.emoji_objects : Icons.emoji_objects_outlined,
                  color: _isLiked ? Colors.amber[700]! : Colors.grey.shade600,
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 4.h),
              // الرقم - لقائمة المعجبين
              GestureDetector(
                onTap: () {
                  if (_currentLikes > 0) {
                    _showLikesBottomSheet(context);
                  }
                },
                child: Text(
                  _currentLikes > 0 ? _currentLikes.toString() : 'ضوء',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color:
                        _currentLikes > 0
                            ? (_isLiked
                                ? Colors.amber[700]!
                                : Colors.grey.shade700)
                            : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          // زر التعليقات - أيقونة أو رقم للتعليقات
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة - لفتح التعليقات
              GestureDetector(
                onTap: () => _showCommentsBottomSheet(context),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey.shade600,
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 4.h),
              // الرقم - لفتح التعليقات أيضاً
              GestureDetector(
                onTap: () => _showCommentsBottomSheet(context),
                child: Text(
                  widget.bolt.comments > 0
                      ? widget.bolt.comments.toString()
                      : 'تعليق',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          // زر إعادة النشر - الأيقونة للإعادة النشر، الرقم لقائمة المعيدين
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة - لإعادة النشر
              GestureDetector(
                onTap: () => _handleRepostAction(context),
                child: Icon(
                  Icons.repeat,
                  color: _isReposted ? Colors.green : Colors.grey.shade600,
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 4.h),
              // الرقم - لقائمة المعيدين
              GestureDetector(
                onTap: () {
                  if (_currentShares > 0) {
                    _showRepostsBottomSheet(context);
                  }
                },
                child: Text(
                  _currentShares > 0 ? _currentShares.toString() : 'شارك',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color:
                        _currentShares > 0
                            ? (_isReposted
                                ? Colors.green
                                : Colors.grey.shade700)
                            : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          // زر الإرسال
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => print('تم الإرسال'),
                child: Icon(
                  Icons.send_outlined,
                  color: Colors.grey.shade600,
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: () => print('تم الإرسال'),
                child: Text(
                  'إرسال',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // المحتوى الرئيسي للبطاقة
          _buildMainCard(),
          SizedBox(height: 10),
          
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // الشريط الجانبي الملون (الجزء الأيسر)
        Container(
          margin: EdgeInsets.only(top: 9),
          width: 30.w,
          height: widget.bolt.content.length > 100 ? 80.h : 70.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            color: widget.bolt.categoryColor,
          ),
          child: Icon(
            Icons.lightbulb_outline,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 7.w),

        // البطاقة الرئيسية (الجزء الأيمن)
        Expanded(
          child: Column(
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
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      context
                                  .watch<LanguageProvider>()
                                  .getCurrentLanguageName() ==
                              'العربية'
                          ? BorderRadius.only(topRight: Radius.circular(100.r))
                          : BorderRadius.only(topLeft: Radius.circular(100.r)),
                  boxShadow: [
                     BoxShadow(
                    color: Colors.black.withOpacity(0.3), // تغيير اللون إلى أسود
                    blurRadius: 8.r,
                    spreadRadius: 2.r,
                    offset: Offset(0, 3),
                  ),
                    // BoxShadow(
                    //   color: widget.bolt.categoryColor.withOpacity(0.8),
                    //   blurRadius: 8.r,
                    //   spreadRadius: 2.r,
                    //   offset: Offset(0, 2),
                    // ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child:
                          context
                                      .watch<LanguageProvider>()
                                      .getCurrentLanguageName() ==
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 10.h,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 5.h),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.center,
                              child: Text(
                                widget.bolt.content,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height:12,),
              _buildActionsSection(),
            ],
          ),
        ),
      ],
    );
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
    final isArabic =
        Provider.of<LanguageProvider>(
          context,
          listen: false,
        ).getCurrentLanguageName() ==
        'العربية';

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
            Text(
              isArabic ? 'حفظ البرقية' : 'Save Telegram',
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'copy',
        child: Row(
          children: [
            Icon(Icons.copy, size: 18.sp, color: Colors.grey.shade700),
            SizedBox(width: 8.w),
            Text(
              isArabic ? 'نسخ النص' : 'Copy Text',
              style: TextStyle(fontSize: 12.sp),
            ),
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
              isArabic ? 'الإبلاغ' : 'Report',
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
            Text(
              isArabic ? 'إخفاء' : 'Hide',
              style: TextStyle(fontSize: 12.sp),
            ),
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
              isArabic ? 'حظر المستخدم' : 'Block User',
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

  void _showReportDialog(BuildContext context) {
    final isArabic =
        Provider.of<LanguageProvider>(
          context,
          listen: false,
        ).getCurrentLanguageName() ==
        'العربية';

    showDialog(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Text(
                isArabic ? 'الإبلاغ عن المحتوى' : 'Report Content',
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
                      isArabic
                          ? 'اختر سبب الإبلاغ عن هذه البرقية:'
                          : 'Select a reason for reporting this telegram:',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildReportOption(
                      context,
                      isArabic ? 'محتوى غير لائق' : 'Inappropriate content',
                      Icons.block,
                    ),
                    _buildReportOption(
                      context,
                      isArabic ? 'معلومات مضللة' : 'Misleading information',
                      Icons.warning,
                    ),
                    _buildReportOption(
                      context,
                      isArabic ? 'محتوى مسيء' : 'Offensive content',
                      Icons.report_problem,
                    ),
                    _buildReportOption(
                      context,
                      isArabic ? 'انتحال شخصية' : 'Impersonation',
                      Icons.person_off,
                    ),
                    _buildReportOption(
                      context,
                      isArabic ? 'محتوى عنيف' : 'Violent content',
                      Icons.gpp_bad,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    isArabic ? 'إلغاء' : 'Cancel',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic
                              ? 'تم الإبلاغ عن البرقية بنجاح'
                              : 'Report submitted successfully',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(isArabic ? 'إبلاغ' : 'Report'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildReportOption(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.red.shade600, size: 20.sp),
      title: Text(title, style: TextStyle(fontSize: 12.sp)),
      onTap: () {
        print('Selected report reason: $title');
      },
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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

  void _navigateToUserProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => UserProfileScreen(
              userId: widget.bolt.userId!,
              initialName: widget.bolt.userName,
              initialImage: widget.bolt.userImage,
            ),
      ),
    );
  }
}
