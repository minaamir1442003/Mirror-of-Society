// lib/presentation/cubits/auth/login_state.dart
part of 'login_cubit.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final User user;
  
  LoginSuccess(this.user);
}

class LoginError extends LoginState {
  final String message;
  
  LoginError(this.message);
}