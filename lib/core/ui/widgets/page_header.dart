import 'package:flutter/material.dart';

import '../layout/breakpoints.dart';
import '../theme/app_text_styles.dart';
import 'brand_mark.dart';

/// Cabecera de pantalla interna (.page-header en App.tsx).
///
/// Muestra la marca compacta, el eyebrow en dorado, el título principal en
/// Manrope y el texto descriptivo secundario.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.copy,
  });

  final String eyebrow;
  final String title;
  final String copy;

  @override
  Widget build(BuildContext context) {
    final isCompact = ScreenSize.of(context).isCompact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandMark(compact: true),
        SizedBox(height: isCompact ? 38 : 48),
        Text(eyebrow, style: AppTextStyles.eyebrow),
        const SizedBox(height: 10),
        Text(title, style: AppTextStyles.pageHeaderTitle),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Text(copy, style: AppTextStyles.pageHeaderCopy),
        ),
        const SizedBox(height: 27),
      ],
    );
  }
}

