import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import 'chat_screen.dart';

/// UI-only, per project rule: no messaging API exists. Local sample
/// conversations only — never presented as real/synced data.
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  static const _conversations = [
    (name: 'Dr. Randy Wigham', preview: 'Fine, I do a check. Does the patient have a history of certain diseases?', time: '11:11', unread: true),
    (name: 'Dr. Jack Sulivan', preview: 'Fine, I do a check. Does the patient have a history of certain diseases?', time: '11:11', unread: false),
    (name: 'Drg. Hanna Stanton', preview: 'Fine, I do a check. Does the patient have a history of certain diseases?', time: '11:11', unread: true),
    (name: 'Dr. Emery Lubin', preview: 'Fine, I do a check. Does the patient have a history of certain diseases?', time: '11:11', unread: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message')),
      body: _conversations.isEmpty
          ? Center(child: Text('No messages yet.', style: AppTextStyles.bodyMedium))
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              itemCount: _conversations.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.spaceSm),
              itemBuilder: (context, i) {
                final c = _conversations[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(doctorName: c.name))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceSm),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 26, backgroundColor: AppColors.surface, child: Icon(Icons.person, color: AppColors.textHint)),
                        const SizedBox(width: AppDimensions.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(c.preview, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(c.time, style: AppTextStyles.caption),
                            if (c.unread) Container(margin: const EdgeInsets.only(top: 6), width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}