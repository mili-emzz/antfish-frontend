import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

/// Traduce errores de Dio / HTTP a la jerarquía [AppFailure].
///
/// El backend responde con `{"code": "...", "detail": "..."}`
/// según `docs/contrato_api_v2.md`.
abstract final class ErrorMapper {
  /// Código que indica cuenta sin verificar (HTTP 403 en login o análisis).
  static const String accountNotVerifiedCode = 'ACCOUNT_NOT_VERIFIED';

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
    final detail = extractDetailMessage(response.data);

    return switch (response.statusCode) {
      400 || 422 => ValidationFailure(
        message:
            detail ??
            'Los datos enviados no son válidos. Revisa el formulario.',
        code: code ?? 'VALIDATION_ERROR',
      ),
      401 || 403 => UnauthorizedFailure(
        message: detail ?? 'Credenciales inválidas o sesión expirada.',
        code: code ?? 'UNAUTHORIZED',
      ),
      404 => NotFoundFailure(
        message: detail ?? 'El recurso solicitado no fue encontrado.',
        code: code ?? 'NOT_FOUND',
      ),
      409 => ConflictFailure(
        message: detail ?? 'El correo electrónico ya se encuentra registrado.',
        code: code ?? 'CONFLICT',
      ),
      429 => RateLimitFailure(
        message: detail ?? 'Has alcanzado el límite de intentos. Por favor espera antes de reintentar.',
        code: code ?? 'RATE_LIMIT_EXCEEDED',
        retryAfterSeconds: int.tryParse(
          response.headers.value('retry-after') ?? '',
        ),
      ),
      final int s when s >= 500 => ServerFailure(
        message:
            detail ??
            'Servicio temporalmente no disponible. Inténtalo más tarde.',
        code: code ?? 'SERVER_ERROR',
      ),
      _ => UnknownFailure(
        message: detail ?? 'Ocurrió un error inesperado.',
        code: code ?? 'UNKNOWN',
        originalException: error,
      ),
    };
  }

  /// `true` si la respuesta es un 403 con `ACCOUNT_NOT_VERIFIED`.
  static bool isAccountNotVerified(DioException error) {
    final response = error.response;
    return response?.statusCode == 403 &&
        extractCode(response?.data) == accountNotVerifiedCode;
  }

  /// Extrae `code` (o `detail` si coincide con `ACCOUNT_NOT_VERIFIED`).
  static String? extractCode(Object? data) {
    if (data is! Map) return null;
    if (data['code'] is String) return data['code'] as String;
    final detail = data['detail'];
    if (detail is String && detail == accountNotVerifiedCode) return detail;
    return null;
  }

  /// Extrae `detail` cuando es un mensaje de texto o lista de errores de FastAPI.
  static String? extractDetailMessage(Object? data) {
    if (data is! Map) return null;
    final detail = data['detail'];
    if (detail is String &&
        detail.trim().isNotEmpty &&
        detail != accountNotVerifiedCode) {
      return detail.trim();
    }
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] is String) {
        final msg = (first['msg'] as String).trim();
        if (msg.isNotEmpty) return msg;
      } else if (first is String && first.trim().isNotEmpty) {
        return first.trim();
      }
    }
    return null;
  }
}
