import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/specialization_icons.dart';
import '../../../l10n/l10n.dart';
import '../../../logic/blocs/specialization/specialization_bloc.dart';
import '../../../logic/blocs/specialization/specialization_event.dart';
import '../../../logic/blocs/specialization/specialization_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/motion.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/skeleton.dart';

class SpecializationListScreen extends StatefulWidget {
  const SpecializationListScreen({super.key});

  @override
  State<SpecializationListScreen> createState() =>
      _SpecializationListScreenState();
}

class _SpecializationListScreenState extends State<SpecializationListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SpecializationBloc>().add(const SpecializationListStarted());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.doctorSpeciality)),
      body: ContentConstraint(
          child: BlocBuilder<SpecializationBloc, SpecializationState>(
        builder: (context, state) {
          if (state is SpecializationLoading) {
            return const LoadingView();
          }
          if (state is SpecializationError) {
            return ErrorStateView(
              error: state.error,
              onRetry: () => context
                  .read<SpecializationBloc>()
                  .add(const SpecializationListStarted()),
            );
          }

          final loaded = state as SpecializationLoaded;
          if (loaded.specializations.isEmpty) {
            return EmptyStateView(
                message: l10n.noSpecialtiesFound,
                icon: Icons.medical_services_outlined);
          }

          // Column count follows the width (3 on phones, more on web)
          // instead of squeezing three tiles onto a 320px screen.
          return GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.spaceLg),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120,
              mainAxisSpacing: AppDimensions.spaceMd,
              crossAxisSpacing: AppDimensions.spaceMd,
              // Fixed tile height (disc + two label lines) so narrow columns
              // never overflow.
              mainAxisExtent: 132,
            ),
            itemCount: loaded.specializations.length,
            itemBuilder: (context, i) {
              final s = loaded.specializations[i];
              // Doctors of this specialty: the Search screen with its
              // specialty filter pre-selected (client-side over the real
              // doctor list — no per-specialty endpoint exists).
              return FadeIn(
                delay: Duration(milliseconds: 25 * (i < 12 ? i : 12)),
                child: AppCard(
                  semanticLabel: s.name,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceSm,
                      vertical: AppDimensions.spaceMd),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.search,
                      arguments: s.id),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            color: context.palette.primaryLight,
                            shape: BoxShape.circle),
                        child: Icon(SpecializationIcons.iconFor(s.name),
                            size: AppDimensions.iconLg + 4,
                            color: context.palette.primary),
                      ),
                      const SizedBox(height: AppDimensions.spaceSm),
                      // Flexible: with unusual font metrics the label
                      // ellipsizes instead of overflowing the tile.
                      Flexible(
                        child: Text(
                          s.name,
                          style: context.textTheme.bodySmall
                              ?.copyWith(color: context.palette.textPrimary),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      )),
    );
  }
}
