import 'package:antfish/app.dart';
import 'package:antfish/core/router/app_routes.dart';
import 'package:antfish/features/analysis/presentation/screens/history_screen.dart';
import 'package:antfish/features/analysis/presentation/widgets/history_row_item.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpHistory(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(const AntFishApp(initialRoute: AppRoutes.history));
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

    testWidgets('Sin overflow en pantallas de 320x568 y texto al 200 %', (
      tester,
    ) async {
      await _pumpHistory(tester, size: const Size(320, 568), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });
}
