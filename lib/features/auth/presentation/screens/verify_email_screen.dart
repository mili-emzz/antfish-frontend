import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/otp_code_input.dart';
import '../../../../l10n/app_strings.dart';
import '../auth_scope.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_scaffold.dart';

/// Pantalla de verificación de correo con código de 6 dígitos
/// (CU-14, RF-06.2, RF-06.3).
///
/// Conectada a `POST /api/v1/auth/verify-email` y `POST /api/v1/auth/resend-code`
/// cuando existe [AuthRepository] en [AuthScope]. Si se monta sin repositorio
/// (modo plantilla), conserva la validación local y el aviso informativo.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    this.email,
    this.resendCooldownSeconds = 60,
  });

  /// Correo al que se envió el código. Llega desde registro o login 403.
  final String? email;

  /// Segundos de espera tras solicitar un reenvío (protege el límite 3/hora).
  final int resendCooldownSeconds;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  String _code = '';
  String? _codeError;
  bool _isSubmitting = false;
  bool _isResending = false;
  int _cooldownRemaining = 0;
  Timer? _cooldownTimer;

  String? _alertMessage;
  AlertVariant _alertVariant = AlertVariant.info;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    if (widget.resendCooldownSeconds <= 0) return;
    setState(() => _cooldownRemaining = widget.resendCooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownRemaining <= 1) {
        timer.cancel();
        setState(() => _cooldownRemaining = 0);
      } else {
        setState(() => _cooldownRemaining--);
      }
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    final error = AuthValidators.verificationCode(_code);
    if (error != null) {
      setState(() {
        _codeError = error;
        _alertMessage = null;
      });
      return;
    }

    final hasBackend = AuthScope.maybeOf(context)?.repository != null;
    if (!hasBackend) {
      setState(() {
        _codeError = null;
        _alertMessage = AppStrings.verifyTemplateNotice;
        _alertVariant = AlertVariant.info;
      });
      return;
    }

    setState(() {
      _codeError = null;
      _isSubmitting = true;
      _alertMessage = null;
    });

    final email = widget.email ?? '';
    final result = await runVerifyEmail(context, email: email, code: _code);
    if (!mounted) return;

    switch (result) {
      case AuthMessageSuccess(:final message):
        showAppSnackBar(context, message);
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        return;
      case AuthError(:final message):
        setState(() {
          _isSubmitting = false;
          _alertMessage = message;
          _alertVariant = AlertVariant.error;
        });
      default:
        setState(() {
          _isSubmitting = false;
          _alertMessage = AppStrings.verifyTemplateNotice;
          _alertVariant = AlertVariant.info;
        });
    }
  }

  Future<void> _resendCode() async {
    if (_isSubmitting || _isResending || _cooldownRemaining > 0) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isResending = true;
      _alertMessage = null;
    });

    final email = widget.email ?? '';
    final result = await runResendCode(context, email: email);
    if (!mounted) return;

    switch (result) {
      case AuthMessageSuccess(:final message):
        _startCooldown();
        setState(() {
          _isResending = false;
          _alertMessage = message;
          _alertVariant = AlertVariant.success;
        });
      case AuthError(:final message):
        setState(() {
          _isResending = false;
          _alertMessage = message;
          _alertVariant = AlertVariant.error;
        });
      default:
        setState(() {
          _isResending = false;
          _alertMessage = AppStrings.verifyTemplateNotice;
          _alertVariant = AlertVariant.info;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String email = widget.email ?? AppStrings.verifyEmailPlaceholder;
    final bool hasBackend = AuthScope.maybeOf(context)?.repository != null;
    final bool canResend =
        hasBackend &&
        !_isSubmitting &&
        !_isResending &&
        _cooldownRemaining == 0 &&
        (widget.email?.trim().isNotEmpty ?? false);

    final String resendLabel = _cooldownRemaining > 0
        ? AppStrings.verifyResendCooldown(_cooldownRemaining)
        : AppStrings.verifyResend;

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
            child: _alertMessage == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: AppAlert(
                      message: _alertMessage!,
                      variant: _alertVariant,
                      onDismiss: () => setState(() => _alertMessage = null),
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
            isLoading: _isSubmitting,
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
              LinkButton(
                label: resendLabel,
                onPressed: canResend ? _resendCode : null,
              ),
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
              onPressed: _isSubmitting
                  ? null
                  : () =>
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.register),
            ),
          ),
        ],
      ),
    );
  }
}
