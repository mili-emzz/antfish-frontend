/// Rutas nombradas de la aplicación.
///
/// Provisional hasta integrar `go_router` (DPF-02). `core/` solo declara las
/// rutas; el mapeo ruta → pantalla vive en `app.dart` para no importar features.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
}
