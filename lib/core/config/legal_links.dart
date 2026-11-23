import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../ui/theme/app_colors.dart';
import '../ui/theme/app_text_styles.dart';

/// Enlaces centralizados de documentos legales de AntFish.
///
/// Las URLs pueden sobreescribirse mediante `--dart-define-from-file=.env`
/// (`TERMS_URL` y `PRIVACY_URL`) cuando la landing page esté publicada.
abstract final class LegalLinks {
  static const String termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://antfish.app/terminos',
  );

  static const String privacyUrl = String.fromEnvironment(
    'PRIVACY_URL',
    defaultValue: 'https://antfish.app/privacidad',
  );

  /// Muestra el aviso temporal para Términos y condiciones mientras se publica
  /// la landing page y se integra la apertura en navegador externo.
  static Future<void> openTerms(BuildContext context) {
    return showLegalLinkNotice(
      context,
      title: AppStrings.authLegalTerms,
      url: termsUrl,
    );
  }

  /// Muestra el aviso temporal para el Aviso de privacidad mientras se publica
  /// la landing page y se integra la apertura en navegador externo.
  static Future<void> openPrivacy(BuildContext context) {
    return showLegalLinkNotice(
      context,
      title: AppStrings.authLegalPrivacy,
      url: privacyUrl,
    );
  }

  /// Diálogo informativo temporal mientras la landing page está en construcción.
  static Future<void> showLegalLinkNotice(
    BuildContext context, {
    required String title,
    required String url,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.sheetSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
          title: Text(
            title,
            style: AppTextStyles.panelTitle.copyWith(fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.legalLinkPendingBody,
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glassPanel,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.goldBorder),
                ),
                child: Text(
                  url,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gold,
                minimumSize: const Size(44, 44),
              ),
              child: const Text(
                AppStrings.legalLinkPendingClose,
                style: AppTextStyles.link,
              ),
            ),
          ],
        );
      },
    );
  }
}
