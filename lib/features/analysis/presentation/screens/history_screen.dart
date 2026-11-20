import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/glass_panel.dart';
import '../../../../core/ui/widgets/page_header.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/models/analysis_result.dart';
import '../analysis_scope.dart';
import '../widgets/analysis_report_sheet.dart';
import '../widgets/history_row_item.dart';
import '../widgets/scanner_card.dart';

/// Filtro local de la pantalla de historial.
enum HistoryFilter { all, urls, sms }

/// Pantalla de historial de análisis (`HistoryScreen` en App.tsx),
/// conectada a `GET /api/v1/analysis`, `GET /api/v1/analysis/{id}` y
/// `DELETE /api/v1/analysis/{id}` vía [AnalysisScope].
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryFilter _filter = HistoryFilter.all;
  bool _requestedInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedInitialLoad) return;
    final controller = AnalysisScope.maybeOf(context);
    if (controller != null && controller.hasBackend) {
      _requestedInitialLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) controller.loadHistory();
      });
    }
  }

  List<ScanHistoryItem> _applyFilter(List<ScanHistoryItem> fullList) {
    return switch (_filter) {
      HistoryFilter.all => fullList,
      HistoryFilter.urls =>
        fullList.where((item) => item.type == AnalysisInputType.url).toList(),
      HistoryFilter.sms =>
        fullList.where((item) => item.type == AnalysisInputType.sms).toList(),
    };
  }

  Future<void> _openDetail(
    BuildContext context,
    AnalysisController controller,
    AnalysisResult item,
  ) async {
    final detailed = await controller.fetchDetail(item.id) ?? item;
    if (!context.mounted) return;
    final deleted = await showAnalysisReportSheet(
      context,
      result: detailed,
      onDelete: () => controller.deleteHistoryItem(detailed.id),
    );
    if (deleted == true && context.mounted) {
      showAppSnackBar(context, AppStrings.analysisDeleteSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AnalysisScope.maybeOf(context);
    final hasBackend = controller?.hasBackend ?? false;
    final isLoading = hasBackend && (controller?.isLoadingHistory ?? false);
    final isLoadingMore = hasBackend && (controller?.isLoadingMore ?? false);
    final errorMessage = hasBackend ? controller?.historyError : null;

    final List<ScanHistoryItem> rawItems = hasBackend
        ? controller!.history.map(ScanHistoryItem.fromAnalysis).toList()
        : <ScanHistoryItem>[...demoScanHistory, ...demoScanHistory.take(2)];
    final filteredItems = _applyFilter(rawItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const PageHeader(
          eyebrow: AppStrings.historyEyebrow,
          title: AppStrings.historyTitle,
          copy: AppStrings.historyCopy,
        ),
        // .filter-row
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
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
        ),
        const SizedBox(height: 17),
        if (isLoading) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gold,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  AppStrings.historyLoading,
                  style: TextStyle(
                    fontFamily: AppTextStyles.body,
                    fontSize: 13,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (errorMessage != null) ...[
          AppAlert(message: errorMessage, variant: AlertVariant.error),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: SecondaryButton(
              label: AppStrings.statsRetry,
              onPressed: isLoading
                  ? null
                  : () => controller?.loadHistory(force: true),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (hasBackend && filteredItems.isEmpty && !isLoading)
          const GlassPanel(
            borderRadius: 21,
            padding: EdgeInsets.all(22),
            child: Text(
              AppStrings.historyEmpty,
              style: AppTextStyles.bodyMuted,
            ),
          )
        else
          HistoryListCard(
            items: filteredItems,
            onItemTap: hasBackend
                ? (item) {
                    if (item.analysis != null) {
                      _openDetail(context, controller!, item.analysis!);
                    }
                  }
                : null,
          ),
        if (hasBackend && (controller?.hasMoreHistory ?? false)) ...[
          const SizedBox(height: 14),
          SecondaryButton(
            label: isLoadingMore
                ? AppStrings.historyLoading
                : AppStrings.historyLoadMore,
            onPressed: isLoadingMore
                ? null
                : () => controller?.loadMoreHistory(),
          ),
        ],
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
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: active ? const Color(0x1AD7BA89) : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.body,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.gold : AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
