import 'package:flutter/foundation.dart';

/// Jerarquía sellada de fallos de la aplicación AntFish.
/// Espejo del catálogo de errores del backend (`AntFishError`).
@immutable
sealed class AppFailure {
  const AppFailure({required this.message, this.code});

  final String message;
  final String? code;
}

/// Fallo de red (timeout de conexión o sin acceso a internet).
final class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.message =
        'No se pudo conectar con el servidor. Revisa tu conexión a internet.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Fallo de autenticación o token revocado / inválido (HTTP 401).
final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({
    super.message = 'Credenciales inválidas o sesión expirada.',
    super.code = 'UNAUTHORIZED',
  });
}

/// Cuenta pendiente de verificación de correo (HTTP 403 con código ACCOUNT_NOT_VERIFIED).
final class AccountNotVerifiedFailure extends AppFailure {
  const AccountNotVerifiedFailure({
    required this.email,
    super.message = 'Tu cuenta aún no ha sido verificada. Ingresa el código enviado a tu correo.',
    super.code = 'ACCOUNT_NOT_VERIFIED',
  });

  final String email;
}

/// Conflicto de recurso, ej. correo ya registrado (HTTP 409).
final class ConflictFailure extends AppFailure {
  const ConflictFailure({
    super.message = 'El correo electrónico ya se encuentra registrado.',
    super.code = 'CONFLICT',
  });
}

/// Límite de tasa alcanzado (HTTP 429).
final class RateLimitFailure extends AppFailure {
  const RateLimitFailure({
    super.message = 'Has alcanzado el límite de intentos. Por favor espera antes de reintentar.',
    super.code = 'RATE_LIMIT_EXCEEDED',
    this.retryAfterSeconds,
  });

  final int? retryAfterSeconds;
}

/// Error del servidor o dependencias externas no disponibles (HTTP 500 / 503).
final class ServerFailure extends AppFailure {
  const ServerFailure({
    super.message =
        'Servicio temporalmente no disponible. Inténtalo más tarde.',
    super.code = 'SERVER_ERROR',
  });
}

/// Error imprevisto o genérico.
final class UnknownFailure extends AppFailure {
  const UnknownFailure({
    super.message = 'Ocurrió un error inesperado.',
    super.code = 'UNKNOWN',
    this.originalException,
  });

  final Object? originalException;
}
