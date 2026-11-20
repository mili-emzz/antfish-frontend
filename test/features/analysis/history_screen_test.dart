import 'package:antfish/app.dart';
import 'package:antfish/core/router/app_routes.dart';
import 'package:antfish/core/ui/widgets/risk_badge.dart';
import 'package:antfish/features/analysis/analysis.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHistoryRepository implements AnalysisRepository {
  _FakeHistoryRepository(List<AnalysisResult> initial)
    : _items = List<AnalysisResult>.from(initial);

  final List<AnalysisResult> _items;
  String? lastDeletedId;

  @override
  Future<AnalysisResult> analyze({
    required String tipoEntrada,
    required String contenido,
  }) async => _items.first;

  @override
  Future<AnalysisHistoryPage> getHistory({
    int limit = 20,
    String? cursor,
  }) async => AnalysisHistoryPage(items: List<AnalysisResult>.from(_items));

  @override
  Future<AnalysisResult> getAnalysisById(String id) async =>
      _items.firstWhere((e) => e.id == id);

  @override
  Future<void> deleteAnalysis(String id) async {
    lastDeletedId = id;
    _items.removeWhere((e) => e.id == id);
  }
}

Future<void> _pumpHistory(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1.0,
  AnalysisRepository? analysisRepository,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    AntFishApp(
      initialRoute: AppRoutes.history,
      analysisRepository: analysisRepository,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HistoryScreen (Fase 3)', () {
    testWidgets('Renderiza cabecera, filtros y lista de análisis', (
      tester,
    ) async {
      await _pumpHistory(tester);

      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.text(AppStrings.historyTitle), findsOneWidget);
      expect(find.text(AppStrings.historyFilterAll), findsOneWidget);
      expect(find.text(AppStrings.historyFilterUrls), findsOneWidget);
      expect(find.text(AppStrings.historyFilterSms), findsOneWidget);
      expect(find.byType(HistoryRowItem), findsWidgets);
    });

    testWidgets('Filtros cambian el subconjunto de elementos mostrados', (
      tester,
    ) async {
      await _pumpHistory(tester);

      // En "Todos", debe haber 6 elementos (4 demo + 2 repetidos de App.tsx)
      final allCount = tester.widgetList(find.byType(HistoryRowItem)).length;
      expect(allCount, 6);

      // Filtrar por "Enlaces"
      await tester.tap(find.text(AppStrings.historyFilterUrls));
      await tester.pumpAndSettle();

      final urlCount = tester.widgetList(find.byType(HistoryRowItem)).length;
      expect(urlCount, lessThan(allCount));
      expect(urlCount, 3); // 2 URLs en demo + 1 en los 2 primeros

      // Filtrar por "Mensajes"
      await tester.tap(find.text(AppStrings.historyFilterSms));
      await tester.pumpAndSettle();

      final smsCount = tester.widgetList(find.byType(HistoryRowItem)).length;
      expect(smsCount, 3);
    });

    testWidgets(
      'Tocar un elemento del historial abre AnalysisReportSheet y permite eliminar',
      (tester) async {
        final repo = _FakeHistoryRepository([
          AnalysisResult(
            id: 'hist-1',
            tipoEntrada: 'url',
            scoreTotal: 75,
            nivelRiesgo: RiskLevel.alto,
            puntosPorCapa: const {'url': 75},
            analisisParcial: false,
            fechaAnalisis: DateTime(2026, 11, 20, 14, 30),
            urlsExtraidas: const [
              ExtractedUrl(
                url: 'https://alerta-bancaria.example',
                dominio: 'alerta-bancaria.example',
              ),
            ],
            hallazgos: const [
              AnalysisFinding(
                reglaCodigo: 'URL_01',
                titulo: 'Dominio sospechoso',
                descripcion: 'Estructura inusual en el enlace.',
                puntos: 75,
              ),
            ],
          ),
        ]);

        await _pumpHistory(tester, analysisRepository: repo);

        await tester.tap(find.byType(HistoryRowItem).first);
        await tester.pumpAndSettle();

        expect(find.byType(AnalysisReportSheet), findsOneWidget);
        expect(find.text('Dominio sospechoso'), findsOneWidget);

        final deleteBtn = find.text(AppStrings.analysisDetailDelete);
        await tester.ensureVisible(deleteBtn);
        await tester.tap(deleteBtn);
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.analysisDetailDelete).last);
        await tester.pumpAndSettle();

        expect(repo.lastDeletedId, 'hist-1');
        expect(find.byType(AnalysisReportSheet), findsNothing);
      },
    );

    testWidgets('Sin overflow en pantallas de 320x568 y texto al 200 %', (
      tester,
    ) async {
      await _pumpHistory(tester, size: const Size(320, 568), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });
}
