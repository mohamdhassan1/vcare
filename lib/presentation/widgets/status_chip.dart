import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_text_styles.dart';

/// Small tinted pill for a status or a short value (appointment status,
/// price). The tint is derived from [color] so it works on any surface
/// in both themes; text uses the same color at full strength.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
  });

  final String label;

  /// Defaults to the brand color.
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? context.palette.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceSm + 2,
          vertical: AppDimensions.spaceXs),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppDimensions.iconSm, color: tone),
            const SizedBox(width: AppDimensions.spaceXs),
          ],
          // Flexible so the pill can shrink (ellipsis) in tight rows.
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: tone, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
