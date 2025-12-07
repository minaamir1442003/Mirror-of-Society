
import 'package:app_1/core/theme/app_colors.dart';
import 'package:app_1/core/theme/app_theme.dart';
import 'package:app_1/data/models/bolt_model.dart';
import 'package:app_1/presentation/providers/bolt_provider.dart';
import 'package:app_1/presentation/screens/main_app/chat/chats_screen.dart';
import 'package:app_1/presentation/widgets/bolts/bolt_card.dart';
import 'package:app_1/presentation/widgets/common/empty_state.dart';
import 'package:app_1/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String? initialCategory;
  const HomeScreen({Key? key, this.initialCategory}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Offset _curlPosition = const Offset(0.0, 1.0);
  double _curlSize = 0.3;
  int _selectedCategoryIndex = 0;
  List<String> categories = [
    'الكل',
    'تكنولوجيا',
    'رياضة',
    'فن',
    'سياسة',
    'اقتصاد',
  ];
  
  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectCategoryByName(widget.initialCategory!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final boltProvider = Provider.of<BoltProvider>(context, listen: false);
      boltProvider.loadBolts();
    });
  }

  void _selectCategoryByName(String categoryName) {
    int index = categories.indexOf(categoryName);
    if (index != -1) {
      setState(() {
        _selectedCategoryIndex = index;
      });
    }
  }

  void selectCategory(String categoryName) {
    _selectCategoryByName(categoryName);
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
        Stack(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.search, size: 30),
                  onPressed: _showSearchDialog,
                ),
                SizedBox(width: 10), // مسافة بين الأيقونات
                // أيقونة Chat مع إشعارات
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.message,
                        size: 30,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatsScreen(),
                          ),
                        );
                      },
                    ),
                    // النقطة الحمراء
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 12,
                        height: 12,
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
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Container(
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

  Widget _buildTodayFeature() {
    return GestureDetector(
      onTap: _showTodayInHistoryDetails,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.today, color: Colors.white, size: 16),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'في مثل هذا اليوم',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '١٩٦٩: أول هبوط للإنسان على القمر',
                    style: TextStyle(color: AppColors.darkGray, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.info_outline, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  List<BoltModel> _getFilteredBolts(List<BoltModel> allBolts) {
    if (_selectedCategoryIndex == 0) {
      return allBolts; // "الكل" - يرجع كل البرقيات
    }

    String selectedCategory = categories[_selectedCategoryIndex];

    // خريطة لربط أسماء الفئات العربية مع الإنجليزية (لو كانت في المودل بالإنجليزية)
    Map<String, String> categoryMapping = {
      'تكنولوجيا': 'تكنولوجيا',
      'رياضة': 'رياضة',
      'فن': 'فن',
      'سياسة': 'سياسة',
      'اقتصاد': 'اقتصاد',
    };

    String mappedCategory =
        categoryMapping[selectedCategory] ?? selectedCategory;

    return allBolts.where((bolt) => bolt.category == mappedCategory).toList();
  }

  void _showTodayInHistoryDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'في مثل هذا اليوم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHistoryEvent(
                  year: '١٩٦٩',
                  title: 'أول هبوط للإنسان على القمر',
                  description:
                      'هبطت مركبة أبولو 11 على سطح القمر وكان نيل أرمسترونغ أول إنسان يخطو على سطحه.',
                ),
                Divider(height: 24),
                _buildHistoryEvent(
                  year: '١٩٨٩',
                  title: 'سقوط جدار برلين',
                  description:
                      'بدأ هدم جدار برلين الذي قسم المدينة إلى جزئين شرقي وغربي لمدة 28 عاماً.',
                ),
                Divider(height: 24),
                _buildHistoryEvent(
                  year: '٢٠٠٧',
                  title: 'إطلاق أول آيفون',
                  description:
                      'أطلقت شركة آبل أول هاتف آيفون الذي غير شكل صناعة الهواتف الذكية.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryEvent({
    required String year,
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            year,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<BoltProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return LoadingIndicator();
        }

        if (provider.bolts.isEmpty) {
          return EmptyState(
            icon: Icons.bolt,
            message: 'لا توجد برقيات بعد',
            actionText: 'كن أول من ينشر',
            onAction: () {
              // يتم التعامل مع التنقل في MainScreen
            },
          );
        }

        final filteredBolts = _getFilteredBolts(provider.bolts);

        if (filteredBolts.isEmpty) {
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

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadBolts();
          },
          child: ListView(
            children: [
            
              _buildCategories(),
              _buildTodayFeature(),
              SizedBox(height: 8),
              ...filteredBolts.map((bolt) => BoltCard(bolt: bolt)).toList(),
              _buildAdCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdCard() {
    return GestureDetector(
      onTap: () {
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
                        SnackBar(
                          content: Text('سيتم توجيهك لصفحة الاشتراك'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(
                            bottom: 100,
                            left: 16,
                            right: 16,
                          ),
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
              child: Icon(
                Icons.star,
                color: Colors.white.withOpacity(0.2),
                size: 40,
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Icon(
                Icons.bolt,
                color: Colors.white.withOpacity(0.2),
                size: 40,
              ),
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
                        Icon(
                          Icons.local_offer,
                          color: Color(0xFF7C3AED),
                          size: 24,
                        ),
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
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: Colors.yellow,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'مدى الحياة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(
                              Icons.visibility_off,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'بدون إعلانات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
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
      
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          
          _buildBody(),
        
      
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              width: 160,
              height: 160,
              child: IgnorePointer(
                child: CustomPaint(painter: PageCurlPainter()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PageCurlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final curlWidth = size.width;
    final curlHeight = size.height;

    // ألوان ثابتة لتجنب مشاكل nullable
    final Color lightGray = Color(0xFFF5F5F5);
    final Color mediumGray = Color(0xFFE0E0E0);
    final Color shadowColor = Color(0x40000000); // أسود مع شفافية

    // --- خلفية الورقة ---
    final paperPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          lightGray,
        ],
      ).createShader(Rect.fromLTWH(0, 0, curlWidth, curlHeight));

    // --- ظل الانطواء ---
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.centerRight,
        colors: [
          shadowColor,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, curlWidth, curlHeight));

    // مسار الورقة المتنية
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(curlWidth, 0)
      ..arcToPoint(
        Offset(0, curlHeight),
        radius: Radius.circular(curlWidth * 1.2),
        clockwise: false,
      )
      ..close();

    // --- مسار الظل ---
    final shadowPath = Path()
      ..moveTo(curlWidth, 0)
      ..lineTo(curlWidth * 0.65, curlHeight * 0.25)
      ..lineTo(curlWidth * 0.1, curlHeight * 0.55)
      ..lineTo(0, curlHeight)
      ..lineTo(curlWidth, 0)
      ..close();

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paperPaint);

    // خط رفيع في الحافة
    final edgePaint = Paint()
      ..color = mediumGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawLine(
      Offset(curlWidth, 0),
      Offset(0, curlHeight),
      edgePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}