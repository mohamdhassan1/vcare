import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/presentation/widgets/app_text_field.dart';
import 'package:vcare/presentation/widgets/primary_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
          SignInRequested(email: _email.text.trim(), password: _password.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (route) => false);
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.spaceLg),
                    Text('Welcome Back', style: AppTextStyles.h1),
                    const SizedBox(height: AppDimensions.spaceXs),
                    Text('Sign in to continue booking appointments',
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppDimensions.spaceLg),
                    AppTextField(
                      controller: _email,
                      hint: 'Email',
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                    ),
                    const SizedBox(height: AppDimensions.spaceMd),
                    AppTextField(
                        controller: _password,
                        hint: 'Password',
                        validator: Validators.password,
                        obscureText: true),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.forgotPassword),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    PrimaryButton(
                        label: 'Login',
                        isLoading: isLoading,
                        onPressed: _submit),
                    const SizedBox(height: AppDimensions.spaceMd),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.signUp),
                        child: const Text("Don't have an account? Sign Up"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
