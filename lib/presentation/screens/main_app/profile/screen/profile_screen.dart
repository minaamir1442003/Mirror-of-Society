import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/auth_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/core/theme/app_theme.dart';
import 'package:app_1/presentation/screens/main_app/profile/edit_profile_screen.dart';
import 'package:app_1/presentation/screens/main_app/profile/settings_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _setupScrollController();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasMoreData) {
          _loadMore();
        }
      }
    });
  }

  void _loadProfile() {
    final profileCubit = context.read<ProfileCubit>();
    _isLoadingMore = false;
    _hasMoreData = true;

    if (widget.userId == null) {
      profileCubit.getMyProfile();
    } else {
      profileCubit.getUserProfile(widget.userId!);
    }
  }

  void _loadMore() {
    final profileCubit = context.read<ProfileCubit>();

    if (!_isLoadingMore && _hasMoreData && profileCubit.hasMore) {
      _isLoadingMore = true;
      print('🔄 Loading more data...');

      if (widget.userId == null) {
        profileCubit.getMyProfile(loadMore: true).then((_) {
          _isLoadingMore = false;
        });
      } else {
        profileCubit.getUserProfile(widget.userId!, loadMore: true).then((_) {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }

          if (state is ProfileLoaded || state is ProfileUpdated) {
            final cubit = context.read<ProfileCubit>();
            _hasMoreData = cubit.hasMore;
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return _buildLoading();
          } else if (state is ProfileLoadingMore) {
            return _buildProfileContent(state);
          } else if (state is ProfileError) {
            return _buildError(state);
          } else if (state is ProfileLoaded || state is ProfileUpdated) {
            return _buildProfileContent(state);
          }
          return _buildLoading();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(color: AppTheme.primaryColor),
    );
  }

  Widget _buildError(ProfileError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(state.error, textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProfile,
            child: Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(ProfileState state) {
    UserProfileModel profile;
    List<TelegramModel> telegrams;
    bool isLoadingMore = false;

    if (state is ProfileLoadingMore) {
      profile = _getCurrentProfileFromCubit();
      telegrams = state.telegrams;
      isLoadingMore = true;
    } else if (state is ProfileLoaded) {
      profile = state.profile;
      telegrams = profile.telegrams;
    } else if (state is ProfileUpdated) {
      profile = state.profile;
      telegrams = profile.telegrams;
    } else {
      profile = _getCurrentProfileFromCubit();
      telegrams = [];
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildCoverImage(profile),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              // مربع توثيق الحساب (يظهر فقط إذا كان الرانك = 0)
              if (widget.userId == null && profile.rank == "0")
                _buildVerificationBox(),
              
              _buildProfileDetails(profile),
            ],
          ),
        ),
        _buildTelegramsSliver(telegrams, profile),
        _buildLoadingMoreIndicator(isLoadingMore),
      ],
    );
  }

  // مربع توثيق الحساب المعدل (تصميم أهدأ)
  Widget _buildVerificationBox() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان مع أيقونة
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.verified_outlined,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حسابك غير موثق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ارتقِ برتبتك إلى المستوى التالي',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // النص التوضيحي
          Text(
            'توثيق حسابك يمنحك مزايا حصرية ويحسن من ظهورك في المجتمع.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          
          
          
          
          
          SizedBox(height: 20),
          
          // الأزرار
          Row(
            children: [
              // زر تفعيل الحساب
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bolt,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'تفعيل الحساب',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              // زر تخطي
              Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                  
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'تخطي',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
        
        ],
      ),
    );
  }



  







  UserProfileModel _getCurrentProfileFromCubit() {
    final cubit = context.read<ProfileCubit>();
    return UserProfileModel(
      id: 0,
      firstname: '',
      lastname: '',
      email: '',
      rank: '0',
      phone: '',
      bio: '',
      image: '',
      cover: '',
      zodiac: '',
      zodiacDescription: '',
      shareLocation: false,
      shareZodiac: false,
      birthdate: DateTime.now(),
      country: '',
      interests: [],
      statistics: ProfileStatistics(
        followersCount: 0,
        followingCount: 0,
        telegramsCount: 0,
      ),
      telegrams: [],
    );
  }

  Widget _buildCoverImage(UserProfileModel profile) {
    return Stack(
      children: [
        profile.cover.isNotEmpty
            ? Container(
                width: double.infinity,
                height: 350,
                child: Image.network(profile.cover, fit: BoxFit.cover),
              )
            : Container(
                width: double.infinity,
                height: 350,
                color: Colors.grey,
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

        Positioned(bottom: 10, left: 10, child: _buildProfileAvatar(profile)),

        Positioned(
          bottom: 5.h,
          left: 90.w,
          child: Icon(
            Icons.bookmark,
            color: _getRankColor(profile.rank),
            size: 45,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(UserProfileModel profile) {
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
              child: profile.image.isNotEmpty
                  ? CircleAvatar(
                      radius: 65,
                      backgroundImage: NetworkImage(profile.image),
                    )
                  : CircleAvatar(backgroundColor: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(UserProfileModel profile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage(
            "assets/image/154eb93e-c23b-41be-a5d2-c50ef02739d3.png",
          ),
          repeat: ImageRepeat.repeat,
          opacity: 0.5,
          colorFilter: ColorFilter.mode(
            Colors.grey[200]!.withOpacity(0.2),
            BlendMode.modulate,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 60, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile.fullName,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            '${_getZodiacEmoji(profile.zodiac)}',
                            style: TextStyle(fontSize: 30),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          SizedBox(width: 6),
                          Text(
                            profile.username,
                            style: TextStyle(
                              color: AppTheme.darkGray,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
                if (widget.userId == null)
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.white, size: 24),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(),
                          ),
                        ).then((value) {
                          if (value == true) {
                            _loadProfile();
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),

            // البايو
            Text(
              profile.bio,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),

            SizedBox(height: 20),

            // مربع معلومات البرج
            if (profile.shareZodiac && profile.zodiac.isNotEmpty)
              _buildZodiacInfoCard(profile),

            SizedBox(height: 24),
            _buildStatsRow(profile.statistics),

            SizedBox(height: 32),
            _buildInterestChips(profile.interests),

          
          ],
        ),
      ),
    );
  }

  // دالة جديدة لعرض معلومات البرج
  Widget _buildZodiacInfoCard(UserProfileModel profile) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF8F9FA),
            Color(0xFFE9ECEF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صف يحتوي على أيقونة واسم البرج
          Row(
            children: [
              // أيقونة البرج
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getZodiacColor(profile.zodiac),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getZodiacColor(profile.zodiac).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getZodiacEmoji(profile.zodiac),
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ),
              
              SizedBox(width: 16),
              
              // اسم البرج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'برج ${profile.zodiac}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _getZodiacColor(profile.zodiac),
                      ),
                    ),
                    Text(
                      '${_getZodiacSymbol(profile.zodiac)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // خط فاصل
          Divider(
            color: Colors.grey[300],
            height: 1,
            thickness: 1,
          ),
          
          SizedBox(height: 16),
          
          // وصف البرج
          Text(
            profile.zodiacDescription.isNotEmpty 
                ? profile.zodiacDescription 
                : '${profile.zodiac} قادة بالفطرة. إنهم دراميون ومبدعون وواثقون من أنفسهم ومهيمنون ومن الصعب للغاية مقاومتهم.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
          
          SizedBox(height: 10),
          
          // معلومات إضافية
          Row(
            children: [
              Icon(
                Icons.cake,
                size: 18,
                color: Colors.grey[600],
              ),
              SizedBox(width: 8),
              Text(
                _formatBirthdate(profile.birthdate),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              SizedBox(width: 20),
              
              Icon(
                Icons.location_on,
                size: 18,
                color: Colors.grey[600],
              ),
              SizedBox(width: 8),
              Text(
                profile.country,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // دالة مساعدة للحصول على لون البرج
  Color _getZodiacColor(String zodiac) {
    switch (zodiac.toLowerCase()) {
      case 'الحمل':
      case 'aries':
        return Color(0xFFE74C3C); // أحمر
      case 'الثور':
      case 'taurus':
        return Color(0xFF27AE60); // أخضر
      case 'الجوزاء':
      case 'gemini':
        return Color(0xFFF39C12); // أصفر
      case 'السرطان':
      case 'cancer':
        return Color(0xFF3498DB); // أزرق
      case 'الأسد':
      case 'leo':
        return Color(0xFFE67E22); // برتقالي
      case 'العذراء':
      case 'virgo':
        return Color(0xFF9B59B6); // بنفسجي
      case 'الميزان':
      case 'libra':
        return Color(0xFF1ABC9C); // فيروزي
      case 'العقرب':
      case 'scorpio':
        return Color(0xFFE74C3C); // أحمر داكن
      case 'القوس':
      case 'sagittarius':
        return Color(0xFFF1C40F); // ذهبي
      case 'الجدي':
      case 'capricorn':
        return Color(0xFF34495E); // رمادي داكن
      case 'الدلو':
      case 'aquarius':
        return Color(0xFF2980B9); // أزرق سماوي
      case 'الحوت':
      case 'pisces':
        return Color(0xFF8E44AD); // أرجواني
      default:
        return AppTheme.primaryColor;
    }
  }

  // دالة مساعدة للحصول على رمز البرج
  String _getZodiacSymbol(String zodiac) {
    switch (zodiac.toLowerCase()) {
      case 'الحمل':
      case 'aries':
        return '♈ البرج الناري | 21 مارس - 19 أبريل';
      case 'الثور':
      case 'taurus':
        return '♉ البرج الترابي | 20 أبريل - 20 مايو';
      case 'الجوزاء':
      case 'gemini':
        return '♊ البرج الهوائي | 21 مايو - 20 يونيو';
      case 'السرطان':
      case 'cancer':
        return '♋ البرج المائي | 21 يونيو - 22 يوليو';
      case 'الأسد':
      case 'leo':
        return '♌ البرج الناري | 23 يوليو - 22 أغسطس';
      case 'العذراء':
      case 'virgo':
        return '♍ البرج الترابي | 23 أغسطس - 22 سبتمبر';
      case 'الميزان':
      case 'libra':
        return '♎ البرج الهوائي | 23 سبتمبر - 22 أكتوبر';
      case 'العقرب':
      case 'scorpio':
        return '♏ البرج المائي | 23 أكتوبر - 21 نوفمبر';
      case 'القوس':
      case 'sagittarius':
        return '♐ البرج الناري | 22 نوفمبر - 21 ديسمبر';
      case 'الجدي':
      case 'capricorn':
        return '♑ البرج الترابي | 22 ديسمبر - 19 يناير';
      case 'الدلو':
      case 'aquarius':
        return '♒ البرج الهوائي | 20 يناير - 18 فبراير';
      case 'الحوت':
      case 'pisces':
        return '♓ البرج المائي | 19 فبراير - 20 مارس';
      default:
        return '♈';
    }
  }

  // دالة مساعدة لتنسيق تاريخ الميلاد
  String _formatBirthdate(DateTime birthdate) {
    final arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    
    return '${birthdate.day} ${arabicMonths[birthdate.month - 1]} ${birthdate.year}';
  }

  Widget _buildStatsRow(ProfileStatistics stats) {
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
          _buildStatItem(
            stats.telegramsCount.toString(),
            'المنشورات',
            Icons.message_outlined,
            Colors.orange,
          ),
          _buildStatItem(
            stats.followersCount.toString(),
            'متابعون',
            Icons.group_outlined,
            Colors.green,
          ),
          _buildStatItem(
            stats.followingCount.toString(),
            'متابَعون',
            Icons.group_add_outlined,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), Colors.white],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
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

  Widget _buildInterestChips(List<InterestModel> interests) {
    if (interests.isEmpty) return SizedBox();

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
          children: interests.map((interest) {
            final color = _parseColor(interest.color);
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getInterestIcon(interest.name),
                    color: color,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    interest.name,
                    style: TextStyle(
                      color: color,
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

  

  Widget _buildTelegramsSliver(
    List<TelegramModel> telegrams,
    UserProfileModel profile,
  ) {
    final cubit = context.read<ProfileCubit>();

    if (telegrams.isEmpty && cubit.isFirstLoad) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50),
              Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'لا توجد برقيات',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final telegram = telegrams[index];
        final orderNumber = index + 1;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: _buildTelegramCard(telegram, profile, orderNumber),
        );
      }, childCount: telegrams.length),
    );
  }

  Widget _buildTelegramCard(
    TelegramModel telegram,
    UserProfileModel profile,
    int orderNumber,
  ) {
    final color = _parseColor(telegram.category.color);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // الشريط الجانبي الملون برقم الترتيب
        Container(
          width: 30.w,
          height: 75.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            color: color,
          ),
          child: Center(
            child: Text(
              '#${telegram.number}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        SizedBox(width: 8.w),

        // البطاقة الرئيسية
        Expanded(
          child: Column(
            children: [
              // البطاقة العلوية
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: context
                              .watch<LanguageProvider>()
                              .getCurrentLanguageName() ==
                          'العربية'
                      ? BorderRadius.only(topRight: Radius.circular(100.r))
                      : BorderRadius.only(topLeft: Radius.circular(100.r)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.8),
                      blurRadius: 8.r,
                      spreadRadius: 2.r,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: context
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
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 80.w,
                                padding: EdgeInsets.only(top: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 17.r,
                                      backgroundImage: NetworkImage(
                                        telegram.user.image.isNotEmpty
                                            ? telegram.user.image
                                            : profile.image,
                                          
                                      ),
                                      
                                      backgroundColor: Colors.grey[200],
                                    ),
                                    SizedBox(height: 7.h),
                                    Text(
                                      telegram.user.name,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _formatTime(telegram.createdAt),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              context
                                          .watch<LanguageProvider>()
                                          .getCurrentLanguageName() ==
                                      'العربية'
                                  ? Positioned(
                                      top: 25.h,
                                      left: 20.w,
                                      child: Icon(
                                        Icons.bookmark,
                                        color: _getRankColor(telegram.user.rank),
                                        size: 20.sp,
                                      ),
                                    )
                                  : Positioned(
                                      bottom: 27.h,
                                      right: 18.w,
                                      child: Icon(
                                        Icons.bookmark,
                                        color: _getRankColor(telegram.user.rank),
                                        size: 20.sp,
                                      ),
                                    ),
                            ],
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Text(
                              telegram.content,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          if (widget.userId == null)
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.more_vert,
                                size: 20.sp,
                                color: Colors.grey[600],
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18.sp,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'حذف البرقية',
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 18.sp,
                                        color: Colors.grey[700],
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'تعديل',
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _showDeleteDialog(context, telegram.id);
                                } else if (value == 'edit') {
                                  // تعديل البرقية
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      icon: Icons.favorite_border,
                      label: telegram.likesCount > 0
                          ? telegram.likesCount.toString()
                          : 'إعجاب',
                      onTap: () => _handleLike(telegram),
                      color: Colors.red,
                    ),
                    _buildActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: telegram.commentsCount > 0
                          ? telegram.commentsCount.toString()
                          : 'تعليق',
                      onTap: () => _showCommentsDialog(context, telegram),
                      color: Colors.blue,
                    ),
                    _buildActionButton(
                      icon: Icons.repeat,
                      label: telegram.repostsCount > 0
                          ? telegram.repostsCount.toString()
                          : 'إعادة نشر',
                      onTap: () => _handleRepost(telegram),
                      color: Colors.green,
                    ),
                  ],
                ),
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
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color ?? Colors.grey[600], size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator(bool isLoadingMore) {
    final cubit = context.read<ProfileCubit>();

    if (isLoadingMore) {
      return SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: AppTheme.primaryColor),
                SizedBox(height: 8),
                Text(
                  'جاري تحميل المزيد...',
                  style: TextStyle(color: AppTheme.darkGray, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (!cubit.hasMore && cubit.telegramsCount > 0) {
      return SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'تم تحميل جميع البرقيات',
              style: TextStyle(color: AppTheme.darkGray, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(child: SizedBox());
  }

  void _showDeleteDialog(BuildContext context, String telegramId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف البرقية'),
        content: Text('هل أنت متأكد من حذف هذه البرقية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حذف البرقية')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _handleLike(TelegramModel telegram) {
    print('تم الإعجاب بالبرقية ${telegram.id}');
  }

  void _handleRepost(TelegramModel telegram) {
    print('تم إعادة نشر البرقية ${telegram.id}');
  }

  void _showCommentsDialog(BuildContext context, TelegramModel telegram) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعليقات البرقية'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Text('عدد التعليقات: ${telegram.commentsCount}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
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

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
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

  IconData _getInterestIcon(String interestName) {
    switch (interestName.toLowerCase()) {
      case 'sports':
      case 'رياضة':
        return Icons.sports_soccer;
      case 'arts':
        return Icons.palette;
      case 'technology':
        return Icons.code;
      default:
        return Icons.interests;
    }
  }

  String _getZodiacEmoji(String zodiac) {
    switch (zodiac.toLowerCase()) {
      case 'aries':
      case 'الحمل':
        return '♈️';
      case 'taurus':
      case 'الثور':
        return '♉️';
      case 'gemini':
      case 'الجوزاء':
        return '♊️';
      case 'cancer':
      case 'السرطان':
        return '♋️';
      case 'leo':
      case 'الأسد':
        return '♌️';
      case 'virgo':
      case 'العذراء':
        return '♍️';
      case 'libra':
      case 'الميزان':
        return '♎️';
      case 'scorpio':
      case 'العقرب':
        return '♏️';
      case 'sagittarius':
      case 'القوس':
        return '♐️';
      case 'capricorn':
      case 'الجدي':
        return '♑️';
      case 'aquarius':
      case 'الدلو':
        return '♒️';
      case 'pisces':
      case 'الحوت':
        return '♓️';
      default:
        return '♈️';
    }
  }
}