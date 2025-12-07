import 'package:flutter/material.dart';
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
      leadingWidth: 150,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Row(
        children: [
          Icon(Icons.category, color: AppColors.primary, size: 30),
          SizedBox(width: 8),
          Text(
            'التصنيفات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
      actions: [
        Icon(
          Icons.bookmark,
          color: AppColors.warning,
          size: 50,
        ),
        IconButton(
          icon: Icon(Icons.search, size: 30),
          onPressed: () {
            // دالة البحث
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showCategoryDetails(context, category);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: category.color, size: 24),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${category.count}',
                      style: TextStyle(
                        color: category.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                category.description,
                style: TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.onCategorySelected != null) {
                        widget.onCategorySelected!(category.name);
                      }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  category.color
                            ,
                        foregroundColor:
                             Colors.white
                          ,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                         'تصفح' ,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(category.icon, color: category.color, size: 32),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          '${category.count} برقية',
                          style: TextStyle(
                            color: category.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                ],
              ),
              SizedBox(height: 20),
              Text(
                category.description,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkGray,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: category.color,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'عرض برقيات ${category.name}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إغلاق'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
        
        
          SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(categories[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
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

  Category copyWith({
    bool? isFollowing,
    int? count,
  }) {
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