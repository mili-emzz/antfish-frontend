import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env_config.dart';
import '../session/session_controller.dart';
import 'auth_interceptor.dart';
import 'error_mapper.dart';

/// Evita repetir el log de configuración y healthcheck por cada repositorio
/// que instancia su propio cliente Dio al arrancar la app.
bool _didRunStartupCheck = false;

/// Reinicia el estado de verificación inicial (exclusivo para pruebas).
@visibleForTesting
void resetApiClientStartupCheckForTesting() {
  _didRunStartupCheck = false;
}

/// Crea la instancia base de Dio con los timeouts del contrato
/// (5 s conexión, 10 s recepción). Sin logging de bodies ni credenciales.
///
/// Si se proporciona [session], instala [AuthRefreshInterceptor] para adjuntar
/// `Authorization: Bearer <access_token>` y renovar tokens en 401 concurrentes.
Dio createApiClient({
  String? baseUrl,
  SessionController? session,
  void Function()? onUnauthorized,
  bool runStartupHealthCheck = true,
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
    if (runStartupHealthCheck && !_didRunStartupCheck) {
      _didRunStartupCheck = true;
      debugPrint('[API] Base URL configurada: $effectiveBaseUrl');
      unawaited(verifyBackendHealth(dio: dio));
    }
  }

  return dio;
}

/// Resuelve la URL del endpoint público `/health` a partir de `API_BASE_URL`.
///
/// En el backend AntFish, `/health` está montado en la raíz del servidor
/// (por ejemplo `https://184-193-101-215.sslip.io/health`), mientras que
/// `API_BASE_URL` incluye el prefijo `/api/v1`.
@visibleForTesting
String resolveHealthCheckUrl(String apiBaseUrl) {
  final trimmed = apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  final rootBase = trimmed.endsWith('/api/v1')
      ? trimmed.substring(0, trimmed.length - '/api/v1'.length)
      : trimmed;
  return '$rootBase/health';
}

/// Verifica la conectividad con la URL configurada consultando `GET /health`
/// e imprime en consola (`debugPrint`) el estado y tiempo de respuesta.
///
/// Nunca lanza excepciones ni expone credenciales o datos sensibles.
Future<bool> verifyBackendHealth({Dio? dio, String? baseUrl}) async {
  final effectiveBaseUrl =
      (baseUrl ?? dio?.options.baseUrl ?? EnvConfig.apiBaseUrl).trim();
  if (effectiveBaseUrl.isEmpty) {
    if (kDebugMode) {
      debugPrint(
        '[API-CHECK] No se pudo verificar el backend: API_BASE_URL está vacío.',
      );
    }
    return false;
  }

  final healthUrl = resolveHealthCheckUrl(effectiveBaseUrl);
  final client =
      dio ??
      Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
          responseType: ResponseType.json,
        ),
      );

  final stopwatch = Stopwatch()..start();
  if (kDebugMode) {
    debugPrint(
      '[API-CHECK] Verificando conectividad con backend -> GET $healthUrl '
      '(API base: $effectiveBaseUrl)',
    );
  }

  try {
    final response = await client.get<Map<String, dynamic>>(healthUrl);
    stopwatch.stop();
    final statusField = response.data?['status'] ?? 'desconocido';
    if (kDebugMode) {
      debugPrint(
        '[API-CHECK] OK (${response.statusCode}) en '
        '${stopwatch.elapsedMilliseconds} ms | status: $statusField | '
        'URL base operativa: $effectiveBaseUrl',
      );
    }
    return response.statusCode == 200;
  } on DioException catch (e) {
    stopwatch.stop();
    final httpStatus = e.response?.statusCode ?? 'NET_ERR';
    final code = ErrorMapper.extractCode(e.response?.data);
    if (kDebugMode) {
      debugPrint(
        '[API-CHECK] FALLO ($httpStatus) en '
        '${stopwatch.elapsedMilliseconds} ms al conectar con $healthUrl '
        '(type: ${e.type.name}${code != null ? ', code: $code' : ''})',
      );
    }
    return false;
  } catch (e) {
    stopwatch.stop();
    if (kDebugMode) {
      debugPrint(
        '[API-CHECK] FALLO inesperado al verificar $healthUrl '
        '(${e.runtimeType})',
      );
    }
    return false;
  }
}

/// Interceptor de diagnóstico seguro para desarrollo (`kDebugMode`).
///
/// Registra únicamente método, URI completa, estado HTTP, código de error y
/// latencia; nunca imprime bodies, tokens JWT, contraseñas ni códigos de
/// verificación (`AGENTS.md` §8).
class _SafeFlowLogInterceptor extends Interceptor {
  static const String _startTimeKey = '_debug_start_ms';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;
    final hasAuth = options.headers.containsKey('Authorization');
    debugPrint(
      '[API] -> ${options.method} ${options.uri} '
      '(baseUrl: ${options.baseUrl}, path: ${options.path}, auth: $hasAuth)',
    );
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
      '${response.requestOptions.uri} ($elapsed ms)',
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
      '${err.requestOptions.uri} ($elapsed ms, type: ${err.type.name}'
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
