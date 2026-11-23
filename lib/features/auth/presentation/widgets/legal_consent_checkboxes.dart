import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../l10n/app_strings.dart';

/// Casillas obligatorias de aceptación de Términos y condiciones y
/// Aviso de privacidad en el registro local.
class LegalConsentCheckboxes extends StatefulWidget {
  const LegalConsentCheckboxes({
    super.key,
    required this.acceptedTerms,
    required this.acceptedPrivacy,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    this.enabled = true,
  });

  static const Key termsCheckboxKey = Key('register_terms_checkbox');
  static const Key privacyCheckboxKey = Key('register_privacy_checkbox');

  final bool acceptedTerms;
  final bool acceptedPrivacy;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onPrivacyChanged;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;
  final bool enabled;

  @override
  State<LegalConsentCheckboxes> createState() => _LegalConsentCheckboxesState();
}

class _LegalConsentCheckboxesState extends State<LegalConsentCheckboxes> {
  late final TapGestureRecognizer _termsLabelRecognizer;
  late final TapGestureRecognizer _termsLinkRecognizer;
  late final TapGestureRecognizer _privacyLabelRecognizer;
  late final TapGestureRecognizer _privacyLinkRecognizer;

  @override
  void initState() {
    super.initState();
    _termsLabelRecognizer = TapGestureRecognizer();
    _termsLinkRecognizer = TapGestureRecognizer();
    _privacyLabelRecognizer = TapGestureRecognizer();
    _privacyLinkRecognizer = TapGestureRecognizer();
    _syncRecognizers();
  }

  @override
  void didUpdateWidget(covariant LegalConsentCheckboxes oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncRecognizers();
  }

  void _syncRecognizers() {
    _termsLabelRecognizer.onTap = widget.enabled
        ? () => widget.onTermsChanged(!widget.acceptedTerms)
        : null;
    _termsLinkRecognizer.onTap = widget.onOpenTerms;
    _privacyLabelRecognizer.onTap = widget.enabled
        ? () => widget.onPrivacyChanged(!widget.acceptedPrivacy)
        : null;
    _privacyLinkRecognizer.onTap = widget.onOpenPrivacy;
  }

  @override
  void dispose() {
    _termsLabelRecognizer.dispose();
    _termsLinkRecognizer.dispose();
    _privacyLabelRecognizer.dispose();
    _privacyLinkRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ConsentRow(
          checkboxKey: LegalConsentCheckboxes.termsCheckboxKey,
          value: widget.acceptedTerms,
          enabled: widget.enabled,
          onChanged: widget.onTermsChanged,
          prefix: AppStrings.registerAcceptTermsPrefix,
          linkLabel: AppStrings.authLegalTerms,
          prefixRecognizer: _termsLabelRecognizer,
          linkRecognizer: _termsLinkRecognizer,
        ),
        const SizedBox(height: 4),
        _ConsentRow(
          checkboxKey: LegalConsentCheckboxes.privacyCheckboxKey,
          value: widget.acceptedPrivacy,
          enabled: widget.enabled,
          onChanged: widget.onPrivacyChanged,
          prefix: AppStrings.registerAcceptPrivacyPrefix,
          linkLabel: AppStrings.authLegalPrivacy,
          prefixRecognizer: _privacyLabelRecognizer,
          linkRecognizer: _privacyLinkRecognizer,
        ),
      ],
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.checkboxKey,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.prefix,
    required this.linkLabel,
    required this.prefixRecognizer,
    required this.linkRecognizer,
  });

  final Key checkboxKey;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final String prefix;
  final String linkLabel;
  final TapGestureRecognizer prefixRecognizer;
  final TapGestureRecognizer linkRecognizer;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.caption.copyWith(fontSize: 13, height: 1.4);
    final linkStyle = baseStyle.copyWith(
      color: AppColors.gold,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: const Color(0x66D7BA89),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            key: checkboxKey,
            value: value,
            onChanged: enabled ? (v) => onChanged(v ?? false) : null,
            activeColor: AppColors.gold,
            checkColor: const Color(0xFF26152B),
            side: const BorderSide(color: Color(0x80D7BA89), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: prefix, recognizer: prefixRecognizer),
                  TextSpan(
                    text: linkLabel,
                    style: linkStyle,
                    recognizer: linkRecognizer,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
