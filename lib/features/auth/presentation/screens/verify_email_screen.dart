import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/otp_code_input.dart';
import '../../../../l10n/app_strings.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_scaffold.dart';

/// Pantalla de espera y verificación de correo con código de 6 dígitos
/// (CU-14, RF-06.2).
///
/// PLANTILLA SIN LÓGICA: el backend aún no está conectado, por lo que:
/// - No hay cuenta regresiva real (solo se informa la vigencia de 10 min).
/// - El botón "Reenviar código" está deshabilitado.
/// - "Verificar" solo valida el formato y muestra un aviso informativo.
///
/// TODO(Etapa 2): POST /auth/verify-email {email, codigo}; temporizador de
/// 600 s; POST /auth/resend-code (máx. 3/hora, HTTP 429); 5 intentos máx.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.email});

  /// Correo al que se envió el código. Llegará desde el registro.
  final String? email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  String _code = '';
  String? _codeError;
  bool _showNotice = false;

  void _submit() {
    FocusScope.of(context).unfocus();
    final error = AuthValidators.verificationCode(_code);
    setState(() {
      _codeError = error;
      _showNotice = error == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String email = widget.email ?? AppStrings.verifyEmailPlaceholder;

    return AuthScaffold(
      eyebrow: AppStrings.verifyEyebrow,
      title: AppStrings.verifyTitle,
      subtitle: '',
      subtitleWidget: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: AppStrings.verifySubtitlePrefix),
            TextSpan(
              text: email,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        style: AppTextStyles.bodyMuted,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: !_showNotice
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: AppAlert(
                      message: AppStrings.verifyTemplateNotice,
                      onDismiss: () => setState(() => _showNotice = false),
                    ),
                  ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 3, bottom: 10),
            child: Text(
              AppStrings.verifyCodeLabel,
              style: AppTextStyles.fieldLabel,
            ),
          ),
          OtpCodeInput(
            semanticLabel: AppStrings.verifyCodeSemantics,
            errorText: _codeError,
            onChanged: (value) => setState(() {
              _code = value;
              if (_codeError != null) _codeError = null;
            }),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.schedule_rounded, size: 15, color: AppColors.lilac),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.verifyValidity,
                  style: AppTextStyles.fieldHelper,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: AppStrings.verifySubmit,
            icon: Icons.verified_user_outlined,
            onPressed: _submit,
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                AppStrings.verifyResendPrompt,
                style: AppTextStyles.caption,
              ),
              // Deshabilitado hasta conectar POST /auth/resend-code.
              const LinkButton(label: AppStrings.verifyResend, onPressed: null),
            ],
          ),
          const Text(
            AppStrings.verifyResendLimit,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 8),
          Center(
            child: LinkButton(
              label: AppStrings.verifyChangeEmail,
              onPressed: () =>
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.register),
            ),
          ),
        ],
      ),
    );
  }
}
