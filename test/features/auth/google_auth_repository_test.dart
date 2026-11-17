import 'package:antfish/core/errors/app_failure.dart';
import 'package:antfish/features/auth/data/auth_remote_data_source.dart';
import 'package:antfish/features/auth/data/auth_repository_impl.dart';
import 'package:antfish/features/auth/data/google_auth_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockGoogle extends Mock implements GoogleAuthDataSource {}

DioException _httpError(int status, [Map<String, dynamic>? body]) {
  final req = RequestOptions(path: '/auth/google');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status, data: body),
  );
}

void main() {
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

  void stubPost(Object Function() answer) {
    when(() => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')))
        .thenAnswer((_) async => answer() as Response<Map<String, dynamic>>);
  }

  test('login exitoso devuelve tokens y envía id_token', () async {
    when(() => google.obtainIdToken()).thenAnswer((_) async => 'idtok');
    stubPost(
      () => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/auth/google'),
        statusCode: 200,
        data: {
          'access_token': 'a',
          'refresh_token': 'r',
          'user': {'email': 'x@y.com', 'proveedor_auth': 'google'},
        },
      ),
    );

    final session = await repo.signInWithGoogle();

    expect(session?.accessToken, 'a');
    expect(session?.refreshToken, 'r');
    expect(session?.email, 'x@y.com');
    verify(
      () => dio.post<Map<String, dynamic>>(
        '/auth/google',
        data: {'id_token': 'idtok'},
      ),
    ).called(1);
  });

  test('cancelación del usuario devuelve null sin llamar al backend', () async {
    when(() => google.obtainIdToken()).thenAnswer((_) async => null);

    expect(await repo.signInWithGoogle(), isNull);
    verifyNever(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    );
  });

  final cases = <int, Matcher>{
    401: isA<UnauthorizedFailure>(),
    409: isA<ConflictFailure>(),
    429: isA<RateLimitFailure>(),
    503: isA<ServerFailure>(),
  };
  cases.forEach((status, matcher) {
    test('HTTP $status se mapea a AppFailure y no se reintenta', () async {
      when(() => google.obtainIdToken()).thenAnswer((_) async => 'idtok');
      when(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenThrow(_httpError(status));

      await expectLater(repo.signInWithGoogle(), throwsA(matcher));
      verify(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).called(1);
    });
  });
}
