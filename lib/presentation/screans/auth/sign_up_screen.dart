// ignore_for_file: deprecated_member_use
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

  void _submit() {
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.spaceLg),
                    Text('Create Account', style: AppTextStyles.h1),
                    const SizedBox(height: AppDimensions.spaceXs),
                    Text('Sign up to start booking appointments',
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppDimensions.spaceLg),
                    AppTextField(
                        controller: _name,
                        hint: 'Full Name',
                        validator: (v) =>
                            Validators.required(v, field: 'Name')),
                    const SizedBox(height: AppDimensions.spaceMd),
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
                        controller: _phone,
                        hint: 'Phone Number',
                        validator: Validators.phone,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: AppDimensions.spaceMd),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Male'),
                            value: '0',
                            groupValue: _gender,
                            onChanged: (v) => setState(() => _gender = v!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Female'),
                            value: '1',
                            groupValue: _gender,
                            onChanged: (v) => setState(() => _gender = v!),
                          ),
                        ),
                      ],
                    ),
                    AppTextField(
                        controller: _password,
                        hint: 'Password',
                        validator: Validators.password,
                        obscureText: true),
                    const SizedBox(height: AppDimensions.spaceMd),
                    AppTextField(
                      controller: _confirmPassword,
                      hint: 'Confirm Password',
                      obscureText: true,
                      validator: (v) =>
                          Validators.confirmPassword(v, _password.text),
                    ),
                    const SizedBox(height: AppDimensions.spaceLg),
                    PrimaryButton(
                        label: 'Create Account',
                        isLoading: isLoading,
                        onPressed: _submit),
                    const SizedBox(height: AppDimensions.spaceMd),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.signIn),
                        child: const Text('Already have an account? Sign In'),
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
