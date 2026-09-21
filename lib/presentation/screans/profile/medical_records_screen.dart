import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/app_card.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/motion.dart';
import '../../widgets/settings_tiles.dart';

/// UI-only — no medical-records API exists. Static illustrative data
/// (localized so the demo reads naturally in both languages), flagged
/// as sample content.
class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final entries = [
      (
        title: l10n.sampleRecordTitle1,
        date: l10n.sampleRecordDate1,
        values: l10n.sampleRecordValues1
      ),
      (
        title: l10n.sampleRecordTitle2,
        date: l10n.sampleRecordDate2,
        values: l10n.sampleRecordValues2
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicalRecords)),
      body: ContentConstraint(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          itemCount: entries.length + 1,
          separatorBuilder: (_, i) =>
              SizedBox(height: i == 0 ? 0 : AppDimensions.spaceMd),
          itemBuilder: (context, i) {
            if (i == 0) return const SampleContentNotice();
            final e = entries[i - 1];
            return FadeIn(
              delay: Duration(milliseconds: 40 * (i - 1)),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: palette.primaryLight, shape: BoxShape.circle),
                      child: Icon(Icons.science_outlined,
                          size: AppDimensions.iconMd, color: palette.primary),
                    ),
                    const SizedBox(width: AppDimensions.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title,
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.w600)),
                          Text(e.date, style: context.textTheme.labelSmall),
                          const SizedBox(height: AppDimensions.spaceXs),
                          Text(e.values, style: context.textTheme.bodySmall),
                        ],
                      ),
                    ),
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
