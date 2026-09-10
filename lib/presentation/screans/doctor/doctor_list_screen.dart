import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../logic/blocs/doctor/doctor_bloc.dart';
import '../../../logic/blocs/doctor/doctor_event.dart';
import '../../../logic/blocs/doctor/doctor_state.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/empty_state_view.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Doctors')),
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorLoading) return const Center(child: CircularProgressIndicator());
          if (state is DoctorError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: AppDimensions.spaceMd),
                    ElevatedButton(onPressed: () => context.read<DoctorBloc>().add(const DoctorListStarted()), child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          final loaded = state as DoctorLoaded;
          if (loaded.doctors.isEmpty) {
            return const EmptyStateView(message: 'No doctors found.', icon: Icons.medical_services_outlined);
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<DoctorBloc>().add(const DoctorListStarted()),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              itemCount: loaded.doctors.length,
              itemBuilder: (context, i) {
                final doctor = loaded.doctors[i];
                return DoctorCard(
                  doctor: doctor,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.doctorDetails, arguments: doctor.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}