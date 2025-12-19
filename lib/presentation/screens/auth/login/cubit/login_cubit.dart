// lib/presentation/cubits/auth/login_cubit.dart
import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:app_1/presentation/screens/auth/login/models/login_model.dart';
import 'package:app_1/presentation/screens/auth/login/models/login_response_model.dart';
import 'package:app_1/presentation/screens/auth/login/repositories/login_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository loginRepository;
  final StorageService storageService;

  LoginCubit({
    required this.loginRepository,
    required this.storageService,
  }) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    
    try {
      final loginData = LoginModel(email: email, password: password);
      final response = await loginRepository.login(loginData);
      
      if (response.status) {
        // ✅ استخدام response.token مباشرة
        await storageService.saveToken(response.token);
        
        // إذا كان هناك بيانات user في data
        if (response.data != null) {
          await storageService.saveUser(response.data!.user.toJson());
          emit(LoginSuccess(response.data!.user));
        } else {
          // إذا لم يكن هناك user في response، أنشئ user فارغ
          final defaultUser = User(
            id: 0,
            name: email.split('@').first,
            email: email,
            phone: null,
            image: null,
            bio: null,
            isVerified: false,
          );
          await storageService.saveUser(defaultUser.toJson());
          emit(LoginSuccess(defaultUser));
        }
      } else {
        emit(LoginError(response.message));
      }
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}