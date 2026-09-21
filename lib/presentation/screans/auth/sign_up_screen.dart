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
import '../../widgets/gender_selector.dart';
import '../../widgets/motion.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  // API gender mapping is unconfirmed by the Postman collection.
  // Assuming "0" = Male, "1" = Female until verified against the backend.
  String _gender = '0';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  /// Shared by the button and the keyboard's Done on the last field;
  /// ignored while a request is in flight (no duplicate submissions).
  void _submit() {
    if (context.read<AuthBloc>().state is AuthLoading) return;
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SignUpRequested(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            gender: _gender,
            password: _password.text,
            passwordConfirmation: _confirmPassword.text,
          ));
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
              AppSnackBar.error(context, context.errorText(state.error));
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
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
                                child: Text(l10n.createAccount,
                                    style: AppTextStyles.h1),
                              ),
                              const SizedBox(height: AppDimensions.spaceXs),
                              Text(l10n.signUpSubtitle,
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(color: palette.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spaceLg),

                        // Who you are.
                        FadeIn(
                          delay: const Duration(milliseconds: 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                  controller: _name,
                                  label: l10n.fullName,
                                  hint: l10n.fullName,
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: Validators.name(l10n),
                                  autofillHints: const [AutofillHints.name],
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: AppDimensions.spaceMd),
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
                              ),
                              const SizedBox(height: AppDimensions.spaceMd),
                              AppTextField(
                                  controller: _phone,
                                  label: l10n.phoneNumber,
                                  hint: l10n.phoneNumber,
                                  prefixIcon: Icons.phone_outlined,
                                  validator: Validators.phone(l10n),
                                  keyboardType: TextInputType.phone,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumber
                                  ],
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: AppDimensions.spaceMd),
                              // Same "0"/"1" values as before — only the
                              // control changed.
                              GenderSelector(
                                value: _gender,
                                maleValue: '0',
                                femaleValue: '1',
                                enabled: !isLoading,
                                onChanged: (v) => setState(() => _gender = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spaceLg),

                        // Credentials.
                        FadeIn(
                          delay: const Duration(milliseconds: 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                  controller: _password,
                                  label: l10n.password,
                                  hint: l10n.password,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  validator: Validators.password(l10n),
                                  obscureText: true,
                                  autofillHints: const [
                                    AutofillHints.newPassword
                                  ],
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: AppDimensions.spaceMd),
                              AppTextField(
                                controller: _confirmPassword,
                                label: l10n.confirmPassword,
                                hint: l10n.confirmPassword,
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: true,
                                validator: Validators.confirmPassword(
                                    l10n, () => _password.text),
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: AppDimensions.spaceLg),
                              PrimaryButton(
                                  label: l10n.createAccount,
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
                                    context, AppRoutes.signIn),
                            child: Text(l10n.haveAccountSignIn,
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
