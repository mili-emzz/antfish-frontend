import 'package:flutter/widgets.dart';

/// Clases de tamaño de pantalla según DESIGN.md §15 (Responsive).
///
/// - [compact]: ancho ≤ 520 px (móvil). Padding lateral de 18 px.
/// - [medium]: 521–800 px (móvil grande / tablet vertical). Una columna.
/// - [expanded]: > 800 px (tablet horizontal / escritorio). Dos columnas.
enum ScreenSize {
  compact,
  medium,
  expanded;

  static const double compactMax = 520;
  static const double mediumMax = 800;

  static ScreenSize fromWidth(double width) {
    if (width <= compactMax) return ScreenSize.compact;
    if (width <= mediumMax) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  static ScreenSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  bool get isCompact => this == ScreenSize.compact;
  bool get isExpanded => this == ScreenSize.expanded;
}
