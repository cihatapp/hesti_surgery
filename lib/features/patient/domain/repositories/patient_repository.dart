import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/patient.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<Patient>>> getPatients();
  Future<Either<Failure, Patient>> getPatientById(String id);
  Future<Either<Failure, Patient>> createPatient(Patient patient);
  Future<Either<Failure, Patient>> updatePatient(Patient patient);
  Future<Either<Failure, Unit>> deletePatient(String id);
  Future<Either<Failure, List<Patient>>> searchPatients(String query);
}
