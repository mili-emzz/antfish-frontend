import 'package:antfish/app.dart';
import 'package:antfish/core/config/legal_links.dart';
import 'package:antfish/core/router/app_routes.dart';
import 'package:antfish/core/session/session_controller.dart';
import 'package:antfish/core/session/session_state.dart';
import 'package:antfish/core/storage/token_storage.dart';
import 'package:antfish/features/account/presentation/screens/profile_screen.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStorage implements TokenStorage {
  String? token;

  @override
  Future<String?> readRefreshToken() async => token;

  @override
  Future<void> saveRefreshToken(String t) async => token = t;

  @override
  Future<void> clear() async => token = null;
}

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

    testWidgets('Cerrar sesión limpia SessionController y redirige a Login', (
      tester,
    ) async {
      final storage = _FakeStorage();
      final session = SessionController(storage);
      await session.signIn(
        accessToken: 'acc',
        refreshToken: 'ref',
        userEmail: 'carlos@antfish.app',
        userName: 'Carlos Ramírez',
      );

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AntFishApp(initialRoute: AppRoutes.profile, sessionController: session),
      );
      await tester.pumpAndSettle();

      expect(find.text('Carlos Ramírez'), findsOneWidget);
      expect(find.text('carlos@antfish.app'), findsOneWidget);

      await tester.tap(find.text(AppStrings.profileLogout));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.loginTitle), findsOneWidget);
      expect(session.state, isA<SessionUnauthenticated>());
      expect(await storage.readRefreshToken(), isNull);
    });

    testWidgets('Sin overflow en pantallas de 320x568 y texto al 200 %', (
      tester,
    ) async {
      await _pumpProfile(tester, size: const Size(320, 568), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Centro de seguridad navega a ForgotPasswordScreen con el correo activo',
      (tester) async {
        final storage = _FakeStorage();
        final session = SessionController(storage);
        await session.signIn(
          accessToken: 'acc',
          refreshToken: 'ref',
          userEmail: 'carlos@antfish.app',
          userName: 'Carlos Ramírez',
        );

        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          AntFishApp(
            initialRoute: AppRoutes.profile,
            sessionController: session,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.profileSecurityTitle));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.forgotPasswordTitle), findsOneWidget);
        expect(find.text('carlos@antfish.app'), findsOneWidget);
      },
    );

    testWidgets('Privacidad y Términos muestran sus avisos legales', (
      tester,
    ) async {
      await _pumpProfile(tester);

      await tester.tap(find.text(AppStrings.profilePrivacyTitle));
      await tester.pumpAndSettle();
      expect(find.text(LegalLinks.privacyUrl), findsOneWidget);

      await tester.tap(find.text(AppStrings.legalLinkPendingClose));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.profilePreferencesTitle));
      await tester.pumpAndSettle();
      expect(find.text(LegalLinks.termsUrl), findsOneWidget);
    });
  });
}
