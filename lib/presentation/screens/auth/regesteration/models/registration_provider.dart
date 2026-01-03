import 'package:flutter/material.dart';

class RegistrationData {
  String firstName;
  String lastName;
  String email;
  String password;
  String phone;
  String? bio;
  DateTime? birthdate;
  String? zodiac;
  String zodiacDescription;
  List<int> interests;
  String? imagePath;
  String? coverPath;
  bool shareLocation;
  bool shareZodiac;
  String country;
  
  RegistrationData({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.phone = '',
    this.bio,
    this.birthdate,
    this.zodiac,
    this.zodiacDescription = '',
    this.interests = const [],
    this.imagePath,
    this.coverPath,
    this.shareLocation = false,
    this.shareZodiac = false,
    this.country = 'Egypt',
  });
  
  RegistrationData copyWith({
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
    String? imagePath,
    String? coverPath,
    bool? shareLocation,
    bool? shareZodiac,
    String? country,
  }) {
    return RegistrationData(
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
      imagePath: imagePath ?? this.imagePath,
      coverPath: coverPath ?? this.coverPath,
      shareLocation: shareLocation ?? this.shareLocation,
      shareZodiac: shareZodiac ?? this.shareZodiac,
      country: country ?? this.country,
    );
  }
}

class RegistrationProvider extends ChangeNotifier {
  RegistrationData _data = RegistrationData();
  
  RegistrationData get data => _data;
  
  void updateData(RegistrationData newData) {
    _data = newData;
    notifyListeners();
  }
  
  void updateField({
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
    String? imagePath,
    String? coverPath,
    bool? shareLocation,
    bool? shareZodiac,
    String? country,
  }) {
    _data = _data.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
      bio: bio,
      birthdate: birthdate,
      zodiac: zodiac,
      zodiacDescription: zodiacDescription,
      interests: interests,
      imagePath: imagePath,
      coverPath: coverPath,
      shareLocation: shareLocation,
      shareZodiac: shareZodiac,
      country: country,
    );
    notifyListeners();
  }
  
  void clear() {
    _data = RegistrationData();
    notifyListeners();
  }
}