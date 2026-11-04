import 'package:flutter/material.dart';

import '../../../../core/ui/layout/breakpoints.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/ambient_background.dart';
import '../../../../core/ui/widgets/brand_mark.dart';
import '../../../../core/ui/widgets/glass_panel.dart';
import 'auth_hero_panel.dart';
import 'auth_mode_tabs.dart';

/// Estructura responsive compartida por Login y Registro (.auth-shell).
///
/// - **> 800 px:** dos columnas. Visual narrativo a la izquierda y panel de
///   440 px a la derecha, con ancho máximo de 1120 px.
/// - **≤ 800 px:** una columna de hasta 460 px. Se oculta el visual y la marca
///   pasa al interior del panel.
/// - **≤ 520 px:** padding lateral de 18 px y panel más compacto.
///
/// Siempre se puede desplazar, así el teclado, el modo horizontal y el texto
/// ampliado por accesibilidad nunca recortan el formulario.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    this.mode,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.subtitleWidget,
    required this.child,
  });

  /// Pestaña activa. Si es `null` (p. ej. verificación de correo) no se
  /// muestran las pestañas Ingresar / Registrarme.
  final AuthMode? mode;
  final String eyebrow;
  final String title;
  final String subtitle;

  /// Sustituye a [subtitle] cuando se necesita texto con partes resaltadas.
  final Widget? subtitleWidget;

  /// Contenido del formulario, debajo de las pestañas.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: GestureDetector(
        // Tocar fuera de un campo cierra el teclado.
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: AmbientBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = ScreenSize.fromWidth(constraints.maxWidth);
                return size.isExpanded
                    ? _buildTwoColumns(constraints)
                    : _buildSingleColumn(constraints, size);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _scrollable({
    required BoxConstraints constraints,
    required EdgeInsets padding,
    required Widget child,
  }) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: (constraints.maxHeight - padding.vertical).clamp(
            0,
            double.infinity,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildTwoColumns(BoxConstraints constraints) {
    final double width = constraints.maxWidth;
    final double gap = (width * 0.08).clamp(40.0, 110.0);

    return _scrollable(
      constraints: constraints,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: AuthHeroPanel(
                screenWidth: width,
                availableHeight: constraints.maxHeight,
              ),
            ),
            SizedBox(width: gap),
            SizedBox(width: 440, child: _panel(ScreenSize.expanded)),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleColumn(BoxConstraints constraints, ScreenSize size) {
    final double horizontal = size.isCompact ? 18 : 16;

    return _scrollable(
      constraints: constraints,
      padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: _panel(size),
      ),
    );
  }

  Widget _panel(ScreenSize size) {
    final EdgeInsets padding = switch (size) {
      ScreenSize.expanded => const EdgeInsets.fromLTRB(42, 42, 42, 20),
      ScreenSize.medium => const EdgeInsets.fromLTRB(24, 27, 24, 16),
      ScreenSize.compact => const EdgeInsets.fromLTRB(20, 24, 20, 14),
    };

    return GlassPanel(
      elevated: true,
      borderRadius: size.isExpanded ? 32 : 28,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!size.isExpanded) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: BrandMark(compact: true),
            ),
            SizedBox(height: size.isCompact ? 28 : 37),
          ],
          Text(eyebrow, style: AppTextStyles.eyebrow),
          const SizedBox(height: 10),
          Semantics(
            header: true,
            child: Text(
              title,
              style: size.isCompact
                  ? AppTextStyles.panelTitle.copyWith(fontSize: 24)
                  : AppTextStyles.panelTitle,
            ),
          ),
          const SizedBox(height: 9),
          subtitleWidget ?? Text(subtitle, style: AppTextStyles.bodyMuted),
          const SizedBox(height: 24),
          if (mode != null) ...[
            AuthModeTabs(current: mode!),
            SizedBox(height: size.isExpanded ? 26 : 22),
          ],
          child,
        ],
      ),
    );
  }
}
