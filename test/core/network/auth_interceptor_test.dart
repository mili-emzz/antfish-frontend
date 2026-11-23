import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:antfish/core/network/api_client.dart';
import 'package:antfish/core/network/auth_interceptor.dart';
import 'package:antfish/core/session/session_controller.dart';
import 'package:antfish/core/session/session_state.dart';
import 'package:antfish/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryTokenStorage implements TokenStorage {
  String? token;

  @override
  Future<String?> readRefreshToken() async => token;

  @override
  Future<void> saveRefreshToken(String t) async => token = t;

  @override
  Future<void> clear() async => token = null;
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Map<String, dynamic> map, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(map),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  late _MemoryTokenStorage storage;
  late SessionController session;

  setUp(() async {
    storage = _MemoryTokenStorage();
    session = SessionController(storage);
    await session.signIn(
      accessToken: 'old_access',
      refreshToken: 'valid_refresh',
      userEmail: 'user@antfish.app',
      userName: 'Carlos Ramírez',
    );
  });

  test(
    'inyecta Authorization Bearer en rutas protegidas y no en públicas',
    () async {
      final headersByPath = <String, String?>{};
      final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
      dio.httpClientAdapter = _FakeAdapter((options) async {
        headersByPath[options.path] =
            options.headers['Authorization'] as String?;
        return _jsonBody({'status': 'ok'}, 200);
      });
      dio.interceptors.add(AuthRefreshInterceptor(dio: dio, session: session));

      await dio.get<Map<String, dynamic>>('/metrics/me');
      await dio.get<Map<String, dynamic>>('/health');

      expect(headersByPath['/metrics/me'], 'Bearer old_access');
      expect(headersByPath['/health'], isNull);
    },
  );

  test(
    'múltiples 401 concurrentes disparan un único POST /auth/refresh',
    () async {
      int refreshCalls = 0;
      final refreshCompleter = Completer<void>();

      final refreshDio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
      refreshDio.httpClientAdapter = _FakeAdapter((options) async {
        refreshCalls++;
        await refreshCompleter.future;
        return _jsonBody({
          'access_token': 'new_access',
          'token_type': 'bearer',
        }, 200);
      });

      final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
      dio.httpClientAdapter = _FakeAdapter((options) async {
        final auth = options.headers['Authorization'];
        if (auth == 'Bearer old_access') {
          return _jsonBody({'code': 'UNAUTHORIZED', 'detail': 'Expirado'}, 401);
        }
        return _jsonBody({'used_auth': auth}, 200);
      });
      dio.interceptors.add(
        AuthRefreshInterceptor(
          dio: dio,
          session: session,
          refreshDio: refreshDio,
        ),
      );

      final f1 = dio.get<Map<String, dynamic>>('/metrics/me');
      final f2 = dio.get<Map<String, dynamic>>('/analysis');
      final f3 = dio.get<Map<String, dynamic>>('/analysis/123');

      await Future<void>.delayed(const Duration(milliseconds: 20));
      refreshCompleter.complete();

      final results = await Future.wait([f1, f2, f3]);

      expect(refreshCalls, 1);
      expect(session.accessToken, 'new_access');
      for (final res in results) {
        expect(res.data?['used_auth'], 'Bearer new_access');
      }
    },
  );

  test('403 ACCOUNT_NOT_VERIFIED no intenta refrescar el token', () async {
    int refreshCalls = 0;
    final refreshDio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
    refreshDio.httpClientAdapter = _FakeAdapter((_) async {
      refreshCalls++;
      return _jsonBody({'access_token': 'new'}, 200);
    });

    final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
    dio.httpClientAdapter = _FakeAdapter((_) async {
      return _jsonBody({
        'code': 'ACCOUNT_NOT_VERIFIED',
        'detail': 'ACCOUNT_NOT_VERIFIED',
      }, 403);
    });
    dio.interceptors.add(
      AuthRefreshInterceptor(
        dio: dio,
        session: session,
        refreshDio: refreshDio,
      ),
    );

    await expectLater(
      dio.post<Map<String, dynamic>>('/analysis'),
      throwsA(isA<DioException>()),
    );
    expect(refreshCalls, 0);
    expect(session.state, isA<SessionAuthenticated>());
  });

  test(
    'si /auth/refresh responde 401, limpia la sesión e invoca onUnauthorized',
    () async {
      bool unauthorizedCalled = false;
      final refreshDio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
      refreshDio.httpClientAdapter = _FakeAdapter((_) async {
        return _jsonBody({
          'code': 'UNAUTHORIZED',
          'detail': 'Credenciales inválidas',
        }, 401);
      });

      final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
      dio.httpClientAdapter = _FakeAdapter((_) async {
        return _jsonBody({'code': 'UNAUTHORIZED', 'detail': 'Expirado'}, 401);
      });
      dio.interceptors.add(
        AuthRefreshInterceptor(
          dio: dio,
          session: session,
          refreshDio: refreshDio,
          onUnauthorized: () => unauthorizedCalled = true,
        ),
      );

      await expectLater(
        dio.get<Map<String, dynamic>>('/metrics/me'),
        throwsA(isA<DioException>()),
      );
      expect(unauthorizedCalled, isTrue);
      expect(session.state, isA<SessionUnauthenticated>());
      expect(await storage.readRefreshToken(), isNull);
    },
  );

  group('resolveHealthCheckUrl y verifyBackendHealth', () {
    setUp(resetApiClientStartupCheckForTesting);

    test('resuelve /health en la raíz del servidor cuando API_BASE_URL termina en /api/v1', () {
      expect(
        resolveHealthCheckUrl('https://184-193-101-215.sslip.io/api/v1'),
        'https://184-193-101-215.sslip.io/health',
      );
      expect(
        resolveHealthCheckUrl('https://184-193-101-215.sslip.io/api/v1/'),
        'https://184-193-101-215.sslip.io/health',
      );
    });

    test(
      'verifyBackendHealth retorna true cuando /health responde 200 OK',
      () async {
        String? requestedUri;
        final dio = createApiClient(
          baseUrl: 'https://184-193-101-215.sslip.io/api/v1',
          runStartupHealthCheck: false,
        );
        dio.httpClientAdapter = _FakeAdapter((options) async {
          requestedUri = options.uri.toString();
          return _jsonBody({'status': 'ok'}, 200);
        });

        final ok = await verifyBackendHealth(dio: dio);

        expect(ok, isTrue);
        expect(requestedUri, 'https://184-193-101-215.sslip.io/health');
      },
    );
  });
}
