import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/doctor_model.dart';
import '../../logic/blocs/favorites/favorites_bloc.dart';
import '../../logic/blocs/favorites/favorites_event.dart';
import '../../logic/blocs/favorites/favorites_state.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, this.onTap});

  final DoctorModel doctor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: doctor.imageUrl != null
                  ? Image.network(doctor.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
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
                    Text(doctor.degree!, style: AppTextStyles.caption),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    [doctor.specialization, doctor.hospital]
                        .where((e) => e != null && e.isNotEmpty)
                        .join(' | '),
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (doctor.rating != null) ...[
                        const Icon(Icons.star_rounded,
                            size: 16, color: AppColors.star),
                        const SizedBox(width: 4),
                        Text('${doctor.rating} (${doctor.reviewsCount ?? 0})',
                            style: AppTextStyles.caption),
                        const SizedBox(width: AppDimensions.spaceSm),
                      ],
                      if (doctor.appointPrice != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusPill)),
                          child: Text('\$${doctor.appointPrice}',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                final isFav =
                    state is FavoritesLoaded && state.isFavorite(doctor.id);
                return IconButton(
                  onPressed: () => context
                      .read<FavoritesBloc>()
                      .add(FavoriteToggled(doctor.id)),
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? AppColors.error : AppColors.textHint,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 80,
        height: 80,
        color: AppColors.inputFill,
        child: const Icon(Icons.person, color: AppColors.textHint, size: 36),
      );
}
