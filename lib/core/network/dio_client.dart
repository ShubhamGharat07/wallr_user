import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/exceptions.dart';

/// WALLR — Dio HTTP Client
///
/// Pre-configured [Dio] instance with:
///   - Base URL from env (for non-Firebase REST calls, e.g. Cloudinary upload API)
///   - Auth token interceptor (attaches Firebase ID token)
///   - Logging interceptor (debug only)
///   - Error mapping interceptor (DioException → WallrException)
///   - Timeouts: connect 10s, receive 30s, send 30s
///
/// Usage:
///   final dio = sl<Dio>();  // from GetIt
///   final response = await dio.get('/endpoint');

class DioClient {
  late final Dio _dio;

  DioClient({String baseUrl = ''}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      if (kDebugMode) _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}

// ─── Auth Interceptor ─────────────────────────────────────────────────────

/// Attaches Firebase ID token to every request.
/// Token is fetched fresh on every call — Firebase handles caching internally.
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Token injection will be wired up once Firebase Auth is initialized.
    // Placeholder — uncomment when FirebaseAuth.instance is available:
    //
    // try {
    //   final user = FirebaseAuth.instance.currentUser;
    //   if (user != null) {
    //     final token = await user.getIdToken();
    //     options.headers['Authorization'] = 'Bearer $token';
    //   }
    // } catch (_) {}

    return handler.next(options);
  }
}

// ─── Logging Interceptor ──────────────────────────────────────────────────

/// Debug-only request/response logger.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[DIO] ➡ ${options.method} ${options.uri}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[DIO] ✅ ${response.statusCode} ${response.requestOptions.uri}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[DIO] ❌ ${err.type} — ${err.message}');
    return handler.next(err);
  }
}

// ─── Error Interceptor ────────────────────────────────────────────────────

/// Maps [DioException] types to WALLR custom exceptions.
/// Repositories catch these and convert to [Failure] objects.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const TimeoutException(message: 'Request timed out.');

      case DioExceptionType.connectionError:
        throw const NetworkException(message: 'No internet connection.');

      case DioExceptionType.badResponse:
        throw ServerException(
          message: err.response?.statusMessage ?? 'Server error.',
          statusCode: err.response?.statusCode,
        );

      default:
        throw ServerException(message: err.message ?? 'Unexpected error.');
    }
  }
}
