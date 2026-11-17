import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

/// Traduce errores de Dio / HTTP a la jerarquía [AppFailure].
abstract final class ErrorMapper {
  static AppFailure fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      default:
        break;
    }

    final response = error.response;
    if (response == null) return const NetworkFailure();

    final code = _extractCode(response.data);
    return switch (response.statusCode) {
      401 || 403 => UnauthorizedFailure(code: code ?? 'UNAUTHORIZED'),
      409 => ConflictFailure(code: code ?? 'CONFLICT'),
      429 => RateLimitFailure(
        code: code ?? 'RATE_LIMIT_EXCEEDED',
        retryAfterSeconds: int.tryParse(
          response.headers.value('retry-after') ?? '',
        ),
      ),
      final int s when s >= 500 => ServerFailure(code: code ?? 'SERVER_ERROR'),
      _ => UnknownFailure(code: code ?? 'UNKNOWN', originalException: error),
    };
  }

  /// Lee el campo `code` si el backend lo envía (CoVE #4 aún abierto).
  static String? _extractCode(Object? data) {
    if (data is Map && data['code'] is String) return data['code'] as String;
    return null;
  }
}
