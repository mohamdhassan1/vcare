import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/brand_lockup.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/motion.dart';
import '../../widgets/primary_button.dart';

/// Onboarding screen, built from the real Figma layer assets rather
/// than the flattened screen export:
/// - assets/images/onboarding/pattern.png  (decorative background)
/// - assets/images/onboarding/doctor.png   (photo cutout, transparent bg)
/// - assets/images/common/logo_mark.png    (icon mark)
/// The wordmark ("VCare"), headline, subtitle, and button are real
/// Flutter widgets, not baked into any image. One page; the only
/// action is Get Started → Sign In (unchanged).
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: ContentConstraint(
          maxWidth: 520,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Illustration takes what is left, but never balloons on
              // tall/wide screens or squeezes the text on short ones.
              final illustrationHeight =
                  (constraints.maxHeight * 0.48).clamp(160.0, 420.0);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spaceLg,
                    AppDimensions.spaceLg,
                    AppDimensions.spaceLg,
                    AppDimensions.spaceMd),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: constraints.maxHeight -
                          AppDimensions.spaceLg -
                          AppDimensions.spaceMd),
                  child: Column(
                    // Free height (tall screens) opens up between the
                    // illustration and the text; a Spacer cannot be used
                    // inside a scroll view.
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const FadeIn(offset: 0, child: BrandLockup(size: 28)),
                      const SizedBox(height: AppDimensions.spaceMd),

                      // Doctor photo over the decorative pattern.
                      FadeIn(
                        delay: const Duration(milliseconds: 40),
                        child: SizedBox(
                          height: illustrationHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Image.asset(
                                  'assets/images/onboarding/pattern.png',
                                  width: 260,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Image.asset(
                                'assets/images/onboarding/doctor.png',
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceLg),

                      // Text + button section
                      FadeIn(
                        delay: const Duration(milliseconds: 100),
                        child: Column(
                          children: [
                            Text(
                              l10n.onboardingHeadline,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.h1
                                  .copyWith(color: palette.primary),
                            ),
                            const SizedBox(height: AppDimensions.spaceSm),
                            Text(
                              l10n.onboardingSubtitle,
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium
                                  ?.copyWith(color: palette.textSecondary),
                            ),
                            const SizedBox(height: AppDimensions.spaceLg),
                            PrimaryButton(
                              label: l10n.getStarted,
                              onPressed: () => Navigator.pushReplacementNamed(
                                  context, AppRoutes.signIn),
                            ),
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
      ),
    );
  }
}
