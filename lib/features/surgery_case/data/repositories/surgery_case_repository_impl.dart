import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/surgery_case.dart';
import '../../domain/repositories/surgery_case_repository.dart';
import '../datasources/surgery_case_remote_datasource.dart';
import '../models/surgery_case_model.dart';

class SurgeryCaseRepositoryImpl implements SurgeryCaseRepository {
  final SurgeryCaseRemoteDataSource remoteDataSource;

  SurgeryCaseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SurgeryCase>>> getSurgeryCases({
    String? patientId,
  }) async {
    try {
      final models = await remoteDataSource.getSurgeryCases(
        patientId: patientId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SurgeryCase>> getSurgeryCaseById(String id) async {
    try {
      final model = await remoteDataSource.getSurgeryCaseById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SurgeryCase>> createSurgeryCase(
    SurgeryCase surgeryCase,
  ) async {
    try {
      final model = SurgeryCaseModel.fromEntity(surgeryCase);
      final created = await remoteDataSource.createSurgeryCase(model);
      return Right(created.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SurgeryCase>> updateSurgeryCase(
    SurgeryCase surgeryCase,
  ) async {
    try {
      final model = SurgeryCaseModel.fromEntity(surgeryCase);
      final updated = await remoteDataSource.updateSurgeryCase(model);
      return Right(updated.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSurgeryCase(String id) async {
    try {
      await remoteDataSource.deleteSurgeryCase(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SurgeryCase>>> getRecentCases({
    int limit = 5,
  }) async {
    try {
      final models = await remoteDataSource.getRecentCases(limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
