import '../../../../l10n/app_strings.dart';

/// Validadores puros de los formularios de autenticación.
///
/// Solo validan formato en el cliente para mejorar la UX. La validación
/// definitiva es responsabilidad del backend.
abstract final class AuthValidators {
  /// Longitud mínima tomada del prototipo React.
  /// PENDIENTE: confirmar con el backend (AGENTS.md §11, no inventar límites).
  static const int passwordMinLength = 8;

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  /// Normaliza el correo como lo hace el backend (D5): sin espacios y en minúsculas.
  static String normalizeEmail(String value) => value.trim().toLowerCase();

  /// Código de verificación: exactamente 6 dígitos (RF-06.2).
  static const int verificationCodeLength = 6;

  static String? verificationCode(String? value) {
    final code = value ?? '';
    if (code.isEmpty) return AppStrings.verifyValidationRequired;
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return AppStrings.verifyValidationIncomplete;
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationNameRequired;
    }
    return null;
  }

  static String? email(String? value) {
    final normalized = normalizeEmail(value ?? '');
    if (normalized.isEmpty) return AppStrings.validationEmailRequired;
    if (!_emailPattern.hasMatch(normalized)) {
      return AppStrings.validationEmailInvalid;
    }
    return null;
  }

  /// Contraseña de login: solo se exige que no esté vacía.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationPasswordRequired;
    }
    return null;
  }

  /// Contraseña de registro: obligatoria y con longitud mínima.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationPasswordRequired;
    }
    if (value.length < passwordMinLength) {
      return AppStrings.validationPasswordTooShort;
    }
    return null;
  }
}
