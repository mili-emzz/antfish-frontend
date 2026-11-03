import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fondo inmersivo con gradiente berenjena y resplandores ambientales
/// (.auth-page / .ambient-one / .ambient-two). DESIGN.md §3 y §14.
///
/// Los resplandores son estáticos: no se animan grandes superficies de fondo.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundAubergine,
            AppColors.backgroundViolet,
            Color(0xFF120817),
          ],
          stops: [0, 0.48, 1],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: _Glows())),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glows extends StatelessWidget {
  const _Glows();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        // Resplandor púrpura superior izquierdo.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.84, -0.7),
                radius: 0.9,
                colors: [Color(0x476B317F), Color(0x006B317F)],
              ),
            ),
          ),
        ),
        // Resplandor lila inferior derecho.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.84, 0.6),
                radius: 1.0,
                colors: [Color(0x24B47EB3), Color(0x00B47EB3)],
              ),
            ),
          ),
        ),
        // Halo dorado tenue en la esquina inferior.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1.1, 1.1),
                radius: 0.7,
                colors: [Color(0x14D7BA89), Color(0x00D7BA89)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
