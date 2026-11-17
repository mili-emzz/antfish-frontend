import 'package:antfish/app.dart';
import 'package:antfish/core/router/app_routes.dart';
import 'package:antfish/features/account/presentation/screens/profile_screen.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpProfile(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(const AntFishApp(initialRoute: AppRoutes.profile));
  await tester.pumpAndSettle();
}

void main() {
  group('ProfileScreen (Fase 5)', () {
    testWidgets('Renderiza cabecera, datos de usuario y opciones de ajustes', (
      tester,
    ) async {
      await _pumpProfile(tester);

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text(AppStrings.profileTitle), findsOneWidget);
      expect(find.text(AppStrings.profileDemoName), findsOneWidget);
      expect(find.text(AppStrings.profileDemoEmail), findsOneWidget);
      expect(find.text(AppStrings.profileVerifiedBadge), findsOneWidget);
      expect(find.text(AppStrings.profileSecurityTitle), findsOneWidget);
      expect(find.text(AppStrings.profilePrivacyTitle), findsOneWidget);
      expect(find.text(AppStrings.profilePreferencesTitle), findsOneWidget);
      expect(find.text(AppStrings.profileLogout), findsOneWidget);
    });

    testWidgets('Cerrar sesión redirige a pantalla de Login', (tester) async {
      await _pumpProfile(tester);

      await tester.tap(find.text(AppStrings.profileLogout));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.loginTitle), findsOneWidget);
    });

    testWidgets('Sin overflow en pantallas de 320x568 y texto al 200 %', (
      tester,
    ) async {
      await _pumpProfile(tester, size: const Size(320, 568), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });
}
