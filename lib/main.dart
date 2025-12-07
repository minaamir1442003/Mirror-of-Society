// lib/main.dart
import 'package:app_1/data/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// الاستيرادات
import 'core/constants/shared%20pref.dart';
import 'presentation/providers/bolt_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SharedPrefsService.isFirstLaunch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // **التعديل هنا**: التحقق من Onboarding بدلاً من First Launch فقط
        final bool showOnboarding = snapshot.data ?? true;
        final String initialRoute = showOnboarding ? '/' : '/home';

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => BoltProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ],
          child: Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              if (languageProvider.isLoading) {
                return MaterialApp(
                  home: Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              return FutureBuilder<TextDirection>(
                future: languageProvider.getCurrentTextDirection(),
                builder: (context, directionSnapshot) {
                  if (directionSnapshot.connectionState == ConnectionState.waiting) {
                    return MaterialApp(
                      home: Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final direction = directionSnapshot.data ?? TextDirection.rtl;

                  return FutureBuilder<String>(
                    future: languageProvider.getCurrentFontFamily(),
                    builder: (context, fontSnapshot) {
                      return ScreenUtilInit(
                        designSize: const Size(375, 812),
                        minTextAdapt: true,
                        splitScreenMode: true,
                        builder: (_, child) {
                          return MaterialApp(
                            navigatorKey: navigatorKey,
                            title: 'البرقيات',
                            theme: ThemeData(
                              primaryColor: const Color(0xFF1DA1F2),
                              fontFamily: fontSnapshot.data ?? 'Cairo',
                              appBarTheme: const AppBarTheme(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                foregroundColor: Colors.black,
                              ),
                            ),
                            locale: _getLocale(languageProvider.currentLanguage),
                            localizationsDelegates: const [
                              GlobalMaterialLocalizations.delegate,
                              GlobalWidgetsLocalizations.delegate,
                              GlobalCupertinoLocalizations.delegate,
                            ],
                            supportedLocales: const [
                              Locale('ar'), // العربية
                              Locale('en'), // الإنجليزية
                              Locale('fr'), // الفرنسية
                              Locale('es'), // الإسبانية
                            ],
                            debugShowCheckedModeBanner: false,
                            initialRoute: initialRoute,
                            onGenerateRoute: AppRouter.generateRoute,
                            builder: (context, widget) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  textScaleFactor: 1.0,
                                ),
                                child: Directionality(
                                  textDirection: direction,
                                  child: widget!,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Locale _getLocale(String languageName) {
    final languageCode = LanguageService.supportedLanguages[languageName]?['code'] ?? 'ar';
    return Locale(languageCode);
  }
}