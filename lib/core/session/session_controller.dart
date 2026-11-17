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

  Future<void> signIn({
    required String accessToken,
    required String refreshToken,
    String? userEmail,
    String authProvider = 'local',
  }) async {
    await _storage.saveRefreshToken(refreshToken);
    _state = SessionAuthenticated(
      accessToken: accessToken,
      userEmail: userEmail,
      authProvider: authProvider,
    );
    notifyListeners();
  }

  /// Logout local: no existe endpoint de revocación en el backend.
  Future<void> signOut() async {
    await _storage.clear();
    _state = const SessionUnauthenticated();
    notifyListeners();
  }
}
