import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../logic/blocs/my_appointments/my_appointments_bloc.dart';
import '../../../logic/blocs/my_appointments/my_appointments_event.dart';
import '../../../logic/blocs/my_appointments/my_appointments_state.dart';
import '../../widgets/empty_state_view.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyAppointmentsBloc(context.read<AppointmentRepository>())..add(const MyAppointmentsStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Appointment')),
        body: BlocBuilder<MyAppointmentsBloc, MyAppointmentsState>(
          builder: (context, state) {
            if (state is MyAppointmentsLoading) return const Center(child: CircularProgressIndicator());
            if (state is MyAppointmentsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                      const SizedBox(height: AppDimensions.spaceMd),
                      ElevatedButton(
                        onPressed: () => context.read<MyAppointmentsBloc>().add(const MyAppointmentsStarted()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final loaded = state as MyAppointmentsLoaded;
            if (loaded.appointments.isEmpty) {
              return const EmptyStateView(message: 'You have no appointments yet.', icon: Icons.calendar_today_outlined);
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<MyAppointmentsBloc>().add(const MyAppointmentsStarted()),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                itemCount: loaded.appointments.length,
                itemBuilder: (context, i) {
                  final a = loaded.appointments[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
                    padding: const EdgeInsets.all(AppDimensions.spaceMd),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          child: a.doctorImageUrl != null
                              ? Image.network(a.doctorImageUrl!, width: 56, height: 56, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _placeholder())
                              : _placeholder(),
                        ),
                        const SizedBox(width: AppDimensions.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.doctorName ?? 'Doctor', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                              if (a.specialization != null) Text(a.specialization!, style: AppTextStyles.bodySmall),
                              if (a.appointmentTime != null) Text(a.appointmentTime!, style: AppTextStyles.caption),
                              if (a.price != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('\$${a.price}', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                                ),
                            ],
                          ),
                        ),
                        if (a.status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppDimensions.radiusPill)),
                            child: Text(a.status!, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 56, height: 56, color: AppColors.inputFill,
        child: const Icon(Icons.person, color: AppColors.textHint, size: 24),
      );
}