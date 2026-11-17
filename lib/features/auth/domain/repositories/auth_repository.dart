import '../models/auth_session.dart';

/// Contrato del repositorio de autenticación.
abstract interface class AuthRepository {
  /// Inicia sesión con Google (RF-06.4).
  ///
  /// Devuelve `null` si el usuario cancela el selector de cuentas.
  /// Lanza una subclase de `AppFailure` ante errores de red o del backend.
  Future<AuthSession?> signInWithGoogle();
}
