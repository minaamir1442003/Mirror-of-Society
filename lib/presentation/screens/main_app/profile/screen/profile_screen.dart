// lib/presentation/screens/main_app/profile/screen/profile_screen.dart
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/user_profile_model.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/screens/request_verification_screen.dart';
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

  // ✅ إضافة هذا المتغير لتتبع أول تحميل
  bool _firstLoadDone = false;

  @override
  void initState() {
    super.initState();
    _setupScrollController();

    // ✅ التحميل مرة واحدة فقط عند بداية الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_firstLoadDone) {
        _loadInitialProfile();
        _firstLoadDone = true;
      }
    });
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

  void _loadInitialProfile() {
    final profileCubit = context.read<ProfileCubit>();

    // ✅ فقط إذا لم يكن هناك بيانات مخزنة
    if (profileCubit.cachedProfile == null) {
      print('📱 ProfileScreen: No cached data, loading from server...');

      if (widget.userId == null) {
        profileCubit.getMyProfile();
      } else {
        profileCubit.getUserProfile(widget.userId!);
      }
    } else {
      print('📱 ProfileScreen: Using cached data');
    }
  }

  void _loadMore() {
    final profileCubit = context.read<ProfileCubit>();

    if (!_isLoadingMore && _hasMoreData && profileCubit.hasMore) {
      _isLoadingMore = true;
      print('🔄 Loading more telegrams...');

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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }

          if (state is ProfileLoaded || state is ProfileUpdated) {
            final cubit = context.read<ProfileCubit>();
            _hasMoreData = cubit.hasMore;
          }
        },
        builder: (context, state) {
          final profileCubit = context.read<ProfileCubit>();

          if (profileCubit.cachedProfile != null &&
              state is! ProfileLoading &&
              state is! ProfileLoadingMore) {
            return _buildProfileContentWithData(profileCubit.cachedProfile!);
          }

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

  Widget _buildProfileContentWithData(UserProfileModel profile) {
    return Container(
      decoration: BoxDecoration(
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
      child: CustomScrollView(
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
                if (widget.userId == null && profile.rank == "0")
                  _buildVerificationBox(),
                _buildProfileDetails(profile),
              ],
            ),
          ),
          _buildTelegramsSliver(profile.telegrams, profile),
          _buildLoadingMoreIndicator(_isLoadingMore),
        ],
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
            onPressed: _loadInitialProfile,
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
      final cubit = context.read<ProfileCubit>();
      profile = cubit.cachedProfile!;
      telegrams = state.telegrams;
      isLoadingMore = true;
    } else if (state is ProfileLoaded) {
      profile = state.profile;
      telegrams = profile.telegrams;
    } else if (state is ProfileUpdated) {
      profile = state.profile;
      telegrams = profile.telegrams;
    } else {
      return _buildLoading();
    }

    return Container(
      decoration: BoxDecoration(
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
      child: CustomScrollView(
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
                if (widget.userId == null && profile.rank == "0")
                  _buildVerificationBox(),
                _buildProfileDetails(profile),
              ],
            ),
          ),
          _buildTelegramsSliver(telegrams, profile),
          _buildLoadingMoreIndicator(isLoadingMore),
        ],
      ),
    );
  }

  // مربع توثيق الحساب
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
                      style: TextStyle(fontSize: 13, color: AppTheme.darkGray),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Text(
            'توثيق حسابك يمنحك مزايا حصرية ويحسن من ظهورك في المجتمع.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),

          SizedBox(height: 20),

          Row(
            children: [
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

                       Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestVerificationScreen(),
                      ),
                    ).then((value) {
                      // ✅ إذا نجح التفعيل، نقوم بتحديث البروفايل
                      if (value == true) {
                        print('✅ Account verified, refreshing profile...');
                        final profileCubit = context.read<ProfileCubit>();
                        if (widget.userId == null) {
                          profileCubit.getMyProfile();
                        } else {
                          profileCubit.getUserProfile(widget.userId!);
                        }
                      }
                    });
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt, color: Colors.white, size: 18),
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

              Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                ),
                child: TextButton(
                  onPressed: () {},
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
        ],
      ),
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
              child:
                  profile.image.isNotEmpty
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
                          GestureDetector(
                            onTap: () {

                            },
                             child: _getZodiacEmoji(profile.zodiac, profile.shareZodiac)
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
                if (widget.userId == null) _buildEditButton(),
              ],
            ),

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

            profile.shareZodiac && profile.zodiac.isNotEmpty
                ? _buildZodiacInfoCard(profile)
                : SizedBox(),

            SizedBox(height: 24),
            _buildStatsRow(profile.statistics),

            SizedBox(height: 32),
            _buildInterestChips(profile.interests),
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacInfoCard(UserProfileModel profile) {
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
                  child: _getZodiacEmoji(profile.zodiac, profile.shareZodiac),
                ),
              ),

              SizedBox(width: 16),

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

          Row(
            children: [
              Icon(Icons.cake, size: 18, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                _formatBirthdate(profile.birthdate),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              SizedBox(width: 20),

              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                profile.country,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
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
          children:
              interests.map((interest) {
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

  Widget _buildEditButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.edit, color: Colors.white, size: 24),
        onPressed: _navigateToEditProfile,
      ),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    ).then((value) {
      if (value == true) {
        // ✅ بعد تعديل البروفايل، نعيد تحميل البيانات فقط
        final profileCubit = context.read<ProfileCubit>();
        if (widget.userId == null) {
          profileCubit.getMyProfile();
        } else {
          profileCubit.getUserProfile(widget.userId!);
        }
      }
    });
  }

  Widget _buildTelegramsSliver(
    List<TelegramModel> telegrams,
    UserProfileModel profile,
  ) {
    final cubit = context.read<ProfileCubit>();

    if (telegrams.isEmpty && !cubit.isProfileLoaded) {
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
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30.w,
            height: 90.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              color: color,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 20.sp,
            ),
          ),

          SizedBox(width: 7.w),

          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 90.h),
                  decoration: BoxDecoration(
                    borderRadius:
                        context
                                    .watch<LanguageProvider>()
                                    .getCurrentLanguageName() ==
                                'العربية'
                            ? BorderRadius.only(
                              topRight: Radius.circular(100.r),
                            )
                            : BorderRadius.only(
                              topLeft: Radius.circular(100.r),
                            ),
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
                                  child: _buildUserInfo(telegram, profile),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '#${telegram.number}',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    _buildSettingsMenu(telegram),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 15.h),
                            Flexible(
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  telegram.content,
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
                ),
                SizedBox(height: 10),
                _buildActionsSection(telegram),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(TelegramModel telegram, UserProfileModel profile) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 23.r,
                backgroundImage: NetworkImage(
                  telegram.user.image.isNotEmpty
                      ? telegram.user.image
                      : profile.image,
                ),
              ),
              context.watch<LanguageProvider>().getCurrentLanguageName() ==
                      'العربية'
                  ? Positioned(
                    bottom: -4,
                    left: -2,
                    child: Icon(
                      Icons.bookmark,
                      color: _getRankColor(telegram.user.rank),
                      size: 22.sp,
                    ),
                  )
                  : Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(
                      Icons.bookmark,
                      color: _getRankColor(telegram.user.rank),
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
                telegram.user.name,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                _formatTime(telegram.createdAt),
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

  Widget _buildSettingsMenu(TelegramModel telegram) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_vert, size: 20.sp, color: Colors.grey.shade600),
      itemBuilder: (context) => _buildMenuItems(),
      onSelected: (value) => _handleMenuSelection(value, context, telegram),
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

  void _handleMenuSelection(
    String value,
    BuildContext context,
    TelegramModel telegram,
  ) {
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

  Widget _buildActionsSection(TelegramModel telegram) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.emoji_objects,
            label:
                telegram.likesCount > 0
                    ? telegram.likesCount.toString()
                    : 'ضوء',
            onTap: () => _handleLike(telegram),
          ),
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            label:
                telegram.commentsCount > 0
                    ? telegram.commentsCount.toString()
                    : 'تعليق',
            onTap: () => _showCommentsDialog(context, telegram),
          ),
          _buildActionButton(
            icon: Icons.repeat,
            label:
                telegram.repostsCount > 0
                    ? telegram.repostsCount.toString()
                    : 'شارك',
            onTap: () => _handleRepost(telegram),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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

  Widget _buildLoadingMoreIndicator(bool isLoadingMore) {
    final profileCubit = context.read<ProfileCubit>();

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
    } else if (!profileCubit.hasMore && profileCubit.telegramsCount > 0) {
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

  void _handleLike(TelegramModel telegram) {
    print('تم الإعجاب بالبرقية ${telegram.id}');
  }

  void _handleRepost(TelegramModel telegram) {
    print('تم إعادة نشر البرقية ${telegram.id}');
  }

  void _showCommentsDialog(BuildContext context, TelegramModel telegram) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تعليقات البرقية'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: Column(
                children: [Text('عدد التعليقات: ${telegram.commentsCount}')],
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
      color: shareZodiac ? _getZodiacColor(zodiac) : Colors.grey[600], // اللون الحقيقي إذا كان true، وإلا رمادي
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
        return AppTheme.primaryColor;
    }
  }

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

  String _formatBirthdate(DateTime birthdate) {
    final arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${birthdate.day} ${arabicMonths[birthdate.month - 1]} ${birthdate.year}';
  }
}
