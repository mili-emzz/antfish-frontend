import 'package:flutter/foundation.dart';

import '../storage/token_storage.dart';
import 'session_state.dart';

/// Controla el estado reactivo de sesión. El `access_token` solo vive en
/// memoria; el `refresh_token` se persiste vía [TokenStorage].
class SessionController extends ChangeNotifier {
  SessionController(this._storage);

  final TokenStorage _storage;

  SessionState _state = const SessionUnauthenticated();
  SessionState get state => _state;

  /// Devuelve el `access_token` en memoria si la sesión está autenticada.
  String? get accessToken => switch (_state) {
    SessionAuthenticated(:final accessToken) => accessToken,
    _ => null,
  };

  /// Lee el `refresh_token` persistido en almacenamiento seguro.
  Future<String?> readRefreshToken() => _storage.readRefreshToken();

  Future<void> signIn({
    required String accessToken,
    required String refreshToken,
    String? userEmail,
    String? userName,
    String authProvider = 'local',
  }) async {
    await _storage.saveRefreshToken(refreshToken);
    _state = SessionAuthenticated(
      accessToken: accessToken,
      userEmail: userEmail,
      userName: userName,
      authProvider: authProvider,
    );
    if (kDebugMode) {
      debugPrint('[SESSION] Autenticada (provider: $authProvider)');
    }
    notifyListeners();
  }

  /// Actualiza el `access_token` en memoria tras un `POST /auth/refresh` exitoso.
  void updateAccessToken(String newAccessToken) {
    final current = _state;
    if (current is SessionAuthenticated) {
      _state = SessionAuthenticated(
        accessToken: newAccessToken,
        userEmail: current.userEmail,
        userName: current.userName,
        authProvider: current.authProvider,
      );
    } else {
      _state = SessionAuthenticated(accessToken: newAccessToken);
    }
    if (kDebugMode) {
      debugPrint('[SESSION] Access token renovado en memoria');
    }
    notifyListeners();
  }

  /// Cuenta registrada o sin verificar: se espera el código de 6 dígitos.
  void markPendingVerification(String email) {
    _state = SessionPendingVerification(email: email);
    if (kDebugMode) {
      debugPrint('[SESSION] Estado -> pendingVerification');
    }
    notifyListeners();
  }

  /// Logout local: limpia `refresh_token`, `access_token` y datos de usuario.
  Future<void> signOut() async {
    await _storage.clear();
    _state = const SessionUnauthenticated();
    if (kDebugMode) {
      debugPrint('[SESSION] Sesión cerrada y almacenamiento limpiado');
    }
    notifyListeners();
  }
}
