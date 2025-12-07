// lib/screens/profile_screen.dart
import 'package:app_1/core/theme/app_theme.dart';
import 'package:app_1/data/models/bolt_model.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/main_app/profile/edit_profile_screen.dart';
import 'package:app_1/presentation/screens/main_app/profile/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> _languages = ['العربية', 'English', 'Français', 'Español'];
  LanguageProvider? _languageProvider;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // الحصول على المرجع هنا حيث يكون الـ widget نشطاً
    _languageProvider = Provider.of<LanguageProvider>(context, listen: false);
  }

  Future<void> _loadCurrentLanguage() async {
    // لا تحتاج لتحميل اللغة هنا لأن Provider يتولى ذلك
  }

  @override
  void dispose() {
    // لا تقم بأي عملية تستدعي context في dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(background: _buildCoverImage()),
            ),
            SliverToBoxAdapter(child: _buildProfileContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return Stack(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 350,

              child: Image.asset("assets/image/OIP.jpg", fit: BoxFit.cover),
            ),
            Positioned(
              right: 20,
              top: 30,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
                icon: Icon(Icons.settings, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
        Positioned(bottom: 10, left: 10, child: _buildProfileAvatar()),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white, Colors.grey[100]!]),
            borderRadius: BorderRadius.circular(80),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 68,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 65,
                backgroundImage: AssetImage("assets/image/images.jpg"),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.bookmark,
                color: AppTheme.rankColors[4],
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أحمد محمد',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            SizedBox(width: 6),
                            Text(
                              '@ahmed_dev',
                              style: TextStyle(
                                color: AppTheme.darkGray,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.white, size: 24),
                      onPressed: _goToEditProfile,
                    ),
                  ),
                ],
              ),
              Text(
                'مطور تطبيقات Flutter | مهتم بالتقنية والبرمجة | '
                'أحب مشاركة المعرفة مع المجتمع التقني | '
                'أعمل على مشاريع متنوعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          SizedBox(height: 24),
          _buildStatsRow(),
          SizedBox(height: 32),
          _buildZodiacSection(),
          SizedBox(height: 32),
          _buildInterestChips(),

          SizedBox(height: 32),
          _buildUserBoltsSection(),
          SizedBox(height: 32),
          // قسم اللغة - باستخدام Consumer بشكل آمن
          // _buildLanguageSection(),
        ],
      ),
    );
  }

  Widget _buildUserBoltsSection() {
    // بيانات وهمية لبرقيات المستخدم
    final List<BoltModel> userBolts = [
      BoltModel(
        id: '1',
        content:
            'جلسة برمجة ليلية مع فلاتر، هناك شيء سحري في البرمجة عندما يكون العالم نائماً 🌙💻',
        category: 'تكنولوجيا',
        categoryColor: Colors.purple,
        categoryIcon: Icons.computer,
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        userName: 'أحمد محمد',
        userImage: 'assets/image/images.jpg',
        likes: 89,
        comments: 23,
        shares: 8,
      ),
      BoltModel(
        id: '2',
        content:
            'اليوم تعلمت تقنية جديدة في Flutter. التعليم المستمر هو سر النجاح في عالم البرمجة 🚀',
        category: 'تعليم',
        categoryColor: Colors.blue,
        categoryIcon: Icons.school,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        userName: 'أحمد محمد',
        userImage: 'assets/image/images.jpg',
        likes: 120,
        comments: 45,
        shares: 15,
      ),
      BoltModel(
        id: '3',
        content:
            'مشاركة في مؤتمر المطورين العرب. دائماً ما تكون مشاركة المعرفة هي أجمل ما في العمل التقني 👨‍💻',
        category: 'فعاليات',
        categoryColor: Colors.orange,
        categoryIcon: Icons.event,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        userName: 'أحمد محمد',
        userImage: 'assets/image/images.jpg',
        likes: 210,
        comments: 67,
        shares: 32,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان قسم البرقيات
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(Icons.bolt, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'برقيات ${userBolts.length}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  // عرض كل البرقيات
                },
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // عرض البرقيات
        Column(
          children:
              userBolts.map((bolt) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildBoltItem(bolt),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildBoltItem(BoltModel bolt) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البرقية
          Row(
            children: [
              // أيقونة الفئة
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: bolt.categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  bolt.categoryIcon,
                  size: 18,
                  color: bolt.categoryColor,
                ),
              ),
              SizedBox(width: 10),
              // اسم الفئة
              Text(
                bolt.category,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: bolt.categoryColor,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              // وقت النشر
              Text(
                _formatTime(bolt.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),

          SizedBox(height: 12),

          // محتوى البرقية
          Text(
            bolt.content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 16),

          // إحصائيات التفاعل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الإعجابات
              Row(
                children: [
                  Icon(
                    Icons.emoji_objects,
                    size: 18,
                    color: Colors.amber.shade700,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${bolt.likes}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),

              // التعليقات
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 18, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    '${bolt.comments}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),

              // المشاركات
              Row(
                children: [
                  Icon(Icons.repeat, size: 18, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    '${bolt.shares}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return 'قبل ${difference.inMinutes} د';
    } else if (difference.inHours < 24) {
      return 'قبل ${difference.inHours} س';
    } else if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} ي';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  Widget _buildStatsRow() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.grey[50]!, Colors.white]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('320', 'برقية', Icons.message_outlined),
          _buildStatItem('1.2K', 'متابع', Icons.group_outlined),
          _buildStatItem('856', 'متابَع', Icons.group_add_outlined),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.white],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 22),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.darkGray,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildZodiacSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.amber.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Center(child: Text('♊️', style: TextStyle(fontSize: 40))),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'برج الجوزاء',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'المولودين 21 مايو - 20 يونيو',
                  style: TextStyle(color: Colors.orange[800], fontSize: 14),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      ['اجتماعي', 'ذكي', 'مبدع', 'مرح', 'فضولي', 'متكلم'].map((
                        trait,
                      ) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber[800],
                              ),
                              SizedBox(width: 4),
                              Text(
                                trait,
                                style: TextStyle(
                                  color: Colors.amber[900],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestChips() {
    List<Map<String, dynamic>> interests = [
      {'name': 'تكنولوجيا', 'icon': Icons.code, 'color': Colors.blue},
      {'name': 'برمجة', 'icon': Icons.computer, 'color': Colors.green},
      {'name': 'رياضة', 'icon': Icons.sports_soccer, 'color': Colors.red},
      {'name': 'قراءة', 'icon': Icons.menu_book, 'color': Colors.purple},
      {'name': 'سفر', 'icon': Icons.flight_takeoff, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.interests_outlined, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text(
              'الاهتمامات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              interests.map((interest) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        interest['color'].withOpacity(0.1),
                        interest['color'].withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: interest['color'].withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        interest['icon'],
                        color: interest['color'],
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        interest['name'],
                        style: TextStyle(
                          color: interest['color'],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  // دالة لبناء قسم اللغة - النسخة الآمنة

  String _getLanguageEmoji(String language) {
    switch (language) {
      case 'English':
        return '🇺🇸';
      case 'العربية':
        return '🇸🇦';
      case 'Français':
        return '🇫🇷';
      case 'Español':
        return '🇪🇸';
      default:
        return '🌐';
    }
  }

  void _goToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    ).then((value) {
      if (value != null) {
        setState(() {});
      }
    });
  }

  // دالة لتغيير لغة التطبيق - المحدثة بشكل آمن
  // دالة لتغيير لغة التطبيق - المعدلة للبقاء في الصفحة
  // تعديل دالة _changeAppLanguage في ProfileScreen
  void _changeAppLanguage(
    BuildContext context,
    String language,
    LanguageProvider languageProvider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.language, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'تغيير اللغة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('هل تريد تغيير لغة التطبيق إلى:'),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _getLanguageEmoji(language),
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(width: 12),
                        Text(
                          language,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ملاحظة: سيتم تحديث اللغة فوراً',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(color: AppTheme.darkGray),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 1. إغلاق الـ Dialog أولاً
                    Navigator.pop(context);

                    // 2. استخدام الـ GlobalKey لإظهار رسالة التحميل
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'جاري تغيير اللغة إلى $language...',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppTheme.primaryColor,
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    // 3. تغيير اللغة (دون استخدام context)
                    try {
                      await languageProvider.changeLanguage(language);

                      // 4. إغلاق رسالة التحميل وإظهار رسالة النجاح
                      _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();

                      // 5. إعادة بناء الشاشة لتحديث DropdownButton
                      setState(() {});
                    } catch (error) {
                      _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();

                      _scaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'حدث خطأ في تغيير اللغة',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('تغيير'),
                ),
              ],
            ),
          ),
    );
  }
}
// lib/screens/profile_screen_card_style.dart
// import 'package:flutter/material.dart';
// import 'package:app_1/core/theme/app_theme.dart';
// import 'package:app_1/data/models/bolt_model.dart';

// class ProfileScreenCardStyle extends StatefulWidget {
//   @override
//   _ProfileScreenCardStyleState createState() => _ProfileScreenCardStyleState();
// }

// class _ProfileScreenCardStyleState extends State<ProfileScreenCardStyle> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF8F9FA),
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 220,
//             floating: false,
//             pinned: true,
//             automaticallyImplyLeading: false,
//             backgroundColor: AppTheme.primaryColor,
//             flexibleSpace: _buildHeader(),
//             actions: [
//               IconButton(
//                 onPressed: () {},
//                 icon: Icon(Icons.settings, color: Colors.white, size: 26),
//               ),
//             ],
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 children: [
//                   SizedBox(height: 100),
//                   _buildUserInfo(),
//                   SizedBox(height: 30),
//                   _buildStatsCards(),
//                   SizedBox(height: 25),
//                   _buildZodiacCard(),
//                   SizedBox(height: 25),
//                   _buildInterestsSection(),
//                   SizedBox(height: 25),
//                   _buildBoltsSection(),
//                   SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         backgroundColor: AppTheme.primaryColor,
//         child: Icon(Icons.edit, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Stack(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 AppTheme.primaryColor,
//                 Color(0xFF764BA2),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: 50,
//           left: 0,
//           right: 0,
//           child: Center(
//             child: Container(
//               width: 140,
//               height: 140,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 4),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 15,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: CircleAvatar(
//                 backgroundImage: AssetImage("assets/image/images.jpg"),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildUserInfo() {
//     return Card(
//       elevation: 8,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'أحمد محمد',
//                         style: TextStyle(
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       SizedBox(height: 5),
//                       Row(
//                         children: [
//                           Icon(Icons.alternate_email, size: 16, color: Colors.grey),
//                           SizedBox(width: 5),
//                           Text(
//                             '@ahmed_dev',
//                             style: TextStyle(
//                               color: AppTheme.darkGray,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [AppTheme.primaryColor, Color(0xFF764BA2)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.star, color: Colors.white),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Text(
//               'مطور تطبيقات Flutter | مهتم بالتقنية والبرمجة | '
//               'أحب مشاركة المعرفة مع المجتمع التقني | '
//               'أعمل على مشاريع متنوعة',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[700],
//                 height: 1.6,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsCards() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildStatCard('320', 'برقية', Icons.bolt, AppTheme.primaryColor),
//         ),
//         SizedBox(width: 15),
//         Expanded(
//           child: _buildStatCard('1.2K', 'متابع', Icons.group, Colors.green),
//         ),
//         SizedBox(width: 15),
//         Expanded(
//           child: _buildStatCard('856', 'متابَع', Icons.group_add, Colors.blue),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(String count, String label, IconData icon, Color color) {
//     return Container(
//       height: 120,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color, size: 24),
//           ),
//           SizedBox(height: 10),
//           Text(
//             count,
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           SizedBox(height: 5),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 13,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildZodiacCard() {
//     return Card(
//       elevation: 8,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.amber.shade100, Colors.orange.shade100],
//                 ),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Center(
//                 child: Text('♊️', style: TextStyle(fontSize: 40)),
//               ),
//             ),
//             SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'برج الجوزاء',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFFE65100),
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     '21 مايو - 20 يونيو',
//                     style: TextStyle(
//                       color: Colors.orange[800],
//                       fontSize: 14,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: ['اجتماعي', 'ذكي', 'مبدع', 'مرح'].map((trait) {
//                       return Chip(
//                         label: Text(trait),
//                         backgroundColor: Colors.amber.shade50,
//                         labelStyle: TextStyle(color: Colors.amber.shade900),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInterestsSection() {
//     List<Map<String, dynamic>> interests = [
//       {'name': 'تكنولوجيا', 'icon': Icons.code, 'color': Colors.blue},
//       {'name': 'برمجة', 'icon': Icons.computer, 'color': Colors.green},
//       {'name': 'قراءة', 'icon': Icons.menu_book, 'color': Colors.purple},
//       {'name': 'سفر', 'icon': Icons.flight_takeoff, 'color': Colors.orange},
//       {'name': 'موسيقى', 'icon': Icons.music_note, 'color': Colors.pink},
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: Text(
//             'الاهتمامات',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: AppTheme.secondaryColor,
//             ),
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.all(15),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: interests.map((interest) {
//               return Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: interest['color'].withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(interest['icon'], color: interest['color'], size: 18),
//                     SizedBox(width: 8),
//                     Text(
//                       interest['name'],
//                       style: TextStyle(
//                         color: interest['color'],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBoltsSection() {
//     final List<BoltModel> bolts = [
//       BoltModel(
//         id: '1',
//         content: 'جلسة برمجة ليلية مع فلاتر...',
//         category: 'تكنولوجيا',
//         categoryColor: Colors.purple,
//         categoryIcon: Icons.computer,
//         createdAt: DateTime.now().subtract(Duration(hours: 3)),
//         userName: 'أحمد محمد',
//         userImage: 'assets/image/images.jpg',
//         likes: 89,
//         comments: 23,
//         shares: 8,
//       ),
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               'برقياتي',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: AppTheme.secondaryColor,
//               ),
//             ),
//             Spacer(),
//             TextButton(
//               onPressed: () {},
//               child: Text(
//                 'عرض الكل',
//                 style: TextStyle(color: AppTheme.primaryColor),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 15),
//         ...bolts.map((bolt) {
//           return Container(
//             margin: EdgeInsets.only(bottom: 15),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 ListTile(
//                   leading: CircleAvatar(
//                     backgroundImage: AssetImage(bolt.userImage),
//                   ),
//                   title: Text(bolt.userName),
//                   subtitle: Text(_formatTime(bolt.createdAt)),
//                   trailing: Icon(Icons.more_vert),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     bolt.content,
//                     style: TextStyle(fontSize: 15, height: 1.5),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.favorite_border, size: 18, color: Colors.grey),
//                           SizedBox(width: 5),
//                           Text('${bolt.likes}'),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
//                           SizedBox(width: 5),
//                           Text('${bolt.comments}'),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Icon(Icons.share, size: 18, color: Colors.grey),
//                           SizedBox(width: 5),
//                           Text('${bolt.shares}'),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 10),
//               ],
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   String _formatTime(DateTime time) {
//     final now = DateTime.now();
//     final diff = now.difference(time);
//     if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} د';
//     if (diff.inHours < 24) return 'قبل ${diff.inHours} س';
//     return 'قبل ${diff.inDays} ي';
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:app_1/core/theme/app_theme.dart';
// import 'package:app_1/data/models/bolt_model.dart';

// class ProfileScreenParallax extends StatefulWidget {
//   @override
//   _ProfileScreenParallaxState createState() => _ProfileScreenParallaxState();
// }

// class _ProfileScreenParallaxState extends State<ProfileScreenParallax>
//     with SingleTickerProviderStateMixin {

//   late AnimationController _controller;
//   late Animation<double> _headerAnimation;
//   late Animation<double> _avatarAnimation;
//   late Animation<Color?> _gradientAnimation;
//   ScrollController _scrollController = ScrollController();
//   double _scrollOffset = 0.0;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 800),
//     );

//     _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut)
//     );

//     _avatarAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
//     );

//     _gradientAnimation = ColorTween(
//       begin: AppTheme.primaryColor,
//       end: Colors.black.withOpacity(0.8),
//     ).animate(_controller);

//     _controller.forward();

//     _scrollController.addListener(() {
//       setState(() {
//         _scrollOffset = _scrollController.offset.clamp(0.0, 200.0) / 200.0;
//         _controller.value = _scrollOffset;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: NotificationListener<ScrollNotification>(
//         onNotification: (notification) {
//           if (notification is ScrollEndNotification) {
//             if (_scrollOffset > 0.5) {
//               _controller.reverse();
//             } else {
//               _controller.forward();
//             }
//           }
//           return false;
//         },
//         child: CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             // Animated Header
//             SliverAppBar(
//               expandedHeight: 300,
//               pinned: true,
//               floating: false,
//               elevation: 0,
//               backgroundColor: Colors.transparent,
//               flexibleSpace: AnimatedBuilder(
//                 animation: _controller,
//                 builder: (context, child) {
//                   return FlexibleSpaceBar(
//                     collapseMode: CollapseMode.pin,
//                     background: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             _gradientAnimation.value!,
//                             Colors.black.withOpacity(0.9),
//                           ],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                       ),
//                       child: Stack(
//                         children: [
//                           // Animated Background Pattern
//                           Positioned.fill(
//                             child: Opacity(
//                               opacity: _headerAnimation.value * 0.3,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   image: DecorationImage(
//                                     image: AssetImage("assets/image/OIP.jpg"),
//                                     fit: BoxFit.cover,
//                                     colorFilter: ColorFilter.mode(
//                                       Colors.black.withOpacity(0.5),
//                                       BlendMode.darken,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           // Animated Circles
//                           Positioned(
//                             top: 50,
//                             right: 50,
//                             child: Transform.scale(
//                               scale: _headerAnimation.value,
//                               child: Opacity(
//                                 opacity: _headerAnimation.value * 0.2,
//                                 child: Container(
//                                   width: 100,
//                                   height: 100,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: Colors.white,
//                                       width: 2,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           // Animated Profile Content
//                           Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Transform.translate(
//                                   offset: Offset(0, 50 * (1 - _headerAnimation.value)),
//                                   child: Transform.scale(
//                                     scale: _avatarAnimation.value,
//                                     child: Container(
//                                       width: 150,
//                                       height: 150,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         border: Border.all(
//                                           color: Colors.white,
//                                           width: 4,
//                                         ),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: Colors.black.withOpacity(0.3),
//                                             blurRadius: 20,
//                                             spreadRadius: 5,
//                                           ),
//                                         ],
//                                       ),
//                                       child: ClipOval(
//                                         child: Image.asset(
//                                           "assets/image/images.jpg",
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 20),
//                                 AnimatedOpacity(
//                                   duration: Duration(milliseconds: 300),
//                                   opacity: _headerAnimation.value,
//                                   child: Column(
//                                     children: [
//                                       Text(
//                                         'أحمد محمد',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 28,
//                                           fontWeight: FontWeight.bold,
//                                           shadows: [
//                                             Shadow(
//                                               color: Colors.black,
//                                               blurRadius: 10,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: 5),
//                                       Text(
//                                         '@ahmed_dev',
//                                         style: TextStyle(
//                                           color: Colors.white.withOpacity(0.8),
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Content
//             SliverList(
//               delegate: SliverChildListDelegate([
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.black.withOpacity(0.9),
//                         Colors.black,
//                       ],
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       // Animated Stats Cards
//                       Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: AnimatedStatsRow(),
//                       ),

//                       // Bio Card
//                       _buildBioCard(),

//                       // Tabs
//                       _buildAnimatedTabs(),

//                       // Content
//                       _buildTabContent(),
//                     ],
//                   ),
//                 ),
//               ]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBioCard() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Container(
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.grey[900]!,
//               Colors.black,
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.grey[800]!),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.5),
//               blurRadius: 20,
//               spreadRadius: 5,
//             ),
//           ],
//         ),
//         child: Text(
//           'مطور تطبيقات Flutter | مهتم بالتقنية والبرمجة | '
//           'أحب مشاركة المعرفة مع المجتمع التقني | '
//           'أعمل على مشاريع متنوعة',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey[300],
//             height: 1.6,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedTabs() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20),
//       height: 50,
//       child: Row(
//         children: [
//           Expanded(child: _buildAnimatedTab('البرقيات', 0)),
//           Expanded(child: _buildAnimatedTab('الاهتمامات', 1)),
//           Expanded(child: _buildAnimatedTab('حولي', 2)),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnimatedTab(String title, int index) {
//     bool isSelected = index == 0; // Replace with your logic
//     return GestureDetector(
//       onTap: () {},
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         margin: EdgeInsets.symmetric(horizontal: 5),
//         decoration: BoxDecoration(
//           gradient: isSelected ? LinearGradient(
//             colors: [AppTheme.primaryColor, Colors.purple],
//           ) : null,
//           color: isSelected ? null : Colors.grey[900],
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: isSelected ? Colors.transparent : Colors.grey[800]!,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             title,
//             style: TextStyle(
//               color: isSelected ? Colors.white : Colors.grey[400],
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTabContent() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           _buildAnimatedBoltCard(),
//           SizedBox(height: 20),
//           _buildAnimatedBoltCard(),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnimatedBoltCard() {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.grey[900]!,
//             Colors.black,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey[800]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundColor: AppTheme.primaryColor,
//               child: Icon(Icons.bolt, color: Colors.white),
//             ),
//             title: Text(
//               'تكنولوجيا',
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//             subtitle: Text('قبل 3 ساعات', style: TextStyle(color: Colors.grey[400])),
//             trailing: Icon(Icons.more_vert, color: Colors.grey[400]),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               'جلسة برمجة ليلية مع فلاتر، هناك شيء سحري في البرمجة عندما يكون العالم نائماً 🌙💻',
//               style: TextStyle(
//                 color: Colors.grey[300],
//                 fontSize: 14,
//                 height: 1.5,
//               ),
//             ),
//           ),
//           SizedBox(height: 15),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildAnimatedReactionButton(Icons.favorite_outline, '89'),
//                 _buildAnimatedReactionButton(Icons.chat_bubble_outline, '23'),
//                 _buildAnimatedReactionButton(Icons.share, '8'),
//               ],
//             ),
//           ),
//           SizedBox(height: 10),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnimatedReactionButton(IconData icon, String count) {
//     return GestureDetector(
//       onTapDown: (_) {},
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 200),
//         padding: EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: Colors.grey[400], size: 20),
//             SizedBox(height: 4),
//             Text(
//               count,
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AnimatedStatsRow extends StatefulWidget {
//   @override
//   _AnimatedStatsRowState createState() => _AnimatedStatsRowState();
// }

// class _AnimatedStatsRowState extends State<AnimatedStatsRow>
//     with SingleTickerProviderStateMixin {

//   late AnimationController _controller;
//   late List<Animation<double>> _animations;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1000),
//     );

//     _animations = List.generate(3, (index) {
//       return Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(
//           parent: _controller,
//           curve: Interval(index * 0.2, 1.0, curve: Curves.easeOut),
//         ),
//       );
//     });

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildAnimatedStatCard('320', 'برقيات', Icons.bolt, 0),
//         _buildAnimatedStatCard('1.2K', 'متابعين', Icons.group, 1),
//         _buildAnimatedStatCard('856', 'متابَع', Icons.group_add, 2),
//       ],
//     );
//   }

//   Widget _buildAnimatedStatCard(String value, String label, IconData icon, int index) {
//     return AnimatedBuilder(
//       animation: _animations[index],
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, 50 * (1 - _animations[index].value)),
//           child: Opacity(
//             opacity: _animations[index].value,
//             child: Container(
//               width: 100,
//               padding: EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.grey[900]!,
//                     Colors.black,
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(color: Colors.grey[800]!),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Icon(icon, color: AppTheme.primaryColor, size: 24),
//                   SizedBox(height: 10),
//                   Text(
//                     value,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       color: Colors.grey[400],
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:app_1/core/theme/app_theme.dart';

// class ProfileScreen3D extends StatefulWidget {
//   @override
//   _ProfileScreen3DState createState() => _ProfileScreen3DState();
// }

// class _ProfileScreen3DState extends State<ProfileScreen3D>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _rotationAnimation;
//   late Animation<double> _elevationAnimation;
//   late Animation<Offset> _floatAnimation;
//   double _tiltX = 0.0;
//   double _tiltY = 0.0;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//     )..repeat(reverse: true);

//     _rotationAnimation = Tween<double>(
//       begin: -0.05,
//       end: 0.05,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     _elevationAnimation = Tween<double>(begin: 5, end: 20).animate(_controller);
//     _floatAnimation = Tween<Offset>(
//       begin: Offset(0, 0),
//       end: Offset(0, -10),
//     ).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF121212),
//       body: GestureDetector(
//         onPanUpdate: (details) {
//           setState(() {
//             _tiltX = (details.delta.dy / 1000).clamp(-0.1, 0.1);
//             _tiltY = (details.delta.dx / 1000).clamp(-0.1, 0.1);
//           });
//         },
//         onPanEnd: (_) {
//           setState(() {
//             _tiltX = 0.0;
//             _tiltY = 0.0;
//           });
//         },
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 60),

//               // 3D Profile Card
//               AnimatedBuilder(
//                 animation: _controller,
//                 builder: (context, child) {
//                   return Transform(
//                     transform:
//                         Matrix4.identity()
//                           ..setEntry(3, 2, 0.001)
//                           ..rotateX(_rotationAnimation.value + _tiltX)
//                           ..rotateY(_rotationAnimation.value + _tiltY),
//                     alignment: FractionalOffset.center,
//                     child: Container(
//                       margin: EdgeInsets.symmetric(horizontal: 30),
//                       padding: EdgeInsets.all(30),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(30),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.5),
//                             blurRadius: _elevationAnimation.value,
//                             spreadRadius: 2,
//                             offset: Offset(0, 10),
//                           ),
//                           BoxShadow(
//                             color: AppTheme.primaryColor.withOpacity(0.3),
//                             blurRadius: 20,
//                             spreadRadius: 1,
//                             offset: Offset(0, 0),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           Transform.translate(
//                             offset: _floatAnimation.value,
//                             child: Container(
//                               width: 120,
//                               height: 120,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: RadialGradient(
//                                   colors: [
//                                     AppTheme.primaryColor,
//                                     Colors.purple,
//                                   ],
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: AppTheme.primaryColor.withOpacity(
//                                       0.5,
//                                     ),
//                                     blurRadius: 30,
//                                     spreadRadius: 5,
//                                   ),
//                                 ],
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: ClipOval(
//                                   child: Image.asset(
//                                     "assets/image/images.jpg",
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 25),
//                           Text(
//                             'أحمد محمد',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             '@ahmed_dev',
//                             style: TextStyle(
//                               color: Colors.grey[400],
//                               fontSize: 18,
//                             ),
//                           ),
//                           SizedBox(height: 25),
//                           _build3DStats(),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),

//               SizedBox(height: 40),

//               // Floating Bio Card
//               _buildFloatingBio(),

//               SizedBox(height: 30),

//               // Interactive 3D Tabs
//               _build3DTabs(),

//               SizedBox(height: 30),

//               // Floating Elements
//               _buildFloatingElements(),

//               SizedBox(height: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _build3DStats() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         _build3DStatItem('320', 'برقيات', Icons.bolt),
//         _build3DStatItem('1.2K', 'متابعين', Icons.group),
//         _build3DStatItem('856', 'متابَع', Icons.group_add),
//       ],
//     );
//   }

//   Widget _build3DStatItem(String value, String label, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           width: 70,
//           height: 70,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               colors: [AppTheme.primaryColor, Colors.purple],
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: AppTheme.primaryColor.withOpacity(0.5),
//                 blurRadius: 15,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: Icon(icon, color: Colors.white, size: 28),
//         ),
//         SizedBox(height: 12),
//         Text(
//           value,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 5),
//         Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
//       ],
//     );
//   }

//   Widget _buildFloatingBio() {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: _floatAnimation.value * 0.5,
//           child: Container(
//             margin: EdgeInsets.symmetric(horizontal: 30),
//             padding: EdgeInsets.all(25),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.grey[900]!, Color(0xFF1A1A1A)],
//               ),
//               borderRadius: BorderRadius.circular(25),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.4),
//                   blurRadius: 20,
//                   spreadRadius: 5,
//                   offset: Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Text(
//               'مطور تطبيقات Flutter | مهتم بالتقنية والبرمجة | '
//               'أحب مشاركة المعرفة مع المجتمع التقني | '
//               'أعمل على مشاريع متنوعة',
//               style: TextStyle(
//                 color: Colors.grey[300],
//                 fontSize: 16,
//                 height: 1.6,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         );
//       },
//     );
//   }
//     Widget _build3DTabs() {
//     List<String> tabs = ['البرقيات', 'الاهتمامات', 'حولي'];
//     int selectedIndex = 0; // يمكنك إضافة state لهذا

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 30),
//       child: Row(
//         children: tabs.asMap().entries.map((entry) {
//           int index = entry.key;
//           String title = entry.value;
//           bool isSelected = index == selectedIndex;

//           return Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedIndex = index;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: Duration(milliseconds: 300),
//                 margin: EdgeInsets.symmetric(horizontal: 5),
//                 padding: EdgeInsets.symmetric(vertical: 15),
//                 decoration: BoxDecoration(
//                   gradient: isSelected
//                       ? LinearGradient(
//                           colors: [
//                             AppTheme.primaryColor,
//                             Colors.purple.shade600,
//                           ],
//                         )
//                       : LinearGradient(
//                           colors: [
//                             Colors.grey.shade800,
//                             Colors.grey.shade900,
//                           ],
//                         ),
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: isSelected
//                       ? [
//                           BoxShadow(
//                             color: AppTheme.primaryColor.withOpacity(0.5),
//                             blurRadius: 15,
//                             spreadRadius: 2,
//                           ),
//                         ]
//                       : null,
//                 ),
//                 child: Center(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       color: isSelected ? Colors.white : Colors.grey[400],
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildFloatingElements() {
//     List<Map<String, dynamic>> elements = [
//       {
//         'icon': Icons.bolt,
//         'title': 'الأكثر تفاعلاً',
//         'value': '89',
//         'color': Colors.amber,
//       },
//       {
//         'icon': Icons.star,
//         'title': 'مبدع الشهر',
//         'value': '🥇',
//         'color': Colors.yellow,
//       },
//       {
//         'icon': Icons.trending_up,
//         'title': 'نسبة النمو',
//         'value': '42%',
//         'color': Colors.green,
//       },
//     ];

//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: _floatAnimation.value * 0.3,
//           child: Container(
//             margin: EdgeInsets.symmetric(horizontal: 30),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: elements.map((element) {
//                 return Transform.scale(
//                   scale: 1 + (_controller.value * 0.1),
//                   child: Container(
//                     width: 100,
//                     padding: EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.grey.shade900,
//                           Color(0xFF1A1A1A),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(15),
//                       border: Border.all(
//                         color: element['color'].withOpacity(0.3),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: element['color'].withOpacity(0.2),
//                           blurRadius: 15,
//                           spreadRadius: 2,
//                         ),
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.3),
//                           blurRadius: 10,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: LinearGradient(
//                               colors: [
//                                 element['color'].withOpacity(0.2),
//                                 element['color'].withOpacity(0.1),
//                               ],
//                             ),
//                             border: Border.all(
//                               color: element['color'].withOpacity(0.3),
//                             ),
//                           ),
//                           child: Icon(
//                             element['icon'],
//                             color: element['color'],
//                             size: 20,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           element['value'],
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         Text(
//                           element['title'],
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             fontSize: 12,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         );
//       },
//     );
//   }
//     Widget _buildTabContent(int selectedIndex) {
//     switch (selectedIndex) {
//       case 0: // البرقيات
//         return _buildBoltsContent();
//       case 1: // الاهتمامات
//         return _buildInterestsContent();
//       case 2: // حولي
//         return _buildAboutContent();
//       default:
//         return Container();
//     }
//   }

//   Widget _buildBoltsContent() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.grey.shade900,
//             Color(0xFF1A1A1A),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.4),
//             blurRadius: 20,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.bolt, color: AppTheme.primaryColor),
//               SizedBox(width: 10),
//               Text(
//                 'آخر البرقيات',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Spacer(),
//               Text(
//                 '320',
//                 style: TextStyle(
//                   color: Colors.grey[400],
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 15),
//           // هنا يمكنك إضافة ListView للبرقيات
//           Container(
//             padding: EdgeInsets.all(15),
//             margin: EdgeInsets.only(bottom: 10),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade800.withOpacity(0.5),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.code, color: Colors.blue),
//                 ),
//                 SizedBox(width: 15),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'جلسة برمجة ليلية',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'قبل 3 ساعات',
//                         style: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(Icons.favorite_border, color: Colors.grey[400]),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInterestsContent() {
//     List<Map<String, dynamic>> interests = [
//       {'name': 'تكنولوجيا', 'icon': Icons.code, 'color': Colors.blue},
//       {'name': 'برمجة', 'icon': Icons.computer, 'color': Colors.green},
//       {'name': 'قراءة', 'icon': Icons.menu_book, 'color': Colors.purple},
//       {'name': 'سفر', 'icon': Icons.flight_takeoff, 'color': Colors.orange},
//     ];

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.grey.shade900,
//             Color(0xFF1A1A1A),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.4),
//             blurRadius: 20,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'الاهتمامات',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 15),
//           Wrap(
//             spacing: 10,
//             runSpacing: 10,
//             children: interests.map((interest) {
//               return Container(
//                 padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: interest['color'].withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: interest['color'].withOpacity(0.3),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(interest['icon'], color: interest['color'], size: 18),
//                     SizedBox(width: 8),
//                     Text(
//                       interest['name'],
//                       style: TextStyle(
//                         color: interest['color'],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAboutContent() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.grey.shade900,
//             Color(0xFF1A1A1A),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.4),
//             blurRadius: 20,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'معلومات إضافية',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 15),
//           _buildAboutItem(
//             icon: Icons.calendar_today,
//             title: 'تاريخ الانضمام',
//             value: 'يناير 2023',
//             color: Colors.green,
//           ),
//           SizedBox(height: 10),
//           _buildAboutItem(
//             icon: Icons.location_on,
//             title: 'المكان',
//             value: 'مصر',
//             color: Colors.blue,
//           ),
//           SizedBox(height: 10),
//           _buildAboutItem(
//             icon: Icons.language,
//             title: 'اللغات',
//             value: 'العربية، الإنجليزية',
//             color: Colors.purple,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAboutItem({
//     required IconData icon,
//     required String title,
//     required String value,
//     required Color color,
//   }) {
//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         SizedBox(width: 15),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: Colors.grey[400],
//                   fontSize: 14,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:app_1/core/theme/app_theme.dart';
// import 'package:app_1/data/models/bolt_model.dart';

// class ProfileScreenParallax extends StatefulWidget {
//   @override
//   _ProfileScreenParallaxState createState() => _ProfileScreenParallaxState();
// }

// class _ProfileScreenParallaxState extends State<ProfileScreenParallax> 
//     with SingleTickerProviderStateMixin {
  
//   late AnimationController _controller;
//   late Animation<double> _headerAnimation;
//   late Animation<double> _avatarAnimation;
//   late Animation<Color?> _gradientAnimation;
//   ScrollController _scrollController = ScrollController();
//   double _scrollOffset = 0.0;

//   @override
//   void initState() {
//     super.initState();
    
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 800),
//     );
    
//     _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut)
//     );
    
//     _avatarAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
//     );
    
//     _gradientAnimation = ColorTween(
//       begin: AppTheme.primaryColor,
//       end: Colors.black.withOpacity(0.8),
//     ).animate(_controller);
    
//     _controller.forward();
    
//     _scrollController.addListener(() {
//       setState(() {
//         _scrollOffset = _scrollController.offset.clamp(0.0, 200.0) / 200.0;
//         _controller.value = _scrollOffset;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: NotificationListener<ScrollNotification>(
//         onNotification: (notification) {
//           if (notification is ScrollEndNotification) {
//             if (_scrollOffset > 0.5) {
//               _controller.reverse();
//             } else {
//               _controller.forward();
//             }
//           }
//           return false;
//         },
//         child: CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             // Animated Header
//             SliverAppBar(
//               expandedHeight: 300,
//               pinned: true,
//               floating: false,
//               elevation: 0,
//               backgroundColor: Colors.transparent,
//               flexibleSpace: AnimatedBuilder(
//                 animation: _controller,
//                 builder: (context, child) {
//                   return FlexibleSpaceBar(
//                     collapseMode: CollapseMode.pin,
//                     background: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             _gradientAnimation.value!,
//                             Colors.black.withOpacity(0.9),
//                           ],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                       ),
//                       child: Stack(
//                         children: [
//                           // Animated Background Pattern
//                           Positioned.fill(
//                             child: Opacity(
//                               opacity: _headerAnimation.value * 0.3,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   image: DecorationImage(
//                                     image: AssetImage("assets/image/OIP.jpg"),
//                                     fit: BoxFit.cover,
//                                     colorFilter: ColorFilter.mode(
//                                       Colors.black.withOpacity(0.5),
//                                       BlendMode.darken,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
                          
//                           // Animated Circles
//                           Positioned(
//                             top: 50,
//                             right: 50,
//                             child: Transform.scale(
//                               scale: _headerAnimation.value,
//                               child: Opacity(
//                                 opacity: _headerAnimation.value * 0.2,
//                                 child: Container(
//                                   width: 100,
//                                   height: 100,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: Colors.white,
//                                       width: 2,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
                          
//                           // Animated Profile Content
//                           Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Transform.translate(
//                                   offset: Offset(0, 50 * (1 - _headerAnimation.value)),
//                                   child: Transform.scale(
//                                     scale: _avatarAnimation.value,
//                                     child: Container(
//                                       width: 150,
//                                       height: 150,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         border: Border.all(
//                                           color: Colors.white,
//                                           width: 4,
//                                         ),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: Colors.black.withOpacity(0.3),
//                                             blurRadius: 20,
//                                             spreadRadius: 5,
//                                           ),
//                                         ],
//                                       ),
//                                       child: ClipOval(
//                                         child: Image.asset(
//                                           "assets/image/images.jpg",
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 20),
//                                 AnimatedOpacity(
//                                   duration: Duration(milliseconds: 300),
//                                   opacity: _headerAnimation.value,
//                                   child: Column(
//                                     children: [
//                                       Text(
//                                         'أحمد محمد',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 28,
//                                           fontWeight: FontWeight.bold,
//                                           shadows: [
//                                             Shadow(
//                                               color: Colors.black,
//                                               blurRadius: 10,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: 5),
//                                       Text(
//                                         '@ahmed_dev',
//                                         style: TextStyle(
//                                           color: Colors.white.withOpacity(0.8),
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
            
//             // Content
//             SliverList(
//               delegate: SliverChildListDelegate([
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.black.withOpacity(0.9),
//                         Colors.black,
//                       ],
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       // Animated Stats Cards
//                       Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: AnimatedStatsRow(),
//                       ),
                      
//                       // Bio Card
//                       _buildBioCard(),
                      
//                       // Tabs
//                       _buildAnimatedTabs(),
                      
//                       // Content
//                       _buildTabContent(),
//                     ],
//                   ),
//                 ),
//               ]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBioCard() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Container(
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.grey[900]!,
//               Colors.black,
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.grey[800]!),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.5),
//               blurRadius: 20,
//               spreadRadius: 5,
//             ),
//           ],
//         ),
//         child: Text(
//           'مطور تطبيقات Flutter | مهتم بالتقنية والبرمجة | '
//           'أحب مشاركة المعرفة مع المجتمع التقني | '
//           'أعمل على مشاريع متنوعة',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey[300],
//             height: 1.6,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedTabs() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20),
//       height: 50,
//       child: Row(
//         children: [
//           Expanded(child: _buildAnimatedTab('البرقيات', 0)),
//           Expanded(child: _buildAnimatedTab('الاهتمامات', 1)),
//           Expanded(child: _buildAnimatedTab('حولي', 2)),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnimatedTab(String title, int index) {
//     bool isSelected = index == 0; // Replace with your logic
//     return GestureDetector(
//       onTap: () {},
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         margin: EdgeInsets.symmetric(horizontal: 5),
//         decoration: BoxDecoration(
//           gradient: isSelected ? LinearGradient(
//             colors: [AppTheme.primaryColor, Colors.purple],
//           ) : null,
//           color: isSelected ? null : Colors.grey[900],
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: isSelected ? Colors.transparent : Colors.grey[800]!,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             title,
//             style: TextStyle(
//               color: isSelected ? Colors.white : Colors.grey[400],
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTabContent() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           _buildAnimatedBoltCard(),
//           SizedBox(height: 20),
//           _buildAnimatedBoltCard(),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnimatedBoltCard() {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.grey[900]!,
//             Colors.black,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey[800]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundColor: AppTheme.primaryColor,
//               child: Icon(Icons.bolt, color: Colors.white),
//             ),
//             title: Text(
//               'تكنولوجيا',
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//             subtitle: Text('قبل 3 ساعات', style: TextStyle(color: Colors.grey[400])),
//             trailing: Icon(Icons.more_vert, color: Colors.grey[400]),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               'جلسة برمجة ليلية مع فلاتر، هناك شيء سحري في البرمجة عندما يكون العالم نائماً 🌙💻',
//               style: TextStyle(
//                 color: Colors.grey[300],
//                 fontSize: 14,
//                 height: 1.5,
//               ),
//             ),
//           ),
//           SizedBox(height: 15),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildAnimatedReactionButton(Icons.favorite_outline, '89'),
//                 _buildAnimatedReactionButton(Icons.chat_bubble_outline, '23'),
//                 _buildAnimatedReactionButton(Icons.share, '8'),
//               ],
//             ),
//           ),
//           SizedBox(height: 10),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnimatedReactionButton(IconData icon, String count) {
//     return GestureDetector(
//       onTapDown: (_) {},
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 200),
//         padding: EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: Colors.grey[400], size: 20),
//             SizedBox(height: 4),
//             Text(
//               count,
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AnimatedStatsRow extends StatefulWidget {
//   @override
//   _AnimatedStatsRowState createState() => _AnimatedStatsRowState();
// }

// class _AnimatedStatsRowState extends State<AnimatedStatsRow> 
//     with SingleTickerProviderStateMixin {
  
//   late AnimationController _controller;
//   late List<Animation<double>> _animations;

//   @override
//   void initState() {
//     super.initState();
    
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1000),
//     );
    
//     _animations = List.generate(3, (index) {
//       return Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(
//           parent: _controller,
//           curve: Interval(index * 0.2, 1.0, curve: Curves.easeOut),
//         ),
//       );
//     });
    
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildAnimatedStatCard('320', 'برقيات', Icons.bolt, 0),
//         _buildAnimatedStatCard('1.2K', 'متابعين', Icons.group, 1),
//         _buildAnimatedStatCard('856', 'متابَع', Icons.group_add, 2),
//       ],
//     );
//   }

//   Widget _buildAnimatedStatCard(String value, String label, IconData icon, int index) {
//     return AnimatedBuilder(
//       animation: _animations[index],
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, 50 * (1 - _animations[index].value)),
//           child: Opacity(
//             opacity: _animations[index].value,
//             child: Container(
//               width: 100,
//               padding: EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.grey[900]!,
//                     Colors.black,
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(color: Colors.grey[800]!),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Icon(icon, color: AppTheme.primaryColor, size: 24),
//                   SizedBox(height: 10),
//                   Text(
//                     value,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       color: Colors.grey[400],
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:app_1/core/theme/app_theme.dart';

// class ProfileScreenModernWhite extends StatefulWidget {
//   @override
//   _ProfileScreenModernWhiteState createState() => _ProfileScreenModernWhiteState();
// }

// class _ProfileScreenModernWhiteState extends State<ProfileScreenModernWhite> 
//     with SingleTickerProviderStateMixin {
  
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _opacityAnimation;
  
//   int _selectedSection = 0;
//   List<Map<String, dynamic>> sections = [
//     {'title': 'البرقيات', 'icon': Icons.bolt},
//     {'title': 'المتابعون', 'icon': Icons.group},
//     {'title': 'الاهتمامات', 'icon': Icons.interests},
//     {'title': 'حولي', 'icon': Icons.info},
//   ];

//   @override
//   void initState() {
//     super.initState();
    
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 600),
//     );
    
//     _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut)
//     );
    
//     _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut)
//     );
    
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: AnimatedBuilder(
//           animation: _controller,
//           builder: (context, child) {
//             return Transform.scale(
//               scale: _scaleAnimation.value,
//               child: Opacity(
//                 opacity: _opacityAnimation.value,
//                 child: Column(
//                   children: [
//                     // Header with gradient
//                     Container(
//                       height: 120,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             AppTheme.primaryColor.withOpacity(0.8),
//                             Colors.white,
//                           ],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 24),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 30,
//                               backgroundColor: Colors.white,
//                               child: CircleAvatar(
//                                 radius: 28,
//                                 backgroundImage: AssetImage("assets/image/images.jpg"),
//                               ),
//                             ),
//                             SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'أحمد محمد',
//                                     style: TextStyle(
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     '@ahmed_dev',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.white.withOpacity(0.9),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.edit, color: Colors.white),
//                               onPressed: () {},
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
                    
//                     // Stats Bar
//                     Container(
//                       padding: EdgeInsets.symmetric(vertical: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           _buildStatColumn('320', 'برقيات'),
//                           Container(
//                             width: 1,
//                             height: 20,
//                             color: Colors.grey[200],
//                           ),
//                           _buildStatColumn('1.2K', 'متابعون'),
//                           Container(
//                             width: 1,
//                             height: 20,
//                             color: Colors.grey[200],
//                           ),
//                           _buildStatColumn('856', 'متابَع'),
//                         ],
//                       ),
//                     ),
                    
//                     // Bio Card
//                     Container(
//                       margin: EdgeInsets.all(24),
//                       padding: EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: Colors.grey[100] ?? Colors.grey),
//                       ),
//                       child: Text(
//                         'مطور تطبيقات Flutter | مهتم بالتقنية والبرمجة | '
//                         'أحب مشاركة المعرفة مع المجتمع التقني',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[700],
//                           height: 1.6,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
                    
//                     // Sections Navigation
//                     Container(
//                       height: 80,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: sections.length,
//                         itemBuilder: (context, index) {
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _selectedSection = index;
//                               });
//                             },
//                             child: Container(
//                               width: 100,
//                               margin: EdgeInsets.symmetric(horizontal: 8),
//                               decoration: BoxDecoration(
//                                 color: _selectedSection == index 
//                                     ? AppTheme.primaryColor 
//                                     : Colors.grey[50],
//                                 borderRadius: BorderRadius.circular(15),
//                                 border: Border.all(
//                                   color: _selectedSection == index
//                                       ? AppTheme.primaryColor
//                                       : Colors.grey[200] ?? Colors.grey,
//                                 ),
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     sections[index]['icon'],
//                                     color: _selectedSection == index
//                                         ? Colors.white
//                                         : AppTheme.primaryColor,
//                                     size: 24,
//                                   ),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     sections[index]['title'],
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                       color: _selectedSection == index
//                                           ? Colors.white
//                                           : Colors.grey[700],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
                    
//                     // Content Area
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 24),
//                         child: _buildSectionContent(),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildStatColumn(String value, String label) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: AppTheme.primaryColor,
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionContent() {
//     switch (_selectedSection) {
//       case 0:
//         return _buildBoltsContent();
//       case 1:
//         return _buildFollowersContent();
//       case 2:
//         return _buildInterestsContent();
//       case 3:
//         return _buildAboutContent();
//       default:
//         return Container();
//     }
//   }

//   Widget _buildBoltsContent() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: ListView.builder(
//         physics: BouncingScrollPhysics(),
//         itemCount: 3,
//         itemBuilder: (context, index) {
//           return Container(
//             margin: EdgeInsets.only(bottom: 16,top: 15),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Colors.blue.shade50,
//                     child: Icon(Icons.code, color: Colors.blue),
//                   ),
//                   title: Text(
//                     'جلسة برمجة ليلية',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   subtitle: Text('قبل 3 ساعات'),
//                   trailing: Icon(Icons.more_vert, color: Colors.grey[400]),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     'جلسة برمجة ليلية مع فلاتر، هناك شيء سحري في البرمجة عندما يكون العالم نائماً 🌙💻',
//                     style: TextStyle(
//                       color: Colors.grey[700],
//                       fontSize: 14,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     children: [
//                       _buildReactionButton(Icons.favorite_outline, '89'),
//                       SizedBox(width: 16),
//                       _buildReactionButton(Icons.chat_bubble_outline, '23'),
//                       SizedBox(width: 16),
//                       _buildReactionButton(Icons.share, '8'),
//                       Spacer(),
//                       Icon(Icons.bookmark_border, color: Colors.grey[400]),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 12),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildReactionButton(IconData icon, String count) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: Colors.grey[600]),
//           SizedBox(width: 4),
//           Text(
//             count,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFollowersContent() {
//     List<Map<String, dynamic>> followers = [
//       {'name': 'محمد أحمد', 'image': '', 'bio': 'مطور ويب'},
//       {'name': 'سارة علي', 'image': '', 'bio': 'مصممة UI/UX'},
//       {'name': 'خالد حسن', 'image': '', 'bio': 'مهندس برمجيات'},
//     ];

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: ListView.builder(
//         physics: BouncingScrollPhysics(),
//         itemCount: followers.length,
//         itemBuilder: (context, index) {
//           return Container(
//             margin: EdgeInsets.only(bottom: 12),
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey),
//             ),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
//                   child: Icon(Icons.person, color: AppTheme.primaryColor),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         followers[index]['name'],
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         followers[index]['bio'],
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: AppTheme.primaryColor,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                       side: BorderSide(color: AppTheme.primaryColor),
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   ),
//                   child: Text('متابعة'),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInterestsContent() {
//     List<Map<String, dynamic>> interests = [
//       {'name': 'تكنولوجيا', 'icon': Icons.code, 'color': Colors.blue},
//       {'name': 'برمجة', 'icon': Icons.computer, 'color': Colors.green},
//       {'name': 'قراءة', 'icon': Icons.menu_book, 'color': Colors.purple},
//       {'name': 'سفر', 'icon': Icons.flight_takeoff, 'color': Colors.orange},
//     ];

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: GridView.builder(
//         physics: BouncingScrollPhysics(),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           childAspectRatio: 2,
//         ),
//         itemCount: interests.length,
//         itemBuilder: (context, index) {
//           return Container(
//             decoration: BoxDecoration(
//               color: interests[index]['color'].withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: interests[index]['color'].withOpacity(0.2),
//               ),
//             ),
//             child: Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     interests[index]['icon'],
//                     color: interests[index]['color'],
//                     size: 20,
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     interests[index]['name'],
//                     style: TextStyle(
//                       color: interests[index]['color'],
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAboutContent() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildAboutItem(
//               title: 'البرج',
//               value: 'الجوزاء',
//               icon: Icons.star,
//               color: Colors.amber,
//             ),
//             SizedBox(height: 16),
//             _buildAboutItem(
//               title: 'تاريخ الانضمام',
//               value: 'يناير 2023',
//               icon: Icons.calendar_today,
//               color: Colors.blue,
//             ),
//             SizedBox(height: 16),
//             _buildAboutItem(
//               title: 'المكان',
//               value: 'مصر',
//               icon: Icons.location_on,
//               color: Colors.green,
//             ),
//             SizedBox(height: 16),
//             _buildAboutItem(
//               title: 'اللغات',
//               value: 'العربية، الإنجليزية',
//               icon: Icons.language,
//               color: Colors.purple,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAboutItem({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 5,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
