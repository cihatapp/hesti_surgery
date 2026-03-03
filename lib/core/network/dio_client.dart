import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../error/exceptions.dart';

class DioClient {
  DioClient._internal();
  static DioClient? _instance;

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  factory DioClient() => instance;

  late final Dio _dio = _createDio();

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(_LoggingInterceptor());
    }
    dio.interceptors.add(_ErrorInterceptor());

    return dio;
  }

  // Set auth token
  void setAuthToken(String token) {
    _dio.options.headers[ApiConstants.authorization] =
        '${ApiConstants.bearer} $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove(ApiConstants.authorization);
  }

  // HTTP Methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'Connection timed out');
      case DioExceptionType.connectionError:
        return const NetworkException(message: 'No internet connection');
      case DioExceptionType.badResponse:
        return ServerException(
          message: _extractErrorMessage(error.response),
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const ServerException(message: 'Request cancelled');
      default:
        return ServerException(message: error.message ?? 'Unknown error');
    }
  }

  String _extractErrorMessage(Response<dynamic>? response) {
    if (response?.data == null) return 'Server error';
    try {
      final data = response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        final error = data['error'];
        if (message is String) return message;
        if (error is String) return error;
        return 'Server error';
      }
      return 'Server error';
    } catch (_) {
      return 'Server error';
    }
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌────────────────────────────────────────────────');
    debugPrint('│ 🌐 REQUEST: ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('│ Body: ${options.data}');
    }
    debugPrint('└────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint('┌────────────────────────────────────────────────');
    debugPrint('│ ✅ RESPONSE: ${response.statusCode}');
    debugPrint('│ Data: ${response.data}');
    debugPrint('└────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌────────────────────────────────────────────────');
    debugPrint('│ ❌ ERROR: ${err.type}');
    debugPrint('│ Message: ${err.message}');
    debugPrint('│ Response: ${err.response?.data}');
    debugPrint('└────────────────────────────────────────────────');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 - Token expired
    if (err.response?.statusCode == 401) {
      // Trigger logout or token refresh
      // This can be handled by the auth bloc or a dedicated service
      debugPrint('Token expired - triggering logout');
    }
    handler.next(err);
  }
}
