// lib/core/constants/dio_client.dart
import 'package:app_1/core/constants/api_const.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart'; ❌ إزالة هذا الاستيراد

class DioClient {
  late Dio _dio;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final GlobalKey<NavigatorState>? navigatorKey; // ✅ إضافة navigatorKey
  
  DioClient({this.navigatorKey}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://mirsoc.com/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    
    // Add Interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // جلب رؤوس HTTP مع اللغة الحالية
          final headers = await ApiConstants.headers;
          options.headers.addAll(headers);
          
          // Add Authorization header if token exists
          final token = await _storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          print('Error setting headers: $e');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'auth_token');
          await _storage.delete(key: 'user_data');
          
          // ✅ استخدام NavigatorKey بدلاً من Get
          if (navigatorKey != null && navigatorKey!.currentState != null) {
            navigatorKey!.currentState!.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        }
        handler.next(error);
      },
    ));
    
    // Add Logging Interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ));
  }
  
  // Getter for Dio instance
  Dio get dio => _dio;
}