import 'package:dio/dio.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/network/error_mapper.dart';
import '../../../l10n/app_strings.dart';
import '../domain/models/analysis_result.dart';

/// Acceso remoto a los endpoints de análisis (`docs/contrato_api_v2.md` §2).
///
/// Reglas estrictas (`AGENTS.md` §7 y §8):
/// - NUNCA reintentar automáticamente `POST /analysis`.
/// - NUNCA imprimir ni persistir el contenido de un SMS analizado.
class AnalysisRemoteDataSource {
  AnalysisRemoteDataSource(this._dio);

  final Dio _dio;

  /// `POST /analysis` → 200 OK con [AnalysisResult].
  Future<AnalysisResult> analyze({
    required String tipoEntrada,
    required String contenido,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/analysis',
        data: {'tipo_entrada': tipoEntrada, 'contenido': contenido},
      );
      final data = response.data;
      if (data == null) {
        throw const UnknownFailure(
          message: AppStrings.serverInvalidResponse,
          code: 'INVALID_RESPONSE',
        );
      }
      return AnalysisResult.fromJson(data);
    } on DioException catch (e) {
      if (ErrorMapper.isAccountNotVerified(e)) {
        throw const AccountNotVerifiedFailure(email: '');
      }
      throw ErrorMapper.fromDio(e);
    }
  }

  /// `GET /analysis?cursor=...` → 200 OK con [AnalysisHistoryPage].
  Future<AnalysisHistoryPage> getHistory({String? cursor}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/analysis',
        queryParameters: cursor != null && cursor.isNotEmpty
            ? {'cursor': cursor}
            : null,
      );
      final data = response.data;
      if (data == null) {
        throw const UnknownFailure(
          message: AppStrings.serverInvalidResponse,
          code: 'INVALID_RESPONSE',
        );
      }
      return AnalysisHistoryPage.fromJson(data);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// `GET /analysis/{id}` → 200 OK con [AnalysisResult].
  Future<AnalysisResult> getAnalysisById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/analysis/$id');
      final data = response.data;
      if (data == null) {
        throw const UnknownFailure(
          message: AppStrings.serverInvalidResponse,
          code: 'INVALID_RESPONSE',
        );
      }
      return AnalysisResult.fromJson(data);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// `DELETE /analysis/{id}` → 204 No Content.
  Future<void> deleteAnalysis(String id) async {
    try {
      await _dio.delete<void>('/analysis/$id');
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }
}
