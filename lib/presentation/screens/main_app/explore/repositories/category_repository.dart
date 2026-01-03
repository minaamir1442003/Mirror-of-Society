import 'dart:convert';
import 'package:app_1/core/constants/api_const.dart';
import 'package:app_1/presentation/screens/main_app/explore/models/categories_response.dart' show CategoriesResponse;
import 'package:app_1/presentation/screens/main_app/explore/models/category_model.dart';
import 'package:dio/dio.dart';

class CategoryRepository {
  final Dio _dio;

  CategoryRepository({required Dio dio}) : _dio = dio;

  Future<CategoriesResponse> fetchCategories() async {
    try {
      print('📡 CategoryRepository: Fetching categories from API...');
      
      // الحصول على الـ headers مع اللغة المناسبة
      final headers = await ApiConstants.headers;
      
      final response = await _dio.get(
        ApiConstants.getCategories,
        options: Options(headers: headers),
      );

      print('✅ CategoryRepository: API Response received');
      
      if (response.statusCode == 200) {
        final data = response.data;
        print('📊 CategoryRepository: Response data type: ${data.runtimeType}');
        
        // التحقق من بنية الاستجابة
        if (data is Map<String, dynamic>) {
          final categoriesResponse = CategoriesResponse.fromJson(data);
          print('✅ CategoryRepository: ${categoriesResponse.data.length} categories loaded');
          return categoriesResponse;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ CategoryRepository: Dio Error - ${e.message}');
      print('📊 Status: ${e.response?.statusCode}');
      print('🔗 Path: ${e.requestOptions.path}');
      
      if (e.response != null) {
        print('📄 Response Data: ${e.response?.data}');
      }
      
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ CategoryRepository: Unexpected error - $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // دالة للترجمة المحلية للتصنيفات (كـ fallback)
  Future<List<CategoryModel>> getLocalCategories(String language) async {
    print('🏠 CategoryRepository: Loading local categories for $language');
    
    final localCategories = language == 'العربية' ? _getArabicCategories() : _getEnglishCategories();
    return Future.value(localCategories);
  }

  List<CategoryModel> _getEnglishCategories() {
    return [
      CategoryModel(id: 1, name: 'Politics', color: '#dc3545', icon: null, telegramsCount: 33),
      CategoryModel(id: 2, name: 'Sports', color: '#28a745', icon: null, telegramsCount: 35),
      CategoryModel(id: 3, name: 'Arts', color: '#6f42c1', icon: null, telegramsCount: 34),
      CategoryModel(id: 4, name: 'Technology', color: '#007bff', icon: null, telegramsCount: 36),
      CategoryModel(id: 5, name: 'Health', color: '#17a2b8', icon: null, telegramsCount: 26),
      CategoryModel(id: 6, name: 'Travel', color: '#ffc107', icon: null, telegramsCount: 38),
      CategoryModel(id: 7, name: 'Food', color: '#fd7e14', icon: null, telegramsCount: 27),
      CategoryModel(id: 8, name: 'Fashion', color: '#e83e8c', icon: null, telegramsCount: 31),
      CategoryModel(id: 9, name: 'Science', color: '#20c997', icon: null, telegramsCount: 33),
      CategoryModel(id: 10, name: 'Business', color: '#343a40', icon: null, telegramsCount: 44),
      CategoryModel(id: 11, name: 'Music', color: '#6610f2', icon: null, telegramsCount: 33),
      CategoryModel(id: 12, name: 'Movies', color: '#d63384', icon: null, telegramsCount: 37),
      CategoryModel(id: 13, name: 'Gaming', color: '#198754', icon: null, telegramsCount: 26),
      CategoryModel(id: 14, name: 'Literature', color: '#fd7e14', icon: null, telegramsCount: 39),
      CategoryModel(id: 15, name: 'Education', color: '#0dcaf0', icon: null, telegramsCount: 30),
    ];
  }

  List<CategoryModel> _getArabicCategories() {
    return [
      CategoryModel(id: 1, name: 'سياسة', color: '#dc3545', icon: null, telegramsCount: 33),
      CategoryModel(id: 2, name: 'رياضة', color: '#28a745', icon: null, telegramsCount: 35),
      CategoryModel(id: 3, name: 'فن', color: '#6f42c1', icon: null, telegramsCount: 34),
      CategoryModel(id: 4, name: 'تكنولوجيا', color: '#007bff', icon: null, telegramsCount: 36),
      CategoryModel(id: 5, name: 'صحة', color: '#17a2b8', icon: null, telegramsCount: 26),
      CategoryModel(id: 6, name: 'سفر', color: '#ffc107', icon: null, telegramsCount: 38),
      CategoryModel(id: 7, name: 'طعام', color: '#fd7e14', icon: null, telegramsCount: 27),
      CategoryModel(id: 8, name: 'موضة', color: '#e83e8c', icon: null, telegramsCount: 31),
      CategoryModel(id: 9, name: 'علوم', color: '#20c997', icon: null, telegramsCount: 33),
      CategoryModel(id: 10, name: 'أعمال', color: '#343a40', icon: null, telegramsCount: 44),
      CategoryModel(id: 11, name: 'موسيقى', color: '#6610f2', icon: null, telegramsCount: 33),
      CategoryModel(id: 12, name: 'أفلام', color: '#d63384', icon: null, telegramsCount: 37),
      CategoryModel(id: 13, name: 'ألعاب', color: '#198754', icon: null, telegramsCount: 26),
      CategoryModel(id: 14, name: 'أدب', color: '#fd7e14', icon: null, telegramsCount: 39),
      CategoryModel(id: 15, name: 'تعليم', color: '#0dcaf0', icon: null, telegramsCount: 30),
    ];
  }
}