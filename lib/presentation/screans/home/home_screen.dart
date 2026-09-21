import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/specialization_icons.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/app_snack_bar.dart';
import '../../../logic/blocs/home/home_bloc.dart';
import '../../../logic/blocs/home/home_event.dart';
import '../../../logic/blocs/home/home_state.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/motion.dart';
import '../../widgets/section_header.dart';
import '../../widgets/skeleton.dart';

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
    AppSnackBar.show(context, context.l10n.featureComingSoon(feature));
  }

  /// Localized one-line summary of the sections that failed, shown
  /// once as a SnackBar (the sections themselves also show inline
  /// errors with Retry).
  String? _partialErrorText(AppLocalizations l10n, HomeLoaded loaded) {
    final parts = <String>[
      if (loaded.profileFailed) l10n.profileUnavailable,
      if (loaded.specializationsFailed) l10n.specialtiesUnavailable,
      if (loaded.doctorsFailed) l10n.doctorsUnavailable,
    ];
    return parts.isEmpty ? null : parts.join(' ');
  }

  /// Inline state for a Home section whose request failed. Distinct
  /// from the "nothing found" text so the UI never claims a section
  /// loaded when it did not; Retry reloads Home.
  Widget _sectionUnavailable(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceSm),
      child: InlineErrorRow(
        message: message,
        onRetry: () => context.read<HomeBloc>().add(const HomeStarted()),
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onSeeAll) {
    return SectionHeader(
        title: title, actionLabel: context.l10n.seeAll, onAction: onSeeAll);
  }

  /// Shape of the loaded page (greeting, banner, specialty strip, two
  /// cards) while the three requests run, instead of a blank spinner.
  Widget _skeleton() {
    return SkeletonPulse(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 180, height: 22),
                    SizedBox(height: AppDimensions.spaceSm),
                    SkeletonBox(width: 120, height: 12),
                  ],
                ),
              ),
              SkeletonBox(width: 44, height: 44, shape: BoxShape.circle),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceLg),
          const SkeletonBox(height: 132, radius: AppDimensions.radiusLg),
          const SizedBox(height: AppDimensions.spaceLg),
          const SkeletonBox(width: 140, height: 18),
          const SizedBox(height: AppDimensions.spaceMd),
          SizedBox(
            height: _SpecialtyTile.disc,
            // Non-scrolling list, so narrow screens clip instead of overflow.
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                4,
                (_) => const Padding(
                  padding:
                      EdgeInsetsDirectional.only(end: AppDimensions.spaceMd),
                  child: SkeletonBox(
                      width: _SpecialtyTile.disc,
                      height: _SpecialtyTile.disc,
                      shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLg),
          const SkeletonBox(width: 180, height: 18),
          const SizedBox(height: AppDimensions.spaceMd),
          const DoctorCardSkeleton(),
          const DoctorCardSkeleton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<HomeBloc, HomeState>(
          listenWhen: (previous, current) =>
              current is HomeLoaded && current.partialErrorMessage != null,
          listener: (context, state) {
            final text = _partialErrorText(l10n, state as HomeLoaded);
            if (text == null) return;
            AppSnackBar.error(context, text);
          },
          builder: (context, state) =>
              StateSwitcher(child: _content(context, state)),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, HomeState state) {
    final l10n = context.l10n;
    if (state is HomeLoading) {
      return _skeleton();
    }
    if (state is HomeError) {
      return ErrorStateView(
        error: state.error,
        onRetry: () => context.read<HomeBloc>().add(const HomeStarted()),
      );
    }

    final loaded = state as HomeLoaded;
    return RefreshIndicator(
      onRefresh: () async => context.read<HomeBloc>().add(const HomeStarted()),
      child: ContentConstraint(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          children: [
            FadeIn(
                child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          loaded.userName.isEmpty
                              ? l10n.homeGreetingNoName
                              : l10n.homeGreeting(loaded.userName),
                          style: AppTextStyles.h2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(l10n.howAreYouToday,
                          style: context.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSm),
                Tooltip(
                  message: l10n.notifications,
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.notifications),
                    borderRadius: BorderRadius.circular(24),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: context.palette.surface,
                      child: Icon(Icons.notifications_none_rounded,
                          color: context.palette.textPrimary),
                    ),
                  ),
                ),
              ],
            )),
            const SizedBox(height: AppDimensions.spaceMd),

            // Search entry: read-only field that opens the real Search
            // screen (one search system; this is just the door to it).
            FadeIn(
              delay: const Duration(milliseconds: 40),
              child: _SearchEntry(
                hint: l10n.searchDoctorsHint,
                semanticsLabel: l10n.searchDoctors,
                onTap: () => Navigator.pushNamed(context, AppRoutes.search),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLg),

            // Banner — Flutter UI only; no separate photo asset available.
            FadeIn(
                delay: const Duration(milliseconds: 80),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceLg),
                  decoration: BoxDecoration(
                    color: context.palette.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeBannerTitle,
                        style: AppTextStyles.h3
                            .copyWith(color: context.palette.onPrimary),
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.palette.onPrimary,
                          foregroundColor: context.palette.primary,
                          minimumSize:
                              const Size(140, AppDimensions.minTouchTarget),
                        ),
                        onPressed: () => _notAvailableYet(l10n.doctorListing),
                        child: Text(l10n.findNearby),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppDimensions.spaceLg),

            // Specialties
            _sectionHeader(
                l10n.doctorSpeciality,
                () =>
                    Navigator.pushNamed(context, AppRoutes.specializationList)),
            if (loaded.specializationsFailed)
              _sectionUnavailable(l10n.specialtiesUnavailable)
            else if (loaded.specializations.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppDimensions.spaceMd),
                child: Text(l10n.noSpecialtiesFound,
                    style: context.textTheme.bodySmall),
              )
            else
              SizedBox(
                height: _SpecialtyTile.height,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: loaded.specializations.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppDimensions.spaceMd),
                  itemBuilder: (context, i) {
                    final s = loaded.specializations[i];
                    // Opens Search pre-filtered by this specialty
                    // (client-side filter over the real doctor list).
                    return FadeIn(
                      delay: Duration(milliseconds: 30 * (i < 8 ? i : 8)),
                      child: _SpecialtyTile(
                        name: s.name,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.search,
                            arguments: s.id),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: AppDimensions.spaceLg),

            // Recommended doctors
            _sectionHeader(l10n.recommendedDoctors,
                () => Navigator.pushNamed(context, AppRoutes.doctorList)),
            if (loaded.doctorsFailed)
              _sectionUnavailable(l10n.doctorsUnavailable)
            else if (loaded.doctors.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppDimensions.spaceMd),
                child: Text(l10n.noDoctorsFound,
                    style: context.textTheme.bodySmall),
              )
            else
              ...loaded.doctors.asMap().entries.map(
                    (e) => FadeIn(
                      delay:
                          Duration(milliseconds: 40 * (e.key < 5 ? e.key : 5)),
                      child: DoctorCard(
                        doctor: e.value,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.doctorDetails, arguments: {
                          'doctorId': e.value.id,
                          'imageUrl': e.value.imageUrl
                        }),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Read-only "search" field: looks like the Search screen input so the
/// tap feels continuous, but only navigates — no second search logic.
class _SearchEntry extends StatelessWidget {
  const _SearchEntry({
    required this.hint,
    required this.semanticsLabel,
    required this.onTap,
  });

  final String hint;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Material(
          color: palette.inputFill,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: SizedBox(
              height: AppDimensions.inputHeight,
              child: Row(
                children: [
                  const SizedBox(width: AppDimensions.spaceMd),
                  Icon(Icons.search_rounded,
                      size: AppDimensions.iconLg, color: palette.textSecondary),
                  const SizedBox(width: AppDimensions.spaceSm),
                  Expanded(
                    child: Text(hint,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: palette.textHint),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: AppDimensions.spaceMd),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Specialty shortcut: 64px icon disc + up to two lines of label, so
/// names like "Dermatology" are readable instead of truncated.
class _SpecialtyTile extends StatelessWidget {
  const _SpecialtyTile({required this.name, required this.onTap});

  static const double width = 76;
  static const double disc = 64;
  static const double height = disc + AppDimensions.spaceSm + 2 * 16 + 4;

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: name,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                Container(
                  width: disc,
                  height: disc,
                  decoration: BoxDecoration(
                      color: palette.primaryLight, shape: BoxShape.circle),
                  child: Icon(SpecializationIcons.iconFor(name),
                      size: AppDimensions.iconLg + 4, color: palette.primary),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                Flexible(
                  child: _SpecialtyLabel(
                    name: name,
                    style: context.textTheme.labelSmall
                        ?.copyWith(height: 1.25, color: palette.textPrimary),
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

/// Tile caption. Multi-word names wrap onto two lines; a single long
/// word ("Dermatology", "Gastroenterology") is scaled down to fit the
/// tile instead of being broken mid-word ("Dermatolog / y").
class _SpecialtyLabel extends StatelessWidget {
  const _SpecialtyLabel({required this.name, required this.style});

  final String name;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final text = Text(name,
        style: style,
        textAlign: TextAlign.center,
        maxLines: name.trim().contains(' ') ? 2 : 1,
        overflow: TextOverflow.ellipsis);
    if (name.trim().contains(' ')) return text;
    return FittedBox(fit: BoxFit.scaleDown, child: text);
  }
}
