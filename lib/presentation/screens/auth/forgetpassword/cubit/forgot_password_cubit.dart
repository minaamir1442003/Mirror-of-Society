// lib/presentation/screens/auth/forgetpassword/cubit/forgot_password_cubit.dart
import 'package:app_1/presentation/screens/auth/forgetpassword/cubit/forgot_password_state.dart';
import 'package:app_1/presentation/screens/auth/forgetpassword/repository/logout_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final LogoutRepository _authRepository;

  ForgotPasswordCubit({required LogoutRepository authRepository})
      : _authRepository = authRepository,
        super(ForgotPasswordInitial());

  Future<void> sendOtp(String email) async {
    emit(ForgotPasswordLoading());
    try {
      final response = await _authRepository.forgetPassword(email);
      if (response.status) {
        emit(ForgotPasswordSuccess(message: response.message));
      } else {
        emit(ForgotPasswordError(message: response.message));
      }
    } catch (e) {
      emit(ForgotPasswordError(message: e.toString()));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(ResetPasswordLoading());
    try {
      final response = await _authRepository.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (response.status) {
        emit(ResetPasswordSuccess(message: response.message));
      } else {
        emit(ResetPasswordError(message: response.message));
      }
    } catch (e) {
      emit(ResetPasswordError(message: e.toString()));
    }
  }

  void reset() {
    emit(ForgotPasswordInitial());
  }
}