import 'package:antfish/app.dart';
import 'package:antfish/core/router/app_routes.dart';
import 'package:antfish/features/auth/auth.dart';
import 'package:antfish/features/auth/presentation/validators/auth_validators.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Size size, {double scale = 1}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    MaterialApp(
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => const VerifyEmailScreen(email: 'alex@correo.com'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('validador de código exige exactamente 6 dígitos', () {
    expect(
      AuthValidators.verificationCode(''),
      AppStrings.verifyValidationRequired,
    );
    expect(
      AuthValidators.verificationCode('123'),
      AppStrings.verifyValidationIncomplete,
    );
    expect(
      AuthValidators.verificationCode('12a456'),
      AppStrings.verifyValidationIncomplete,
    );
    expect(AuthValidators.verificationCode('123456'), isNull);
  });

  group('VerifyEmailScreen responsive', () {
    const sizes = <String, Size>{
      'móvil pequeño 320x568': Size(320, 568),
      'móvil 390x844': Size(390, 844),
      'móvil horizontal 844x390': Size(844, 390),
      'tablet 768x1024': Size(768, 1024),
      'escritorio 1440x900': Size(1440, 900),
    };
    for (final e in sizes.entries) {
      testWidgets('sin overflow en ${e.key}', (tester) async {
        await _pump(tester, e.value);
        expect(tester.takeException(), isNull);
        expect(find.text(AppStrings.verifyTitle), findsOneWidget);
      });
    }

    testWidgets('sin overflow con texto al 200 %', (tester) async {
      await _pump(tester, const Size(390, 844), scale: 2);
      expect(tester.takeException(), isNull);
    });
  });

  group('VerifyEmailScreen comportamiento (plantilla)', () {
    testWidgets('no muestra pestañas Ingresar / Registrarme', (tester) async {
      await _pump(tester, const Size(390, 844));
      expect(find.text(AppStrings.authTabLogin), findsNothing);
    });

    testWidgets('código vacío muestra error', (tester) async {
      await _pump(tester, const Size(390, 844));
      await tester.tap(find.text(AppStrings.verifySubmit));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.verifyValidationRequired), findsOneWidget);
    });

    testWidgets('código incompleto muestra error', (tester) async {
      await _pump(tester, const Size(390, 844));
      await tester.enterText(find.byType(TextField), '123');
      await tester.tap(find.text(AppStrings.verifySubmit));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.verifyValidationIncomplete), findsOneWidget);
    });

    testWidgets('solo acepta dígitos y máximo 6', (tester) async {
      await _pump(tester, const Size(390, 844));
      await tester.enterText(find.byType(TextField), '12ab34567890');
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '123456');
    });

    testWidgets('código válido solo muestra el aviso de plantilla', (
      tester,
    ) async {
      await _pump(tester, const Size(390, 844));
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text(AppStrings.verifySubmit));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.verifyTemplateNotice), findsOneWidget);
    });

    testWidgets('reenviar código está deshabilitado', (tester) async {
      await _pump(tester, const Size(390, 844));
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, AppStrings.verifyResend),
      );
      expect(button.onPressed, isNull);
    });
  });

  testWidgets('la ruta /verify-email existe en la app', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const AntFishApp());
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(AppRoutes.verifyEmail, arguments: 'a@b.com');
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.verifyTitle), findsOneWidget);
    expect(find.textContaining('a@b.com'), findsOneWidget);
  });
}
