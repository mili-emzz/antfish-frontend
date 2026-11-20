import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/session/session_scope.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_alert.dart';
import '../../../../core/ui/widgets/app_buttons.dart';
import '../../../../core/ui/widgets/crystal_text_field.dart';
import '../../../../core/ui/widgets/glass_panel.dart';
import '../../../../core/ui/widgets/page_header.dart';
import '../../../../l10n/app_strings.dart';
import '../../../auth/auth.dart';

/// Pantalla de perfil y preferencias (`ProfileScreen` en App.tsx).
///
/// - `Cerrar sesión` limpia tokens locales (AGENTS.md §7) y redirige a Login.
/// - `Eliminar cuenta` ejecuta baja definitiva con reautenticación obligatoria
///   (`DELETE /api/v1/auth/me`) cuando existe repositorio en [AuthScope].
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onLogout});

  final VoidCallback? onLogout;

  Future<void> _handleLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    await SessionScope.maybeOf(context)?.signOut();
    if (onLogout != null) {
      onLogout!();
      return;
    }
    navigator.pushReplacementNamed(AppRoutes.login);
  }

  Future<void> _openDeleteAccountDialog(
    BuildContext context, {
    required String authProvider,
  }) async {
    final deletedMessage = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteAccountDialog(authProvider: authProvider),
    );
    if (deletedMessage == null || !context.mounted) return;
    showAppSnackBar(context, deletedMessage);
    if (onLogout != null) {
      onLogout!();
      return;
    }
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  static String _initialsFor(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return AppStrings.homeAvatarInitials;
    if (parts.length == 1) {
      final first = parts.first;
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasBackend = AuthScope.maybeOf(context)?.repository != null;
    final sessionState = SessionScope.maybeOf(context)?.state;
    final authState = sessionState is SessionAuthenticated
        ? sessionState
        : null;
    final authProvider = authState?.authProvider ?? 'local';
    final displayName = (authState?.userName?.trim().isNotEmpty ?? false)
        ? authState!.userName!.trim()
        : AppStrings.profileDemoName;
    final displayEmail = (authState?.userEmail?.trim().isNotEmpty ?? false)
        ? authState!.userEmail!.trim()
        : AppStrings.profileDemoEmail;
    final initials = (authState?.userName?.trim().isNotEmpty ?? false)
        ? _initialsFor(displayName)
        : AppStrings.homeAvatarInitials;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const PageHeader(
          eyebrow: AppStrings.profileEyebrow,
          title: AppStrings.profileTitle,
        ),
        // .profile-card
        GlassPanel(
          borderRadius: 21,
          padding: const EdgeInsets.all(25),
          elevated: true,
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x40D7BA89)),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x29D7BA89), Color(0x1FB47EB3)],
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.display,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.display,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      displayEmail,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x146AD6A2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppColors.riskSafe,
                          ),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              AppStrings.profileVerifiedBadge,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTextStyles.body,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.riskSafe,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        // .settings-list (deshabilitados mientras no haya backend)
        const GlassPanel(
          borderRadius: 21,
          padding: EdgeInsets.zero,
          elevated: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SettingsRow(
                icon: Icons.verified_user_outlined,
                title: AppStrings.profileSecurityTitle,
                subtitle: AppStrings.profileSecuritySubtitle,
                showDivider: true,
              ),
              _SettingsRow(
                icon: Icons.fingerprint_rounded,
                title: AppStrings.profilePrivacyTitle,
                subtitle: AppStrings.profilePrivacySubtitle,
                showDivider: true,
              ),
              _SettingsRow(
                icon: Icons.auto_awesome_outlined,
                title: AppStrings.profilePreferencesTitle,
                subtitle: AppStrings.profilePreferencesSubtitle,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        // .logout-button (acción local en el cliente: AGENTS.md §7)
        Semantics(
          button: true,
          label: AppStrings.profileLogout,
          child: Material(
            color: const Color(0x0DD96179),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0x33D96179)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _handleLogout(context),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      AppStrings.profileLogout,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEE879A),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Acción destructiva: baja definitiva (DELETE /api/v1/auth/me)
        Center(
          child: LinkButton(
            label: AppStrings.profileDeleteAccount,
            onPressed: hasBackend
                ? () => _openDeleteAccountDialog(
                    context,
                    authProvider: authProvider,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          AppStrings.profileVersion,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTextStyles.body,
            fontSize: 12,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.authProvider});

  final String authProvider;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isGoogle => widget.authProvider == 'google';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    if (!_isGoogle && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = _isGoogle
        ? await runDeleteAccountWithGoogle(context)
        : await runDeleteAccountWithPassword(
            context,
            password: _passwordController.text,
          );
    if (!mounted) return;

    switch (result) {
      case AuthMessageSuccess(:final message):
        Navigator.of(context).pop(message);
        return;
      case AuthCancelled():
        setState(() => _isSubmitting = false);
      case AuthError(:final message):
        setState(() {
          _isSubmitting = false;
          _errorMessage = message;
        });
      default:
        setState(() {
          _isSubmitting = false;
          _errorMessage = AppStrings.templateBackendPending;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlassPanel(
          borderRadius: 22,
          padding: const EdgeInsets.all(24),
          elevated: true,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    AppStrings.deleteAccountDialogTitle,
                    style: TextStyle(
                      fontFamily: AppTextStyles.display,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    AppStrings.deleteAccountDialogCopy,
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null) ...[
                    AppAlert(
                      message: _errorMessage!,
                      variant: AlertVariant.error,
                      onDismiss: () => setState(() => _errorMessage = null),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_isGoogle)
                    const Text(
                      AppStrings.deleteAccountGoogleHint,
                      style: AppTextStyles.fieldHelper,
                    )
                  else
                    CrystalTextField(
                      label: AppStrings.deleteAccountPasswordLabel,
                      hint: AppStrings.deleteAccountPasswordHint,
                      icon: Icons.lock_outline_rounded,
                      controller: _passwordController,
                      enabled: !_isSubmitting,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.validationPasswordRequired;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _confirm(),
                    ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: _isGoogle
                        ? AppStrings.deleteAccountConfirmGoogle
                        : AppStrings.deleteAccountConfirm,
                    icon: Icons.delete_forever_outlined,
                    isLoading: _isSubmitting,
                    onPressed: _confirm,
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: AppStrings.deleteAccountCancel,
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.showDivider,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: false,
      label: '$title. $subtitle',
      child: Opacity(
        opacity: 0.65,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(bottom: BorderSide(color: Color(0x0FFFFFFF)))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x14D7BA89),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: AppColors.gold),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF605665),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
