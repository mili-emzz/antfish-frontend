import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core/errors/app_failure.dart';
import '../../../l10n/app_strings.dart';
import '../domain/models/user_metrics.dart';
import '../domain/repositories/metrics_repository.dart';

/// Controlador reactivo de las métricas del usuario (`GET /api/v1/metrics/me`).
class MetricsController extends ChangeNotifier {
  MetricsController({this.repository});

  final MetricsRepository? repository;

  UserMetrics _metrics = UserMetrics.empty;
  UserMetrics get metrics => _metrics;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasBackend => repository != null;

  /// Carga o refresca las métricas desde `GET /api/v1/metrics/me`.
  Future<void> refresh() async {
    final repo = repository;
    if (repo == null || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await repo.getMyMetrics();
      _metrics = data;
      _hasLoaded = true;
      if (kDebugMode) {
        debugPrint(
          '[METRICS] Cargadas: total=${data.totalEscaneos}, '
          'amenazas=${data.amenazasBloqueadas}',
        );
      }
    } on AppFailure catch (f) {
      _errorMessage = f.message;
      if (kDebugMode) debugPrint('[METRICS] Error (${f.code})');
    } catch (_) {
      _errorMessage = AppStrings.metricsLoadError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restablece las métricas en memoria (p. ej. al cerrar sesión).
  void reset() {
    _metrics = UserMetrics.empty;
    _hasLoaded = false;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}

/// Provee [MetricsController] al árbol de widgets.
class MetricsScope extends InheritedNotifier<MetricsController> {
  const MetricsScope({
    super.key,
    required MetricsController controller,
    required super.child,
  }) : super(notifier: controller);

  static MetricsController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MetricsScope>()?.notifier;
}
