import 'package:dio/dio.dart';

import '../config/env_config.dart';
import '../session/session_controller.dart';
import 'auth_interceptor.dart';

/// Crea la instancia base de Dio con los timeouts del contrato
/// (5 s conexión, 10 s recepción). Sin logging de bodies ni headers.
///
/// Si se proporciona [session], instala [AuthRefreshInterceptor] para adjuntar
/// `Authorization: Bearer <access_token>` y renovar tokens en 401 concurrentes.
Dio createApiClient({
  String? baseUrl,
  SessionController? session,
  void Function()? onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  if (session != null) {
    dio.interceptors.add(
      AuthRefreshInterceptor(
        dio: dio,
        session: session,
        onUnauthorized: onUnauthorized,
      ),
    );
  }

  return dio;
}
