import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/crystal_text_field.dart';
import '../../../../l10n/app_strings.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_form_footer.dart';
import '../widgets/auth_mode_tabs.dart';
import '../widgets/auth_scaffold.dart';

/// Pantalla de registro local con nombre, correo y contraseña (CU-13, RF-06.1).
///
/// PLANTILLA: todavía no hay backend. El envío solo valida el formulario,
/// muestra el estado de carga y un aviso informativo.
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
  String? _alertMessage;
  AlertVariant _alertVariant = AlertVariant.info;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
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

    // TODO(Etapa 2): POST /api/v1/auth/register {email, password, nombre}.
    // - Éxito → SessionPendingVerification(email) → pantalla de verificación.
    // - 409 → ConflictFailure (correo ya registrado).
    // - Nunca reintentar automáticamente este POST (AGENTS.md §7).
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _alertMessage = AppStrings.templateBackendPending;
      _alertVariant = AlertVariant.info;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: AppStrings.registerSubmit,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 14),
                const AuthPrivacyNote(),
                AuthFormFooter(enabled: !_isSubmitting),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
