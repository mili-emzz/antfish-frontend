import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/crystal_text_field.dart';
import '../../../../l10n/app_strings.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_form_footer.dart';
import '../widgets/auth_mode_tabs.dart';
import '../widgets/auth_scaffold.dart';

/// Pantalla de registro local con nombre, correo y contraseña (CU-13, RF-06.1).
///
/// PLANTILLA SIN BACKEND:
/// - Los campos del formulario, mostrar/ocultar contraseña y el cambio de
///   pestaña funcionan localmente.
/// - Los botones que requieren el backend (`Crear cuenta segura` y
///   `Continuar con Google`) permanecen deshabilitados (`onPressed: null`).
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
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
                CrystalTextField(
                  label: AppStrings.fieldNameLabel,
                  hint: AppStrings.fieldNameHint,
                  icon: Icons.person_outline_rounded,
                  controller: _nameController,
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
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: AuthValidators.newPassword,
                ),
                const SizedBox(height: 22),
                const PrimaryButton(
                  label: AppStrings.registerSubmit,
                  // Deshabilitado hasta conectar POST /api/v1/auth/register.
                  onPressed: null,
                ),
                const SizedBox(height: 14),
                const AuthPrivacyNote(),
                const AuthFormFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
