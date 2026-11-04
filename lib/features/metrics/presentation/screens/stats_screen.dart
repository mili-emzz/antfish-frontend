import 'package:flutter/material.dart';

import '../../../../core/ui/layout/breakpoints.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/glass_panel.dart';
import '../../../../core/ui/widgets/page_header.dart';
import '../../../../l10n/app_strings.dart';

/// Pantalla de métricas de protección (`StatsScreen` en App.tsx).
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const List<_MetricItemData> _metrics = [
    _MetricItemData(
      icon: Icons.center_focus_strong_outlined,
      value: '148',
      label: AppStrings.statsMetricTotalScans,
      sublabel: AppStrings.statsMetricTotalScansSub,
    ),
    _MetricItemData(
      icon: Icons.verified_user_outlined,
      value: '23',
      label: AppStrings.statsMetricBlocked,
      sublabel: AppStrings.statsMetricBlockedSub,
    ),
    _MetricItemData(
      icon: Icons.link_rounded,
      value: '91',
      label: AppStrings.statsMetricUrls,
      sublabel: AppStrings.statsMetricUrlsSub,
    ),
    _MetricItemData(
      icon: Icons.chat_bubble_outline_rounded,
      value: '57',
      label: AppStrings.statsMetricSms,
      sublabel: AppStrings.statsMetricSmsSub,
    ),
  ];

  static const List<_BreakdownRowData> _breakdown = [
    _BreakdownRowData(
      label: AppStrings.statsRiskSafe,
      percent: 71,
      color: AppColors.riskSafe,
    ),
    _BreakdownRowData(
      label: AppStrings.statsRiskMedium,
      percent: 19,
      color: AppColors.riskMedium,
    ),
    _BreakdownRowData(
      label: AppStrings.statsRiskHigh,
      percent: 7,
      color: AppColors.riskHigh,
    ),
    _BreakdownRowData(
      label: AppStrings.statsRiskCritical,
      percent: 3,
      color: AppColors.riskCritical,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    final bool isCompact = screenSize.isCompact;
    final bool isExpanded = screenSize.isExpanded;
    final double heroTitleSize = isCompact ? 17 : 21;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const PageHeader(
          eyebrow: AppStrings.statsEyebrow,
          title: AppStrings.statsTitle,
          copy: AppStrings.statsCopy,
        ),
        // .stats-hero
        GlassPanel(
          borderRadius: 23,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 20 : 28,
            vertical: isCompact ? 20 : 23,
          ),
          elevated: true,
          child: Row(
            children: [
                            SizedBox(width: isCompact ? 18 : 28),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      AppStrings.statsHeroEyebrow,
                      style: AppTextStyles.eyebrow,
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text.rich(
                        TextSpan(
                          children: const [
                            TextSpan(text: AppStrings.statsHeroTitleLead),
                            TextSpan(
                              text: AppStrings.statsHeroTitleAccent,
                              style: TextStyle(color: AppColors.gold),
                            ),
                          ],
                          style: TextStyle(
                            fontFamily: AppTextStyles.display,
                            fontSize: heroTitleSize,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      AppStrings.statsHeroCopy,
                      style: TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 10,
                        color: Color(0xFF918596),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        // .metric-grid (4 columnas en >800px, 2x2 en <=800px)
        if (isExpanded)
          Row(
            children: [
              for (var i = 0; i < _metrics.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _MetricCard(data: _metrics[i])),
              ],
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _MetricCard(data: _metrics[0])),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(data: _metrics[1])),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _MetricCard(data: _metrics[2])),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(data: _metrics[3])),
                ],
              ),
            ],
          ),
        const SizedBox(height: 15),
        // .threat-breakdown
        GlassPanel(
          borderRadius: 21,
          padding: const EdgeInsets.all(23),
          elevated: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.statsBreakdownEyebrow,
                        style: AppTextStyles.eyebrow,
                      ),
                      SizedBox(height: 5),
                      Text(
                        AppStrings.statsBreakdownTitle,
                        style: TextStyle(
                          fontFamily: AppTextStyles.display,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.54,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    AppStrings.statsBreakdownPeriod,
                    style: TextStyle(
                      fontFamily: AppTextStyles.body,
                      fontSize: 9,
                      color: Color(0xFF756B79),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (final row in _breakdown)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.5),
                  child: _ThreatBreakdownBar(data: row),
                ),
              const SizedBox(height: 10),
              // Nota aclaratoria obligatoria (AGENTS.md §9: Métricas vs Historial)
              const Text(
                AppStrings.statsPersistenceNote,
                style: TextStyle(
                  fontFamily: AppTextStyles.body,
                  fontSize: 9,
                  color: Color(0xFF756B79),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // .insight-card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x21D7BA89)),
            gradient: const LinearGradient(
              colors: [Color(0x17D7BA89), Color(0x0AB47EB3)],
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 22,
                color: AppColors.gold,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.statsInsightTitle,
                      style: TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE4DBE5),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      AppStrings.statsInsightCopy,
                      style: TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 9,
                        color: Color(0xFF857A89),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricItemData {
  const _MetricItemData({
    required this.icon,
    required this.value,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final String value;
  final String label;
  final String sublabel;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricItemData data;

  @override
  Widget build(BuildContext context) {
    final bool isUltraNarrow = MediaQuery.sizeOf(context).width <= 370;

    return GlassPanel(
      borderRadius: 18,
      padding: EdgeInsets.all(isUltraNarrow ? 15 : 18),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0x1AD7BA89),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, size: 18, color: AppColors.gold),
          ),
          const SizedBox(height: 13),
          Text(
            data.value,
            style: const TextStyle(
              fontFamily: AppTextStyles.display,
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            data.label,
            style: const TextStyle(
              fontFamily: AppTextStyles.body,
              fontSize: 9,
              color: Color(0xFFA99DAB),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.sublabel,
            style: const TextStyle(
              fontFamily: AppTextStyles.body,
              fontSize: 7,
              color: Color(0xFF685F6C),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRowData {
  const _BreakdownRowData({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final Color color;
}

class _ThreatBreakdownBar extends StatelessWidget {
  const _ThreatBreakdownBar({required this.data});

  final _BreakdownRowData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 85,
          child: Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTextStyles.body,
              fontSize: 9,
              color: Color(0xFFA89DAB),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0x0EFFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (data.percent / 100.0).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            '${data.percent}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: AppTextStyles.body,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFFA89DAB),
            ),
          ),
        ),
      ],
    );
  }
}
