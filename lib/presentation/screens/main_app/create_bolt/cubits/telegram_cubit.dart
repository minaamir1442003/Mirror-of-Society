

import 'package:app_1/presentation/screens/main_app/create_bolt/cubits/telegram_state.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/repositories/telegram_repository.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/services/category_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TelegramCubit extends Cubit<TelegramState> {
  final TelegramRepository _telegramRepository;
  final CategoryService _categoryService;

  TelegramCubit({
    required TelegramRepository telegramRepository,
    required CategoryService categoryService,
  })  : _telegramRepository = telegramRepository,
        _categoryService = categoryService,
        super(TelegramInitial());

  // جلب الفئات
  Future<void> loadCategories({bool forceRefresh = false}) async {
    try {
      emit(TelegramLoading());
      final categories = await _categoryService.getCategories(
        forceRefresh: forceRefresh,
      );
      emit(CategoriesLoaded(categories: categories));
    } catch (e) {
      emit(TelegramError(message: 'فشل في تحميل الفئات: $e'));
    }
  }

  // إنشاء برقية جديدة
  Future<void> createTelegram({
    required String content,
    required int categoryId,
    bool isAd = false,
  }) async {
    try {
      emit(TelegramCreating());
      
      final telegram = await _telegramRepository.createTelegram(
        content: content,
        categoryId: categoryId,
        isAd: isAd,
      );
      
      emit(TelegramCreated(telegram: telegram));
      
      // إعادة تعيين الحالة بعد 2 ثانية للعودة للشاشة الرئيسية
      await Future.delayed(Duration(seconds: 2));
      emit(TelegramInitial());
      
    } catch (e) {
      emit(TelegramError(message: 'فشل في إنشاء البرقية: $e'));
    }
  }

  // تحديث برقية
  Future<void> updateTelegram({
    required int telegramId,
    String? content,
    int? categoryId,
    bool? isAd,
  }) async {
    try {
      emit(TelegramUpdating());
      
      final telegram = await _telegramRepository.updateTelegram(
        telegramId: telegramId,
        content: content,
        categoryId: categoryId,
        isAd: isAd,
      );
      
      emit(TelegramUpdated(telegram: telegram));
      
      // إعادة تعيين الحالة
      await Future.delayed(Duration(seconds: 2));
      emit(TelegramInitial());
      
    } catch (e) {
      emit(TelegramError(message: 'فشل في تحديث البرقية: $e'));
    }
  }

  // حذف برقية
  Future<void> deleteTelegram(int telegramId) async {
    try {
      emit(TelegramDeleting());
      
      final success = await _telegramRepository.deleteTelegram(telegramId);
      
      if (success) {
        emit(TelegramDeleted(telegramId: telegramId));
      } else {
        emit(TelegramError(message: 'فشل في حذف البرقية'));
      }
      
      // إعادة تعيين الحالة
      await Future.delayed(Duration(seconds: 2));
      emit(TelegramInitial());
      
    } catch (e) {
      emit(TelegramError(message: 'فشل في حذف البرقية: $e'));
    }
  }

  // إعادة تعيين الحالة
  void resetState() {
    emit(TelegramInitial());
  }
}