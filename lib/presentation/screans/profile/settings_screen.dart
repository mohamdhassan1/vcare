import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import 'faq_screen.dart';
import 'language_screen.dart';
import 'notification_settings_screen.dart';
import 'security_screen.dart';
import 'theme_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        children: [
          _row(
              context,
              Icons.notifications_none_rounded,
              'Notification',
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen()))),
          _row(
              context,
              Icons.help_outline_rounded,
              'FAQ',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FaqScreen()))),
          _row(
              context,
              Icons.security_rounded,
              'Security',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SecurityScreen()))),
          _row(
              context,
              Icons.language_rounded,
              'Language',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LanguageScreen()))),
          _row(
              context,
              Icons.dark_mode_outlined,
              'Theme',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ThemeScreen()))),
          _row(context, Icons.logout_rounded, 'Logout',
              () => context.read<AuthBloc>().add(const LogoutRequested()),
              color: AppColors.error),
        ],
      ),
    );
  }

  Widget _row(
      BuildContext context, IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title:
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
