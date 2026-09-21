import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/motion.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _precached = false;

  @override
  void initState() {
    super.initState();

    _startSplash();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    // Decode the brand mark now (and warm the onboarding art) so the
    // first web paint shows the logo with the wordmark instead of a
    // beat later. Failures are ignored: the images simply load lazily.
    for (final asset in const [
      'assets/images/common/logo_mark.png',
      'assets/images/onboarding/doctor.png',
      'assets/images/onboarding/pattern.png',
    ]) {
      precacheImage(AssetImage(asset), context).catchError((_) {});
    }
  }

  Future<void> _startSplash() async {
    // Keep splash visible for 2 seconds.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final isLoggedIn = await context.read<AuthRepository>().isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      isLoggedIn ? AppRoutes.home : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final title = context.l10nOrNull?.appTitle ?? 'VCare';
    final lockup = Semantics(
      label: title,
      image: true,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/common/logo_mark.png',
              width: 96,
              height: 96,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            Text(
              title,
              style: AppTextStyles.h1.copyWith(
                color: palette.primary,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
    // Theme background (light or dark) comes from the Scaffold. The
    // lockup settles in with a short fade/scale; instant under reduced
    // motion. The 2s hold above is unchanged.
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: context.reduceMotion
              ? lockup
              : TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: AppDurations.slow,
                  curve: Curves.easeOutCubic,
                  child: lockup,
                  builder: (context, t, child) => Opacity(
                    opacity: t,
                    child:
                        Transform.scale(scale: 0.92 + 0.08 * t, child: child),
                  ),
                ),
        ),
      ),
    );
  }
}
