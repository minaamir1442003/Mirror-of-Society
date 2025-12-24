import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/repositories/verification_repository.dart';
import 'verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  final VerificationRepository _verificationRepository;

  VerificationCubit({required VerificationRepository verificationRepository})
      : _verificationRepository = verificationRepository,
        super(VerificationInitial());

  // طلب رمز التحقق
  Future<void> requestVerification() async {
    emit(VerificationLoading(message: 'جاري إرسال رمز التحقق...'));

    final result = await _verificationRepository.requestVerification();

    if (result['status'] == true) {
      final message = result['data']['message'] ?? 'تم إرسال رمز التحقق إلى بريدك الإلكتروني';
      emit(VerificationRequested(message: message));
    } else {
      emit(VerificationError(error: result['error']));
    }
  }

  // التحقق من الرمز
  Future<void> verifyAccount(String code) async {
    if (code.isEmpty || code.length != 6) {
      emit(VerificationError(error: 'يرجى إدخال رمز تحقق صحيح مكون من 6 أرقام'));
      return;
    }

    emit(VerificationLoading(message: 'جاري التحقق من الرمز...'));

    final result = await _verificationRepository.verifyAccount(code);

    if (result['status'] == true) {
      final message = result['data']['message'] ?? 'تم تفعيل حسابك بنجاح';
      emit(VerificationSuccess(message: message, data: result['data']));
    } else {
      emit(VerificationError(error: result['error']));
    }
  }

  // إعادة التعيين
  void reset() {
    emit(VerificationInitial());
  }
}