import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Separador horizontal con etiqueta centrada (.divider), p. ej. "o continúa con".
class LabeledDivider extends StatelessWidget {
  const LabeledDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: Divider(height: 1, thickness: 1, color: Color(0x12FFFFFF)),
    );

    return Row(
      children: [
        line,
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF857A89),
              ),
            ),
          ),
        ),
        line,
      ],
    );
  }
}
