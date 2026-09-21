import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/logout_confirm_dialog.dart';
import '../../widgets/motion.dart';
import '../../widgets/settings_tiles.dart';
import 'faq_screen.dart';
import 'language_screen.dart';
import 'notification_settings_screen.dart';
import 'security_screen.dart';
import 'theme_screen.dart';

/// Settings hub: preferences (with their current value as a subtitle),
/// support pages, and — visually apart — logout.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Each language is named in its own script on purpose (see
  /// LanguageScreen); these are proper nouns, not translated strings.
  static String languageName(String code) =>
      code == 'ar' ? 'العربية' : 'English';

  static String themeModeName(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.systemDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.watch<LocaleController>().value;
    final themeMode = context.watch<ThemeController>().value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ContentConstraint(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          children: [
            FadeIn(
              child: SettingsGroup(
                title: l10n.preferencesSection,
                children: [
                  SettingsRow(
                      icon: Icons.language_rounded,
                      label: l10n.language,
                      subtitle: languageName(locale.languageCode),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LanguageScreen()))),
                  SettingsRow(
                      icon: Icons.dark_mode_outlined,
                      label: l10n.theme,
                      subtitle: themeModeName(l10n, themeMode),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ThemeScreen()))),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            FadeIn(
              delay: const Duration(milliseconds: 40),
              child: SettingsGroup(
                title: l10n.supportSection,
                children: [
                  SettingsRow(
                      icon: Icons.notifications_none_rounded,
                      label: l10n.notifications,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const NotificationSettingsScreen()))),
                  SettingsRow(
                      icon: Icons.help_outline_rounded,
                      label: l10n.faq,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FaqScreen()))),
                  SettingsRow(
                      icon: Icons.security_rounded,
                      label: l10n.security,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SecurityScreen()))),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLg),
            FadeIn(
              delay: const Duration(milliseconds: 80),
              child: DestructiveTile(
                icon: Icons.logout_rounded,
                label: l10n.logout,
                onTap: () => confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
