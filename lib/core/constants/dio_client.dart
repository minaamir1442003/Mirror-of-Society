// lib/core/constants/dio_client.dart - النسخة المحسنة
import 'package:app_1/core/constants/api_const.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GlobalKey<NavigatorState>? navigatorKey;
  
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
        print('🚨 Dio Error Details:');
        print('📊 Status: ${error.response?.statusCode}');
        print('🔗 Path: ${error.requestOptions.path}');
        print('💬 Message: ${error.message}');
        print('📄 Response: ${error.response?.data}');
        
        // IMPORTANT: We don't handle redirects here anymore!
        // All error handling should be done in Cubits/Blocs
        
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