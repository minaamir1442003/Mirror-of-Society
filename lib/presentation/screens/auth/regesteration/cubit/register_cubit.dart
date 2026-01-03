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
    print('📨 Calling repository with email: ${request.email}');
    final response = await _registerRepository.register(request);
    
    print('📨 Repository Response - Status: ${response.status}');
    print('📨 Repository Response - Message: "${response.message}"');
    
    if (response.status) {
      // Save token and user
      await _storageService.saveToken(response.token);
      await _storageService.saveUser(response.user.toJson());
      
      emit(RegisterSuccess(user: response.user));
    } else {
      // **التعديل: ترجمة الرسالة**
      String errorMessage = response.message;
      final isArabic = request.country == 'Egypt' || 
                      (response.errorData != null && 
                       response.errorData!.containsKey('lang') && 
                       response.errorData!['lang'] == 'ar');
      
      // ترجمة الرسالة
      errorMessage = _translateErrorMessage(errorMessage, isArabic);
      
      RegisterErrorType errorType = RegisterErrorType.general;
      
      // تحديد نوع الخطأ
      if (errorMessage.contains('البريد الإلكتروني') || 
          errorMessage.contains('The email')) {
        errorType = RegisterErrorType.emailAlreadyUsed;
      } 
      else if (errorMessage.contains('رقم الهاتف') || 
               errorMessage.contains('The phone')) {
        errorType = RegisterErrorType.phoneAlreadyUsed;
      }
      else if (errorMessage.contains('الاهتمامات') || 
               errorMessage.contains('Interests')) {
        errorType = RegisterErrorType.validation;
      }
      
      emit(RegisterFailure(
        error: errorMessage.trim(),
        errorType: errorType,
      ));
    }
  } catch (error) {
    // معالجة الأخطاء من الـ Exception
    final errorStr = error.toString();
    final isArabic = errorStr.contains('العربية') || errorStr.contains('البريد');
    
    String translatedError = _translateErrorMessage(errorStr, isArabic);
    
    RegisterErrorType errorType = RegisterErrorType.general;
    
    if (translatedError.contains('البريد الإلكتروني') || 
        translatedError.contains('The email')) {
      errorType = RegisterErrorType.emailAlreadyUsed;
    } else if (translatedError.contains('رقم الهاتف') || 
               translatedError.contains('The phone')) {
      errorType = RegisterErrorType.phoneAlreadyUsed;
    }
    
    emit(RegisterFailure(
      error: translatedError,
      errorType: errorType,
    ));
  }
}
  String _translateErrorMessage(String error, bool isArabic) {
  print('🔍 Translating error: $error');
  
  if (isArabic) {
    if (error.contains('The email has already been taken') ||
        error.toLowerCase().contains('email') && 
        error.toLowerCase().contains('already')) {
      return 'البريد الإلكتروني مستخدم بالفعل. يرجى استخدام بريد إلكتروني آخر.';
    }
    
    if (error.contains('The phone has already been taken') ||
        error.toLowerCase().contains('phone') && 
        error.toLowerCase().contains('already')) {
      return 'رقم الهاتف مستخدم بالفعل. يرجى استخدام رقم هاتف آخر.';
    }
    
    if (error.contains('The interests field is required') ||
        error.toLowerCase().contains('interests')) {
      return 'الاهتمامات مطلوبة. يرجى اختيار 3 اهتمامات على الأقل.';
    }
    
    // الرسائل الأخرى بالعربية
    if (error.contains('validation')) {
      return 'خطأ في التحقق من البيانات. يرجى التأكد من صحة المعلومات المدخلة.';
    }
    
    if (error.toLowerCase().contains('timeout') || 
        error.toLowerCase().contains('connection')) {
      return 'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
    }
    
    return error.isNotEmpty ? error : 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  } else {
    // الإنجليزية
    if (error.contains('The email has already been taken') ||
        error.toLowerCase().contains('email') && 
        error.toLowerCase().contains('already')) {
      return 'The email has already been taken. Please use another email.';
    }
    
    if (error.contains('The phone has already been taken') ||
        error.toLowerCase().contains('phone') && 
        error.toLowerCase().contains('already')) {
      return 'The phone has already been taken. Please use another phone number.';
    }
    
    if (error.contains('The interests field is required') ||
        error.toLowerCase().contains('interests')) {
      return 'Interests are required. Please select at least 3 interests.';
    }
    
    // الرسائل الأخرى بالإنجليزية
    if (error.contains('validation')) {
      return 'Validation error. Please check your input data.';
    }
    
    if (error.toLowerCase().contains('timeout') || 
        error.toLowerCase().contains('connection')) {
      return 'Cannot connect to server. Please check your internet connection and try again.';
    }
    
    return error.isNotEmpty ? error : 'An unexpected error occurred. Please try again.';
  }
}
  
  void reset() {
    emit(RegisterInitial());
  }
}