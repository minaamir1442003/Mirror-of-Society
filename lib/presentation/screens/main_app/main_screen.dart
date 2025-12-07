import 'package:flutter/material.dart';
import 'package:app_1/presentation/widgets/layout/bottom_nav_bar.dart';
import 'home/home_screen.dart';
import 'explore/categories_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';
import 'create_bolt/create_bolt_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _notificationCount = 5;
  String? _selectedCategory;
  
  // مفتاح لـ ScaffoldMessenger
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();
      
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();


       List<Widget> get _screens => [
    HomeScreen(
      key: _homeScreenKey,
      initialCategory: _selectedCategory,
    ), // 0 - الرئيسية
    CategoriesScreen(
      onCategorySelected: _onCategorySelected, // أضف callback
    ), // 1 - التصنيفات
    Container(), // 2 - مكان فارغ
    NotificationsScreen(), // 3 - الإشعارات
    ProfileScreen(), // 4 - البروفايل
  ];
  void _onCategorySelected(String category) {
    // 1. تغيير الـ selected category
    setState(() {
      _selectedCategory = category;
    });
     setState(() {
      _currentIndex = 0;
    });
      WidgetsBinding.instance.addPostFrameCallback((_) {
     _homeScreenKey.currentState?.selectCategory(category);
    });
  }



  void _onTabSelected(int index) {
    if (index == 2) {
      // الانتقال لشاشة الإنشاء
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateBoltScreen()),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
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
          bottom: 100, // مسافة من الأسفل للزر العائم
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
        body: IndexedStack(
          index: _currentIndex,
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