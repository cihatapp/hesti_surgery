import '../../../../core/cache/cache_keys.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  });

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> saveUser(UserModel user);

  Future<UserModel?> getUser();

  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final CacheManager cacheManager;

  AuthLocalDataSourceImpl({required this.cacheManager});

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await cacheManager.setString(CacheKeys.accessToken, accessToken);
      if (refreshToken != null) {
        await cacheManager.setString(CacheKeys.refreshToken, refreshToken);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to save tokens: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return cacheManager.getString(CacheKeys.accessToken);
    } catch (e) {
      throw CacheException(message: 'Failed to get access token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return cacheManager.getString(CacheKeys.refreshToken);
    } catch (e) {
      throw CacheException(message: 'Failed to get refresh token: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await cacheManager.setObject(CacheKeys.user, user);
    } catch (e) {
      throw CacheException(message: 'Failed to save user: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      return cacheManager.getObject(
        CacheKeys.user,
        UserModel.fromJson,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to get user: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await cacheManager.remove(CacheKeys.accessToken);
      await cacheManager.remove(CacheKeys.refreshToken);
      await cacheManager.remove(CacheKeys.user);
    } catch (e) {
      throw CacheException(message: 'Failed to clear auth data: $e');
    }
  }
}
