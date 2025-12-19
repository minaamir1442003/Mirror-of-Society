import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class CategoriesScreen extends StatefulWidget {
  final Function(String)? onCategorySelected;
  const CategoriesScreen({Key? key, this.onCategorySelected}) : super(key: key);
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<Category> categories = [
    Category(
      name: 'تكنولوجيا',
      color: AppColors.primary,
      icon: Icons.computer,
      count: 156,
      description: 'أحدث الأخبار والتطورات التقنية',
    ),
    Category(
      name: 'رياضة',
      color: AppColors.success,
      icon: Icons.sports_soccer,
      count: 234,
      description: 'أخبار الرياضة والمباريات',
    ),
    Category(
      name: 'فن',
      color: AppColors.warning,
      icon: Icons.palette,
      count: 189,
      description: 'الفنون والأدب والثقافة',
    ),
    Category(
      name: 'سياسة',
      color: AppColors.danger,
      icon: Icons.account_balance,
      count: 123,
      description: 'الأخبار السياسية والتحليلات',
    ),
    Category(
      name: 'اقتصاد',
      color: Color(0xFF794BC4),
      icon: Icons.trending_up,
      count: 98,
      description: 'الأخبار الاقتصادية والمالية',
    ),
    Category(
      name: 'عامة',
      color: AppColors.darkGray,
      icon: Icons.public,
      count: 345,
      description: 'مواضيع عامة ومنوعة',
    ),
    Category(
      name: 'صحة',
      color: Color(0xFF00B894),
      icon: Icons.health_and_safety,
      count: 87,
      description: 'نصائح صحية وأخبار طبية',
    ),
    Category(
      name: 'سفر',
      color: Color(0xFFFD79A8),
      icon: Icons.flight,
      count: 76,
      description: 'نصائح السفر والرحلات',
    ),
  ];

  // AppBar
  AppBar _buildAppBar() {
    return AppBar(
      leadingWidth: 150.w,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Row(
        children: [
          Icon(Icons.category, color: AppColors.primary, size: 30.sp),
          SizedBox(width: 8.w),
          Text(
            'التصنيفات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
      actions: [
        Icon(
          Icons.bookmark,
          color: AppColors.warning,
          size: 40.sp, // تصغير
        ),
        SizedBox(width: 8.w),
        IconButton(
          icon: Icon(Icons.search, size: 25.sp), // تصغير
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), // تصغير
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showCategoryDetails(context, category);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 180.h), // تحديد ارتفاع أدنى
          child: Padding(
            padding: EdgeInsets.all(12.w), // تصغير
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيع المسافات
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w), // تصغير
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r), // تصغير
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 20.sp, // تصغير
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
                        borderRadius: BorderRadius.circular(6.r), // تصغير
                      ),
                      child: Text(
                        '${category.count}',
                        style: TextStyle(
                          color: category.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp, // تصغير
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 16.sp, // تصغير قليلاً
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded( // استخدام Expanded للوصف
                  child: Text(
                    category.description,
                    style: TextStyle(
                      color: AppColors.darkGray,
                      fontSize: 11.sp, // تصغير
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: SizedBox(
                    width: 80.w, // تصغير عرض الزر
                    height: 28.h, // تصغير ارتفاع الزر
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
                          borderRadius: BorderRadius.circular(15.r), // تصغير
                        ),
                        padding: EdgeInsets.zero, // إزالة padding الإضافي
                      ),
                      child: Text(
                        'تصفح',
                        style: TextStyle(fontSize: 11.sp), // تصغير
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
          child: SingleChildScrollView( // إضافة ScrollView
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
                            '${category.count} برقية',
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: category.color,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'عرض برقيات ${category.name}',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
                SizedBox(height: 10.h),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('إغلاق', style: TextStyle(fontSize: 14.sp)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دالة لحساب عدد الأعمدة بناءً على عرض الشاشة
  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 400) {
      return 1;
    } else if (screenWidth < 600) {
      return 2;
    } else if (screenWidth < 900) {
      return 3;
    } else {
      return 4; // زيادة في الشاشات الكبيرة
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Scaffold(
      appBar: isPortrait ? _buildAppBar() : null,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h), // تقليل المسافة
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = _calculateCrossAxisCount(context);
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w), // تقليل
                    child: GridView.builder(
                      physics: BouncingScrollPhysics(), // إضافة تأثير التمرير
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12.w, // تقليل
                        mainAxisSpacing: 12.h, // تقليل
                        childAspectRatio: _getAspectRatio(crossAxisCount), // دالة جديدة
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

  // دالة جديدة لحساب aspect ratio بناءً على عدد الأعمدة وعرض الشاشة
  double _getAspectRatio(int crossAxisCount) {
    switch (crossAxisCount) {
      case 1:
        return 1.3; // عمود واحد - بطاقة أطول
      case 2:
        return 0.75; // عمودين - بطاقة متوسطة
      case 3:
        return 0.7; // ثلاثة أعمدة - بطاقة أصغر
      case 4:
        return 0.65; // أربعة أعمدة - بطاقة أصغر جداً
      default:
        return 0.7;
    }
  }
}

class Category {
  final String name;
  final Color color;
  final IconData icon;
  final String description;
  int count;
  bool isFollowing;

  Category({
    required this.name,
    required this.color,
    required this.icon,
    required this.count,
    required this.description,
    this.isFollowing = false,
  });

  Category copyWith({bool? isFollowing, int? count}) {
    return Category(
      name: name,
      color: color,
      icon: icon,
      count: count ?? this.count,
      description: description,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

class TabItem {
  final String title;
  final int count;

  TabItem({required this.title, required this.count});
}