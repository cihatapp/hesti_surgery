import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class UpdatePatient extends UseCase<Patient, Patient> {
  final PatientRepository repository;

  UpdatePatient(this.repository);

  @override
  Future<Either<Failure, Patient>> call(Patient params) {
    return repository.updatePatient(params);
  }
}
