import 'package:flutter/material.dart';

import 'core/router/app_routes.dart';
import 'core/ui/theme/app_theme.dart';
import 'features/auth/auth.dart';

/// Punto de entrada del widget raíz de AntFish.
///
/// Navegación provisional con rutas nombradas hasta integrar `go_router`
/// con guards de sesión (DPF-02).
class AntFishApp extends StatelessWidget {
  const AntFishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AntFish',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Para previsualizar otra pantalla:
      // flutter run -d chrome --dart-define=INITIAL_ROUTE=/verify-email
      initialRoute: const String.fromEnvironment(
        'INITIAL_ROUTE',
        defaultValue: AppRoutes.login,
      ),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  static Route<void> _onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.register => const RegisterScreen(),
      AppRoutes.verifyEmail => VerifyEmailScreen(
        email: settings.arguments as String?,
      ),
      _ => const LoginScreen(),
    };

    // Transición de fundido corto (200–300 ms, DESIGN.md §14): al cambiar entre
    // Login y Registro, el fondo y el panel se mantienen visualmente estables.
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}
