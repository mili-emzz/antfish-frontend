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

/// Resultado de un intento de login con Google.
sealed class GoogleSignInResult {
  const GoogleSignInResult();
}

final class GoogleSignInSuccess extends GoogleSignInResult {
  const GoogleSignInSuccess();
}

final class GoogleSignInCancelled extends GoogleSignInResult {
  const GoogleSignInCancelled();
}

final class GoogleSignInUnavailable extends GoogleSignInResult {
  const GoogleSignInUnavailable();
}

final class GoogleSignInError extends GoogleSignInResult {
  const GoogleSignInError(this.message);
  final String message;
}

/// Orquesta Google Sign-In + backend + sesión. Compartido por Login y Registro.
Future<GoogleSignInResult> runGoogleSignIn(BuildContext context) async {
  final scope = AuthScope.maybeOf(context);
  final repository = scope?.repository;
  if (scope == null || repository == null) {
    return const GoogleSignInUnavailable();
  }

  try {
    final session = await repository.signInWithGoogle();
    if (session == null) return const GoogleSignInCancelled();
    await scope.session.signIn(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userEmail: session.email,
      authProvider: session.proveedorAuth,
    );
    return const GoogleSignInSuccess();
  } on ConflictFailure {
    return const GoogleSignInError(AppStrings.googleEmailNotVerified);
  } on UnauthorizedFailure {
    return const GoogleSignInError(AppStrings.googleInvalidCredential);
  } on AppFailure catch (f) {
    return GoogleSignInError(f.message);
  } catch (_) {
    return const GoogleSignInError(AppStrings.googleGenericError);
  }
}
