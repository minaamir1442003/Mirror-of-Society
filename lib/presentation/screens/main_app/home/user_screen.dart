import 'package:app_1/presentation/widgets/bolts/user_bolt_card.dart';
import 'package:flutter/material.dart';
import 'package:app_1/core/theme/app_theme.dart';
import 'package:app_1/data/models/user_model.dart';
import 'package:app_1/data/models/bolt_model.dart';

class VisitProfileScreen extends StatefulWidget {
  final UserModel user;
  
  const VisitProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _VisitProfileScreenState createState() => _VisitProfileScreenState();
}

class _VisitProfileScreenState extends State<VisitProfileScreen> {
  bool _isFollowing = false;
  List<BoltModel> _userBolts = [];
  bool _isLoadingBolts = true;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.user.isFollowing;
    _loadUserBolts();
  }

  Future<void> _loadUserBolts() async {
    // محاكاة تحميل البيانات
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      _userBolts = [
        BoltModel(
          id: '1',
          content: 'جلسة برمجة ليلية مع فلاتر، هناك شيء سحري في البرمجة عندما يكون العالم نائماً 🌙💻',
          category: 'تكنولوجيا',
          categoryColor: Colors.purple,
          categoryIcon: Icons.computer,
          createdAt: DateTime.now().subtract(Duration(hours: 3)),
          userName: widget.user.name,
          userImage: "assets/image/images.jpg",
          likes: 89,
          comments: 23,
          shares: 8,
        ),
        BoltModel(
          id: '2',
          content: 'اليوم تعلمت تقنية جديدة في Flutter. التعليم المستمر هو سر النجاح في عالم البرمجة 🚀',
          category: 'تعليم',
          categoryColor: Colors.blue,
          categoryIcon: Icons.school,
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          userName: widget.user.name,
          userImage: "assets/image/images.jpg",
          likes: 120,
          comments: 45,
          shares: 15,
        ),
        BoltModel(
          id: '3',
          content: 'مشاركة في مؤتمر المطورين العرب. دائماً ما تكون مشاركة المعرفة هي أجمل ما في العمل التقني 👨‍💻',
          category: 'فعاليات',
          categoryColor: Colors.orange,
          categoryIcon: Icons.event,
          createdAt: DateTime.now().subtract(Duration(days: 3)),
          userName: widget.user.name,
          userImage: "assets/image/images.jpg",
          likes: 210,
          comments: 67,
          shares: 32,
        ),
        BoltModel(
          id: '4',
          content: 'نصائح للمبرمجين المبتدئين: ابدأ بمشاريع صغيرة، لا تخف من الأخطاء، واستمر في التعلم يومياً 💡',
          category: 'نصائح',
          categoryColor: Colors.teal,
          categoryIcon: Icons.lightbulb,
          createdAt: DateTime.now().subtract(Duration(days: 5)),
          userName: widget.user.name,
          userImage: "assets/image/images.jpg",
          likes: 156,
          comments: 32,
          shares: 21,
        ),
        BoltModel(
          id: '5',
          content: 'مشروع جديد قيد التطوير باستخدام Flutter! يبدو واعداً جداً 🎯',
          category: 'مشاريع',
          categoryColor: Colors.indigo,
          categoryIcon: Icons.rocket_launch,
          createdAt: DateTime.now().subtract(Duration(days: 7)),
          userName: widget.user.name,
          userImage: "assets/image/images.jpg",
          likes: 78,
          comments: 19,
          shares: 12,
        ),
      ];
      _isLoadingBolts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(widget.user.name),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {
            _showOptionsDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCoverImage(),
          _buildProfileInfo(),
          _buildStatsRow(),
          _buildBioSection(),
          _buildFollowButton(),
          SizedBox(height: 20),
          _buildUserBoltsSection(),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.primaryColor.withOpacity(0.4),
          ],
        ),
      ),
      child: Stack(
        children: [
          // صور غلاف عشوائية
          Positioned.fill(
            child: Image.asset(
              _getRandomCoverImage(),
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(0.7),
            ),
          ),
          
          // تأثير التدرج
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 10,
            left: 20,
            child: _buildProfileAvatar(),
          ),
        ],
      ),
    );
  }

  String _getRandomCoverImage() {
    List<String> coverImages = [
      'assets/image/OIP.jpg',
      'assets/image/OIP.jpg',
      'assets/image/OIP.jpg',
      'assets/image/OIP.jpg',
    ];
    
    // يمكنك استخدام ID المستخدم لتحديد صورة ثابتة لكل مستخدم
    int index = widget.user.id.hashCode % coverImages.length;
    return coverImages[index];
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundImage: AssetImage(
          widget.user.imageUrl ?? "assets/image/default_profile.png",
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.alternate_email, size: 16, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(
                          '@${widget.user.username}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            widget.user.boltCount.toString(),
            'البرقيات',
            Icons.bolt,
            AppTheme.primaryColor,
          ),
          _buildStatItem(
            widget.user.followersCount.toString(),
            'المتابِعون',
            Icons.group,
            Colors.green,
          ),
          _buildStatItem(
            widget.user.followingCount.toString(),
            'يَتْبَع',
            Icons.group_add,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: color, size: 22),
          ),
        ),
        SizedBox(height: 8),
        Text(
          _formatNumber(int.parse(value)),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
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

  Widget _buildBioSection() {
    if (widget.user.bio == null || widget.user.bio!.isEmpty) {
      return SizedBox();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'عن المستخدم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            widget.user.bio!,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isFollowing = !_isFollowing;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          _isFollowing ? Icons.check_circle : Icons.add_circle,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _isFollowing 
                              ? 'أنت تتابع الآن ${widget.user.name}'
                              : 'تم إلغاء متابعة ${widget.user.name}',
                        ),
                      ],
                    ),
                    backgroundColor: _isFollowing ? Colors.green : Colors.grey[700],
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing 
                    ? Colors.grey[100]
                    : AppTheme.primaryColor,
                foregroundColor: _isFollowing 
                    ? Colors.black
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _isFollowing 
                        ? Colors.grey[300]!
                        : AppTheme.primaryColor,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isFollowing ? Icons.check : Icons.add,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    _isFollowing ? 'متابع' : 'متابعة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.mail_outline, size: 24),
              color: AppTheme.primaryColor,
              onPressed: () {
                _sendMessage();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBoltsSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bolt,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'برقيات ${widget.user.name}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${_userBolts.length} برقية',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Spacer(),
              PopupMenuButton<String>(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.filter_list, size: 20, color: Colors.grey),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'recent', child: Text('الأحدث')),
                  PopupMenuItem(value: 'popular', child: Text('الأكثر تفاعلاً')),
                  PopupMenuItem(value: 'oldest', child: Text('الأقدم')),
                ],
                onSelected: (value) {
                  // TODO: ترتيب البرقيات
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          
          if (_isLoadingBolts)
            Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          else if (_userBolts.isEmpty)
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(Icons.bolt_outlined, size: 60, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد برقيات بعد',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.user.name} لم ينشر أي برقيات حتى الآن',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: _userBolts
                  .map((bolt) => UserBoltCard(
                        bolt: bolt,
                        isMyProfile: false,
                      ))
                  .toList(),
            ),
          
          if (_userBolts.length > 3)
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // عرض كل البرقيات
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('عرض كل برقيات ${widget.user.name}'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض كل البرقيات',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_left, size: 18),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.settings, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'خيارات ${widget.user.name}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOptionTile(
                  Icons.block,
                  'حظر ${widget.user.name}',
                  Colors.red,
                  _blockUser,
                ),
                _buildOptionTile(
                  Icons.report,
                  'الإبلاغ عن ${widget.user.name}',
                  Colors.orange,
                  _reportUser,
                ),
                _buildOptionTile(
                  Icons.copy,
                  'نسخ رابط الملف الشخصي',
                  Colors.blue,
                  _copyProfileLink,
                ),
                _buildOptionTile(
                  Icons.share,
                  'مشاركة الملف الشخصي',
                  Colors.green,
                  _shareProfile,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _blockUser() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('حظر ${widget.user.name}'),
            content: Text(
              'هل أنت متأكد من حظر ${widget.user.name}؟ '
              'لن تتمكن من رؤية برقياته أو التفاعل معها.',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حظر ${widget.user.name}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('حظر'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _reportUser() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('الإبلاغ عن ${widget.user.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('اختر سبب الإبلاغ:', style: TextStyle(fontSize: 14)),
                SizedBox(height: 16),
                _buildReportOption('محتوى غير لائق'),
                _buildReportOption('انتحال شخصية'),
                _buildReportOption('تحرش'),
                _buildReportOption('مخالفات أخرى'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم الإبلاغ عن ${widget.user.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text('إبلاغ'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportOption(String title) {
    return ListTile(
      leading: Icon(Icons.circle_outlined, size: 16),
      title: Text(title, style: TextStyle(fontSize: 13)),
      onTap: () {},
    );
  }

  void _copyProfileLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 8),
            Text('تم نسخ رابط الملف الشخصي'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('مشاركة ملف ${widget.user.name} الشخصي'),
      ),
    );
  }

  void _sendMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.message, color: Colors.white),
            SizedBox(width: 8),
            Text('فتح محادثة مع ${widget.user.name}'),
          ],
        ),
      ),
    );
  }
}