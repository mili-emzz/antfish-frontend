import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Escala tipográfica de DESIGN.md §4.
///
/// Manrope: títulos, cifras y marca. DM Sans: cuerpo, controles y etiquetas.
/// Si las fuentes no están empaquetadas, Flutter usa la fuente del sistema.
abstract final class AppTextStyles {
  static const String display = 'Manrope';
  static const String body = 'DM Sans';

  /// Etiqueta superior en mayúsculas con tracking amplio (.eyebrow).
  static const TextStyle eyebrow = TextStyle(
    fontFamily: body,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: AppColors.gold,
  );

  /// Hero de autenticación (42–67 px). El tamaño final se calcula según el ancho.
  static TextStyle authHero(double fontSize) => TextStyle(
    fontFamily: display,
    fontSize: fontSize,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: -0.055 * fontSize,
    color: AppColors.textLight,
  );

  /// Título del panel de autenticación (h2).
  static const TextStyle panelTitle = TextStyle(
    fontFamily: display,
    fontSize: 27,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.9,
    color: AppColors.textLight,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: body,
    fontSize: 13,
    height: 1.45,
    color: AppColors.muted,
  );

  static const TextStyle heroCopy = TextStyle(
    fontFamily: body,
    fontSize: 16,
    height: 1.65,
    color: Color(0xFFBBB0BE),
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: body,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFFBDB1C0),
  );

  static const TextStyle fieldInput = TextStyle(
    fontFamily: body,
    fontSize: 14,
    color: Color(0xFFF9F4FA),
  );

  static const TextStyle fieldHint = TextStyle(
    fontFamily: body,
    fontSize: 14,
    color: Color(0xFF7A6F7E),
  );

  static const TextStyle fieldHelper = TextStyle(
    fontFamily: body,
    fontSize: 11,
    height: 1.35,
    color: Color(0xFF948899),
  );

  static const TextStyle button = TextStyle(
    fontFamily: body,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle link = TextStyle(
    fontFamily: body,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: body,
    fontSize: 11,
    height: 1.5,
    color: Color(0xFF8A7E8E),
  );

  static const TextStyle brandName = TextStyle(
    fontFamily: display,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
    color: AppColors.textLight,
  );

  static const TextStyle brandTagline = TextStyle(
    fontFamily: body,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.8,
    color: AppColors.muted,
  );

  /// Título principal de pantallas internas (.page-header > h1).
  static const TextStyle pageHeaderTitle = TextStyle(
    fontFamily: display,
    fontSize: 33,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -1.48,
    color: AppColors.textLight,
  );

  /// Subtítulo descriptivo de pantallas internas (.page-header > p).
  static const TextStyle pageHeaderCopy = TextStyle(
    fontFamily: body,
    fontSize: 12,
    height: 1.5,
    color: AppColors.muted,
  );

  /// Etiqueta de ítem en barra de navegación inferior (.bottom-nav span/small).
  static const TextStyle bottomNavLabel = TextStyle(
    fontFamily: body,
    fontSize: 9,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}
