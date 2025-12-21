import 'package:app_1/core/constants/injection_container.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/auth_repository.dart';
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
    // 1. نظف البيانات المحلية أولاً
    await _clearLocalData();
    
    // 2. Reset الـ ProfileCubit من GetIt
    _resetProfileCubit();
    
    // 3. أرسل طلب logout للسيرفر
    _authRepository.logout().then((success) {
      print('✅ AuthCubit: Server logout completed: $success');
    }).catchError((e) {
      print('⚠️ AuthCubit: Server logout error (ignored): $e');
    });
    
    // 4. أرسل حالة النجاح
    emit(LogoutSuccess());
    print('✅ AuthCubit: LogoutSuccess emitted');
    
  } catch (e) {
    print('❌ AuthCubit: Error in logout: $e');
    emit(LogoutError('حدث خطأ أثناء تسجيل الخروج'));
  }
}
void _resetProfileCubit() {
  try {
    print('🔄 AuthCubit: Resetting ProfileCubit...');
    
    // احصل على الـ ProfileCubit الحالي من GetIt
    final profileCubit = sl.get<ProfileCubit>();
    
    // نظف كل بياناته
    profileCubit.clearAllData();
    
    print('✅ AuthCubit: ProfileCubit reset successfully');
  } catch (e) {
    print('⚠️ AuthCubit: Error resetting ProfileCubit: $e');
  }
}

  // ✅ دالة لتنظيف البيانات المحلية (بدون أي reference لـ context)
  Future<void> _clearLocalData() async {
    try {
      print('🧹 AuthCubit: Cleaning local data...');
      
      // 1. تنظيف ProfileCubit
      _profileCubit.clearAllData();
      print('✅ AuthCubit: ProfileCubit data cleared');
      
      // 2. تأخير بسيط
      await Future.delayed(Duration(milliseconds: 50));
      
      print('✅ AuthCubit: Local data cleared successfully');
    } catch (e) {
      print('❌ AuthCubit: Error clearing local data: $e');
      // نستمر حتى لو حدث خطأ
    }
  }
}