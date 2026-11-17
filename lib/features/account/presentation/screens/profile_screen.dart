import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/glass_panel.dart';
import '../../../../core/ui/widgets/page_header.dart';
import '../../../../l10n/app_strings.dart';

/// Pantalla de perfil y preferencias (`ProfileScreen` en App.tsx).
///
/// PLANTILLA SIN BACKEND:
/// - Los botones de configuración que dependen de servicios/subpantallas aún no
///   conectados permanecen deshabilitados (`onTap: null`).
/// - `Cerrar sesión` es una acción local en el cliente (AGENTS.md §7) que
///   redirige a [AppRoutes.login].
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onLogout});

  final VoidCallback? onLogout;

  void _handleLogout(BuildContext context) {
    if (onLogout != null) {
      onLogout!();
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
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
                child: const Center(
                  child: Text(
                    AppStrings.homeAvatarInitials,
                    style: TextStyle(
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
                    const Text(
                      AppStrings.profileDemoName,
                      style: TextStyle(
                        fontFamily: AppTextStyles.display,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      AppStrings.profileDemoEmail,
                      style: TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 10,
                        color: Color(0xFF8B7F8F),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
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
                            size: 12,
                            color: AppColors.riskSafe,
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              AppStrings.profileVerifiedBadge,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTextStyles.body,
                                fontSize: 8,
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
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC7588),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          AppStrings.profileVersion,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTextStyles.body,
            fontSize: 8,
            color: Color(0xFF5F5663),
          ),
        ),
      ],
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
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.body,
                        fontSize: 8,
                        color: Color(0xFF766B7A),
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
