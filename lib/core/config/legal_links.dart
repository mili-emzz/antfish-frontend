import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enlaces centralizados de documentos legales de AntFish.
///
/// Las URLs pueden sobreescribirse mediante `--dart-define-from-file=.env`
/// (`TERMS_URL` y `PRIVACY_URL`).
abstract final class LegalLinks {
  static const String termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://www.antfish.xyz/terminos',
  );

  static const String privacyUrl = String.fromEnvironment(
    'PRIVACY_URL',
    defaultValue: 'https://www.antfish.xyz/privacidad',
  );

  @visibleForTesting
  static Future<bool> Function(Uri url)? urlLauncherOverride;

  /// Abre la página oficial de Términos y condiciones en el navegador del dispositivo.
  static Future<bool> openTerms([BuildContext? context]) {
    return launch(termsUrl);
  }

  /// Abre la página oficial del Aviso de privacidad en el navegador del dispositivo.
  static Future<bool> openPrivacy([BuildContext? context]) {
    return launch(privacyUrl);
  }

  /// Abre la URL especificada en el navegador externo del dispositivo.
  static Future<bool> launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    if (urlLauncherOverride != null) {
      return urlLauncherOverride!(uri);
    }

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
