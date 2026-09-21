import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_text_styles.dart';
import 'motion.dart';

/// Consistent empty-state presentation, reused across list screens.
/// Optionally offers one next step ([actionLabel] + [onAction]) so an
/// empty list is never a dead end. Fades in so it settles instead of
/// popping after a load.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: FadeIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                    color: palette.primaryLight, shape: BoxShape.circle),
                child: Icon(icon,
                    size: AppDimensions.iconXl - 12, color: palette.primary),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              Text(message,
                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              if (actionLabel != null) ...[
                const SizedBox(height: AppDimensions.spaceMd),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, AppDimensions.minTouchTarget)),
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
