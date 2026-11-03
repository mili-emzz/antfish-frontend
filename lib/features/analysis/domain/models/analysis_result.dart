import 'package:flutter/foundation.dart';

import '../../../../core/ui/widgets/risk_badge.dart';

/// Modelo de dominio inmutable para el resultado de un análisis en AntFish.
/// Fuente de verdad: docs/CONTEXTO/CONTEXTO_AntFish_V2.md §5 y antfish_modelo_nosql.json.
@immutable
class AnalysisResult {
  const AnalysisResult({
    required this.id,
    required this.tipoEntrada,
    required this.scoreTotal,
    required this.nivelRiesgo,
    required this.puntosPorCapa,
    required this.analisisParcial,
    required this.fechaAnalisis,
    this.motivoCortocircuito,
    this.urlDominante,
    this.urlSecundaria,
    this.flagsSintacticosSecundaria = const [],
  });

  final String id;
  final String tipoEntrada; // 'sms' | 'url'
  final int scoreTotal; // 0..100
  final RiskLevel nivelRiesgo; // bajo | medio | alto | critico
  final Map<String, int> puntosPorCapa;
  final bool analisisParcial;
  final DateTime fechaAnalisis;
  final String? motivoCortocircuito; // 'lista_negra' | 'suplantacion_marca'
  final String? urlDominante;
  final String? urlSecundaria;
  final List<String> flagsSintacticosSecundaria;

  bool get esAmenaza => scoreTotal >= 50;
  bool get tieneCortocircuito => motivoCortocircuito != null;
}
