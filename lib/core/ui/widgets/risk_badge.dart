import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Niveles de riesgo del semáforo AntFish según contrato de backend y DESIGN.md.
enum RiskLevel {
  bajo,
  medio,
  alto,
  critico;

  /// Convierte el valor textual del backend (`bajo | medio | alto | critico`)
  /// sin recalcular nunca el score en el cliente (`AGENTS.md` §9).
  static RiskLevel fromApi(String? raw, {int? fallbackScore}) {
    switch (raw?.trim().toLowerCase()) {
      case 'bajo':
        return RiskLevel.bajo;
      case 'medio':
        return RiskLevel.medio;
      case 'alto':
        return RiskLevel.alto;
      case 'critico':
        return RiskLevel.critico;
      default:
        return fallbackScore != null
            ? fromScore(fallbackScore)
            : RiskLevel.bajo;
    }
  }

  /// Fallback según los rangos del contrato v2 (`docs/contrato_api_v2.md`):
  /// bajo (0-29), medio (30-59), alto (60-84), critico (85-100).
  static RiskLevel fromScore(int score) {
    if (score < 30) return RiskLevel.bajo;
    if (score < 60) return RiskLevel.medio;
    if (score < 85) return RiskLevel.alto;
    return RiskLevel.critico;
  }

  String get label {
    switch (this) {
      case RiskLevel.bajo:
        return 'Seguro';
      case RiskLevel.medio:
        return 'Precaución';
      case RiskLevel.alto:
        return 'Riesgo Alto';
      case RiskLevel.critico:
        return 'Amenaza Crítica';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.bajo:
        return AppColors.riskSafe;
      case RiskLevel.medio:
        return AppColors.riskMedium;
      case RiskLevel.alto:
        return AppColors.riskHigh;
      case RiskLevel.critico:
        return AppColors.riskCritical;
    }
  }

  IconData get icon {
    switch (this) {
      case RiskLevel.bajo:
        return Icons.verified_user_outlined;
      case RiskLevel.medio:
        return Icons.warning_amber_rounded;
      case RiskLevel.alto:
        return Icons.report_problem_outlined;
      case RiskLevel.critico:
        return Icons.gpp_bad_outlined;
    }
  }
}

/// Badge visual accesible del semáforo de riesgo AntFish.
/// Cumple la regla de DESIGN.md: combina color, icono, etiqueta y puntaje opcional.
class RiskBadge extends StatelessWidget {
  const RiskBadge({
    super.key,
    required this.level,
    this.score,
    this.compact = false,
  });

  final RiskLevel level;
  final int? score;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = level.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(level.icon, color: color, size: compact ? 16 : 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              score != null ? '${level.label} ($score/100)' : level.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: compact ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
