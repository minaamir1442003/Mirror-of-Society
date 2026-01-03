// lib/presentation/screens/main_app/main_screen.dart
import 'package:app_1/presentation/screens/auth/login/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/presentation/screens/main_app/home/Cubit/home_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/auth_cubit.dart';
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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _notificationCount = 5;
  String? _selectedCategoryId;
  
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();
      
  final PageController _pageController = PageController();
  
  // ✅ الشاشات الرئيسية (بدون Create Bolt)
  final List<Widget> _mainScreens = [];
  
  bool _shouldRefreshProfile = false;
  bool _isCreateBoltActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // ✅ تهيئة الشاشات الرئيسية
    _initializeMainScreens();
  }

  void _initializeMainScreens() {
    _mainScreens.clear();
    _mainScreens.addAll([
      KeepAliveWidget(
        key: ValueKey('home_screen'),
        child: HomeScreen(
          initialCategoryId: _selectedCategoryId,
        ),
      ),
      KeepAliveWidget(
        key: ValueKey('categories_screen'),
        child: CategoriesScreen(
          onCategorySelected: _onCategorySelected,
        ),
      ),
      KeepAliveWidget(
        key: ValueKey('notifications_screen'),
        child: NotificationsScreen(),
      ),
      KeepAliveWidget(
        key: ValueKey('profile_screen'),
        child: ProfileScreen(userId: null),
      ),
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForUpdates();
    }
  }
  
  void _checkForUpdates() {
    if (_currentIndex == 0 && !_isCreateBoltActive) {
      try {
        final homeCubit = context.read<HomeCubit>();
        _refreshHomeDataInBackground(homeCubit);
      } catch (e) {
        print('⚠️ Error checking for updates: $e');
      }
    }
  }
  
  void _refreshHomeDataInBackground(HomeCubit homeCubit) {
    print('🔄 Checking for home data updates...');
    try {
      // homeCubit.refreshDataInBackground();
    } catch (e) {
      print('⚠️ Error refreshing data in background: $e');
    }
  }

  void _onCategorySelected(String categoryId) {
    print('🔄 MainScreen: Category selected: $categoryId');
    
    setState(() {
      _selectedCategoryId = categoryId;
      _currentIndex = 0;
      _isCreateBoltActive = false;
    });
    
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHomeScreenWithCategory(categoryId);
    });
  }

  void _refreshHomeScreenWithCategory(String categoryId) {
    try {
      final homeCubit = context.read<HomeCubit>();
      homeCubit.switchCategory(categoryId);
      print('✅ MainScreen: Switched to category: $categoryId');
    } catch (e) {
      print('❌ MainScreen: Error switching category: $e');
    }
  }

  void _onTabSelected(int index) {
    print('📍 MainScreen: Tab selected - index: $index, isCreateBoltActive: $_isCreateBoltActive');
    
    // ✅ إذا كان المستخدم يضغط على Create Bolt (index 2)
    if (index == 2) {
      if (!_isCreateBoltActive) {
        // ✅ الذهاب لشاشة إنشاء البرقية
        _navigateToCreateBolt();
      } else {
        // ✅ إذا كان بالفعل في Create Bolt، نرجع للصفحة الرئيسية
        _returnFromCreateBolt(0);
      }
      return;
    }

    // ✅ إذا كان في Create Bolt ونريد الرجوع لشاشة أخرى
    if (_isCreateBoltActive) {
      _returnFromCreateBolt(index);
      return;
    }

    // ✅ التنقل العادي بين الشاشات الرئيسية
    _handleNormalNavigation(index);
  }

  void _navigateToCreateBolt() async {
  print('🚀 MainScreen: Navigating to Create Bolt');
  
  final result = await Navigator.push<Map<String, dynamic>>(
    context,
    MaterialPageRoute(
      builder: (context) => CreateBoltScreen(),
      fullscreenDialog: true,
    ),
  );
  
  // ✅ التعامل مع النتيجة بعد العودة
  _handleCreateBoltResult(result);
}

  void _returnFromCreateBolt(int newIndex) {
    print('🔙 MainScreen: Returning from Create Bolt to index: $newIndex');
    
    setState(() {
      _isCreateBoltActive = false;
      _currentIndex = newIndex;
    });
    
    // الانتقال للشاشة المطلوبة في PageView
    if (_pageController.hasClients) {
      _pageController.jumpToPage(_getPageIndexForNavigation(newIndex));
    }
  }

  void _handleNormalNavigation(int index) {
    print('🔄 MainScreen: Normal navigation to index: $index');
    
    setState(() {
      _currentIndex = index;
      _isCreateBoltActive = false;
    });
    
    if (_pageController.hasClients) {
      _pageController.jumpToPage(_getPageIndexForNavigation(index));
    }
    
    if (index == 3 && _shouldRefreshProfile) { // Profile هو index 3 في الـ navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshProfileScreen();
      });
      _shouldRefreshProfile = false;
    }
  }

  // ✅ حساب الـ PageView index بناءً على الـ navigation index
  int _getPageIndexForNavigation(int navIndex) {
    // Create Bolt ليس جزءًا من PageView (index 2 في الـ navigation)
    // الخريطة: 
    // Navigation indices: Home=0, Categories=1, CreateBolt=2, Notifications=3, Profile=4
    // PageView indices: Home=0, Categories=1, Notifications=2, Profile=3
    
    // ✅ إذا كان Create Bolt (index 2)، نرجع آخر صفحة كانت مفتوحة (0 للهوم)
    if (navIndex == 2) return 0;
    
    // ✅ إذا كان الـ index أكبر من Create Bolt (2) نطرح 1
    return navIndex > 2 ? navIndex - 1 : navIndex;
  }

  // ✅ حساب الـ navigation index بناءً على الـ PageView index
  int _getNavigationIndexForPage(int pageIndex) {
    // الخريطة:
    // PageView indices: Home=0, Categories=1, Notifications=2, Profile=3
    // Navigation indices: Home=0, Categories=1, CreateBolt=2, Notifications=3, Profile=4
    
    // ✅ Notifications: PageView index 2 => Navigation index 3
    // ✅ Profile: PageView index 3 => Navigation index 4
    return pageIndex >= 2 ? pageIndex + 1 : pageIndex;
  }

  void _refreshHomeScreen() {
    if (_currentIndex == 0 && !_isCreateBoltActive) {
      final homeCubit = context.read<HomeCubit>();
      homeCubit.refresh();
    }
  }

  void _refreshProfileScreen() {
    final profileCubit = context.read<ProfileCubit>();
    
    if (profileCubit.isProfileLoaded) {
      profileCubit.clearCache();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileCubit.getMyProfile();
      });
    }
  }
  void _handleCreateBoltResult(Map<String, dynamic>? result) {
  if (result != null && result['success'] == true) {
    print('✅ CreateBoltScreen: Telegram created successfully');
    
    // ✅ إذا طلبنا الانتقال للبروفايل
    if (result['navigate_to_profile'] == true) {
      _navigateToProfileAfterCreatingBolt();
    }
  }
}
void _navigateToProfileAfterCreatingBolt() {
  print('📍 Navigating to profile after creating telegram...');
  
  // ✅ 1. تحديث بيانات البروفايل أولاً
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      final profileCubit = context.read<ProfileCubit>();
      profileCubit.getMyProfile(forceRefresh: true, showOverlay: false);
    } catch (e) {
      print('❌ Error refreshing profile: $e');
    }
  });
  
  // ✅ 2. الانتقال لصفحة البروفايل في الـ PageView
  setState(() {
    _isCreateBoltActive = false;
    _currentIndex = 4; // صفحة البروفايل في navigation
  });
  
  // ✅ 3. الانتقال في PageController
  if (_pageController.hasClients) {
    _pageController.animateToPage(
      3, // صفحة البروفايل في PageView (index 3)
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

  void refreshProfileData() {
    _shouldRefreshProfile = true;
    
    if (_currentIndex == 4 && !_isCreateBoltActive) { // Profile index = 4
      _refreshProfileScreen();
      _shouldRefreshProfile = false;
    }
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
        BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdated) {
              _shouldRefreshProfile = true;
            }
          },
        ),
        
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              print('🔄 MainScreen: Logout detected, refreshing home data...');
              
              try {
                final homeCubit = context.read<HomeCubit>();
                
                try {
                  homeCubit.forceClear();
                  print('✅ HomeCubit forceClear executed');
                } catch (e) {
                  print('⚠️ forceClear not available, using clearCacheAndData: $e');
                  homeCubit.clearCacheAndData();
                }
                
                setState(() {
                  _selectedCategoryId = null;
                  _currentIndex = 0;
                  _isCreateBoltActive = false;
                });
                
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(0);
                }
                
                Future.delayed(Duration(milliseconds: 300), () {
                  if (mounted) {
                    try {
                      homeCubit.initialize(force: true);
                      print('✅ HomeCubit reinitialized after logout');
                    } catch (e) {
                      print('❌ Error reinitializing HomeCubit: $e');
                    }
                  }
                });
                
                try {
                  final profileCubit = context.read<ProfileCubit>();
                  profileCubit.clearAllData();
                  print('✅ ProfileCubit cleared after logout');
                } catch (e) {
                  print('⚠️ Error clearing ProfileCubit: $e');
                }
                
              } catch (e) {
                print('❌ MainScreen: Error handling logout: $e');
              }
            }
          },
        ),
        
        BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              print('🔄 MainScreen: New login detected, refreshing data...');
              
              Future.delayed(Duration(milliseconds: 500), () {
                try {
                  final homeCubit = context.read<HomeCubit>();
                  homeCubit.forceRefreshOnLogin();
                  
                  final profileCubit = context.read<ProfileCubit>();
                  profileCubit.clearAllData();
                  
                  setState(() {
                    _selectedCategoryId = null;
                    _isCreateBoltActive = false;
                  });
                  
                  print('✅ MainScreen: Data refreshed after login');
                } catch (e) {
                  print('❌ MainScreen: Error refreshing after login: $e');
                }
              });
            }
          },
        ),
      ],
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          // ❌ إزالة الظل من الشاشة السفلية
          extendBody: true,
          body: _isCreateBoltActive
              ? CreateBoltScreen()
              : PageView(
                  controller: _pageController,
                  physics: const PageScrollPhysics(),
                  onPageChanged: (pageIndex) {
                    // تحويل من page index إلى navigation index
                    int newNavIndex = _getNavigationIndexForPage(pageIndex);
                    
                    if (_currentIndex != newNavIndex) {
                      print('📄 MainScreen: Page changed - pageIndex: $pageIndex, newNavIndex: $newNavIndex');
                      
                      setState(() {
                        _currentIndex = newNavIndex;
                        _isCreateBoltActive = false;
                      });
                    }
                    
                    if (newNavIndex == 3 && _shouldRefreshProfile) { // Notifications index = 3 في الـ navigation
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _refreshProfileScreen();
                      });
                      _shouldRefreshProfile = false;
                    }
                    
                    if (newNavIndex == 0 && _selectedCategoryId != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        try {
                          final homeCubit = context.read<HomeCubit>();
                          if (homeCubit.currentCategoryId != _selectedCategoryId) {
                            homeCubit.switchCategory(_selectedCategoryId);
                          }
                        } catch (e) {
                          print('❌ Error applying category on page change: $e');
                        }
                      });
                    }
                  },
                  children: _mainScreens,
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
}

class KeepAliveWidget extends StatefulWidget {
  final Widget child;
  
  const KeepAliveWidget({Key? key, required this.child}) : super(key: key);
  
  @override
  State<KeepAliveWidget> createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}