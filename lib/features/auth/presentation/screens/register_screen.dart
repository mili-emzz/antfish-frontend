import 'package:flutter/material.dart';

import '../../../../core/config/legal_links.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/crystal_text_field.dart';
import '../../../../l10n/app_strings.dart';
import '../auth_scope.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_form_footer.dart';
import '../widgets/auth_mode_tabs.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/legal_consent_checkboxes.dart';

/// Pantalla de registro local con nombre, correo y contraseña (CU-13, RF-06.1)
/// y autenticación con Google (RF-06.4).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isSubmitting = false;
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  String? _alertMessage;
  AlertVariant _alertVariant = AlertVariant.info;

  bool get _hasAcceptedLegal => _acceptedTerms && _acceptedPrivacy;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Aplica el resultado de un intento de autenticación (registro o Google).
  void _handleResult(AuthAttemptResult result) {
    switch (result) {
      case AuthSuccess():
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        return;
      case AuthNeedsVerification(:final email):
        Navigator.of(context)
            .pushReplacementNamed(AppRoutes.verifyEmail, arguments: email);
        return;
      case AuthCancelled():
        break;
      case AuthMessageSuccess(:final message):
        _alertMessage = message;
        _alertVariant = AlertVariant.success;
      case AuthUnavailable():
        _alertMessage = AppStrings.templateBackendPending;
        _alertVariant = AlertVariant.info;
      case AuthError(:final message):
        _alertMessage = message;
        _alertVariant = AlertVariant.error;
    }
    setState(() => _isSubmitting = false);
  }

  Future<void> _googleSignIn() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _alertMessage = null;
    });

    final result = await runGoogleSignIn(context);
    if (!mounted) return;
    _handleResult(result);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    if (!_hasAcceptedLegal) {
      setState(() {
        _alertMessage = AppStrings.validationLegalRequired;
        _alertVariant = AlertVariant.warning;
      });
      return;
    }

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

    final result = await runRegister(
      context,
      email: _emailController.text,
      password: _passwordController.text,
      nombre: _nameController.text,
    );
    if (!mounted) return;
    _handleResult(result);
  }

  @override
  Widget build(BuildContext context) {
    final hasBackend = AuthScope.maybeOf(context)?.repository != null;

    // Con "atrás" en Android se vuelve a Login en vez de cerrar la app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      },
      child: AuthScaffold(
        mode: AuthMode.register,
        eyebrow: AppStrings.registerEyebrow,
        title: AppStrings.registerTitle,
        subtitle: AppStrings.registerSubtitle,
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
                            onDismiss: () =>
                                setState(() => _alertMessage = null),
                          ),
                        ),
                ),
                CrystalTextField(
                  label: AppStrings.fieldNameLabel,
                  hint: AppStrings.fieldNameHint,
                  icon: Icons.person_outline_rounded,
                  controller: _nameController,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: AuthValidators.name,
                  onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                ),
                const SizedBox(height: 18),
                CrystalTextField(
                  label: AppStrings.fieldEmailLabel,
                  hint: AppStrings.fieldEmailHint,
                  icon: Icons.mail_outline_rounded,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: AuthValidators.email,
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 18),
                CrystalTextField(
                  label: AppStrings.fieldPasswordLabel,
                  hint: AppStrings.fieldPasswordHint,
                  helper: AppStrings.registerPasswordHelper,
                  icon: Icons.lock_outline_rounded,
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  enabled: !_isSubmitting,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: AuthValidators.newPassword,
                ),
                const SizedBox(height: 16),
                LegalConsentCheckboxes(
                  acceptedTerms: _acceptedTerms,
                  acceptedPrivacy: _acceptedPrivacy,
                  enabled: !_isSubmitting,
                  onTermsChanged: (value) =>
                      setState(() => _acceptedTerms = value),
                  onPrivacyChanged: (value) =>
                      setState(() => _acceptedPrivacy = value),
                  onOpenTerms: () => LegalLinks.openTerms(context),
                  onOpenPrivacy: () => LegalLinks.openPrivacy(context),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: AppStrings.registerSubmit,
                  isLoading: _isSubmitting,
                  onPressed: hasBackend && _hasAcceptedLegal ? _submit : null,
                ),
                const SizedBox(height: 14),
                const AuthPrivacyNote(),
                AuthFormFooter(
                  enabled: hasBackend && !_isSubmitting,
                  onGooglePressed: hasBackend ? _googleSignIn : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
