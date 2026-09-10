import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/specialization_icons.dart';
import '../../../logic/blocs/home/home_bloc.dart';
import '../../../logic/blocs/home/home_event.dart';
import '../../../logic/blocs/home/home_state.dart';
import '../../widgets/doctor_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeStarted());
  }

  void _notAvailableYet(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature is coming in a future update.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<HomeBloc, HomeState>(
          listenWhen: (previous, current) => current is HomeLoaded && current.partialErrorMessage != null,
          listener: (context, state) {
            final loaded = state as HomeLoaded;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loaded.partialErrorMessage!)),
            );
          },
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HomeError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                      const SizedBox(height: AppDimensions.spaceMd),
                      ElevatedButton(
                        onPressed: () => context.read<HomeBloc>().add(const HomeStarted()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final loaded = state as HomeLoaded;
            return RefreshIndicator(
              onRefresh: () async => context.read<HomeBloc>().add(const HomeStarted()),
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hi, ${loaded.userName}!', style: AppTextStyles.h2),
                          Text('How Are you Today?', style: AppTextStyles.bodySmall),
                        ],
                      ),
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                        borderRadius: BorderRadius.circular(24),
                        child: const CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.surface,
                          child: Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),

                  // Banner — Flutter UI only; no separate photo asset available.
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceLg),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book and schedule with\nnearest doctor',
                          style: AppTextStyles.h3.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppDimensions.spaceMd),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            minimumSize: const Size(140, 44),
                          ),
                          onPressed: () => _notAvailableYet('Doctor listing'),
                          child: const Text('Find Nearby'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),

                  // Specialties
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Doctor Speciality', style: AppTextStyles.h3),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.specializationList),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  if (loaded.specializations.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceMd),
                      child: Text('No specialties found.', style: AppTextStyles.bodySmall),
                    )
                  else
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: loaded.specializations.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.spaceMd),
                        itemBuilder: (context, i) {
                          final s = loaded.specializations[i];
                          return Column(
                            children: [
                              Container(
                                width: 56, height: 56,
                                decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                                child: Icon(SpecializationIcons.iconFor(s.name), color: AppColors.primary),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(width: 64, child: Text(s.name, style: AppTextStyles.caption, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: AppDimensions.spaceLg),

                  // Recommended doctors
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recommendation Doctor', style: AppTextStyles.h3),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.doctorList),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  if (loaded.doctors.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceMd),
                      child: Text('No doctors found.', style: AppTextStyles.bodySmall),
                    )
                  else
                    ...loaded.doctors.map(
                      (d) => DoctorCard(
                        doctor: d,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.doctorDetails, arguments: d.id),
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
}