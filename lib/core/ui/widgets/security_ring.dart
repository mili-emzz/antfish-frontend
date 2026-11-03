import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Anillo circular de porcentaje de protección (`SecurityRing` en App.tsx).
///
/// Se utiliza en `HomeScreen` (compacto) y en `StatsScreen` (`large: true`).
class SecurityRing extends StatelessWidget {
  const SecurityRing({
    super.key,
    this.score = 94,
    this.label = AppStrings.homeSecurityRingLabel,
    this.large = false,
  });

  final int score;
  final String label;
  final bool large;

  double _resolveDimension(double screenWidth) {
    if (large) {
      return screenWidth <= 520 ? 105 : 125;
    }
    if (screenWidth <= 370) return 82;
    if (screenWidth <= 520) return 94;
    return 108;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double dimension = _resolveDimension(screenWidth);
    final double iconSize = screenWidth <= 370 && !large ? 21 : 28;
    final int clampedScore = score.clamp(0, 100);

    return Semantics(
      label: '$label: $clampedScore%',
      excludeSemantics: true,
      child: Container(
        width: dimension,
        height: dimension,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x1FD7BA89), blurRadius: 16)],
        ),
        child: CustomPaint(
          painter: _SecurityRingPainter(progress: clampedScore / 100.0),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: iconSize,
                      color: AppColors.gold,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$clampedScore%',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.display,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 8,
                        color: Color(0xFF9B8D9F),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityRingPainter extends CustomPainter {
  const _SecurityRingPainter({required this.progress});

  final double progress;

  static const double _ringThickness = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Pista circular exterior
    final trackPaint = Paint()
      ..color = const Color(0x12FFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, trackPaint);

    // Arco de progreso en dorado desde las 12 en punto (-pi/2)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        true,
        progressPaint,
      );
    }

    // Círculo interior oscuro (.security-ring::before inset: 6px)
    final innerPaint = Paint()
      ..color = const Color(0xFF211029)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - _ringThickness, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _SecurityRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
