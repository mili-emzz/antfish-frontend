import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/brand_mark.dart';
import '../../../../l10n/app_strings.dart';

/// Columna narrativa y visual de autenticación (.auth-visual).
/// Solo se muestra en pantallas anchas (> 800 px). DESIGN.md §15.
class AuthHeroPanel extends StatelessWidget {
  const AuthHeroPanel({
    super.key,
    required this.screenWidth,
    required this.availableHeight,
  });

  final double screenWidth;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    // clamp(42px, 5vw, 67px), igual que el prototipo.
    final double heroFont = (screenWidth * 0.05).clamp(42.0, 67.0);
    // El escudo se reduce u oculta en pantallas anchas pero bajas
    // (p. ej. tablet en horizontal o ventana de escritorio pequeña).
    final double orbitSize = availableHeight < 620
        ? 0
        : availableHeight < 760
        ? 210
        : 290;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandMark(),
        SizedBox(height: orbitSize > 0 ? 24 : 48),
        if (orbitSize > 0) ...[
          Center(child: _ShieldOrbit(size: orbitSize)),
          const SizedBox(height: 12),
        ],
        Text(AppStrings.authHeroEyebrow, style: AppTextStyles.eyebrow),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: '${AppStrings.authHeroTitleLead}\n'),
              TextSpan(
                text: AppStrings.authHeroTitleAccent,
                style: TextStyle(color: AppColors.gold),
              ),
            ],
          ),
          style: AppTextStyles.authHero(heroFont),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const Text(
            AppStrings.authHeroCopy,
            style: AppTextStyles.heroCopy,
          ),
        ),
        const SizedBox(height: 40),
        const Wrap(
          spacing: 24,
          runSpacing: 10,
          children: [
            _TrustItem(
              icon: Icons.lock_outline,
              label: AppStrings.authTrustEncryption,
            ),
            _TrustItem(
              icon: Icons.auto_awesome_outlined,
              label: AppStrings.authTrustSpeed,
            ),
          ],
        ),
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF9D91A2);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 7),
        Text(label, style: AppTextStyles.caption.copyWith(color: color)),
      ],
    );
  }
}

/// Escudo central con órbitas decorativas (.shield-orbit). Estático.
class _ShieldOrbit extends StatelessWidget {
  const _ShieldOrbit({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double scale = size / 290;

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _Orbit(
              width: size,
              height: size * 0.66,
              angle: 0.314, // 18°
              color: const Color(0x33B47EB3),
            ),
            _Orbit(
              width: size * 0.82,
              height: size * 0.82,
              angle: -0.576, // -33°
              color: const Color(0x26D7BA89),
            ),
            Container(
              width: 142 * scale,
              height: 166 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(65 * scale, 58 * scale),
                  bottom: Radius.elliptical(78 * scale, 111 * scale),
                ),
                border: Border.all(color: const Color(0x42D7BA89)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x1AFFFFFF), Color(0x14B47EB3)],
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x3BB47EB3), blurRadius: 65),
                  BoxShadow(
                    color: Color(0x52000000),
                    blurRadius: 70,
                    offset: Offset(0, 25),
                  ),
                ],
              ),
              child: Icon(
                Icons.fingerprint,
                size: 58 * scale,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orbit extends StatelessWidget {
  const _Orbit({
    required this.width,
    required this.height,
    required this.angle,
    required this.color,
  });

  final double width;
  final double height;
  final double angle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: OvalBorder(side: BorderSide(color: color)),
                ),
              ),
            ),
            // Punto dorado sobre la órbita.
            Align(
              alignment: const Alignment(-0.62, -0.78),
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold,
                  boxShadow: [BoxShadow(color: AppColors.gold, blurRadius: 16)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
