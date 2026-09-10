// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../logic/blocs/home/home_bloc.dart';
import '../../../logic/blocs/home/home_event.dart';
import '../../../logic/blocs/profile/profile_bloc.dart';
import '../../../logic/blocs/profile/profile_event.dart';
import '../../../logic/blocs/profile/profile_state.dart';
import '../../../logic/blocs/update_profile/update_profile_bloc.dart';
import '../../../logic/blocs/update_profile/update_profile_event.dart';
import '../../../logic/blocs/update_profile/update_profile_state.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});
  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _gender = '0';
  bool _prefilled = false;

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    if (!_prefilled && profileState is ProfileLoaded) {
      _name.text = profileState.profile.name;
      _email.text = profileState.profile.email ?? '';
      _phone.text = profileState.profile.phone ?? '';
      _prefilled = true;
    }

    return BlocProvider(
      create: (context) => UpdateProfileBloc(context.read<UserRepository>()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Personal Information')),
        body: BlocConsumer<UpdateProfileBloc, UpdateProfileState>(
          listener: (context, state) {
            if (state is UpdateProfileSuccess) {
              context.read<ProfileBloc>().add(const ProfileStarted());
              if (context.mounted) {
                context.read<HomeBloc>().add(const HomeStarted());
              }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Profile updated successfully.')));
              Navigator.pop(context);
            } else if (state is UpdateProfileFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final isSubmitting = state is UpdateProfileSubmitting;
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(controller: _name, hint: 'Full Name'),
                    const SizedBox(height: AppDimensions.spaceMd),
                    AppTextField(
                        controller: _email,
                        hint: 'Email',
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: AppDimensions.spaceMd),
                    AppTextField(
                        controller: _phone,
                        hint: 'Phone Number',
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: AppDimensions.spaceMd),
                    Row(children: [
                      Expanded(
                          child: RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Male'),
                              value: '0',
                              groupValue: _gender,
                              onChanged: (v) => setState(() => _gender = v!))),
                      Expanded(
                          child: RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Female'),
                              value: '1',
                              groupValue: _gender,
                              onChanged: (v) => setState(() => _gender = v!))),
                    ]),
                    const SizedBox(height: AppDimensions.spaceLg),
                    PrimaryButton(
                        label: 'Save',
                        isLoading: isSubmitting,
                        onPressed: () => context.read<UpdateProfileBloc>().add(
                            UpdateProfileSubmitted(
                                name: _name.text.trim(),
                                email: _email.text.trim(),
                                phone: _phone.text.trim(),
                                gender: _gender))),
                  ]),
            );
          },
        ),
      ),
    );
  }
}
