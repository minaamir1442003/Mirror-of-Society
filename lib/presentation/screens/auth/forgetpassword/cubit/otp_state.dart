// lib/presentation/screens/auth/otp/cubit/otp_state.dart
part of 'otp_cubit.dart';

abstract class OtpState {}

class OtpInitial extends OtpState {}

// حالات التحقق من OTP
class OtpVerifyLoading extends OtpState {}
class OtpVerifySuccess extends OtpState {
  final String message;
  OtpVerifySuccess({required this.message});
}
class OtpVerifyError extends OtpState {
  final String message;
  OtpVerifyError({required this.message});
}

// حالات إعادة إرسال OTP
class OtpResendLoading extends OtpState {}
class OtpResendSuccess extends OtpState {
  final String message;
  OtpResendSuccess({required this.message});
}
class OtpResendError extends OtpState {
  final String message;
  OtpResendError({required this.message});
}