// lib/presentation/screens/auth/login/cubit/login_cubit.dart
import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:app_1/presentation/screens/auth/login/models/login_model.dart';
import 'package:app_1/presentation/screens/auth/login/models/login_response_model.dart';
import 'package:app_1/presentation/screens/auth/login/repositories/login_repository.dart';
import 'package:app_1/presentation/screens/main_app/home/Cubit/home_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository loginRepository;
  final StorageService storageService;

  LoginCubit({
    required this.loginRepository,
    required this.storageService,
  }) : super(LoginInitial());

  Future<void> login(String email, String password, {BuildContext? context}) async {
    emit(LoginLoading());
    
    try {
      final loginData = LoginModel(email: email, password: password);
      final response = await loginRepository.login(loginData);
      
      if (response.status) {
        // ✅ 1. تنظيف البيانات القديمة أولاً
        await _clearOldDataBeforeLogin();
        
        // ✅ 2. حفظ التوكن الجديد
        await storageService.saveToken(response.token);
        
        // ✅ 3. حفظ بيانات المستخدم
        User user;
        if (response.data != null) {
          user = response.data!.user;
          await storageService.saveUser(user.toJson());
        } else {
          user = User(
            id: 0,
            name: email.split('@').first,
            email: email,
            phone: null,
            image: null,
            bio: null,
            isVerified: false,
          );
          await storageService.saveUser(user.toJson());
        }
        
        // ✅ 4. تنظيف Cubits إذا كان context متاحاً
        if (context != null) {
          await _resetCubitsAfterLogin(context);
        }
        
        emit(LoginSuccess(user));
      } else {
        emit(LoginError(response.message));
      }
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
  
  // ✅ دالة لتنظيف البيانات القديمة قبل تسجيل الدخول
  Future<void> _clearOldDataBeforeLogin() async {
    try {
      print('🧹 LoginCubit: Clearing old data before login...');
      
      // مسح جميع البيانات المخزنة
      await storageService.clearAllUserData();
      
      print('✅ LoginCubit: Old data cleared');
    } catch (e) {
      print('❌ LoginCubit: Error clearing old data: $e');
    }
  }
  
  // ✅ دالة لإعادة تعيين الـ Cubits بعد تسجيل الدخول
  Future<void> _resetCubitsAfterLogin(BuildContext context) async {
    try {
      print('🔄 LoginCubit: Resetting cubits after login...');
      
      // 1. تنظيف HomeCubit
      try {
        final homeCubit = context.read<HomeCubit>();
        await homeCubit.clearDataOnNewLogin();
        print('✅ HomeCubit reset after login');
      } catch (e) {
        print('⚠️ Error resetting HomeCubit: $e');
      }
      
      // 2. تنظيف ProfileCubit
      try {
        final profileCubit = context.read<ProfileCubit>();
        profileCubit.clearAllData();
        print('✅ ProfileCubit reset after login');
      } catch (e) {
        print('⚠️ Error resetting ProfileCubit: $e');
      }
      
    } catch (e) {
      print('❌ LoginCubit: Error resetting cubits: $e');
    }
  }
}