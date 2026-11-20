import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/crystal_text_field.dart';
import '../../../../core/ui/widgets/otp_code_input.dart';
import '../../../../l10n/app_strings.dart';
import '../auth_scope.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_scaffold.dart';

/// Pantalla para restablecer la contraseña con código de 6 dígitos
/// (`POST /api/v1/auth/password/reset`).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.email});

  final String? email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController = TextEditingController(
    text: widget.email ?? '',
  );
  final _passwordController = TextEditingController();

  String _code = '';
  String? _codeError;
  bool _isSubmitting = false;
  String? _alertMessage;
  AlertVariant _alertVariant = AlertVariant.info;

  bool get _hasInitialEmail => widget.email?.trim().isNotEmpty ?? false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    final codeError = AuthValidators.verificationCode(_code);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (codeError != null || !formValid) {
      setState(() {
        _codeError = codeError;
        _alertMessage = formValid ? null : AppStrings.validationFormHasErrors;
        _alertVariant = AlertVariant.warning;
      });
      return;
    }

    setState(() {
      _codeError = null;
      _isSubmitting = true;
      _alertMessage = null;
    });

    final email = _hasInitialEmail ? widget.email! : _emailController.text;
    final result = await runConfirmPasswordReset(
      context,
      email: email,
      code: _code,
      newPassword: _passwordController.text,
    );
    if (!mounted) return;

    switch (result) {
      case AuthMessageSuccess(:final message):
        showAppSnackBar(context, message);
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
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
          _alertMessage = AppStrings.templateBackendPending;
          _alertVariant = AlertVariant.info;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasBackend = AuthScope.maybeOf(context)?.repository != null;

    return AuthScaffold(
      eyebrow: AppStrings.resetPasswordEyebrow,
      title: AppStrings.resetPasswordTitle,
      subtitle: _hasInitialEmail
          ? ''
          : AppStrings.resetPasswordSubtitleFallback,
      subtitleWidget: _hasInitialEmail
          ? Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: AppStrings.resetPasswordSubtitlePrefix),
                  TextSpan(
                    text: widget.email!.trim(),
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              style: AppTextStyles.bodyMuted,
            )
          : null,
      child: Form(
        key: _formKey,
        child: AutofillGroup(
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
              if (!_hasInitialEmail) ...[
                CrystalTextField(
                  label: AppStrings.fieldEmailLabel,
                  hint: AppStrings.fieldEmailHint,
                  icon: Icons.mail_outline_rounded,
                  controller: _emailController,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: AuthValidators.email,
                ),
                const SizedBox(height: 18),
              ],
              const Padding(
                padding: EdgeInsets.only(left: 3, bottom: 10),
                child: Text(
                  AppStrings.resetPasswordCodeLabel,
                  style: AppTextStyles.fieldLabel,
                ),
              ),
              OtpCodeInput(
                semanticLabel: AppStrings.resetPasswordCodeSemantics,
                errorText: _codeError,
                onChanged: (value) => setState(() {
                  _code = value;
                  if (_codeError != null) _codeError = null;
                }),
              ),
              const SizedBox(height: 18),
              CrystalTextField(
                label: AppStrings.resetPasswordNewLabel,
                hint: AppStrings.fieldPasswordHint,
                helper: AppStrings.registerPasswordHelper,
                icon: Icons.lock_reset_rounded,
                controller: _passwordController,
                enabled: !_isSubmitting,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: AuthValidators.newPassword,
                onFieldSubmitted: (_) {
                  if (hasBackend) _submit();
                },
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: AppStrings.resetPasswordSubmit,
                icon: Icons.lock_open_rounded,
                isLoading: _isSubmitting,
                onPressed: hasBackend ? _submit : null,
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  LinkButton(
                    label: AppStrings.resetPasswordRequestAgain,
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pushReplacementNamed(
                            AppRoutes.forgotPassword,
                            arguments: _emailController.text.trim(),
                          ),
                  ),
                  LinkButton(
                    label: AppStrings.forgotPasswordBackToLogin,
                    onPressed: _isSubmitting
                        ? null
                        : () =>
                              Navigator.of(context)
                                  .pushReplacementNamed(AppRoutes.login),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
