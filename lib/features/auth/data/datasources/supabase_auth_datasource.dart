import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/supabase/supabase_constants.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class SupabaseAuthDataSource implements AuthRemoteDataSource {
  final SupabaseClient client;

  SupabaseAuthDataSource({required this.client});

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerException(message: 'Login failed: no user returned');
      }

      // Fetch surgeon profile
      final profile = await _fetchProfile(response.user!.id);

      final userModel = UserModel.fromSupabaseUser(
        response.user!,
        profile: profile,
      );

      return AuthResponseModel(
        user: userModel,
        accessToken: response.session?.accessToken ?? '',
        refreshToken: response.session?.refreshToken,
      );
    } on AuthException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Login failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': ?name,
        },
      );

      if (response.user == null) {
        throw const ServerException(
          message: 'Registration failed: no user returned',
        );
      }

      // Profile is auto-created by the DB trigger
      final profile = await _fetchProfile(response.user!.id);

      final userModel = UserModel.fromSupabaseUser(
        response.user!,
        profile: profile,
      );

      return AuthResponseModel(
        user: userModel,
        accessToken: response.session?.accessToken ?? '',
        refreshToken: response.session?.refreshToken,
      );
    } on AuthException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } catch (_) {
      // Best-effort logout
    }
  }

  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    try {
      final data = await client
          .from(SupabaseConstants.surgeonProfilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }
}
