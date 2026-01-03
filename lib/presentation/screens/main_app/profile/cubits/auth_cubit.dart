import 'package:app_1/core/constants/injection_container.dart';
import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/cubits/telegram_cubit.dart';
import 'package:app_1/presentation/screens/main_app/home/Cubit/home_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/update_profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/auth_repository.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/cubits/verification_cubit.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/cubits/user_profile_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ProfileCubit _profileCubit;

  AuthCubit({
    required AuthRepository authRepository,
    required ProfileCubit profileCubit,
  })  : _authRepository = authRepository,
        _profileCubit = profileCubit,
        super(AuthInitial());

  Future<void> logout() async {
    print('🚀 AuthCubit: Starting logout process');
    emit(LogoutLoading());

    try {
      // 1. أرسل طلب logout للسيرفر أولاً
      try {
        final success = await _authRepository.logout();
        print('✅ AuthCubit: Server logout completed: $success');
      } catch (e) {
        print('⚠️ AuthCubit: Server logout error (ignored): $e');
      }

      // 2. نظف البيانات المحلية
      await _clearLocalData();

      // 3. Reset جميع الـ Cubits بشكل متزامن
      await _resetAllCubits();

      // 4. Reset الـ dependencies في GetIt
      await resetUserDependencies();

      // 5. إعطاء وقت للتأكد من تنظيف البيانات
      await Future.delayed(Duration(milliseconds: 100));

      // 6. أرسل حالة النجاح
      emit(LogoutSuccess());
      print('✅ AuthCubit: LogoutSuccess emitted');

    } catch (e) {
      print('❌ AuthCubit: Error in logout: $e');
      emit(LogoutError('حدث خطأ أثناء تسجيل الخروج'));
    }
  }

  // ✅ دالة لتنظيف البيانات المحلية (بدون أي reference لـ context)
  Future<void> _clearLocalData() async {
    try {
      print('🧹 AuthCubit: Cleaning local data...');

      final storageService = StorageService();
      await storageService.ensureInitialized();

      // مسح التوكن وبيانات المستخدم
      await storageService.clearAllUserData();

      print('✅ AuthCubit: Local data cleared successfully');
    } catch (e) {
      print('❌ AuthCubit: Error clearing local data: $e');
    }
  }

  // ✅ دالة محسنة لreset جميع الـ Cubits
  Future<void> _resetAllCubits() async {
    try {
      print('🔄 AuthCubit: Resetting all cubits...');

      // 1. Reset ProfileCubit
      try {
        final profileCubit = sl.get<ProfileCubit>();
        profileCubit.clearAllData();
        print('✅ ProfileCubit reset done');
      } catch (e) {
        print('⚠️ Error resetting ProfileCubit: $e');
      }

      // 2. Reset HomeCubit - مهم: إعادة تعيين كاملة
      try {
        final homeCubit = sl.get<HomeCubit>();
        // ✅ تحقق أولاً إذا كانت الدالة resetCubit موجودة، إذا لم تكن استخدم clearCacheAndData
        if (homeCubit is HomeCubit) {
          // جرب استدعاء resetCubit إذا كانت موجودة
          try {
            await homeCubit.resetCubit();
            print('✅ HomeCubit reset done using resetCubit');
          } catch (e) {
            // إذا لم تكن الدالة موجودة، استخدم clearCacheAndData
            print('⚠️ resetCubit not available, using clearCacheAndData instead');
            await homeCubit.clearCacheAndData();
            print('✅ HomeCubit reset done using clearCacheAndData');
          }
        }
      } catch (e) {
        print('⚠️ Error resetting HomeCubit: $e');
      }

      // 3. إعادة تعيين الـ Cubits الأخرى
      try {
        // Reset UpdateProfileCubit إذا كان مسجل
        if (sl.isRegistered<UpdateProfileCubit>()) {
          sl.unregister<UpdateProfileCubit>();
        }

        // Reset TelegramCubit إذا كان مسجل
        if (sl.isRegistered<TelegramCubit>()) {
          sl.unregister<TelegramCubit>();
        }

        // Reset VerificationCubit إذا كان مسجل
        if (sl.isRegistered<VerificationCubit>()) {
          sl.unregister<VerificationCubit>();
        }

        // Reset UserProfileCubit إذا كان مسجل
        if (sl.isRegistered<UserProfileCubit>()) {
          sl.unregister<UserProfileCubit>();
        }

        print('✅ Other cubits reset done');
      } catch (e) {
        print('⚠️ Error resetting other cubits: $e');
      }

      print('✅ AuthCubit: All cubits reset successfully');
    } catch (e) {
      print('❌ AuthCubit: Error resetting cubits: $e');
    }
  }
  
  // ✅ يمكنك إزالة دالة _resetProfileCubit القديمة لأنها أصبحت جزء من _resetAllCubits
  // أو احتفظ بها إذا كنت تستخدمها في مكان آخر
}