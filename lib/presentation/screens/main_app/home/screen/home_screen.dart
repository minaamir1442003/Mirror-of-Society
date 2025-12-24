import 'package:app_1/core/theme/app_colors.dart';
import 'package:app_1/core/theme/app_theme.dart';
import 'package:app_1/data/models/bolt_model.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/main_app/chat/chats_screen.dart';
import 'package:app_1/presentation/screens/main_app/home/Cubit/home_cubit.dart';
import 'package:app_1/presentation/screens/main_app/home/Models/home_feed_model.dart';
import 'package:app_1/presentation/widgets/bolts/bolt_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _setupScrollController();
    _initializeOnce();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      final homeCubit = context.read<HomeCubit>();

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !homeCubit.isLoadingMore &&
          homeCubit.hasMore) {
        _loadMore();
      }
    });
  }

  void _initializeOnce() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeCubit = context.read<HomeCubit>();

      // ✅ التحقق إذا تم التهيئة مسبقاً
      if (homeCubit.isInitialized) {
        print('✅ HomeScreen: Cubit already initialized');
        return;
      }

      print('🔄 HomeScreen: Initializing cubit...');
      await homeCubit.initialize();
    });
  }

  Future<void> _loadMore() async {
    final homeCubit = context.read<HomeCubit>();
    if (!homeCubit.isLoadingMore && homeCubit.hasMore) {
      await homeCubit.loadMore();
    }
  }

  Future<void> _onRefresh() async {
    // ✅ إعادة تحميل البيانات فقط، بدون إعادة التهيئة
    await context.read<HomeCubit>().refresh();
  }

  void resetScreen() {
    final homeCubit = context.read<HomeCubit>();
    homeCubit.resetInitialization();
    homeCubit.clearCacheAndData();
  }

  // ✅ بناء AppBar
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
      title: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final cubit = context.read<HomeCubit>();
          if (cubit.currentCategoryId != null) {
            final category = cubit.categories.firstWhere(
              (c) => c.id == cubit.currentCategoryId,
              orElse:
                  () => Category(
                    id: '',
                    name: 'تصنيف',
                    color: '#000000',
                    telegramsCount: 0,
                  ),
            );
            return Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            );
          }
          return Text(
            'الصفحة الرئيسية',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          );
        },
      ),
      centerTitle: true,
      actions: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.search, size: 30, color: Colors.black),
              onPressed: _showSearchDialog,
            ),
            SizedBox(width: 5),
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatsScreen()),
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

  // ✅ بناء قائمة التصنيفات
  Widget _buildCategories(List<Category> categories) {
    // إضافة "الكل" في البداية
    final allCategories = [
      Category(
        id: 'all',
        name: _getTranslatedCategoryName('All'),
        color: '#000000',
        icon: null,
        telegramsCount: 0,
      ),
      ...categories,
    ];

    return Container(
      padding: EdgeInsets.only(left: 82.w),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          bool isSelected = index == _selectedCategoryIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });

              final homeCubit = context.read<HomeCubit>();

              if (category.id == 'all') {
                homeCubit.switchCategory(null);
              } else {
                homeCubit.switchCategory(category.id);
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primary : AppColors.extraLightGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category.name,
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

  String _getTranslatedCategoryName(String englishName) {
    final langProvider = context.read<LanguageProvider>();
    final isArabic = langProvider.getCurrentLanguageName() == 'العربية';

    if (!isArabic) return englishName;

    final translations = {
      'Arts': 'فنون',
      'Sports': 'رياضة',
      'Technology': 'تكنولوجيا',
      'Movies': 'أفلام',
      'Fashion': 'موضة',
      'Business': 'أعمال',
      'Health': 'صحة',
      'Travel': 'سفر',
      'Science': 'علوم',
      'Gaming': 'ألعاب',
      'Literature': 'أدب',
      'Politics': 'سياسة',
      'Food': 'طعام',
      'Music': 'موسيقى',
      'Education': 'تعليم',
      'All': 'الكل',
    };

    return translations[englishName] ?? englishName;
  }

  // ✅ بناء الجسم الرئيسي - المعدل
  Widget _buildBody(BuildContext context, HomeState state) {
    final homeCubit = context.read<HomeCubit>();

    if (state is HomeInitial ||
        (state is HomeLoading && homeCubit.feedItems.isEmpty)) {
      return _LoadingWidget(); // ✅ استخدام الـ Widget الداخلي
    }

    if (state is HomeError && homeCubit.feedItems.isEmpty) {
      return _ErrorWidget(
        // ✅ استخدام الـ Widget الداخلي
        message: state.error,
        onRetry: () => homeCubit.refresh(),
      );
    }

    List<FeedItem> feedItems = homeCubit.feedItems;
    List<OnThisDayEvent> onThisDayEvents = homeCubit.onThisDayEvents;
    List<Category> categories = homeCubit.categories;

    if (feedItems.isEmpty) {
      return _EmptyStateWidget(
        // ✅ استخدام الـ Widget الداخلي
        message: 'لا توجد برقيات لعرضها',
        onRetry: () => homeCubit.refresh(),
      );
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _onRefresh,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/image/Untitled-1.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 10),
              _buildCategories(categories),
              SizedBox(height: 30),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    ..._buildBoltsWithTodayFeature(
                      feedItems,
                      onThisDayEvents,
                      context,
                    ),

                    // مؤشر التحميل للـ Pagination
                    if (homeCubit.isLoadingMore)
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      ),

                    // رسالة نهاية المحتوى
                    if (!homeCubit.hasMore && homeCubit.feedItems.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'تم الوصول إلى نهاية المحتوى',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                    // إعلان الاشتراك
                    _buildAdCard(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ تحويل FeedItem إلى BoltModel
  BoltModel _feedItemToBoltModel(FeedItem feedItem, BuildContext context) {
    final homeCubit = context.read<HomeCubit>();

    return BoltModel(
      id: feedItem.id,
      content: feedItem.content,
      category: feedItem.category.name,
      categoryColor: _parseColor(feedItem.category.color),
      categoryIcon: _getCategoryIcon(feedItem.category.name),
      createdAt: feedItem.createdAt,
      userName: feedItem.user.name,
      userImage:
          feedItem.user.image.isNotEmpty
              ? feedItem.user.image
              : "assets/image/images.jpg",
      userId: feedItem.user.id,
      likes: feedItem.metrics.likesCount,
      comments: feedItem.metrics.commentsCount,
      shares: feedItem.metrics.repostsCount,
      isAd: false,
      isLiked: feedItem.isLiked,
      isReposted: feedItem.isReposted,
      userRank: feedItem.user.rank,
      onLikePressed: () {
        if (feedItem.isLiked) {
          homeCubit.unlikeTelegram(feedItem.id);
        } else {
          homeCubit.likeTelegram(feedItem.id);
        }
      },
      onCommentPressed: () {
        // TODO: فتح التعليقات
      },
      onSharePressed: () {
        homeCubit.repostTelegram(feedItem.id);
      },
    );
  }

  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'arts':
        return Icons.palette;
      case 'sports':
        return Icons.sports_soccer;
      case 'technology':
        return Icons.computer;
      case 'movies':
        return Icons.movie;
      case 'fashion':
        return Icons.shopping_bag;
      case 'business':
        return Icons.business;
      case 'health':
        return Icons.health_and_safety;
      case 'travel':
        return Icons.flight;
      case 'science':
        return Icons.science;
      case 'gaming':
        return Icons.games;
      case 'literature':
        return Icons.menu_book;
      default:
        return Icons.category;
    }
  }

  // ✅ بناء البرقيات مع ميزة "في مثل هذا اليوم"
  List<Widget> _buildBoltsWithTodayFeature(
    List<FeedItem> feedItems,
    List<OnThisDayEvent> events,
    BuildContext context,
  ) {
    List<Widget> widgets = [];

    for (int i = 0; i < feedItems.length; i++) {
      widgets.add(BoltCard(bolt: _feedItemToBoltModel(feedItems[i], context)));

      // إضافة ميزة "في مثل هذا اليوم" بعد كل 3 برقيات
      if ((i + 1) % 3 == 0 && i != feedItems.length - 1) {
        widgets.add(_buildTodayFeature(events));
      }
    }

    // إذا كان عدد البرقيات أقل من 3 وأوجدت أحداث، نضيف الميزة في النهاية
    if (feedItems.length < 3 && events.isNotEmpty) {
      widgets.add(_buildTodayFeature(events));
    }

    return widgets;
  }

  // ✅ بناء ميزة "في مثل هذا اليوم"
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
            color: Colors.white.withOpacity(0.9),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                  image:
                      event.imageUrl != null
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
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 18,
                        ),
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
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
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
            color: Colors.white.withOpacity(0.9),
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
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 18,
                        ),
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
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${arabicMonths[date.month - 1]} ${date.year}';
  }

  Widget _buildAdCard() {
    return GestureDetector(
      onTap: () => _showSubscriptionDialog(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
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
                  children: [
                    Icon(Icons.local_offer, color: Color(0xFF7C3AED), size: 24),
                    SizedBox(height: 4),
                    Text(
                      'خصم 30%',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحديث حسابك إلى المميز',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'احصل على مزايا حصرية وإزالة الإعلانات',
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                    SnackBar(content: Text('سيتم توجيهك لصفحة الاشتراك')),
                  );
                },
                child: Text('اشترك الآن'),
              ),
            ],
          ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('بحث'),
            content: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن برقيات أو مستخدمين...',
                prefixIcon: Icon(Icons.search),
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
          ),
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
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
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

// ✅ ========== Widgets الداخلية ==========

// ✅ Loading Widget
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'جاري التحميل...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ✅ Error Widget
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

// ✅ Empty State Widget
class _EmptyStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _EmptyStateWidget({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          if (onRetry != null) ...[
            SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: Text('إعادة التحميل')),
          ],
        ],
      ),
    );
  }
}
