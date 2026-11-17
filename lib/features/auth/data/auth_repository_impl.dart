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
}
