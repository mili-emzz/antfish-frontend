import 'package:antfish/app.dart';
import 'package:antfish/core/router/app_routes.dart';
import 'package:antfish/core/ui/widgets/risk_badge.dart';
import 'package:antfish/features/analysis/analysis.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAnalysisRepository implements AnalysisRepository {
  _FakeAnalysisRepository(this.sample);

  final AnalysisResult sample;

  @override
  Future<AnalysisResult> analyze({
    required String tipoEntrada,
    required String contenido,
  }) async => sample;

  @override
  Future<AnalysisHistoryPage> getHistory({
    int limit = 20,
    String? cursor,
  }) async => AnalysisHistoryPage(items: [sample]);

  @override
  Future<AnalysisResult> getAnalysisById(String id) async => sample;

  @override
  Future<void> deleteAnalysis(String id) async {}
}

final _sampleAnalysis = AnalysisResult(
  id: 'an-001',
  tipoEntrada: 'url',
  scoreTotal: 92,
  nivelRiesgo: RiskLevel.critico,
  puntosPorCapa: const {'apis': 60, 'url': 32},
  analisisParcial: true,
  fechaAnalisis: DateTime(2026, 11, 20, 12, 0),
  motivoCortocircuito: 'lista_negra',
  urlsExtraidas: const [
    ExtractedUrl(
      url: 'https://secure-bbva-access.xyz/login',
      dominio: 'secure-bbva-access.xyz',
    ),
    ExtractedUrl(
      url: 'https://bit.ly/promo-bbva',
      dominio: 'bit.ly',
      flagsSintacticos: ['acortador_url'],
    ),
  ],
  hallazgos: const [
    AnalysisFinding(
      reglaCodigo: 'BL_01',
      titulo: 'Dominio reportado en lista negra',
      descripcion: 'El dominio coincide con campañas activas de phishing.',
      puntos: 85,
    ),
  ],
  recomendaciones: const ['No ingreses credenciales ni abras este enlace.'],
  fuentesConsultadas: const [
    ConsultedSource(
      api: 'Google Web Risk',
      estado: 'ok',
      positivo: true,
      detecciones: 2,
      desdeCache: false,
    ),
  ],
);

Future<void> _pumpHome(
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
      initialRoute: AppRoutes.home,
      analysisRepository: analysisRepository,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HomeScreen (Fase 2)', () {
    testWidgets(
      'Renderiza cabecera, saludo, escáner y semáforo sin recientes',
      (tester) async {
        await _pumpHome(tester);

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text(AppStrings.homeGreeting), findsOneWidget);
        expect(find.byType(ScannerCard), findsOneWidget);
        expect(find.byType(RiskTrafficLightCard), findsOneWidget);
        expect(find.text(AppStrings.recentTitle), findsNothing);
      },
    );

    testWidgets('Conmutador URL / SMS cambia el hint del campo', (
      tester,
    ) async {
      await _pumpHome(tester);

      expect(find.text(AppStrings.homeInputUrlHint), findsOneWidget);

      await tester.tap(find.text(AppStrings.homeTypeSms));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.homeInputSmsHint), findsOneWidget);
    });

    testWidgets('Escribir en el campo muestra el botón de limpiar y funciona', (
      tester,
    ) async {
      await _pumpHome(tester);

      final textField = find.byType(TextField);
      expect(find.text('×'), findsNothing);

      await tester.enterText(textField, 'https://phishing-test.com');
      await tester.pumpAndSettle();

      expect(find.text('×'), findsOneWidget);

      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();

      expect(find.text('×'), findsNothing);
      expect(find.text('https://phishing-test.com'), findsNothing);
    });

    testWidgets('El botón Analizar ahora está deshabilitado sin backend', (
      tester,
    ) async {
      await _pumpHome(tester);

      // Incluso escribiendo texto, el botón no dispara peticiones
      await tester.enterText(find.byType(TextField), 'https://test.com');
      await tester.pumpAndSettle();

      final button = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.text(AppStrings.homeScanSubmit),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(button.opacity, 0.55);
    });

    testWidgets('initialShowResult muestra ResultCard y permite cerrarla', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeScreen(initialShowResult: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ResultCard), findsOneWidget);
      expect(find.text(AppStrings.resultCriticalTitle), findsOneWidget);
      expect(find.byType(RiskTrafficLightCard), findsNothing);

      // Cerrar la tarjeta de resultado
      final closeButton = find.bySemanticsLabel(AppStrings.alertDismiss);
      await tester.ensureVisible(closeButton);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.byType(ResultCard), findsNothing);
      expect(find.byType(RiskTrafficLightCard), findsOneWidget);
    });

    testWidgets('Analizar con backend abre AnalysisReportSheet completo', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        analysisRepository: _FakeAnalysisRepository(_sampleAnalysis),
      );

      await tester.enterText(
        find.byType(TextField),
        'https://secure-bbva-access.xyz/login',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.homeScanSubmit));
      await tester.pumpAndSettle();

      final sheet = find.byType(AnalysisReportSheet);
      expect(sheet, findsOneWidget);
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(AppStrings.analysisDetailTitle),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(AppStrings.resultPartialWarning),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text('https://secure-bbva-access.xyz/login'),
        ),
        findsOneWidget,
      );
      final findingFinder = find.descendant(
        of: sheet,
        matching: find.text('Dominio reportado en lista negra'),
      );
      await tester.scrollUntilVisible(
        findingFinder,
        250,
        scrollable: find
            .descendant(of: sheet, matching: find.byType(Scrollable))
            .first,
      );
      await tester.pumpAndSettle();

      expect(findingFinder, findsOneWidget);
    });

    testWidgets('Sin overflow en pantallas de 320x568 y texto al 200 %', (
      tester,
    ) async {
      await _pumpHome(tester, size: const Size(320, 568), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });
}
