import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/surgery_case.dart';
import '../repositories/surgery_case_repository.dart';

class UpdateSurgeryCase extends UseCase<SurgeryCase, SurgeryCase> {
  final SurgeryCaseRepository repository;

  UpdateSurgeryCase(this.repository);

  @override
  Future<Either<Failure, SurgeryCase>> call(SurgeryCase params) {
    return repository.updateSurgeryCase(params);
  }
}
