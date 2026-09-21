import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/l10n.dart';
import '../../../logic/blocs/doctor/doctor_bloc.dart';
import '../../../logic/blocs/doctor/doctor_event.dart';
import '../../../logic/blocs/doctor/doctor_state.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/motion.dart';
import '../../widgets/skeleton.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});
  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorBloc>().add(const DoctorListStarted());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.doctors)),
      body: ContentConstraint(
        child: BlocBuilder<DoctorBloc, DoctorState>(
          builder: (context, state) =>
              StateSwitcher(child: _body(context, state)),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, DoctorState state) {
    final l10n = context.l10n;
    if (state is DoctorLoading) {
      return const SkeletonList();
    }
    if (state is DoctorError) {
      return ErrorStateView(
        error: state.error,
        onRetry: () =>
            context.read<DoctorBloc>().add(const DoctorListStarted()),
      );
    }
    final loaded = state as DoctorLoaded;
    if (loaded.doctors.isEmpty) {
      return EmptyStateView(
          message: l10n.noDoctorsFound, icon: Icons.medical_services_outlined);
    }
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<DoctorBloc>().add(const DoctorListStarted()),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        itemCount: loaded.doctors.length,
        itemBuilder: (context, i) {
          final doctor = loaded.doctors[i];
          return DoctorCard(
            doctor: doctor,
            onTap: () => Navigator.pushNamed(context, AppRoutes.doctorDetails,
                arguments: {
                  'doctorId': doctor.id,
                  'imageUrl': doctor.imageUrl
                }),
          );
        },
      ),
    );
  }
}
