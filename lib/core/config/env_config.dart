/// Configuración de variables de entorno inyectadas mediante `--dart-define-from-file=.env`.
///
/// Nunca hardcodear credenciales o Client IDs directamente aquí; definirlos en `.env`.
abstract final class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  static const String googleAndroidClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
  );
}
