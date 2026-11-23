import '../models/user_metrics.dart';

/// Contrato del repositorio de métricas de usuario (`GET /api/v1/metrics/me`).
abstract interface class MetricsRepository {
  Future<UserMetrics> getMyMetrics();
}
