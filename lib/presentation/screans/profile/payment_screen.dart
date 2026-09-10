import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// UI-only — no payment API exists. Static display, non-interactive.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  static const _methods = ['PayPal', 'Master Card', 'Apple Pay', 'Payoneer'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        itemCount: _methods.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceSm),
        itemBuilder: (context, i) => Container(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
          child: Row(
            children: [
              const Icon(Icons.credit_card_rounded, color: AppColors.primary),
              const SizedBox(width: AppDimensions.spaceMd),
              Expanded(
                  child: Text(_methods[i], style: AppTextStyles.bodyMedium)),
              Text('Not connected', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}
