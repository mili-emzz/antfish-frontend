import 'package:dio/dio.dart';

import '../config/env_config.dart';

/// Crea la instancia base de Dio con los timeouts del contrato
/// (5 s conexión, 10 s recepción). Sin logging de bodies ni headers.
Dio createApiClient({String? baseUrl}) {
  return Dio(
    BaseOptions(
      baseUrl: baseUrl ?? EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );
}
