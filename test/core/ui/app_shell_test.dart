import 'package:antfish/app.dart';
import 'package:antfish/core/router/app_routes.dart';
import 'package:antfish/core/ui/layout/app_shell.dart';
import 'package:antfish/core/ui/widgets/crystal_bottom_nav.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpShell(
  WidgetTester tester, {
  String initialRoute = AppRoutes.home,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    AntFishApp(key: UniqueKey(), initialRoute: initialRoute),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Fase 1: AppShell y CrystalBottomNav', () {
    testWidgets('Renderiza las 4 pestañas y el botón central Escanear', (
      tester,
    ) async {
      await _pumpShell(tester);

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(CrystalBottomNav), findsOneWidget);
      expect(find.text(AppStrings.navHome), findsOneWidget);
      expect(find.text(AppStrings.navHistory), findsOneWidget);
      expect(find.text(AppStrings.navScan), findsOneWidget);
      expect(find.text(AppStrings.navStats), findsOneWidget);
      expect(find.text(AppStrings.navProfile), findsOneWidget);
    });

    testWidgets('Permite cambiar entre Inicio, Historial, Métricas y Perfil', (
      tester,
    ) async {
      await _pumpShell(tester);
      expect(find.text(AppStrings.homeTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.navHistory));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.historyTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.navStats));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.statsTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.navProfile));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.profileTitle), findsOneWidget);

      // El botón central Escanear regresa a Inicio
      await tester.tap(find.text(AppStrings.navScan));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.homeTitle), findsOneWidget);
    });

    testWidgets('Las rutas /history, /stats y /profile abren su pestaña', (
      tester,
    ) async {
      await _pumpShell(tester, initialRoute: AppRoutes.history);
      expect(find.text(AppStrings.historyTitle), findsOneWidget);

      await _pumpShell(tester, initialRoute: AppRoutes.stats);
      expect(find.text(AppStrings.statsTitle), findsOneWidget);

      await _pumpShell(tester, initialRoute: AppRoutes.profile);
      expect(find.text(AppStrings.profileTitle), findsOneWidget);
    });

    testWidgets('Sin overflow en móvil pequeño (320x568) y texto al 200 %', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(const AntFishApp(initialRoute: AppRoutes.home));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
