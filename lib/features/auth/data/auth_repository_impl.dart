import '../domain/models/auth_session.dart';
import '../domain/models/register_result.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_remote_data_source.dart';
import 'google_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._google, required this._remote});

  final GoogleAuthDataSource _google;
  final AuthRemoteDataSource _remote;

  @override
  Future<RegisterResult> register({
    required String email,
    required String password,
    required String nombre,
  }) => _remote.register(email: email, password: password, nombre: nombre);

  @override
  Future<String> verifyEmail({required String email, required String code}) =>
      _remote.verifyEmail(email: email, code: code);

  @override
  Future<String> resendCode({required String email}) =>
      _remote.resendCode(email: email);

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => _remote.login(email: email, password: password);

  @override
  Future<AuthSession?> signInWithGoogle() async {
    final idToken = await _google.obtainIdToken();
    if (idToken == null) return null; // El usuario canceló.
    // El id_token solo vive en esta variable local y se descarta al terminar.
    return _remote.loginWithGoogle(idToken);
  }

  @override
  Future<String> requestPasswordReset({required String email}) =>
      _remote.requestPasswordReset(email: email);

  @override
  Future<String> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) => _remote.confirmPasswordReset(
    email: email,
    code: code,
    newPassword: newPassword,
  );

  @override
  Future<void> deleteAccountWithPassword({required String password}) =>
      _remote.deleteAccount(password: password);

  @override
  Future<bool> deleteAccountWithGoogle() async {
    final idToken = await _google.obtainIdToken();
    if (idToken == null) return false; // El usuario canceló.
    // El id_token solo vive en esta variable local y se descarta al terminar.
    await _remote.deleteAccount(idToken: idToken);
    return true;
  }
}
