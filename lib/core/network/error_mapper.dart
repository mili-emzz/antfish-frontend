import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

/// Traduce errores de Dio / HTTP a la jerarquía [AppFailure].
///
/// El backend (FastAPI) responde errores como `{"detail": "..."}`
/// (docs/contrato_api.md). Si algún día envía también `code`, se prefiere.
abstract final class ErrorMapper {
  /// Valor de `detail` que indica cuenta sin verificar (HTTP 403 en login).
  static const String accountNotVerifiedDetail = 'ACCOUNT_NOT_VERIFIED';

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

    final code = extractCode(response.data);
    return switch (response.statusCode) {
      400 || 422 => ValidationFailure(code: code ?? 'VALIDATION_ERROR'),
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

  /// `true` si la respuesta es un 403 con `detail == ACCOUNT_NOT_VERIFIED`.
  static bool isAccountNotVerified(DioException error) {
    final response = error.response;
    return response?.statusCode == 403 &&
        extractCode(response?.data) == accountNotVerifiedDetail;
  }

  /// Lee `code` o, si no existe, `detail` cuando es una cadena corta de código.
  static String? extractCode(Object? data) {
    if (data is! Map) return null;
    if (data['code'] is String) return data['code'] as String;
    final detail = data['detail'];
    if (detail is String && detail == accountNotVerifiedDetail) return detail;
    return null;
  }
}
