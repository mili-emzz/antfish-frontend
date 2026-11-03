import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Campo de formulario de cristal (.field). DESIGN.md §9.
///
/// - Etiqueta siempre visible encima del campo (el placeholder no la sustituye).
/// - Icono de contexto inicial.
/// - Foco con borde dorado y halo discreto.
/// - Mensaje de ayuda y de error en texto (no solo color).
/// - Opción para mostrar u ocultar contraseñas con nombre accesible.
class CrystalTextField extends StatefulWidget {
  const CrystalTextField({
    super.key,
    required this.label,
    required this.icon,
    this.hint,
    this.helper,
    this.controller,
    this.focusNode,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.isPassword = false,
    this.enabled = true,
    this.onFieldSubmitted,
    this.maxLength,
  });

  final String label;
  final IconData icon;
  final String? hint;
  final String? helper;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final bool isPassword;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;
  final int? maxLength;

  @override
  State<CrystalTextField> createState() => _CrystalTextFieldState();
}

class _CrystalTextFieldState extends State<CrystalTextField> {
  late bool _obscured = widget.isPassword;
  FocusNode? _internalFocus;
  bool _hasFocus = false;

  FocusNode get _focus => widget.focusNode ?? (_internalFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _internalFocus?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() => _hasFocus = _focus.hasFocus);
  }

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 7),
          child: Text(widget.label, style: AppTextStyles.fieldLabel),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            boxShadow: _hasFocus
                ? const [BoxShadow(color: Color(0x12D7BA89), spreadRadius: 3)]
                : const [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focus,
            enabled: widget.enabled,
            validator: widget.validator,
            obscureText: _obscured,
            enableSuggestions: !widget.isPassword,
            autocorrect: !widget.isPassword,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            textCapitalization: widget.textCapitalization,
            onFieldSubmitted: widget.onFieldSubmitted,
            maxLength: widget.maxLength,
            autovalidateMode: AutovalidateMode.onUserInteractionIfError,
            style: AppTextStyles.fieldInput,
            cursorColor: AppColors.gold,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.fieldHint,
              helperText: widget.helper,
              helperStyle: AppTextStyles.fieldHelper,
              helperMaxLines: 2,
              errorMaxLines: 3,
              errorStyle: AppTextStyles.fieldHelper.copyWith(
                color: AppColors.riskCritical,
                fontWeight: FontWeight.w600,
              ),
              counterText: '',
              isDense: true,
              filled: true,
              fillColor: const Color(0x4508030B),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
              prefixIcon: Icon(widget.icon, size: 19),
              prefixIconColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? AppColors.gold
                    : const Color(0xFF837688),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 46,
                minHeight: 48,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      onPressed: () => setState(() => _obscured = !_obscured),
                      tooltip: _obscured
                          ? AppStrings.fieldPasswordShow
                          : AppStrings.fieldPasswordHide,
                      icon: Icon(
                        _obscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 19,
                        color: const Color(0xFF9A8E9E),
                      ),
                    )
                  : null,
              border: _border(const Color(0x17FFFFFF)),
              enabledBorder: _border(const Color(0x17FFFFFF)),
              disabledBorder: _border(const Color(0x0DFFFFFF)),
              focusedBorder: _border(const Color(0x8CD7BA89), 1.2),
              errorBorder: _border(const Color(0x99D96179)),
              focusedErrorBorder: _border(AppColors.riskCritical, 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
