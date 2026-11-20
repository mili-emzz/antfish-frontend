import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/glass_panel.dart';
import '../../../../core/ui/widgets/risk_badge.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/models/analysis_result.dart';

/// Diálogo con el detalle completo de un análisis (`GET /api/v1/analysis/{id}`).
///
/// Cumple todas las reglas de `AGENTS.md` §9:
/// - Muestra `score_total` y `puntos_por_capa` (nunca suma puntos de hallazgos).
/// - Rotula claramente la URL dominante y la URL secundaria (`flags_sintacticos`).
/// - Muestra advertencia clara si `analisis_parcial == true`.
/// - Permite eliminar el registro (`DELETE /api/v1/analysis/{id}`).
class AnalysisDetailDialog extends StatefulWidget {
  const AnalysisDetailDialog({super.key, required this.result, this.onDelete});

  final AnalysisResult result;

  /// Retorna `null` si la eliminación tuvo éxito o un mensaje de error.
  final Future<String?> Function()? onDelete;

  @override
  State<AnalysisDetailDialog> createState() => _AnalysisDetailDialogState();
}

class _AnalysisDetailDialogState extends State<AnalysisDetailDialog> {
  bool _isDeleting = false;
  String? _errorMessage;

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
            child: const Text(AppStrings.deleteAccountCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              AppStrings.analysisDetailDelete,
              style: TextStyle(color: AppColors.riskCritical),
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        child: GlassPanel(
          borderRadius: 22,
          padding: const EdgeInsets.all(22),
          elevated: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        AppStrings.analysisDetailTitle,
                        style: TextStyle(
                          fontFamily: AppTextStyles.display,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isDeleting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RiskBadge(
                    level: result.nivelRiesgo,
                    score: result.scoreTotal,
                  ),
                ),
                if (result.analisisParcial) ...[
                  const SizedBox(height: 12),
                  const AppAlert(
                    message: AppStrings.resultPartialWarning,
                    variant: AlertVariant.warning,
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  AppAlert(
                    message: _errorMessage!,
                    variant: AlertVariant.error,
                    onDismiss: () => setState(() => _errorMessage = null),
                  ),
                ],
                if (result.puntosPorCapa.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _SectionTitle(AppStrings.analysisDetailLayersTitle),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in result.puntosPorCapa.entries)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x14FFFFFF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${entry.key.toUpperCase()}: ${entry.value}',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.body,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                if (primaryUrl != null) ...[
                  const SizedBox(height: 16),
                  const _SectionTitle(AppStrings.analysisDetailPrimaryUrl),
                  const SizedBox(height: 6),
                  Text(
                    primaryUrl.url,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.body,
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
                if (secondaryUrl != null) ...[
                  const SizedBox(height: 14),
                  const _SectionTitle(AppStrings.analysisDetailSecondaryUrl),
                  const SizedBox(height: 6),
                  Text(
                    secondaryUrl.url,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.body,
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  if (secondaryUrl.flagsSintacticos.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final flag in secondaryUrl.flagsSintacticos)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              flag,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.body,
                                fontSize: 10,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
                if (result.hallazgos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _SectionTitle(AppStrings.analysisDetailFindingsTitle),
                  const SizedBox(height: 8),
                  for (final finding in result.hallazgos)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0x0EFFFFFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              finding.titulo,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.body,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textLight,
                              ),
                            ),
                            if (finding.descripcion.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                finding.descripcion,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.body,
                                  fontSize: 11,
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
                  const SizedBox(height: 14),
                  const _SectionTitle(
                    AppStrings.analysisDetailRecommendationsTitle,
                  ),
                  const SizedBox(height: 6),
                  for (final rec in result.recomendaciones)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        '• $rec',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.body,
                          fontSize: 11,
                          height: 1.4,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                ],
                if (result.fuentesConsultadas.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const _SectionTitle(AppStrings.analysisDetailSourcesTitle),
                  const SizedBox(height: 6),
                  for (final source in result.fuentesConsultadas)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${source.api}: ${source.estado}'
                        '${source.positivo ? ' (detecciones: ${source.detecciones})' : ''}',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.body,
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 18),
                if (widget.onDelete != null) ...[
                  SecondaryButton(
                    label: AppStrings.analysisDetailDelete,
                    onPressed: _isDeleting ? null : _confirmAndDelete,
                  ),
                  const SizedBox(height: 8),
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
        ),
      ),
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
