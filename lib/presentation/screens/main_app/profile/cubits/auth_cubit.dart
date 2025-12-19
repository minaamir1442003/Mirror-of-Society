import 'package:app_1/presentation/screens/main_app/profile/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial());

  Future<void> logout() async {
    emit(LogoutLoading());
    try {
      final success = await _authRepository.logout();
      if (success) {
        emit(LogoutSuccess());
      } else {
        emit(LogoutError('فشل تسجيل الخروج'));
      }
    } catch (e) {
      emit(LogoutError('حدث خطأ: $e'));
    }
  }
}