import 'package:flutter/material.dart';

/// Tokens de color oficiales del Sistema de Diseño Dark Crystal Cyber-Shield de AntFish.
/// Fuente de verdad: DESIGN.md.
abstract final class AppColors {
  // Fondos principales con profundidad
  static const Color backgroundDeep = Color(0xFF110816);
  static const Color backgroundAubergine = Color(0xFF180A20);
  static const Color backgroundViolet = Color(0xFF240E2D);
  static const Color glassPanel = Color(
    0x0EFFFFFF,
  ); // rgba(255, 255, 255, 0.055)

  // Colores principales de marca
  static const Color plum = Color(
    0xFF462255,
  ); // Morado principal, fondos y superficies activas
  static const Color lilac = Color(
    0xFFB47EB3,
  ); // Resplandores, inteligencia y estados secundarios
  static const Color gold = Color(
    0xFFD7BA89,
  ); // Acciones, protección y destacados
  static const Color muted = Color(0xFFAA9EAE); // Texto secundario
  static const Color textLight = Color(
    0xFFF3EDF7,
  ); // Texto principal de alto contraste

  // Semáforo de riesgo (Fuente: DESIGN.md §3 y §12)
  static const Color riskSafe = Color(0xFF6AD6A2); // Riesgo bajo (0-19)
  static const Color riskMedium = Color(
    0xFFE0CC72,
  ); // Riesgo medio / Precaución (20-49)
  static const Color riskHigh = Color(0xFFDD905D); // Riesgo alto (50-79)
  static const Color riskCritical = Color(
    0xFFD96179,
  ); // Crítico / Amenaza confirmada (80-100)

  // Bordes y reflejos
  static const Color glassBorder = Color(0x1BFFFFFF); // ~0.105 opacidad
  static const Color goldBorder = Color(0x3DD7BA89); // ~0.24 opacidad
}
