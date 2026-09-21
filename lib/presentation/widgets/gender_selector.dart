import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n.dart';
import 'motion.dart';

/// Male / Female choice as two equal tiles instead of cramped radio
/// rows. Selected = brand border + tint + check badge + bold label (not
/// color alone), animated over 150ms, announced as `selected`. The
/// values are whatever the caller passes ("0"/"1" today) — this widget
/// carries no mapping of its own.
class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.maleValue,
    required this.femaleValue,
    this.enabled = true,
  });

  /// Currently selected value, or null when nothing is chosen yet.
  final String? value;
  final ValueChanged<String> onChanged;
  final String maleValue;
  final String femaleValue;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.gender, style: context.textTheme.bodySmall),
        const SizedBox(height: AppDimensions.spaceSm),
        Row(
          children: [
            Expanded(
              child: _GenderTile(
                icon: Icons.male_rounded,
                label: l10n.male,
                selected: value == maleValue,
                enabled: enabled,
                onTap: () => onChanged(maleValue),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSm),
            Expanded(
              child: _GenderTile(
                icon: Icons.female_rounded,
                label: l10n.female,
                selected: value == femaleValue,
                enabled: enabled,
                onTap: () => onChanged(femaleValue),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderTile extends StatelessWidget {
  const _GenderTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = selected ? palette.primary : palette.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: AnimatedContainer(
              duration: context.motion(AppDurations.fast),
              curve: Curves.easeOut,
              constraints:
                  const BoxConstraints(minHeight: AppDimensions.inputHeight),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceSm + 4,
                  vertical: AppDimensions.spaceSm),
              decoration: BoxDecoration(
                color: selected ? palette.primaryLight : palette.inputFill,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(
                    color: selected ? palette.primary : Colors.transparent,
                    width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(icon, size: AppDimensions.iconMd, color: tone),
                  const SizedBox(width: AppDimensions.spaceSm),
                  Expanded(
                    child: Text(label,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: selected
                                ? palette.textPrimary
                                : palette.textSecondary,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  AnimatedSwitcher(
                    duration: context.motion(AppDurations.fast),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: selected
                        ? Icon(Icons.check_circle_rounded,
                            key: const ValueKey('on'),
                            size: AppDimensions.iconMd,
                            color: palette.primary)
                        : const SizedBox(
                            key: ValueKey('off'),
                            width: AppDimensions.iconMd,
                            height: AppDimensions.iconMd),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
