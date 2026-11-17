import 'dart:async';

import 'package:antfish/core/errors/app_failure.dart';
import 'package:antfish/core/network/error_mapper.dart';
import 'package:antfish/core/session/session_controller.dart';
import 'package:antfish/core/session/session_state.dart';
import 'package:antfish/core/storage/token_storage.dart';
import 'package:antfish/core/ui/theme/app_theme.dart';
import 'package:antfish/features/auth/auth.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<String?> readRefreshToken() async => _token;

  @override
  Future<void> saveRefreshToken(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

Widget _wrapWithAuth({
  required AuthRepository repository,
  required SessionController session,
  required Widget child,
}) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: AuthScope(repository: repository, session: session, child: child),
  );
}

void main() {
  late _MockAuthRepository repository;
  late _InMemoryTokenStorage storage;
  late SessionController session;

  setUp(() {
    repository = _MockAuthRepository();
    storage = _InMemoryTokenStorage();
    session = SessionController(storage);
  });

  group('Flujo Google Sign-In en UI', () {
    testWidgets('muestra carga, deshabilita botón y autentica sesión al éxito', (
      tester,
    ) async {
      final completer = Completer<AuthSession?>();
      when(
        () => repository.signInWithGoogle(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        _wrapWithAuth(
          repository: repository,
          session: session,
          child: const LoginScreen(),
        ),
      );

      final googleBtn = find.text(AppStrings.authGoogle);
      await tester.ensureVisible(googleBtn);
      await tester.tap(googleBtn);
      await tester.pump();

      // Mientras está en curso, un segundo tap no debe disparar otra llamada.
      await tester.tap(googleBtn, warnIfMissed: false);
      await tester.pump();
      verify(() => repository.signInWithGoogle()).called(1);

      completer.complete(
        const AuthSession(
          accessToken: 'jwt_access',
          refreshToken: 'jwt_refresh',
          email: 'user@antfish.app',
          proveedorAuth: 'google',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.googleSignInSuccess), findsOneWidget);
      expect(await storage.readRefreshToken(), 'jwt_refresh');
      expect(session.state, isA<SessionAuthenticated>());
      final authState = session.state as SessionAuthenticated;
      expect(authState.accessToken, 'jwt_access');
      expect(authState.userEmail, 'user@antfish.app');
      expect(authState.authProvider, 'google');
    });

    testWidgets('cancelar selector de Google no muestra alerta de error', (
      tester,
    ) async {
      when(() => repository.signInWithGoogle()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        _wrapWithAuth(
          repository: repository,
          session: session,
          child: const LoginScreen(),
        ),
      );

      final googleBtn = find.text(AppStrings.authGoogle);
      await tester.ensureVisible(googleBtn);
      await tester.tap(googleBtn);
      await tester.pumpAndSettle();

      expect(session.state, isA<SessionUnauthenticated>());
      expect(find.text(AppStrings.googleGenericError), findsNothing);
      expect(find.text(AppStrings.googleInvalidCredential), findsNothing);
    });

    testWidgets('error 409 muestra aviso de correo no verificado en Registro', (
      tester,
    ) async {
      when(
        () => repository.signInWithGoogle(),
      ).thenThrow(const ConflictFailure());

      await tester.pumpWidget(
        _wrapWithAuth(
          repository: repository,
          session: session,
          child: const RegisterScreen(),
        ),
      );

      final googleBtn = find.text(AppStrings.authGoogle);
      await tester.ensureVisible(googleBtn);
      await tester.tap(googleBtn);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.googleEmailNotVerified), findsOneWidget);
      expect(session.state, isA<SessionUnauthenticated>());
    });

    testWidgets('error 401 muestra aviso de credencial inválida', (
      tester,
    ) async {
      when(
        () => repository.signInWithGoogle(),
      ).thenThrow(const UnauthorizedFailure());

      await tester.pumpWidget(
        _wrapWithAuth(
          repository: repository,
          session: session,
          child: const LoginScreen(),
        ),
      );

      final googleBtn = find.text(AppStrings.authGoogle);
      await tester.ensureVisible(googleBtn);
      await tester.tap(googleBtn);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.googleInvalidCredential), findsOneWidget);
    });
  });

  group('SessionController y ErrorMapper', () {
    test('signOut limpia refresh_token y vuelve a unauthenticated', () async {
      await session.signIn(
        accessToken: 'a',
        refreshToken: 'r',
        userEmail: 'a@b.com',
        authProvider: 'google',
      );
      expect(await storage.readRefreshToken(), 'r');

      await session.signOut();
      expect(await storage.readRefreshToken(), isNull);
      expect(session.state, isA<SessionUnauthenticated>());
    });

    test('ErrorMapper mapea timeouts y retry-after en 429', () {
      final req = RequestOptions(path: '/auth/google');
      final timeout = DioException(
        requestOptions: req,
        type: DioExceptionType.connectionTimeout,
      );
      expect(ErrorMapper.fromDio(timeout), isA<NetworkFailure>());

      final rateLimit = DioException(
        requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: req,
          statusCode: 429,
          headers: Headers.fromMap({
            'retry-after': ['60'],
          }),
          data: {'code': 'RATE_LIMIT_EXCEEDED'},
        ),
      );
      final failure = ErrorMapper.fromDio(rateLimit) as RateLimitFailure;
      expect(failure.code, 'RATE_LIMIT_EXCEEDED');
      expect(failure.retryAfterSeconds, 60);
    });
  });
}
