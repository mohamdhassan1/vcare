import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n.dart';
import 'chat_screen.dart';

/// UI-only, per project rule: no messaging API exists. Local sample
/// conversations only — never presented as real/synced data.
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  static const _conversations = [
    (
      name: 'Dr. Randy Wigham',
      preview:
          'Fine, I do a check. Does the patient have a history of certain diseases?',
      time: '11:11',
      unread: true
    ),
    (
      name: 'Dr. Jack Sulivan',
      preview:
          'Fine, I do a check. Does the patient have a history of certain diseases?',
      time: '11:11',
      unread: false
    ),
    (
      name: 'Drg. Hanna Stanton',
      preview:
          'Fine, I do a check. Does the patient have a history of certain diseases?',
      time: '11:11',
      unread: true
    ),
    (
      name: 'Dr. Emery Lubin',
      preview:
          'Fine, I do a check. Does the patient have a history of certain diseases?',
      time: '11:11',
      unread: false
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.messages)),
      body: _conversations.isEmpty
          ? Center(
              child: Text(context.l10n.noMessagesYet,
                  style: AppTextStyles.bodyMedium))
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              itemCount: _conversations.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.spaceSm),
              itemBuilder: (context, i) {
                final c = _conversations[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatScreen(doctorName: c.name))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spaceSm),
                    child: Row(
                      children: [
                        CircleAvatar(
                            radius: 26,
                            backgroundColor: context.palette.surface,
                            child: Icon(Icons.person,
                                color: context.palette.textHint)),
                        const SizedBox(width: AppDimensions.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: AppTextStyles.bodyLarge
                                      .copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(c.preview,
                                  style: context.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(c.time, style: context.textTheme.labelSmall),
                            if (c.unread)
                              Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: context.palette.primary,
                                      shape: BoxShape.circle)),
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
