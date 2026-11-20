import 'package:flutter/foundation.dart';

/// Modelo de dominio para las métricas acumuladas del usuario
/// (`GET /api/v1/metrics/me` en `docs/contrato_api_v2.md` §3).
@immutable
class UserMetrics {
  const UserMetrics({
    required this.totalEscaneos,
    required this.totalUrl,
    required this.totalSms,
    required this.amenazasBloqueadas,
    this.ultimaActualizacion,
  });

  /// Estado inicial limpio (sin mocks) cuando aún no hay escaneos registrados.
  static const UserMetrics empty = UserMetrics(
    totalEscaneos: 0,
    totalUrl: 0,
    totalSms: 0,
    amenazasBloqueadas: 0,
  );

  /// Construye [UserMetrics] a partir del JSON de `GET /api/v1/metrics/me`.
  factory UserMetrics.fromJson(Map<String, dynamic> json) {
    final rawDate = json['ultima_actualizacion'];
    return UserMetrics(
      totalEscaneos: (json['total_escaneos'] as num?)?.toInt() ?? 0,
      totalUrl: (json['total_url'] as num?)?.toInt() ?? 0,
      totalSms: (json['total_sms'] as num?)?.toInt() ?? 0,
      amenazasBloqueadas: (json['amenazas_bloqueadas'] as num?)?.toInt() ?? 0,
      ultimaActualizacion: rawDate is String
          ? DateTime.tryParse(rawDate)
          : null,
    );
  }

  final int totalEscaneos;
  final int totalUrl;
  final int totalSms;
  final int amenazasBloqueadas;
  final DateTime? ultimaActualizacion;

  /// Análisis que resultaron con nivel de riesgo bajo o medio
  /// (`total_escaneos - amenazas_bloqueadas`).
  int get escaneosSinAmenazaCritica =>
      (totalEscaneos - amenazasBloqueadas).clamp(0, totalEscaneos);

  /// Calcula el porcentaje entero (0..100) de [part] respecto a [totalEscaneos].
  int percentOfTotal(int part) {
    if (totalEscaneos <= 0) return 0;
    return ((part * 100) / totalEscaneos).round().clamp(0, 100);
  }
}
