class Categors {
  final int id;
  final String name;
  final String color;
  final String? icon;
  final int telegramsCount;

  Categors({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.telegramsCount,
  });

  factory Categors.fromJson(Map<String, dynamic> json) {
    return Categors(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String?,
      telegramsCount: json['telegrams_count'] as int? ?? 0,
    );
  }
}