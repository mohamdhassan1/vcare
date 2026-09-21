import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/app_card.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/motion.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final faqs = [
      (l10n.faqQ1, l10n.faqA1),
      (l10n.faqQ2, l10n.faqA2),
      (l10n.faqQ3, l10n.faqA3),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.faq)),
      body: ContentConstraint(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          itemCount: faqs.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimensions.spaceSm),
          itemBuilder: (context, i) => FadeIn(
            delay: Duration(milliseconds: 40 * i),
            child: _FaqCard(question: faqs[i].$1, answer: faqs[i].$2),
          ),
        ),
      ),
    );
  }
}

/// One question on a card. Keeps [ExpansionTile]'s built-in animated
/// expansion and rotating chevron; the open state is also shown by a
/// bold question and a divider above the answer (not color alone).
class _FaqCard extends StatefulWidget {
  const _FaqCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        // Drop ExpansionTile's own top/bottom borders — the card frames it.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (open) => setState(() => _expanded = open),
          tilePadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMd,
              vertical: AppDimensions.spaceXs),
          childrenPadding: const EdgeInsets.fromLTRB(AppDimensions.spaceMd, 0,
              AppDimensions.spaceMd, AppDimensions.spaceMd),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Icon(Icons.help_outline_rounded,
              color: _expanded ? palette.primary : palette.textSecondary),
          title: AnimatedDefaultTextStyle(
            duration: context.motion(AppDurations.fast),
            style: AppTextStyles.bodyMedium.copyWith(
                color: palette.textPrimary,
                fontWeight: _expanded ? FontWeight.w700 : FontWeight.w500),
            child: Text(widget.question),
          ),
          children: [
            Divider(height: 1, color: palette.divider),
            const SizedBox(height: AppDimensions.spaceSm + 4),
            Text(widget.answer, style: context.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
