import 'package:flutter/material.dart';

import '../../../../core/ui/layout/breakpoints.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/glass_panel.dart';
import '../../../../l10n/app_strings.dart';

/// Tipo de entrada seleccionada en el escáner (`inputType` en App.tsx).
enum AnalysisInputType {
  url,
  sms;

  String get apiValue => this == AnalysisInputType.url ? 'url' : 'sms';
}

/// Callback con el tipo seleccionado (`url` | `sms`) y el contenido validado.
typedef AnalysisSubmitCallback = void Function(
  AnalysisInputType type,
  String content,
);

/// Tarjeta interactiva de escaneo (`.scanner-card` en App.tsx).
///
/// - Permite conmutar entre `Enlace URL` y `Mensaje SMS`, escribir en el campo
///   y limpiar el texto con el botón `×`.
/// - Nunca persiste el contenido del texto en almacenamiento local (`AGENTS.md` §8).
/// - Valida límites de longitud del contrato v2 (2,048 URL / 1,600 SMS).
/// - Deshabilita el botón mientras [isSubmitting] es `true` (`AGENTS.md` §7).
class ScannerCard extends StatefulWidget {
  const ScannerCard({
    super.key,
    this.initialInputType = AnalysisInputType.url,
    this.onInputTypeChanged,
    this.onAnalyze,
    this.onAnalyzeSubmit,
    this.isSubmitting = false,
  });

  final AnalysisInputType initialInputType;
  final ValueChanged<AnalysisInputType>? onInputTypeChanged;

  /// Callback simple opcional (compatibilidad).
  final ValueChanged<String>? onAnalyze;

  /// Callback principal conectado a `POST /api/v1/analysis`.
  final AnalysisSubmitCallback? onAnalyzeSubmit;

  /// Bloquea el botón y muestra estado de carga mientras la petición está activa.
  final bool isSubmitting;

  @override
  State<ScannerCard> createState() => _ScannerCardState();
}

class _ScannerCardState extends State<ScannerCard> {
  static const int _maxUrlLength = 2048;
  static const int _maxSmsLength = 1600;

  late AnalysisInputType _inputType = widget.initialInputType;
  final TextEditingController _controller = TextEditingController();
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_validationError != null) {
      _validationError = null;
    }
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
    if (_inputType == type || widget.isSubmitting) return;
    setState(() {
      _inputType = type;
      _validationError = null;
    });
    widget.onInputTypeChanged?.call(type);
  }

  void _clearInput() {
    if (widget.isSubmitting) return;
    _controller.clear();
  }

  void _handleSubmit() {
    if (widget.isSubmitting) return;
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;

    final maxLength = _inputType == AnalysisInputType.url
        ? _maxUrlLength
        : _maxSmsLength;
    if (trimmed.length > maxLength) {
      setState(() {
        _validationError = _inputType == AnalysisInputType.url
            ? AppStrings.analysisUrlTooLong
            : AppStrings.analysisSmsTooLong;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    if (widget.onAnalyzeSubmit != null) {
      widget.onAnalyzeSubmit!(_inputType, trimmed);
    } else if (widget.onAnalyze != null) {
      widget.onAnalyze!(trimmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isCompact = ScreenSize.fromWidth(screenWidth).isCompact;
    final bool isUltraNarrow = screenWidth <= 370;
    final bool isUrl = _inputType == AnalysisInputType.url;
    final bool hasText = _controller.text.trim().isNotEmpty;
    final bool hasCallback =
        widget.onAnalyzeSubmit != null || widget.onAnalyze != null;
    final VoidCallback? scanAction =
        hasCallback && hasText && !widget.isSubmitting ? _handleSubmit : null;

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
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.gold,
                  ),
                ),
              ),
              if (!isUltraNarrow)
                const Text(
                  AppStrings.homeScannerEngineStatus,
                  style: TextStyle(
                    fontFamily: AppTextStyles.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            AppStrings.homeScannerHeading,
            style: TextStyle(
              fontFamily: AppTextStyles.display,
              fontSize: 22,
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
              fontSize: 14,
              color: AppColors.muted,
              height: 1.5,
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
              border: Border.all(
                color: _validationError != null
                    ? AppColors.riskCritical.withValues(alpha: 0.6)
                    : const Color(0x1AFFFFFF),
              ),
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
                    enabled: !widget.isSubmitting,
                    minLines: isUrl ? 1 : 3,
                    maxLines: isUrl ? 2 : 5,
                    keyboardType: isUrl
                        ? TextInputType.url
                        : TextInputType.multiline,
                    textInputAction: isUrl
                        ? TextInputAction.done
                        : TextInputAction.newline,
                    onSubmitted: isUrl && scanAction != null
                        ? (_) => _handleSubmit()
                        : null,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.body,
                      fontSize: 14,
                      height: 1.55,
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
                        fontSize: 14,
                        height: 1.55,
                        color: Color(0xFFA69AAA),
                      ),
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty && !widget.isSubmitting) ...[
                  const SizedBox(width: 4),
                  Semantics(
                    button: true,
                    label: AppStrings.homeInputClearSemantics,
                    child: InkWell(
                      onTap: _clearInput,
                      borderRadius: BorderRadius.circular(10),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Text(
                            '×',
                            style: TextStyle(
                              fontSize: 22,
                              height: 1,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_validationError != null) ...[
            const SizedBox(height: 8),
            Text(
              _validationError!,
              style: const TextStyle(
                fontFamily: AppTextStyles.body,
                fontSize: 12,
                color: AppColors.riskCritical,
              ),
            ),
          ],
          const SizedBox(height: 10),
          // .privacy-note
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 15,
                    color: AppColors.muted,
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppStrings.homePrivacyNote,
                    style: TextStyle(
                      fontFamily: AppTextStyles.body,
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          // .scan-button
          _ScanSubmitButton(
            label: widget.isSubmitting
                ? AppStrings.homeScanSubmitting
                : AppStrings.homeScanSubmit,
            isLoading: widget.isSubmitting,
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
  const _ScanSubmitButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final radius = BorderRadius.circular(15);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled || isLoading ? 1.0 : 0.55,
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
                        child: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(7),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.gold,
                                ),
                              )
                            : const Icon(
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
