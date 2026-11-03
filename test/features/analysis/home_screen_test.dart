import 'package:antfish/app.dart';
import 'package:antfish/core/router/app_routes.dart';
import 'package:antfish/features/analysis/presentation/screens/home_screen.dart';
import 'package:antfish/features/analysis/presentation/widgets/risk_traffic_light_card.dart';
import 'package:antfish/features/analysis/presentation/widgets/scanner_card.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpHome(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(const AntFishApp(initialRoute: AppRoutes.home));
  await tester.pumpAndSettle();
}

void main() {
  group('HomeScreen (Fase 2)', () {
    testWidgets('Renderiza cabecera, saludo, escáner, semáforo y recientes', (
      tester,
    ) async {
      await _pumpHome(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text(AppStrings.homeGreeting), findsOneWidget);
      expect(find.byType(ScannerCard), findsOneWidget);
      expect(find.byType(RiskTrafficLightCard), findsOneWidget);
      expect(find.text(AppStrings.recentTitle), findsOneWidget);
    });

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

    testWidgets('Sin overflow en pantallas de 320x568 y texto al 200 %', (
      tester,
    ) async {
      await _pumpHome(tester, size: const Size(320, 568), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });
}
