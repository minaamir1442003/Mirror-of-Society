// lib/presentation/screens/main_app/profile/cubits/update_profile_cubit.dart
import 'package:app_1/presentation/screens/main_app/profile/models/profile_response.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/update_profile_request.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/user_profile_model.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/update_profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'update_profile_state.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  final UpdateProfileRepository _updateRepository;
  
  List<Map<String, dynamic>> _availableInterests = [];
  List<Map<String, dynamic>> _availableZodiacs = [];

  UpdateProfileCubit({required UpdateProfileRepository updateRepository})
      : _updateRepository = updateRepository,
        super(UpdateProfileInitial());

  Future<void> loadInitialData() async {
    emit(UpdateProfileLoading());
    try {
      // جلب الاهتمامات المتاحة
      _availableInterests = await _updateRepository.getAvailableInterests();
      
      // جلب الأبراج المتاحة
      _availableZodiacs = await _updateRepository.getAvailableZodiacs();
      
      emit(UpdateProfileDataLoaded(
        availableInterests: _availableInterests,
        availableZodiacs: _availableZodiacs,
      ));
    } catch (e) {
      emit(UpdateProfileError(error: 'فشل تحميل البيانات: $e'));
    }
  }

  Future<void> updateProfile(UpdateProfileRequest request) async {
    emit(UpdateProfileUpdating());
    try {
      final response = await _updateRepository.updateProfile(request);
      
      emit(UpdateProfileSuccess(
        message: 'تم تحديث الملف الشخصي بنجاح',
        updatedProfile: response.data,
      ));
    } catch (e) {
      emit(UpdateProfileError(error: 'فشل تحديث الملف الشخصي: $e'));
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    emit(UpdateProfileUpdating());
    try {
      final request = UpdateProfileRequest(imagePath: imagePath);
      final response = await _updateRepository.updateProfile(request);
      
      emit(UpdateProfileSuccess(
        message: 'تم تحديث الصورة بنجاح',
        updatedProfile: response.data,
      ));
    } catch (e) {
      emit(UpdateProfileError(error: 'فشل تحديث الصورة: $e'));
    }
  }

  Future<void> updateCoverImage(String coverPath) async {
    emit(UpdateProfileUpdating());
    try {
      final request = UpdateProfileRequest(coverPath: coverPath);
      final response = await _updateRepository.updateProfile(request);
      
      emit(UpdateProfileSuccess(
        message: 'تم تحديث صورة الغلاف بنجاح',
        updatedProfile: response.data,
      ));
    } catch (e) {
      emit(UpdateProfileError(error: 'فشل تحديث صورة الغلاف: $e'));
    }
  }

  // دالة للحصول على الاهتمامات المتاحة
  List<Map<String, dynamic>> get availableInterests => _availableInterests;
  
  // دالة للحصول على الأبراج المتاحة
  List<Map<String, dynamic>> get availableZodiacs => _availableZodiacs;
  
  // دالة للبحث عن برج بالاسم
  Map<String, dynamic>? findZodiacByName(String name) {
    return _availableZodiacs.firstWhere(
      (zodiac) => zodiac['name'] == name,
      orElse: () => {},
    );
  }
}