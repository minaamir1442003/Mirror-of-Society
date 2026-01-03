import 'package:app_1/presentation/screens/main_app/user_profile/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/repost_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/repost_model.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/repost_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/profile/screen/profile_screen.dart';

class RepostsBottomSheet extends StatefulWidget {
  final String telegramId;
  final RepostCubit? repostCubit;

  const RepostsBottomSheet({
    Key? key,
    required this.telegramId,
    this.repostCubit,
  }) : super(key: key);

  @override
  _RepostsBottomSheetState createState() => _RepostsBottomSheetState();
}

class _RepostsBottomSheetState extends State<RepostsBottomSheet> {
  late RepostCubit _repostCubit;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    _repostCubit = widget.repostCubit ?? _createRepostCubit();
    
    _setupScrollController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _repostCubit.getReposts(widget.telegramId);
    });
  }

  RepostCubit _createRepostCubit() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Accept': 'application/json',
        'Accept-Language': 'ar',
        'Content-Type': 'application/json',
      },
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ));
    
    final repostRepository = RepostRepository(dio: dio);
    return RepostCubit(repostRepository: repostRepository);
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
    if (!_isLoadingMore && _repostCubit.hasMore) {
      _isLoadingMore = true;
      _repostCubit.getReposts(widget.telegramId, loadMore: true).then((_) {
        _isLoadingMore = false;
      });
    }
  }

  // ✅ دالة التنقل الجديدة
void _navigateToUserProfile(int userId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserProfileScreen(userId: userId.toString()), // ✅ هنا بتغير
    ),
  ).then((value) {
    _repostCubit.getReposts(widget.telegramId, forceRefresh: true);
  });
}

  @override
  void dispose() {
    _scrollController.dispose();
    if (widget.repostCubit == null) {
      _repostCubit.close();
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
      child: BlocConsumer<RepostCubit, RepostState>(
        bloc: _repostCubit,
        listener: (context, state) {
          if (state is RepostError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error))
            );
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إعادة النشر',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 24.sp),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(RepostState state) {
    if (state is RepostLoading) {
      return _buildLoading();
    } else if (state is RepostError) {
      return _buildError(state);
    } else if (state is RepostsLoaded || state is RepostLoadingMore) {
      return _buildRepostsList(state);
    }
    
    return _buildLoading();
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(RepostError state) {
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
              _repostCubit.getReposts(widget.telegramId, forceRefresh: true);
            },
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildRepostsList(RepostState state) {
    List<RepostModel> reposts = [];
    bool isLoadingMore = false;
    
    if (state is RepostsLoaded) {
      reposts = state.reposts;
    } else if (state is RepostLoadingMore) {
      reposts = state.reposts;
      isLoadingMore = true;
    }
    
    if (reposts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.repeat, size: 60.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              'لا توجد إعادة نشر بعد',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 8.h),
      itemCount: reposts.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == reposts.length) {
          return _buildLoadingMoreIndicator();
        }
        
        final repost = reposts[index];
        return _buildRepostItem(repost);
      },
    );
  }

  Widget _buildRepostItem(RepostModel repost) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          _navigateToUserProfile(repost.user.id);
        },
        child: _buildUserAvatar(repost),
      ),
      title: GestureDetector(
        onTap: () {
          _navigateToUserProfile(repost.user.id);
        },
        child: Text(
          repost.user.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ),
      subtitle: Text(
        'شارك ${_formatTime(repost.createdAt)}',
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.repeat,
        color: Colors.green,
        size: 20.sp,
      ),
      // ✅ إزالة onTap من ListTile لأن الصورة واسم المستخدم هما اللي بيفتحوا البروفايل
    );
  }

  Widget _buildUserAvatar(RepostModel repost) {
    return Stack(
      children: [
        Container(
          width: 48.r,
          height: 48.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _getRankColor(repost.user.rank).withOpacity(0.3),
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
            child: repost.user.image.isNotEmpty
                ? Image.network(
                    repost.user.image,
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
                          value: loadingProgress.expectedTotalBytes != null
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
            color: _getRankColor(repost.user.rank),
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
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (!_repostCubit.hasMore && _repostCubit.repostsCount > 0) {
      return Container(
        padding: EdgeInsets.all(20.h),
        child: Center(
          child: Text(
            'تم تحميل جميع إعادة النشر',
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