import 'package:flutter/material.dart';

import '../../../../core/session/session_scope.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/ui/layout/breakpoints.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/brand_mark.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/models/analysis_result.dart';
import '../analysis_scope.dart';
import '../widgets/analysis_report_sheet.dart';
import '../widgets/risk_traffic_light_card.dart';
import '../widgets/scanner_card.dart';

/// Pantalla principal de escaneo (`HomeScreen`).
///
/// Cuando existe [AnalysisScope] con repositorio conectado:
/// - Envía URLs y mensajes SMS a `POST /api/v1/analysis`.
/// - Abre automáticamente [AnalysisReportSheet] deslizable a pantalla completa
///   con el diagnóstico íntegro sin recalcular score.
/// - Mantiene [ResultCard.fromAnalysis] como acceso rápido al último resultado.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialShowResult = false,
    this.onOpenProfile,
  });

  final bool initialShowResult;
  final VoidCallback? onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _showPreviewResult = widget.initialShowResult;

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialShowResult != widget.initialShowResult) {
      _showPreviewResult = widget.initialShowResult;
    }
  }

  Future<void> _openDetail(
    BuildContext context,
    AnalysisController controller,
    AnalysisResult item, {
    bool fetchFresh = true,
  }) async {
    final detailed = fetchFresh
        ? (await controller.fetchDetail(item.id) ?? item)
        : item;
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

  Future<void> _submitAndShowReport(
    BuildContext context,
    AnalysisController controller,
    AnalysisInputType type,
    String content,
  ) async {
    final result = await controller.submitAnalysis(
      tipoEntrada: type.apiValue,
      contenido: content,
    );
    if (result == null || !context.mounted) return;
    await _openDetail(context, controller, result, fetchFresh: false);
  }

  static String _initialsFor(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return AppStrings.homeAvatarInitials;
    if (parts.length == 1) {
      final first = parts.first;
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String _firstNameFor(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.isEmpty ? '' : parts.first;
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompact = ScreenSize.of(context).isCompact;
    final double titleFontSize = isCompact ? 27 : 36;

    final sessionState = SessionScope.maybeOf(context)?.state;
    final authState = sessionState is SessionAuthenticated
        ? sessionState
        : null;
    final userName = authState?.userName?.trim() ?? '';
    final greeting = userName.isNotEmpty
        ? AppStrings.homeGreetingFor(_firstNameFor(userName))
        : AppStrings.homeGreeting;
    final initials = userName.isNotEmpty
        ? _initialsFor(userName)
        : AppStrings.homeAvatarInitials;

    final controller = AnalysisScope.maybeOf(context);
    final hasBackend = controller?.hasBackend ?? false;
    final isAnalyzing = controller?.isAnalyzing ?? false;
    final analyzeError = controller?.analyzeError;
    final latestResult = controller?.latestResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // .app-header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(child: BrandMark(compact: true)),
            _AvatarButton(initials: initials, onTap: widget.onOpenProfile),
          ],
        ),
        SizedBox(height: isCompact ? 31 : 38),
        // .hello-row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.body,
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 7),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isCompact ? 225 : 350,
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: const [
                          TextSpan(text: AppStrings.homeTitleLead),
                          TextSpan(
                            text: AppStrings.homeTitleAccent,
                            style: TextStyle(color: AppColors.gold),
                          ),
                        ],
                        style: TextStyle(
                          fontFamily: AppTextStyles.display,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                          letterSpacing: -0.045 * titleFontSize,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        SizedBox(height: isCompact ? 23 : 30),
        if (analyzeError != null) ...[
          AppAlert(
            message: analyzeError,
            variant: AlertVariant.error,
            onDismiss: () => controller?.dismissAnalyzeError(),
          ),
          const SizedBox(height: 14),
        ],
        // .scanner-card
        ScannerCard(
          isSubmitting: isAnalyzing,
          onInputTypeChanged: (_) {
            if (_showPreviewResult) setState(() => _showPreviewResult = false);
            controller?.dismissLatestResult();
          },
          onAnalyzeSubmit: hasBackend
              ? (type, content) =>
                    _submitAndShowReport(context, controller!, type, content)
              : null,
        ),
        const SizedBox(height: 18),
        // .traffic-card o .result-card
        if (latestResult != null)
          ResultCard.fromAnalysis(
            latestResult,
            onDismiss: () => controller?.dismissLatestResult(),
            onViewDetails: () =>
                _openDetail(context, controller!, latestResult),
          )
        else if (_showPreviewResult)
          ResultCard(
            onDismiss: () => setState(() => _showPreviewResult = false),
          )
        else
          const RiskTrafficLightCard(),
      ],
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.initials, this.onTap});

  final String initials;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: AppStrings.homeAvatarSemantics,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x3DD7BA89)),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0x26D7BA89), Color(0x1FB47EB3)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF69D7A3),
                    border: Border.all(
                      color: const Color(0xFF23102C),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
