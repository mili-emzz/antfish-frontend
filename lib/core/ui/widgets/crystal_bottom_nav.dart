import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Pestañas principales del shell de AntFish (`Screen` en App.tsx).
enum AppTab {
  home(AppRoutes.home),
  history(AppRoutes.history),
  stats(AppRoutes.stats),
  profile(AppRoutes.profile);

  const AppTab(this.route);

  /// Ruta nombrada asociada a la pestaña.
  final String route;
}

/// Barra de navegación inferior flotante en cristal (.bottom-nav en App.tsx).
///
/// Incluye 4 destinos (`Inicio`, `Historial`, `Métricas`, `Perfil`) y el botón
/// central elevado de escaneo (`Escanear`).
class CrystalBottomNav extends StatelessWidget {
  const CrystalBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.onScanPressed,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback? onScanPressed;

  static const double _barHeight = 78.0;
  static const double _protrusionHeight = 16.0;
  static const double totalHeight = _barHeight + _protrusionHeight;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(25);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 690),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Superficie translúcida inferior (.bottom-nav)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _barHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x70000000),
                      blurRadius: 50,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xC723112B),
                        borderRadius: radius,
                        border: Border.all(
                          color: const Color(0x21FFFFFF),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Fila de 5 acciones (1fr 1fr 1.15fr 1fr 1fr)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 20,
                      child: _NavTabButton(
                        label: AppStrings.navHome,
                        icon: Icons.home_outlined,
                        active: currentTab == AppTab.home,
                        onTap: () => onTabSelected(AppTab.home),
                      ),
                    ),
                    Expanded(
                      flex: 20,
                      child: _NavTabButton(
                        label: AppStrings.navHistory,
                        icon: Icons.schedule_rounded,
                        active: currentTab == AppTab.history,
                        onTap: () => onTabSelected(AppTab.history),
                      ),
                    ),
                    Expanded(
                      flex: 23,
                      child: _CentralScanButton(
                        onTap:
                            onScanPressed ?? () => onTabSelected(AppTab.home),
                      ),
                    ),
                    Expanded(
                      flex: 20,
                      child: _NavTabButton(
                        label: AppStrings.navStats,
                        icon: Icons.bar_chart_rounded,
                        active: currentTab == AppTab.stats,
                        onTap: () => onTabSelected(AppTab.stats),
                      ),
                    ),
                    Expanded(
                      flex: 20,
                      child: _NavTabButton(
                        label: AppStrings.navProfile,
                        icon: Icons.person_outline_rounded,
                        active: currentTab == AppTab.profile,
                        onTap: () => onTabSelected(AppTab.profile),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? AppColors.gold : const Color(0xFF746A78);

    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: AppTextStyles.bottomNavLabel.copyWith(color: color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CentralScanButton extends StatelessWidget {
  const _CentralScanButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.navScanSemantics,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF211029), width: 5),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF51305C), Color(0xFF2E1638)],
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x40B47EB3), blurRadius: 25),
                ],
              ),
              child: const Center(
                child: CustomPaint(
                  size: Size.square(25),
                  painter: _ScanReticlePainter(color: AppColors.gold),
                ),
              ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AppStrings.navScan,
                maxLines: 1,
                style: AppTextStyles.bottomNavLabel.copyWith(
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

/// Dibuja el ícono vectorial `scan` de App.tsx:
/// `<path d="M8 3H5a2 2 0 0 0-2 2v3M16 3h3a2 2 0 0 1 2 2v3M21 16v3a2 2 0 0 1-2 2h-3M8 21H5a2 2 0 0 1-2-2v-3" />`
/// `<path d="M7 12h10M12 7v10" />`
class _ScanReticlePainter extends CustomPainter {
  const _ScanReticlePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    double s(double v) => v * scale;

    final path = Path()
      // Esquina superior izquierda: M8 3 H5 a2 2 0 0 0 -2 2 v3
      ..moveTo(s(8), s(3))
      ..lineTo(s(5), s(3))
      ..arcToPoint(
        Offset(s(3), s(5)),
        radius: Radius.circular(s(2)),
        clockwise: false,
      )
      ..lineTo(s(3), s(8))
      // Esquina superior derecha: M16 3 h3 a2 2 0 0 1 2 2 v3
      ..moveTo(s(16), s(3))
      ..lineTo(s(19), s(3))
      ..arcToPoint(Offset(s(21), s(5)), radius: Radius.circular(s(2)))
      ..lineTo(s(21), s(8))
      // Esquina inferior derecha: M21 16 v3 a2 2 0 0 1 -2 2 h-3
      ..moveTo(s(21), s(16))
      ..lineTo(s(21), s(19))
      ..arcToPoint(Offset(s(19), s(21)), radius: Radius.circular(s(2)))
      ..lineTo(s(16), s(21))
      // Esquina inferior izquierda: M8 21 H5 a2 2 0 0 1 -2 -2 v-3
      ..moveTo(s(8), s(21))
      ..lineTo(s(5), s(21))
      ..arcToPoint(Offset(s(3), s(19)), radius: Radius.circular(s(2)))
      ..lineTo(s(3), s(16))
      // Cruz central: M7 12 h10 M12 7 v10
      ..moveTo(s(7), s(12))
      ..lineTo(s(17), s(12))
      ..moveTo(s(12), s(7))
      ..lineTo(s(12), s(17));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScanReticlePainter oldDelegate) =>
      oldDelegate.color != color;
}
