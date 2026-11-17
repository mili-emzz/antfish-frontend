import 'package:dio/dio.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/network/error_mapper.dart';
import '../../../l10n/app_strings.dart';
import '../domain/models/auth_session.dart';

/// Acceso remoto a los endpoints de autenticación.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// `POST /auth/google` con `{ "id_token": ... }`.
  /// Nunca se reintenta automáticamente (AGENTS.md §7).
  Future<AuthSession> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/google',
        data: {'id_token': idToken},
      );
      return _parseSession(response.data);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  // Contrato de respuesta pendiente de validar con OpenAPI (CoVE #5).
  AuthSession _parseSession(Map<String, dynamic>? json) {
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
      email: (userMap['email'] ?? json?['email']) as String?,
      nombre: (userMap['nombre'] ?? json?['nombre']) as String?,
      proveedorAuth:
          (userMap['proveedor_auth'] ?? json?['proveedor_auth'] ?? 'google')
              as String,
    );
  }
}
