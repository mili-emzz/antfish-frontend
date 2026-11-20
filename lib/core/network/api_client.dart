import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env_config.dart';
import '../session/session_controller.dart';
import 'auth_interceptor.dart';
import 'error_mapper.dart';

/// Crea la instancia base de Dio con los timeouts del contrato
/// (5 s conexión, 10 s recepción). Sin logging de bodies ni credenciales.
///
/// Si se proporciona [session], instala [AuthRefreshInterceptor] para adjuntar
/// `Authorization: Bearer <access_token>` y renovar tokens en 401 concurrentes.
Dio createApiClient({
  String? baseUrl,
  SessionController? session,
  void Function()? onUnauthorized,
}) {
  final effectiveBaseUrl = (baseUrl ?? EnvConfig.apiBaseUrl).trim();
  if (effectiveBaseUrl.isEmpty) {
    throw StateError(
      'API_BASE_URL está vacío. Ejecuta la app con '
      '--dart-define-from-file=.env',
    );
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: effectiveBaseUrl,
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

  if (kDebugMode) {
    dio.interceptors.add(_SafeFlowLogInterceptor());
  }

  return dio;
}

/// Interceptor de diagnóstico seguro para desarrollo (`kDebugMode`).
///
/// Registra únicamente método, URI, estado HTTP, código de error y latencia;
/// nunca imprime bodies, tokens JWT, contraseñas ni códigos de verificación
/// (`AGENTS.md` §8).
class _SafeFlowLogInterceptor extends Interceptor {
  static const String _startTimeKey = '_debug_start_ms';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;
    final hasAuth = options.headers.containsKey('Authorization');
    debugPrint('[API] -> ${options.method} ${options.uri} (auth: $hasAuth)');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final elapsed = _elapsedMs(response.requestOptions);
    debugPrint(
      '[API] <- ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.path} ($elapsed ms)',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final elapsed = _elapsedMs(err.requestOptions);
    final status = err.response?.statusCode ?? 'NET';
    final code = ErrorMapper.extractCode(err.response?.data);
    debugPrint(
      '[API] !! $status ${err.requestOptions.method} '
      '${err.requestOptions.path} ($elapsed ms, type: ${err.type.name}'
      '${code != null ? ', code: $code' : ''})',
    );
    handler.next(err);
  }

  int _elapsedMs(RequestOptions options) {
    final start = options.extra[_startTimeKey];
    if (start is int) {
      return DateTime.now().millisecondsSinceEpoch - start;
    }
    return 0;
  }
}
