import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_app_boilerplate/core/error/failures.dart';
import 'package:flutter_app_boilerplate/features/auth/domain/entities/user.dart';
import 'package:flutter_app_boilerplate/features/auth/domain/usecases/login_user.dart';

import '../../../../mocks/mocks.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late LoginUser usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUser(mockRepository);
  });

  setUpAll(() {
    registerFallbackValues();
  });

  final tUser = TestData.testUser;
  const tParams = LoginParams(
    email: 'test@example.com',
    password: 'password123',
  );

  group('LoginUser', () {
    test('should return User when login is successful', () async {
      // Arrange
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right<Failure, User>(tUser));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, equals(Right<Failure, User>(tUser)));
      verify(() => mockRepository.login(
            email: tParams.email,
            password: tParams.password,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when login fails', () async {
      // Arrange
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left<Failure, User>(ServerFailure(message: 'Login failed')));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left<Failure, User>(ServerFailure(message: 'Login failed')));
      verify(() => mockRepository.login(
            email: tParams.email,
            password: tParams.password,
          )).called(1);
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
              (_) async => const Left<Failure, User>(NetworkFailure(message: 'No internet connection')));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left<Failure, User>(NetworkFailure(message: 'No internet connection')));
    });
  });
}
