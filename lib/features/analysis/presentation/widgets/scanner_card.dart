import 'package:flutter/material.dart';

import '../../../../core/ui/layout/breakpoints.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/glass_panel.dart';
import '../../../../l10n/app_strings.dart';

/// Tipo de entrada seleccionada en el escáner (`inputType` en App.tsx).
enum AnalysisInputType { url, sms }

/// Tarjeta interactiva de escaneo (`.scanner-card` en App.tsx).
///
/// PLANTILLA SIN BACKEND:
/// - Permite conmutar entre `Enlace URL` y `Mensaje SMS`, escribir en el campo
///   y limpiar el texto con el botón `×`.
/// - Nunca persiste el contenido del texto en almacenamiento local (AGENTS.md §8).
/// - El botón `Analizar ahora` permanece deshabilitado (`onAnalyze == null`)
///   mientras el endpoint `POST /api/v1/analysis` no esté disponible.
class ScannerCard extends StatefulWidget {
  const ScannerCard({
    super.key,
    this.initialInputType = AnalysisInputType.url,
    this.onInputTypeChanged,
    this.onAnalyze,
  });

  final AnalysisInputType initialInputType;
  final ValueChanged<AnalysisInputType>? onInputTypeChanged;

  /// Callback opcional para `POST /api/v1/analysis`. Mientras sea `null`
  /// (sin backend conectado), el botón de análisis permanece deshabilitado.
  final ValueChanged<String>? onAnalyze;

  @override
  State<ScannerCard> createState() => _ScannerCardState();
}

class _ScannerCardState extends State<ScannerCard> {
  late AnalysisInputType _inputType = widget.initialInputType;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _selectType(AnalysisInputType type) {
    if (_inputType == type) return;
    setState(() => _inputType = type);
    widget.onInputTypeChanged?.call(type);
  }

  void _clearInput() {
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isCompact = ScreenSize.fromWidth(screenWidth).isCompact;
    final bool isUltraNarrow = screenWidth <= 370;
    final bool isUrl = _inputType == AnalysisInputType.url;
    final bool hasText = _controller.text.trim().isNotEmpty;
    final VoidCallback? scanAction = widget.onAnalyze != null && hasText
        ? () => widget.onAnalyze!(_controller.text.trim())
        : null;

    return GlassPanel(
      borderRadius: 25,
      padding: EdgeInsets.all(isCompact ? 20 : 25),
      borderColor: const Color(0x26D7BA89),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // .scanner-topline
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF74D7AB),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF74D7AB), blurRadius: 9),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  AppStrings.homeEyebrow,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.body,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.35,
                    color: AppColors.gold,
                  ),
                ),
              ),
              if (!isUltraNarrow)
                const Text(
                  AppStrings.homeScannerEngineStatus,
                  style: TextStyle(
                    fontFamily: AppTextStyles.body,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF746B78),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            AppStrings.homeScannerHeading,
            style: TextStyle(
              fontFamily: AppTextStyles.display,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.63,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            AppStrings.homeCopy,
            style: TextStyle(
              fontFamily: AppTextStyles.body,
              fontSize: 12,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 19),
          // .type-switch
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0x40040108),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0x0FFFFFFF)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TypeSwitchButton(
                    label: AppStrings.homeTypeUrl,
                    icon: Icons.link_rounded,
                    active: isUrl,
                    onTap: () => _selectType(AnalysisInputType.url),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _TypeSwitchButton(
                    label: AppStrings.homeTypeSms,
                    icon: Icons.chat_bubble_outline_rounded,
                    active: !isUrl,
                    onTap: () => _selectType(AnalysisInputType.sms),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // .scan-input-wrap
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0x4D060209),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    isUrl
                        ? Icons.link_rounded
                        : Icons.chat_bubble_outline_rounded,
                    size: 20,
                    color: const Color(0xFF8D7F91),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: isUrl ? 1 : 3,
                    maxLines: isUrl ? 2 : 5,
                    keyboardType: isUrl
                        ? TextInputType.url
                        : TextInputType.multiline,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.body,
                      fontSize: 12,
                      height: 1.6,
                      color: Color(0xFFF5EFF6),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: isUrl
                          ? AppStrings.homeInputUrlHint
                          : AppStrings.homeInputSmsHint,
                      hintStyle: const TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 12,
                        height: 1.6,
                        color: Color(0xFF655B69),
                      ),
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: AppStrings.homeInputClearSemantics,
                    child: InkWell(
                      onTap: _clearInput,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '×',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1,
                            color: Color(0xFF766A7B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 9),
          // .privacy-note
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 13,
                    color: Color(0xFF756B79),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    AppStrings.homePrivacyNote,
                    style: TextStyle(
                      fontFamily: AppTextStyles.body,
                      fontSize: 9,
                      color: Color(0xFF756B79),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          // .scan-button (deshabilitado mientras no exista backend)
          _ScanSubmitButton(
            label: AppStrings.homeScanSubmit,
            onPressed: scanAction,
          ),
        ],
      ),
    );
  }
}

class _TypeSwitchButton extends StatelessWidget {
  const _TypeSwitchButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = active ? Colors.white : const Color(0xFF918595);

    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: active ? const Color(0x29B47EB3) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? const Color(0x21B47EB3) : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: foreground),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanSubmitButton extends StatelessWidget {
  const _ScanSubmitButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final radius = BorderRadius.circular(15);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.55,
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
              onTap: onPressed,
              borderRadius: radius,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 54),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF37203D),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.center_focus_strong_outlined,
                          size: 18,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.body,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF26152B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF26152B),
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
