import 'package:flutter/material.dart';

import '../../../../core/ui/layout/breakpoints.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/brand_mark.dart';
import '../../../../l10n/app_strings.dart';
import '../widgets/history_row_item.dart';
import '../widgets/risk_traffic_light_card.dart';
import '../widgets/scanner_card.dart';

/// Pantalla principal de escaneo (`HomeScreen` en App.tsx).
///
/// PLANTILLA SIN BACKEND:
/// - Permite interactuar con el selector URL/SMS y el campo de texto.
/// - El botón de envío a `POST /api/v1/analysis` permanece deshabilitado hasta
///   que el backend esté disponible.
/// - Admite [initialShowResult] para previsualizar y verificar [ResultCard]
///   o alternar con [RiskTrafficLightCard].
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialShowResult = false,
    this.onOpenProfile,
    this.onViewAllHistory,
  });

  final bool initialShowResult;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onViewAllHistory;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _showResult = widget.initialShowResult;

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialShowResult != widget.initialShowResult) {
      _showResult = widget.initialShowResult;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompact = ScreenSize.of(context).isCompact;
    final double titleFontSize = isCompact ? 27 : 36;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // .app-header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(child: BrandMark(compact: true)),
            _AvatarButton(onTap: widget.onOpenProfile),
          ],
        ),
        SizedBox(height: isCompact ? 31 : 38),
        // .hello-row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    AppStrings.homeGreeting,
                    style: TextStyle(
                      fontFamily: AppTextStyles.body,
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 7),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isCompact ? 225 : 350,
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: const [
                          TextSpan(text: AppStrings.homeTitleLead),
                          TextSpan(
                            text: AppStrings.homeTitleAccent,
                            style: TextStyle(color: AppColors.gold),
                          ),
                        ],
                        style: TextStyle(
                          fontFamily: AppTextStyles.display,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                          letterSpacing: -0.045 * titleFontSize,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        SizedBox(height: isCompact ? 23 : 30),
        // .scanner-card
        ScannerCard(
          onInputTypeChanged: (_) {
            if (_showResult) setState(() => _showResult = false);
          },
        ),
        const SizedBox(height: 18),
        // .traffic-card o .result-card
        _showResult
            ? ResultCard(onDismiss: () => setState(() => _showResult = false))
            : const RiskTrafficLightCard(),
        const SizedBox(height: 35),
        // .recent-section
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.recentEyebrow, style: AppTextStyles.eyebrow),
                  SizedBox(height: 5),
                  Text(
                    AppStrings.recentTitle,
                    style: TextStyle(
                      fontFamily: AppTextStyles.display,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.54,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              enabled: widget.onViewAllHistory != null,
              label: AppStrings.recentViewAll,
              child: InkWell(
                onTap: widget.onViewAllHistory,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.recentViewAll,
                        style: TextStyle(
                          fontFamily: AppTextStyles.body,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 15,
                        color: AppColors.gold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        HistoryListCard(
          items: demoScanHistory.take(3).toList(),
          compactList: true,
        ),
      ],
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: AppStrings.homeAvatarSemantics,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x3DD7BA89)),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0x26D7BA89), Color(0x1FB47EB3)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      AppStrings.homeAvatarInitials,
                      style: TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF69D7A3),
                    border: Border.all(
                      color: const Color(0xFF23102C),
                      width: 2,
                    ),
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
