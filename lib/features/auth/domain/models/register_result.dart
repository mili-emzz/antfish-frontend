import 'package:flutter/foundation.dart';

/// Respuesta `201 Created` de `POST /api/v1/auth/register`.
@immutable
class RegisterResult {
  const RegisterResult({
    required this.id,
    required this.email,
    required this.estadoCuenta,
    required this.emailVerificado,
    this.nombre,
    this.mensaje,
  });

  final String id;
  final String email;
  final String? nombre;
  final String estadoCuenta; // 'pendiente_verificacion'
  final bool emailVerificado;
  final String? mensaje;
}
