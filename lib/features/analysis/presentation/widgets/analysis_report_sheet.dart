import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/risk_badge.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/models/analysis_result.dart';

/// Abre el reporte completo de un análisis en una hoja deslizable expandible
/// hasta pantalla completa (`DraggableScrollableSheet` + `showModalBottomSheet`).
///
/// Reutilizable desde [HomeScreen] y [HistoryScreen].
/// Retorna `true` si el análisis fue eliminado del historial.
Future<bool?> showAnalysisReportSheet(
  BuildContext context, {
  required AnalysisResult result,
  Future<String?> Function()? onDelete,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xA607030B),
    builder: (_) => AnalysisReportSheet(result: result, onDelete: onDelete),
  );
}

/// Hoja deslizable expandible a pantalla completa con el detalle completo de un
/// análisis (`POST /api/v1/analysis` y `GET /api/v1/analysis/{id}`).
///
/// Cumple todas las reglas de `AGENTS.md` §9 y accesibilidad WCAG AA:
/// - Muestra `score_total` y `puntos_por_capa` (nunca suma puntos de hallazgos).
/// - Rotula claramente la URL dominante y la URL secundaria (`flags_sintacticos`).
/// - Muestra advertencia clara si `analisis_parcial == true`.
/// - Muestra `motivo_cortocircuito` cuando existe.
/// - Permite eliminar el registro (`DELETE /api/v1/analysis/{id}`).
class AnalysisReportSheet extends StatefulWidget {
  const AnalysisReportSheet({super.key, required this.result, this.onDelete});

  final AnalysisResult result;

  /// Retorna `null` si la eliminación tuvo éxito o un mensaje de error.
  final Future<String?> Function()? onDelete;

  @override
  State<AnalysisReportSheet> createState() => _AnalysisReportSheetState();
}

class _AnalysisReportSheetState extends State<AnalysisReportSheet> {
  bool _isDeleting = false;
  String? _errorMessage;

  String? get _shortCircuitLabel => switch (widget.result.motivoCortocircuito) {
    'lista_negra' => AppStrings.resultShortCircuitBlacklist,
    'suplantacion_marca' => AppStrings.resultShortCircuitImpersonation,
    _ => null,
  };

  String _layerLabel(String key) => switch (key.toLowerCase()) {
    'apis' => AppStrings.resultLayerApis,
    'url' => AppStrings.resultLayerUrl,
    'texto' => AppStrings.resultLayerText,
    _ => key.toUpperCase(),
  };

  Future<void> _confirmAndDelete() async {
    if (_isDeleting || widget.onDelete == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundViolet,
        title: const Text(
          AppStrings.analysisDeleteConfirmTitle,
          style: TextStyle(
            fontFamily: AppTextStyles.display,
            fontSize: 20,
            color: AppColors.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          AppStrings.analysisDeleteConfirmCopy,
          style: AppTextStyles.bodyMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              AppStrings.deleteAccountCancel,
              style: TextStyle(fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              AppStrings.analysisDetailDelete,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.riskCritical,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    final error = await widget.onDelete!();
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isDeleting = false;
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final primaryUrl = result.urlDominante;
    final secondaryUrl = result.urlSecundaria;
    final shortCircuitText = _shortCircuitLabel;
    final accent = result.nivelRiesgo.color;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.45,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [0.65, 1.0],
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.sheetSurface, AppColors.backgroundDeep],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: AppColors.glassBorder, width: 1.2),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Barra de agarre superior para indicar gesto deslizable
                  Semantics(
                    label: AppStrings.analysisDetailTitle,
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0x4DFFFFFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 10, 10),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            AppStrings.analysisDetailTitle,
                            style: TextStyle(
                              fontFamily: AppTextStyles.display,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: AppStrings.analysisDetailClose,
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          onPressed: _isDeleting
                              ? null
                              : () => Navigator.of(context).pop(false),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 24,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0x18FFFFFF)),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                      children: [
                        // Bloque principal de score y nivel de riesgo
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.32),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${result.scoreTotal}',
                                          style: TextStyle(
                                            fontFamily: AppTextStyles.display,
                                            fontSize: 36,
                                            fontWeight: FontWeight.w800,
                                            color: accent,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: '/100',
                                          style: TextStyle(
                                            fontFamily: AppTextStyles.body,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RiskBadge(
                                    level: result.nivelRiesgo,
                                    score: result.scoreTotal,
                                  ),
                                ],
                              ),
                              if (shortCircuitText != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.riskCritical.withValues(
                                      alpha: 0.18,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.riskCritical.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.gpp_bad_outlined,
                                        size: 18,
                                        color: AppColors.riskCritical,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          shortCircuitText,
                                          style: const TextStyle(
                                            fontFamily: AppTextStyles.body,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.riskCritical,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (result.analisisParcial) ...[
                          const SizedBox(height: 14),
                          const AppAlert(
                            message: AppStrings.resultPartialWarning,
                            variant: AlertVariant.warning,
                          ),
                        ],
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          AppAlert(
                            message: _errorMessage!,
                            variant: AlertVariant.error,
                            onDismiss: () =>
                                setState(() => _errorMessage = null),
                          ),
                        ],
                        if (result.puntosPorCapa.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const _SectionTitle(
                            AppStrings.analysisDetailLayersTitle,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final entry in result.puntosPorCapa.entries)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x14FFFFFF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0x1AFFFFFF),
                                    ),
                                  ),
                                  child: Text(
                                    '${_layerLabel(entry.key)}: ${entry.value} pts',
                                    style: const TextStyle(
                                      fontFamily: AppTextStyles.body,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (primaryUrl != null) ...[
                          const SizedBox(height: 22),
                          const _SectionTitle(
                            AppStrings.analysisDetailPrimaryUrl,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0x0EFFFFFF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0x14FFFFFF),
                              ),
                            ),
                            child: SelectableText(
                              primaryUrl.url,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.body,
                                fontSize: 14,
                                height: 1.45,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                        ],
                        if (secondaryUrl != null) ...[
                          const SizedBox(height: 18),
                          const _SectionTitle(
                            AppStrings.analysisDetailSecondaryUrl,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0x0BFFFFFF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0x14FFFFFF),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  secondaryUrl.url,
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.body,
                                    fontSize: 14,
                                    height: 1.45,
                                    color: AppColors.muted,
                                  ),
                                ),
                                if (secondaryUrl
                                    .flagsSintacticos
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (final flag
                                          in secondaryUrl.flagsSintacticos)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.gold.withValues(
                                              alpha: 0.16,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            flag,
                                            style: const TextStyle(
                                              fontFamily: AppTextStyles.body,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.gold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        if (result.hallazgos.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const _SectionTitle(
                            AppStrings.analysisDetailFindingsTitle,
                          ),
                          const SizedBox(height: 10),
                          for (final finding in result.hallazgos)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0x0EFFFFFF),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0x14FFFFFF),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      finding.titulo,
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.body,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                    if (finding.descripcion.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        finding.descripcion,
                                        style: const TextStyle(
                                          fontFamily: AppTextStyles.body,
                                          fontSize: 14,
                                          height: 1.5,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                        ],
                        if (result.recomendaciones.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const _SectionTitle(
                            AppStrings.analysisDetailRecommendationsTitle,
                          ),
                          const SizedBox(height: 10),
                          for (final rec in result.recomendaciones)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 3),
                                    child: Icon(
                                      Icons.shield_outlined,
                                      size: 16,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      rec,
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.body,
                                        fontSize: 14,
                                        height: 1.5,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0x0DFFFFFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x1AFFFFFF)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 16,
                                    color: AppColors.gold,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppStrings.analysisDisclaimerTitle,
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.body,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                AppStrings.analysisDisclaimerBody,
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
                        if (result.fuentesConsultadas.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const _SectionTitle(
                            AppStrings.analysisDetailSourcesTitle,
                          ),
                          const SizedBox(height: 10),
                          for (final source in result.fuentesConsultadas)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x0BFFFFFF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${source.api}: ${source.estado}'
                                  '${source.positivo ? ' (detecciones: ${source.detecciones})' : ''}',
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.body,
                                    fontSize: 13,
                                    height: 1.4,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ),
                        ],
                        const SizedBox(height: 24),
                        if (widget.onDelete != null) ...[
                          SecondaryButton(
                            label: AppStrings.analysisDetailDelete,
                            onPressed: _isDeleting ? null : _confirmAndDelete,
                          ),
                          const SizedBox(height: 10),
                        ],
                        PrimaryButton(
                          label: AppStrings.analysisDetailClose,
                          onPressed: _isDeleting
                              ? null
                              : () => Navigator.of(context).pop(false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppTextStyles.eyebrow);
  }
}
