import 'package:app_1/presentation/screens/main_app/explore/cubits/category_state.dart';
import 'package:app_1/presentation/screens/main_app/explore/models/category_model.dart';
import 'package:app_1/presentation/screens/main_app/explore/repositories/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/data/services/language_service.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _categoryRepository;
  
  List<CategoryModel> _cachedCategories = [];
  String? _currentLanguage;
  bool _isRefreshing = false;
  bool _isInitialized = false;
  bool _isInitializing = false;
  
  // ⭐ آخر بيانات صالحة (مثل HomeCubit)
  List<CategoryModel> _lastValidCategories = [];
  
  // ⭐ Overlay Refresh Variable
  bool _isRefreshingWithOverlay = false;

  CategoryCubit({
    required CategoryRepository categoryRepository,
  })  : _categoryRepository = categoryRepository,
        super(const CategoryInitial());

  // ✅ دالة التهيئة المعدلة (مثل HomeCubit)
  Future<void> initialize({bool force = false}) async {
    if (_isInitialized && !force) {
      print('✅ CategoryCubit: Already initialized, skipping...');
      return;
    }
    
    if (_isInitializing) {
      print('⚠️ CategoryCubit: Initialization already in progress');
      return;
    }
    
    _isInitializing = true;
    
    try {
      print('🔄 CategoryCubit: Starting initialization...');
      
      // 1. استخدام الاستدعاءات static مباشرة
      final language = await LanguageService.getSavedLanguage();
      _currentLanguage = language;
      
      // 2. التحقق إذا كان هناك بيانات مخزنة
      if (_lastValidCategories.isNotEmpty) {
        // إصدار حالة Refreshing مع البيانات المخزنة
        emit(CategoryRefreshingWithOverlay(
          categories: _lastValidCategories,
          language: language,
        ));
      } else {
        // إذا مفيش بيانات مخزنة، نعرض حالة Loading بدون بيانات
        emit(CategoryLoading(cachedCategories: null));
      }
      
      // 3. جلب البيانات الجديدة مباشرة
      try {
        final response = await _categoryRepository.fetchCategories();
        
        // تحديث البيانات
        _cachedCategories = response.data;
        _lastValidCategories = List.from(_cachedCategories);
        
        print('✅ CategoryCubit: Successfully fetched ${response.data.length} categories');
        
        emit(CategoryLoaded(
          categories: _cachedCategories,
          language: language,
        ));
        
      } catch (e) {
        print('❌ CategoryCubit: Error loading fresh data: $e');
        
        // إذا فشل تحميل البيانات الجديدة، نظهر البيانات القديمة إذا كانت موجودة
        if (_lastValidCategories.isNotEmpty) {
          emit(CategoryLoaded(
            categories: _lastValidCategories,
            language: language,
          ));
        } else {
          // إذا مفيش بيانات خالص، نظهر Error State
          emit(CategoryError(
            message: 'فشل تحميل التصنيفات: $e',
            cachedCategories: null,
          ));
        }
      }

      _isInitialized = true;
      
    } catch (e) {
      print('❌ CategoryCubit: Initialization error: $e');
      
      _isInitialized = true;
      
      if (_lastValidCategories.isNotEmpty) {
        emit(CategoryLoaded(
          categories: _lastValidCategories,
          language: _currentLanguage,
        ));
      }
    } finally {
      _isInitializing = false;
    }
  }

  // ✅ دالة refresh الجديدة مع Overlay (مثل HomeCubit)
  Future<void> refresh() async {
    print('🔄 CategoryCubit: Refreshing with overlay...');
    
    if (_isRefreshingWithOverlay) return;
    
    try {
      _isRefreshingWithOverlay = true;
      
      // ✅ إصدار حالة الـ Overlay Loading مع البيانات الحالية
      if (state is CategoryLoaded) {
        final currentState = state as CategoryLoaded;
        emit(CategoryRefreshingWithOverlay(
          categories: currentState.categories,
          language: currentState.language,
        ));
      } else if (state is CategoryRefreshingWithOverlay) {
        // إذا كان بالفعل في حالة overlay، نظهر البيانات القديمة
        final currentState = state as CategoryRefreshingWithOverlay;
        emit(CategoryRefreshingWithOverlay(
          categories: currentState.categories,
          language: currentState.language,
        ));
      }
      
      // ✅ حفظ البيانات القديمة مؤقتاً
      final oldCategories = List<CategoryModel>.from(_cachedCategories);
      
      try {
        // جلب البيانات الجديدة
        final language = await LanguageService.getSavedLanguage();
        final response = await _categoryRepository.fetchCategories();
        
        // تحديث البيانات
        _cachedCategories = response.data;
        _lastValidCategories = List.from(_cachedCategories);
        _currentLanguage = language;
        
        // إصدار الحالة الجديدة
        emit(CategoryLoaded(
          categories: _cachedCategories,
          language: language,
        ));
        
        print('✅ CategoryCubit: Successfully refreshed ${response.data.length} categories');
        
      } catch (e) {
        print('❌ CategoryCubit: Error in refresh: $e');
        
        // ✅ استعادة البيانات القديمة في حالة الخطأ
        _cachedCategories = oldCategories;
        _lastValidCategories = List.from(_cachedCategories);
        
        emit(CategoryLoaded(
          categories: _cachedCategories,
          language: _currentLanguage,
        ));
        
        throw e;
      }
    } finally {
      _isRefreshingWithOverlay = false;
    }
  }

  // جلب التصنيفات من API - للتحميل الأولي (القديم للحفاظ على التوافق)
  Future<void> fetchCategories() async {
    await initialize();
  }

  // ✅ تحديث التصنيفات مع الحفاظ على البيانات القديمة أثناء التحديث
  Future<void> refreshCategories() async {
    try {
      print('🔄 CategoryCubit: Refreshing categories...');
      
      _isRefreshing = true;
      
      // ✅ أثناء الـ refresh، نعرض البيانات المخزنة أولاً
      if (_lastValidCategories.isNotEmpty) {
        emit(CategoryRefreshingWithOverlay(
          categories: _lastValidCategories,
          language: _currentLanguage,
        ));
      }
      
      // ✅ استخدام الاستدعاءات static مباشرة
      final language = await LanguageService.getSavedLanguage();
      _currentLanguage = language;
      
      // محاولة جلب التصنيفات من API
      final response = await _categoryRepository.fetchCategories();
      
      // حفظ في الكاش
      _cachedCategories = response.data;
      _lastValidCategories = List.from(_cachedCategories);
      
      print('✅ CategoryCubit: Successfully refreshed ${response.data.length} categories');
      
      emit(CategoryLoaded(
        categories: response.data,
        language: language,
      ));
      
    } catch (e) {
      print('❌ CategoryCubit: Error refreshing categories: $e');
      
      // ✅ عند حدوث خطأ أثناء الـ refresh، نعود للبيانات المخزنة
      if (_lastValidCategories.isNotEmpty) {
        emit(CategoryLoaded(
          categories: _lastValidCategories,
          language: _currentLanguage,
        ));
      } else {
        emit(CategoryError(
          message: 'Refresh failed: $e',
          cachedCategories: _cachedCategories,
        ));
      }
      
      throw Exception('Failed to refresh categories');
      
    } finally {
      _isRefreshing = false;
    }
  }

  // ✅ دالة محسنة لعرض البيانات المخزنة أثناء التحميل
  List<CategoryModel> getDisplayCategories(CategoryState state) {
    if (state is CategoryLoaded) {
      return state.categories;
    } 
    else if (state is CategoryRefreshingWithOverlay) {
      return state.categories;
    }
    else if (state is CategoryLoading) {
      // إذا كان هناك بيانات مخزنة، نعرضها
      return state.cachedCategories ?? _lastValidCategories;
    }
    else if (state is CategoryError) {
      // عند الخطأ، نعرض البيانات المخزنة (إذا كانت موجودة)
      return state.cachedCategories ?? _lastValidCategories;
    }
    else if (state is CategoryInitial) {
      return _lastValidCategories;
    }
    return _lastValidCategories;
  }

  // ✅ دالة للتحقق مما إذا كان هناك بيانات مخزنة للعرض
  bool hasCachedData(CategoryState state) {
    final displayCategories = getDisplayCategories(state);
    return displayCategories.isNotEmpty;
  }

  // Getters (مثل HomeCubit)
  bool get isRefreshingWithOverlay => _isRefreshingWithOverlay;
  List<CategoryModel> get lastValidCategories => _lastValidCategories;
  bool get isInitialized => _isInitialized;

  // الحصول على تصنيف محدد
  CategoryModel? getCategoryById(int id) {
    if (state is CategoryLoaded) {
      final loadedState = state as CategoryLoaded;
      return loadedState.categories.firstWhere(
        (category) => category.id == id,
        orElse: () => CategoryModel(
          id: 0,
          name: 'Unknown',
          color: '#000000',
          icon: null,
          telegramsCount: 0,
        ),
      );
    }
    return null;
  }

  // ترتيب التصنيفات حسب عدد التيليجرامات
  Future<void> sortCategoriesByCount(bool ascending) async {
    if (state is CategoryLoaded) {
      final loadedState = state as CategoryLoaded;
      final sortedCategories = List<CategoryModel>.from(loadedState.categories);
      
      sortedCategories.sort((a, b) {
        return ascending
            ? a.telegramsCount.compareTo(b.telegramsCount)
            : b.telegramsCount.compareTo(a.telegramsCount);
      });
      
      emit(CategoryLoaded(
        categories: sortedCategories,
        language: loadedState.language,
      ));
    }
  }

  // تصفية التصنيفات
  Future<void> filterCategories(String query) async {
    if (state is CategoryLoaded) {
      final loadedState = state as CategoryLoaded;
      
      if (query.isEmpty) {
        // إذا كان البحث فارغاً، ارجع كل التصنيفات
        emit(CategoryLoaded(
          categories: _cachedCategories,
          language: loadedState.language,
        ));
      } else {
        final filtered = _cachedCategories.where((category) {
          return category.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
        
        emit(CategoryLoaded(
          categories: filtered,
          language: loadedState.language,
        ));
      }
    }
  }

  // جلب الكاش
  List<CategoryModel> get cachedCategories => _cachedCategories;

  // معرفة إذا كانت البيانات قد تم تحميلها
  bool get isLoaded => state is CategoryLoaded;
  bool get isLoading => state is CategoryLoading;
  bool get hasError => state is CategoryError;
  bool get isRefreshing => _isRefreshing;
}