import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<AuthResponse> register({
    required String email,
    required String password,
    String? name,
  });

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        },
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post<void>(ApiConstants.logout);
    } catch (_) {
      // Ignore logout errors - we'll clear local data anyway
    }
  }
}
