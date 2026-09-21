import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/l10n.dart';
import 'motion.dart';

/// Standard primary action button with a built-in loading state,
/// used across auth (and later) forms. The spinner takes the theme's
/// on-primary color (not a hardcoded white) and swaps in with a short
/// cross-fade; while loading the button is disabled and announced as
/// "Loading".
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: AnimatedSwitcher(
        duration: context.motion(AppDurations.fast),
        child: isLoading
            ? SizedBox(
                key: const ValueKey('loading'),
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: context.palette.onPrimary,
                  semanticsLabel: context.l10nOrNull?.loading ?? 'Loading',
                ),
              )
            : Text(label, key: const ValueKey('label')),
      ),
    );
  }
}
