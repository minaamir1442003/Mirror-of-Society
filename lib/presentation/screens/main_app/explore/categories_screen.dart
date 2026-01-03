import 'package:app_1/presentation/screens/main_app/explore/cubits/category_cubit.dart';
import 'package:app_1/presentation/screens/main_app/explore/cubits/category_state.dart';
import 'package:app_1/presentation/screens/main_app/explore/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_1/core/theme/app_colors.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  final Function(String)? onCategorySelected;
  const CategoriesScreen({Key? key, this.onCategorySelected}) : super(key: key);
  
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _searchController = TextEditingController();
  late CategoryCubit _categoryCubit;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _categoryCubit = context.read<CategoryCubit>();
    _initializeOnce();
  }

  void _initializeOnce() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _categoryCubit.initialize();
    });
  }

  Future<void> _onRefresh() async {
    print('🔄 CategoriesScreen: Refreshing with overlay...');
    try {
      await _categoryCubit.refresh();
    } catch (e) {
      // الخطأ تم التعامل معه في الكيوبت
      print('⚠️ Refresh failed: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // دالة لتحويل hex color إلى Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // دالة للحصول على icon بناءً على اسم الفئة
  IconData _getIconForCategory(String categoryName) {
    final iconsMap = {
      'سياسة': Icons.account_balance,
      'رياضة': Icons.sports_soccer,
      'فن': Icons.palette,
      'تكنولوجيا': Icons.computer,
      'صحة': Icons.health_and_safety,
      'سفر': Icons.flight,
      'طعام': Icons.restaurant,
      'موضة': Icons.shopping_bag,
      'علوم': Icons.science,
      'أعمال': Icons.business,
      'موسيقى': Icons.music_note,
      'أفلام': Icons.movie,
      'ألعاب': Icons.videogame_asset,
      'أدب': Icons.book,
      'تعليم': Icons.school,
      'Politics': Icons.account_balance,
      'Sports': Icons.sports_soccer,
      'Arts': Icons.palette,
      'Technology': Icons.computer,
      'Health': Icons.health_and_safety,
      'Travel': Icons.flight,
      'Food': Icons.restaurant,
      'Fashion': Icons.shopping_bag,
      'Science': Icons.science,
      'Business': Icons.business,
      'Music': Icons.music_note,
      'Movies': Icons.movie,
      'Gaming': Icons.videogame_asset,
      'Literature': Icons.book,
      'Education': Icons.school,
    };
    
    return iconsMap[categoryName] ?? Icons.category;
  }

  // دالة للحصول على الوصف بناءً على اسم الفئة
  String _getDescriptionForCategory(String categoryName, bool isArabic) {
    final descriptionsArabic = {
      'سياسة': 'الأخبار السياسية والتحليلات',
      'رياضة': 'أخبار الرياضة والمباريات',
      'فن': 'الفنون والأدب والثقافة',
      'تكنولوجيا': 'أحدث الأخبار والتطورات التقنية',
      'صحة': 'نصائح صحية وأخبار طبية',
      'سفر': 'نصائح السفر والرحلات',
      'طعام': 'وصفات وأخبار الطعام',
      'موضة': 'أحدث صيحات الموضة',
      'علوم': 'أحدث الاكتشافات العلمية',
      'أعمال': 'الأخبار الاقتصادية والمالية',
      'موسيقى': 'أخبار الموسيقى والحفلات',
      'أفلام': 'أخبار الأفلام والسينما',
      'ألعاب': 'أحدث ألعاب الفيديو والتطورات',
      'أدب': 'أخبار الأدب والكتب',
      'تعليم': 'أخبار التعليم والدورات',
    };

    final descriptionsEnglish = {
      'Politics': 'Political news and analysis',
      'Sports': 'Sports news and matches',
      'Arts': 'Arts, literature and culture',
      'Technology': 'Latest tech news and developments',
      'Health': 'Health tips and medical news',
      'Travel': 'Travel tips and trips',
      'Food': 'Recipes and food news',
      'Fashion': 'Latest fashion trends',
      'Science': 'Latest scientific discoveries',
      'Business': 'Economic and financial news',
      'Music': 'Music news and concerts',
      'Movies': 'Movie and cinema news',
      'Gaming': 'Latest video games and developments',
      'Literature': 'Literature and books news',
      'Education': 'Education news and courses',
    };
    
    return isArabic 
        ? descriptionsArabic[categoryName] ?? 'مواضيع متنوعة'
        : descriptionsEnglish[categoryName] ?? 'Various topics';
  }

  // AppBar
  AppBar _buildAppBar(BuildContext context, bool isArabic) {
    return AppBar(
      leadingWidth: 150.w,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Row(
        children: [
          Icon(Icons.category, color: AppColors.primary, size: 30.sp),
          SizedBox(width: 8.w),
          Text(
            isArabic ? 'التصنيفات' : 'Categories',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.sp,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: AppColors.primary),
          onPressed: () {
            _refreshIndicatorKey.currentState?.show();
          },
        ),
      ],
    );
  }

  // Category Card
  Widget _buildCategoryCard(CategoryModel category, bool isArabic) {
    final color = _getColorFromHex(category.color);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      child: Container(
        constraints: BoxConstraints(minHeight: 180.h),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getIconForCategory(category.name),
                      color: color,
                      size: 20.sp,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${category.telegramsCount}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                _getDescriptionForCategory(category.name, isArabic),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Color(0xFF8E8E93),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Center(
                child: SizedBox(
                  width: 80.w,
                  height: 28.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onCategorySelected != null) {
                        widget.onCategorySelected!(category.id.toString());
                        print('✅ Category selected: ${category.name} (ID: ${category.id})');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      isArabic ? 'تصفح' : 'Browse',
                      style: TextStyle(fontSize: 11.sp),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return BlocConsumer<CategoryCubit, CategoryState>(
      listener: (context, state) {
        if (state is CategoryError && state.cachedCategories == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Color(0xFFFF3B30),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        // ✅ بناء الـ UI مع Overlay Loading
        return Scaffold(
          appBar: isPortrait ? _buildAppBar(context, isArabic) : null,
          body: SafeArea(
            child: Stack(
              children: [
                // ✅ الجزء الرئيسي مع Refresh Indicator
                RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _onRefresh,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: _buildMainContent(state, isArabic),
                  ),
                ),
                
                // ✅ Overlay Loading عند التحميل أو الـ Refresh
                if (state is CategoryLoading || state is CategoryRefreshingWithOverlay)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Main Content Widget
  Widget _buildMainContent(CategoryState state, bool isArabic) {
    return Column(
      children: [
        Expanded(
          child: _buildContent(state, isArabic),
        ),
      ],
    );
  }

  Widget _buildContent(CategoryState state, bool isArabic) {
    // ✅ استخدام دالة الكيوبت للحصول على البيانات المعروضة
    final categoriesToShow = _categoryCubit.getDisplayCategories(state);
    
    // ✅ إذا كان هناك بيانات للعرض
    if (categoriesToShow.isNotEmpty) {
      return GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.75,
        ),
        itemCount: categoriesToShow.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(categoriesToShow[index], isArabic);
        },
      );
    }
    
    // ✅ إذا لم تكن هناك بيانات على الإطلاق (التحميل الأولي)
    if (state is CategoryInitial || state is CategoryLoading) {
      return _buildLoadingWidget(isArabic);
    }
    
    // ✅ حالة الخطأ بدون بيانات مخزنة
    if (state is CategoryError && !_categoryCubit.hasCachedData(state)) {
      return _buildErrorWidget(state.message, null, isArabic);
    }
    
    // ✅ حالة فارغة (نادراً ما تحدث)
    return _buildEmptyWidget(isArabic);
  }

  // ✅ Loading Widget للتحميل الأولي
  Widget _buildLoadingWidget(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16.h),
          Text(
            isArabic ? 'جاري تحميل التصنيفات...' : 'Loading categories...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  // Error Widget
  Widget _buildErrorWidget(String message, List<CategoryModel>? cachedCategories, bool isArabic) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF3B30),
                  size: 50.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Color(0xFF8E8E93),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                if (cachedCategories != null && cachedCategories.isNotEmpty)
                  Text(
                    isArabic ? 'يتم عرض البيانات المخزنة' : 'Showing cached data',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xFF34C759),
                    ),
                  ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => _categoryCubit.initialize(force: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    isArabic ? 'إعادة المحاولة' : 'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Empty Widget
  Widget _buildEmptyWidget(bool isArabic) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  color: Color(0xFF8E8E93),
                  size: 50.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  isArabic ? 'لا توجد تصنيفات متاحة' : 'No categories available',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => _categoryCubit.initialize(force: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    isArabic ? 'إعادة التحميل' : 'Reload',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}