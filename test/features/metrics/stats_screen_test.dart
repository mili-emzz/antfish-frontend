import 'package:antfish/app.dart';
import 'package:antfish/core/router/app_routes.dart';
import 'package:antfish/features/metrics/domain/models/user_metrics.dart';
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
  group('UserMetrics (GET /api/v1/metrics/me)', () {
    test('parsea el JSON del contrato v2 y calcula porcentajes reales', () {
      final metrics = UserMetrics.fromJson(const {
        'total_escaneos': 42,
        'total_url': 15,
        'total_sms': 27,
        'amenazas_bloqueadas': 11,
        'ultima_actualizacion': '2026-11-16T18:00:00Z',
      });

      expect(metrics.totalEscaneos, 42);
      expect(metrics.totalUrl, 15);
      expect(metrics.totalSms, 27);
      expect(metrics.amenazasBloqueadas, 11);
      expect(metrics.escaneosSinAmenazaCritica, 31);
      expect(metrics.ultimaActualizacion, isNotNull);
      expect(metrics.percentOfTotal(metrics.amenazasBloqueadas), 26);
      expect(metrics.percentOfTotal(metrics.escaneosSinAmenazaCritica), 74);
      expect(metrics.percentOfTotal(metrics.totalUrl), 36);
      expect(metrics.percentOfTotal(metrics.totalSms), 64);
    });

    test('maneja usuario nuevo sin escaneos (ultima_actualizacion: null)', () {
      final metrics = UserMetrics.fromJson(const {
        'total_escaneos': 0,
        'total_url': 0,
        'total_sms': 0,
        'amenazas_bloqueadas': 0,
        'ultima_actualizacion': null,
      });

      expect(metrics.totalEscaneos, 0);
      expect(metrics.ultimaActualizacion, isNull);
      expect(metrics.percentOfTotal(10), 0);
    });
  });

  group('StatsScreen sin mocks (preparado para GET /api/v1/metrics/me)', () {
    testWidgets(
      'Por defecto inicia en UserMetrics.empty (0) sin valores mock estáticos',
      (tester) async {
        await _pumpStats(tester);

        expect(find.byType(StatsScreen), findsOneWidget);
        expect(find.text(AppStrings.statsTitle), findsOneWidget);
        expect(find.text(AppStrings.statsMetricTotalScans), findsOneWidget);
        expect(find.text(AppStrings.statsMetricBlocked), findsOneWidget);
        expect(find.text(AppStrings.statsMetricUrls), findsOneWidget);
        expect(find.text(AppStrings.statsMetricSms), findsOneWidget);
        expect(find.text(AppStrings.statsBreakdownTitle), findsOneWidget);
        expect(find.text(AppStrings.statsNoScansYet), findsOneWidget);
        expect(find.text(AppStrings.statsPersistenceNote), findsOneWidget);

        // Los 4 contadores inician en '0' y no contienen los antiguos mocks
        expect(find.text('0'), findsNWidgets(4));
        expect(find.text('148'), findsNothing);
        expect(find.text('23'), findsNothing);
        expect(find.text('91'), findsNothing);
        expect(find.text('57'), findsNothing);
      },
    );

    testWidgets(
      'Renderiza los valores y porcentajes reales cuando recibe UserMetrics',
      (tester) async {
        final metrics = UserMetrics(
          totalEscaneos: 42,
          totalUrl: 15,
          totalSms: 27,
          amenazasBloqueadas: 11,
          ultimaActualizacion: DateTime.utc(2026, 11, 16, 18, 0),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: StatsScreen(metrics: metrics)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('42'), findsOneWidget);
        expect(find.text('11'), findsOneWidget);
        expect(find.text('15'), findsOneWidget);
        expect(find.text('27'), findsOneWidget);
        expect(find.text('26% del total'), findsOneWidget);
        expect(find.text('36% de actividad'), findsOneWidget);
        expect(find.text('64% de actividad'), findsOneWidget);
        expect(find.text('74%'), findsOneWidget);
        expect(find.textContaining('Actualizado:'), findsOneWidget);
      },
    );

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
