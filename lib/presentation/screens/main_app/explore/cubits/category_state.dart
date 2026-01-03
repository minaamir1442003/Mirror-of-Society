import 'package:app_1/presentation/screens/main_app/explore/models/category_model.dart';

abstract class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  final List<CategoryModel>? cachedCategories;
  
  const CategoryLoading({this.cachedCategories});
}

// ✅ أضف هذه الحالة الجديدة (مثل HomeRefreshingWithOverlay)
class CategoryRefreshingWithOverlay extends CategoryState {
  final List<CategoryModel> categories;
  final String? language;

  const CategoryRefreshingWithOverlay({
    required this.categories,
    this.language,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryRefreshingWithOverlay &&
          runtimeType == other.runtimeType &&
          categories == other.categories &&
          language == other.language;

  @override
  int get hashCode => categories.hashCode ^ language.hashCode;
}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final String? language;

  const CategoryLoaded({required this.categories, this.language});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryLoaded &&
          runtimeType == other.runtimeType &&
          categories == other.categories &&
          language == other.language;

  @override
  int get hashCode => categories.hashCode ^ language.hashCode;
}

class CategoryError extends CategoryState {
  final String message;
  final List<CategoryModel>? cachedCategories;

  const CategoryError({required this.message, this.cachedCategories});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          cachedCategories == other.cachedCategories;

  @override
  int get hashCode => message.hashCode ^ cachedCategories.hashCode;
}