import 'package:flutter/material.dart';

import '../../../../core/ui/layout/breakpoints.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/glass_panel.dart';
import '../../../../core/ui/widgets/risk_badge.dart';
import '../../../../l10n/app_strings.dart';

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
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: AppColors.gold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  AppStrings.trafficLightTitle,
                  style: TextStyle(
                    fontFamily: AppTextStyles.body,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppStrings.trafficLightCopy,
                  style: TextStyle(
                    fontFamily: AppTextStyles.body,
                    fontSize: 10,
                    height: 1.45,
                    color: Color(0xFF887D8C),
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
/// Muestra el puntaje recibido desde el backend junto con icono, etiqueta y
/// hallazgos, sin recalcular nunca el score en el cliente (AGENTS.md §5 y §9).
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
    this.onDismiss,
  });

  final int score;
  final RiskLevel level;
  final String title;
  final String copy;
  final List<String> findings;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final bool isCompact = ScreenSize.of(context).isCompact;
    final Color accent = level.color;
    final List<String> visibleFindings = isCompact && findings.length > 1
        ? [findings.first]
        : findings;

    return GlassPanel(
      borderRadius: 20,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 21,
        vertical: isCompact ? 15 : 18,
      ),
      borderColor: accent.withValues(alpha: 0.25),
      backgroundColor: accent.withValues(alpha: 0.08),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                constraints: BoxConstraints(minWidth: isCompact ? 90 : 105),
                padding: EdgeInsets.all(isCompact ? 12 : 15),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Color(0x17FFFFFF))),
                ),
                child: Column(
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
                              fontSize: 12,
                              color: Color(0xFF8A7D8E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(level.icon, size: 12, color: accent),
                        const SizedBox(width: 4),
                        Text(
                          level.label.toUpperCase(),
                          style: TextStyle(
                            fontFamily: AppTextStyles.body,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: isCompact ? 8 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      AppStrings.resultEyebrow,
                      style: TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      copy,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 10,
                        height: 1.45,
                        color: Color(0xFF887D8C),
                      ),
                    ),
                    if (visibleFindings.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (var i = 0; i < visibleFindings.length; i++)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (i == 0) ...[
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: 13,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    visibleFindings[i],
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.body,
                                      fontSize: 8,
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
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
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Color(0xFF766A7B),
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
