import 'package:flutter/widgets.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/session/session_controller.dart';
import '../../../l10n/app_strings.dart';
import '../domain/repositories/auth_repository.dart';

/// Provee dependencias de autenticación al árbol de widgets.
class AuthScope extends InheritedWidget {
  const AuthScope({
    super.key,
    required this.repository,
    required this.session,
    required super.child,
  });

  final AuthRepository? repository;
  final SessionController session;

  static AuthScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>();

  @override
  bool updateShouldNotify(AuthScope old) =>
      repository != old.repository || session != old.session;
}

/// Resultado de un intento de autenticación (Google o login local).
sealed class AuthAttemptResult {
  const AuthAttemptResult();
}

/// Sesión iniciada; se debe navegar al shell principal.
final class AuthSuccess extends AuthAttemptResult {
  const AuthSuccess();
}

/// El usuario canceló el selector de Google; no se muestra nada.
final class AuthCancelled extends AuthAttemptResult {
  const AuthCancelled();
}

/// No hay repositorio inyectado (modo plantilla).
final class AuthUnavailable extends AuthAttemptResult {
  const AuthUnavailable();
}

/// Cuenta pendiente de verificar (login 403 o registro 201).
final class AuthNeedsVerification extends AuthAttemptResult {
  const AuthNeedsVerification(this.email);
  final String email;
}

final class AuthError extends AuthAttemptResult {
  const AuthError(this.message);
  final String message;
}

/// Orquesta Google Sign-In + backend + sesión. Compartido por Login y Registro.
Future<AuthAttemptResult> runGoogleSignIn(BuildContext context) async {
  final scope = AuthScope.maybeOf(context);
  final repository = scope?.repository;
  if (scope == null || repository == null) return const AuthUnavailable();

  try {
    final session = await repository.signInWithGoogle();
    if (session == null) return const AuthCancelled();
    await scope.session.signIn(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userEmail: session.email,
      authProvider: session.proveedorAuth,
    );
    return const AuthSuccess();
  } on ConflictFailure {
    return const AuthError(AppStrings.googleEmailNotVerified);
  } on UnauthorizedFailure {
    return const AuthError(AppStrings.googleInvalidCredential);
  } on AppFailure catch (f) {
    return AuthError(f.message);
  } catch (_) {
    return const AuthError(AppStrings.googleGenericError);
  }
}

/// Login local (`POST /auth/login`).
Future<AuthAttemptResult> runLogin(
  BuildContext context, {
  required String email,
  required String password,
}) async {
  final scope = AuthScope.maybeOf(context);
  final repository = scope?.repository;
  if (scope == null || repository == null) return const AuthUnavailable();

  try {
    final session = await repository.login(email: email, password: password);
    await scope.session.signIn(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userEmail: session.email,
      authProvider: session.proveedorAuth,
    );
    return const AuthSuccess();
  } on AccountNotVerifiedFailure catch (f) {
    scope.session.markPendingVerification(f.email);
    return AuthNeedsVerification(f.email);
  } on AppFailure catch (f) {
    return AuthError(f.message);
  } catch (_) {
    return const AuthError(AppStrings.authGenericError);
  }
}

/// Registro local (`POST /auth/register`). Éxito → pendiente de verificación.
Future<AuthAttemptResult> runRegister(
  BuildContext context, {
  required String email,
  required String password,
  required String nombre,
}) async {
  final scope = AuthScope.maybeOf(context);
  final repository = scope?.repository;
  if (scope == null || repository == null) return const AuthUnavailable();

  try {
    final result = await repository.register(
      email: email,
      password: password,
      nombre: nombre,
    );
    scope.session.markPendingVerification(result.email);
    return AuthNeedsVerification(result.email);
  } on AppFailure catch (f) {
    return AuthError(f.message);
  } catch (_) {
    return const AuthError(AppStrings.authGenericError);
  }
}
