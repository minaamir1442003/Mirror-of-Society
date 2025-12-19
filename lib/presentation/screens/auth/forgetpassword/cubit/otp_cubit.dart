// lib/presentation/screens/auth/otp/cubit/otp_cubit.dart
import 'package:app_1/presentation/screens/auth/forgetpassword/repository/otp_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepository _otpRepository;

  OtpCubit({required OtpRepository otpRepository})
      : _otpRepository = otpRepository,
        super(OtpInitial());

  // التحقق من OTP
  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    emit(OtpVerifyLoading());
    try {
      final response = await _otpRepository.verifyOtp(
        email: email,
        otp: otp,
      );
      
      if (response.status) {
        emit(OtpVerifySuccess(message: response.message));
      } else {
        emit(OtpVerifyError(message: response.message));
      }
    } catch (e) {
      emit(OtpVerifyError(message: e.toString()));
    }
  }

  // إعادة إرسال OTP
  Future<void> resendOtp(String email) async {
    emit(OtpResendLoading());
    try {
      final response = await _otpRepository.resendOtp(email);
      
      if (response.status) {
        emit(OtpResendSuccess(message: response.message));
      } else {
        emit(OtpResendError(message: response.message));
      }
    } catch (e) {
      emit(OtpResendError(message: e.toString()));
    }
  }

  void reset() {
    emit(OtpInitial());
  }
}