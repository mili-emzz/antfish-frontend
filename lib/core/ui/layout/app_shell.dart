import 'package:flutter/material.dart';

import '../widgets/ambient_background.dart';
import '../widgets/crystal_bottom_nav.dart';
import 'breakpoints.dart';

/// Contenedor principal de la aplicación autenticada (`AppShell` en App.tsx).
///
/// Aplica el fondo ambiental Dark Crystal, la columna central `.mobile-app`
/// (`max-width: 760px`), el área desplazable `.screen-content` y la barra de
/// navegación flotante [CrystalBottomNav].
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.child,
    this.onScanPressed,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback? onScanPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isCompact = ScreenSize.of(context).isCompact;
    final EdgeInsets contentPadding = isCompact
        ? const EdgeInsets.fromLTRB(18, 22, 18, 125)
        : const EdgeInsets.fromLTRB(30, 28, 30, 135);
    final double navHorizontalMargin = isCompact ? 10 : 15;
    final double navBottomOffset = isCompact ? 10 : 15;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x8C271031), Color(0xAB130818)],
                  ),
                  border: Border.symmetric(
                    vertical: BorderSide(color: Color(0x06FFFFFF), width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(color: Color(0x4D000000), blurRadius: 90),
                  ],
                ),
                child: SizedBox.expand(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SingleChildScrollView(
                          padding: contentPadding,
                          child: child,
                        ),
                      ),
                      Positioned(
                        left: navHorizontalMargin,
                        right: navHorizontalMargin,
                        bottom: navBottomOffset,
                        child: SafeArea(
                          top: false,
                          child: Center(
                            child: CrystalBottomNav(
                              currentTab: currentTab,
                              onTabSelected: onTabSelected,
                              onScanPressed: onScanPressed,
                            ),
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
      ),
    );
  }
}
