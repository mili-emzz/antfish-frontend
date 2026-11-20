import 'package:flutter/material.dart';

import 'core/router/app_routes.dart';
import 'core/session/session_controller.dart';
import 'core/session/session_scope.dart';
import 'core/storage/token_storage.dart';
import 'core/ui/layout/app_shell.dart';
import 'core/ui/theme/app_theme.dart';
import 'core/ui/widgets/crystal_bottom_nav.dart';
import 'features/account/account.dart';
import 'features/analysis/analysis.dart';
import 'features/auth/auth.dart';
import 'features/metrics/metrics.dart';

/// Constructor diferido para crear [AuthRepository] conectado al
/// [SessionController] de la aplicación.
typedef AuthRepositoryBuilder = AuthRepository Function(
  SessionController session,
  VoidCallback onUnauthorized,
);

/// Constructor diferido para crear [MetricsRepository] conectado al
/// [SessionController] de la aplicación.
typedef MetricsRepositoryBuilder = MetricsRepository Function(
  SessionController session,
  VoidCallback onUnauthorized,
);

/// Constructor diferido para crear [AnalysisRepository] conectado al
/// [SessionController] de la aplicación.
typedef AnalysisRepositoryBuilder = AnalysisRepository Function(
  SessionController session,
  VoidCallback onUnauthorized,
);

/// Punto de entrada del widget raíz de AntFish.
///
/// Navegación provisional con rutas nombradas hasta integrar `go_router`
/// con guards de sesión (DPF-02).
class AntFishApp extends StatefulWidget {
  const AntFishApp({
    super.key,
    this.initialRoute,
    this.authRepository,
    this.authRepositoryBuilder,
    this.metricsRepository,
    this.metricsRepositoryBuilder,
    this.analysisRepository,
    this.analysisRepositoryBuilder,
    this.sessionController,
  });

  /// Ruta inicial opcional (útil para pruebas de widgets). Si no se indica,
  /// toma `INITIAL_ROUTE` de `--dart-define` o [AppRoutes.login].
  final String? initialRoute;

  /// Repositorio de autenticación directo (pruebas). Si es null y tampoco se
  /// indica [authRepositoryBuilder], los botones de API quedan inactivos.
  final AuthRepository? authRepository;

  /// Fábrica opcional que construye [AuthRepository] conectado a la sesión.
  final AuthRepositoryBuilder? authRepositoryBuilder;

  /// Repositorio de métricas directo (pruebas).
  final MetricsRepository? metricsRepository;

  /// Fábrica opcional que construye [MetricsRepository] conectado a la sesión.
  final MetricsRepositoryBuilder? metricsRepositoryBuilder;

  /// Repositorio de análisis directo (pruebas).
  final AnalysisRepository? analysisRepository;

  /// Fábrica opcional que construye [AnalysisRepository] conectado a la sesión.
  final AnalysisRepositoryBuilder? analysisRepositoryBuilder;

  /// Controlador de sesión opcional (permite inyectarlo en pruebas).
  final SessionController? sessionController;

  @override
  State<AntFishApp> createState() => _AntFishAppState();
}

class _AntFishAppState extends State<AntFishApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final SessionController _session =
      widget.sessionController ?? SessionController(SecureTokenStorage());
  late final AuthRepository? _repository =
      widget.authRepository ??
      widget.authRepositoryBuilder?.call(_session, _handleUnauthorized);
  late final MetricsController _metricsController = MetricsController(
    repository:
        widget.metricsRepository ??
        widget.metricsRepositoryBuilder?.call(_session, _handleUnauthorized),
  );
  late final AnalysisController _analysisController = AnalysisController(
    repository:
        widget.analysisRepository ??
        widget.analysisRepositoryBuilder?.call(_session, _handleUnauthorized),
    onAnalysisCompleted: () => _metricsController.refresh(),
  );

  @override
  void dispose() {
    _analysisController.dispose();
    _metricsController.dispose();
    super.dispose();
  }

  void _handleUnauthorized() {
    _analysisController.reset();
    _metricsController.reset();
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
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
      builder: (context, child) => SessionScope(
        controller: _session,
        child: AuthScope(
          repository: _repository,
          session: _session,
          child: MetricsScope(
            controller: _metricsController,
            child: AnalysisScope(
              controller: _analysisController,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  static Route<void> _onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.register => const RegisterScreen(),
      AppRoutes.verifyEmail => VerifyEmailScreen(
        email: settings.arguments as String?,
      ),
      AppRoutes.forgotPassword => ForgotPasswordScreen(
        initialEmail: settings.arguments as String?,
      ),
      AppRoutes.resetPassword => ResetPasswordScreen(
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
