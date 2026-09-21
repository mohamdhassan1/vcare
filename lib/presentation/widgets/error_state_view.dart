import 'package:flutter/material.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n.dart';
import 'motion.dart';

/// Consistent full-area error presentation with a Retry action, reused
/// by every list/detail screen. The message is localized from the
/// error's code; a backend-provided message is shown as-is (never
/// translated). Visually distinct from an empty state (error-tinted
/// icon) so a failure is never mistaken for "nothing here".
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.error,
    required this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final AppErrorInfo error;
  final VoidCallback onRetry;
  final IconData icon;

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
                    color: palette.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: Icon(icon,
                    size: AppDimensions.iconXl - 12, color: palette.error),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              Text(context.errorText(error),
                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppDimensions.spaceMd),
              // Compact (not full-width) so the action reads as "try
              // again", not as the page's primary CTA.
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, AppDimensions.minTouchTarget)),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded,
                    size: AppDimensions.iconMd),
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single-line variant for a section that failed inside an otherwise
/// working page (Home's partial failures): icon, message, Retry.
class InlineErrorRow extends StatelessWidget {
  const InlineErrorRow({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(AppDimensions.spaceMd,
          AppDimensions.spaceSm, AppDimensions.spaceXs, AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: palette.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              size: AppDimensions.iconMd, color: palette.error),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Text(message,
                style: context.textTheme.bodySmall!
                    .copyWith(color: palette.error)),
          ),
          TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
        ],
      ),
    );
  }
}
