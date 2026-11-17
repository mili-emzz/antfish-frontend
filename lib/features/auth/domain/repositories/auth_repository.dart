import '../models/auth_session.dart';
import '../models/register_result.dart';

/// Contrato del repositorio de autenticación.
///
/// Todos los métodos lanzan una subclase de `AppFailure` ante errores de red
/// o del backend, y nunca reintentan automáticamente.
abstract interface class AuthRepository {
  /// Registro local (`POST /auth/register`). La cuenta queda pendiente de
  /// verificación por correo.
  Future<RegisterResult> register({
    required String email,
    required String password,
    required String nombre,
  });

  /// Verifica el código de 6 dígitos enviado al correo (`POST /auth/verify-email`).
  /// Devuelve el mensaje de confirmación del servidor.
  Future<String> verifyEmail({required String email, required String code});

  /// Solicita el reenvío del código de 6 dígitos (`POST /auth/resend-code`).
  /// Máximo 3 envíos por hora por cuenta.
  Future<String> resendCode({required String email});

  /// Login local (`POST /auth/login`). Lanza `AccountNotVerifiedFailure` si la
  /// cuenta aún no verifica su correo (HTTP 403).
  Future<AuthSession> login({required String email, required String password});

  /// Inicia sesión / se registra con Google (RF-06.4).
  ///
  /// Devuelve `null` si el usuario cancela el selector de cuentas.
  Future<AuthSession?> signInWithGoogle();
}
