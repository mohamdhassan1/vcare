import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/l10n.dart';
import '../../logic/blocs/auth/auth_bloc.dart';
import '../../logic/blocs/auth/auth_event.dart';

/// Asks before logging out, so a stray tap on "Logout" (Profile tab or
/// Settings) cannot end the session by accident. On confirmation the
/// existing [LogoutRequested] flow runs unchanged (token cleared, app-level
/// navigation to Sign In).
Future<void> confirmLogout(BuildContext context) async {
  final l10n = context.l10n;
  final authBloc = context.read<AuthBloc>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.logoutConfirmTitle),
      content: Text(l10n.logoutConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(
              foregroundColor: dialogContext.palette.error),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.logout),
        ),
      ],
    ),
  );
  if (confirmed == true) authBloc.add(const LogoutRequested());
}
