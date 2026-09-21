import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/profile_photo_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../l10n/l10n.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/profile/profile_bloc.dart';
import '../../../logic/blocs/profile/profile_event.dart';
import '../../../logic/blocs/profile/profile_state.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/logout_confirm_dialog.dart';
import '../../widgets/motion.dart';
import '../../widgets/settings_tiles.dart';
import '../../widgets/skeleton.dart';
import 'medical_records_screen.dart';
import 'payment_screen.dart';
import 'personal_information_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _photoErrorMessage(BuildContext context, ProfilePhotoError error) {
    final l10n = context.l10n;
    switch (error) {
      case ProfilePhotoError.loadFailed:
        return l10n.photoLoadFailed;
      case ProfilePhotoError.pickFailed:
        return l10n.photoPickFailed;
      case ProfilePhotoError.saveFailed:
        return l10n.photoSaveFailed;
      case ProfilePhotoError.removeFailed:
        return l10n.photoRemoveFailed;
    }
  }

  void _showPhotoOptions(BuildContext context, {required bool hasPhoto}) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusLg))),
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: AppDimensions.spaceMd),
          Text(l10n.updateProfilePhoto, style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spaceMd),
          ListTile(
              leading: Icon(Icons.photo_library_outlined,
                  color: context.palette.primary),
              title: Text(l10n.chooseFromGallery),
              onTap: () {
                Navigator.pop(sheetContext);
                context
                    .read<ProfileBloc>()
                    .add(const ProfilePhotoRequested(ImageSource.gallery));
              }),
          ListTile(
              leading: Icon(Icons.camera_alt_outlined,
                  color: context.palette.primary),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(sheetContext);
                context
                    .read<ProfileBloc>()
                    .add(const ProfilePhotoRequested(ImageSource.camera));
              }),
          // Only offered when there is a device-local photo to remove.
          if (hasPhoto)
            ListTile(
                leading:
                    Icon(Icons.delete_outline, color: context.palette.error),
                title: Text(l10n.removePhoto),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<ProfileBloc>().add(const ProfilePhotoRemoved());
                }),
          ListTile(
              leading: Icon(Icons.close_rounded,
                  color: context.palette.textSecondary),
              title: Text(l10n.cancel),
              onTap: () => Navigator.pop(sheetContext)),
          const SizedBox(height: AppDimensions.spaceMd),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (context) => ProfileBloc(context.read<UserRepository>(),
          context.read<ProfilePhotoRepository>())
        ..add(const ProfileStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.profile),
          actions: [
            Builder(
              builder: (context) => IconButton(
                  tooltip: l10n.editProfile,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _openPersonalInformation(context)),
            ),
          ],
        ),
        // Logout / session-expiry navigation is handled app-wide in
        // main.dart (via AppRouter.navigatorKey), not by this tab.
        body: BlocListener<ProfileBloc, ProfileState>(
          // Photo problems are non-blocking: the profile stays visible
          // and the user gets a clear, retryable message.
          listenWhen: (_, current) =>
              current is ProfileLoaded && current.photoError != null,
          listener: (context, state) {
            final error = (state as ProfileLoaded).photoError!;
            AppSnackBar.error(context, _photoErrorMessage(context, error));
          },
          child: ContentConstraint(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) =>
                  StateSwitcher(child: _body(context, state)),
            ),
          ),
        ),
      ),
    );
  }

  void _openPersonalInformation(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => BlocProvider.value(
              value: context.read<ProfileBloc>(),
              child: const PersonalInformationScreen())));

  Widget _body(BuildContext context, ProfileState state) {
    final l10n = context.l10n;
    if (state is ProfileLoading) return const LoadingView();
    if (state is ProfileError) {
      return ErrorStateView(
        error: state.error,
        onRetry: () => context.read<ProfileBloc>().add(const ProfileStarted()),
      );
    }
    final loaded = state as ProfileLoaded;
    final profile = loaded.profile;
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      children: [
        // Identity: photo (with a 48px edit target), name, email.
        FadeIn(
          child: Column(
            children: [
              _ProfilePhoto(
                localPhotoBytes: loaded.localPhotoBytes,
                imageUrl: profile.imageUrl,
                onEdit: () => _showPhotoOptions(context,
                    hasPhoto: loaded.localPhotoBytes != null),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              Text(profile.name,
                  style: AppTextStyles.h2, textAlign: TextAlign.center),
              if (profile.email != null) ...[
                const SizedBox(height: 2),
                Text(profile.email!,
                    style: context.textTheme.bodySmall,
                    textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceLg),

        // Quick actions.
        FadeIn(
          delay: const Duration(milliseconds: 40),
          child: Row(children: [
            // Text-only: with leading icons the labels were cut to
            // "My Appointm…" on a 420px phone. Two lines are allowed so
            // a long translation wraps instead of being clipped.
            Expanded(
                child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.myAppointments),
                    child: Text(l10n.myAppointment,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis))),
            const SizedBox(width: AppDimensions.spaceSm),
            Expanded(
                child: OutlinedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MedicalRecordsScreen())),
                    child: Text(l10n.medicalRecords,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis))),
          ]),
        ),
        const SizedBox(height: AppDimensions.spaceLg),

        // Account section.
        FadeIn(
          delay: const Duration(milliseconds: 80),
          child: SettingsGroup(
            title: l10n.accountSection,
            children: [
              SettingsRow(
                  icon: Icons.badge_outlined,
                  label: l10n.personalInformation,
                  onTap: () => _openPersonalInformation(context)),
              SettingsRow(
                  icon: Icons.science_outlined,
                  label: l10n.myTestAndDiagnosis,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MedicalRecordsScreen()))),
              SettingsRow(
                  icon: Icons.payment_outlined,
                  label: l10n.payment,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PaymentScreen()))),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMd),

        // Preferences section.
        FadeIn(
          delay: const Duration(milliseconds: 120),
          child: SettingsGroup(
            children: [
              SettingsRow(
                  icon: Icons.favorite_border_rounded,
                  label: l10n.myFavorites,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.favorites)),
              SettingsRow(
                  icon: Icons.settings_outlined,
                  label: l10n.settings,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                              value: context.read<AuthBloc>(),
                              child: const SettingsScreen())))),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceLg),

        // Destructive: tinted, no chevron; confirmation dialog unchanged.
        FadeIn(
          delay: const Duration(milliseconds: 160),
          child: DestructiveTile(
            icon: Icons.logout_rounded,
            label: l10n.logout,
            onTap: () => confirmLogout(context),
          ),
        ),
      ],
    );
  }
}

/// Avatar with the edit badge. The badge's tap target is a full 48px
/// (the visible disc is smaller), labelled for screen readers.
class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({
    required this.localPhotoBytes,
    required this.imageUrl,
    required this.onEdit,
  });

  final Uint8List? localPhotoBytes;
  final String? imageUrl;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final ImageProvider? image = localPhotoBytes != null
        ? MemoryImage(localPhotoBytes!) as ImageProvider
        : (imageUrl != null ? NetworkImage(imageUrl!) : null);
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: palette.cardBorder),
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: palette.surface,
                backgroundImage: image,
                child: image == null
                    ? Icon(Icons.person, size: 48, color: palette.textHint)
                    : null,
              ),
            ),
          ),
          // Directional: bottom-trailing corner in RTL too.
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: Tooltip(
              message: l10n.changePhoto,
              child: Semantics(
                button: true,
                label: l10n.changePhoto,
                child: ExcludeSemantics(
                  child: InkResponse(
                    onTap: onEdit,
                    radius: AppDimensions.minTouchTarget / 2,
                    child: SizedBox(
                      width: AppDimensions.minTouchTarget,
                      height: AppDimensions.minTouchTarget,
                      child: Center(
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: palette.primary,
                            shape: BoxShape.circle,
                            // Ring in the page color so the badge reads
                            // on top of any photo, light or dark.
                            border:
                                Border.all(color: palette.background, width: 2),
                          ),
                          child: Icon(Icons.camera_alt_rounded,
                              size: AppDimensions.iconSm + 2,
                              color: palette.onPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
