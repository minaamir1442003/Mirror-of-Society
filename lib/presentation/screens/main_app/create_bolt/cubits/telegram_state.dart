
import 'package:app_1/presentation/screens/main_app/create_bolt/models/telegram_m.dart';

abstract class TelegramState  {
  const TelegramState();

  @override
  List<Object> get props => [];
}

class TelegramInitial extends TelegramState {}

class TelegramLoading extends TelegramState {}

class TelegramCreating extends TelegramState {}

class TelegramUpdating extends TelegramState {}

class TelegramDeleting extends TelegramState {}

class CategoriesLoaded extends TelegramState {
  final List<CategoryModel> categories; // عدّل هنا من Categors إلى CategoryModel
  
  const CategoriesLoaded({required this.categories});
  
  @override
  List<Object> get props => [categories];
}

class TelegramCreated extends TelegramState {
  final Telegram telegram;
  
  const TelegramCreated({required this.telegram});
  
  @override
  List<Object> get props => [telegram];
}

class TelegramUpdated extends TelegramState {
  final Telegram telegram;
  
  const TelegramUpdated({required this.telegram});
  
  @override
  List<Object> get props => [telegram];
}

class TelegramDeleted extends TelegramState {
  final int telegramId;
  
  const TelegramDeleted({required this.telegramId});
  
  @override
  List<Object> get props => [telegramId];
}

class TelegramError extends TelegramState {
  final String message;
  
  const TelegramError({required this.message});
  
  @override
  List<Object> get props => [message];
}