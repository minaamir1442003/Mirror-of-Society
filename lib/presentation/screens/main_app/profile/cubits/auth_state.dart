part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class LogoutLoading extends AuthState {}
class LogoutSuccess extends AuthState {}
class LogoutError extends AuthState {
  final String message;
  LogoutError(this.message);
}