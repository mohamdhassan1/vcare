import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/repositories/doctor_repository.dart';
import '../../../l10n/l10n.dart';
import '../../../logic/blocs/doctor_details/doctor_details_bloc.dart';
import '../../../logic/blocs/doctor_details/doctor_details_event.dart';
import '../../../logic/blocs/doctor_details/doctor_details_state.dart';
import '../../../logic/blocs/favorites/favorites_bloc.dart';
import '../../../logic/blocs/favorites/favorites_event.dart';
import '../../../logic/blocs/favorites/favorites_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/motion.dart';
import '../../widgets/skeleton.dart';

class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen(
      {super.key, required this.doctorId, this.initialImageUrl});

  final int doctorId;

  /// Photo URL handed over by the card that was tapped (may be null).
  /// Lets the header render — and the Hero land — before /doctor/show
  /// answers; the loaded doctor's own URL takes over afterwards.
  final String? initialImageUrl;

  /// Photo size: 40% of the width, never smaller than the old 140px and
  /// never a billboard on desktop.
  static double photoSize(double width) => (width * 0.4).clamp(140, 200);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (context) => DoctorDetailsBloc(context.read<DoctorRepository>())
        ..add(DoctorDetailsStarted(doctorId)),
      child: BlocBuilder<DoctorDetailsBloc, DoctorDetailsState>(
        builder: (context, state) {
          final doctor = state is DoctorDetailsLoaded ? state.doctor : null;
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.doctorDetails),
              actions: [
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, state) {
                    final isFav = state.isFavorite(doctorId);
                    return IconButton(
                      tooltip: isFav
                          ? l10n.removeFromFavorites
                          : l10n.addToFavorites,
                      onPressed: () => context
                          .read<FavoritesBloc>()
                          .add(FavoriteToggled(doctorId)),
                      icon: AnimatedSwitcher(
                        duration: context.motion(AppDurations.fast),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(isFav),
                            color: isFav ? context.palette.error : null),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: ContentConstraint(
              child: StateSwitcher(child: _body(context, state)),
            ),
            // Sticky CTA: always reachable, whatever the scroll position.
            bottomNavigationBar:
                doctor == null ? null : _BookBar(doctor: doctor),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, DoctorDetailsState state) {
    if (state is DoctorDetailsError) {
      return ErrorStateView(
        error: state.error,
        onRetry: () => context
            .read<DoctorDetailsBloc>()
            .add(DoctorDetailsStarted(doctorId)),
      );
    }
    if (state is DoctorDetailsLoaded) {
      return _DoctorDetailsContent(doctor: state.doctor);
    }
    // Loading: the photo we already have plus the shape of the text.
    return LayoutBuilder(
      builder: (context, constraints) => SkeletonPulse(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          children: [
            Center(
              child: DoctorPhoto(
                  doctorId: doctorId,
                  imageUrl: initialImageUrl,
                  size: photoSize(constraints.maxWidth),
                  radius: AppDimensions.radiusLg),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            const Center(child: SkeletonBox(width: 180, height: 22)),
            const SizedBox(height: AppDimensions.spaceSm),
            const Center(child: SkeletonBox(width: 120, height: 12)),
            const SizedBox(height: AppDimensions.spaceLg),
            const SkeletonBox(height: 56, radius: AppDimensions.radiusLg),
            const SizedBox(height: AppDimensions.spaceLg),
            const SkeletonBox(width: 80, height: 18),
            const SizedBox(height: AppDimensions.spaceSm),
            const SkeletonBox(height: 12),
            const SizedBox(height: AppDimensions.spaceSm),
            const SkeletonBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DoctorDetailsContent extends StatelessWidget {
  const _DoctorDetailsContent({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final rating = DoctorPresentation.rating(l10n, doctor);
    final subtitle = DoctorPresentation.subtitle(doctor);
    final hasHours = doctor.startTime != null && doctor.endTime != null;
    final hasAbout =
        doctor.description != null && doctor.description!.trim().isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Identity: photo, name, degree, specialty | hospital.
            Center(
              child: DoctorPhoto(
                  doctorId: doctor.id,
                  imageUrl: doctor.imageUrl,
                  size: DoctorDetailsScreen.photoSize(constraints.maxWidth),
                  radius: AppDimensions.radiusLg),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            FadeIn(
              child: Column(
                children: [
                  Text(doctor.name,
                      style: AppTextStyles.h2, textAlign: TextAlign.center),
                  if (doctor.degree != null) ...[
                    const SizedBox(height: 2),
                    Text(doctor.degree!,
                        style: context.textTheme.bodySmall,
                        textAlign: TextAlign.center),
                  ],
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spaceXs),
                    Text(subtitle,
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),

            // Facts at a glance: rating, price, hours — each a small tile.
            if (rating != null || doctor.appointPrice != null || hasHours) ...[
              const SizedBox(height: AppDimensions.spaceLg),
              FadeIn(
                delay: const Duration(milliseconds: 40),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppDimensions.spaceSm,
                  runSpacing: AppDimensions.spaceSm,
                  children: [
                    if (rating != null)
                      _FactTile(
                          icon: Icons.star_rounded,
                          iconColor: palette.star,
                          text: rating),
                    if (doctor.appointPrice != null)
                      _FactTile(
                          icon: Icons.payments_outlined,
                          iconColor: palette.primary,
                          text: l10n.pricePerVisit(
                              DoctorPresentation.price(doctor.appointPrice!))),
                    if (hasHours)
                      _FactTile(
                          icon: Icons.access_time_rounded,
                          iconColor: palette.textSecondary,
                          // Backend "HH:mm" values; kept LTR so the
                          // range reads start → end in Arabic too.
                          text: '${doctor.startTime} - ${doctor.endTime}',
                          textDirection: TextDirection.ltr,
                          semanticsLabel: l10n.workingHours),
                  ],
                ),
              ),
            ],

            if (hasAbout) ...[
              const SizedBox(height: AppDimensions.spaceLg),
              FadeIn(
                delay: const Duration(milliseconds: 80),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.about, style: AppTextStyles.h3),
                      const SizedBox(height: AppDimensions.spaceSm),
                      Text(doctor.description!,
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spaceLg),
          ],
        ),
      ),
    );
  }
}

/// One rounded fact ("★ 4.5 · 12 reviews", "$300 / visit", "09:00 - 17:00").
class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.textDirection,
    this.semanticsLabel,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final TextDirection? textDirection;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      label: semanticsLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd, vertical: AppDimensions.spaceSm),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(color: palette.cardBorder),
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppDimensions.iconMd, color: iconColor),
            const SizedBox(width: AppDimensions.spaceXs + 2),
            Text(text,
                style: AppTextStyles.bodySmall.copyWith(
                    color: palette.textPrimary, fontWeight: FontWeight.w600),
                textDirection: textDirection),
          ],
        ),
      ),
    );
  }
}

/// Sticky bottom bar: price summary + the existing Book Appointment
/// push (same route and arguments as before).
class _BookBar extends StatelessWidget {
  const _BookBar({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Material(
      color: palette.background,
      shape: Border(top: BorderSide(color: palette.divider)),
      child: SafeArea(
        top: false,
        child: ContentConstraint(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLg,
                AppDimensions.spaceMd,
                AppDimensions.spaceLg,
                AppDimensions.spaceMd),
            child: Row(
              children: [
                if (doctor.appointPrice != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(DoctorPresentation.price(doctor.appointPrice!),
                          style: AppTextStyles.h3
                              .copyWith(color: palette.primary)),
                      Text(l10n.perVisit, style: context.textTheme.labelSmall),
                    ],
                  ),
                  const SizedBox(width: AppDimensions.spaceLg),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.bookAppointment,
                      arguments: {
                        'doctorId': doctor.id,
                        'doctorName': doctor.name
                      },
                    ),
                    icon: const Icon(Icons.calendar_month_rounded,
                        size: AppDimensions.iconMd),
                    label: Text(l10n.bookAppointment,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
