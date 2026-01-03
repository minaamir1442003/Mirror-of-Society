import 'package:app_1/data/models/bolt_model.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/main_app/home/models/home_feed_model.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/cubits/user_profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/models/user_profile_model.dart';
import 'package:app_1/presentation/widgets/bolts/bolt_card.dart';
import 'package:app_1/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialImage;

  const UserProfileScreen({
    Key? key,
    required this.userId,
    this.initialName,
    this.initialImage,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _showErrorSnackbar = false;
  bool _showZodiacInfo = false; // ✅ إضافة متغير لعرض/إخفاء معلومات البرج

  @override
  void initState() {
    super.initState();
    _setupScrollController();
    _loadUserProfile();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreTelegrams();
      }
    });
  }

  void _loadUserProfile() {
    final cubit = context.read<UserProfileCubit>();
    cubit.loadUserProfile(widget.userId);
  }

  void _loadMoreTelegrams() {
    final cubit = context.read<UserProfileCubit>();
    
    if (!_isLoadingMore && cubit.hasMore) {
      setState(() {
        _isLoadingMore = true;
      });
      
      cubit.loadMoreTelegrams().then((_) {
        setState(() {
          _isLoadingMore = false;
        });
      }).catchError((error) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('حدث خطأ أثناء تحميل المزيد', 'Error loading more')),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _toggleFollow() {
    final cubit = context.read<UserProfileCubit>();
    cubit.toggleFollow();
  }

  // ✅ دالة للحصول على النص بناءً على اللغة
  String _getText(String arabicText, String englishText) {
    final isArabic = context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';
    return isArabic ? arabicText : englishText;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          // ✅ التعامل مع الأخطاء العامة
          if (state is UserProfileError && !_showErrorSnackbar) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
          }
          
          // ✅ التعامل مع أخطاء تحميل المزيد
          if (state is UserProfileErrorLoadingMore && !_showErrorSnackbar) {
            _showErrorSnackbar = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
                _showErrorSnackbar = false;
              }
            });
          }
        },
        builder: (context, state) {
          // ✅ الحالة الأولية أو التحميل
          if (state is UserProfileLoading && state is! UserProfileLoadingMore) {
            return _buildLoadingState(context);
          }

          // ✅ حالة الخطأ (بدون بيانات محملة)
          if (state is UserProfileError && state is! UserProfileLoaded && state is! UserProfileLoadingMore) {
            return _buildErrorState(context, state);
          }

          // ✅ الحالة العامة - عرض البيانات المحملة
          final cubit = context.read<UserProfileCubit>();
          final userData = cubit.userData;
          final telegrams = cubit.telegrams;
          
          if (userData != null) {
            // ✅ الحصول على الإحصائيات من الحالة المناسبة
            ProfileStatistics? statistics;
            
            if (state is UserProfileLoaded) {
              statistics = state.statistics;
            } else if (state is UserProfileLoadingMore) {
              statistics = state.statistics;
            } else if (state is UserProfileErrorLoadingMore) {
              statistics = state.statistics;
            }
            
            return _buildProfileContent(
              context,
              userData,
              statistics ?? ProfileStatistics(followersCount: 0, followingCount: 0, telegramsCount: 0),
              telegrams,
              state is UserProfileLoadingMore,
            );
          }

          // ✅ الحالة الافتراضية - التحميل
          return _buildLoadingState(context);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.initialName ?? _getText('الملف الشخصي', 'Profile')),
      ),
      body: LoadingIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, UserProfileError state) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.initialName ?? _getText('الملف الشخصي', 'Profile')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _getText('حدث خطأ', 'Error'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(state.error, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: Text(_getText('إعادة المحاولة', 'Retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1DA1F2),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserData user,
    ProfileStatistics statistics,
    List<FeedItem> telegrams,
    bool isLoadingMore,
  ) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/image/154eb93e-c23b-41be-a5d2-c50ef02739d3.png"),
          repeat: ImageRepeat.repeat,
          opacity: 0.5,
          colorFilter: ColorFilter.mode(
            Colors.grey[200]!.withOpacity(0.2),
            BlendMode.modulate,
          ),
        ),
      ),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ✅ AppBar مع الصورة الخلفية
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildCoverImage(context, user),
            ),
          ),

          // ✅ تفاصيل الملف الشخصي
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileDetails(context, user, statistics),
              ],
            ),
          ),

          // ✅ البرقيات
          _buildTelegramsSliver(context, telegrams, user),

          // ✅ مؤشر التحميل الإضافي
          _buildLoadingMoreIndicator(context, isLoadingMore),
        ],
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context, UserData user) {
    return Stack(
      children: [
        user.cover.isNotEmpty
            ? Container(
                width: double.infinity,
                height: 350,
                child: Image.network(user.cover, fit: BoxFit.cover),
              )
            : Container(
                width: double.infinity,
                height: 350,
                color: Colors.grey,
              ),

        // ✅ صورة الملف الشخصي
        Positioned(bottom: 10, left: 10, child: _buildProfileAvatar(context, user)),

        // ✅ أيقونة الرتبة
        Positioned(
          bottom: 5.h,
          left: 90.w,
          child: Icon(
            Icons.bookmark,
            color: _getRankColor(user.rank),
            size: 45,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context, UserData user) {
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
                colors: [Color(0xFF1DA1F2), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 68,
              backgroundColor: Colors.white,
              child: user.image.isNotEmpty
                  ? CircleAvatar(
                      radius: 65,
                      backgroundImage: NetworkImage(user.image),
                    )
                  : CircleAvatar(backgroundColor: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(BuildContext context, UserData user, ProfileStatistics stats) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage("assets/image/154eb93e-c23b-41be-a5d2-c50ef02739d3.png"),
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
            // ✅ الاسم والمعلومات
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.fullName,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 15),
                              // ✅ جعل رمز البرج قابل للنقر لعرض/إخفاء المعلومات
                             if (user.zodiacIcon != null && user.zodiacIcon!.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  if (user.shareZodiac) {
                                    setState(() {
                                      _showZodiacInfo = !_showZodiacInfo;
                                    });
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    user.zodiacIcon!,
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.cover,
                                    color: user.shareZodiac 
                                        ? null 
                                        : Colors.grey,
                                    colorBlendMode: user.shareZodiac 
                                        ? BlendMode.srcIn 
                                        : BlendMode.saturation,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        _buildFollowButton(context, user.isFollowing),
                      ],
                    ),
                      
                      SizedBox(height: 2),
                    
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ البايو
            if (user.bio != null && user.bio!.isNotEmpty)
              Column(
                children: [
                  Text(
                    user.bio!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),

            // ✅ معلومات البرج (تظهر/تختفي عند النقر على الرمز)
            if (user.shareZodiac && user.zodiac != null && user.zodiac!.isNotEmpty && _showZodiacInfo)
              Column(
                children: [
                  _buildZodiacInfoCard(context, user),
                  SizedBox(height: 24),
                ],
              ),

            // ✅ الإحصائيات
            _buildStatsRow(context, stats),

            SizedBox(height: 32),

            // ✅ زر المتابعة
            

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, bool isFollowing) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 300),
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: isFollowing
          ? LinearGradient(
              colors: [Colors.red[400]!, Colors.red[700]!],
            )
          : LinearGradient(
              colors: [Color(0xFF1DA1F2), Color(0xFF0D8BF0)],
            ),
      boxShadow: [
        BoxShadow(
          color: isFollowing
              ? Colors.red.withOpacity(0.3)
              : Color(0xFF1DA1F2).withOpacity(0.3),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleFollow,
        borderRadius: BorderRadius.circular(30),
        child: Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: Icon(
              isFollowing ? Icons.person_remove : Icons.person_add,
              key: ValueKey<bool>(isFollowing),
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildZodiacInfoCard(BuildContext context, UserData user) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
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
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getZodiacColor(user.zodiac ?? ''),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getZodiacColor(user.zodiac ?? '').withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: _getZodiacEmoji(user.zodiac ?? '', user.shareZodiac),
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getText('برج ${user.zodiac}', '${user.zodiac} Zodiac'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _getZodiacColor(user.zodiac ?? ''),
                      ),
                    ),
                    Text(
                      _getZodiacSymbol(user.zodiac ?? '', context),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Divider(color: Colors.grey[300], height: 1, thickness: 1),

          SizedBox(height: 16),

          Text(
            user.zodiacDescription?.isNotEmpty == true
                ? user.zodiacDescription!
                : _getText(
                    '${user.zodiac} قادة بالفطرة. إنهم دراميون ومبدعون وواثقون من أنفسهم ومهيمنون ومن الصعب للغاية مقاومتهم.',
                    '${user.zodiac} are natural leaders. They are dramatic, creative, self-confident, dominant, and very difficult to resist.'
                  ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 10),

          if (user.shareLocation && user.country != null)
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  user.country!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ProfileStatistics stats) {
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
            context,
            stats.telegramsCount.toString(),
            _getText('البرقيات', 'Telegrams'),
            Icons.message_outlined,
            Colors.orange,
          ),
          _buildStatItem(
            context,
            stats.followersCount.toString(),
            _getText('متابعون', 'Followers'),
            Icons.group_outlined,
            Colors.green,
          ),
          _buildStatItem(
            context,
            stats.followingCount.toString(),
            _getText('متابَعون', 'Following'),
            Icons.group_add_outlined,
            Colors.blue,
          ),
        ],
      )
    );
  }

  Widget _buildStatItem(
    BuildContext context,
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
            color: Color(0xFF666666),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTelegramsSliver(BuildContext context, List<FeedItem> telegrams, UserData user) {
    final cubit = context.read<UserProfileCubit>();

    if (telegrams.isEmpty && !cubit.hasMore) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50),
              Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                _getText('لا توجد برقيات', 'No telegrams'),
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
        
        // ✅ تحويل FeedItem إلى BoltModel
        final bolt = _feedItemToBoltModel(telegram, context, user, orderNumber);
        
        return BoltCard(bolt: bolt);
      }, childCount: telegrams.length),
    );
  }

  // ✅ دالة لتحويل FeedItem إلى BoltModel
  BoltModel _feedItemToBoltModel(FeedItem feedItem, BuildContext context, UserData user, int orderNumber) {
    return feedItem.toBoltModel(
      onLikePressed: () => _handleLike(feedItem, context),
      onCommentPressed: () => _handleComment(feedItem, context),
      onSharePressed: () => _handleRepost(feedItem, context),
    ).copyWith(
      // ✅ إضافة ترتيب البرقية
      content: '#$orderNumber - ${feedItem.content}',
      userName: user.fullName,
      userImage: user.image,
    );
  }

  void _handleLike(FeedItem feedItem, BuildContext context) {
    print(_getText('تم الإعجاب بالبرقية', 'Liked telegram') + ' ${feedItem.id}');
  }

  void _handleComment(FeedItem feedItem, BuildContext context) {
    print(_getText('فتح التعليقات للبرقية', 'Opening comments for telegram') + ' ${feedItem.id}');
  }

  void _handleRepost(FeedItem feedItem, BuildContext context) {
    print(_getText('إعادة نشر البرقية', 'Reposting telegram') + ' ${feedItem.id}');
  }

  Widget _buildLoadingMoreIndicator(BuildContext context, bool isLoadingMore) {
    final cubit = context.read<UserProfileCubit>();

    if (isLoadingMore) {
      return SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: Color(0xFF1DA1F2)),
                SizedBox(height: 8),
                Text(
                  _getText('جاري تحميل المزيد...', 'Loading more...'),
                  style: TextStyle(color: Color(0xFF666666), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (!cubit.hasMore && cubit.userData != null && cubit.telegrams.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              _getText('تم تحميل جميع البرقيات', 'All telegrams loaded'),
              style: TextStyle(color: Color(0xFF666666), fontSize: 14),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(child: SizedBox());
  }

  // ========================
  // HELPER METHODS
  // ========================

  Text _getZodiacEmoji(String zodiac, bool shareZodiac) {
    String emoji;
    
    switch (zodiac.toLowerCase()) {
      case 'aries':
      case 'الحمل':
        emoji = '♈️';
        break;
      case 'taurus':
      case 'الثور':
        emoji = '♉️';
        break;
      case 'gemini':
      case 'الجوزاء':
        emoji = '♊️';
        break;
      case 'cancer':
      case 'السرطان':
        emoji = '♋️';
        break;
      case 'leo':
      case 'الأسد':
        emoji = '♌️';
        break;
      case 'virgo':
      case 'العذراء':
        emoji = '♍️';
        break;
      case 'libra':
      case 'الميزان':
        emoji = '♎️';
        break;
      case 'scorpio':
      case 'العقرب':
        emoji = '♏️';
        break;
      case 'sagittarius':
      case 'القوس':
        emoji = '♐️';
        break;
      case 'capricorn':
      case 'الجدي':
        emoji = '♑️';
        break;
      case 'aquarius':
      case 'الدلو':
        emoji = '♒️';
        break;
      case 'pisces':
      case 'الحوت':
        emoji = '♓️';
        break;
      default:
        emoji = '♈️';
    }
    
    return Text(
      emoji,
      style: TextStyle(
        fontSize: 30,
        color: shareZodiac ? _getZodiacColor(zodiac) : Colors.grey[600],
      ),
    );
  }

  Color _getZodiacColor(String zodiac) {
    switch (zodiac.toLowerCase()) {
      case 'الحمل':
      case 'aries':
        return Color(0xFFE74C3C);
      case 'الثور':
      case 'taurus':
        return Color(0xFF27AE60);
      case 'الجوزاء':
      case 'gemini':
        return Color(0xFFF39C12);
      case 'السرطان':
      case 'cancer':
        return Color(0xFF3498DB);
      case 'الأسد':
      case 'leo':
        return Color(0xFFE67E22);
      case 'العذراء':
      case 'virgo':
        return Color(0xFF9B59B6);
      case 'الميزان':
      case 'libra':
        return Color(0xFF1ABC9C);
      case 'العقرب':
      case 'scorpio':
        return Color(0xFFE74C3C);
      case 'القوس':
      case 'sagittarius':
        return Color(0xFFF1C40F);
      case 'الجدي':
      case 'capricorn':
        return Color(0xFF34495E);
      case 'الدلو':
      case 'aquarius':
        return Color(0xFF2980B9);
      case 'الحوت':
      case 'pisces':
        return Color(0xFF8E44AD);
      default:
        return Color(0xFF1DA1F2);
    }
  }

  String _getZodiacSymbol(String zodiac, BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';
    
    if (isArabic) {
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
    } else {
      switch (zodiac.toLowerCase()) {
        case 'aries':
        case 'الحمل':
          return '♈ Fire Sign | Mar 21 - Apr 19';
        case 'taurus':
        case 'الثور':
          return '♉ Earth Sign | Apr 20 - May 20';
        case 'gemini':
        case 'الجوزاء':
          return '♊ Air Sign | May 21 - Jun 20';
        case 'cancer':
        case 'السرطان':
          return '♋ Water Sign | Jun 21 - Jul 22';
        case 'leo':
        case 'الأسد':
          return '♌ Fire Sign | Jul 23 - Aug 22';
        case 'virgo':
        case 'العذراء':
          return '♍ Earth Sign | Aug 23 - Sep 22';
        case 'libra':
        case 'الميزان':
          return '♎ Air Sign | Sep 23 - Oct 22';
        case 'scorpio':
        case 'العقرب':
          return '♏ Water Sign | Oct 23 - Nov 21';
        case 'sagittarius':
        case 'القوس':
          return '♐ Fire Sign | Nov 22 - Dec 21';
        case 'capricorn':
        case 'الجدي':
          return '♑ Earth Sign | Dec 22 - Jan 19';
        case 'aquarius':
        case 'الدلو':
          return '♒ Air Sign | Jan 20 - Feb 18';
        case 'pisces':
        case 'الحوت':
          return '♓ Water Sign | Feb 19 - Mar 20';
        default:
          return '♈';
      }
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
}