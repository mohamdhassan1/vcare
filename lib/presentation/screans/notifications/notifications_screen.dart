import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// UI-only placeholder. No backend/Firebase notification system
/// exists — per project decision, real push notifications are
/// intentionally skipped. Static local content only.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _items = [
    (icon: Icons.calendar_today_rounded, title: 'Appointment Reminder', body: 'Your appointment is coming up soon.', time: '2h ago', unread: true),
    (icon: Icons.check_circle_outline_rounded, title: 'Booking Confirmed', body: 'Your appointment request was received.', time: '1d ago', unread: true),
    (icon: Icons.favorite_border_rounded, title: 'Favorites', body: 'Doctors you saved are available for booking.', time: '3d ago', unread: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.spaceSm),
        itemBuilder: (context, i) {
          final item = _items[i];
          return Container(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            decoration: BoxDecoration(
              color: item.unread ? AppColors.primaryLight : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: AppColors.primary, radius: 20, child: Icon(item.icon, color: Colors.white, size: 20)),
                const SizedBox(width: AppDimensions.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(item.body, style: AppTextStyles.bodySmall),
                      const SizedBox(height: 4),
                      Text(item.time, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                if (item.unread) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              ],
            ),
          );
        },
      ),
    );
  }
}