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
      print('✅ StorageService initialized successfully');
    } catch (e) {
      print('❌ Error initializing SharedPreferences: $e');
      _isInitialized = false;
    }
  }
  
  // ✅ جعلها public بدل private
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _init();
    }
  }
  
  // ✅ دالة إضافية للتحقق من التهيئة
  bool get isInitialized => _isInitialized;
  
  // Token Methods
  Future<void> saveToken(String token) async {
    await ensureInitialized();
    await _secureStorage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    await ensureInitialized();
    return await _secureStorage.read(key: 'auth_token');
  }
  
  Future<void> deleteToken() async {
    await ensureInitialized();
    await _secureStorage.delete(key: 'auth_token');
  }
  
  // User Data Methods
  Future<void> saveUser(Map<String, dynamic> user) async {
    await ensureInitialized();
    final userJson = jsonEncode(user);
    await _secureStorage.write(key: 'user_data', value: userJson);
  }
  
  Future<Map<String, dynamic>?> getUser() async {
    await ensureInitialized();
    final userJson = await _secureStorage.read(key: 'user_data');
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }
  
  Future<void> deleteUser() async {
    await ensureInitialized();
    await _secureStorage.delete(key: 'user_data');
  }
  
  // First Launch Methods
  Future<bool> isFirstLaunch() async {
    await ensureInitialized();
    return !_prefs.containsKey('first_launch_completed');
  }
  
  Future<void> setFirstLaunchCompleted() async {
    await ensureInitialized();
    await _prefs.setBool('first_launch_completed', true);
  }
  
  // Onboarding Methods
  Future<bool> isOnboardingCompleted() async {
    await ensureInitialized();
    final result = _prefs.getBool('onboarding_completed') ?? false;
    print('🔍 StorageService: isOnboardingCompleted = $result');
    return result;
  }
  
  Future<void> setOnboardingCompleted() async {
    await ensureInitialized();
    await _prefs.setBool('onboarding_completed', true);
    print('✅ StorageService: setOnboardingCompleted = true');
  }
  
  // Clear All
  Future<void> clearAll() async {
    await ensureInitialized();
    await _secureStorage.deleteAll();
    await _prefs.clear();
    print('🧹 All storage cleared');
  }
  
  Future<void> clearAllUserData() async {
  try {
    print('🧹 StorageService: Clearing all user data from storage...');
    
    await ensureInitialized();
    
    // مسح التوكن
    await deleteToken();
    
    // مسح بيانات المستخدم
    await deleteUser();
    
    // مسح الكاش
    await deleteSecureData('cached_home_feed');
    await deleteSecureData('cached_events');
    await deleteSecureData('cached_next_cursor');
    await deleteSecureData('cached_has_more');
    await deleteSecureData('cached_timestamp');
    
    // مسح أي بيانات أخرى مرتبطة بالمستخدم
    await _prefs.remove('user_id');
    await _prefs.remove('user_name');
    await _prefs.remove('user_email');
    await _prefs.remove('user_image');
    await _prefs.remove('user_rank');
    await _prefs.remove('fcm_token');
    await _prefs.remove('notifications_enabled');
    
    print('✅ StorageService: All user data cleared');
  } catch (e) {
    print('❌ StorageService: Error clearing user data: $e');
  }
}
  Future<void> writeSecureData(String key, String value) async {
    await ensureInitialized();
    await _secureStorage.write(key: key, value: value);
  }
  
  Future<String?> readSecureData(String key) async {
    await ensureInitialized();
    return await _secureStorage.read(key: key);
  }
  
  Future<void> deleteSecureData(String key) async {
    await ensureInitialized();
    await _secureStorage.delete(key: key);
  }
  
  // ✅ دالة جديدة لفحص حالة التخزين
  Future<void> debugStorage() async {
    await ensureInitialized();
    
    print('🔍 ===== STORAGE DEBUG INFO =====');
    print('🔍 isInitialized: $_isInitialized');
    
    // فحص حالة الأونبوردينج
    final onboarding = _prefs.getBool('onboarding_completed') ?? false;
    print('🔍 onboarding_completed: $onboarding');
    
    // فحص جميع المفاتيح الموجودة
    final keys = _prefs.getKeys();
    print('🔍 All keys in SharedPreferences:');
    for (var key in keys) {
      final value = _prefs.get(key);
      print('   - $key: $value');
    }
    
    // فحص التوكن من Secure Storage
    try {
      final token = await getToken();
      print('🔍 Auth token exists: ${token != null}');
      print('🔍 Token length: ${token?.length ?? 0}');
    } catch (e) {
      print('🔍 Error getting token: $e');
    }
    
    print('🔍 ==============================');
  }
}