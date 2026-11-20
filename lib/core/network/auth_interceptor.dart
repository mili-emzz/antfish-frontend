import 'package:dio/dio.dart';

import '../session/session_controller.dart';
import 'error_mapper.dart';

/// Interceptor de autenticación Bearer y renovación Single-Flight de tokens
/// (`AGENTS.md` §7 y `docs/contrato_api_v2.md`).
///
/// - En `onRequest`: adjunta `Authorization: Bearer <access_token>` en rutas
///   protegidas cuando existe un token en memoria.
/// - En `onError`: ante un HTTP 401 en rutas protegidas, encola las peticiones
///   concurrentes y ejecuta una única llamada a `POST /auth/refresh`.
/// - Si la respuesta es 403 `ACCOUNT_NOT_VERIFIED`, NO intenta refrescar.
/// - Si `/auth/refresh` falla con 401/403, limpia la sesión (`signOut()`) e
///   invoca [onUnauthorized] si fue provisto.
class AuthRefreshInterceptor extends Interceptor {
  AuthRefreshInterceptor({
    required Dio dio,
    required this.session,
    Dio? refreshDio,
    this.onUnauthorized,
  }) : _dio = dio,
       _refreshDio =
           refreshDio ??
           Dio(
             BaseOptions(
               baseUrl: dio.options.baseUrl,
               connectTimeout: dio.options.connectTimeout,
               receiveTimeout: dio.options.receiveTimeout,
               contentType: Headers.jsonContentType,
               responseType: ResponseType.json,
             ),
           );

  static const String _retriedKey = '_auth_retried';

  static const Set<String> _publicAuthPaths = <String>{
    '/auth/register',
    '/auth/verify-email',
    '/auth/resend-code',
    '/auth/login',
    '/auth/google',
    '/auth/refresh',
    '/auth/password/forgot',
    '/auth/password/reset',
    '/health',
  };

  final Dio _dio;
  final Dio _refreshDio;
  final SessionController session;
  final void Function()? onUnauthorized;

  Future<String?>? _refreshFuture;

  bool _isPublicPath(String path) {
    for (final publicPath in _publicAuthPaths) {
      if (path == publicPath || path.endsWith(publicPath)) return true;
    }
    return false;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = session.accessToken;
    if (token != null &&
        token.isNotEmpty &&
        !_isPublicPath(options.path) &&
        !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final options = err.requestOptions;

    // 403 ACCOUNT_NOT_VERIFIED u otros códigos distintos de 401 no refrescan.
    if (statusCode != 401 ||
        ErrorMapper.isAccountNotVerified(err) ||
        _isPublicPath(options.path) ||
        options.extra[_retriedKey] == true) {
      handler.next(err);
      return;
    }

    final newAccessToken = await (_refreshFuture ??= _refreshAccessToken());
    if (newAccessToken == null) {
      handler.next(err);
      return;
    }

    try {
      final retryHeaders = Map<String, dynamic>.from(options.headers)
        ..['Authorization'] = 'Bearer $newAccessToken';
      final retryExtra = Map<String, dynamic>.from(options.extra)
        ..[_retriedKey] = true;

      final response = await _dio.fetch<dynamic>(
        options.copyWith(headers: retryHeaders, extra: retryExtra),
      );
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshAccessToken() async {
    try {
      final refreshToken = await session.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _expireSession();
        return null;
      }

      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final newAccess = response.data?['access_token'];
      if (newAccess is! String || newAccess.isEmpty) {
        await _expireSession();
        return null;
      }

      session.updateAccessToken(newAccess);
      return newAccess;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _expireSession();
      }
      return null;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<void> _expireSession() async {
    await session.signOut();
    onUnauthorized?.call();
  }
}
