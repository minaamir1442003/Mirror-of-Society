class RegisterData {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final String? bio;
  final DateTime? birthdate;
  final String? zodiac;
  final String zodiacDescription;
  final List<int> interests;
  
  RegisterData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phone = '',
    this.bio,
    this.birthdate,
    this.zodiac,
    this.zodiacDescription = '',
    this.interests = const [],
  });
  
  RegisterData copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phone,
    String? bio,
    DateTime? birthdate,
    String? zodiac,
    String? zodiacDescription,
    List<int>? interests,
  }) {
    return RegisterData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      birthdate: birthdate ?? this.birthdate,
      zodiac: zodiac ?? this.zodiac,
      zodiacDescription: zodiacDescription ?? this.zodiacDescription,
      interests: interests ?? this.interests,
    );
  }
}