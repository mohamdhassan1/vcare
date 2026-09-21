import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/doctor_model.dart';
import '../../l10n/l10n.dart';
import '../display_format.dart';
import '../../logic/blocs/favorites/favorites_bloc.dart';
import '../../logic/blocs/favorites/favorites_event.dart';
import '../../logic/blocs/favorites/favorites_state.dart';
import 'app_card.dart';
import 'motion.dart';

/// Shared presentation helpers so the card and the details screen show
/// the same doctor the same way.
class DoctorPresentation {
  DoctorPresentation._();

  /// Hero tag for the doctor's photo. Unique per doctor, so two cards on
  /// one screen can never collide, and stable across card → details.
  static Object heroTag(int doctorId) => 'doctor-photo-$doctorId';

  /// "4.5 · 12 reviews" — one format everywhere. Null when unrated.
  static String? rating(AppLocalizations l10n, DoctorModel doctor) {
    if (doctor.rating == null) return null;
    return '${doctor.rating} · ${l10n.reviewsCount(doctor.reviewsCount ?? 0)}';
  }

  /// See [formatPrice] — one currency presentation everywhere.
  static String price(num price) => formatPrice(price);

  /// "Specialization | Hospital", skipping missing parts.
  static String subtitle(DoctorModel doctor) => [
        doctor.specialization,
        doctor.hospital
      ].where((e) => e != null && e.isNotEmpty).join(' | ');
}

/// Doctor photo with a placeholder fallback, wrapped in a [Hero] so it
/// flies into the details screen. Works with or without an image URL
/// (the placeholder is part of the hero on both ends).
class DoctorPhoto extends StatelessWidget {
  const DoctorPhoto({
    super.key,
    required this.doctorId,
    required this.imageUrl,
    required this.size,
    this.radius = AppDimensions.radiusMd,
  });

  final int doctorId;
  final String? imageUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final placeholder = Container(
      width: size,
      height: size,
      color: palette.inputFill,
      child: Icon(Icons.person, color: palette.textHint, size: size * 0.45),
    );
    return Hero(
      tag: DoctorPresentation.heroTag(doctorId),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: imageUrl != null
            ? Image.network(imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder)
            : placeholder,
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, this.onTap});

  final DoctorModel doctor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final rating = DoctorPresentation.rating(l10n, doctor);
    final subtitle = DoctorPresentation.subtitle(doctor);
    return AppCard(
      onTap: onTap,
      semanticLabel: doctor.name,
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DoctorPhoto(doctorId: doctor.id, imageUrl: doctor.imageUrl, size: 80),
          const SizedBox(width: AppDimensions.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (doctor.degree != null) ...[
                  const SizedBox(height: 2),
                  Text(doctor.degree!,
                      style: context.textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spaceXs),
                  Text(subtitle,
                      style: context.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: AppDimensions.spaceSm),
                Row(
                  children: [
                    if (rating != null) ...[
                      Icon(Icons.star_rounded,
                          size: AppDimensions.iconSm, color: palette.star),
                      const SizedBox(width: AppDimensions.spaceXs),
                      Flexible(
                        child: Text(rating,
                            style: context.textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: AppDimensions.spaceSm),
                    ],
                    if (doctor.appointPrice != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceSm, vertical: 3),
                        decoration: BoxDecoration(
                            color: palette.primaryLight,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusPill)),
                        child: Text(
                            DoctorPresentation.price(doctor.appointPrice!),
                            style: AppTextStyles.caption.copyWith(
                                color: palette.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _FavoriteButton(doctorId: doctor.id),
        ],
      ),
    );
  }
}

/// Heart toggle with a short scale/fade between the two states.
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.doctorId});

  final int doctorId;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        // Base-state accessor: still reflects the last known set
        // while a later toggle/load error is being reported.
        final isFav = state.isFavorite(doctorId);
        return IconButton(
          tooltip: isFav
              ? context.l10n.removeFromFavorites
              : context.l10n.addToFavorites,
          onPressed: () =>
              context.read<FavoritesBloc>().add(FavoriteToggled(doctorId)),
          icon: AnimatedSwitcher(
            duration: context.motion(AppDurations.fast),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFav),
              color: isFav ? palette.error : palette.textHint,
            ),
          ),
        );
      },
    );
  }
}
