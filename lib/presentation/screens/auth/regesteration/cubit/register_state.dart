// lib/features/auth/presentation/cubit/register_state.dart
part of 'register_cubit.dart';

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final UserModel user;
  
  RegisterSuccess({required this.user});
}

class RegisterFailure extends RegisterState {
  final String error;
  
  RegisterFailure({required this.error});
}