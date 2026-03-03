import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Base UseCase interface with Either pattern
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use when no parameters needed
class NoParams {
  const NoParams();
}
