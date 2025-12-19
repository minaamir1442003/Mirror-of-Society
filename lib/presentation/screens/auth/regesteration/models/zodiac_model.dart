class ZodiacModel {
  final int id;
  final String name;
  final String description;
  final String? icon;

  ZodiacModel({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
  });

  factory ZodiacModel.fromJson(Map<String, dynamic> json) {
    return ZodiacModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
    };
  }
}

class ZodiacsResponse {
  final bool status;
  final String message;
  final List<ZodiacModel> zodiacs;

  ZodiacsResponse({
    required this.status,
    required this.message,
    required this.zodiacs,
  });

  factory ZodiacsResponse.fromJson(Map<String, dynamic> json) {
    final zodiacsList = (json['data'] as List)
        .map((item) => ZodiacModel.fromJson(item))
        .toList();
    
    return ZodiacsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      zodiacs: zodiacsList,
    );
  }
}