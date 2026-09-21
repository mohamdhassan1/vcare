import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/settings_tiles.dart';

/// Theme picker. Selecting an option applies and persists it at once
/// through the existing [ThemeController] (unchanged).
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final l10n = context.l10n;
    Widget option(ThemeMode mode, IconData icon, String title,
            {String? subtitle}) =>
        SettingsRadioTile(
          icon: icon,
          title: title,
          subtitle: subtitle,
          selected: controller.value == mode,
          onTap: () => controller.setThemeMode(mode),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.theme)),
      body: ContentConstraint(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          children: [
            option(ThemeMode.light, Icons.light_mode_outlined, l10n.light),
            option(ThemeMode.dark, Icons.dark_mode_outlined, l10n.dark),
            option(ThemeMode.system, Icons.brightness_auto_outlined,
                l10n.systemDefault,
                subtitle: l10n.systemDefaultHint),
          ],
        ),
      ),
    );
  }
}
