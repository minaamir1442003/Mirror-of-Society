import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/register_request.dart';
import 'package:app_1/presentation/screens/auth/regesteration/repositories/register_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/data/models/user_model.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepository _registerRepository;
  final StorageService _storageService;
  
  RegisterCubit({
    required RegisterRepository registerRepository,
    required StorageService storageService,
  })  : _registerRepository = registerRepository,
        _storageService = storageService,
        super(RegisterInitial());
  
  Future<void> register(RegisterRequest request) async {
    emit(RegisterLoading());
    
    try {
      final response = await _registerRepository.register(request);
      
      if (response.status) {
        // Save token and user
        await _storageService.saveToken(response.token);
        await _storageService.saveUser(response.user.toJson());
        
        emit(RegisterSuccess(user: response.user));
      } else {
        emit(RegisterFailure(error: response.message));
      }
    } catch (error) {
      emit(RegisterFailure(error: error.toString()));
    }
  }
  
  void reset() {
    emit(RegisterInitial());
  }
}