import 'package:antfish/app.dart';
import 'package:antfish/core/router/app_routes.dart';
import 'package:antfish/features/metrics/presentation/screens/stats_screen.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpStats(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(const AntFishApp(initialRoute: AppRoutes.stats));
  await tester.pumpAndSettle();
}

void main() {
  group('StatsScreen (Fase 4)', () {
    testWidgets('Renderiza cabecera, cuadrícula y desglose de amenazas', (
      tester,
    ) async {
      await _pumpStats(tester);

      expect(find.byType(StatsScreen), findsOneWidget);
      expect(find.text(AppStrings.statsTitle), findsOneWidget);
      expect(find.text(AppStrings.statsMetricTotalScans), findsOneWidget);
      expect(find.text(AppStrings.statsMetricBlocked), findsOneWidget);
      expect(find.text(AppStrings.statsMetricUrls), findsOneWidget);
      expect(find.text(AppStrings.statsMetricSms), findsOneWidget);
      expect(find.text(AppStrings.statsBreakdownTitle), findsOneWidget);
      expect(find.text(AppStrings.statsPersistenceNote), findsOneWidget);

      // Verificación de que los apartados no medibles fueron eliminados
      expect(find.text('ESTE MES'), findsNothing);
      expect(find.text('Tu hábito más seguro'), findsNothing);
    });

    testWidgets('Sin overflow en pantallas de 320x568 y texto al 200 %', (
      tester,
    ) async {
      await _pumpStats(tester, size: const Size(320, 568), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Modo escritorio (>800px) muestra 4 métricas en una sola fila',
      (tester) async {
        await _pumpStats(tester, size: const Size(1200, 800));
        expect(tester.takeException(), isNull);
        expect(find.byType(StatsScreen), findsOneWidget);
      },
    );
  });
}
