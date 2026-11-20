import '../models/analysis_result.dart';

/// Contrato del repositorio de análisis e historial (`docs/contrato_api_v2.md` §2).
abstract interface class AnalysisRepository {
  /// `POST /api/v1/analysis` (nunca reintenta automáticamente).
  Future<AnalysisResult> analyze({
    required String tipoEntrada,
    required String contenido,
  });

  /// `GET /api/v1/analysis` con paginación por cursor opaco.
  Future<AnalysisHistoryPage> getHistory({String? cursor});

  /// `GET /api/v1/analysis/{analysis_id}`.
  Future<AnalysisResult> getAnalysisById(String id);

  /// `DELETE /api/v1/analysis/{analysis_id}`.
  Future<void> deleteAnalysis(String id);
}
