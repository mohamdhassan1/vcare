import 'package:flutter/material.dart';
import 'package:vcare/presentation/widgets/app_text_field.dart';
import 'package:vcare/presentation/widgets/primary_button.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/motion.dart';

/// UI-only screen, per project rule: there is no /auth/forgot-password
/// endpoint in the API, so this does not perform any real request.
/// The screen says so up front, and submitting repeats the honest
/// message rather than pretending to send a reset email.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      AppSnackBar.show(context, context.l10n.passwordResetUnavailable,
          icon: Icons.info_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.forgotPassword)),
      // Scrollable so the button stays reachable with the keyboard open.
      body: ContentConstraint(
        maxWidth: 480,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeIn(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                            color: palette.primaryLight,
                            shape: BoxShape.circle),
                        child: Icon(Icons.lock_reset_rounded,
                            size: AppDimensions.iconXl - 12,
                            color: palette.primary),
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      Text(l10n.forgotPasswordInstructions,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLg),
                FadeIn(
                  delay: const Duration(milliseconds: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                          controller: _email,
                          label: l10n.email,
                          hint: l10n.email,
                          prefixIcon: Icons.mail_outline_rounded,
                          validator: Validators.email(l10n),
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit()),
                      const SizedBox(height: AppDimensions.spaceMd),
                      // Honest, up front: nothing is sent anywhere yet.
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceMd,
                            vertical: AppDimensions.spaceSm),
                        decoration: BoxDecoration(
                          color: palette.warning.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: AppDimensions.iconMd,
                                color: palette.warning),
                            const SizedBox(width: AppDimensions.spaceSm),
                            Expanded(
                              child: Text(l10n.passwordResetUnavailable,
                                  style: context.textTheme.bodySmall
                                      ?.copyWith(color: palette.textPrimary)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceLg),
                      PrimaryButton(
                          label: l10n.resetPassword, onPressed: _submit),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
