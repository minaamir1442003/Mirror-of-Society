// lib/presentation/screens/main_app/profile/models/update_profile_request.dart
import 'package:dio/dio.dart';

class UpdateProfileRequest {
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? phone;
  final String? bio;
  final String? zodiac;
  final String? zodiacDescription;
  final bool? shareLocation;
  final bool? shareZodiac;
  final DateTime? birthdate;
  final String? country;
  final List<int>? interests;
  final String? imagePath;
  final String? coverPath;

  UpdateProfileRequest({
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
    this.bio,
    this.zodiac,
    this.zodiacDescription,
    this.shareLocation,
    this.shareZodiac,
    this.birthdate,
    this.country,
    this.interests,
    this.imagePath,
    this.coverPath,
  });

  Map<String, dynamic> toFormData() {
    final data = <String, dynamic>{};
    
    if (firstname != null) data['firstname'] = firstname!;
    if (lastname != null) data['lastname'] = lastname!;
    if (email != null) data['email'] = email!;
    if (phone != null) data['phone'] = phone!;
    if (bio != null) data['bio'] = bio!;
    if (zodiac != null) data['zodiac'] = zodiac!;
    if (zodiacDescription != null) data['zodiac_description'] = zodiacDescription!;
    if (shareLocation != null) data['share_location'] = shareLocation! ? '1' : '0';
    if (shareZodiac != null) data['share_zodiac'] = shareZodiac! ? '1' : '0';
    if (birthdate != null) data['birthdate'] = birthdate!.toIso8601String().split('T')[0];
    if (country != null) data['country'] = country!;
    if (interests != null && interests!.isNotEmpty) {
      for (int i = 0; i < interests!.length; i++) {
        data['interests[$i]'] = interests![i];
      }
    }
    
    return data;
  }

  // دالة لإضافة ملفات الصور
  Future<FormData> toFormDataWithFiles() async {
    final formData = FormData.fromMap(toFormData());
    
    // إضافة صورة الملف الشخصي إذا كانت موجودة
    if (imagePath != null && imagePath!.isNotEmpty) {
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(
          imagePath!,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      ));
    }
    
    // إضافة صورة الغلاف إذا كانت موجودة
    if (coverPath != null && coverPath!.isNotEmpty) {
      formData.files.add(MapEntry(
        'cover',
        await MultipartFile.fromFile(
          coverPath!,
          filename: 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      ));
    }
    
    return formData;
  }
}