import 'package:flutter/foundation.dart';

/// Jerarquía sellada que representa el estado reactivo de sesión de AntFish.
@immutable
sealed class SessionState {
  const SessionState();
}

/// Estado inicial mientras se verifica la persistencia de tokens en arranque en frío.
final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

/// Usuario sin sesión activa (pantalla de Login / Registro).
final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

/// Usuario registrado pendiente de verificar código de correo de 6 dígitos.
final class SessionPendingVerification extends SessionState {
  const SessionPendingVerification({required this.email});

  final String email;
}

/// Usuario autenticado con token JWT válido en memoria.
final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated({
    required this.accessToken,
    this.userEmail,
    this.authProvider = 'local',
  });

  final String accessToken;
  final String? userEmail;
  final String authProvider;
}
