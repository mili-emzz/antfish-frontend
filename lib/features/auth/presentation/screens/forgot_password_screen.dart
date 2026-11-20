import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/crystal_text_field.dart';
import '../../../../l10n/app_strings.dart';
import '../auth_scope.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_scaffold.dart';

/// Pantalla de solicitud de recuperación de contraseña
/// (`POST /api/v1/auth/password/forgot`).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController = TextEditingController(
    text: widget.initialEmail ?? '',
  );

  bool _isSubmitting = false;
  String? _alertMessage;
  AlertVariant _alertVariant = AlertVariant.info;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _alertMessage = AppStrings.validationFormHasErrors;
        _alertVariant = AlertVariant.warning;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _alertMessage = null;
    });

    final normalizedEmail = AuthValidators.normalizeEmail(
      _emailController.text,
    );
    final result = await runRequestPasswordReset(
      context,
      email: normalizedEmail,
    );
    if (!mounted) return;

    switch (result) {
      case AuthMessageSuccess(:final message):
        showAppSnackBar(context, message);
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.resetPassword,
          arguments: normalizedEmail,
        );
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
      eyebrow: AppStrings.forgotPasswordEyebrow,
      title: AppStrings.forgotPasswordTitle,
      subtitle: AppStrings.forgotPasswordSubtitle,
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
              CrystalTextField(
                label: AppStrings.fieldEmailLabel,
                hint: AppStrings.fieldEmailHint,
                icon: Icons.mail_outline_rounded,
                controller: _emailController,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                validator: AuthValidators.email,
                onFieldSubmitted: (_) {
                  if (hasBackend) _submit();
                },
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: AppStrings.forgotPasswordSubmit,
                icon: Icons.mark_email_read_outlined,
                isLoading: _isSubmitting,
                onPressed: hasBackend ? _submit : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: LinkButton(
                  label: AppStrings.forgotPasswordBackToLogin,
                  onPressed: _isSubmitting
                      ? null
                      : () =>
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.login),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
