import 'package:antfish/app.dart';
import 'package:antfish/core/ui/widgets/app_buttons.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const AntFishApp());
  await tester.pumpAndSettle();
}

void main() {
  group('Responsive de autenticación', () {
    const sizes = <String, Size>{
      'móvil pequeño 320x568': Size(320, 568),
      'móvil 390x844': Size(390, 844),
      'móvil horizontal 844x390': Size(844, 390),
      'tablet 768x1024': Size(768, 1024),
      'escritorio 1440x900': Size(1440, 900),
    };

    for (final entry in sizes.entries) {
      testWidgets('Login y Registro sin overflow en ${entry.key}', (
        tester,
      ) async {
        await _pumpAt(tester, entry.value);
        expect(tester.takeException(), isNull);
        expect(find.text(AppStrings.loginTitle), findsOneWidget);

        await tester.tap(find.text(AppStrings.authTabRegister));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text(AppStrings.registerTitle), findsOneWidget);
      });
    }

    testWidgets('El visual narrativo solo aparece en pantallas anchas', (
      tester,
    ) async {
      await _pumpAt(tester, const Size(390, 844));
      expect(find.text(AppStrings.authHeroEyebrow), findsNothing);

      await _pumpAt(tester, const Size(1440, 900));
      expect(find.text(AppStrings.authHeroEyebrow), findsOneWidget);
    });

    testWidgets('Sin overflow con texto ampliado al 200 %', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(const AntFishApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Comportamiento del formulario (plantilla sin backend)', () {
    testWidgets('Botones que requieren backend en Login están deshabilitados', (
      tester,
    ) async {
      await _pumpAt(tester, const Size(390, 844));

      final submit = tester.widget<PrimaryButton>(
        find.widgetWithText(PrimaryButton, AppStrings.loginSubmit),
      );
      expect(submit.onPressed, isNull);

      final forgot = tester.widget<LinkButton>(
        find.widgetWithText(LinkButton, AppStrings.loginForgotPassword),
      );
      expect(forgot.onPressed, isNull);

      final google = tester.widget<SecondaryButton>(
        find.widgetWithText(SecondaryButton, AppStrings.authGoogle),
      );
      expect(google.onPressed, isNull);
    });

    testWidgets(
      'Botones que requieren backend en Registro están deshabilitados',
      (tester) async {
        await _pumpAt(tester, const Size(390, 844));
        await tester.tap(find.text(AppStrings.authTabRegister));
        await tester.pumpAndSettle();

        final submit = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, AppStrings.registerSubmit),
        );
        expect(submit.onPressed, isNull);

        final google = tester.widget<SecondaryButton>(
          find.widgetWithText(SecondaryButton, AppStrings.authGoogle),
        );
        expect(google.onPressed, isNull);
      },
    );

    testWidgets('Mostrar y ocultar la contraseña funciona localmente', (
      tester,
    ) async {
      await _pumpAt(tester, const Size(390, 844));

      expect(find.byTooltip(AppStrings.fieldPasswordShow), findsOneWidget);
      await tester.tap(find.byTooltip(AppStrings.fieldPasswordShow));
      await tester.pump();
      expect(find.byTooltip(AppStrings.fieldPasswordHide), findsOneWidget);
    });
  });
}
