// part of 'forgot_password_cubit.dart';

abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;
  ForgotPasswordSuccess({required this.message});
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  ForgotPasswordError({required this.message});
}

// حالات التحقق من OTP
class VerifyOtpLoading extends ForgotPasswordState {}

class VerifyOtpSuccess extends ForgotPasswordState {
  final String message;
  VerifyOtpSuccess({required this.message});
}

class VerifyOtpError extends ForgotPasswordState {
  final String message;
  VerifyOtpError({required this.message});
}

// حالات إعادة تعيين كلمة المرور
class ResetPasswordLoading extends ForgotPasswordState {}

class ResetPasswordSuccess extends ForgotPasswordState {
  final String message;
  ResetPasswordSuccess({required this.message});
}

class ResetPasswordError extends ForgotPasswordState {
  final String message;
  ResetPasswordError({required this.message});
}