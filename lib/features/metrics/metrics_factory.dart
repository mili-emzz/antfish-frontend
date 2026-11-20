import '../../core/network/api_client.dart';
import '../../core/session/session_controller.dart';
import 'data/metrics_remote_data_source.dart';
import 'data/metrics_repository_impl.dart';
import 'domain/repositories/metrics_repository.dart';

/// Punto de composición: crea el repositorio real de métricas conectado a Dio.
MetricsRepository createMetricsRepository({
  SessionController? session,
  void Function()? onUnauthorized,
}) => MetricsRepositoryImpl(
  MetricsRemoteDataSource(
    createApiClient(session: session, onUnauthorized: onUnauthorized),
  ),
);
