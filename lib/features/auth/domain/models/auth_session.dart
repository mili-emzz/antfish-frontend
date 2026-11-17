import 'package:flutter/foundation.dart';

/// Tokens y datos básicos devueltos por el backend tras autenticarse.
@immutable
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    this.email,
    this.nombre,
    this.proveedorAuth = 'google',
  });

  final String accessToken;
  final String refreshToken;
  final String? email;
  final String? nombre;
  final String proveedorAuth; // 'local' | 'google'
}
