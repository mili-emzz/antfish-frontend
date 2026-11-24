import 'dart:async';

import 'package:antfish/core/config/legal_links.dart';
import 'package:antfish/core/errors/app_failure.dart';
import 'package:antfish/core/session/session_controller.dart';
import 'package:antfish/core/session/session_state.dart';
import 'package:antfish/core/storage/token_storage.dart';
import 'package:antfish/core/ui/theme/app_theme.dart';
import 'package:antfish/features/auth/auth.dart';
import 'package:antfish/features/auth/data/auth_remote_data_source.dart';
import 'package:antfish/features/auth/data/auth_repository_impl.dart';
import 'package:antfish/features/auth/data/google_auth_data_source.dart';
import 'package:antfish/features/auth/domain/models/register_result.dart';
import 'package:antfish/features/auth/presentation/widgets/legal_consent_checkboxes.dart';
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
  group('Repositorio: registro y login local (contrato_api.md)', () {
    late _MockDio dio;
    late AuthRepositoryImpl repo;

    setUp(() {
      dio = _MockDio();
      repo = AuthRepositoryImpl(
        google: _MockGoogle(),
        remote: AuthRemoteDataSource(dio),
      );
    });

    void stubPost(String path, Future<Response<Map<String, dynamic>>> answer) {
      when(() => dio.post<Map<String, dynamic>>(path, data: any(named: 'data')))
          .thenAnswer((_) => answer);
    }

    test('register 201 normaliza el correo y parsea RegisterResult', () async {
      stubPost(
        '/auth/register',
        Future.value(
          _ok('/auth/register', 201, {
            'id': '67389a1b',
            'email': 'usuario@correo.com',
            'nombre': 'Carlos Ramírez',
            'estado_cuenta': 'pendiente_verificacion',
            'email_verificado': false,
            'mensaje': 'ok',
          }),
        ),
      );

      final RegisterResult result = await repo.register(
        email: '  Usuario@Correo.COM ',
        password: 'PasswordSeguro123',
        nombre: '  Carlos Ramírez ',
      );

      expect(result.id, '67389a1b');
      expect(result.estadoCuenta, 'pendiente_verificacion');
      expect(result.emailVerificado, isFalse);
      verify(
        () => dio.post<Map<String, dynamic>>(
          '/auth/register',
          data: {
            'email': 'usuario@correo.com',
            'password': 'PasswordSeguro123',
            'nombre': 'Carlos Ramírez',
          },
        ),
      ).called(1);
    });

    test('register 409 lanza ConflictFailure sin reintentar', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/register',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        _error('/auth/register', 409, {
          'detail': 'El correo ya se encuentra registrado',
        }),
      );

      await expectLater(
        repo.register(email: 'a@b.com', password: '12345678', nombre: 'A'),
        throwsA(isA<ConflictFailure>()),
      );
      verify(
        () => dio.post<Map<String, dynamic>>(
          '/auth/register',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test('register 422 lanza ValidationFailure', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/register',
          data: any(named: 'data'),
        ),
      ).thenThrow(_error('/auth/register', 422, {'detail': []}));

      await expectLater(
        repo.register(email: 'a@b.com', password: '12345678', nombre: 'A'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('login 200 devuelve tokens con proveedor local', () async {
      stubPost(
        '/auth/login',
        Future.value(
          _ok('/auth/login', 200, {
            'access_token': 'acc',
            'refresh_token': 'ref',
            'token_type': 'bearer',
          }),
        ),
      );

      final session = await repo.login(
        email: ' User@Mail.com ',
        password: 'secreta123',
      );

      expect(session.accessToken, 'acc');
      expect(session.refreshToken, 'ref');
      expect(session.proveedorAuth, 'local');
      expect(session.email, 'user@mail.com');
    });

    test('login 401 lanza UnauthorizedFailure', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/login',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        _error('/auth/login', 401, {'detail': 'Credenciales inválidas'}),
      );

      await expectLater(
        repo.login(email: 'a@b.com', password: 'x'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test(
      'login 403 ACCOUNT_NOT_VERIFIED lanza AccountNotVerifiedFailure',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            '/auth/login',
            data: any(named: 'data'),
          ),
        ).thenThrow(
          _error('/auth/login', 403, {'detail': 'ACCOUNT_NOT_VERIFIED'}),
        );

        await expectLater(
          repo.login(email: 'Pend@Mail.com', password: 'x'),
          throwsA(
            isA<AccountNotVerifiedFailure>().having(
              (f) => f.email,
              'email',
              'pend@mail.com',
            ),
          ),
        );
      },
    );

    test('login 429 lanza RateLimitFailure', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/login',
          data: any(named: 'data'),
        ),
      ).thenThrow(_error('/auth/login', 429, null));

      await expectLater(
        repo.login(email: 'a@b.com', password: 'x'),
        throwsA(isA<RateLimitFailure>()),
      );
    });

    test('verifyEmail 200 envía email y codigo y devuelve mensaje', () async {
      stubPost(
        '/auth/verify-email',
        Future.value(
          _ok('/auth/verify-email', 200, {
            'mensaje': 'Cuenta verificada exitosamente.',
          }),
        ),
      );

      final msg = await repo.verifyEmail(
        email: ' User@Mail.com ',
        code: '123456',
      );
      expect(msg, 'Cuenta verificada exitosamente.');
      verify(
        () => dio.post<Map<String, dynamic>>(
          '/auth/verify-email',
          data: {'email': 'user@mail.com', 'codigo': '123456'},
        ),
      ).called(1);
    });

    test('verifyEmail 400 lanza ValidationFailure con detail', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/verify-email',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        _error('/auth/verify-email', 400, {
          'code': 'BAD_REQUEST',
          'detail': 'Código inválido o expirado.',
        }),
      );

      await expectLater(
        repo.verifyEmail(email: 'a@b.com', code: '000000'),
        throwsA(
          isA<ValidationFailure>().having(
            (f) => f.message,
            'message',
            'Código inválido o expirado.',
          ),
        ),
      );
    });

    test('resendCode 200 envía email normalizado y devuelve mensaje', () async {
      stubPost(
        '/auth/resend-code',
        Future.value(
          _ok('/auth/resend-code', 200, {
            'mensaje': 'Si la cuenta está pendiente de verificación, se envió un nuevo código.',
          }),
        ),
      );

      final msg = await repo.resendCode(email: ' User@Mail.com ');
      expect(msg, contains('se envió un nuevo código'));
      verify(
        () => dio.post<Map<String, dynamic>>(
          '/auth/resend-code',
          data: {'email': 'user@mail.com'},
        ),
      ).called(1);
    });
  });

  group('UI: login y registro locales', () {
    late _MockRepo repository;
    late _MemoryStorage storage;
    late SessionController session;

    setUp(() {
      repository = _MockRepo();
      storage = _MemoryStorage();
      session = SessionController(storage);
    });

    Widget wrap(Widget child) => MaterialApp(
      theme: AppTheme.darkTheme,
      home: AuthScope(repository: repository, session: session, child: child),
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => Scaffold(
          body: Text('ROUTE:${settings.name}:${settings.arguments}'),
        ),
      ),
    );

    Future<void> tapSubmit(WidgetTester tester, String label) async {
      final finder = find.text(label);
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();
    }

    testWidgets('login exitoso guarda sesión y navega a /home', (tester) async {
      final completer = Completer<AuthSession>();
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(wrap(const LoginScreen()));
      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'secreta123');
      await tapSubmit(tester, AppStrings.loginSubmit);

      // Segundo toque mientras carga: no debe duplicar la petición.
      await tester.tap(find.text(AppStrings.loginSubmit), warnIfMissed: false);
      await tester.pump();
      verify(() => repository.login(email: 'a@b.com', password: 'secreta123'))
          .called(1);

      completer.complete(
        const AuthSession(
          accessToken: 'acc',
          refreshToken: 'ref',
          email: 'a@b.com',
          proveedorAuth: 'local',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ROUTE:/home:null'), findsOneWidget);
      expect(storage.token, 'ref');
      expect(session.state, isA<SessionAuthenticated>());
    });

    testWidgets('login 403 redirige a /verify-email con el correo', (
      tester,
    ) async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AccountNotVerifiedFailure(email: 'a@b.com'));

      await tester.pumpWidget(wrap(const LoginScreen()));
      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'secreta123');
      await tapSubmit(tester, AppStrings.loginSubmit);
      await tester.pumpAndSettle();

      expect(find.text('ROUTE:/verify-email:a@b.com'), findsOneWidget);
      expect(session.state, isA<SessionPendingVerification>());
    });

    testWidgets('login 401 muestra alerta y no navega', (tester) async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const UnauthorizedFailure());

      await tester.pumpWidget(wrap(const LoginScreen()));
      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'mala');
      await tapSubmit(tester, AppStrings.loginSubmit);
      await tester.pumpAndSettle();

      expect(find.text(const UnauthorizedFailure().message), findsOneWidget);
      expect(session.state, isA<SessionUnauthenticated>());
    });

    testWidgets('login con formulario vacío no llama al backend', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const LoginScreen()));
      await tapSubmit(tester, AppStrings.loginSubmit);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.validationFormHasErrors), findsOneWidget);
      verifyNever(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    Future<void> tapCheckbox(WidgetTester tester, Key key) async {
      final finder = find.byKey(key);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> acceptAllLegal(WidgetTester tester) async {
      await tapCheckbox(tester, LegalConsentCheckboxes.termsCheckboxKey);
      await tapCheckbox(tester, LegalConsentCheckboxes.privacyCheckboxKey);
    }

    testWidgets(
      'registro bloqueado si faltan checkboxes de términos o privacidad',
      (tester) async {
        await tester.pumpWidget(wrap(const RegisterScreen()));
        await tester.enterText(find.byType(TextFormField).at(0), 'Carlos');
        await tester.enterText(find.byType(TextFormField).at(1), 'nuevo@b.com');
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'PasswordSeguro1',
        );

        // Sin marcar ninguno: botón bloqueado.
        await tapSubmit(tester, AppStrings.registerSubmit);
        await tester.pumpAndSettle();
        verifyNever(
          () => repository.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            nombre: any(named: 'nombre'),
          ),
        );

        // Solo Términos marcado: sigue bloqueado.
        await tapCheckbox(tester, LegalConsentCheckboxes.termsCheckboxKey);
        await tapSubmit(tester, AppStrings.registerSubmit);
        await tester.pumpAndSettle();
        verifyNever(
          () => repository.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            nombre: any(named: 'nombre'),
          ),
        );

        // Desmarca Términos y marca solo Aviso de privacidad: sigue bloqueado.
        await tapCheckbox(tester, LegalConsentCheckboxes.termsCheckboxKey);
        await tapCheckbox(tester, LegalConsentCheckboxes.privacyCheckboxKey);
        await tapSubmit(tester, AppStrings.registerSubmit);
        await tester.pumpAndSettle();
        verifyNever(
          () => repository.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            nombre: any(named: 'nombre'),
          ),
        );
      },
    );

    testWidgets(
      'enlaces de términos y privacidad abren las URLs oficiales directamente',
      (tester) async {
        final launchedUrls = <String>[];
        LegalLinks.urlLauncherOverride = (uri) async {
          launchedUrls.add(uri.toString());
          return true;
        };
        addTearDown(() => LegalLinks.urlLauncherOverride = null);

        await tester.pumpWidget(wrap(const RegisterScreen()));

        final termsLink = find.text(AppStrings.authLegalTerms);
        await tester.ensureVisible(termsLink);
        await tester.tap(termsLink);
        await tester.pumpAndSettle();

        expect(launchedUrls, contains(LegalLinks.termsUrl));

        final privacyLink = find.text(AppStrings.authLegalPrivacy);
        await tester.ensureVisible(privacyLink);
        await tester.tap(privacyLink);
        await tester.pumpAndSettle();

        expect(launchedUrls, contains(LegalLinks.privacyUrl));
      },
    );

    testWidgets('registro 201 redirige a /verify-email con el correo', (
      tester,
    ) async {
      when(
        () => repository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          nombre: any(named: 'nombre'),
        ),
      ).thenAnswer(
        (_) async => const RegisterResult(
          id: '1',
          email: 'nuevo@b.com',
          estadoCuenta: 'pendiente_verificacion',
          emailVerificado: false,
        ),
      );

      await tester.pumpWidget(wrap(const RegisterScreen()));
      await tester.enterText(find.byType(TextFormField).at(0), 'Carlos');
      await tester.enterText(find.byType(TextFormField).at(1), 'nuevo@b.com');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'PasswordSeguro1',
      );
      await acceptAllLegal(tester);
      await tapSubmit(tester, AppStrings.registerSubmit);
      await tester.pumpAndSettle();

      expect(find.text('ROUTE:/verify-email:nuevo@b.com'), findsOneWidget);
      expect(session.state, isA<SessionPendingVerification>());
    });

    testWidgets('registro 409 muestra alerta de correo ya registrado', (
      tester,
    ) async {
      when(
        () => repository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          nombre: any(named: 'nombre'),
        ),
      ).thenThrow(const ConflictFailure());

      await tester.pumpWidget(wrap(const RegisterScreen()));
      await tester.enterText(find.byType(TextFormField).at(0), 'Carlos');
      await tester.enterText(find.byType(TextFormField).at(1), 'dup@b.com');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'PasswordSeguro1',
      );
      await acceptAllLegal(tester);
      await tapSubmit(tester, AppStrings.registerSubmit);
      await tester.pumpAndSettle();

      expect(find.text(const ConflictFailure().message), findsOneWidget);
      expect(session.state, isA<SessionUnauthenticated>());
    });

    testWidgets('verifyEmail 200 redirige a /login', (tester) async {
      when(
        () => repository.verifyEmail(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => AppStrings.verifySuccessDefault);

      await tester.pumpWidget(
        wrap(const VerifyEmailScreen(email: 'nuevo@b.com')),
      );
      await tester.enterText(find.byType(TextField), '123456');
      await tapSubmit(tester, AppStrings.verifySubmit);
      await tester.pumpAndSettle();

      expect(find.text('ROUTE:/login:null'), findsOneWidget);
    });

    testWidgets('resendCode activa cooldown visual en el botón', (
      tester,
    ) async {
      when(() => repository.resendCode(email: any(named: 'email')))
          .thenAnswer((_) async => AppStrings.verifyResendDefault);

      await tester.pumpWidget(
        wrap(
          const VerifyEmailScreen(
            email: 'nuevo@b.com',
            resendCooldownSeconds: 3,
          ),
        ),
      );

      await tapSubmit(tester, AppStrings.verifyResend);
      await tester.pump();

      expect(find.text(AppStrings.verifyResendCooldown(3)), findsOneWidget);
      verify(() => repository.resendCode(email: 'nuevo@b.com')).called(1);

      await tester.pump(const Duration(seconds: 3));
      expect(find.text(AppStrings.verifyResend), findsOneWidget);
    });
  });
}
