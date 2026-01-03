import 'package:app_1/presentation/screens/main_app/create_bolt/cubits/telegram_state.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/repositories/telegram_repository.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/services/category_service.dart';
import 'package:flutter/material.dart';
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
    BuildContext? context,
  }) async {
    try {
      emit(TelegramCreating());
      
      final telegram = await _telegramRepository.createTelegram(
        content: content,
        categoryId: categoryId,
        isAd: isAd,
      );
      
      emit(TelegramCreated(telegram: telegram));
      
      // ✅ إعادة تعيين الحالة بعد 2 ثانية
      await Future.delayed(Duration(seconds: 2));
      emit(TelegramInitial());
      
    } catch (e) {
      emit(TelegramError(message: 'فشل في إنشاء البرقية: $e'));
    }
  }

  // ✅ دالة تحديث البرقية


  // ✅ دالة الحذف المعدلة
 Future<void> deleteTelegram(int telegramId) async {
    try {
      emit(TelegramDeleting());
      
      print('🗑️ TelegramCubit: Deleting telegram $telegramId');
      
      await _telegramRepository.deleteTelegram(telegramId);
      
      emit(TelegramDeleted(telegramId: telegramId));
      
      // ✅ إعادة تعيين الحالة بعد وقت قصير
      await Future.delayed(Duration(milliseconds: 300));
      emit(TelegramInitial());
      
    } catch (e) {
      print('❌ Error in deleteTelegram: $e');
      emit(TelegramError(message: 'فشل في حذف البرقية: $e'));
    }
  }

  // ✅ دالة حذف إعادة النشر
    Future<void> deleteRepost(int telegramId) async {
    try {
      emit(TelegramDeleting());
      
      await _telegramRepository.deleteRepost(telegramId);
      
      emit(TelegramDeleted(telegramId: telegramId));
      
      // إعادة تعيين الحالة بعد وقت قصير
      await Future.delayed(Duration(milliseconds: 300));
      emit(TelegramInitial());
      
    } catch (e) {
      emit(TelegramError(message: 'فشل في إزالة إعادة النشر: $e'));
    }
  }


  // ✅ دالة التبليغ

  // إعادة تعيين الحالة
  void resetState() {
    emit(TelegramInitial());
  }
}