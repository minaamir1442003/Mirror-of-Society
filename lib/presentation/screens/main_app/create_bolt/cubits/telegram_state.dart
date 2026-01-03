import 'package:app_1/presentation/screens/main_app/create_bolt/models/telegram_m.dart';

abstract class TelegramState {
  const TelegramState();
}

class TelegramInitial extends TelegramState {}

class TelegramLoading extends TelegramState {}

class TelegramCreating extends TelegramState {}

class TelegramUpdating extends TelegramState {}

class TelegramDeleting extends TelegramState {}

class TelegramReporting extends TelegramState {}

class CategoriesLoaded extends TelegramState {
  final List<CategoryModel> categories;
  
  const CategoriesLoaded({required this.categories});
}

class TelegramCreated extends TelegramState {
  final Telegram telegram;
  
  const TelegramCreated({required this.telegram});
}

class TelegramUpdated extends TelegramState {
  final Telegram telegram;
  
  const TelegramUpdated({required this.telegram});
}

// ✅ إضافة معامل telegramId هنا
class TelegramDeleted extends TelegramState {
  final int telegramId;
  
  const TelegramDeleted({required this.telegramId});
}

// ✅ إضافة معامل telegramId هنا
class TelegramReported extends TelegramState {
  final int telegramId;
  
  const TelegramReported({required this.telegramId});
}

class TelegramError extends TelegramState {
  final String message;
  
  const TelegramError({required this.message});
}