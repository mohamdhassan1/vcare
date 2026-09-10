import 'package:flutter/material.dart';
import 'package:vcare/presentation/widgets/app_text_field.dart';
import 'package:vcare/presentation/widgets/primary_button.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';

/// UI-only screen, per project rule: there is no /auth/forgot-password
/// endpoint in the API, so this does not perform any real request.
/// Submitting shows an honest message rather than pretending to send
/// a reset email.
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Password reset isn\'t available yet — coming in a future update.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                  'Enter your email and we\'ll send you instructions to reset your password.',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppDimensions.spaceLg),
              AppTextField(
                  controller: _email,
                  hint: 'Email',
                  validator: Validators.email),
              const SizedBox(height: AppDimensions.spaceLg),
              PrimaryButton(label: 'Reset Password', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
