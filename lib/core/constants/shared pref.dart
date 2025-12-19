// lib/core/services/storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  
  StorageService() {
    // بدء التهيئة بشكل غير متزامن
    _init();
  }
  
  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
    }
  }
  
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _init();
    }
  }
  
  // Token Methods
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
  
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }
  
  // User Data Methods
  Future<void> saveUser(Map<String, dynamic> user) async {
    final userJson = jsonEncode(user);
    await _secureStorage.write(key: 'user_data', value: userJson);
  }
  
  Future<Map<String, dynamic>?> getUser() async {
    final userJson = await _secureStorage.read(key: 'user_data');
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }
  
  Future<void> deleteUser() async {
    await _secureStorage.delete(key: 'user_data');
  }
  
  // First Launch Methods - FIXED
  Future<bool> isFirstLaunch() async {
    await _ensureInitialized();
    return !_prefs.containsKey('first_launch_completed');
  }
  
  Future<void> setFirstLaunchCompleted() async {
    await _ensureInitialized();
    await _prefs.setBool('first_launch_completed', true);
  }
  
  // Onboarding Methods - FIXED
  Future<bool> isOnboardingCompleted() async {
    await _ensureInitialized();
    return _prefs.getBool('onboarding_completed') ?? false;
  }
  
  Future<void> setOnboardingCompleted() async {
    await _ensureInitialized();
    await _prefs.setBool('onboarding_completed', true);
  }
  
  // Clear All
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _ensureInitialized();
    await _prefs.clear();
  }
}