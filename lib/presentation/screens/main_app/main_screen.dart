// lib/presentation/screens/main_app/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
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
      
  final PageController _pageController = PageController();
  
  // ✅ تحديث getter للشاشات ليتضمن ProfileScreen مع cache
  List<Widget> get _screens => [
    HomeScreen(
      initialCategory: _selectedCategory,
      onCategoryChange: _onHomeCategoryChange,
    ),
    CategoriesScreen(
      onCategorySelected: _onCategorySelected,
    ),
    Container(),
    NotificationsScreen(),
    // ✅ ProfileScreen بدون userId (يعني البروفايل الخاص بالمستخدم)
    ProfileScreen(userId: null),
  ];
  
  // ✅ متغير لتتبع إذا كان البروفايل بحاجة لتحديث
  bool _shouldRefreshProfile = false;

  @override
  void initState() {
    super.initState();
    _setupPageControllerListener();
  }

  // ✅ إضافة listener للـ PageController
  void _setupPageControllerListener() {
    _pageController.addListener(() {
      final int pageIndex = _pageController.page?.round() ?? 0;
      
      // ✅ عندما ننتقل إلى صفحة البروفايل (index 4)
      if (pageIndex == 4 && _shouldRefreshProfile) {
        _refreshProfileScreen();
        _shouldRefreshProfile = false;
      }
      
      // ✅ تحديث currentIndex
      if (_currentIndex != pageIndex) {
        setState(() {
          _currentIndex = pageIndex;
        });
      }
    });
  }

  void _onHomeCategoryChange(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onCategorySelected(String category) {
    _selectedCategory = category;
    
    setState(() {
      _currentIndex = 0;
    });
    
    _pageController.jumpToPage(0);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHomeScreen();
    });
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateBoltScreen()),
      ).then((value) {
        if (value != null && value is bool && value) {
          _refreshHomeScreen();
        }
      });
      return;
    }

    // ✅ إذا كنا ننتقل لصفحة البروفايل وكان هناك حاجة لتحديث
    if (index == 4 && _shouldRefreshProfile) {
      _refreshProfileScreen();
      _shouldRefreshProfile = false;
    }

    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _refreshHomeScreen() {
    setState(() {
      _screens[0] = HomeScreen(
        initialCategory: _selectedCategory,
        onCategoryChange: _onHomeCategoryChange,
      );
    });
  }

  // ✅ دالة لتحديث شاشة البروفايل
  void _refreshProfileScreen() {
    final profileCubit = context.read<ProfileCubit>();
    
    // ✅ فقط إذا كان هناك cache قديم
    if (profileCubit.isProfileLoaded) {
      // ✅ نستخدم clearCache بدلاً من clearProfile للحفاظ على البيانات
      profileCubit.clearCache();
      
      // ✅ إعادة تحميل البروفايل
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileCubit.getMyProfile();
      });
    }
  }

  // ✅ دالة لتحديث البروفايل من خارج الـ Screen
  void refreshProfileData() {
    _shouldRefreshProfile = true;
    
    // ✅ إذا كنا في صفحة البروفايل حالياً، نقوم بالتحديث فوراً
    if (_currentIndex == 4) {
      _refreshProfileScreen();
      _shouldRefreshProfile = false;
    }
  }

  // ✅ دالة لتحديث شاشة الإشعارات
  void _refreshNotificationsScreen() {
    setState(() {
      _screens[3] = NotificationsScreen();
    });
  }

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
    return MultiBlocListener(
      listeners: [
        // ✅ الاستماع لتحديثات ProfileCubit
        BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdated) {
              // ✅ عند تحديث البروفايل، نضع علامة أنه يحتاج تحديث
              _shouldRefreshProfile = true;
              
              // ✅ إظهار رسالة نجاح
              showAppSnackBar('تم تحديث الملف الشخصي بنجاح');
            }
          },
        ),
      ],
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          body: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: _screens,
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTabSelected: _onTabSelected,
            notificationCount: _notificationCount,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}