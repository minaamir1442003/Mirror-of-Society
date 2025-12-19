import 'package:flutter/material.dart';
import 'package:app_1/presentation/widgets/layout/bottom_nav_bar.dart';
import 'home/screen/home_screen.dart';
import 'explore/categories_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/screen/profile_screen.dart';
import 'create_bolt/create_bolt_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _notificationCount = 5;
  String? _selectedCategory;
  
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();
      
  // استخدام PageController بدلاً من GlobalKey
  final PageController _pageController = PageController();
  
  List<Widget> get _screens => [
    HomeScreen(
      initialCategory: _selectedCategory,
      onCategoryChange: _onHomeCategoryChange,
    ), // 0 - الرئيسية
    CategoriesScreen(
      onCategorySelected: _onCategorySelected,
    ), // 1 - التصنيفات
    Container(), // 2 - مكان فارغ
    NotificationsScreen(), // 3 - الإشعارات
    ProfileScreen(), // 4 - البروفايل
  ];
  
  // دالة للتعامل مع تغيير الفئة من HomeScreen نفسها
  void _onHomeCategoryChange(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onCategorySelected(String category) {
    // 1. حفظ الفئة المحددة
    _selectedCategory = category;
    
    // 2. تغيير المؤشر إلى الصفحة الرئيسية
    setState(() {
      _currentIndex = 0;
    });
    
    // 3. الانتقال إلى الصفحة الرئيسية مباشرة
    _pageController.jumpToPage(0);
    
    // 4. إرسال حدث تغيير الفئة
    _notifyCategoryChange(category);
  }

  void _notifyCategoryChange(String category) {
    // استخدام طريقة مختلفة لنقل البيانات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // البحث عن HomeScreen في الشجرة وإرسال البيانات
      _sendCategoryToHomeScreen(category);
    });
  }

  void _sendCategoryToHomeScreen(String category) {
    // الطريقة 1: استخدام InheritedWidget أو Provider (مستحسن)
    // الطريقة 2: إعادة بناء HomeScreen مع الفئة الجديدة
    setState(() {
      // إعادة بناء HomeScreen مع الفئة الجديدة
      _screens[0] = HomeScreen(
        initialCategory: category,
        onCategoryChange: _onHomeCategoryChange,
      );
    });
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      // الانتقال لشاشة الإنشاء
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateBoltScreen()),
      ).then((value) {
        // عند العودة من شاشة الإنشاء
        if (value != null && value is bool && value) {
          // يمكنك تحديث الشاشة إذا لزم الأمر
          _refreshHomeScreen();
        }
      });
      return;
    }

    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _refreshHomeScreen() {
    setState(() {
      // إعادة بناء HomeScreen
      _screens[0] = HomeScreen(
        initialCategory: _selectedCategory,
        onCategoryChange: _onHomeCategoryChange,
      );
    });
  }

  // دالة جديدة لاظهار SnackBar
  void showAppSnackBar(String message, {bool isError = false}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 100,
          left: 16,
          right: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(), // لمنع التمرير الأفقي
          children: _screens,
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
          notificationCount: _notificationCount,
        ),
      ),
    );
  }
}