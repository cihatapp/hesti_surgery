import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/surgery_case.dart';
import '../repositories/surgery_case_repository.dart';

class GetSurgeryCases extends UseCase<List<SurgeryCase>, GetSurgeryCasesParams> {
  final SurgeryCaseRepository repository;

  GetSurgeryCases(this.repository);

  @override
  Future<Either<Failure, List<SurgeryCase>>> call(GetSurgeryCasesParams params) {
    return repository.getSurgeryCases(patientId: params.patientId);
  }
}

class GetSurgeryCasesParams {
  final String? patientId;
  const GetSurgeryCasesParams({this.patientId});
}
