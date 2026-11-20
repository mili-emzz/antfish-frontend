import 'package:flutter/material.dart';

import '../../../../core/ui/layout/breakpoints.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/glass_panel.dart';
import '../../../../core/ui/widgets/page_header.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/models/user_metrics.dart';

/// Pantalla de métricas de protección (`StatsScreen`), alineada con el esquema
/// de `GET /api/v1/metrics/me` (`docs/contrato_api_v2.md` §3) sin valores mock.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, this.metrics = UserMetrics.empty});

  final UserMetrics metrics;

  static String _formatLastUpdated(DateTime? date) {
    if (date == null) return AppStrings.statsNoScansYet;
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return AppStrings.statsLastUpdated('$day/$month/$year $hour:$minute');
  }

  List<_MetricItemData> get _metricCards {
    final blockedPct = metrics.percentOfTotal(metrics.amenazasBloqueadas);
    final urlPct = metrics.percentOfTotal(metrics.totalUrl);
    final smsPct = metrics.percentOfTotal(metrics.totalSms);

    return [
      _MetricItemData(
        icon: Icons.center_focus_strong_outlined,
        value: '${metrics.totalEscaneos}',
        label: AppStrings.statsMetricTotalScans,
        sublabel: AppStrings.statsMetricTotalScansSub,
      ),
      _MetricItemData(
        icon: Icons.verified_user_outlined,
        value: '${metrics.amenazasBloqueadas}',
        label: AppStrings.statsMetricBlocked,
        sublabel: AppStrings.statsPercentOfTotal(blockedPct),
      ),
      _MetricItemData(
        icon: Icons.link_rounded,
        value: '${metrics.totalUrl}',
        label: AppStrings.statsMetricUrls,
        sublabel: AppStrings.statsPercentOfActivity(urlPct),
      ),
      _MetricItemData(
        icon: Icons.chat_bubble_outline_rounded,
        value: '${metrics.totalSms}',
        label: AppStrings.statsMetricSms,
        sublabel: AppStrings.statsPercentOfActivity(smsPct),
      ),
    ];
  }

  List<_BreakdownRowData> get _breakdownRows => [
    _BreakdownRowData(
      label: AppStrings.statsRiskSafeOrMedium,
      percent: metrics.percentOfTotal(metrics.escaneosSinAmenazaCritica),
      color: AppColors.riskSafe,
    ),
    _BreakdownRowData(
      label: AppStrings.statsRiskBlockedThreats,
      percent: metrics.percentOfTotal(metrics.amenazasBloqueadas),
      color: AppColors.riskCritical,
    ),
    _BreakdownRowData(
      label: AppStrings.statsBreakdownUrls,
      percent: metrics.percentOfTotal(metrics.totalUrl),
      color: AppColors.gold,
    ),
    _BreakdownRowData(
      label: AppStrings.statsBreakdownSms,
      percent: metrics.percentOfTotal(metrics.totalSms),
      color: AppColors.lilac,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);
    final bool isExpanded = screenSize.isExpanded;
    final cards = _metricCards;
    final breakdown = _breakdownRows;
    final periodLabel = _formatLastUpdated(metrics.ultimaActualizacion);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const PageHeader(
          eyebrow: AppStrings.statsEyebrow,
          title: AppStrings.statsTitle,
          copy: AppStrings.statsCopy,
        ),
        // .metric-grid (4 columnas en >800px, 2x2 en <=800px)
        if (isExpanded)
          Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _MetricCard(data: cards[i])),
              ],
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _MetricCard(data: cards[0])),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(data: cards[1])),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _MetricCard(data: cards[2])),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(data: cards[3])),
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
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                runSpacing: 6,
                children: [
                  const Column(
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
                    periodLabel,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.body,
                      fontSize: 9,
                      color: Color(0xFF756B79),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (final row in breakdown)
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
          width: 115,
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
