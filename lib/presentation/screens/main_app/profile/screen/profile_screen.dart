// lib/presentation/screens/main_app/profile/screen/profile_screen.dart
import 'package:app_1/core/constants/injection_container.dart' as di;
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/cubits/telegram_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/comment_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/like_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/repost_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/user_profile_model.dart';
import 'package:app_1/presentation/screens/main_app/profile/screen/comments_bottom_sheet.dart';
import 'package:app_1/presentation/screens/main_app/profile/screen/likes_bottom_sheet.dart';
import 'package:app_1/presentation/screens/main_app/profile/screen/reposts_bottom_sheet.dart';
import 'package:app_1/presentation/screens/main_app/profile/screen/update_telegram_screen.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/screens/request_verification_screen.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/core/theme/app_theme.dart';
import 'package:app_1/presentation/screens/main_app/profile/edit_profile_screen.dart';
import 'package:app_1/presentation/screens/main_app/profile/settings_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/shared pref.dart';

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

  bool _firstLoadDone = false;
  bool _showZodiacInfo = false;

  @override
  void initState() {
    super.initState();
    _setupScrollController();

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

    if (!profileCubit.isInitialized) {
      print('📱 ProfileScreen: Initializing cubit...');
      
      if (widget.userId == null) {
        profileCubit.initialize();
      } else {
        profileCubit.initialize(userId: widget.userId);
      }
    } else if (profileCubit.cachedProfile == null) {
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

  String _getText(BuildContext context, String arabic, String english) {
    final isArabic =
        context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';
    return isArabic ? arabic : english;
  }

  void _navigateToUserProfileFromTelegram(TelegramModel telegram) {
    final profileCubit = context.read<ProfileCubit>();
    final currentUserId = profileCubit.cachedProfile?.id;

    if (telegram.user.id == currentUserId?.toString()) {
      print('⚠️ Same user, no navigation needed');
      return;
    }

    print('📍 Opening profile for user: ${telegram.user.id}');

    try {
      final targetUserId = int.tryParse(telegram.user.id.toString());
      if (targetUserId == null) {
        print('❌ Invalid user ID: ${telegram.user.id}');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => UserProfileScreen(userId: targetUserId.toString()),
        ),
      ).then((value) {
        print('🔄 Refreshing current profile after navigation...');
        if (widget.userId == null) {
          profileCubit.getMyProfile(forceRefresh: true);
        } else {
          profileCubit.getUserProfile(widget.userId!, forceRefresh: true);
        }
      });
    } catch (e) {
      print('❌ Error navigating to user profile: $e');
    }
  }

  String _truncateText(String text, {int maxLength = 15}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Future<void> _onRefresh() async {
    final profileCubit = context.read<ProfileCubit>();
    
    print('🔄 Pull-to-Refresh triggered with overlay');
    
    try {
      if (widget.userId == null) {
        await profileCubit.refresh();
      } else {
        await profileCubit.refresh(userId: widget.userId);
      }

      setState(() {
        _hasMoreData = true;
        _firstLoadDone = true;
      });
    } catch (e) {
      print('❌ Error refreshing: $e');
      
      final isArabic = context.read<LanguageProvider>().getCurrentLanguageName() == 'العربية';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'حدث خطأ في التحديث' : 'Error refreshing',
          ),
        ),
      );
    }
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    final profileCubit = context.read<ProfileCubit>();
    
    UserProfileModel? profile;
    List<TelegramModel> telegrams = [];
    bool showOverlay = false;
    bool showError = false;
    String? errorMessage;
    bool showEmptyState = false;
    
    final lastValidProfile = profileCubit.lastValidProfile;
    final lastValidTelegrams = profileCubit.lastValidTelegrams;

    if (state is ProfileLoaded) {
      profile = state.profile;
      telegrams = state.telegrams;
    } 
    else if (state is ProfileRefreshingWithOverlay) {
      profile = state.profile;
      telegrams = state.telegrams;
      showOverlay = true;
    }
    else if (state is ProfileUpdated) {
      profile = state.profile;
      telegrams = state.telegrams;
    }
    else if (state is ProfileLoading) {
      if (lastValidProfile != null && lastValidTelegrams.isNotEmpty) {
        profile = lastValidProfile.copyWith(telegrams: lastValidTelegrams);
        telegrams = lastValidTelegrams;
        showOverlay = true;
      } else {
        showOverlay = true;
      }
    }
    else if (state is ProfileError) {
      if (lastValidProfile != null && lastValidTelegrams.isNotEmpty) {
        profile = lastValidProfile.copyWith(telegrams: lastValidTelegrams);
        telegrams = lastValidTelegrams;
        showError = true;
        errorMessage = state.error;
      } else {
        showEmptyState = true;
        errorMessage = state.error;
      }
    }
    else if (state is ProfileLoadingMore) {
      profile = profileCubit.cachedProfile;
      telegrams = state.telegrams;
    }
    else if (state is ProfileInitial) {
      if (lastValidProfile != null && lastValidTelegrams.isNotEmpty) {
        profile = lastValidProfile.copyWith(telegrams: lastValidTelegrams);
        telegrams = lastValidTelegrams;
        showOverlay = true;
      } else {
        showOverlay = true;
      }
    }

    if (profile == null && !showOverlay && !showError) {
      showEmptyState = true;
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primaryColor,
          backgroundColor: Colors.white,
          strokeWidth: 3.0,
          child: Container(
            color: Colors.white,
            child: _buildContent(
              profile: profile,
              telegrams: telegrams,
              showEmptyState: showEmptyState,
              showError: showError,
              errorMessage: errorMessage,
            ),
          ),
        ),
        
        if (showOverlay && profile != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10.r,
                            spreadRadius: 2.r,
                          ),
                        ],
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          strokeWidth: 3.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      _getText(context, 'جاري التحديث...', 'Updating...'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        if (showOverlay && profile == null)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  strokeWidth: 3.0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent({
    required UserProfileModel? profile,
    required List<TelegramModel> telegrams,
    required bool showEmptyState,
    required bool showError,
    String? errorMessage,
  }) {
    if (showEmptyState) {
      return _buildLoading(context);
    }

    if (showError && profile == null) {
      return _buildError(context, errorMessage ?? 'حدث خطأ');
    }

    if (profile == null) {
      return Container();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
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
                  _buildVerificationBox(context),
                _buildProfileDetails(context, profile),
              ],
            ),
          ),
          _buildTelegramsSliver(context, telegrams, profile),
          _buildLoadingMoreIndicator(context, _isLoadingMore),
           SliverToBoxAdapter(
          child: SizedBox(height: 60),
        ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     return MultiBlocProvider(
    providers: [
       
      BlocProvider<LikeCubit>(
        create: (context) => di.sl<LikeCubit>(),
      ),
      BlocProvider<RepostCubit>(
        create: (context) => di.sl<RepostCubit>(),
      ),
      BlocProvider<CommentCubit>(
        create: (context) => di.sl<CommentCubit>(),
      ),
    ],
    child:  Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
         listener: (context, state) {
        if (state is ProfileError) {
          final isArabic = Provider.of<LanguageProvider>(context, listen: false)
              .getCurrentLanguageName() == 'العربية';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    )
     );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppTheme.primaryColor),
    );
  }

  Widget _buildError(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            _getText(context, 'حدث خطأ', 'Error'),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(errorMessage, textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialProfile,
            child: Text(_getText(context, 'إعادة المحاولة', 'Retry')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBox(BuildContext context) {
  final storageService = di.sl<StorageService>();
  bool showVerification = true;

  return FutureBuilder<bool>(
    future: storageService.shouldShowVerification(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          height: 0,
          width: 0,
        ); // لا تعرض شيئاً أثناء التحميل
      }

      showVerification = snapshot.data ?? true;

      if (!showVerification) {
        return SizedBox(); // لا تعرض المربع
      }

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
            // عنوان المربع
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
                        _getText(
                          context,
                          'حسابك غير موثق',
                          'Your account is not verified',
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _getText(
                          context,
                          'ارتقِ برتبتك إلى المستوى التالي',
                          'Upgrade your rank to the next level',
                        ),
                        style: TextStyle(fontSize: 13, color: AppTheme.darkGray),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // وصف المربع
            Text(
              _getText(
                context,
                'توثيق حسابك يمنحك مزايا حصرية ويحسن من ظهورك في المجتمع.',
                'Verifying your account gives you exclusive benefits and improves your visibility in the community.',
              ),
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
                            _getText(context, 'تفعيل الحساب', 'Activate Account'),
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

                // زر التخطي المعدل
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 1.5),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      try {
                        // تخزين تاريخ الضغط على تخطي
                        await storageService.setVerificationSkipped();
                        
                        // إظهار رسالة تأكيد
                        final isArabic = context.read<LanguageProvider>().getCurrentLanguageName() == 'العربية';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isArabic
                                  ? 'سيتم إخفاء الإشعار لمدة 30 يومًا'
                                  : 'Notification will be hidden for 30 days',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        
                        // إعادة بناء الواجهة لتحديث العرض
                        if (mounted) {
                          setState(() {});
                        }
                        
                        print('⏰ Verification hidden for 30 days');
                      } catch (e) {
                        print('❌ Error saving skip state: $e');
                      }
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _getText(context, 'تخطي', 'Skip'),
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
    },
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

  Widget _buildProfileDetails(BuildContext context, UserProfileModel profile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 60, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _truncateText(profile.fullName, maxLength: 20),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      // ✅ التعديل: صورة البرج فقط بدون Container
                      if (profile.zodiacIcon.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            if (profile.shareZodiac) {
                              setState(() {
                                _showZodiacInfo = !_showZodiacInfo;
                              });
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              profile.zodiacIcon,
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                              color: profile.shareZodiac 
                                  ? null 
                                  : Colors.grey,
                              colorBlendMode: profile.shareZodiac 
                                  ? BlendMode.srcIn 
                                  : BlendMode.saturation,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.userId == null) _buildEditButton(context),
              ],
            ),

            SizedBox(height: 10),

            Container(
              width: double.infinity,
              child: Text(
                profile.bio,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ),

            SizedBox(height: 20),

            profile.shareZodiac && _showZodiacInfo && profile.zodiac.isNotEmpty
                ? _buildZodiacInfoCard(context, profile)
                : SizedBox(),

            SizedBox(height: 24),
            _buildStatsRow(context, profile.statistics),

            SizedBox(height: 32),
            _buildInterestChips(context, profile.interests),
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacInfoCard(BuildContext context, UserProfileModel profile) {
    final isArabic =
        context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

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
                  child: profile.zodiacIcon.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            profile.zodiacIcon,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            color: profile.shareZodiac 
                                ? null 
                                : Colors.grey.withOpacity(0.5),
                            colorBlendMode: profile.shareZodiac 
                                ? BlendMode.srcIn 
                                : BlendMode.saturation,
                          ),
                        )
                      : Icon(
                          Icons.star,
                          color: profile.shareZodiac 
                              ? _getZodiacColor(profile.zodiac) 
                              : Colors.grey[400],
                          size: 30,
                        ),
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic
                          ? 'برج ${profile.zodiac}'
                          : '${profile.zodiac} Zodiac',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _getZodiacColor(profile.zodiac),
                      ),
                    ),
                    Text(
                      _getZodiacSymbol(context, profile.zodiac),
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
                : isArabic
                ? '${profile.zodiac} قادة بالفطرة. إنهم دراميون ومبدعون وواثقون من أنفسهم ومهيمنون ومن الصعب للغاية مقاومتهم.'
                : '${profile.zodiac} are natural leaders. They are dramatic, creative, self-confident, dominant, and very difficult to resist.',
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
                _formatBirthdate(context, profile.birthdate),
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
            _getText(context, 'المنشورات', 'Posts'),
            Icons.message_outlined,
            Colors.orange,
          ),
          _buildStatItem(
            context,
            stats.followersCount.toString(),
            _getText(context, 'متابعون', 'Followers'),
            Icons.group_outlined,
            Colors.green,
          ),
          _buildStatItem(
            context,
            stats.followingCount.toString(),
            _getText(context, 'متابَعون', 'Following'),
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
            color: AppTheme.darkGray,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestChips(
    BuildContext context,
    List<InterestModel> interests,
  ) {
    if (interests.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.interests_outlined, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text(
              _getText(context, 'الاهتمامات', 'Interests'),
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

  Widget _buildEditButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.edit, color: Colors.white, size: 24),
        onPressed: () => _navigateToEditProfile(context),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    ).then((value) {
      if (value == true) {
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
    BuildContext context,
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
                _getText(context, 'لا توجد برقيات', 'No telegrams'),
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
        
        // ✅ التحقق إذا كانت برقية إعلان
        if (telegram.isAd) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
            child: _buildAdTelegramCard(telegram, profile, orderNumber),
          );
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
            child: _buildNormalTelegramCard(telegram, profile, orderNumber),
          );
        }
      }, childCount: telegrams.length),
    );
  }

  // ✅ تصميم مبسط وجذاب للإعلانات
  Widget _buildAdTelegramCard(
    TelegramModel telegram,
    UserProfileModel profile,
    int orderNumber,
  ) {
    final isArabic =
        context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Color(0xFFFFA500).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط الإعلان العلوي
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Color(0xFFFFA500),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ads_click, size: 16.sp, color: Colors.white),
                    SizedBox(width: 6.w),
                    Text(
                      _getText(context, 'إعلان مميز', 'Sponsored'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.white),
              ],
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات المعلن
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 18.r,
                        backgroundImage: NetworkImage(
                          telegram.user.image.isNotEmpty 
                              ? telegram.user.image 
                              : 'https://mirsoc.com/images/usersProfile/profile.png',
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            telegram.user.name,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _getText(context, 'معلن معتمد', 'Verified Advertiser'),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xFFFFA500),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                // محتوى الإعلان
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    telegram.content,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // زر الإجراء
                Container(
                  width: double.infinity,
                  height: 40.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFA500), Color(0xFFFF6B00)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextButton(
                    onPressed: () {
                      print('🛒 Ad clicked: ${telegram.id}');
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _getText(context, 'عرض خاص', 'Special Offer'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                // نص إضافي
                Text(
                  _getText(
                    context,
                    'عرض لفترة محدودة • احصل على خصم 30%',
                    'Limited Time Offer • Get 30% Discount',
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ التصميم العادي للبرقيات
  Widget _buildNormalTelegramCard(
    TelegramModel telegram,
    UserProfileModel profile,
    int orderNumber,
  ) {
    final color = _parseColor(telegram.category.color);

    final isArabic =
        context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

    final bool isRepost = telegram.type == 'repost';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isRepost && telegram.user.id != profile.id.toString()) ...[
            _buildRepostHeader(context, telegram, profile, isArabic),
            SizedBox(height: 8.h),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    isArabic
                        ? EdgeInsets.only(right: 60.0)
                        : EdgeInsets.only(left: 60.0),
                child: _buildUserInfo(telegram, profile, isArabic),
              ),
              _buildSettingsMenu(context, telegram, profile),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                
                width: 30.w,
                height: telegram.content.length.toDouble() > 100 ? 80.h : 70.h,
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
                child: Container(
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              '#${telegram.number}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          SizedBox(height: 5.h),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.center,
                              child: Text(
                                telegram.content,
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
              )
              ),
            ],
          ),

          SizedBox(height: 10),
          _buildActionsSection(context, telegram),
        ],
      ),
    );
  }

  Widget _buildRepostHeader(
    BuildContext context,
    TelegramModel telegram,
    UserProfileModel profile,
    bool isArabic,
  ) {
    return Align(
      alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 1.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.repeat, size: 16.sp, color: AppTheme.primaryColor),
              SizedBox(width: 6.w),

              CircleAvatar(
                radius: 12.r,
                backgroundImage: NetworkImage(profile.image),
              ),
              SizedBox(width: 6.w),

              Flexible(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${_truncateText(profile.firstname, maxLength: 10)} ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      TextSpan(
                        text: isArabic ? 'شارك منشورًا من ' : 'reposted from ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      TextSpan(
                        text: _truncateText(telegram.user.name, maxLength: 12),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(
    TelegramModel telegram,
    UserProfileModel profile,
    bool isArabic,
  ) {
    return GestureDetector(
      onTap: () {
        _navigateToUserProfileFromTelegram(telegram);
      },
      child: Stack(
        children:[ Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 60,
                  child: Center(
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundImage: NetworkImage(
                        telegram.user.image.isNotEmpty
                            ? telegram.user.image
                            : profile.image,
                      ),
                    ),
                  ),
                ),
                isArabic
                    ? Positioned(
                      bottom: -2,
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
                  _truncateText(telegram.user.name, maxLength: 15),
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
    ]  ),
    );
  }

  Widget _buildSettingsMenu(
  BuildContext context,
  TelegramModel telegram,
  UserProfileModel profile,
) {
  return PopupMenuButton<String>(
    padding: EdgeInsets.zero,
    icon: Icon(Icons.more_vert, size: 20.sp, color: Colors.grey.shade600),
    itemBuilder: (BuildContext context) {
      final isArabic =
          Provider.of<LanguageProvider>(context, listen: false).getCurrentLanguageName() ==
          'العربية';

      // ✅ تصحيح هنا: تحويل كلا المعرفين لنفس النوع للمقارنة الصحيحة
      final bool isMyPost = 
          telegram.user.id.toString() == profile.id.toString() &&
          telegram.type == 'post';
      
      final bool isMyRepost = 
          telegram.user.id.toString() == profile.id.toString() &&
          telegram.type == 'repost';
      
      // ✅ بديل: يمكن استخدام هذا للتحقق من أي برقية في صفحة المستخدم الشخصية
      final bool isInMyProfile = 
          telegram.user.id.toString() == profile.id.toString();

      final List<PopupMenuItem<String>> items = [];

      items.addAll([
        
      
      ]);

      // ✅ إذا كانت البرقية في صفحة المستخدم الشخصية (سواء كانت منشور أو إعادة نشر)
      if (isInMyProfile) {
        items.add(
          PopupMenuItem<String>(
            value: 'update',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18.sp, color: AppTheme.primaryColor),
                SizedBox(width: 8.w),
                Text(
                  isArabic ? 'تحديث' : 'Update',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
        
        items.add(
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 18.sp,
                  color: Colors.red.shade600,
                ),
                SizedBox(width: 8.w),
                Text(
                  isArabic ? 'حذف البرقية' : 'Delete Telegram',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // إذا لم تكن برقية المستخدم نفسه
        items.add(
          PopupMenuItem<String>(
            value: 'report',
            child: Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 18.sp,
                  color: Colors.red.shade600,
                ),
                SizedBox(width: 8.w),
                Text(
                  isArabic ? 'الإبلاغ' : 'Report',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      items.addAll([
      
      
      ]);

      return items;
    },
    onSelected: (value) => _handleMenuSelection(value, context, telegram, profile),
  );
}

  void _handleMenuSelection(
    String value,
    BuildContext context,
    TelegramModel telegram,
    UserProfileModel profile,
  ) {
    final bool isMyPost =
        telegram.user.id == profile.id.toString() && telegram.type == 'post';
    final bool isMyRepost = telegram.type == 'repost';

    switch (value) {
      case 'update':
        if (isMyPost) {
          _navigateToUpdateTelegram(telegram);
        }
        break;
      case 'delete':
        if (isMyPost || isMyRepost) {
          _showDeleteDialog(context, telegram, isMyPost, isMyRepost);
        }
        break;
      case 'report':
        if (!isMyPost && !isMyRepost) {
          _showReportDialog(context, telegram);
        }
        break;
      case 'save':
        _showSnackBar(
          context,
          _getText(
            context,
            'تم حفظ البرقية في المفضلة',
            'Telegram saved to favorites',
          ),
          Colors.green,
        );
        break;
      case 'copy':
        _showSnackBar(
          context,
          _getText(context, 'تم نسخ نص البرقية', 'Telegram text copied'),
          Colors.blue,
        );
        break;
      case 'hide':
        _showSnackBar(
          context,
          _getText(context, 'تم إخفاء البرقية', 'Telegram hidden'),
          Colors.orange,
        );
        break;
      case 'block':
        _showBlockDialog(context, telegram);
        break;
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    TelegramModel telegram,
    bool isMyPost,
    bool isMyRepost,
  ) {
    final isArabic =
        context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

    String message;
    if (isMyRepost) {
      message =
          isArabic
              ? 'هل أنت متأكد من إزالة إعادة النشر هذه؟\nسيتم إزالة هذه البرقية من ملفك الشخصي فقط.'
              : 'Are you sure you want to remove this repost?\nThis will only remove it from your profile.';
    } else {
      message =
          isArabic
              ? 'هل أنت متأكد من حذف هذه البرقية؟\nلا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to delete this telegram?\nThis action cannot be undone.';
    }

    showDialog(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red.shade700),
                  SizedBox(width: 10),
                  Text(
                    isArabic
                        ? (isMyRepost ? 'إزالة إعادة النشر' : 'حذف البرقية')
                        : (isMyRepost ? 'Remove Repost' : 'Delete Telegram'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                  height: 1.5,
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
                  onPressed:
                      () =>
                          _handleDeleteTelegram(context, telegram, isMyRepost),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                  ),
                  child: Text(
                    isArabic
                        ? (isMyRepost ? 'إزالة' : 'حذف')
                        : (isMyRepost ? 'Remove' : 'Delete'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _handleDeleteTelegram(
  BuildContext context,
  TelegramModel telegram,
  bool isRepost,
) async {
  final isArabic = context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

  try {
    print('🗑️ ${isRepost ? 'Removing repost' : 'Deleting telegram'}: ${telegram.id}');

    Navigator.pop(context);

    final telegramCubit = context.read<TelegramCubit>();
    final profileCubit = context.read<ProfileCubit>();

    // ✅ تحديث القائمة محلياً أولاً
    profileCubit.removeTelegramFromList(int.parse(telegram.id));

    // ✅ تنفيذ الحذف من السيرفر بدون تمرير context
    if (isRepost) {
      await telegramCubit.deleteRepost(int.parse(telegram.id));
    } else {
      await telegramCubit.deleteTelegram(int.parse(telegram.id));
    }

    print('✅ ${isRepost ? 'Repost removed' : 'Telegram deleted'} successfully');

    // ✅ إظهار رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? (isRepost ? 'تمت إزالة إعادة النشر' : 'تم حذف البرقية')
              : (isRepost ? 'Repost removed' : 'Telegram deleted'),
        ),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print('❌ Error ${isRepost ? 'removing repost' : 'deleting telegram'}: $e');

    // ✅ إعادة تحميل البيانات في حالة الخطأ
    final profileCubit = context.read<ProfileCubit>();
    if (widget.userId == null) {
      await profileCubit.getMyProfile(forceRefresh: true);
    } else {
      await profileCubit.getUserProfile(widget.userId!, forceRefresh: true);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? (isRepost ? 'فشل إزالة إعادة النشر' : 'فشل حذف البرقية')
              : (isRepost ? 'Failed to remove repost' : 'Failed to delete telegram'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _showReportDialog(BuildContext context, TelegramModel telegram) {
    final isArabic =
        context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

    showDialog(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.red.shade700),
                  SizedBox(width: 10),
                  Text(
                    isArabic ? 'الإبلاغ عن البرقية' : 'Report Telegram',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
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
                    SizedBox(height: 10.h),
                    Text(
                      isArabic
                          ? 'سيتم مراجعة الإبلاغ خلال 24 ساعة'
                          : 'Your report will be reviewed within 24 hours',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
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
                  onPressed: () => _handleReportTelegram(context, telegram),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                  ),
                  child: Text(isArabic ? 'إبلاغ' : 'Report'),
                ),
              ],
            ),
          ),
    );
  }

  void _handleReportTelegram(
  BuildContext context,
  TelegramModel telegram,
) async {

}

  void _showBlockDialog(BuildContext context, TelegramModel telegram) {
    final isArabic =
        context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

    showDialog(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  Icon(Icons.block, color: Colors.red.shade700),
                  SizedBox(width: 10),
                  Text(
                    isArabic ? 'حظر المستخدم' : 'Block User',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              content: Text(
                isArabic
                    ? 'هل تريد حظر ${telegram.user.name}؟\nلن تتمكن من رؤية منشوراته وسيتم حظره من إرسال رسائل إليك.'
                    : 'Do you want to block ${telegram.user.name}?\nYou won\'t see their posts and they will be blocked from messaging you.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                  height: 1.5,
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
                    _handleBlockUser(context, telegram);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                  ),
                  child: Text(isArabic ? 'حظر' : 'Block'),
                ),
              ],
            ),
          ),
    );
  }

  void _handleBlockUser(BuildContext context, TelegramModel telegram) {
    final isArabic =
        context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

    print('🚫 Blocking user: ${telegram.user.id} - ${telegram.user.name}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'تم حظر ${telegram.user.name} بنجاح'
              : 'Successfully blocked ${telegram.user.name}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToUpdateTelegram(TelegramModel telegram) {
    print('فتح شاشة تحديث البرقية ${telegram.id}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTelegramScreen(telegram: telegram),
      ),
    ).then((value) {
      if (value == true) {
        final profileCubit = context.read<ProfileCubit>();
        if (widget.userId == null) {
          profileCubit.getMyProfile(forceRefresh: true);
        } else {
          profileCubit.getUserProfile(widget.userId!, forceRefresh: true);
        }
      }
    });
  }

  Widget _buildActionsSection(BuildContext context, TelegramModel telegram) {
    final isArabic =
        context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

    return Container(
      width: 350,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLikeButton(context, telegram),

          GestureDetector(
            onTap: () => _showCommentsDialog(context, telegram),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey.shade600,
                  size: 20.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  telegram.commentsCount > 0
                      ? telegram.commentsCount.toString()
                      : _getText(context, 'تعليق', 'Comment'),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          _buildRepostButton(context, telegram),

          _buildActionButton(
            context,
            icon: Icons.send_outlined,
            label: _getText(context, 'إرسال', 'Send'),
            onTap: () => print(_getText(context, 'تم الإرسال', 'Sent')),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context, TelegramModel telegram) {
  final isArabic =
      context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';
  
  // ✅ استخدام نفس الألوان الموجودة في BoltCard
  final iconColor = telegram.isLiked ? Colors.amber[700]! : Colors.grey.shade600;
  final textColor = telegram.isLiked ? Colors.amber[700]! : Colors.grey.shade700;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      GestureDetector(
        onTap: () => _handleLike(telegram),
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: telegram.isLiked
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8.r,
                      spreadRadius: 2.r,
                    ),
                  ],
                )
              : null,
          child: Icon(
            telegram.isLiked
                ? Icons.emoji_objects
                : Icons.emoji_objects_outlined,
            color: iconColor,
            size: telegram.isLiked ? 22.sp : 20.sp,
          ),
        ),
      ),
      SizedBox(height: 4.h),

      GestureDetector(
        onTap: () => _showLikesBottomSheet(context, telegram),
        child: Text(
          telegram.likesCount > 0
              ? telegram.likesCount.toString()
              : _getText(context, 'ضوء', 'Light'),
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    ],
  );
}

  Widget _buildActionButton(
    BuildContext context, {
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

  Widget _buildRepostButton(BuildContext context, TelegramModel telegram) {
  final isArabic =
      context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

  // ✅ استخدام نفس الألوان الموجودة في BoltCard
  final iconColor = telegram.isReposted
      ? Colors.green
      : telegram.repostsCount > 0
          ? Colors.green
          : Colors.grey.shade600;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // ✅ الأيقونة - للقيام بإعادة النشر
      GestureDetector(
        onTap: () {
          _handleRepost(context, telegram);
        },
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: telegram.isReposted
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8.r,
                      spreadRadius: 2.r,
                    ),
                  ],
                )
              : null,
          child: Icon(
            Icons.repeat,
            color: iconColor,
            size: telegram.isReposted ? 22.sp : 20.sp,
          ),
        ),
      ),
      
      SizedBox(height: 4.h),
      
      // ✅ الرقم - لعرض قائمة المعيدين للنشر
      GestureDetector(
        onTap: () {
          if (telegram.repostsCount > 0) {
            _showRepostsBottomSheet(context, telegram);
          }
        },
        child: Text(
          telegram.repostsCount > 0
              ? telegram.repostsCount.toString()
              : _getText(context, 'شارك', 'Repost'),
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: iconColor,
          ),
        ),
      ),
    ],
  );
}

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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

  Widget _buildLoadingMoreIndicator(BuildContext context, bool isLoadingMore) {
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
                  _getText(context, 'جاري تحميل المزيد...', 'Loading more...'),
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
              _getText(
                context,
                'تم تحميل جميع البرقيات',
                'All telegrams loaded',
              ),
              style: TextStyle(color: AppTheme.darkGray, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(child: SizedBox());
  }

  void _handleLike(TelegramModel telegram) async {
  try {
    print('💡 Like button pressed for telegram: ${telegram.id}');

    // ✅ استخدم listen: false
    final likeCubit = context.read<LikeCubit>();
    await likeCubit.toggleLike(telegram.id);

    final profileCubit = context.read<ProfileCubit>();
    final newIsLiked = !telegram.isLiked;
    final newLikesCount =
        newIsLiked ? telegram.likesCount + 1 : telegram.likesCount - 1;

    profileCubit.updateTelegramLikeStatus(telegram.id, {
      'likes_count': newLikesCount,
      'is_liked': newIsLiked,
    });
  } catch (e) {
    print('❌ Error liking telegram: $e');
  }
}

  void _showLikesBottomSheet(BuildContext context, TelegramModel telegram) {
  try {
    // ✅ استخدم listen: false
    final likeCubit = BlocProvider.of<LikeCubit>(context, listen: false);
    
    final isArabic = Provider.of<LanguageProvider>(context, listen: false)
        .getCurrentLanguageName() == 'العربية';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (context) {
        return LikesBottomSheet(
          telegramId: telegram.id.toString(),
          likeCubit: likeCubit,
        );
      },
    );
  } catch (e) {
    print('❌ Error showing likes bottom sheet: $e');
  }
}

  void _handleRepost(BuildContext context, TelegramModel telegram) async {
  try {
    print('🔄 Repost button pressed for telegram: ${telegram.id}');

    // ✅ استخدم context.read بدلاً من context.watch
    final repostCubit = context.read<RepostCubit>();
    await repostCubit.toggleRepost(telegram.id);

    final profileCubit = context.read<ProfileCubit>();
    final isCurrentlyRepost = telegram.type == 'repost';
    final newRepostsCount =
        isCurrentlyRepost
            ? telegram.repostsCount - 1
            : telegram.repostsCount + 1;

    profileCubit.updateTelegramRepostStatus(telegram.id, {
      'reposts_count': newRepostsCount,
    });

    // ✅ استخدم listen: false للغة
    final isArabic = Provider.of<LanguageProvider>(context, listen: false)
        .getCurrentLanguageName() == 'العربية';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCurrentlyRepost
              ? (isArabic ? 'تمت إزالة إعادة النشر' : 'Removed repost')
              : (isArabic ? 'تمت إعادة النشر' : 'Reposted successfully'),
        ),
        backgroundColor: Colors.green,
      ),
    );

    if (!isCurrentlyRepost) {
      _showRepostsBottomSheet(context, telegram);
    }
  } catch (e) {
    print('❌ Error reposting telegram: $e');

    final isArabic = Provider.of<LanguageProvider>(context, listen: false)
        .getCurrentLanguageName() == 'العربية';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'فشلت عملية إعادة النشر' : 'Failed to repost',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _showRepostsBottomSheet(BuildContext context, TelegramModel telegram) {
  try {
    print('📋 Opening reposts bottom sheet for telegram: ${telegram.id}');

    // ✅ استخدم listen: false هنا
    final repostCubit = BlocProvider.of<RepostCubit>(context, listen: false);

    // ✅ استخدم Provider.of مع listen: false للغة
    final isArabic = Provider.of<LanguageProvider>(context, listen: false)
        .getCurrentLanguageName() == 'العربية';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (context) {
        return RepostsBottomSheet(
          telegramId: telegram.id,
          repostCubit: repostCubit,
        );
      },
    );
  } catch (e) {
    print('❌ Error showing reposts bottom sheet: $e');
  }
}

void _showCommentsDialog(BuildContext context, TelegramModel telegram) {
  // ✅ استخدم listen: false
  final commentCubit = BlocProvider.of<CommentCubit>(context, listen: false);
  
  final isArabic = Provider.of<LanguageProvider>(context, listen: false)
      .getCurrentLanguageName() == 'العربية';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
    ),
    builder: (context) {
      return CommentsBottomSheet(
        telegramId: telegram.id.toString(),
        commentCubit: commentCubit,
      );
    },
  );
}

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${_getText(context, 'قبل', '')} ${difference.inMinutes} ${_getText(context, 'د', 'm')}';
    } else if (difference.inHours < 24) {
      return '${_getText(context, 'قبل', '')} ${difference.inHours} ${_getText(context, 'س', 'h')}';
    } else if (difference.inDays < 7) {
      return '${_getText(context, 'قبل', '')} ${difference.inDays} ${_getText(context, 'ي', 'd')}';
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

  String _getZodiacSymbol(BuildContext context, String zodiac) {
    final isArabic =
        context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

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

  String _formatBirthdate(BuildContext context, DateTime birthdate) {
    final isArabic =
        context.watch<LanguageProvider>().getCurrentLanguageName() == 'العربية';

    if (isArabic) {
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
    } else {
      final englishMonths = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${birthdate.day} ${englishMonths[birthdate.month - 1]} ${birthdate.year}';
    }
  }

  void resetScreen() {
    final profileCubit = context.read<ProfileCubit>();
    profileCubit.resetInitialization();
    
    _hasMoreData = true;
    _firstLoadDone = false;
    
    if (widget.userId == null) {
      profileCubit.getMyProfile(forceRefresh: true);
    } else {
      profileCubit.getUserProfile(widget.userId!, forceRefresh: true);
    }
  }
}