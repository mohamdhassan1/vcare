import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/presentation/widgets/app_text_field.dart';
import 'package:vcare/presentation/widgets/primary_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/l10n.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/brand_lockup.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/motion.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Single submit path for the button AND the keyboard's Done/Enter
  /// (see the password field). Ignored while a sign-in is already in
  /// flight so Enter can't queue a second request.
  void _submit() {
    if (context.read<AuthBloc>().state is AuthLoading) return;
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
          SignInRequested(email: _email.text.trim(), password: _password.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (route) => false);
            } else if (state is AuthFailure) {
              // A 401 here means wrong credentials, not an expired session.
              AppSnackBar.error(context,
                  context.errorText(state.error, invalidCredentials: true));
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            // Scrollable so the fields and the Login button stay
            // reachable when the keyboard is open on small screens or
            // with large text scaling (was a fixed-height Column).
            return ContentConstraint(
              maxWidth: 480,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppDimensions.spaceMd),
                        const FadeIn(offset: 0, child: BrandLockup(size: 32)),
                        const SizedBox(height: AppDimensions.spaceXl),
                        FadeIn(
                          delay: const Duration(milliseconds: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                header: true,
                                child: Text(l10n.welcomeBack,
                                    style: AppTextStyles.h1),
                              ),
                              const SizedBox(height: AppDimensions.spaceXs),
                              Text(l10n.signInSubtitle,
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(color: palette.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spaceLg),
                        FadeIn(
                          delay: const Duration(milliseconds: 80),
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
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                              const SizedBox(height: AppDimensions.spaceMd),
                              AppTextField(
                                  controller: _password,
                                  label: l10n.password,
                                  hint: l10n.password,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  validator: Validators.password(l10n),
                                  obscureText: true,
                                  autofillHints: const [AutofillHints.password],
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submit()),
                              Align(
                                // Directional: trailing edge in both LTR and RTL.
                                alignment: AlignmentDirectional.centerEnd,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      minimumSize: const Size(
                                          0, AppDimensions.minTouchTarget)),
                                  onPressed: () => Navigator.pushNamed(
                                      context, AppRoutes.forgotPassword),
                                  child: Text(l10n.forgotPasswordQuestion),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spaceSm),
                              PrimaryButton(
                                  label: l10n.login,
                                  isLoading: isLoading,
                                  onPressed: _submit),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spaceMd),
                        Center(
                          child: TextButton(
                            style: TextButton.styleFrom(
                                minimumSize: const Size(
                                    0, AppDimensions.minTouchTarget)),
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pushReplacementNamed(
                                    context, AppRoutes.signUp),
                            child: Text(l10n.noAccountSignUp,
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
