import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/env_config.dart';
import '../../../core/errors/app_failure.dart';
import '../../../l10n/app_strings.dart';

/// Envuelve el SDK oficial `google_sign_in` (v7) y obtiene el `id_token`.
class GoogleAuthDataSource {
  GoogleAuthDataSource({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;
  Future<void>? _initialization;

  Future<void> _ensureInitialized() {
    // En Web `serverClientId` no está soportado y `clientId` debe ser el Web Client ID.
    // En Android/iOS `serverClientId` es el Web Client ID (el `aud` del backend).
    final String? clientId = kIsWeb
        ? (EnvConfig.googleWebClientId.isEmpty
              ? null
              : EnvConfig.googleWebClientId)
        : (EnvConfig.googleAndroidClientId.isEmpty
              ? null
              : EnvConfig.googleAndroidClientId);
    final String? serverClientId = kIsWeb || EnvConfig.googleWebClientId.isEmpty
        ? null
        : EnvConfig.googleWebClientId;

    return _initialization ??= _googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
  }

  /// Devuelve el `id_token` o `null` si el usuario cancela.
  Future<String?> obtainIdToken() async {
    try {
      await _ensureInitialized();
      if (kDebugMode) {
        debugPrint(
          '[AUTH] GoogleSignIn inicializado (web: $kIsWeb, '
          'supportsAuthenticate: ${_googleSignIn.supportsAuthenticate()})',
        );
      }

      GoogleSignInAccount? account;
      if (_googleSignIn.supportsAuthenticate()) {
        account = await _googleSignIn.authenticate();
      } else {
        account = await _googleSignIn.attemptLightweightAuthentication();
        if (account == null) {
          throw const UnknownFailure(
            message: AppStrings.googleWebUnsupported,
            code: 'GOOGLE_WEB_UNSUPPORTED',
          );
        }
      }

      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const UnauthorizedFailure(
          message: AppStrings.googleNoCredential,
          code: 'GOOGLE_NO_ID_TOKEN',
        );
      }
      if (kDebugMode) {
        debugPrint(
          '[AUTH] GoogleSignIn obtuvo id_token (no registrado en log)',
        );
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        if (kDebugMode) {
          debugPrint('[AUTH] GoogleSignIn cancelado por el usuario');
        }
        return null;
      }
      if (kDebugMode) {
        debugPrint('[AUTH] GoogleSignInException (${e.code.name})');
      }
      throw UnknownFailure(
        message: AppStrings.googleGenericError,
        code: 'GOOGLE_SIGN_IN_ERROR',
        originalException: e,
      );
    }
  }
}
