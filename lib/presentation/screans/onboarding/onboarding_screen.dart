import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Onboarding screen, built from the real Figma layer assets rather
/// than the flattened screen export:
/// - assets/images/onboarding/pattern.png  (decorative background)
/// - assets/images/onboarding/doctor.png   (photo cutout, transparent bg)
/// - assets/images/common/logo_mark.png    (icon mark)
/// The wordmark ("VCare"), headline, subtitle, and button are real
/// Flutter widgets, not baked into any image.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.spaceLg),

            // Logo lockup: icon mark + wordmark, centered.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/common/logo_mark.png', height: 28),
                const SizedBox(width: AppDimensions.spaceSm),
                Text(
                  'VCare',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            // Doctor photo over the decorative pattern.
            Expanded(
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

            // Text + button section
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLg,
                0,
                AppDimensions.spaceLg,
                AppDimensions.spaceMd,
              ),
              child: Column(
                children: [
                  Text(
                    'Best Doctor\nAppointment App',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: AppDimensions.spaceSm),
                  Text(
                    'Manage and schedule all of your medical '
                    'appointments easily with VCare to get a new experience.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, AppRoutes.signIn),
                      child: const Text('Get Started'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
