import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/settings_tiles.dart';

/// Language picker. Selecting a language applies and persists it
/// immediately (the whole app re-renders in place) — the same
/// interaction as the Theme screen, so the two settings feel alike.
///
/// Each language is listed in its own script ("English" / "العربية")
/// on purpose: a user who can't read the current language must still
/// be able to find their own.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocaleController>();
    final selected = controller.value.languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.language)),
      body: ContentConstraint(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          children: [
            SettingsRadioTile(
              icon: Icons.language_rounded,
              title: 'English',
              selected: selected == 'en',
              onTap: () => controller.setLocale(const Locale('en')),
            ),
            SettingsRadioTile(
              icon: Icons.translate_rounded,
              title: 'العربية',
              selected: selected == 'ar',
              onTap: () => controller.setLocale(const Locale('ar')),
            ),
          ],
        ),
      ),
    );
  }
}
