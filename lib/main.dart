import 'package:app_1/data/services/language_service.dart';
import 'package:app_1/presentation/screens/auth/forgetpassword/cubit/forgot_password_cubit.dart';
import 'package:app_1/presentation/screens/auth/login/cubit/login_cubit.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/registration_provider.dart';
import 'package:app_1/presentation/screens/auth/regesteration/screens/RegisterStep1Screen.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/cubits/telegram_cubit.dart';
import 'package:app_1/presentation/screens/main_app/explore/cubits/category_cubit.dart';
import 'package:app_1/presentation/screens/main_app/home/Cubit/home_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/auth_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/comment_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/like_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/repost_cubit.dart';
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
import 'package:app_1/presentation/screens/auth/forgetpassword/screen/forgot_password_screen.dart';
import 'package:app_1/presentation/screens/auth/login/screen/login_screen.dart';
import 'package:app_1/presentation/screens/main_app/main_screen.dart';
import 'package:app_1/presentation/screens/auth/regesteration/cubit/register_cubit.dart';
import 'package:app_1/presentation/screens/main_app/onboarding/onboarding_screen.dart';
import 'package:app_1/core/constants/app_constants.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/shared pref.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ إخفاء الـ logs في الإصدار النهائي
  bool isDebug = true; // غيّرها لـ false في الإصدار النهائي
  
  if (!isDebug) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  } else {
    print('🚀 App starting...');
  }

  // ✅ اختبار SharedPreferences
  try {
    final testPrefs = await SharedPreferences.getInstance();
    if (isDebug) {
      print('✅ SharedPreferences test: successful');
    }
  } catch (e) {
    if (isDebug) print('❌ SharedPreferences test failed: $e');
  }

  // ✅ إنشاء navigatorKey أولاً
  final navigatorKey = GlobalKey<NavigatorState>();

  // ✅ تمرير navigatorKey إلى init
  await di.init(navigatorKey);

  // احصل على اللغة المحفوظة
  final savedLanguage = await LanguageService.getSavedLanguage();
  final savedLanguageCode = LanguageService.getLanguageCode(savedLanguage);

  if (isDebug) {
    print('🌐 Saved language: $savedLanguage, code: $savedLanguageCode');
  }

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
        // ✅ إضافة StorageService كـ Provider
        // سيتم إضافته في ملف منفصل إذا كنت تستخدم GetIt
        
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
        BlocProvider(create: (context) => di.sl<CommentCubit>()),
        BlocProvider(create: (context) => di.sl<RepostCubit>()),
        BlocProvider(create: (context) => di.sl<CategoryCubit>()),
        BlocProvider(create: (context) => di.sl<LikeCubit>()),
        
        Provider<VerificationRepository>(
          create: (context) => di.sl<VerificationRepository>(),
        ),
        
        // Language Provider
        ChangeNotifierProvider<LanguageProvider>(
          create: (context) => LanguageProvider(initialLocale: initialLanguage),
        ),
        
        // RegistrationProvider
        ChangeNotifierProvider<RegistrationProvider>(
          create: (context) => RegistrationProvider(),
        ),
      ],
      child: Consumer2<LanguageProvider, RegistrationProvider>(
        builder: (context, languageProvider, registrationProvider, child) {
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
                
                navigatorKey: navigatorKey,

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

                // ✅ مباشرة إلى AuthChecker
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

// ✅ AuthChecker بدون شاشة تحميل
class AuthChecker extends StatefulWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _determineInitialScreen();
  }

  Future<void> _determineInitialScreen() async {
    try {
      final storageService = di.sl<StorageService>();
      await storageService.ensureInitialized();

      // تحميل البيانات بسرعة
      final results = await Future.wait([
        storageService.isOnboardingCompleted(),
        storageService.getToken(),
      ]);

      final isOnboardingCompleted = results[0] as bool;
      final token = results[1] as String?;
      final isLoggedIn = token != null && token.isNotEmpty;

      if (!isOnboardingCompleted) {
        _initialScreen = OnboardingScreen(
          onCompleted: () async {
            await storageService.setOnboardingCompleted();
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
        );
      } else if (isLoggedIn) {
        _initialScreen = MainScreen();
      } else {
        _initialScreen = const LoginScreen();
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // في حالة الخطأ، انتقل مباشرة إلى تسجيل الدخول
      _initialScreen = const LoginScreen();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // إذا لم يتم تحديد الشاشة بعد، اعرض شاشة بيضاء مؤقتاً
    if (_initialScreen == null) {
      return const Scaffold(
        body: SizedBox.shrink(), // شاشة بيضاء فارغة مؤقتاً
      );
    }

    // الانتقال المباشر للشاشة المناسبة
    return _initialScreen!;
  }
}