import 'package:flutter/material.dart';

import 'core/router/app_routes.dart';
import 'core/session/session_controller.dart';
import 'core/storage/token_storage.dart';
import 'core/ui/layout/app_shell.dart';
import 'core/ui/theme/app_theme.dart';
import 'core/ui/widgets/crystal_bottom_nav.dart';
import 'features/account/account.dart';
import 'features/analysis/analysis.dart';
import 'features/auth/auth.dart';
import 'features/metrics/metrics.dart';

/// Punto de entrada del widget raíz de AntFish.
///
/// Navegación provisional con rutas nombradas hasta integrar `go_router`
/// con guards de sesión (DPF-02).
class AntFishApp extends StatefulWidget {
  const AntFishApp({super.key, this.initialRoute, this.authRepository});

  /// Ruta inicial opcional (útil para pruebas de widgets). Si no se indica,
  /// toma `INITIAL_ROUTE` de `--dart-define` o [AppRoutes.login].
  final String? initialRoute;

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
      // flutter run -d chrome --dart-define=INITIAL_ROUTE=/home
      initialRoute:
          widget.initialRoute ??
          const String.fromEnvironment(
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
      AppRoutes.home => const _AppShellHost(initialTab: AppTab.home),
      AppRoutes.history => const _AppShellHost(initialTab: AppTab.history),
      AppRoutes.stats => const _AppShellHost(initialTab: AppTab.stats),
      AppRoutes.profile => const _AppShellHost(initialTab: AppTab.profile),
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

/// Anfitrión del shell principal que conmuta entre las 4 pestañas de App.tsx
/// (`home`, `history`, `stats`, `profile`).
class _AppShellHost extends StatefulWidget {
  const _AppShellHost({required this.initialTab});

  final AppTab initialTab;

  @override
  State<_AppShellHost> createState() => _AppShellHostState();
}

class _AppShellHostState extends State<_AppShellHost> {
  late AppTab _currentTab = widget.initialTab;

  @override
  void didUpdateWidget(covariant _AppShellHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _currentTab = widget.initialTab;
    }
  }

  void _selectTab(AppTab tab) {
    if (_currentTab == tab) return;
    setState(() => _currentTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final Widget tabBody = switch (_currentTab) {
      AppTab.home => HomeScreen(
        onOpenProfile: () => _selectTab(AppTab.profile),
        onViewAllHistory: () => _selectTab(AppTab.history),
      ),
      AppTab.history => const HistoryScreen(),
      AppTab.stats => const StatsScreen(),
      AppTab.profile => const ProfileScreen(),
    };

    return AppShell(
      currentTab: _currentTab,
      onTabSelected: _selectTab,
      onScanPressed: () => _selectTab(AppTab.home),
      child: tabBody,
    );
  }
}
