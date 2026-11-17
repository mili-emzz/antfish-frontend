import 'package:dio/dio.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/network/error_mapper.dart';
import '../../../l10n/app_strings.dart';
import '../domain/models/auth_session.dart';
import '../domain/models/register_result.dart';

/// Acceso remoto a los endpoints de autenticación (`docs/contrato_api_v2.md`).
///
/// Ningún método reintenta automáticamente (`AGENTS.md` §7).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// Normaliza el correo: minúsculas y sin espacios (D5 / ADR #55).
  static String normalizeEmail(String email) => email.trim().toLowerCase();

  /// `POST /auth/register` → 201 con el usuario en `pendiente_verificacion`.
  Future<RegisterResult> register({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': normalizeEmail(email),
          'password': password,
          'nombre': nombre.trim(),
        },
      );
      return _parseRegister(response.data);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// `POST /auth/verify-email` con `{"email": ..., "codigo": ...}`.
  Future<String> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/verify-email',
        data: {'email': normalizeEmail(email), 'codigo': code.trim()},
      );
      final msg = response.data?['mensaje'];
      return msg is String && msg.isNotEmpty
          ? msg
          : AppStrings.verifySuccessDefault;
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// `POST /auth/resend-code` con `{"email": ...}`.
  Future<String> resendCode({required String email}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/resend-code',
        data: {'email': normalizeEmail(email)},
      );
      final msg = response.data?['mensaje'];
      return msg is String && msg.isNotEmpty
          ? msg
          : AppStrings.verifyResendDefault;
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// `POST /auth/login` → `{access_token, refresh_token, token_type, user}`.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final normalized = normalizeEmail(email);
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': normalized, 'password': password},
      );
      return _parseSession(
        response.data,
        email: normalized,
        defaultProvider: 'local',
      );
    } on DioException catch (e) {
      if (ErrorMapper.isAccountNotVerified(e)) {
        throw AccountNotVerifiedFailure(email: normalized);
      }
      throw ErrorMapper.fromDio(e);
    }
  }

  /// `POST /auth/google` con `{ "id_token": ... }`.
  Future<AuthSession> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/google',
        data: {'id_token': idToken},
      );
      return _parseSession(response.data, defaultProvider: 'google');
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  RegisterResult _parseRegister(Map<String, dynamic>? json) {
    final id = json?['id'];
    final email = json?['email'];
    if (id is! String || email is! String) {
      throw const UnknownFailure(
        message: AppStrings.serverInvalidResponse,
        code: 'INVALID_RESPONSE',
      );
    }
    return RegisterResult(
      id: id,
      email: email,
      nombre: json?['nombre'] as String?,
      estadoCuenta:
          (json?['estado_cuenta'] as String?) ?? 'pendiente_verificacion',
      emailVerificado: (json?['email_verificado'] as bool?) ?? false,
      mensaje: json?['mensaje'] as String?,
    );
  }

  AuthSession _parseSession(
    Map<String, dynamic>? json, {
    String? email,
    required String defaultProvider,
  }) {
    final access = json?['access_token'];
    final refresh = json?['refresh_token'];
    if (access is! String || refresh is! String) {
      throw const UnknownFailure(
        message: AppStrings.serverInvalidResponse,
        code: 'INVALID_RESPONSE',
      );
    }
    final user = json?['user'];
    final userMap = user is Map ? user : const {};
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      email: (userMap['email'] ?? json?['email'] ?? email) as String?,
      nombre: (userMap['nombre'] ?? json?['nombre']) as String?,
      proveedorAuth:
          (userMap['proveedor_auth'] ??
                  json?['proveedor_auth'] ??
                  defaultProvider)
              as String,
    );
  }
}
