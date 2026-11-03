/// Rutas nombradas de la aplicación.
///
/// Provisional hasta integrar `go_router` (DPF-02). `core/` solo declara las
/// rutas; el mapeo ruta → pantalla vive en `app.dart` para no importar features.
abstract final class AppRoutes {
  // Autenticación
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';

  // Shell principal (App.tsx: 'home' | 'history' | 'stats' | 'profile')
  static const String home = '/home';
  static const String history = '/history';
  static const String stats = '/stats';
  static const String profile = '/profile';
}
