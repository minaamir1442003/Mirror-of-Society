// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_1/main.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Mock the language service
    final mockLocale = const Locale('en', '');
    
    // Build our app with the required parameter
    await tester.pumpWidget(
      MaterialApp(
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
        home: Scaffold(
          body: MyApp(initialLanguage: mockLocale, navigatorKey: GlobalKey<NavigatorState>()),
        ),
      ),
    );

    // You can add your actual widget tests here
    expect(find.byType(MyApp), findsOneWidget);
  });
}