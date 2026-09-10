import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// UI-only — no medical-records API exists. Static illustrative data.
class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  static const _entries = [
    (
      group: 'This Month',
      title: 'End of observation',
      date: 'Feb 15',
      values: 'White blood cell: 4.30 million/uL · Hemoglobin: 148 g/mL'
    ),
    (
      group: 'This Month',
      title: 'Blood Analysis',
      date: 'Feb 25',
      values: 'Red blood cell: 9.30 million/uL · Hemoglobin: 132 g/mL'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Record')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        itemCount: _entries.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMd),
        itemBuilder: (context, i) {
          final e = _entries[i];
          return Container(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(e.date, style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(e.values, style: AppTextStyles.bodySmall),
              ],
            ),
          );
        },
      ),
    );
  }
}
