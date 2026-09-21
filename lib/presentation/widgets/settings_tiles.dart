import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n.dart';
import 'app_card.dart';
import 'motion.dart';

/// A card holding a stack of [SettingsRow]s separated by hairlines —
/// the "section" unit of Profile and Settings. Optional [title] above.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children, this.title});

  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsetsDirectional.only(
                start: AppDimensions.spaceXs, bottom: AppDimensions.spaceSm),
            child: Text(title!,
                style: context.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                      height: 1,
                      indent: AppDimensions.spaceMd,
                      endIndent: AppDimensions.spaceMd,
                      color: palette.divider),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Navigation row: tinted icon disc, label, optional subtitle and a
/// chevron that points into the reading direction. ≥48px tall, exposed
/// to screen readers as a button.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  /// Replaces the chevron (e.g. a value badge).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: subtitle == null ? label : '$label, $subtitle',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                minHeight: AppDimensions.minTouchTarget + 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceMd,
                  vertical: AppDimensions.spaceSm),
              child: Row(
                children: [
                  _IconDisc(icon: icon, color: palette.primary),
                  const SizedBox(width: AppDimensions.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label,
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        if (subtitle != null)
                          Text(subtitle!,
                              style: context.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSm),
                  trailing ??
                      Icon(
                        // "Go forward" points into the reading direction.
                        context.isRtl
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        color: palette.textHint,
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

/// Destructive action (Logout): error tint, error icon/text, **no**
/// chevron — it acts, it does not navigate. Same height as a row.
class DestructiveTile extends StatelessWidget {
  const DestructiveTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: palette.error.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            side: BorderSide(color: palette.error.withValues(alpha: 0.25)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  minHeight: AppDimensions.minTouchTarget + 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMd,
                    vertical: AppDimensions.spaceSm),
                child: Row(
                  children: [
                    _IconDisc(icon: icon, color: palette.error),
                    const SizedBox(width: AppDimensions.spaceMd),
                    Expanded(
                      child: Text(label,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: palette.error,
                              fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One choice in a settings picker (theme mode, language). Selected =
/// brand border + filled check badge + bold title (never color alone),
/// animated over 150ms, announced as `selected`.
class SettingsRadioTile extends StatelessWidget {
  const SettingsRadioTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.icon,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10nOrNull;
    return Semantics(
      button: true,
      selected: selected,
      label: subtitle == null ? title : '$title, $subtitle',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              child: AnimatedContainer(
                duration: context.motion(AppDurations.fast),
                curve: Curves.easeOut,
                constraints: const BoxConstraints(
                    minHeight: AppDimensions.minTouchTarget + 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMd,
                    vertical: AppDimensions.spaceSm + 2),
                decoration: BoxDecoration(
                  color: selected ? palette.primaryLight : palette.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                      color: selected ? palette.primary : palette.cardBorder,
                      width: selected ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      _IconDisc(
                          icon: icon!,
                          color: selected
                              ? palette.primary
                              : palette.textSecondary,
                          filled: !selected),
                      const SizedBox(width: AppDimensions.spaceMd),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          if (subtitle != null)
                            Text(subtitle!,
                                style: context.textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceSm),
                    AnimatedSwitcher(
                      duration: context.motion(AppDurations.fast),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: selected
                          ? Container(
                              key: const ValueKey('on'),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                  color: palette.primary,
                                  shape: BoxShape.circle),
                              child: Icon(Icons.check_rounded,
                                  size: AppDimensions.iconSm,
                                  color: palette.onPrimary,
                                  semanticLabel: l10n?.done),
                            )
                          : Container(
                              key: const ValueKey('off'),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: palette.border)),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small localized notice for screens whose content is illustrative
/// (nothing behind it yet), so demo data is never mistaken for real.
class SampleContentNotice extends StatelessWidget {
  const SampleContentNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd, vertical: AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: palette.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: AppDimensions.iconMd, color: palette.warning),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Text(context.l10n.sampleContentNotice,
                style: context.textTheme.bodySmall
                    ?.copyWith(color: palette.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _IconDisc extends StatelessWidget {
  const _IconDisc(
      {required this.icon, required this.color, this.filled = true});

  final IconData icon;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: AppDimensions.iconMd, color: color),
    );
  }
}
