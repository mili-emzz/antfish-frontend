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
    // `serverClientId` = Web Client ID: es el `aud` que valida el backend.
    // `clientId` = Android/iOS Client ID según plataforma.
    return _initialization ??= _googleSignIn.initialize(
      clientId: EnvConfig.googleAndroidClientId.isEmpty
          ? null
          : EnvConfig.googleAndroidClientId,
      serverClientId: EnvConfig.googleWebClientId.isEmpty
          ? null
          : EnvConfig.googleWebClientId,
    );
  }

  /// Devuelve el `id_token` o `null` si el usuario cancela.
  Future<String?> obtainIdToken() async {
    try {
      await _ensureInitialized();
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const UnauthorizedFailure(
          message: AppStrings.googleNoCredential,
          code: 'GOOGLE_NO_ID_TOKEN',
        );
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      throw UnknownFailure(
        message: AppStrings.googleGenericError,
        code: 'GOOGLE_SIGN_IN_ERROR',
        originalException: e,
      );
    }
  }
}
