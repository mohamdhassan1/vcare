import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';

/// One way to show transient feedback. Colors/shape come from the
/// theme's snackBarTheme; this only adds the icon and replaces any bar
/// still on screen so messages never queue up behind each other.
class AppSnackBar {
  AppSnackBar._();

  /// Neutral / success feedback ("Profile updated.").
  static void show(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    IconData? icon,
  }) =>
      _show(context, message, action: action, icon: icon);

  /// Failure feedback: same bar, with an error-tinted icon so it is
  /// recognisable at a glance without relying on color alone.
  static void error(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) =>
      _show(context, message,
          action: action,
          icon: Icons.error_outline_rounded,
          iconColor: context.palette.error);

  static void _show(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    IconData? icon,
    Color? iconColor,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final textColor = Theme.of(context).snackBarTheme.contentTextStyle?.color;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          action: action,
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: AppDimensions.iconMd, color: iconColor ?? textColor),
                const SizedBox(width: AppDimensions.spaceSm),
              ],
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
