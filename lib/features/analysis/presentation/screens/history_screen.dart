import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/page_header.dart';
import '../../../../l10n/app_strings.dart';
import '../widgets/history_row_item.dart';
import '../widgets/scanner_card.dart';

/// Filtro local de la pantalla de historial.
enum HistoryFilter { all, urls, sms }

/// Pantalla de historial de análisis (`HistoryScreen` en App.tsx).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryFilter _filter = HistoryFilter.all;

  List<ScanHistoryItem> get _filteredItems {
    final fullList = <ScanHistoryItem>[
      ...demoScanHistory,
      ...demoScanHistory.take(2),
    ];
    return switch (_filter) {
      HistoryFilter.all => fullList,
      HistoryFilter.urls =>
        fullList.where((item) => item.type == AnalysisInputType.url).toList(),
      HistoryFilter.sms =>
        fullList.where((item) => item.type == AnalysisInputType.sms).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const PageHeader(
          eyebrow: AppStrings.historyEyebrow,
          title: AppStrings.historyTitle,
          copy: AppStrings.historyCopy,
        ),
        // .filter-row
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0x40040108),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0x0FFFFFFF)),
          ),
          child: Wrap(
            spacing: 4,
            children: [
              _FilterChipButton(
                label: AppStrings.historyFilterAll,
                active: _filter == HistoryFilter.all,
                onTap: () => setState(() => _filter = HistoryFilter.all),
              ),
              _FilterChipButton(
                label: AppStrings.historyFilterUrls,
                active: _filter == HistoryFilter.urls,
                onTap: () => setState(() => _filter = HistoryFilter.urls),
              ),
              _FilterChipButton(
                label: AppStrings.historyFilterSms,
                active: _filter == HistoryFilter.sms,
                onTap: () => setState(() => _filter = HistoryFilter.sms),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        HistoryListCard(items: _filteredItems),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: active ? const Color(0x1AD7BA89) : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.body,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.gold : const Color(0xFF7F7483),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
