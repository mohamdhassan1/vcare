import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/app_card.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/motion.dart';
import '../../widgets/settings_tiles.dart';

/// UI-only placeholder. No backend/Firebase notification system
/// exists — per project decision, real push notifications are
/// intentionally skipped. Static local content only (localized so the
/// demo reads naturally in both languages), flagged as sample content.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final items = [
      (
        icon: Icons.calendar_today_rounded,
        title: l10n.sampleNotifTitle1,
        body: l10n.sampleNotifBody1,
        time: l10n.sampleNotifTime1,
        unread: true
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        title: l10n.sampleNotifTitle2,
        body: l10n.sampleNotifBody2,
        time: l10n.sampleNotifTime2,
        unread: true
      ),
      (
        icon: Icons.favorite_border_rounded,
        title: l10n.sampleNotifTitle3,
        body: l10n.sampleNotifBody3,
        time: l10n.sampleNotifTime3,
        unread: false
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: ContentConstraint(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          itemCount: items.length + 1,
          separatorBuilder: (_, i) =>
              SizedBox(height: i == 0 ? 0 : AppDimensions.spaceSm),
          itemBuilder: (context, i) {
            if (i == 0) return const SampleContentNotice();
            final item = items[i - 1];
            return FadeIn(
              delay: Duration(milliseconds: 40 * (i - 1)),
              child: AppCard(
                color: item.unread ? palette.primaryLight : null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        backgroundColor: palette.primary,
                        radius: 20,
                        child: Icon(item.icon,
                            color: palette.onPrimary,
                            size: AppDimensions.iconMd)),
                    const SizedBox(width: AppDimensions.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: item.unread
                                      ? FontWeight.w700
                                      : FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(item.body, style: context.textTheme.bodySmall),
                          const SizedBox(height: AppDimensions.spaceXs),
                          Text(item.time, style: context.textTheme.labelSmall),
                        ],
                      ),
                    ),
                    if (item.unread)
                      Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                              color: palette.primary, shape: BoxShape.circle)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
