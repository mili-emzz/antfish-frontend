import '../../core/network/api_client.dart';
import '../../core/session/session_controller.dart';
import 'data/analysis_remote_data_source.dart';
import 'data/analysis_repository_impl.dart';
import 'domain/repositories/analysis_repository.dart';

/// Punto de composición: crea el repositorio real de análisis conectado a Dio.
AnalysisRepository createAnalysisRepository({
  SessionController? session,
  void Function()? onUnauthorized,
}) => AnalysisRepositoryImpl(
  AnalysisRemoteDataSource(
    createApiClient(session: session, onUnauthorized: onUnauthorized),
  ),
);
