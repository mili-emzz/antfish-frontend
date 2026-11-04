import 'package:flutter/material.dart';

import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/crystal_text_field.dart';
import '../../../../l10n/app_strings.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_form_footer.dart';
import '../widgets/auth_mode_tabs.dart';
import '../widgets/auth_scaffold.dart';

/// Pantalla de inicio de sesión local (CU-02).
///
/// PLANTILLA SIN BACKEND:
/// - Los campos de correo y contraseña, el botón de mostrar/ocultar contraseña
///   y las pestañas `Ingresar` / `Registrarme` funcionan localmente.
/// - Los botones que requieren llamadas al backend (`Entrar de forma segura`,
///   `¿Olvidaste tu contraseña?` y `Continuar con Google`) permanecen
///   deshabilitados (`onPressed: null`) hasta que exista el servidor.
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              CrystalTextField(
                label: AppStrings.fieldEmailLabel,
                hint: AppStrings.fieldEmailHint,
                icon: Icons.mail_outline_rounded,
                controller: _emailController,
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
              const AuthFormFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
