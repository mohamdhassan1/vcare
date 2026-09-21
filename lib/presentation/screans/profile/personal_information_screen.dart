import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/app_snack_bar.dart';
import '../../../logic/blocs/home/home_bloc.dart';
import '../../../logic/blocs/home/home_event.dart';
import '../../../logic/blocs/profile/profile_bloc.dart';
import '../../../logic/blocs/profile/profile_event.dart';
import '../../../logic/blocs/profile/profile_state.dart';
import '../../../logic/blocs/update_profile/update_profile_bloc.dart';
import '../../../logic/blocs/update_profile/update_profile_event.dart';
import '../../../logic/blocs/update_profile/update_profile_state.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/gender_selector.dart';
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

  // Form value for gender, using the representation this project
  // already sends to /auth/register and /user/update ("0" = Male,
  // "1" = Female — unverified against the backend; kept as-is).
  // Null until prefilled from the loaded profile, so an unknown gender
  // is never silently overwritten with a default on Save.
  String? _gender;
  bool _prefilled = false;

  static const _male = '0';
  static const _female = '1';

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) _prefill(state.profile);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _prefill(UserProfileModel profile) {
    _name.text = profile.name;
    _email.text = profile.email ?? '';
    _phone.text = profile.phone ?? '';
    _gender = _genderFormValue(profile.gender);
    _prefilled = true;
  }

  /// Maps whatever the API returned for gender onto the form's
  /// "0"/"1" values. Accepts the numeric form the app itself sends and
  /// the textual form some backends echo back; anything else is
  /// treated as unknown (no radio selected).
  static String? _genderFormValue(String? raw) {
    if (raw == null) return null;
    switch (raw.trim().toLowerCase()) {
      case '0':
      case 'male':
        return _male;
      case '1':
      case 'female':
        return _female;
      default:
        return null;
    }
  }

  void _submit(BuildContext context) {
    final gender = _gender;
    if (gender == null) {
      AppSnackBar.show(context, context.l10n.pleaseSelectGender);
      return;
    }
    // No password field on this screen, so none is sent — the data
    // source omits the field entirely rather than posting "".
    context.read<UpdateProfileBloc>().add(UpdateProfileSubmitted(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        gender: gender));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (context) => UpdateProfileBloc(context.read<UserRepository>()),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.personalInformation)),
        body: BlocListener<ProfileBloc, ProfileState>(
          // Covers opening this screen while the profile was still
          // loading: prefill once it arrives, without touching build().
          listenWhen: (_, current) => !_prefilled && current is ProfileLoaded,
          listener: (_, state) =>
              setState(() => _prefill((state as ProfileLoaded).profile)),
          child: BlocConsumer<UpdateProfileBloc, UpdateProfileState>(
            listener: (context, state) {
              if (state is UpdateProfileSuccess) {
                // Re-fetch so Profile and the Home greeting show the
                // saved values from the server, not the form.
                context.read<ProfileBloc>().add(const ProfileStarted());
                if (context.mounted) {
                  context.read<HomeBloc>().add(const HomeStarted());
                }
                AppSnackBar.show(context, l10n.profileUpdated,
                    icon: Icons.check_circle_outline_rounded);
                Navigator.pop(context);
              } else if (state is UpdateProfileFailure) {
                AppSnackBar.error(context, context.errorText(state.error));
              }
            },
            builder: (context, state) {
              final isSubmitting = state is UpdateProfileSubmitting;
              // Scrollable: three fields + radios + Save don't fit above
              // the keyboard on small phones.
              // Same field/gender controls as Sign Up (Batch 6) so the two
              // forms feel alike; values and submit payload are unchanged.
              return ContentConstraint(
                maxWidth: 480,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(AppDimensions.spaceLg),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                            controller: _name,
                            label: l10n.fullName,
                            hint: l10n.fullName,
                            prefixIcon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next),
                        const SizedBox(height: AppDimensions.spaceMd),
                        AppTextField(
                            controller: _email,
                            label: l10n.email,
                            hint: l10n.email,
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            autocorrect: false,
                            textInputAction: TextInputAction.next),
                        const SizedBox(height: AppDimensions.spaceMd),
                        AppTextField(
                            controller: _phone,
                            label: l10n.phoneNumber,
                            hint: l10n.phoneNumber,
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done),
                        const SizedBox(height: AppDimensions.spaceMd),
                        // Null (unknown gender from the API) leaves both
                        // tiles unselected, exactly like the radios did.
                        GenderSelector(
                          value: _gender,
                          maleValue: _male,
                          femaleValue: _female,
                          enabled: !isSubmitting,
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                        const SizedBox(height: AppDimensions.spaceLg),
                        PrimaryButton(
                            label: l10n.save,
                            isLoading: isSubmitting,
                            onPressed: () => _submit(context)),
                      ]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
