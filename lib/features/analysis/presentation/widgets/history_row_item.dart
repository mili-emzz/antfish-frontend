import 'package:flutter/material.dart';

import '../../../../core/ui/layout/breakpoints.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/risk_badge.dart';
import 'scanner_card.dart';

/// Elemento de demostración del historial (`scanHistory` en App.tsx).
@immutable
class ScanHistoryItem {
  const ScanHistoryItem({
    required this.type,
    required this.value,
    required this.time,
    required this.risk,
    required this.score,
    required this.level,
  });

  final AnalysisInputType type;
  final String value;
  final String time;
  final String risk;
  final int score;
  final RiskLevel level;

  String get typeLabel => type == AnalysisInputType.url ? 'URL' : 'SMS';
}

/// Datos de plantilla del prototipo `App.tsx` (sin conexión al backend).
const List<ScanHistoryItem> demoScanHistory = [
  ScanHistoryItem(
    type: AnalysisInputType.url,
    value: 'secure-bbva-access.xyz',
    time: 'Hace 8 min',
    risk: 'Crítico',
    score: 92,
    level: RiskLevel.critico,
  ),
  ScanHistoryItem(
    type: AnalysisInputType.sms,
    value: 'Tu paquete está en espera...',
    time: 'Hoy, 09:42',
    risk: 'Medio',
    score: 38,
    level: RiskLevel.medio,
  ),
  ScanHistoryItem(
    type: AnalysisInputType.url,
    value: 'spotify.com/account',
    time: 'Ayer, 18:12',
    risk: 'Seguro',
    score: 4,
    level: RiskLevel.bajo,
  ),
  ScanHistoryItem(
    type: AnalysisInputType.sms,
    value: 'Código de acceso: 483921',
    time: '12 jun, 11:20',
    risk: 'Seguro',
    score: 2,
    level: RiskLevel.bajo,
  ),
];

/// Contenedor agrupado de filas de historial (`.history-list` en App.tsx).
class HistoryListCard extends StatelessWidget {
  const HistoryListCard({
    super.key,
    required this.items,
    this.compactList = false,
    this.onItemTap,
  });

  final List<ScanHistoryItem> items;
  final bool compactList;

  /// Callback opcional para `GET /api/v1/analysis/{id}`. Permanece `null`
  /// mientras no exista conexión con la API.
  final ValueChanged<ScanHistoryItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x06FFFFFF),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0x12FFFFFF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++)
            HistoryRowItem(
              item: items[i],
              compactList: compactList,
              showBottomDivider: i < items.length - 1,
              onTap: onItemTap != null ? () => onItemTap!(items[i]) : null,
            ),
        ],
      ),
    );
  }
}

/// Fila individual del historial (`HistoryRow` en App.tsx).
class HistoryRowItem extends StatelessWidget {
  const HistoryRowItem({
    super.key,
    required this.item,
    this.compactList = false,
    this.showBottomDivider = true,
    this.onTap,
  });

  final ScanHistoryItem item;
  final bool compactList;
  final bool showBottomDivider;
  final VoidCallback? onTap;

  Color get _toneColor => switch (item.level) {
    RiskLevel.bajo => AppColors.riskSafe,
    RiskLevel.medio => AppColors.riskMedium,
    RiskLevel.alto => AppColors.riskHigh,
    RiskLevel.critico => const Color(0xFFE27689),
  };

  @override
  Widget build(BuildContext context) {
    final bool isCompact = ScreenSize.of(context).isCompact;
    final Color tone = _toneColor;
    final double horizontalPadding = compactList && isCompact ? 12 : 17;

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label:
          '${item.typeLabel}: ${item.value}, ${item.risk} (${item.score}/100)',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          hoverColor: const Color(0x06FFFFFF),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              border: showBottomDivider
                  ? const Border(bottom: BorderSide(color: Color(0x0FFFFFFF)))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    item.type == AnalysisInputType.url
                        ? Icons.link_rounded
                        : Icons.chat_bubble_outline_rounded,
                    size: 19,
                    color: tone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.body,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE6DEE8),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.typeLabel} · ${item.time}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.body,
                          fontSize: 8,
                          color: Color(0xFF786D7C),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.level.icon, size: 11, color: tone),
                        const SizedBox(width: 4),
                        Text(
                          '${item.risk} · ${item.score}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.body,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: tone,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: Color(0xFF5F5663),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
