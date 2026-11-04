import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Entrada de código de un solo uso con casillas de cristal (DESIGN.md §9).
///
/// Internamente es **un único campo de texto invisible** y seis casillas
/// visuales. Así funcionan sin código extra el pegado, el autocompletado de
/// SMS/correo (`oneTimeCode`), el borrado y los lectores de pantalla.
///
/// Las casillas se calculan con el ancho disponible, por lo que nunca
/// desbordan, ni siquiera en pantallas de 320 px.
class OtpCodeInput extends StatefulWidget {
  const OtpCodeInput({
    super.key,
    required this.semanticLabel,
    this.length = 6,
    this.enabled = true,
    this.errorText,
    this.onChanged,
    this.onCompleted,
  });

  final String semanticLabel;
  final int length;
  final bool enabled;

  /// Mensaje de error en texto (nunca solo color).
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call(_controller.text);
    if (_controller.text.length == widget.length) {
      widget.onCompleted?.call(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String text = _controller.text;
    final bool hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const double gap = 8;
            final double cellWidth =
                ((constraints.maxWidth - gap * (widget.length - 1)) /
                        widget.length)
                    .clamp(30.0, 58.0);
            final double cellHeight = (cellWidth * 1.2).clamp(46.0, 66.0);

            return Semantics(
              label: widget.semanticLabel,
              textField: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.enabled ? _focus.requestFocus : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Campo real: invisible pero funcional.
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focus,
                          enabled: widget.enabled,
                          maxLength: widget.length,
                          keyboardType: TextInputType.number,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          enableInteractiveSelection: false,
                          showCursor: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    ExcludeSemantics(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < widget.length; i++) ...[
                            if (i > 0) const SizedBox(width: gap),
                            _Cell(
                              width: cellWidth,
                              height: cellHeight,
                              char: i < text.length ? text[i] : '',
                              active:
                                  widget.enabled &&
                                  _focus.hasFocus &&
                                  i == text.length.clamp(0, widget.length - 1),
                              error: hasError,
                              enabled: widget.enabled,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (hasError) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 15,
                color: AppColors.riskCritical,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: AppTextStyles.fieldHelper.copyWith(
                    color: AppColors.riskCritical,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.width,
    required this.height,
    required this.char,
    required this.active,
    required this.error,
    required this.enabled,
  });

  final double width;
  final double height;
  final String char;
  final bool active;
  final bool error;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color border = error
        ? AppColors.riskCritical
        : active
        ? const Color(0x8CD7BA89)
        : const Color(0x17FFFFFF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: enabled ? const Color(0x4508030B) : const Color(0x2208030B),
        border: Border.all(color: border, width: active ? 1.4 : 1),
        boxShadow: active
            ? const [BoxShadow(color: Color(0x12D7BA89), spreadRadius: 3)]
            : const [],
      ),
      child: Text(
        char,
        style: TextStyle(
          fontFamily: AppTextStyles.display,
          fontSize: (width * 0.5).clamp(18.0, 28.0),
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}
