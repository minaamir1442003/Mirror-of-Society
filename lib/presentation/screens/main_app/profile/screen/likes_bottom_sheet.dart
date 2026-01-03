import 'package:app_1/presentation/screens/main_app/user_profile/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/like_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/like_model.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/like_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/profile/screen/profile_screen.dart';

class LikesBottomSheet extends StatefulWidget {
  final String telegramId;
  final LikeCubit? likeCubit;

  const LikesBottomSheet({Key? key, required this.telegramId, this.likeCubit})
    : super(key: key);

  @override
  _LikesBottomSheetState createState() => _LikesBottomSheetState();
}

class _LikesBottomSheetState extends State<LikesBottomSheet> {
  late LikeCubit _likeCubit;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    _likeCubit = widget.likeCubit ?? _createLikeCubit();

    _setupScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _likeCubit.getLikes(widget.telegramId);
    });
  }

  LikeCubit _createLikeCubit() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'ar',
          'Content-Type': 'application/json',
        },
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
      ),
    );

    final likeRepository = LikeRepository(dio: dio);
    return LikeCubit(likeRepository: likeRepository);
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        _loadMore();
      }
    });
  }

  void _loadMore() {
    if (!_isLoadingMore && _likeCubit.hasMore) {
      _isLoadingMore = true;
      _likeCubit.getLikes(widget.telegramId, loadMore: true).then((_) {
        _isLoadingMore = false;
      });
    }
  }

  // ✅ دالة التنقل الجديدة
  // في lib/presentation/screens/main_app/profile/screen/likes_bottom_sheet.dart
  void _navigateToUserProfile(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                UserProfileScreen(userId: userId.toString()), // ✅ هنا بتغير
      ),
    ).then((value) {
      _likeCubit.getLikes(widget.telegramId, forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (widget.likeCubit == null) {
      _likeCubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: BlocConsumer<LikeCubit, LikeState>(
        bloc: _likeCubit,
        listener: (context, state) {
          if (state is LikeError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),

              // Content
              Expanded(child: _buildContent(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(LikeState state) {
    if (state is LikeLoading) {
      return _buildLoading();
    } else if (state is LikeError) {
      return _buildError(state);
    } else if (state is LikesLoaded || state is LikeLoadingMore) {
      return _buildLikesList(state);
    }

    return _buildLoading();
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildError(LikeError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            state.error,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              _likeCubit.getLikes(widget.telegramId, forceRefresh: true);
            },
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildLikesList(LikeState state) {
    List<LikeModel> likes = [];
    bool isLoadingMore = false;

    if (state is LikesLoaded) {
      likes = state.likes;
    } else if (state is LikeLoadingMore) {
      likes = state.likes;
      isLoadingMore = true;
    }

    if (likes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 60.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد إعجابات بعد',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16.sp),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 8.h),
      itemCount: likes.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == likes.length) {
          return _buildLoadingMoreIndicator();
        }

        final like = likes[index];
        return _buildLikeItem(like);
      },
    );
  }

  Widget _buildLikeItem(LikeModel like) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          _navigateToUserProfile(like.user.id);
        },
        child: _buildUserAvatar(like),
      ),
      title: GestureDetector(
        onTap: () {
          _navigateToUserProfile(like.user.id);
        },
        child: Text(
          like.user.name,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
      ),
      subtitle: Text(
        'تم الإعجاب ${_formatTime(like.createdAt)}',
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        Icons.emoji_objects, // 💡 ده اللي هتضيفه
        color: Colors.amber[700], // اللون الذهبي/الأصفر للضوء
        size: 20.sp,
      ),
      // ✅ إزالة onTap من ListTile لأن الصورة واسم المستخدم هما اللي بيفتحوا البروفايل
      // onTap: () {
      //   print('Navigating to user profile: ${like.user.id}');
      // },
    );
  }

  Widget _buildUserAvatar(LikeModel like) {
    return Stack(
      children: [
        Container(
          width: 48.r,
          height: 48.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _getRankColor(like.user.rank).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child:
                like.user.image.isNotEmpty
                    ? Image.network(
                      like.user.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            color: Colors.grey[500],
                            size: 20.r,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                    )
                    : Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[500],
                        size: 20.r,
                      ),
                    ),
          ),
        ),

        Positioned(
          bottom: -2,
          right: -2,
          child: Icon(
            Icons.bookmark,
            color: _getRankColor(like.user.rank),
            size: 18.r,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingMoreIndicator() {
    if (_isLoadingMore) {
      return Container(
        padding: EdgeInsets.all(20.h),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (!_likeCubit.hasMore && _likeCubit.likesCount > 0) {
      return Container(
        padding: EdgeInsets.all(20.h),
        child: Center(
          child: Text(
            'تم تحميل جميع الإعجابات',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return SizedBox();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return 'قبل ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'قبل ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} يوم';
    } else if (difference.inDays < 30) {
      return 'قبل ${(difference.inDays / 7).floor()} أسبوع';
    } else {
      return '${time.day}/${time.month}/${time.year}';
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
