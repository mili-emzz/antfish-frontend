import 'package:flutter/foundation.dart';

/// Modelo de dominio inmutable para el usuario autenticado.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.estadoCuenta,
    required this.proveedorAuth,
    this.nombre,
  });

  final String id;
  final String email;
  final String estadoCuenta; // 'pendiente_verificacion' | 'activa' | 'suspendida' | 'eliminada'
  final String proveedorAuth; // 'local' | 'google'
  final String? nombre;
}
