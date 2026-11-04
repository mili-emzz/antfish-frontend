import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Superficie de cristal translúcida (.glass-panel) oficial de AntFish.
/// Fuente de verdad: DESIGN.md §7.
///
/// Incluye gradiente translúcido, blur de 24 px, borde fino, reflejo superior
/// interno y sombra profunda.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(20.0),
    this.borderColor = AppColors.glassBorder,
    this.backgroundColor = AppColors.glassPanel,
    this.elevated = false,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Color backgroundColor;

  /// Aplica el gradiente y la sombra profunda de los paneles principales.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: Color(0x59040008),
                  blurRadius: 80,
                  offset: Offset(0, 30),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: elevated ? null : backgroundColor,
              gradient: elevated
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0x15FFFFFF), Color(0x09FFFFFF)],
                    )
                  : null,
              borderRadius: radius,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
