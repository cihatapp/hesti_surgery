import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class SearchPatients extends UseCase<List<Patient>, String> {
  final PatientRepository repository;

  SearchPatients(this.repository);

  @override
  Future<Either<Failure, List<Patient>>> call(String params) {
    return repository.searchPatients(params);
  }
}
