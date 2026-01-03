part of 'register_cubit.dart';

enum RegisterErrorType {
  emailAlreadyUsed,
  phoneAlreadyUsed,
  validation,
  general,
  network,
  server,
}

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final UserModel user;
  
  RegisterSuccess({required this.user});
}

class RegisterFailure extends RegisterState {
  final String error;
  final RegisterErrorType errorType;
  
  RegisterFailure({
    required this.error,
    this.errorType = RegisterErrorType.general,
  });
}