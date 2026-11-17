import '../../core/network/api_client.dart';
import 'data/auth_remote_data_source.dart';
import 'data/auth_repository_impl.dart';
import 'data/google_auth_data_source.dart';
import 'domain/repositories/auth_repository.dart';

/// Punto de composición: crea el repositorio real de autenticación.
AuthRepository createAuthRepository() => AuthRepositoryImpl(
  google: GoogleAuthDataSource(),
  remote: AuthRemoteDataSource(createApiClient()),
);
