
abstract class VerificationState  {
  const VerificationState();

  @override
  List<Object> get props => [];
}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {
  final String message;

  const VerificationLoading({this.message = 'جاري المعالجة...'});

  @override
  List<Object> get props => [message];
}

class VerificationRequested extends VerificationState {
  final String message;

  const VerificationRequested({required this.message});

  @override
  List<Object> get props => [message];
}

class VerificationSuccess extends VerificationState {
  final String message;
  final Map<String, dynamic>? data;

  const VerificationSuccess({required this.message, this.data});

  @override
  List<Object> get props => [message];
}

class VerificationError extends VerificationState {
  final String error;

  const VerificationError({required this.error});

  @override
  List<Object> get props => [error];
}