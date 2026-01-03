// lib/presentation/screens/main_app/profile/screen/comments_bottom_sheet.dart
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/comment_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/comment_model.dart';
import 'package:app_1/core/theme/app_theme.dart';
import 'package:app_1/presentation/screens/main_app/profile/screen/profile_screen.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String telegramId;
  final CommentCubit commentCubit;

  const CommentsBottomSheet({
    Key? key,
    required this.telegramId,
    required this.commentCubit,
  }) : super(key: key);

  @override
  _CommentsBottomSheetState createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _replyingToId;
  String? _replyingToName;
  
  bool _isLoadingMore = false;
  bool _isInitialLoad = true;
  bool _hasShownEmptyState = false;
  Map<int, bool> _expandedReplies = {};

  @override
  void initState() {
    super.initState();
    _loadInitialComments();
    _setupScrollController();
  }

  void _loadInitialComments() {
    print('🔄 Starting initial comments load...');
    _isInitialLoad = true;
    _hasShownEmptyState = false;
    widget.commentCubit.getComments(widget.telegramId, forceRefresh: true);
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && widget.commentCubit.hasMore) {
          _loadMoreComments();
        }
      }
    });
  }

  void _loadMoreComments() {
    if (_isLoadingMore || !widget.commentCubit.hasMore) return;
    
    _isLoadingMore = true;
    print('🔄 Loading more comments...');
    
    widget.commentCubit.getComments(widget.telegramId, loadMore: true)
      .then((_) {
        _isLoadingMore = false;
        print('✅ More comments loaded');
      })
      .catchError((e) {
        _isLoadingMore = false;
        print('❌ Error loading more comments: $e');
      });
  }

  void _toggleReplies(int commentId) {
    setState(() {
      _expandedReplies[commentId] = !(_expandedReplies[commentId] ?? false);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LanguageProvider>(context, listen: false)
        .getCurrentLanguageName() == 'العربية';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'التعليقات' : 'Comments',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: BlocConsumer<CommentCubit, CommentState>(
              bloc: widget.commentCubit,
              listener: (context, state) {
                if (state is CommentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                
                if (state is CommentsLoaded && _isInitialLoad) {
                  setState(() {
                    _isInitialLoad = false;
                    if (state.comments.isEmpty) {
                      _hasShownEmptyState = true;
                    }
                  });
                }
                
                if (state is CommentsLoaded && !_isInitialLoad) {
                  setState(() {
                    if (state.comments.isNotEmpty) {
                      _hasShownEmptyState = false;
                    }
                  });
                }
              },
              builder: (context, state) {
                print('📊 Comment State: $state');
                
                // حالة التحميل الأولي
                if ((state is CommentInitial || state is CommentLoading) && _isInitialLoad) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.primaryColor),
                        SizedBox(height: 16.h),
                        Text(
                          isArabic ? 'جاري تحميل التعليقات...' : 'Loading comments...',
                          style: TextStyle(
                            color: AppTheme.darkGray,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // الحصول على التعليقات من الـ cubit مباشرة
                final comments = widget.commentCubit.comments;
                print('📝 Comments count from cubit: ${comments.length}');

                // حالة عدم وجود تعليقات
                if (comments.isEmpty && _hasShownEmptyState && !_isInitialLoad) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          isArabic ? 'لا توجد تعليقات' : 'No comments yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          isArabic ? 'كن أول من يعلق!' : 'Be the first to comment!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // حالة وسيطة أثناء التحميل
                if (comments.isEmpty && !_isInitialLoad && !_hasShownEmptyState) {
                  return Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(8.r),
                  itemCount: comments.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == comments.length && _isLoadingMore) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: CircularProgressIndicator(color: AppTheme.primaryColor),
                        ),
                      );
                    }

                    final comment = comments[index];
                    return _buildCommentItem(comment, isArabic, 0, true);
                  },
                );
              },
            ),
          ),

          // Reply Indicator
          if (_replyingToName != null) _buildReplyIndicator(isArabic),

          // Comment Input
          _buildCommentInput(isArabic),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, bool isArabic, int depth, bool isParent) {
    final hasReplies = comment.children.isNotEmpty;
    final isExpanded = _expandedReplies[comment.id] ?? true;
    final replyCount = comment.children.length;
    
    return GestureDetector(
      // ✅ هنا التحكم: الـ GestureDetector على الصورة فقط، مش الكل
      behavior: HitTestBehavior.translucent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // خط التوصيل الأفقي
          if (depth > 0)
            Container(
              margin: EdgeInsets.only(left: depth * 20.w),
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 1.h,
                    color: Colors.grey[300],
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),

          Container(
            margin: EdgeInsets.only(
              left: depth * 20.w + (depth > 0 ? 28.w : 0),
            ),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: isParent ? Colors.grey[200]! : Colors.grey[100]!,
                  width: 1,
                ),
              ),
              color: isParent ? Colors.white : Colors.grey[50],
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comment Header
                    Row(
                      children: [
                        // ✅ هذه الصورة فقط هي اللي تفتح البروفايل
                        GestureDetector(
                          onTap: () {
                            _navigateToUserProfile(comment.user.id);
                          },
                          child: CircleAvatar(
                            radius: 16.r,
                            backgroundImage: NetworkImage(comment.user.image.isNotEmpty
                                ? comment.user.image
                                : 'https://mirsoc.com/images/usersProfile/profile.png'),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ اسم المستخدم يفتح البروفايل برضو
                              GestureDetector(
                                onTap: () {
                                  _navigateToUserProfile(comment.user.id);
                                },
                                child: Text(
                                  comment.user.name,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatTime(comment.createdAt, isArabic),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasReplies && isParent)
                          IconButton(
                            icon: Icon(
                              isExpanded ? Icons.expand_less : Icons.expand_more,
                              size: 18.sp,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () => _toggleReplies(comment.id),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.more_vert, size: 18.sp, color: Colors.grey.shade600),
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'reply',
                              child: Row(
                                children: [
                                  Icon(Icons.reply, size: 16.sp, color: Colors.grey.shade700),
                                  SizedBox(width: 8.w),
                                  Text(
                                    isArabic ? 'رد' : 'Reply',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 16.sp, color: Colors.red.shade600),
                                  SizedBox(width: 8.w),
                                  Text(
                                    isArabic ? 'حذف' : 'Delete',
                                    style: TextStyle(fontSize: 12.sp, color: Colors.red.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'reply') {
                              setState(() {
                                _replyingToId = comment.id;
                                _replyingToName = comment.user.name;
                              });
                            } else if (value == 'delete') {
                              _showDeleteCommentDialog(comment);
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Comment Content
                    Padding(
                      padding: EdgeInsets.only(left: 40.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.content,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          // Reply Button
                          InkWell(
                            onTap: () {
                              setState(() {
                                _replyingToId = comment.id;
                                _replyingToName = comment.user.name;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(Icons.reply, size: 14.sp, color: AppTheme.primaryColor),
                                SizedBox(width: 4.w),
                                Text(
                                  isArabic ? 'رد' : 'Reply',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Show Replies Button
                          if (hasReplies && isParent)
                            InkWell(
                              onTap: () => _toggleReplies(comment.id),
                              child: Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20.w,
                                      height: 1.h,
                                      color: Colors.grey[300],
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      isArabic 
                                          ? 'عرض الردود ($replyCount)'
                                          : 'View replies ($replyCount)',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Icon(
                                      isExpanded ? Icons.expand_less : Icons.expand_more,
                                      size: 16.sp,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Nested Comments
          if (hasReplies && (isExpanded || !isParent)) ...[
            SizedBox(height: 8.h),
            ...comment.children.map(
              (child) => _buildCommentItem(child, isArabic, depth + 1, false)
            ).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyIndicator(bool isArabic) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Colors.grey[100],
      child: Row(
        children: [
          Icon(Icons.reply, size: 16.sp, color: AppTheme.primaryColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '${isArabic ? 'جارٍ الرد على' : 'Replying to'} $_replyingToName',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.primaryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16.sp),
            onPressed: () {
              setState(() {
                _replyingToId = null;
                _replyingToName = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isArabic) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: isArabic ? 'أضف تعليقاً...' : 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          BlocBuilder<CommentCubit, CommentState>(
            bloc: widget.commentCubit,
            builder: (context, state) {
              return state is CommentAdding
                  ? Container(
                      width: 55.w,
                      height: 55.w,
                      padding: EdgeInsets.all(12.r),
                      child: CircularProgressIndicator(
                        strokeWidth: 3.r,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : Container(
                      width: 55.w,
                      height: 55.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            Color(0xFF764BA2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 8.r,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        shape: CircleBorder(),
                        child: InkWell(
                          onTap: () async {
                            if (_commentController.text.trim().isNotEmpty) {
                              try {
                                await widget.commentCubit.addComment(
                                  telegramId: widget.telegramId,
                                  content: _commentController.text.trim(),
                                  parentId: _replyingToId,
                                );
                                
                                _commentController.clear();
                                setState(() {
                                  _replyingToId = null;
                                  _replyingToName = null;
                                });
                                
                                // التمرير إلى الأسفل
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (_scrollController.hasClients) {
                                    _scrollController.animateTo(
                                      _scrollController.position.maxScrollExtent,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                });
                              } catch (e) {
                                // الخطأ معالج في الـ listener
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: Center(
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteCommentDialog(CommentModel comment) {
    final isArabic = Provider.of<LanguageProvider>(context, listen: false)
        .getCurrentLanguageName() == 'العربية';

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red.shade700),
              SizedBox(width: 10.w),
              Text(
                isArabic ? 'حذف التعليق' : 'Delete Comment',
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
                ? 'هل أنت متأكد من حذف هذا التعليق؟\nلا يمكن التراجع عن هذا الإجراء.'
                : 'Are you sure you want to delete this comment?\nThis action cannot be undone.',
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
              onPressed: () async {
                Navigator.pop(context);
                await widget.commentCubit.deleteComment(comment.id, widget.telegramId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: Text(isArabic ? 'حذف' : 'Delete'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دالة التنقل الجديدة
  void _navigateToUserProfile(int userId) {
  // ✅ تأكد إن ده مش نفس المستخدم الحالي
  final profileCubit = context.read<ProfileCubit>();
  final currentUserId = profileCubit.cachedProfile?.id;
  
  if (userId.toString() == currentUserId?.toString()) {
    print('⚠️ Same user, no navigation needed');
    return;
  }
  
  print('📍 Opening profile for user: $userId');
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserProfileScreen(userId: userId.toString()), // ✅ هنا بتغير userId
    ),
  ).then((value) {
    // ✅ بعد الرجوع، أعد تحميل التعليقات
    widget.commentCubit.getComments(widget.telegramId, forceRefresh: true);
  });
}

  String _formatTime(DateTime time, bool isArabic) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return isArabic 
          ? 'قبل ${difference.inMinutes} د'
          : '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return isArabic
          ? 'قبل ${difference.inHours} س'
          : '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return isArabic
          ? 'قبل ${difference.inDays} ي'
          : '${difference.inDays}d ago';
    } else {
      return isArabic
          ? '${time.day}/${time.month}'
          : '${time.month}/${time.day}';
    }
  }
}