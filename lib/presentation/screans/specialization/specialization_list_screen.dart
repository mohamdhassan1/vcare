import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/specialization_icons.dart';
import '../../../logic/blocs/specialization/specialization_bloc.dart';
import '../../../logic/blocs/specialization/specialization_event.dart';
import '../../../logic/blocs/specialization/specialization_state.dart';
import '../../widgets/empty_state_view.dart';

class SpecializationListScreen extends StatefulWidget {
  const SpecializationListScreen({super.key});

  @override
  State<SpecializationListScreen> createState() => _SpecializationListScreenState();
}

class _SpecializationListScreenState extends State<SpecializationListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SpecializationBloc>().add(const SpecializationListStarted());
  }

  void _notAvailableYet(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Doctor listing by specialty is coming in a future update.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Speciality')),
      body: BlocBuilder<SpecializationBloc, SpecializationState>(
        builder: (context, state) {
          if (state is SpecializationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SpecializationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: AppDimensions.spaceMd),
                    ElevatedButton(
                      onPressed: () => context.read<SpecializationBloc>().add(const SpecializationListStarted()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final loaded = state as SpecializationLoaded;
          if (loaded.specializations.isEmpty) {
            return const EmptyStateView(message: 'No specialties found.', icon: Icons.medical_services_outlined);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.spaceLg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppDimensions.spaceLg,
              crossAxisSpacing: AppDimensions.spaceMd,
              childAspectRatio: 0.85,
            ),
            itemCount: loaded.specializations.length,
            itemBuilder: (context, i) {
              final s = loaded.specializations[i];
              return InkWell(
                onTap: () => _notAvailableYet(context),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                      child: Icon(SpecializationIcons.iconFor(s.name), color: AppColors.primary),
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    Text(
                      s.name,
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}