import 'package:flutter/foundation.dart';

/// Modelo de dominio para las métricas acumuladas del usuario.
/// Fuente de verdad: docs/CONTEXTO/CONTEXTO_AntFish_V2.md §7 y CU-09.
@immutable
class UserMetrics {
  const UserMetrics({
    required this.totalEscaneos,
    required this.amenazasBloqueadas,
    required this.desglosePorTipo,
    required this.distribucionRiesgo,
    required this.anilloSeguridadPorcentaje,
  });

  final int totalEscaneos;
  final int amenazasBloqueadas;
  final Map<String, int> desglosePorTipo; // {'sms': n, 'url': m}
  final Map<String, int>
  distribucionRiesgo; // {'bajo': a, 'medio': b, 'alto': c, 'critico': d}
  final double anilloSeguridadPorcentaje; // 0..100
}
