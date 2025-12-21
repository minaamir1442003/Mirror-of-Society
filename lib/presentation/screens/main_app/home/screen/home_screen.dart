import 'package:app_1/core/theme/app_colors.dart';
import 'package:app_1/core/theme/app_theme.dart';
import 'package:app_1/data/models/bolt_model.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/main_app/chat/chats_screen.dart';
import 'package:app_1/presentation/screens/main_app/home/Cubit/home_cubit.dart';
import 'package:app_1/presentation/screens/main_app/home/models/home_feed_model.dart';
import 'package:app_1/presentation/widgets/bolts/bolt_card.dart';
import 'package:app_1/presentation/widgets/common/empty_state.dart';
import 'package:app_1/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  final String? initialCategory;
  final Function(String?)? onCategoryChange;
  
  const HomeScreen({
    Key? key, 
    this.initialCategory,
    this.onCategoryChange,
  }) : super(key: key);
  
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  
  List<String> get categories {
    final langProvider = context.read<LanguageProvider>();
    final isArabic = langProvider.getCurrentLanguageName() == 'العربية';
    
    if (isArabic) {
      return [
        'الكل',
        'فنون',
        'رياضة',
        'تكنولوجيا',
        'أفلام',
        'موضة',
        'أعمال',
        'صحة',
        'سفر',
        'علوم',
        'ألعاب',
        'أدب',
      ];
    } else {
      return [
        'All',
        'Arts',
        'Sports',
        'Technology',
        'Movies',
        'Fashion',
        'Business',
        'Health',
        'Travel',
        'Science',
        'Gaming',
        'Literature',
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    
    // إذا كانت هناك فئة أولية، حددها
    if (widget.initialCategory != null) {
      _selectCategoryByName(widget.initialCategory!);
    }
    
    // تحميل البيانات الأولية
    context.read<HomeCubit>().getHomeFeed();
    
    // إعداد الـ ScrollController للتحميل اللانهائي
    _setupScrollController();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  void _loadMore() {
    final homeCubit = context.read<HomeCubit>();
    
    if (!_isLoadingMore && _hasMoreData && homeCubit.hasMore) {
      _isLoadingMore = true;
      print('🔄 Loading more home feed...');
      
      homeCubit.getHomeFeed(loadMore: true).then((_) {
        _isLoadingMore = false;
      });
    }
  }

  void _selectCategoryByName(String categoryName) {
    int index = categories.indexOf(categoryName);
    if (index != -1) {
      setState(() {
        _selectedCategoryIndex = index;
      });
      // إعلام الوالد بتغيير الفئة
      if (widget.onCategoryChange != null) {
        widget.onCategoryChange!(categoryName);
      }
    }
  }

  // دالة يمكن استدعاؤها من الخارج لتحديث الفئة
  void updateSelectedCategory(String categoryName) {
    if (mounted) {
      _selectCategoryByName(categoryName);
    }
  }

  // دالة لتحويل FeedItem إلى BoltModel
  BoltModel _feedItemToBoltModel(FeedItem feedItem) {
    return feedItem.toBoltModel(
      onLikePressed: () => _handleLike(feedItem),
      onCommentPressed: () => _handleComment(feedItem),
      onSharePressed: () => _handleRepost(feedItem),
    );
  }

  void _handleLike(FeedItem feedItem) {
    final homeCubit = context.read<HomeCubit>();
    if (feedItem.isLiked) {
      homeCubit.unlikeTelegram(feedItem.id);
    } else {
      homeCubit.likeTelegram(feedItem.id);
    }
  }

  void _handleComment(FeedItem feedItem) {
    // فتح شاشة التعليقات
    print('Opening comments for telegram ${feedItem.id}');
  }

  void _handleRepost(FeedItem feedItem) {
    final homeCubit = context.read<HomeCubit>();
    homeCubit.repostTelegram(feedItem.id);
  }

  // دالة لفلترة البرقيات حسب الفئة
  List<FeedItem> _getFilteredFeedItems(List<FeedItem> allItems) {
    if (_selectedCategoryIndex == 0) {
      return allItems;
    }
    
    String selectedCategory = categories[_selectedCategoryIndex];
    return allItems.where((item) => item.category.name == selectedCategory).toList();
  }

  AppBar _buildAppBar() {
    return AppBar(
      leadingWidth: 150,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/image/photo_2025-12-06_01-52-45-removebg-preview.png",
              width: 50,
              height: 50,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.bookmark, color: AppTheme.rankColors[4], size: 50),
        ],
      ),
      actions: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.search, size: 30),
              onPressed: _showSearchDialog,
            ),
            SizedBox(width: 5),
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatsScreen(),
                      ),
                    );
                  },
                  child: Image.asset(
                    "assets/image/message.png",
                    width: 32,
                    height: 32,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Positioned(
                  top: 3,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Container(
      padding: EdgeInsets.only(left: 82.w),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
              // إعلام الوالد بتغيير الفئة
              if (widget.onCategoryChange != null) {
                widget.onCategoryChange!(index == 0 ? null : categories[index]);
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.extraLightGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayFeature(List<OnThisDayEvent> events) {
    if (events.isEmpty) {
      return _buildDefaultTodayFeature();
    }
    
    final event = events.first;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black),
          ),
          child: Row(
            children: [
              // الصورة
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                  image: event.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(event.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: AssetImage("assets/image/download (1).jpg"),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'في مثل هذا اليوم',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      _formatDate(event.date),
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      event.title,
                      style: TextStyle(
                        color: AppColors.darkGray.withOpacity(0.8),
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultTodayFeature() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                  image: DecorationImage(
                    image: AssetImage("assets/image/download (1).jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'في مثل هذا اليوم',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '٢٠ يوليو ١٩٦٩',
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'أول هبوط للإنسان على سطح القمر',
                      style: TextStyle(
                        color: AppColors.darkGray.withOpacity(0.8),
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    
    return '${date.day} ${arabicMonths[date.month - 1]} ${date.year}';
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is HomeLoading && state is! HomeLoadingMore) {
      return LoadingIndicator();
    }

    final homeCubit = context.read<HomeCubit>();
    List<FeedItem> feedItems = [];
    List<OnThisDayEvent> onThisDayEvents = [];

    if (state is HomeLoaded) {
      feedItems = _getFilteredFeedItems(state.feedItems);
      onThisDayEvents = state.onThisDayEvents;
      _hasMoreData = state.hasMore;
    } else if (state is HomeLoadingMore) {
      feedItems = _getFilteredFeedItems(state.feedItems);
    }

    if (homeCubit.isFirstLoad && feedItems.isEmpty) {
      return EmptyState(
        icon: Icons.bolt,
        message: 'لا توجد برقيات بعد',
        actionText: 'تحديث',
        onAction: () => homeCubit.getHomeFeed(),
      );
    }

    if (feedItems.isEmpty) {
      return EmptyState(
        icon: Icons.category,
        message: 'لا توجد برقيات في هذه الفئة',
        actionText: 'عرض الكل',
        onAction: () {
          setState(() {
            _selectedCategoryIndex = 0;
          });
        },
      );
    }

    final filteredBolts = feedItems.map(_feedItemToBoltModel).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await homeCubit.getHomeFeed();
      },
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset("assets/image/Untitled-1.jpg", fit: BoxFit.cover),
          ),
          Center(
            child: Container(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  _buildCategories(),
                  SizedBox(height: 30),
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        ..._buildBoltsWithTodayFeature(filteredBolts, onThisDayEvents),
                        if (_isLoadingMore)
                          Container(
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
                        if (!_hasMoreData && homeCubit.feedItemsCount > 0)
                          Container(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                'تم تحميل جميع البرقيات',
                                style: TextStyle(color: AppTheme.darkGray, fontSize: 14),
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
        ],
      ),
    );
  }

  List<Widget> _buildBoltsWithTodayFeature(List<BoltModel> bolts, List<OnThisDayEvent> events) {
    List<Widget> widgets = [];
    
    for (int i = 0; i < bolts.length; i++) {
      widgets.add(BoltCard(bolt: bolts[i]));
      
      if ((i + 1) % 3 == 0 && i != bolts.length - 1) {
        widgets.add(_buildTodayFeature(events));
        widgets.add(SizedBox(height: 8));
      }
    }
    
    if (bolts.length < 3) {
      widgets.add(_buildTodayFeature(events));
      widgets.add(SizedBox(height: 8));
    }
    
    widgets.add(_buildAdCard());
    
    return widgets;
  }

  Widget _buildAdCard() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('اشترك الآن!'),
            content: Text('احصل على خصم 30% على أول اشتراك سنوي.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('لاحقاً'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('سيتم توجيهك لصفحة الاشتراك'),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(bottom: 100, left: 16, right: 16),
                    ),
                  );
                },
                child: Text('اشترك الآن'),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 10,
              top: 10,
              child: Icon(Icons.star, color: Colors.white.withOpacity(0.2), size: 40),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Icon(Icons.bolt, color: Colors.white.withOpacity(0.2), size: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_offer, color: Color(0xFF7C3AED), size: 24),
                        SizedBox(height: 4),
                        Text('خصم 30%', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تحديث حسابك إلى المميز', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('احصل على مزايا حصرية وإزالة الإعلانات', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12), maxLines: 2),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.verified, color: Colors.yellow, size: 14),
                            SizedBox(width: 4),
                            Text('مدى الحياة', style: TextStyle(color: Colors.white, fontSize: 12)),
                            SizedBox(width: 12),
                            Icon(Icons.visibility_off, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('بدون إعلانات', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('بحث'),
          content: TextField(
            decoration: InputDecoration(
              hintText: 'ابحث عن برقيات أو مستخدمين...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
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
                  SnackBar(content: Text('ميزة البحث قيد التطوير')),
                );
              },
              child: Text('بحث'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}