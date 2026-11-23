import 'package:flutter/material.dart';

import '../../../../core/ui/layout/breakpoints.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/glass_panel.dart';
import '../../../../core/ui/widgets/risk_badge.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/models/analysis_result.dart';

/// Tarjeta informativa del semáforo de riesgo (`RiskTrafficLight` en App.tsx).
class RiskTrafficLightCard extends StatelessWidget {
  const RiskTrafficLightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isCompact = ScreenSize.of(context).isCompact;

    return GlassPanel(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 18),
      elevated: true,
      child: Row(
        crossAxisAlignment: isCompact
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          _TrafficVisual(compact: isCompact),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.trafficLightEyebrow,
                  style: TextStyle(
                    fontFamily: AppTextStyles.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.gold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  AppStrings.trafficLightTitle,
                  style: TextStyle(
                    fontFamily: AppTextStyles.body,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppStrings.trafficLightCopy,
                  style: TextStyle(
                    fontFamily: AppTextStyles.body,
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrafficVisual extends StatelessWidget {
  const _TrafficVisual({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    const dots = [
      _TrafficDot(color: AppColors.riskSafe),
      _TrafficDot(color: AppColors.riskMedium),
      _TrafficDot(color: AppColors.riskHigh),
      _TrafficDot(color: AppColors.riskCritical),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0x40020104),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: compact
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [dots[0], const SizedBox(width: 6), dots[1]],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [dots[2], const SizedBox(width: 6), dots[3]],
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                dots[0],
                const SizedBox(width: 6),
                dots[1],
                const SizedBox(width: 6),
                dots[2],
                const SizedBox(width: 6),
                dots[3],
              ],
            ),
    );
  }
}

class _TrafficDot extends StatelessWidget {
  const _TrafficDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 8),
        ],
      ),
    );
  }
}

/// Tarjeta de resultado de análisis (`ResultCard` en App.tsx).
///
/// Muestra `score_total`, `puntos_por_capa`, advertencia de `analisis_parcial`,
/// `motivo_cortocircuito` y hallazgos recibidos desde el backend sin recalcular
/// nunca el score en el cliente (`AGENTS.md` §5 y §9).
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    this.score = 92,
    this.level = RiskLevel.critico,
    this.title = AppStrings.resultCriticalTitle,
    this.copy = AppStrings.resultCriticalCopy,
    this.findings = const [
      AppStrings.resultFindingDeceptiveDomain,
      AppStrings.resultFindingBlacklist,
    ],
    this.layerPoints = const {},
    this.isPartial = false,
    this.shortCircuitReason,
    this.onViewDetails,
    this.onDismiss,
  });

  /// Construye la tarjeta a partir de un [AnalysisResult] real del backend.
  factory ResultCard.fromAnalysis(
    AnalysisResult result, {
    Key? key,
    VoidCallback? onViewDetails,
    VoidCallback? onDismiss,
  }) {
    final (title, defaultCopy) = switch (result.nivelRiesgo) {
      RiskLevel.bajo => (AppStrings.resultSafeTitle, AppStrings.resultSafeCopy),
      RiskLevel.medio => (
        AppStrings.resultMediumTitle,
        AppStrings.resultMediumCopy,
      ),
      RiskLevel.alto => (AppStrings.resultHighTitle, AppStrings.resultHighCopy),
      RiskLevel.critico => (
        AppStrings.resultCriticalTitle,
        AppStrings.resultCriticalCopy,
      ),
    };

    final copy = result.recomendaciones.isNotEmpty
        ? result.recomendaciones.first
        : defaultCopy;

    final findingLabels = result.hallazgos
        .map((f) => f.titulo)
        .where((t) => t.trim().isNotEmpty)
        .take(3)
        .toList();

    return ResultCard(
      key: key,
      score: result.scoreTotal,
      level: result.nivelRiesgo,
      title: title,
      copy: copy,
      findings: findingLabels,
      layerPoints: result.puntosPorCapa,
      isPartial: result.analisisParcial,
      shortCircuitReason: result.motivoCortocircuito,
      onViewDetails: onViewDetails,
      onDismiss: onDismiss,
    );
  }

  final int score;
  final RiskLevel level;
  final String title;
  final String copy;
  final List<String> findings;
  final Map<String, int> layerPoints;
  final bool isPartial;
  final String? shortCircuitReason;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDismiss;

  String? get _shortCircuitLabel => switch (shortCircuitReason) {
    'lista_negra' => AppStrings.resultShortCircuitBlacklist,
    'suplantacion_marca' => AppStrings.resultShortCircuitImpersonation,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final bool isCompact = ScreenSize.of(context).isCompact;
    final Color accent = level.color;
    final List<String> visibleFindings = isCompact && findings.length > 2
        ? findings.take(2).toList()
        : findings;
    final shortCircuitText = _shortCircuitLabel;

    final Widget scoreBlock = Container(
      constraints: BoxConstraints(minWidth: isCompact ? 0 : 118),
      padding: EdgeInsets.only(
        right: isCompact ? 0 : 16,
        bottom: isCompact ? 12 : 0,
      ),
      decoration: BoxDecoration(
        border: isCompact
            ? const Border(bottom: BorderSide(color: Color(0x17FFFFFF)))
            : const Border(right: BorderSide(color: Color(0x17FFFFFF))),
      ),
      child: isCompact
          ? Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$score',
                        style: TextStyle(
                          fontFamily: AppTextStyles.display,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      const TextSpan(
                        text: '/100',
                        style: TextStyle(
                          fontFamily: AppTextStyles.body,
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(level.icon, size: 15, color: accent),
                    const SizedBox(width: 5),
                    Text(
                      level.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$score',
                        style: TextStyle(
                          fontFamily: AppTextStyles.display,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      const TextSpan(
                        text: '/100',
                        style: TextStyle(
                          fontFamily: AppTextStyles.body,
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(level.icon, size: 14, color: accent),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        level.label.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyles.body,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );

    final Widget detailsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          AppStrings.resultEyebrow,
          style: TextStyle(
            fontFamily: AppTextStyles.body,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppTextStyles.body,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          copy,
          style: const TextStyle(
            fontFamily: AppTextStyles.body,
            fontSize: 13,
            height: 1.5,
            color: AppColors.muted,
          ),
        ),
        if (shortCircuitText != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.riskCritical.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.riskCritical.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              shortCircuitText,
              style: const TextStyle(
                fontFamily: AppTextStyles.body,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.riskCritical,
              ),
            ),
          ),
        ],
        if (layerPoints.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (layerPoints.containsKey('apis'))
                _LayerChip(
                  label: AppStrings.resultLayerApis,
                  points: layerPoints['apis']!,
                ),
              if (layerPoints.containsKey('url'))
                _LayerChip(
                  label: AppStrings.resultLayerUrl,
                  points: layerPoints['url']!,
                ),
              if (layerPoints.containsKey('texto'))
                _LayerChip(
                  label: AppStrings.resultLayerText,
                  points: layerPoints['texto']!,
                ),
            ],
          ),
        ],
        if (visibleFindings.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < visibleFindings.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (i == 0) ...[
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: accent,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Flexible(
                        child: Text(
                          visibleFindings[i],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTextStyles.body,
                            fontSize: 12,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
        if (onViewDetails != null) ...[
          const SizedBox(height: 10),
          InkWell(
            onTap: onViewDetails,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      AppStrings.resultViewDetail,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.gold,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );

    return GlassPanel(
      borderRadius: 20,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 21,
        vertical: isCompact ? 16 : 18,
      ),
      borderColor: accent.withValues(alpha: 0.25),
      backgroundColor: accent.withValues(alpha: 0.08),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCompact) ...[
                Padding(
                  padding: EdgeInsets.only(right: onDismiss != null ? 36 : 0),
                  child: scoreBlock,
                ),
                const SizedBox(height: 12),
                detailsColumn,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    scoreBlock,
                    const SizedBox(width: 20),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: onDismiss != null ? 32 : 0,
                        ),
                        child: detailsColumn,
                      ),
                    ),
                  ],
                ),
              if (isPartial) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.riskMedium.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.riskMedium.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.riskMedium,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.resultPartialWarning,
                          style: TextStyle(
                            fontFamily: AppTextStyles.body,
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.riskMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (onDismiss != null)
            Positioned(
              right: 0,
              top: 0,
              child: Semantics(
                button: true,
                label: AppStrings.alertDismiss,
                child: InkWell(
                  onTap: onDismiss,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LayerChip extends StatelessWidget {
  const _LayerChip({required this.label, required this.points});

  final String label;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $points',
        style: const TextStyle(
          fontFamily: AppTextStyles.body,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}
