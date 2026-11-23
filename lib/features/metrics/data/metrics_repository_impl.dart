import '../domain/models/user_metrics.dart';
import '../domain/repositories/metrics_repository.dart';
import 'metrics_remote_data_source.dart';

class MetricsRepositoryImpl implements MetricsRepository {
  MetricsRepositoryImpl(this._remote);

  final MetricsRemoteDataSource _remote;

  @override
  Future<UserMetrics> getMyMetrics() => _remote.fetchMyMetrics();
}
