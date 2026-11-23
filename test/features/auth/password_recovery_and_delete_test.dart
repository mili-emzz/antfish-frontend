import 'package:antfish/app.dart';
import 'package:antfish/core/errors/app_failure.dart';
import 'package:antfish/core/router/app_routes.dart';
import 'package:antfish/core/session/session_controller.dart';
import 'package:antfish/core/session/session_state.dart';
import 'package:antfish/core/storage/token_storage.dart';
import 'package:antfish/features/auth/auth.dart';
import 'package:antfish/features/auth/data/auth_remote_data_source.dart';
import 'package:antfish/features/auth/data/auth_repository_impl.dart';
import 'package:antfish/features/auth/data/google_auth_data_source.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockGoogle extends Mock implements GoogleAuthDataSource {}

class _MockRepo extends Mock implements AuthRepository {}

class _MemoryStorage implements TokenStorage {
  String? token;

  @override
  Future<String?> readRefreshToken() async => token;

  @override
  Future<void> saveRefreshToken(String t) async => token = t;

  @override
  Future<void> clear() async => token = null;
}

Response<Map<String, dynamic>> _ok(String path, int status, Object? data) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: path),
      statusCode: status,
      data: data as Map<String, dynamic>?,
    );

DioException _error(String path, int status, Map<String, dynamic>? body) {
  final req = RequestOptions(path: path);
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status, data: body),
  );
}

void main() {
  group(
    'Repositorio: forgot, reset y DELETE /auth/me (contrato_api_v2.md)',
    () {
      late _MockDio dio;
      late _MockGoogle google;
      late AuthRepositoryImpl repo;

      setUp(() {
        dio = _MockDio();
        google = _MockGoogle();
        repo = AuthRepositoryImpl(
          google: google,
          remote: AuthRemoteDataSource(dio),
        );
      });

      test(
        'requestPasswordReset 200 normaliza email y devuelve mensaje',
        () async {
          when(
            () => dio.post<Map<String, dynamic>>(
              '/auth/password/forgot',
              data: any(named: 'data'),
            ),
          ).thenAnswer(
            (_) async => _ok('/auth/password/forgot', 200, {
              'mensaje': 'Si el correo corresponde a una cuenta activa...',
            }),
          );

          final msg = await repo.requestPasswordReset(
            email: '  User@Mail.COM ',
          );
          expect(msg, 'Si el correo corresponde a una cuenta activa...');
          verify(
            () => dio.post<Map<String, dynamic>>(
              '/auth/password/forgot',
              data: {'email': 'user@mail.com'},
            ),
          ).called(1);
        },
      );

      test('requestPasswordReset 429 lanza RateLimitFailure', () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            '/auth/password/forgot',
            data: any(named: 'data'),
          ),
        ).thenThrow(
          _error('/auth/password/forgot', 429, {
            'code': 'RATE_LIMIT_EXCEEDED',
            'detail': 'Demasiadas solicitudes',
          }),
        );

        await expectLater(
          repo.requestPasswordReset(email: 'a@b.com'),
          throwsA(isA<RateLimitFailure>()),
        );
      });

      test(
        'confirmPasswordReset 200 envía email, codigo y nueva_password',
        () async {
          when(
            () => dio.post<Map<String, dynamic>>(
              '/auth/password/reset',
              data: any(named: 'data'),
            ),
          ).thenAnswer(
            (_) async => _ok('/auth/password/reset', 200, {
              'mensaje': 'Contraseña restablecida exitosamente.',
            }),
          );

          final msg = await repo.confirmPasswordReset(
            email: ' User@Mail.com ',
            code: ' 123456 ',
            newPassword: 'NuevaPassword123!',
          );

          expect(msg, 'Contraseña restablecida exitosamente.');
          verify(
            () => dio.post<Map<String, dynamic>>(
              '/auth/password/reset',
              data: {
                'email': 'user@mail.com',
                'codigo': '123456',
                'nueva_password': 'NuevaPassword123!',
              },
            ),
          ).called(1);
        },
      );

      test(
        'confirmPasswordReset 400 lanza ValidationFailure con detail',
        () async {
          when(
            () => dio.post<Map<String, dynamic>>(
              '/auth/password/reset',
              data: any(named: 'data'),
            ),
          ).thenThrow(
            _error('/auth/password/reset', 400, {
              'code': 'BAD_REQUEST',
              'detail': 'Código inválido o expirado.',
            }),
          );

          await expectLater(
            repo.confirmPasswordReset(
              email: 'a@b.com',
              code: '000000',
              newPassword: 'NuevaPassword123!',
            ),
            throwsA(
              isA<ValidationFailure>().having(
                (f) => f.message,
                'message',
                'Código inválido o expirado.',
              ),
            ),
          );
        },
      );

      test(
        'deleteAccountWithPassword 204 envía DELETE /auth/me con password',
        () async {
          when(() => dio.delete<void>('/auth/me', data: any(named: 'data')))
              .thenAnswer(
                (_) async => Response<void>(
                  requestOptions: RequestOptions(path: '/auth/me'),
                  statusCode: 204,
                ),
              );

          await repo.deleteAccountWithPassword(password: 'PasswordActual123!');

          verify(
            () => dio.delete<void>(
              '/auth/me',
              data: {'password': 'PasswordActual123!'},
            ),
          ).called(1);
        },
      );

      test('deleteAccountWithPassword 403 INVALID_CREDENTIALS lanza UnauthorizedFailure', () async {
        when(() => dio.delete<void>('/auth/me', data: any(named: 'data')))
            .thenThrow(
              _error('/auth/me', 403, {
                'code': 'INVALID_CREDENTIALS',
                'detail': 'Credenciales inválidas',
              }),
            );

        await expectLater(
          repo.deleteAccountWithPassword(password: 'wrong'),
          throwsA(
            isA<UnauthorizedFailure>()
                .having((f) => f.code, 'code', 'INVALID_CREDENTIALS')
                .having((f) => f.message, 'message', 'Credenciales inválidas'),
          ),
        );
      });

      test(
        'deleteAccountWithGoogle obtiene id_token y envía DELETE /auth/me',
        () async {
          when(() => google.obtainIdToken())
              .thenAnswer((_) async => 'id-tok-1');
          when(() => dio.delete<void>('/auth/me', data: any(named: 'data')))
              .thenAnswer(
                (_) async => Response<void>(
                  requestOptions: RequestOptions(path: '/auth/me'),
                  statusCode: 204,
                ),
              );

          final deleted = await repo.deleteAccountWithGoogle();

          expect(deleted, isTrue);
          verify(
            () => dio.delete<void>('/auth/me', data: {'id_token': 'id-tok-1'}),
          ).called(1);
        },
      );

      test(
        'deleteAccountWithGoogle devuelve false si el usuario cancela Google',
        () async {
          when(() => google.obtainIdToken()).thenAnswer((_) async => null);

          final deleted = await repo.deleteAccountWithGoogle();

          expect(deleted, isFalse);
          verifyNever(() => dio.delete<void>(any(), data: any(named: 'data')));
        },
      );
    },
  );

  group('UI: recuperación de contraseña y baja definitiva de cuenta', () {
    late _MockRepo repo;
    late _MemoryStorage storage;
    late SessionController session;

    setUp(() {
      repo = _MockRepo();
      storage = _MemoryStorage();
      session = SessionController(storage);
    });

    Future<void> pumpApp(WidgetTester tester, {String? initialRoute}) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AntFishApp(
          initialRoute: initialRoute,
          authRepository: repo,
          sessionController: session,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Login -> ForgotPassword -> ResetPassword -> Login completa el flujo',
      (tester) async {
        when(() => repo.requestPasswordReset(email: 'ana@correo.com'))
            .thenAnswer((_) async => AppStrings.forgotPasswordSuccessDefault);
        when(
          () => repo.confirmPasswordReset(
            email: 'ana@correo.com',
            code: '123456',
            newPassword: 'NuevaPassword123!',
          ),
        ).thenAnswer((_) async => AppStrings.resetPasswordSuccessDefault);

        await pumpApp(tester, initialRoute: AppRoutes.login);

        await tester.tap(find.text(AppStrings.loginForgotPassword));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.forgotPasswordTitle), findsOneWidget);

        await tester.enterText(
          find.byType(TextFormField).first,
          'ana@correo.com',
        );
        await tester.tap(find.text(AppStrings.forgotPasswordSubmit));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.resetPasswordTitle), findsOneWidget);
        expect(find.textContaining('ana@correo.com'), findsOneWidget);

        // Ingresar 6 dígitos en OtpCodeInput + nueva contraseña.
        await tester.enterText(find.byType(TextField).first, '123456');
        await tester.enterText(
          find.byType(TextFormField).last,
          'NuevaPassword123!',
        );
        await tester.tap(find.text(AppStrings.resetPasswordSubmit));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.loginTitle), findsOneWidget);
        verify(
          () => repo.confirmPasswordReset(
            email: 'ana@correo.com',
            code: '123456',
            newPassword: 'NuevaPassword123!',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'ProfileScreen (local): Eliminar cuenta pide contraseña, limpia sesión y va a Login',
      (tester) async {
        await session.signIn(
          accessToken: 'acc',
          refreshToken: 'ref',
          userEmail: 'carlos@antfish.app',
          userName: 'Carlos Ramírez',
          authProvider: 'local',
        );
        when(() => repo.deleteAccountWithPassword(password: 'MiPass123!'))
            .thenAnswer((_) async {});

        await pumpApp(tester, initialRoute: AppRoutes.profile);

        await tester.ensureVisible(find.text(AppStrings.profileDeleteAccount));
        await tester.tap(find.text(AppStrings.profileDeleteAccount));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(Dialog),
            matching: find.text(AppStrings.deleteAccountDialogTitle),
          ),
          findsOneWidget,
        );
        await tester.enterText(find.byType(TextFormField).first, 'MiPass123!');
        await tester.tap(find.text(AppStrings.deleteAccountConfirm));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.loginTitle), findsOneWidget);
        expect(session.state, isA<SessionUnauthenticated>());
        expect(await storage.readRefreshToken(), isNull);
      },
    );

    testWidgets('ProfileScreen (local): 403 muestra alerta sin cerrar sesión', (
      tester,
    ) async {
      await session.signIn(
        accessToken: 'acc',
        refreshToken: 'ref',
        userEmail: 'carlos@antfish.app',
        userName: 'Carlos Ramírez',
        authProvider: 'local',
      );
      when(() => repo.deleteAccountWithPassword(password: 'mala')).thenThrow(
        const UnauthorizedFailure(
          message: 'Credenciales inválidas',
          code: 'INVALID_CREDENTIALS',
        ),
      );

      await pumpApp(tester, initialRoute: AppRoutes.profile);

      await tester.ensureVisible(find.text(AppStrings.profileDeleteAccount));
      await tester.tap(find.text(AppStrings.profileDeleteAccount));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'mala');
      await tester.tap(find.text(AppStrings.deleteAccountConfirm));
      await tester.pumpAndSettle();

      expect(find.text('Credenciales inválidas'), findsOneWidget);
      expect(session.state, isA<SessionAuthenticated>());
    });

    testWidgets(
      'ProfileScreen (google): Eliminar cuenta reautentica con Google y va a Login',
      (tester) async {
        await session.signIn(
          accessToken: 'acc',
          refreshToken: 'ref',
          userEmail: 'g@antfish.app',
          userName: 'G User',
          authProvider: 'google',
        );
        when(() => repo.deleteAccountWithGoogle())
            .thenAnswer((_) async => true);

        await pumpApp(tester, initialRoute: AppRoutes.profile);

        await tester.ensureVisible(find.text(AppStrings.profileDeleteAccount));
        await tester.tap(find.text(AppStrings.profileDeleteAccount));
        await tester.pumpAndSettle();

        expect(
          find.text(AppStrings.deleteAccountConfirmGoogle),
          findsOneWidget,
        );
        expect(find.byType(TextFormField), findsNothing);

        await tester.tap(find.text(AppStrings.deleteAccountConfirmGoogle));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.loginTitle), findsOneWidget);
        expect(session.state, isA<SessionUnauthenticated>());
        verify(() => repo.deleteAccountWithGoogle()).called(1);
      },
    );
  });
}
