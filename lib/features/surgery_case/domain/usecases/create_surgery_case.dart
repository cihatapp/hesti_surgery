import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/surgery_case.dart';
import '../repositories/surgery_case_repository.dart';

class CreateSurgeryCase extends UseCase<SurgeryCase, SurgeryCase> {
  final SurgeryCaseRepository repository;

  CreateSurgeryCase(this.repository);

  @override
  Future<Either<Failure, SurgeryCase>> call(SurgeryCase params) {
    return repository.createSurgeryCase(params);
  }
}
