import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/app_card.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/motion.dart';
import '../../widgets/status_chip.dart';

/// UI-only — no payment API exists. Static display, non-interactive;
/// every row says "Not connected" so nothing here reads as a real
/// payment method.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  // Provider brand names are proper nouns — intentionally not localized.
  static const _methods = ['PayPal', 'Master Card', 'Apple Pay', 'Payoneer'];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.payment)),
      body: ContentConstraint(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          itemCount: _methods.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimensions.spaceSm),
          itemBuilder: (context, i) => FadeIn(
            delay: Duration(milliseconds: 40 * i),
            child: AppCard(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: palette.primaryLight, shape: BoxShape.circle),
                    child: Icon(Icons.credit_card_rounded,
                        size: AppDimensions.iconMd, color: palette.primary),
                  ),
                  const SizedBox(width: AppDimensions.spaceMd),
                  Expanded(
                      child: Text(_methods[i],
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w500))),
                  const SizedBox(width: AppDimensions.spaceSm),
                  Flexible(
                    child: StatusChip(
                        label: l10n.notConnected,
                        icon: Icons.link_off_rounded,
                        color: palette.textSecondary),
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
