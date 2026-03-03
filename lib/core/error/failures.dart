import 'package:equatable/equatable.dart';

/// High-level failures - used in BLoCs via Either pattern
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    String message = 'Server error occurred',
    this.statusCode,
  }) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache error'}) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'No internet connection'})
      : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure({String message = 'Validation error'})
      : super(message);
}
