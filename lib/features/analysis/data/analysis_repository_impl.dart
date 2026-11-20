import '../domain/models/analysis_result.dart';
import '../domain/repositories/analysis_repository.dart';
import 'analysis_remote_data_source.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  AnalysisRepositoryImpl(this._remote);

  final AnalysisRemoteDataSource _remote;

  @override
  Future<AnalysisResult> analyze({
    required String tipoEntrada,
    required String contenido,
  }) => _remote.analyze(tipoEntrada: tipoEntrada, contenido: contenido);

  @override
  Future<AnalysisHistoryPage> getHistory({String? cursor}) =>
      _remote.getHistory(cursor: cursor);

  @override
  Future<AnalysisResult> getAnalysisById(String id) =>
      _remote.getAnalysisById(id);

  @override
  Future<void> deleteAnalysis(String id) => _remote.deleteAnalysis(id);
}
