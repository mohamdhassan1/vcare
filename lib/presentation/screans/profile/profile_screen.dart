import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/profile_photo_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../../logic/blocs/profile/profile_bloc.dart';
import '../../../logic/blocs/profile/profile_event.dart';
import '../../../logic/blocs/profile/profile_state.dart';
import 'medical_records_screen.dart';
import 'payment_screen.dart';
import 'personal_information_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusLg))),
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: AppDimensions.spaceMd),
          Text('Update Profile Photo', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spaceMd),
          ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                context
                    .read<ProfileBloc>()
                    .add(const ProfilePhotoRequested(ImageSource.gallery));
              }),
          ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                context
                    .read<ProfileBloc>()
                    .add(const ProfilePhotoRequested(ImageSource.camera));
              }),
          ListTile(
              leading: const Icon(Icons.close_rounded,
                  color: AppColors.textSecondary),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(sheetContext)),
          const SizedBox(height: AppDimensions.spaceMd),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(context.read<UserRepository>(),
          context.read<ProfilePhotoRepository>())
        ..add(const ProfileStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                            value: context.read<ProfileBloc>(),
                            child: const PersonalInformationScreen()))))
          ],
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.onboarding, (route) => false);
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ProfileError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spaceLg),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(state.message,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center),
                      const SizedBox(height: AppDimensions.spaceMd),
                      ElevatedButton(
                          onPressed: () => context
                              .read<ProfileBloc>()
                              .add(const ProfileStarted()),
                          child: const Text('Retry')),
                    ]),
                  ),
                );
              }
              final loaded = state as ProfileLoaded;
              final profile = loaded.profile;
              return ListView(
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                children: [
                  Center(
                    child: Stack(children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surface,
                        backgroundImage: loaded.localPhotoBytes != null
                            ? MemoryImage(loaded.localPhotoBytes!)
                            : (profile.imageUrl != null
                                ? NetworkImage(profile.imageUrl!)
                                    as ImageProvider
                                : null),
                        child: (loaded.localPhotoBytes == null &&
                                profile.imageUrl == null)
                            ? const Icon(Icons.person,
                                size: 48, color: AppColors.textHint)
                            : null,
                      ),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                              onTap: () => _showPhotoOptions(context),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      size: 18, color: Colors.white)))),
                    ]),
                  ),
                  const SizedBox(height: AppDimensions.spaceMd),
                  Center(child: Text(profile.name, style: AppTextStyles.h2)),
                  if (profile.email != null)
                    Center(
                        child: Text(profile.email!,
                            style: AppTextStyles.bodySmall)),
                  const SizedBox(height: AppDimensions.spaceLg),
                  Row(children: [
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.myAppointments),
                            child: const Text('My Appointment'))),
                    const SizedBox(width: AppDimensions.spaceSm),
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const MedicalRecordsScreen())),
                            child: const Text('Medical records'))),
                  ]),
                  const SizedBox(height: AppDimensions.spaceLg),
                  _menuRow(
                      context,
                      Icons.badge_outlined,
                      'Personal Information',
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                  value: context.read<ProfileBloc>(),
                                  child: const PersonalInformationScreen())))),
                  _menuRow(
                      context,
                      Icons.science_outlined,
                      'My Test & Diagnosis',
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MedicalRecordsScreen()))),
                  _menuRow(
                      context,
                      Icons.payment_outlined,
                      'Payment',
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PaymentScreen()))),
                  _menuRow(
                      context,
                      Icons.settings_outlined,
                      'Settings',
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                  value: context.read<AuthBloc>(),
                                  child: const SettingsScreen())))),
                  _menuRow(
                      context,
                      Icons.favorite_border_rounded,
                      'My Favorites',
                      () => Navigator.pushNamed(context, AppRoutes.favorites)),
                  const SizedBox(height: AppDimensions.spaceLg),
                  OutlinedButton(
                      onPressed: () =>
                          context.read<AuthBloc>().add(const LogoutRequested()),
                      child: const Text('Logout')),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _menuRow(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
