import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';

/// The one card surface used across VCare: theme surface color, large
/// radius, the palette's (dark-mode-only) hairline, and — when [onTap]
/// is given — a ripple that is clipped to the rounded shape instead of
/// bleeding into the margin.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(AppDimensions.spaceMd),
    this.margin = EdgeInsets.zero,
    this.radius = AppDimensions.radiusLg,
    this.color,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;

  /// Overrides the surface color (e.g. a tinted "unread" card).
  final Color? color;

  /// Accessible name for a tappable card, e.g. the doctor's name.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: palette.cardBorder),
    );
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null || onLongPress != null) {
      content = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: shape,
        child: content,
      );
    }
    Widget card = Material(
      color: color ?? palette.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: content,
    );
    if (semanticLabel != null) {
      card =
          Semantics(button: onTap != null, label: semanticLabel, child: card);
    }
    if (margin != EdgeInsets.zero) {
      card = Padding(padding: margin, child: card);
    }
    return card;
  }
}
