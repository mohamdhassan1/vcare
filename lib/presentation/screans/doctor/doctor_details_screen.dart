import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/doctor_repository.dart';
import '../../../logic/blocs/doctor_details/doctor_details_bloc.dart';
import '../../../logic/blocs/doctor_details/doctor_details_event.dart';
import '../../../logic/blocs/doctor_details/doctor_details_state.dart';
import '../../../logic/blocs/favorites/favorites_bloc.dart';
import '../../../logic/blocs/favorites/favorites_event.dart';
import '../../../logic/blocs/favorites/favorites_state.dart';

class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen({super.key, required this.doctorId});
  final int doctorId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorDetailsBloc(context.read<DoctorRepository>())
        ..add(DoctorDetailsStarted(doctorId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Details'),
          actions: [
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                final isFav =
                    state is FavoritesLoaded && state.isFavorite(doctorId);
                return IconButton(
                  onPressed: () => context
                      .read<FavoritesBloc>()
                      .add(FavoriteToggled(doctorId)),
                  icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? AppColors.error : null),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<DoctorDetailsBloc, DoctorDetailsState>(
          builder: (context, state) {
            if (state is DoctorDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DoctorDetailsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center),
                      const SizedBox(height: AppDimensions.spaceMd),
                      ElevatedButton(
                        onPressed: () => context
                            .read<DoctorDetailsBloc>()
                            .add(DoctorDetailsStarted(doctorId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final doctor = (state as DoctorDetailsLoaded).doctor;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLg),
                      child: doctor.imageUrl != null
                          ? Image.network(doctor.imageUrl!,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder())
                          : _placeholder(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMd),
                  Center(
                      child: Text(doctor.name,
                          style: AppTextStyles.h2,
                          textAlign: TextAlign.center)),
                  if (doctor.degree != null) ...[
                    const SizedBox(height: 2),
                    Center(
                        child: Text(doctor.degree!,
                            style: AppTextStyles.bodySmall)),
                  ],
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      [doctor.specialization, doctor.hospital]
                          .where((e) => e != null && e.isNotEmpty)
                          .join(' | '),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceSm),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppDimensions.spaceSm,
                      children: [
                        if (doctor.rating != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 20, color: AppColors.star),
                              const SizedBox(width: 4),
                              Text(
                                  '${doctor.rating} (${doctor.reviewsCount ?? 0} reviews)',
                                  style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        if (doctor.appointPrice != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusPill)),
                            child: Text('\$${doctor.appointPrice} / visit',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                  if (doctor.startTime != null && doctor.endTime != null) ...[
                    const SizedBox(height: AppDimensions.spaceLg),
                    Text('Working Hours', style: AppTextStyles.h3),
                    const SizedBox(height: AppDimensions.spaceSm),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text('${doctor.startTime} - ${doctor.endTime}',
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ],
                  if (doctor.description != null &&
                      doctor.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spaceLg),
                    Text('About', style: AppTextStyles.h3),
                    const SizedBox(height: AppDimensions.spaceSm),
                    Text(doctor.description!, style: AppTextStyles.bodyMedium),
                  ],
                  const SizedBox(height: AppDimensions.spaceLg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.bookAppointment,
                        arguments: {
                          'doctorId': doctor.id,
                          'doctorName': doctor.name
                        },
                      ),
                      child: const Text('Book Appointment'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 140,
        height: 140,
        color: AppColors.surface,
        child: const Icon(Icons.person, color: AppColors.textHint, size: 48),
      );
}
