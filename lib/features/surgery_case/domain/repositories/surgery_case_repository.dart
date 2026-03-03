import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/surgery_case.dart';

abstract class SurgeryCaseRepository {
  Future<Either<Failure, List<SurgeryCase>>> getSurgeryCases({String? patientId});
  Future<Either<Failure, SurgeryCase>> getSurgeryCaseById(String id);
  Future<Either<Failure, SurgeryCase>> createSurgeryCase(SurgeryCase surgeryCase);
  Future<Either<Failure, SurgeryCase>> updateSurgeryCase(SurgeryCase surgeryCase);
  Future<Either<Failure, Unit>> deleteSurgeryCase(String id);
  Future<Either<Failure, List<SurgeryCase>>> getRecentCases({int limit = 5});
}
