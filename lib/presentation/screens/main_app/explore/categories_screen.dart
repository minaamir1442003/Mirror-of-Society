import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';

class CategoriesScreen extends StatefulWidget {
  final Function(String)? onCategorySelected;
  const CategoriesScreen({Key? key, this.onCategorySelected}) : super(key: key);
  
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // نموذج البيانات من API
  Map<String, dynamic> apiDataArabic = {
    "status": true,
    "message": "Categories fetched successfully",
    "data": [
      {
        "id": 1,
        "name": "سياسة",
        "color": "#dc3545",
        "icon": null,
        "telegrams_count": 34
      },
      {
        "id": 2,
        "name": "رياضة",
        "color": "#28a745",
        "icon": null,
        "telegrams_count": 35
      },
      {
        "id": 3,
        "name": "فن",
        "color": "#6f42c1",
        "icon": null,
        "telegrams_count": 34
      },
      {
        "id": 4,
        "name": "تكنولوجيا",
        "color": "#007bff",
        "icon": null,
        "telegrams_count": 36
      },
      {
        "id": 5,
        "name": "صحة",
        "color": "#17a2b8",
        "icon": null,
        "telegrams_count": 26
      },
      {
        "id": 6,
        "name": "سفر",
        "color": "#ffc107",
        "icon": null,
        "telegrams_count": 38
      },
      {
        "id": 7,
        "name": "طعام",
        "color": "#fd7e14",
        "icon": null,
        "telegrams_count": 27
      },
      {
        "id": 8,
        "name": "موضة",
        "color": "#e83e8c",
        "icon": null,
        "telegrams_count": 31
      },
      {
        "id": 9,
        "name": "علوم",
        "color": "#20c997",
        "icon": null,
        "telegrams_count": 33
      },
      {
        "id": 10,
        "name": "أعمال",
        "color": "#343a40",
        "icon": null,
        "telegrams_count": 44
      },
      {
        "id": 11,
        "name": "موسيقى",
        "color": "#6610f2",
        "icon": null,
        "telegrams_count": 33
      },
      {
        "id": 12,
        "name": "أفلام",
        "color": "#d63384",
        "icon": null,
        "telegrams_count": 37
      },
      {
        "id": 13,
        "name": "ألعاب",
        "color": "#198754",
        "icon": null,
        "telegrams_count": 26
      },
      {
        "id": 14,
        "name": "أدب",
        "color": "#fd7e14",
        "icon": null,
        "telegrams_count": 39
      },
      {
        "id": 15,
        "name": "تعليم",
        "color": "#0dcaf0",
        "icon": null,
        "telegrams_count": 30
      }
    ]
  };

  Map<String, dynamic> apiDataEnglish = {
    "status": true,
    "message": "Categories fetched successfully",
    "data": [
      {
        "id": 1,
        "name": "Politics",
        "color": "#dc3545",
        "icon": null,
        "telegrams_count": 34
      },
      {
        "id": 2,
        "name": "Sports",
        "color": "#28a745",
        "icon": null,
        "telegrams_count": 35
      },
      {
        "id": 3,
        "name": "Arts",
        "color": "#6f42c1",
        "icon": null,
        "telegrams_count": 34
      },
      {
        "id": 4,
        "name": "Technology",
        "color": "#007bff",
        "icon": null,
        "telegrams_count": 36
      },
      {
        "id": 5,
        "name": "Health",
        "color": "#17a2b8",
        "icon": null,
        "telegrams_count": 26
      },
      {
        "id": 6,
        "name": "Travel",
        "color": "#ffc107",
        "icon": null,
        "telegrams_count": 38
      },
      {
        "id": 7,
        "name": "Food",
        "color": "#fd7e14",
        "icon": null,
        "telegrams_count": 27
      },
      {
        "id": 8,
        "name": "Fashion",
        "color": "#e83e8c",
        "icon": null,
        "telegrams_count": 31
      },
      {
        "id": 9,
        "name": "Science",
        "color": "#20c997",
        "icon": null,
        "telegrams_count": 33
      },
      {
        "id": 10,
        "name": "Business",
        "color": "#343a40",
        "icon": null,
        "telegrams_count": 44
      },
      {
        "id": 11,
        "name": "Music",
        "color": "#6610f2",
        "icon": null,
        "telegrams_count": 33
      },
      {
        "id": 12,
        "name": "Movies",
        "color": "#d63384",
        "icon": null,
        "telegrams_count": 37
      },
      {
        "id": 13,
        "name": "Gaming",
        "color": "#198754",
        "icon": null,
        "telegrams_count": 26
      },
      {
        "id": 14,
        "name": "Literature",
        "color": "#fd7e14",
        "icon": null,
        "telegrams_count": 39
      },
      {
        "id": 15,
        "name": "Education",
        "color": "#0dcaf0",
        "icon": null,
        "telegrams_count": 30
      }
    ]
  };

  // دالة لتحويل hex color إلى Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
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
      // الإنجليزية
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
  String _getDescriptionForCategory(String categoryName) {
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
    
    final languageProvider = context.read<LanguageProvider>();
    if (languageProvider.isArabic) {
      return descriptionsArabic[categoryName] ?? 'مواضيع متنوعة';
    } else {
      return descriptionsEnglish[categoryName] ?? 'Various topics';
    }
  }

  List<Category> _getCategoriesFromApi() {
    final languageProvider = context.read<LanguageProvider>();
    final apiData = languageProvider.isArabic ? apiDataArabic : apiDataEnglish;
    final List<dynamic> categoriesData = apiData['data'];
    
    return categoriesData.map((item) {
      return Category(
        id: item['id'],
        name: item['name'],
        color: _getColorFromHex(item['color']),
        icon: _getIconForCategory(item['name']),
        count: item['telegrams_count'],
        description: _getDescriptionForCategory(item['name']),
      );
    }).toList();
  }

  // AppBar
  AppBar _buildAppBar() {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
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
        Icon(
          Icons.bookmark,
          color: AppColors.warning,
          size: 40.sp,
        ),
        SizedBox(width: 8.w),
        IconButton(
          icon: Icon(Icons.search, size: 25.sp),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Category category) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showCategoryDetails(context, category);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 180.h),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
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
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '${category.count}',
                        style: TextStyle(
                          color: category.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: Text(
                    category.description,
                    style: TextStyle(
                      color: AppColors.darkGray,
                      fontSize: 11.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: SizedBox(
                    width: 80.w,
                    height: 28.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.onCategorySelected != null) {
                          widget.onCategorySelected!(category.name);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: category.color,
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
      ),
    );
  }

  void _showCategoryDetails(BuildContext context, Category category) {
    final languageProvider = context.read<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${category.count} ${isArabic ? 'برقية' : 'telegrams'}',
                            style: TextStyle(
                              color: category.color,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  category.description,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.darkGray,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 30.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onCategorySelected != null) {
                      widget.onCategorySelected!(category.name);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: category.color,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    isArabic ? 'عرض برقيات ${category.name}' : 'View ${category.name} telegrams',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
                SizedBox(height: 10.h),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      isArabic ? 'إغلاق' : 'Close',
                      style: TextStyle(fontSize: 14.sp)
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

  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 400) {
      return 1;
    } else if (screenWidth < 600) {
      return 2;
    } else if (screenWidth < 900) {
      return 3;
    } else {
      return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final languageProvider = context.watch<LanguageProvider>();
    final categories = _getCategoriesFromApi();
    
    return Scaffold(
      appBar: isPortrait ? _buildAppBar() : null,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = _calculateCrossAxisCount(context);
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: GridView.builder(
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: _getAspectRatio(crossAxisCount),
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryCard(categories[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getAspectRatio(int crossAxisCount) {
    switch (crossAxisCount) {
      case 1:
        return 1.3;
      case 2:
        return 0.75;
      case 3:
        return 0.7;
      case 4:
        return 0.65;
      default:
        return 0.7;
    }
  }
}

class Category {
  final int id;
  final String name;
  final Color color;
  final IconData icon;
  final String description;
  final int count;
  bool isFollowing;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.count,
    required this.description,
    this.isFollowing = false,
  });

  Category copyWith({bool? isFollowing, int? count}) {
    return Category(
      id: id,
      name: name,
      color: color,
      icon: icon,
      count: count ?? this.count,
      description: description,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}