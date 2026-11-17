import 'package:flutter/material.dart';

import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/crystal_text_field.dart';
import '../../../../l10n/app_strings.dart';
import '../auth_scope.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_form_footer.dart';
import '../widgets/auth_mode_tabs.dart';
import '../widgets/auth_scaffold.dart';

/// Pantalla de inicio de sesión local (CU-02) y con Google (RF-06.4).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _isSubmitting = false;
  String? _alertMessage;
  AlertVariant _alertVariant = AlertVariant.info;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
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

    setState(() {
      _isSubmitting = false;
      switch (result) {
        case GoogleSignInSuccess():
          _alertMessage = AppStrings.googleSignInSuccess;
          _alertVariant = AlertVariant.success;
        case GoogleSignInCancelled():
          break;
        case GoogleSignInUnavailable():
          _alertMessage = AppStrings.templateBackendPending;
          _alertVariant = AlertVariant.info;
        case GoogleSignInError(:final message):
          _alertMessage = message;
          _alertVariant = AlertVariant.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasGoogleAuth = AuthScope.maybeOf(context)?.repository != null;

    return AuthScaffold(
      mode: AuthMode.login,
      eyebrow: AppStrings.loginEyebrow,
      title: AppStrings.loginTitle,
      subtitle: AppStrings.loginSubtitle,
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
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: AuthValidators.email,
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: 18),
              CrystalTextField(
                label: AppStrings.fieldPasswordLabel,
                hint: AppStrings.fieldPasswordHint,
                icon: Icons.lock_outline_rounded,
                controller: _passwordController,
                focusNode: _passwordFocus,
                enabled: !_isSubmitting,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: AuthValidators.loginPassword,
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: LinkButton(
                  label: AppStrings.loginForgotPassword,
                  // Deshabilitado hasta conectar POST /api/v1/auth/password/forgot.
                  onPressed: null,
                ),
              ),
              const SizedBox(height: 6),
              const PrimaryButton(
                label: AppStrings.loginSubmit,
                // Deshabilitado hasta conectar POST /api/v1/auth/login.
                onPressed: null,
              ),
              const SizedBox(height: 14),
              const AuthPrivacyNote(),
              AuthFormFooter(
                enabled: hasGoogleAuth && !_isSubmitting,
                onGooglePressed: hasGoogleAuth ? _googleSignIn : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
