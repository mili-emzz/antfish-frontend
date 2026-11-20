import 'package:dio/dio.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/network/error_mapper.dart';
import '../../../l10n/app_strings.dart';
import '../domain/models/user_metrics.dart';

/// Acceso remoto a `GET /api/v1/metrics/me` (`docs/contrato_api_v2.md` §3).
class MetricsRemoteDataSource {
  MetricsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserMetrics> fetchMyMetrics() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/metrics/me');
      final data = response.data;
      if (data == null) {
        throw const UnknownFailure(
          message: AppStrings.serverInvalidResponse,
          code: 'INVALID_RESPONSE',
        );
      }
      return UserMetrics.fromJson(data);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }
}
