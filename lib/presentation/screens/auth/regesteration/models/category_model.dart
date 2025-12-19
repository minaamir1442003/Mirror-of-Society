class CategoryModel {
  final int id;
  final String name;
  final String color;
  final String? icon;
  final int telegramsCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.telegramsCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'] ?? '#000000',
      icon: json['icon'],
      telegramsCount: json['telegrams_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'telegrams_count': telegramsCount,
    };
  }
}

class CategoriesResponse {
  final bool status;
  final String message;
  final List<CategoryModel> categories;

  CategoriesResponse({
    required this.status,
    required this.message,
    required this.categories,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    final categoriesList = (json['data'] as List)
        .map((item) => CategoryModel.fromJson(item))
        .toList();
    
    return CategoriesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      categories: categoriesList,
    );
  }
}