import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/labeled_divider.dart';
import '../../../../l10n/app_strings.dart';

/// Nota de privacidad junto al formulario (DESIGN.md §2, "Privacidad visible").
class AuthPrivacyNote extends StatelessWidget {
  const AuthPrivacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.lock_outline, size: 14, color: Color(0xFF8A7E8E)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(AppStrings.authPrivacyNote, style: AppTextStyles.caption),
        ),
      ],
    );
  }
}

/// Pie común de Login y Registro: separador, Google y aviso legal.
///
/// PLANTILLA SIN BACKEND: los botones que requieren integración con el
/// servidor (`POST /api/v1/auth/google` y enlaces legales) permanecen
/// deshabilitados (`onPressed: null`).
class AuthFormFooter extends StatelessWidget {
  const AuthFormFooter({super.key, this.enabled = false});

  /// Reservado para activar las acciones cuando se conecte el backend.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final legalStyle = AppTextStyles.caption.copyWith(
      fontSize: 11,
      color: const Color(0xFF7E7382),
    );
    final legalLinkStyle = legalStyle.copyWith(
      color: const Color(0xFFB09BB5),
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: const Color(0x66B09BB5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 26),
        const LabeledDivider(label: AppStrings.authDivider),
        const SizedBox(height: 20),
        const SecondaryButton(
          label: AppStrings.authGoogle,
          // Deshabilitado hasta conectar google_sign_in → POST /api/v1/auth/google (RF-06.4).
          onPressed: null,
          leading: _GoogleGlyph(),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(AppStrings.authLegalPrefix, style: legalStyle),
            LinkButton(
              label: AppStrings.authLegalTerms,
              style: legalLinkStyle,
              onPressed: null,
            ),
            Text(AppStrings.authLegalAnd, style: legalStyle),
            LinkButton(
              label: AppStrings.authLegalPrivacy,
              style: legalLinkStyle,
              onPressed: null,
            ),
          ],
        ),
      ],
    );
  }
}

/// "G" de Google. El logotipo oficial se añadirá como asset en la Etapa 2.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Text(
        'G',
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
