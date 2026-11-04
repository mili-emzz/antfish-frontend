import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Marca AntFish: escudo dorado en cristal + nombre (.brand). DESIGN.md §17.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  /// Versión reducida (38 px) para encabezados y paneles móviles.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 38 : 52;

    return Semantics(
      label: AppStrings.brandName,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(compact ? 12 : 17),
              border: Border.all(color: const Color(0x5CD7BA89)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x29D7BA89), Color(0x0DB47EB3)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2E000000),
                  blurRadius: 30,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: compact ? 21 : 29,
                  color: AppColors.gold,
                ),
                // Destello (.brand-glint).
                Positioned(
                  right: compact ? 5 : 7,
                  top: compact ? 5 : 7,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFF7DF),
                      boxShadow: [
                        BoxShadow(color: Color(0xFFFFF7DF), blurRadius: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.brandName,
                  style: AppTextStyles.brandName,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!compact)
                  Text(
                    AppStrings.brandTagline.toUpperCase(),
                    style: AppTextStyles.brandTagline,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
