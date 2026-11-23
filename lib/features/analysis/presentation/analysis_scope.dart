import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core/errors/app_failure.dart';
import '../../../l10n/app_strings.dart';
import '../domain/models/analysis_result.dart';
import '../domain/repositories/analysis_repository.dart';

/// Controlador reactivo del flujo de análisis e historial
/// (`POST /analysis`, `GET /analysis`, `GET /analysis/{id}`, `DELETE /analysis/{id}`).
///
/// Privacidad (`AGENTS.md` §8): nunca persiste ni registra en consola el texto
/// del SMS enviado a analizar.
class AnalysisController extends ChangeNotifier {
  AnalysisController({this.repository, this.onAnalysisCompleted});

  final AnalysisRepository? repository;

  /// Callback opcional ejecutado tras un análisis exitoso (ej. refrescar métricas).
  final VoidCallback? onAnalysisCompleted;

  bool get hasBackend => repository != null;

  AnalysisResult? _latestResult;
  AnalysisResult? get latestResult => _latestResult;

  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  String? _analyzeError;
  String? get analyzeError => _analyzeError;

  List<AnalysisResult> _history = const [];
  List<AnalysisResult> get history => _history;

  String? _nextCursor;
  String? get nextCursor => _nextCursor;
  bool get hasMoreHistory => _nextCursor != null;

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasLoadedHistory = false;
  bool get hasLoadedHistory => _hasLoadedHistory;

  String? _historyError;
  String? get historyError => _historyError;

  /// Envía una URL o SMS a `POST /api/v1/analysis`.
  ///
  /// Bloquea envíos concurrentes y nunca reintenta automáticamente (`AGENTS.md` §7).
  Future<AnalysisResult?> submitAnalysis({
    required String tipoEntrada,
    required String contenido,
  }) async {
    final repo = repository;
    if (repo == null || _isAnalyzing) return null;

    _isAnalyzing = true;
    _analyzeError = null;
    notifyListeners();

    try {
      final result = await repo.analyze(
        tipoEntrada: tipoEntrada,
        contenido: contenido,
      );
      _latestResult = result;
      _history = [result, ..._history.where((item) => item.id != result.id)];
      _hasLoadedHistory = true;
      if (kDebugMode) {
        debugPrint(
          '[ANALYSIS] Completado (tipo=$tipoEntrada, score=${result.scoreTotal}, '
          'riesgo=${result.nivelRiesgo.name}, parcial=${result.analisisParcial})',
        );
      }
      onAnalysisCompleted?.call();
      return result;
    } on AppFailure catch (f) {
      _analyzeError = f.message;
      if (kDebugMode) debugPrint('[ANALYSIS] Error (${f.code})');
      return null;
    } catch (_) {
      _analyzeError = AppStrings.analysisSubmitError;
      return null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Carga la primera página del historial (`GET /api/v1/analysis`).
  Future<void> loadHistory({bool force = false}) async {
    final repo = repository;
    if (repo == null || _isLoadingHistory) return;
    if (_hasLoadedHistory && !force) return;

    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      final page = await repo.getHistory();
      _history = page.items;
      _nextCursor = page.nextCursor;
      _hasLoadedHistory = true;
      if (kDebugMode) {
        debugPrint(
          '[ANALYSIS] Historial cargado (${page.items.length} elementos, '
          'nextCursor=${page.nextCursor != null})',
        );
      }
    } on AppFailure catch (f) {
      _historyError = f.message;
      if (kDebugMode) debugPrint('[ANALYSIS] Error historial (${f.code})');
    } catch (_) {
      _historyError = AppStrings.historyLoadError;
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Carga la siguiente página del historial usando `next_cursor`.
  Future<void> loadMoreHistory() async {
    final repo = repository;
    final cursor = _nextCursor;
    if (repo == null || cursor == null || _isLoadingMore || _isLoadingHistory) {
      return;
    }

    _isLoadingMore = true;
    _historyError = null;
    notifyListeners();

    try {
      final page = await repo.getHistory(cursor: cursor);
      final existingIds = _history.map((e) => e.id).toSet();
      final appended = [
        ..._history,
        ...page.items.where((item) => !existingIds.contains(item.id)),
      ];
      _history = appended;
      _nextCursor = page.nextCursor;
    } on AppFailure catch (f) {
      _historyError = f.message;
      if (kDebugMode) debugPrint('[ANALYSIS] Error paginando (${f.code})');
    } catch (_) {
      _historyError = AppStrings.historyLoadError;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Obtiene el detalle actualizado de un análisis (`GET /api/v1/analysis/{id}`).
  Future<AnalysisResult?> fetchDetail(String id) async {
    final repo = repository;
    if (repo == null) return null;
    try {
      return await repo.getAnalysisById(id);
    } on AppFailure {
      return null;
    }
  }

  /// Elimina un análisis del historial (`DELETE /api/v1/analysis/{id}`).
  ///
  /// Retorna `null` si tuvo éxito o un mensaje de error si falló.
  Future<String?> deleteHistoryItem(String id) async {
    final repo = repository;
    if (repo == null) return AppStrings.templateBackendPending;

    try {
      await repo.deleteAnalysis(id);
      _history = _history.where((item) => item.id != id).toList();
      if (_latestResult?.id == id) {
        _latestResult = null;
      }
      notifyListeners();
      return null;
    } on AppFailure catch (f) {
      return f.message;
    } catch (_) {
      return AppStrings.analysisDeleteError;
    }
  }

  void dismissLatestResult() {
    if (_latestResult == null) return;
    _latestResult = null;
    notifyListeners();
  }

  void dismissAnalyzeError() {
    if (_analyzeError == null) return;
    _analyzeError = null;
    notifyListeners();
  }

  /// Limpia todo el estado en memoria (p. ej. al cerrar sesión).
  void reset() {
    _latestResult = null;
    _isAnalyzing = false;
    _analyzeError = null;
    _history = const [];
    _nextCursor = null;
    _isLoadingHistory = false;
    _isLoadingMore = false;
    _hasLoadedHistory = false;
    _historyError = null;
    notifyListeners();
  }
}

/// Provee [AnalysisController] al árbol de widgets.
class AnalysisScope extends InheritedNotifier<AnalysisController> {
  const AnalysisScope({
    super.key,
    required AnalysisController controller,
    required super.child,
  }) : super(notifier: controller);

  static AnalysisController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AnalysisScope>()?.notifier;
}
