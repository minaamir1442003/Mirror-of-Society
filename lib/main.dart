import 'package:app_1/data/services/language_service.dart';
import 'package:app_1/presentation/screens/auth/forgetpassword/cubit/forgot_password_cubit.dart';
import 'package:app_1/presentation/screens/auth/login/cubit/login_cubit.dart';
import 'package:app_1/presentation/screens/auth/regesteration/screens/RegisterStep1Screen.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/cubits/telegram_cubit.dart';
import 'package:app_1/presentation/screens/main_app/home/Cubit/home_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/auth_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/update_profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/cubits/verification_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/repositories/verification_repository.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/cubits/user_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:app_1/core/constants/injection_container.dart' as di;
import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:app_1/presentation/screens/auth/forgetpassword/screen/forgot_password_screen.dart';
import 'package:app_1/presentation/screens/auth/login/screen/login_screen.dart';
import 'package:app_1/presentation/screens/main_app/main_screen.dart';
import 'package:app_1/presentation/screens/auth/regesteration/cubit/register_cubit.dart';
import 'package:app_1/presentation/screens/main_app/onboarding/onboarding_screen.dart';
import 'package:app_1/core/constants/app_constants.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 App starting...');

  // ✅ اختبار SharedPreferences مباشرة
  try {
    final testPrefs = await SharedPreferences.getInstance();
    print('✅ SharedPreferences test: successful');
    print('🔍 Test prefs keys: ${testPrefs.getKeys()}');
  } catch (e) {
    print('❌ SharedPreferences test failed: $e');
  }

  // ✅ إنشاء navigatorKey أولاً
  final navigatorKey = GlobalKey<NavigatorState>();

  // ✅ تمرير navigatorKey إلى init
  await di.init(navigatorKey);

  // احصل على اللغة المحفوظة قبل تشغيل التطبيق
  final savedLanguage = await LanguageService.getSavedLanguage();
  final savedLanguageCode = LanguageService.getLanguageCode(savedLanguage);

  print('🌐 Saved language: $savedLanguage, code: $savedLanguageCode');

  runApp(
    MyApp(
      initialLanguage: Locale(savedLanguageCode),
      navigatorKey: navigatorKey,
    ),
  );
}

class MyApp extends StatelessWidget {
  final Locale initialLanguage;
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    Key? key,
    required this.initialLanguage,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Bloc Providers
        BlocProvider(create: (context) => di.sl<AuthCubit>()),
        BlocProvider(create: (context) => di.sl<RegisterCubit>()),
        BlocProvider(create: (context) => di.sl<ProfileCubit>()),
        BlocProvider(create: (context) => di.sl<LoginCubit>()),
        BlocProvider(create: (context) => di.sl<ForgotPasswordCubit>()),
        BlocProvider(create: (context) => di.sl<UpdateProfileCubit>()),
        BlocProvider(create: (context) => di.sl<HomeCubit>()),
        BlocProvider(create: (context) => di.sl<TelegramCubit>()),
        BlocProvider(create: (context) => di.sl<VerificationCubit>()),
          BlocProvider(create: (context) => di.sl<UserProfileCubit>()),
        Provider<VerificationRepository>(
          create: (context) => di.sl<VerificationRepository>(),
        ),
        // أضف LanguageProvider هنا
        ChangeNotifierProvider<LanguageProvider>(
          create: (context) => LanguageProvider(initialLocale: initialLanguage),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: false,
            builder: (context, child) {
              return MaterialApp(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                theme: _buildTheme(),
                darkTheme: _buildDarkTheme(),
                themeMode: ThemeMode.light,

                // ✅ إضافة navigatorKey هنا
                navigatorKey: navigatorKey,

                // هنا نحدد اللغة بشكل ديناميكي
                locale: languageProvider.currentLocale,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('ar', ''),
                  Locale('en', ''),
                  Locale('fr', ''),
                  Locale('es', ''),
                ],

                home: const AuthChecker(),

                routes: {
                  '/login': (context) => const LoginScreen(),
                  '/register': (context) => const RegisterStep1Screen(),
                  '/forgot-password': (context) => const ForgotPasswordScreen(),
                  '/main': (context) => MainScreen(),
                  '/onboarding': (context) => const OnboardingScreen(),
                  '/home': (context) => MainScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primaryColor: const Color(0xFF1DA1F2),
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      fontFamily: 'Cairo',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1DA1F2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: const Color(0xFF1DA1F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DA1F2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF1DA1F2),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),
      useMaterial3: false,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primaryColor: const Color(0xFF1DA1F2),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1DA1F2),
        secondary: Color(0xFFBB86FC),
      ),
    );
  }
}

// AuthChecker Widget
class AuthChecker extends StatefulWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoading = true;
  bool _shouldShowOnboarding = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    print('🚀 AuthChecker: initState');
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final storageService = di.sl<StorageService>();

      print('🔍 AuthChecker: Starting status check...');

      // ✅ 1. تأكد من تهيئة StorageService
      await storageService.ensureInitialized();

      // ✅ 2. طباعة معلومات التخزين للتحقق
      await storageService.debugStorage();

      // ✅ 3. التحقق من حالة الأونبوردينج
      final isOnboardingCompleted =
          await storageService.isOnboardingCompleted();
      print('📊 AuthChecker: isOnboardingCompleted = $isOnboardingCompleted');

      // ✅ 4. التحقق من التوكن
      final token = await storageService.getToken();
      final isLoggedIn = (token != null && token.isNotEmpty);
      print('📊 AuthChecker: isLoggedIn = $isLoggedIn');
      print(
        '📊 AuthChecker: token = ${token != null ? "Exists (${token.length} chars)" : "null"}',
      );

      // ✅ 5. محاكاة تأخير تحميل البيانات (اختياري)
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _shouldShowOnboarding = !isOnboardingCompleted;
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });

        print('📊 AuthChecker: Final Decision');
        print('   - Show Onboarding: $_shouldShowOnboarding');
        print('   - User Logged In: $_isLoggedIn');
      }
    } catch (e) {
      print('❌ AuthChecker: Error checking status: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _shouldShowOnboarding = true; // في حالة الخطأ، اعرض الأونبوردينج
          _isLoggedIn = false;
        });

        print('⚠️ AuthChecker: Defaulting to Onboarding due to error');
      }
    }
  }

  // ✅ دالة لحفظ حالة إكمال الأونبوردينج مباشرة
  Future<void> _markOnboardingCompleted() async {
    try {
      final storageService = di.sl<StorageService>();
      await storageService.setOnboardingCompleted();
      print('✅ AuthChecker: Onboarding completion saved successfully');
    } catch (e) {
      print('❌ AuthChecker: Error saving onboarding completion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🚀 AuthChecker: Building widget');
    print('   - isLoading: $_isLoading');
    print('   - shouldShowOnboarding: $_shouldShowOnboarding');
    print('   - isLoggedIn: $_isLoggedIn');

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'جاري التحميل...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    print('🚀 AuthChecker: Navigation Decision');
    print('   - Show Onboarding: $_shouldShowOnboarding');
    print('   - User Logged In: $_isLoggedIn');

    if (_shouldShowOnboarding) {
      print('🚀 Showing OnboardingScreen');
      return OnboardingScreen(
        onCompleted: _markOnboardingCompleted, // ✅ تمرير callback
      );
    }

    if (_isLoggedIn) {
      print('🚀 Showing MainScreen (User is logged in)');
      return MainScreen();
    }

    print('🚀 Showing LoginScreen (User is not logged in)');
    return const LoginScreen();
  }
}
