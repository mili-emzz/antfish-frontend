import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Tipos de aviso. Cada uno combina color + icono + texto: nunca solo color
/// (DESIGN.md §16).
enum AlertVariant {
  info(Icons.info_outline_rounded, AppColors.lilac),
  success(Icons.check_circle_outline_rounded, AppColors.riskSafe),
  warning(Icons.warning_amber_rounded, AppColors.riskMedium),
  error(Icons.error_outline_rounded, AppColors.riskCritical);

  const AlertVariant(this.icon, this.color);

  final IconData icon;
  final Color color;
}

/// Aviso en línea de cristal, pensado para mostrarse dentro de formularios
/// (p. ej. errores del servidor o avisos de privacidad).
class AppAlert extends StatelessWidget {
  const AppAlert({
    super.key,
    required this.message,
    this.variant = AlertVariant.info,
    this.title,
    this.onDismiss,
  });

  final String message;
  final String? title;
  final AlertVariant variant;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final color = variant.color;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.32)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(variant.icon, size: 19, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          title!,
                          style: AppTextStyles.fieldLabel.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Text(
                      message,
                      style: AppTextStyles.fieldHelper.copyWith(
                        fontSize: 12,
                        color: const Color(0xFFD9D1DC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onDismiss != null)
              SizedBox.square(
                dimension: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 17,
                  tooltip: AppStrings.alertDismiss,
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Muestra un aviso flotante (SnackBar) con el estilo del sistema.
void showAppSnackBar(
  BuildContext context,
  String message, {
  AlertVariant variant = AlertVariant.info,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final width = MediaQuery.sizeOf(context).width;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: const Color(0xF2241029),
        // En pantallas anchas el aviso no se estira de borde a borde.
        width: width > 560 ? 440 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: variant.color.withValues(alpha: 0.35)),
        ),
        content: Row(
          children: [
            Icon(variant.icon, size: 19, color: variant.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.fieldHelper.copyWith(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
