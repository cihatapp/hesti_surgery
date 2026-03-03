import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final DioClient dioClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.dioClient,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Save tokens
      await localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      // Set auth token for future requests
      dioClient.setAuthToken(result.accessToken);

      // Save user
      await localDataSource.saveUser(result.user);

      return Right(result.user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final result = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );

      // Save tokens
      await localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      // Set auth token for future requests
      dioClient.setAuthToken(result.accessToken);

      // Save user
      await localDataSource.saveUser(result.user);

      return Right(result.user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUser();
      if (user != null) {
        // Restore auth token
        final token = await localDataSource.getAccessToken();
        if (token != null) {
          dioClient.setAuthToken(token);
        }
      }
      return Right(user?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      // Call remote logout (best effort)
      await remoteDataSource.logout();

      // Clear local data
      await localDataSource.clearAll();

      // Clear auth token
      dioClient.clearAuthToken();

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      // Even if remote logout fails, we should clear local data
      try {
        await localDataSource.clearAll();
        dioClient.clearAuthToken();
      } catch (_) {}
      return const Right(unit);
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final token = await localDataSource.getAccessToken();
      return Right(token != null);
    } catch (_) {
      return const Right(false);
    }
  }
}
