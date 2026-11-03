import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/widgets/crystal_segmented_control.dart';
import '../../../../l10n/app_strings.dart';

/// Modo de la pantalla de autenticación.
enum AuthMode { login, register }

/// Pestañas Ingresar / Registrarme. Cada pestaña es una ruta propia, así el
/// botón "atrás" y los futuros guards de `go_router` funcionan de forma natural.
class AuthModeTabs extends StatelessWidget {
  const AuthModeTabs({super.key, required this.current});

  final AuthMode current;

  @override
  Widget build(BuildContext context) {
    return CrystalSegmentedControl<AuthMode>(
      selected: current,
      options: const [
        SegmentOption(value: AuthMode.login, label: AppStrings.authTabLogin),
        SegmentOption(
          value: AuthMode.register,
          label: AppStrings.authTabRegister,
        ),
      ],
      onChanged: (mode) {
        FocusScope.of(context).unfocus();
        Navigator.of(context).pushReplacementNamed(
          mode == AuthMode.login ? AppRoutes.login : AppRoutes.register,
        );
      },
    );
  }
}
