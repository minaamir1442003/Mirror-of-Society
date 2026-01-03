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
    required this.icon,
    required this.telegramsCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'] ?? '#007bff',
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

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, telegramsCount: $telegramsCount)';
  }
}