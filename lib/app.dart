import 'package:flutter/material.dart';

import 'core/router/app_routes.dart';
import 'core/session/session_controller.dart';
import 'core/storage/token_storage.dart';
import 'core/ui/theme/app_theme.dart';
import 'features/auth/auth.dart';

/// Punto de entrada del widget raíz de AntFish.
///
/// Navegación provisional con rutas nombradas hasta integrar `go_router`
/// con guards de sesión (DPF-02).
class AntFishApp extends StatefulWidget {
  const AntFishApp({super.key, this.authRepository});

  /// Repositorio de autenticación; si es null, Google Sign-In queda inactivo.
  final AuthRepository? authRepository;

  @override
  State<AntFishApp> createState() => _AntFishAppState();
}

class _AntFishAppState extends State<AntFishApp> {
  late final SessionController _session = SessionController(
    SecureTokenStorage(),
  );

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
      builder: (context, child) => AuthScope(
        repository: widget.authRepository,
        session: _session,
        child: child ?? const SizedBox.shrink(),
      ),
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
