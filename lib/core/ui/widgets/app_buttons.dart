import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Botón de acción principal con gradiente dorado (.primary-button).
/// DESIGN.md §8: altura 51–54 px, radio 14 px, peso 700, texto oscuro.
///
/// Mientras [isLoading] es `true` el botón se deshabilita y muestra un
/// indicador, evitando envíos duplicados (AGENTS.md §7).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  static const Color _foreground = Color(0xFF26152B);

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(14);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled || isLoading ? 1 : 0.5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: const Color(0x45FFF7E1)),
            gradient: const LinearGradient(
              begin: Alignment(-1, -0.4),
              end: Alignment(1, 0.4),
              colors: [Color(0xFFB99A68), Color(0xFFEAD6AD), Color(0xFFC2A16F)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2BD7BA89),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: enabled ? onPressed : null,
              splashColor: const Color(0x33FFFFFF),
              highlightColor: const Color(0x14FFFFFF),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isLoading
                        ? const Center(
                            key: ValueKey('loading'),
                            child: SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: _foreground,
                              ),
                            ),
                          )
                        : Row(
                            key: const ValueKey('label'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.button.copyWith(
                                    color: _foreground,
                                  ),
                                ),
                              ),
                              if (icon != null) ...[
                                const SizedBox(width: 12),
                                Icon(icon, size: 18, color: _foreground),
                              ],
                            ],
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

/// Botón secundario de cristal oscuro (.google-button). DESIGN.md §8.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final radius = BorderRadius.circular(13);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.5,
        child: Material(
          color: const Color(0x09FFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: const BorderSide(color: Color(0x1AFFFFFF)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            hoverColor: const Color(0x0FFFFFFF),
            splashColor: const Color(0x1FD7BA89),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 11),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.button.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD9D1DC),
                        ),
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

/// Enlace de texto dorado con área táctil mínima de 44 px (DESIGN.md §16).
class LinkButton extends StatelessWidget {
  const LinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppTextStyles.link,
  });

  final String label;
  final VoidCallback? onPressed;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.gold,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: style),
    );
  }
}
