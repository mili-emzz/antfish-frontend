import 'package:antfish/features/auth/presentation/validators/auth_validators.dart';
import 'package:antfish/l10n/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators.email', () {
    test('vacío', () {
      expect(AuthValidators.email(''), AppStrings.validationEmailRequired);
      expect(AuthValidators.email('   '), AppStrings.validationEmailRequired);
    });

    test('formato inválido', () {
      expect(AuthValidators.email('nombre'), AppStrings.validationEmailInvalid);
      expect(AuthValidators.email('a@b'), AppStrings.validationEmailInvalid);
    });

    test('válido con espacios y mayúsculas (normalización D5)', () {
      expect(AuthValidators.email('  Nombre@Correo.COM '), isNull);
      expect(
        AuthValidators.normalizeEmail('  Nombre@Correo.COM '),
        'nombre@correo.com',
      );
    });
  });

  group('AuthValidators.password', () {
    test('login solo exige no vacío', () {
      expect(
        AuthValidators.loginPassword(''),
        AppStrings.validationPasswordRequired,
      );
      expect(AuthValidators.loginPassword('x'), isNull);
    });

    test('registro exige longitud mínima', () {
      expect(
        AuthValidators.newPassword('1234567'),
        AppStrings.validationPasswordTooShort,
      );
      expect(AuthValidators.newPassword('12345678'), isNull);
    });
  });

  test('nombre obligatorio', () {
    expect(AuthValidators.name('  '), AppStrings.validationNameRequired);
    expect(AuthValidators.name('Alex'), isNull);
  });
}
