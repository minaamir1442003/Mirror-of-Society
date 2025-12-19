// lib/features/auth/data/models/register_request.dart
class RegisterRequest {
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String phone;
  final String? bio;
  final String zodiac;
  final String zodiacDescription;
  final bool shareLocation;
  final bool shareZodiac;
  final String birthdate;
  final String country;
  final List<int> interests;
  final String? imagePath;
  final String? coverPath;
  
  RegisterRequest({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.phone,
    this.bio,
    required this.zodiac,
    required this.zodiacDescription,
    required this.shareLocation,
    required this.shareZodiac,
    required this.birthdate,
    required this.country,
    required this.interests,
    this.imagePath,
    this.coverPath,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone': phone,
      'bio': bio,
      'zodiac': zodiac,
      'zodiac_description': zodiacDescription,
      'share_location': shareLocation,
      'share_zodiac': shareZodiac,
      'birthdate': birthdate,
      'country': country,
      'interests': interests,
    };
  }
}