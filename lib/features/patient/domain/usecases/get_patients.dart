import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class GetPatients extends UseCase<List<Patient>, NoParams> {
  final PatientRepository repository;

  GetPatients(this.repository);

  @override
  Future<Either<Failure, List<Patient>>> call(NoParams params) {
    return repository.getPatients();
  }
}
