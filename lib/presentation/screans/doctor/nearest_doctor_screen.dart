import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/location/location_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../l10n/l10n.dart';
import '../../../logic/blocs/nearest_doctor/nearest_doctor_bloc.dart';
import '../../../logic/blocs/nearest_doctor/nearest_doctor_event.dart';
import '../../../logic/blocs/nearest_doctor/nearest_doctor_state.dart';
import '../../display_format.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/motion.dart';
import '../../widgets/skeleton.dart';

/// Doctors sorted by how far their clinic is from the user, nearest first.
///
/// The location permission prompt happens when this screen opens — that is
/// the first point the app actually needs the user's position.
class NearestDoctorScreen extends StatefulWidget {
  const NearestDoctorScreen({super.key});
  @override
  State<NearestDoctorScreen> createState() => _NearestDoctorScreenState();
}

class _NearestDoctorScreenState extends State<NearestDoctorScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() =>
      context.read<NearestDoctorBloc>().add(const NearestDoctorRequested());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nearestDoctorTitle)),
      body: ContentConstraint(
        child: BlocBuilder<NearestDoctorBloc, NearestDoctorState>(
          builder: (context, state) =>
              StateSwitcher(child: _body(context, state)),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, NearestDoctorState state) {
    final l10n = context.l10n;

    if (state is NearestDoctorInitial || state is NearestDoctorLoading) {
      return const SkeletonList();
    }

    if (state is NearestDoctorError) {
      return ErrorStateView(error: state.error, onRetry: _load);
    }

    // Could not place the user. The message and the action depend on which
    // way it failed — a permanent denial can only be undone in Settings.
    if (state is NearestDoctorLocationUnavailable) {
      return EmptyStateView(
        icon: Icons.location_off_rounded,
        message: _locationMessage(l10n, state.failure),
        actionLabel: state.needsSettings
            ? l10n.nearestDoctorOpenSettings
            : l10n.retry,
        onAction: state.needsSettings
            ? () => context.read<LocationService>().openPermissionSettings()
            : _load,
      );
    }

    // The API returned no doctors at all — nothing to do with locations.
    if (state is NearestDoctorNoDoctors) {
      return EmptyStateView(
        icon: Icons.medical_services_outlined,
        message: l10n.noDoctorsFound,
        actionLabel: l10n.retry,
        onAction: _load,
      );
    }

    // Doctors loaded, but none of them had a usable location.
    if (state is NearestDoctorEmpty) {
      return EmptyStateView(
        icon: Icons.location_searching_rounded,
        message: l10n.nearestDoctorNoCoordinates,
        actionLabel: l10n.nearestDoctorBrowseAll,
        onAction: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.doctorList),
      );
    }

    final loaded = state as NearestDoctorLoaded;
    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        // One extra row for the demo-data note at the top.
        itemCount: loaded.results.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) return const _DemoLocationNote();

          final result = loaded.results[i - 1];
          final doctor = result.doctor;
          return DoctorCard(
            doctor: doctor,
            distanceLabel: formatDistance(l10n, result.distanceMetres),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.doctorDetails,
              arguments: {'doctorId': doctor.id, 'imageUrl': doctor.imageUrl},
            ),
          );
        },
      ),
    );
  }

  String _locationMessage(AppLocalizations l10n, LocationFailure failure) {
    switch (failure) {
      case LocationFailure.serviceDisabled:
        return l10n.nearestDoctorServiceDisabled;
      case LocationFailure.permissionDenied:
        return l10n.nearestDoctorPermissionDenied;
      case LocationFailure.permissionDeniedForever:
        return l10n.nearestDoctorPermissionDeniedForever;
      case LocationFailure.unavailable:
        return l10n.nearestDoctorUnavailable;
    }
  }
}

/// Says plainly that the clinic coordinates behind these distances are demo
/// data, so nobody reads them as real practice addresses.
class _DemoLocationNote extends StatelessWidget {
  const _DemoLocationNote();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: AppDimensions.iconSm, color: palette.textSecondary),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Text(context.l10n.nearestDoctorDemoNote,
                style: context.textTheme.labelSmall),
          ),
        ],
      ),
    );
  }
}
