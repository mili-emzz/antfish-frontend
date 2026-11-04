import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Opción de un [CrystalSegmentedControl].
class SegmentOption<T> {
  const SegmentOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Control segmentado de cristal (.auth-tabs / .type-switch). DESIGN.md §8.
///
/// Contenedor oscuro, 4 px entre opciones, opción activa en púrpura translúcido
/// y todas las opciones con el mismo ancho. Se reutiliza para URL/SMS.
class CrystalSegmentedControl<T> extends StatelessWidget {
  const CrystalSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<SegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: const Color(0x40040108),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _segment(options[i])),
          ],
        ],
      ),
    );
  }

  Widget _segment(SegmentOption<T> option) {
    final bool active = option.value == selected;
    final radius = BorderRadius.circular(10);

    return Semantics(
      button: true,
      selected: active,
      label: option.label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: active ? const Color(0x29B47EB3) : Colors.transparent,
          border: Border.all(
            color: active ? const Color(0x21B47EB3) : Colors.transparent,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: active ? null : () => onChanged(option.value),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    option.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.button.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : const Color(0xFF9A8E9E),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
