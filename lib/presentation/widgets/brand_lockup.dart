import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n.dart';

/// VCare logo mark + wordmark. Always laid out left-to-right (a brand
/// lockup is not text to mirror), with the mark image untouched.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.size = 28, this.showWordmark = true});

  /// Height of the mark; the wordmark scales with it.
  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final title = context.l10nOrNull?.appTitle ?? 'VCare';
    return Semantics(
      label: title,
      image: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            Image.asset('assets/images/common/logo_mark.png',
                height: size, fit: BoxFit.contain),
            if (showWordmark) ...[
              const SizedBox(width: AppDimensions.spaceSm),
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  fontSize: size * 0.72,
                  fontWeight: FontWeight.w700,
                  color: context.palette.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
