

import 'package:app_1/core/constants/dio_client.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/models/telegram_m.dart';
import 'package:dio/dio.dart';

class CategoryService {
  final Dio _dio;
  List<CategoryModel> _categories = [];
  DateTime? _lastFetchTime;

  CategoryService({required DioClient dioClient})
      : _dio = dioClient.dio;

  // جلب جميع الفئات
  Future<List<CategoryModel>> getCategories({bool forceRefresh = false}) async {
    // التحقق من الكاش إذا لم نطلب تحديث إجباري
    if (!forceRefresh && 
        _categories.isNotEmpty && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < Duration(minutes: 10)) {
      return _categories;
    }

    try {
      final response = await _dio.get('/categories');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        _categories = data.map((json) => CategoryModel.fromJson(json)).toList();
        _lastFetchTime = DateTime.now();
        return _categories;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error in getCategories: $e');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
      }
      
      // إرجاع البيانات المخزنة مؤقتًا في حالة الخطأ
      if (_categories.isNotEmpty) {
        return _categories;
      }
      rethrow;
    }
  }

  // الحصول على فئة محددة بواسطة ID
  CategoryModel? getCategoryById(int id) {
    return _categories.firstWhere(
      (category) => category.id == id,
      orElse: () => throw Exception('Category not found'),
    );
  }

  // الحصول على فئة محددة بواسطة الاسم
  CategoryModel? getCategoryByName(String name) {
    return _categories.firstWhere(
      (category) => category.name == name,
      orElse: () => throw Exception('Category not found'),
    );
  }

  // مسح الكاش
  void clearCache() {
    _categories.clear();
    _lastFetchTime = null;
  }
}